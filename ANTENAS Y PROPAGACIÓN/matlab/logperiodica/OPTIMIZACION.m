% optimizeLPDADirectivity.m
% Script para crear, analizar y optimizar una antena LPDA
% para maximizar la directividad usando un algoritmo genético.

%% 1. Definición de Parámetros Globales para la Optimización
% Frecuencia de interés para la directividad (en Hz)
plotFrequency = 300 * 1e6; % 300 MHz

% Rangos para las variables de diseño. Ajusta estos según tus necesidades
% y las limitaciones físicas o de diseño.
minBoardLength = 0.2; maxBoardLength = 0.5;
minBoardWidth = 0.3; maxBoardWidth = 0.6;

% Rangos para el número de elementos (dipolos)
minNumElements = 8; % Mínimo de elementos a considerar
maxNumElements = 16; % Máximo de elementos a considerar

% Para asegurar que el vector de diseño tenga una longitud fija para ga,
% definimos el número máximo posible de elementos para los arrays de brazos.
maxPossibleElementsForOptimization = maxNumElements; 

% Rangos para las dimensiones de los brazos (aplicables a cada brazo)
minArmLength = 0.01; maxArmLength = 0.2;
minArmWidth = 0.0001; maxArmWidth = 0.0005;
minArmSpacing = 0.005; maxArmSpacing = 0.06;

%% 2. Configuración y Ejecución del Algoritmo Genético

% Construir los límites inferiores (lb) y superiores (ub) del vector de diseño.
% La longitud de lb y ub debe coincidir con la longitud de designParameters.
% [BoardLength, BoardWidth, NumElements, ArmLength_1...N, ArmWidth_1...N, ArmSpacing_1...N-1]

% Parámetros fijos al inicio del vector
lb_fixed = [minBoardLength, minBoardWidth, minNumElements];
ub_fixed = [maxBoardLength, maxBoardWidth, maxNumElements];

% Parámetros para los brazos (repetidos hasta maxPossibleElementsForOptimization)
lb_arms = [repmat(minArmLength, 1, maxPossibleElementsForOptimization), ...  % ArmLengths
           repmat(minArmWidth, 1, maxPossibleElementsForOptimization), ...   % ArmWidths
           repmat(minArmSpacing, 1, maxPossibleElementsForOptimization - 1)]; % ArmSpacings

ub_arms = [repmat(maxArmLength, 1, maxPossibleElementsForOptimization), ...  % ArmLengths
           repmat(maxArmWidth, 1, maxPossibleElementsForOptimization), ...   % ArmWidths
           repmat(maxArmSpacing, 1, maxPossibleElementsForOptimization - 1)]; % ArmSpacings

% Concatenar todos los límites
lb = [lb_fixed, lb_arms];
ub = [ub_fixed, ub_arms];

% Número total de variables en el vector de diseño
numVariables = length(lb);

% Opciones para el algoritmo genético
options = optimoptions('ga', ...
                       'PlotFcn', @gaplotbestf, ...     % Muestra el mejor valor de fitness en cada generación
                       'Display', 'iter', ...           % Muestra información en la ventana de comandos
                       'PopulationSize', 50, ...        % Tamaño de la población (ajustar según recursos)
                       'MaxGenerations', 100);          % Número máximo de generaciones (ajustar según tiempo)

% Ejecutar el algoritmo genético
disp('Iniciando optimización de la antena LPDA...');
% ga necesita la función objetivo y el número de variables.
% No hay restricciones de igualdad ni desigualdad lineal aquí.
% La última opción es para variables enteras, aquí no la usaremos directamente para numElements
% porque ga no maneja variables discretas de forma nativa en su input principal.
[optimalDesignParams, negMaxDirectivity] = ga(@calculateAntennaDirectivity, numVariables, [], [], [], [], lb, ub, [], options);

% El valor devuelto por ga es negativo (porque minimizamos -directividad),
% así que lo convertimos a positivo para la directividad máxima real.
maxDirectivity = -negMaxDirectivity;

disp(' ');
disp(['Optimización completada.']);
disp(['Directividad máxima encontrada: ', num2str(maxDirectivity), ' dBi (a ', num2str(plotFrequency/1e6), ' MHz)']);
disp(' ');

%% 3. Reconstruir la Antena Óptima y Visualizar

% Descodificar los parámetros del diseño óptimo encontrado
optimalBoardLength = optimalDesignParams(1);
optimalBoardWidth = optimalDesignParams(2);

optimalNumElements = round(optimalDesignParams(3));
optimalNumElements = max(minNumElements, min(maxNumElements, optimalNumElements)); % Asegura que esté en el rango

% Recalcular los índices para extraer solo los elementos necesarios
% Asegúrate de usar 'maxPossibleElementsForOptimization' para los índices base
idx_opt_armLengths_start = 4;
% El rango de los índices para extraer de designParameters debe ser siempre consistente
% con el tamaño total de designParameters, luego truncar para optimalNumElements.
idx_opt_armLengths_end_full = idx_opt_armLengths_start + maxPossibleElementsForOptimization - 1; 

idx_opt_armWidths_start = idx_opt_armLengths_end_full + 1;
idx_opt_armWidths_end_full = idx_opt_armWidths_start + maxPossibleElementsForOptimization - 1;

idx_opt_armSpacings_start = idx_opt_armWidths_end_full + 1;
% El final de los espaciados es maxPossibleElementsForOptimization - 1 elementos de espaciado
idx_opt_armSpacings_end_full = idx_opt_armSpacings_start + (maxPossibleElementsForOptimization - 1) - 1;


% Extraer las longitudes, anchos y espaciados óptimos, truncando al número de elementos óptimo
optimalArmLengths = optimalDesignParams(idx_opt_armLengths_start : idx_opt_armLengths_start + optimalNumElements - 1);
optimalArmWidths = optimalDesignParams(idx_opt_armWidths_start : idx_opt_armWidths_start + optimalNumElements - 1);

optimalArmSpacings = [];
if optimalNumElements > 1
    optimalArmSpacings = optimalDesignParams(idx_opt_armSpacings_start : idx_opt_armSpacings_start + (optimalNumElements - 1) - 1);
end

% Crear el objeto de la antena óptima
optimalAntenna = lpda;
optimalAntenna.BoardLength = optimalBoardLength;
optimalAntenna.BoardWidth = optimalBoardWidth;
optimalAntenna.ArmLength = optimalArmLengths;
optimalAntenna.ArmWidth = optimalArmWidths;

if optimalNumElements > 1
    optimalAntenna.ArmSpacing = optimalArmSpacings;
else
    disp('La antena óptima tiene solo un elemento, lo cual no es una LPDA típica.');
end

disp(' ');
disp('Parámetros de la Antena Optimizada:');
disp(['  BoardLength: ', num2str(optimalAntenna.BoardLength)]);
disp(['  BoardWidth: ', num2str(optimalAntenna.BoardWidth)]);
disp(['  Número de Elementos: ', num2str(optimalNumElements)]);
disp('  ArmLength:'); disp(optimalAntenna.ArmLength);
disp('  ArmWidth:'); disp(optimalAntenna.ArmWidth);
if optimalNumElements > 1
    disp('  ArmSpacing:'); disp(optimalAntenna.ArmSpacing);
end


% Mostrar la antena óptima
figure;
show(optimalAntenna);
title('Antena LPDA Optimizada');

% Mostrar el patrón de radiación de la antena óptima a la frecuencia de interés
figure;
pattern(optimalAntenna, plotFrequency);
title(['Patrón de Directividad de la Antena Optimizada a ', num2str(plotFrequency/1e6), ' MHz (Max D: ', num2str(maxDirectivity), ' dBi)']);

% Mostrar patrones azimutal y de elevación
figure;
patternAzimuth(optimalAntenna, plotFrequency, 0, 'Azimuth', 0:5:360);
title(['Patrón Azimutal de la Antena Optimizada a ', num2str(plotFrequency/1e6), ' MHz']);

figure;
patternElevation(optimalAntenna, plotFrequency,0,'Elevation',0:5:360);
title(['Patrón Elevación de la Antena Optimizada a ', num2str(plotFrequency/1e6), ' MHz']);


%% 4. Función Objetivo (debe ir al final del script)
% Esta función evalúa la directividad de una configuración de antena dada.
% Se define como una función local para que pueda acceder a las variables
% del script principal (`plotFrequency`, `minNumElements`, etc.).

function directivity = calculateAntennaDirectivity(designParameters)
    % Acceder a las variables definidas en el script principal (padre)
    % Usamos `evalin('base', 'variableName')` para asegurar que las variables
    % del espacio de trabajo base sean accesibles dentro de esta función local.
    % Usamos `persistent` para evitar llamar `evalin` en cada iteración, lo que mejora el rendimiento.
    persistent p_plotFrequency p_minElements p_maxElements p_maxPossibleElementsForOptimization;
    persistent p_minArmLength p_maxArmLength p_minArmWidth p_maxArmWidth p_minArmSpacing p_maxArmSpacing;

    % Inicializar las variables persistentes solo una vez
    if isempty(p_plotFrequency)
        p_plotFrequency = evalin('base', 'plotFrequency');
        p_minElements = evalin('base', 'minNumElements');
        p_maxElements = evalin('base', 'maxNumElements');
        p_maxPossibleElementsForOptimization = evalin('base', 'maxPossibleElementsForOptimization');
        p_minArmLength = evalin('base', 'minArmLength');
        p_maxArmLength = evalin('base', 'maxArmLength');
        p_minArmWidth = evalin('base', 'minArmWidth');
        p_maxArmWidth = evalin('base', 'maxArmWidth');
        p_minArmSpacing = evalin('base', 'minArmSpacing');
        p_maxArmSpacing = evalin('base', 'maxArmSpacing');
    end

    % 1. Descodificar los parámetros de diseño del vector `designParameters`
    % El orden asumido es: [BoardLength, BoardWidth, numElements, ArmLength_1...N, ArmWidth_1...N, ArmSpacing_1...N-1]
    
    boardLength = designParameters(1);
    boardWidth = designParameters(2);
    
    % El número de elementos es una variable discreta, redondear y limitar al rango
    numElements = round(designParameters(3)); 
    numElements = max(p_minElements, min(p_maxElements, numElements)); 
    
    % Calcular los índices de inicio y fin para extraer los arrays de brazos completos
    % según el `maxPossibleElementsForOptimization` para la longitud fija del vector designParameters.
    idx_armLengths_start = 4;
    idx_armLengths_end_full = idx_armLengths_start + p_maxPossibleElementsForOptimization - 1;

    idx_armWidths_start = idx_armLengths_end_full + 1;
    idx_armWidths_end_full = idx_armWidths_start + p_maxPossibleElementsForOptimization - 1;

    idx_armSpacings_start = idx_armWidths_end_full + 1;
    % La longitud del array de espaciado es (maxPossibleElementsForOptimization - 1)
    idx_armSpacings_end_full = idx_armSpacings_start + (p_maxPossibleElementsForOptimization - 1) - 1; 

    % Extraer las partes relevantes de los arrays según el 'numElements' actual
    % Asegurarse de que se toman solo los primeros 'numElements' valores de los arrays grandes.
    % Es crucial que la longitud de los arrays extraídos coincida con numElements
    % para ArmLength y ArmWidth, y (numElements - 1) para ArmSpacing.
    
    % Asegurarse de que los índices no excedan la longitud real de designParameters
    % Esto es una protección adicional si los rangos de ub y lb se definieran mal.
    % Aunque con la definición actual de lb/ub y numVariables, esto debería ser seguro.
    
    % Truncar al número de elementos actual para la simulación
    armLengths_temp = designParameters(idx_armLengths_start : min(idx_armLengths_end_full, length(designParameters)));
    armWidths_temp = designParameters(idx_armWidths_start : min(idx_armWidths_end_full, length(designParameters)));
    armSpacings_temp = designParameters(idx_armSpacings_start : min(idx_armSpacings_end_full, length(designParameters)));
    
    armLengths = armLengths_temp(1:numElements);
    armWidths = armWidths_temp(1:numElements);
    
    armSpacings = [];
    if numElements > 1
        armSpacings = armSpacings_temp(1:(numElements - 1));
    end

    % 2. Crear el objeto de la antena y simular
    try
        currentAntenna = lpda;
        currentAntenna.BoardLength = boardLength;
        currentAntenna.BoardWidth = boardWidth;
        currentAntenna.ArmLength = armLengths;
        currentAntenna.ArmWidth = armWidths;
        
        if numElements > 1 
            currentAntenna.ArmSpacing = armSpacings;
        else
            % Para un solo elemento, no hay espaciado en LPDA y se asume directividad baja.
            directivity = -inf; 
            return;
        end

        % Calcular la directividad.
        [D, ~] = pattern(currentAntenna, p_plotFrequency);
        directivity = max(D(:)); 

        % Manejar casos donde la simulación resulta en valores inválidos
        if isnan(directivity) || isinf(directivity)
            directivity = -inf; % Penalizar diseños que no se simulan bien
        end

    catch ME
        % Capturar errores de MATLAB (ej. geometría inválida)
        warning(['Error en simulación o creación de antena: ', ME.message]);
        directivity = -inf;
    end

    % El algoritmo genético busca MINIMIZAR. Para maximizar la directividad,
    % devolvemos el negativo de la directividad.
    directivity = -directivity;
end