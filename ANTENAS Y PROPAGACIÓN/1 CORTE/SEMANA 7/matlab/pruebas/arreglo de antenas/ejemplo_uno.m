function antenna_array_simulation
    % Crear la interfaz gráfica
    fig = figure('Name', 'Simulación de Arreglo de Dipolos', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1000, 800], 'Color', [0.95 0.95 0.95]);
    
    % Controles deslizantes
    uicontrol('Style', 'text', 'Position', [50 750 200 20], ...
              'String', 'Número de elementos (N):', 'BackgroundColor', [0.95 0.95 0.95]);
    N_slider = uicontrol('Style', 'slider', 'Position', [50 730 200 20], ...
                         'Min', 1, 'Max', 20, 'Value', 4, 'SliderStep', [1/19 2/19]);
    
    uicontrol('Style', 'text', 'Position', [50 700 200 20], ...
              'String', 'Separación entre elementos (d/λ):', 'BackgroundColor', [0.95 0.95 0.95]);
    d_slider = uicontrol('Style', 'slider', 'Position', [50 680 200 20], ...
                         'Min', 0.1, 'Max', 2, 'Value', 0.5, 'SliderStep', [0.1/1.9 0.2/1.9]);
    
    % Etiquetas para valores actuales
    N_label = uicontrol('Style', 'text', 'Position', [260 730 50 20], 'String', '4');
    d_label = uicontrol('Style', 'text', 'Position', [260 680 50 20], 'String', '0.5');
    
    % Área de gráficos - Usar polaraxes para los cortes
    ax_3d = subplot(2,2,[1,3], 'Parent', fig);
    
    % Crear ejes polares para los cortes
    ax_h = polaraxes('Parent', fig, 'Position', [0.55 0.55 0.4 0.4]);
    ax_e = polaraxes('Parent', fig, 'Position', [0.55 0.05 0.4 0.4]);
    
    % Configurar los ejes
    title(ax_3d, 'Patrón de radiación 3D');
    title(ax_h, 'Corte H (Plano XY)');
    title(ax_e, 'Corte E (Plano XZ)');
    
    % Función de actualización
    function update_plots(~,~)
        N = round(get(N_slider, 'Value'));
        d = get(d_slider, 'Value');
        
        set(N_label, 'String', num2str(N));
        set(d_label, 'String', num2str(d));
        
        % Calcular el patrón de radiación
        [theta, phi, F] = calculate_radiation_pattern(N, d);
        
        % Graficar patrón 3D
        plot_3d_pattern(ax_3d, theta, phi, F);
        
        % Graficar cortes
        plot_cuts(ax_h, ax_e, theta, phi, F);
    end

    % Configurar callbacks
    set(N_slider, 'Callback', @update_plots);
    set(d_slider, 'Callback', @update_plots);
    
    % Ejecutar primera actualización
    update_plots();
end

function [theta, phi, F] = calculate_radiation_pattern(N, d)
    % Crear rejilla de ángulos
    [theta, phi] = meshgrid(linspace(0, pi, 181), linspace(0, 2*pi, 361));
    
    % Patrón del elemento (dipolo λ/2)
    Fe = abs(cos(pi/2*cos(theta)) ./ sin(theta));
    Fe(theta==0 | theta==pi) = 0; % Evitar división por cero
    
    % Factor de arreglo
    k = 2*pi; % Número de onda (k = 2π/λ, pero normalizado a λ=1)
    psi = k * d * sin(theta) .* cos(phi);
    Fa = sin(N*psi/2) ./ (N*sin(psi/2));
    Fa(psi==0) = 1; % Límite cuando ψ→0
    
    % Patrón total
    F = Fe .* abs(Fa);
end

function plot_3d_pattern(ax, theta, phi, F)
    % Convertir a coordenadas cartesianas
    F_normalized = F / max(F(:));
    [x, y, z] = sph2cart(phi, pi/2-theta, F_normalized);
    
    % Graficar
    cla(ax);
    surf(ax, x, y, z, F_normalized, 'EdgeColor', 'none');
    axis(ax, 'equal');
    colormap(ax, 'jet');
    colorbar(ax);
    xlabel(ax, 'X');
    ylabel(ax, 'Y');
    zlabel(ax, 'Z');
    title(ax, 'Patrón de radiación 3D');
    view(ax, 30, 30);
end

function plot_cuts(ax_h, ax_e, theta, phi, F)
    % Corte H (plano XY, theta=pi/2)
    idx_theta = find(abs(theta(1,:) - pi/2) < 0.01, 1);
    F_h = F(:,idx_theta);
    phi_h = phi(:,idx_theta);
    
    % Corte E (plano XZ, phi=0)
    idx_phi1 = find(abs(phi(:,1)) < 0.01, 1);
    idx_phi2 = find(abs(phi(:,1) - pi) < 0.01, 1);
    F_e = [flipud(F(idx_phi2:end,1)); F(1:idx_phi1,1)];
    theta_e = [flipud(pi - theta(idx_phi2:end,1)); theta(1:idx_phi1,1)];
    
    % Graficar cortes
    cla(ax_h);
    polarplot(ax_h, phi_h, F_h / max(F_h), 'LineWidth', 2);
    title(ax_h, 'Corte H (Plano XY)');
    
    cla(ax_e);
    polarplot(ax_e, theta_e, F_e / max(F_e), 'LineWidth', 2);
    title(ax_e, 'Corte E (Plano XZ)');
end