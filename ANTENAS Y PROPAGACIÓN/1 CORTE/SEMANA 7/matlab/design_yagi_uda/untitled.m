function untitled()
    % Interfaz gráfica para controlar el número de directores
    fig = figure('Name', 'Simulador de Antena Yagi', 'NumberTitle', 'off', 'Position', [100 100 900 700]);
    
    % Panel de control
    uicontrol('Style', 'text', 'String', 'Número de Directores:',...
              'Position', [20 650 150 20], 'HorizontalAlignment', 'left');
    director_slider = uicontrol('Style', 'slider',...
                              'Min', 0, 'Max', 10, 'Value', 3,...
                              'Position', [20 630 150 20],...
                              'Callback', @update_plot);
    uicontrol('Style', 'text', 'String', '0',...
              'Position', [20 610 20 15], 'HorizontalAlignment', 'left');
    uicontrol('Style', 'text', 'String', '10',...
              'Position', [150 610 20 15], 'HorizontalAlignment', 'right');
    
    % Inicialización
    update_plot(director_slider, []);
    
    function update_plot(~,~)
        % Obtener número de directores del slider
        num_directors = round(get(director_slider, 'Value'));
        total_elements = 2 + num_directors; % Reflector + Dipolo + Directores
        
        % Parámetros de la antena Yagi
        f = 300e6;          % Frecuencia de operación (300 MHz - banda UHF)
        c = 3e8;            % Velocidad de la luz
        lambda = c/f;       % Longitud de onda
        
        % Configuración de los elementos
        elements_length = [0.5, 0.47] * lambda; % Reflector y dipolo
        
        % Añadir directores si existen
        if num_directors > 0
            director_lengths = linspace(0.45, 0.4, num_directors) * lambda;
            elements_length = [elements_length, director_lengths];
        end
        
        % Posiciones de los elementos
        elements_pos = [-0.25*lambda, 0]; % Reflector y dipolo
        
        % Añadir posiciones de directores con espaciado progresivo
        if num_directors > 0
            director_spacing = linspace(0.3, 0.35, num_directors) * lambda;
            elements_pos = [elements_pos, cumsum(director_spacing) + elements_pos(end)];
        end
        
        % Cálculo del patrón de radiación
        theta = linspace(0, 2*pi, 361);  % Ángulo azimutal
        phi = linspace(0, pi, 181);      % Ángulo de elevación
        
        % Patrón del dipolo (elemento radiante)
        dipole_pattern = cos(pi/2 * cos(theta)) ./ sin(theta);
        dipole_pattern(isnan(dipole_pattern)) = 0;
        
        % Factor de arreglo (array factor)
        k = 2*pi/lambda;
        phases = zeros(1, total_elements);
        if total_elements > 2
            phases(3:end) = linspace(-pi/4, -pi/2, total_elements-2);
        end
        
        AF = zeros(size(theta));
        for n = 1:total_elements
            AF = AF + exp(1i*(k*elements_pos(n)*cos(theta) + phases(n)));
        end
        
        % Patrón total normalizado
        total_pattern = abs(dipole_pattern .* AF);
        total_pattern = total_pattern / max(total_pattern);
        
        % Planos E y H
        E_plane = total_pattern;
        H_beamwidth = 90 - num_directors*5; % Ancho de haz en grados
        H_plane = cos(phi).^(H_beamwidth/10);
        H_plane = H_plane / max(H_plane);
        
        % Crear patrón 3D correctamente dimensionado
        [Theta, Phi] = meshgrid(theta, phi);
        Z = (total_pattern .* H_plane')';
        Z = Z/max(Z(:));
        
        % Visualización
        clf(fig);
        
        % Recrear controles
        uicontrol('Style', 'text', 'String', 'Número de Directores:',...
                  'Position', [20 650 150 20], 'HorizontalAlignment', 'left');
        director_slider = uicontrol('Style', 'slider',...
                                  'Min', 0, 'Max', 10, 'Value', num_directors,...
                                  'Position', [20 630 150 20],...
                                  'Callback', @update_plot);
        uicontrol('Style', 'text', 'String', '0',...
                  'Position', [20 610 20 15], 'HorizontalAlignment', 'left');
        uicontrol('Style', 'text', 'String', '10',...
                  'Position', [150 610 20 15], 'HorizontalAlignment', 'right');
        
        % Gráfico 3D (corregido)
        subplot(2,2,1);
        [X, Y, Z_3d] = sph2cart(Theta, pi/2-Phi, Z);
        surf(X, Y, Z_3d, 20*log10(Z+eps), 'EdgeColor', 'none');
        axis equal;
        title(sprintf('Patrón 3D - %d elementos', total_elements));
        xlabel('X');
        ylabel('Y');
        zlabel('Ganancia (dB)');
        colormap('jet');
        colorbar;
        view(135, 30);
        
        % Plano E (corte vertical)
        subplot(2,2,2);
        polarplot(theta, E_plane, 'LineWidth', 2);
        title('Plano E (Elevación)');
        rlim([0 1]);
        set(gca, 'ThetaZeroLocation', 'top');
        
        % Plano H (corte horizontal)
        subplot(2,2,3);
        polarplot(phi, H_plane, 'LineWidth', 2, 'Color', 'r');
        title('Plano H (Azimut)');
        rlim([0 1]);
        set(gca, 'ThetaZeroLocation', 'top');
        
        % Diagrama comparativo
        subplot(2,2,4);
        plot(theta*180/pi, 20*log10(E_plane+eps), 'b', 'LineWidth', 2);
        hold on;
        plot(phi*180/pi, 20*log10(H_plane+eps), 'r', 'LineWidth', 2);
        title('Comparación Planos E y H');
        xlabel('Ángulo [°]');
        ylabel('Ganancia (dB)');
        legend('Plano E', 'Plano H', 'Location', 'SouthEast');
        grid on;
        axis([0 180 -30 0]);
        
        % Información técnica
        annotation('textbox', [0.15 0.05 0.7 0.1], 'String',...
                 sprintf('Antena Yagi con %d elementos (1 reflector, 1 dipolo, %d directores)\nGanancia estimada: %.1f dBi | Ancho de haz H: %.1f°',...
                 total_elements, num_directors,...
                 8 + num_directors*1.5, H_beamwidth),...
                 'EdgeColor', 'none', 'HorizontalAlignment', 'center');
    end
end