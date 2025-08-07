function fourier_xy_3d_animacion()
    % Define el rango para x e y en [-pi, pi]
    x = -pi:0.1:pi;
    y = -pi:0.1:pi;
    [X, Y] = meshgrid(x, y);

    % Define la función original: f(x,y) = x * y
    Z_original = X .* Y;

    % Crea la figura y los ejes
    fig = figure('Name', 'Serie de Fourier 3D para f(x,y) = x*y', 'NumberTitle', 'off');
    ax = axes('Parent', fig);

    % Plotea la función original como una malla transparente
    mesh(ax, X, Y, Z_original, 'EdgeColor', [0.7 0.7 0.7], 'FaceAlpha', 0.2, 'DisplayName', 'Función Original');
    hold(ax, 'on');

    % Inicializa la suma de Fourier
    Z_fourier_sum = zeros(size(X));

    % Plotea la superficie inicial de la serie de Fourier
    h_fourier_surface = mesh(ax, X, Y, Z_fourier_sum, 'FaceColor', 'interp', 'EdgeColor', 'none', 'DisplayName', 'Serie de Fourier');

    % Configura etiquetas y título
    title(ax, 'Aproximación de Serie de Fourier para $f(x,y) = xy$', 'Interpreter', 'latex');
    xlabel(ax, 'x', 'Interpreter', 'latex');
    ylabel(ax, 'y', 'Interpreter', 'latex');
    zlabel(ax, 'f(x,y)', 'Interpreter', 'latex');
    legend(ax, 'Location', 'northwest');
    grid(ax, 'on');

    % Ajusta los límites del eje Z para una mejor visualización
    zlim(ax, [min(Z_original(:))-0.5 max(Z_original(:))+0.5]);

    % Crea un slider para controlar el número de iteraciones
    uicontrol('Style', 'slider', ...
              'Min', 0, 'Max', 20, 'Value', 0, ... % Número máximo de términos para m y n
              'SliderStep', [1/20 1/10], ...
              'Position', [50 20 400 20], ...
              'Callback', @updatePlot, ...
              'Tag', 'numIterationsSlider');

    uicontrol('Style', 'text', ...
              'String', 'Iteraciones (m,n): 0', ...
              'Position', [50 45 150 20], ...
              'Tag', 'iterationsText');

    function updatePlot(~, ~)
        % Obtiene el valor del slider
        slider = findobj('Tag', 'numIterationsSlider');
        num_iterations = round(get(slider, 'Value'));

        % Actualiza el texto del número de iteraciones
        text_label = findobj('Tag', 'iterationsText');
        set(text_label, 'String', ['Iteraciones (m,n): ' num2str(num_iterations)]);

        % Reinicia la suma de Fourier
        Z_fourier_current = zeros(size(X));

        % Calcula la suma de Fourier usando los coeficientes D_mn
        % Solo sumamos desde m=1 y n=1 porque los demás coeficientes son cero
        for m = 1:num_iterations
            for n = 1:num_iterations
                % Coeficiente D_mn = (4 * (-1)^(m+n)) / (m*n)
                D_mn = (4 * (-1)^(m+n)) / (m*n);
                
                % Suma el término correspondiente a la serie
                Z_fourier_current = Z_fourier_current + D_mn * sin(m*X) .* sin(n*Y);
            end
        end

        % Actualiza la superficie de la serie de Fourier
        set(h_fourier_surface, 'ZData', Z_fourier_current);
        drawnow;
    end
end
