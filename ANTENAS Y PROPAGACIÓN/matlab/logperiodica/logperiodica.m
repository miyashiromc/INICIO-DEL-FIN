% =====================================================================
%  ANTENA LOG-PERIÓDICA CON VISUALIZACIÓN 3D + LÓBULO DE RADIACIÓN
%  Autor: ChatGPT
%  Descripción: Visualización estructural y patrón de radiación idealizado
% =====================================================================

clc;
clear;
close all;

% ===================== PARÁMETROS DE LA ANTENA =====================
L1 = 1.74;        % Longitud inicial (m)
tau = 0.58;      % Factor de escala
sigma = 0.159;     % Espaciado relativo
N = 15;           % Número total de elementos

% Inicialización
L = zeros(1, N);      % Longitudes de dipolos
d = zeros(1, N);      % Espaciamiento entre elementos
x_pos = zeros(1, N);  % Posiciones acumuladas sobre el eje X

% Cálculos
L(1) = L1;
d(1) = 2 * L(1) * sigma;
x_pos(1) = 0;

for n = 2:N
    L(n) = L(n-1) * tau;
    d(n) = 2 * L(n) * sigma;
    x_pos(n) = x_pos(n-1) + d(n-1);
end

% ===================== FIGURA: ESTRUCTURA DE LA ANTENA =====================
figure('Color','w', 'Name', 'Antena Log-Periódica', 'NumberTitle', 'off')
subplot(1,2,1)
hold on
grid on
axis equal
xlabel('X (m)', 'FontWeight', 'bold')
ylabel('Y (m)', 'FontWeight', 'bold')
zlabel('Z (m)', 'FontWeight', 'bold')
title('Estructura 3D de la Antena Log-Periódica', 'FontSize', 12)

colors = jet(N); % Colores diferentes para cada dipolo

for n = 1:N
    x = [x_pos(n), x_pos(n)];
    y = [-L(n)/2, L(n)/2];
    z = [0, 0];
    plot3(x, y, z, 'LineWidth', 2, 'Color', colors(n,:));
end

view(45, 30)
text(x_pos(end), 0, 0.1, sprintf('N = %d elementos', N), 'FontSize', 10, 'FontWeight', 'bold')

% ===================== FIGURA: LÓBULO DE RADIACIÓN =====================
subplot(1,2,2)
[theta, phi] = meshgrid(linspace(0, pi, 60), linspace(0, 2*pi, 60));
n_lobulo = 6;  % Ajuste del ancho del haz
R = abs(cos(theta)).^n_lobulo;

% Conversión a coordenadas cartesianas
X = R .* sin(theta) .* cos(phi);
Y = R .* sin(theta) .* sin(phi);
Z = R .* cos(theta);

% Superficie del patrón
surf(X, Y, Z, R, 'EdgeColor', 'none')
title('Lóbulo de Radiación Aproximado', 'FontSize', 12)
xlabel('X', 'FontWeight', 'bold')
ylabel('Y', 'FontWeight', 'bold')
zlabel('Z', 'FontWeight', 'bold')
axis equal
colormap turbo
colorbar
view(45,30)
lighting gouraud
camlight headlight

% ===================== INFORMACIÓN ADICIONAL =====================
annotation('textbox', [0.15 0.01 0.7 0.05], 'String', ...
    'Frecuencia máxima: 500 MHz | τ = 0.875 | σ = 0.15 | Long. inicial = 1.68 m | Elementos: 18', ...
    'HorizontalAlignment', 'center', 'FontSize', 9, 'EdgeColor', 'none');