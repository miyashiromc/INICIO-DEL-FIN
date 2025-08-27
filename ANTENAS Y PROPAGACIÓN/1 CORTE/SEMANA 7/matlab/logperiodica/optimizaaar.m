function [optimalDesignParams, maxDirectivity] = optimizaaar()
    % Función principal compatible con code generation
    % Define todos los parámetros internamente en lugar de usar evalin
    
    %% 1. Parámetros de Diseño (ahora variables locales)
    plotFrequency = 300 * 1e6;
    
    % Rangos de diseño
    minBoardLength = 0.2; maxBoardLength = 0.5;
    minBoardWidth = 0.3; maxBoardWidth = 0.6;
    minNumElements = 8; maxNumElements = 16;
    maxPossibleElementsForOptimization = maxNumElements;
    
    minArmLength = 0.01; maxArmLength = 0.2;
    minArmWidth = 0.0001; maxArmWidth = 0.0005;
    minArmSpacing = 0.005; maxArmSpacing = 0.06;

    %% 2. Configuración de Límites
    lb_fixed = [minBoardLength, minBoardWidth, minNumElements];
    ub_fixed = [maxBoardLength, maxBoardWidth, maxNumElements];
    
    lb_arms = [repmat(minArmLength, 1, maxPossibleElementsForOptimization), ...
               repmat(minArmWidth, 1, maxPossibleElementsForOptimization), ...
               repmat(minArmSpacing, 1, maxPossibleElementsForOptimization - 1)];
    
    ub_arms = [repmat(maxArmLength, 1, maxPossibleElementsForOptimization), ...
               repmat(maxArmWidth, 1, maxPossibleElementsForOptimization), ...
               repmat(maxArmSpacing, 1, maxPossibleElementsForOptimization - 1)];
    
    lb = [lb_fixed, lb_arms];
    ub = [ub_fixed, ub_arms];
    numVariables = length(lb);

    %% 3. Función Objetivo Anidada (sin evalin)
    function directivity = nestedCalculateDirectivity(designParameters)
        % Descodificación de parámetros
        boardLength = designParameters(1);
        boardWidth = designParameters(2);
        numElements = round(max(minNumElements, min(maxNumElements, designParameters(3))));
        
        % Extracción de parámetros de los brazos
        idx_start = 4;
        armLengths = designParameters(idx_start:idx_start+numElements-1);
        armWidths = designParameters(idx_start+maxPossibleElementsForOptimization:...
                                  idx_start+maxPossibleElementsForOptimization+numElements-1);
        
        % Validaciones geométricas
        if any(armLengths <= 0) || any(armWidths <= 0) || ...
           (numElements > 1 && any(designParameters(idx_start+2*maxPossibleElementsForOptimization:...
           idx_start+2*maxPossibleElementsForOptimization+numElements-2) <= 0))
            directivity = inf; % Penalización para minimización
            return;
        end
        
        % Cálculo de directividad (simplificado para ejemplo)
        % NOTA: En implementación real necesitarías una alternativa a pattern()
        directivity = -sum(armLengths); % Placeholder - maximiza longitud total
    end

    %% 4. Optimización (usando fmincon como alternativa a ga)
    options = optimoptions('fmincon', 'Display', 'iter', 'MaxIterations', 50);
    initialParams = (lb + ub)/2; % Punto medio como valor inicial
    
    [optimalDesignParams, negMaxDirectivity] = fmincon(@nestedCalculateDirectivity, ...
        initialParams, [], [], [], [], lb, ub, [], options);
    
    maxDirectivity = -negMaxDirectivity;
    
    %% 5. Post-procesamiento (sin funciones no soportadas)
    % Guardar resultados en archivo en lugar de mostrar gráficos
    save('optimized_antenna_params.mat', 'optimalDesignParams', 'maxDirectivity');
    
    % Mostrar resumen en consola
    fprintf('Optimización completada. Directividad estimada: %.2f\n', maxDirectivity);
end