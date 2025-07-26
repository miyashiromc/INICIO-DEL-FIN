% Código de optimización para la antena LPDA (versión corregida)

%% Configuración inicial
antennaObject = lpda; % Crear antena LPDA inicial

%% Definir parámetros de optimización
% Límites para los parámetros a optimizar
lb = [0.15, 0.3, 0.0002];  % Límites inferiores [BoardLength, BoardWidth, ArmWidth]
ub = [0.5, 0.5, 0.0005];   % Límites superiores

%% Opciones del algoritmo genético
options = optimoptions('ga', ...
    'PopulationSize', 50, ...
    'MaxGenerations', 30, ...
    'FunctionTolerance', 1e-4, ...
    'PlotFcn', {@gaplotbestf, @gaplotstopping});

%% Ejecutar optimización
[x_opt, fval] = ga(@evaluateAntenna, 3, [], [], [], [], lb, ub, [], options);

%% Mostrar resultados
disp('Parámetros optimizados:');
disp(['BoardLength: ', num2str(x_opt(1))]);
disp(['BoardWidth: ', num2str(x_opt(2))]);
disp(['ArmWidth base: ', num2str(x_opt(3))]);

% Crear y mostrar antena optimizada
optimizedAntenna = lpda;
optimizedAntenna.BoardLength = x_opt(1);
optimizedAntenna.BoardWidth = x_opt(2);
armWidths = linspace(x_opt(3), x_opt(3)*1.2, 14);
optimizedAntenna.ArmWidth = armWidths;
% Mantener otros parámetros como en el original
optimizedAntenna.ArmLength = antennaObject.ArmLength;
optimizedAntenna.ArmSpacing = antennaObject.ArmSpacing;

figure;
show(optimizedAntenna);
title('Antena LPDA Optimizada');

figure;
pattern(optimizedAntenna, 300e6);
title('Patrón de Radiación Optimizado');

%% Función de evaluación (debe estar al final)
function score = evaluateAntenna(x)
    % Crear antena con parámetros actuales
    ant = lpda;
    ant.BoardLength = x(1);
    ant.BoardWidth = x(2);
    
    % Mantener proporciones originales pero ajustar ancho de brazos
    armWidths = linspace(x(3), x(3)*1.2, 14); % Variación gradual
    
    % Configurar otros parámetros (basados en el diseño original)
    ant.ArmLength = [0.174, 0.14616, 0.12277, 0.10313, 0.08663, 0.07277, 0.06113, 0.05135, 0.04313, 0.03623, 0.03043, 0.02556, 0.02147, 0.01804];
    ant.ArmWidth = armWidths;
    ant.ArmSpacing = [0.05568, 0.04677, 0.03929, 0.033, 0.02772, 0.02329, 0.01956, 0.01643, 0.0138, 0.01159, 0.00974, 0.00818, 0.00687];
    
    % Analizar antena
    freqRange = (100:55:500)*1e6;
    s = sparameters(ant, freqRange);
    
    % Calcular métricas de desempeño
    vswr_value = max(vswr(s));
    gain_value = pattern(ant, 300e6, 0, 90); % Ganancia en horizonte
    
    % Función objetivo compuesta (minimizar VSWR y maximizar ganancia)
    score = (0.7 * (1/gain_value) + 0.3 * vswr_value); % Queremos minimizar este score
end