%% Simulación 3D de Antena Yagi-Uda Direccional
% Visualización del patrón de radiación con lóbulos direccionales

clear all;
close all;
clc;

%% Parámetros de la antena Yagi-Uda
f = 300e6;              % Frecuencia (300 MHz - banda UHF)
c = 3e8;                % Velocidad de la luz
lambda = c/f;           % Longitud de onda
k = 2*pi/lambda;        % Número de onda

% Elementos de la Yagi (en longitudes de onda)
reflector = 0.5*lambda;
dipole = 0.47*lambda;
directors = [0.45, 0.45, 0.45]*lambda; % 3 directores
spacing = [0.2, 0.25, 0.25]*lambda;    % Espaciado entre elementos

%% Configuración de la rejilla esférica
theta = linspace(0, pi, 180);      % Ángulo polar (0 a π)
phi = linspace(0, 2*pi, 180);      % Ángulo azimutal (0 a 2π)
[Theta, Phi] = meshgrid(theta, phi);

%% Modelado del patrón de radiación (simplificado)
% Patrón del dipolo
E_dipole = abs((cos(k*dipole/2*cos(Theta)) - cos(k*dipole/2)) ./ sin(Theta));
E_dipole(isnan(E_dipole)) = 0;

% Efecto de los elementos parásitos (modelo simplificado)
director_effect = 1 + 0.5*cos(Theta).^3;  % Refuerzo dirección frontal
reflector_effect = 0.6 + 0.4*cos(Theta+pi/2).^2; % Reducción posterior

% Patrón combinado
E_total = E_dipole .* director_effect .* reflector_effect;

% Normalización
E_total = E_total/max(E_total(:));

%% Conversión a coordenadas cartesianas 3D
X = E_total .* sin(Theta) .* cos(Phi);
Y = E_total .* sin(Theta) .* sin(Phi);
Z = E_total .* cos(Theta);

%% Visualización 3D del patrón de radiación
figure('Color', 'white', 'Position', [100, 100, 1000, 800]);

% 1. Superficie del patrón de radiación
h = surf(X, Y, Z, E_total, 'EdgeColor', 'none', 'FaceAlpha', 0.7);
hold on;

% 2. Modelo de la antena (elementos lineales)
% Reflector
plot3([-0.1 0.1], [-reflector/2 reflector/2], [0 0], 'r-', 'LineWidth', 3);

% Dipolo
plot3([0 0], [-dipole/2 dipole/2], [0 0], 'b-', 'LineWidth', 4);

% Directores
for i = 1:length(directors)
    pos_x = spacing(i);
    plot3([pos_x pos_x], [-directors(i)/2 directors(i)/2], [0 0], 'k-', 'LineWidth', 3);
end

% 3. Ejes y decoración
plot3([-1.5 1.5], [0 0], [0 0], 'k--', 'LineWidth', 1); % Eje X (dirección de máxima radiación)
plot3([0 0], [-1.5 1.5], [0 0], 'k--', 'LineWidth', 1); % Eje Y
plot3([0 0], [0 0], [-1.5 1.5], 'k--', 'LineWidth', 1); % Eje Z

% 4. Configuración de la vista
axis equal tight;
grid on;
xlabel('Dirección de máxima radiación →');
ylabel('Y');
zlabel('Z');
title('Patrón de Radiación 3D de Antena Yagi-Uda Direccional', 'FontSize', 14);
colormap(jet);
colorbar('Location', 'eastoutside');
view(45, 25); % Vista inicial

% 5. Información técnica
annotation('textbox', [0.7, 0.75, 0.25, 0.2], 'String', ...
    {sprintf('Frecuencia: %.0f MHz', f/1e6), ...
     sprintf('λ = %.2f m', lambda), ...
     'Elementos:', ...
     ['- Reflector: ', num2str(reflector/lambda,2),'λ'], ...
     ['- Dipolo: ', num2str(dipole/lambda,2),'λ'], ...
     ['- Directores: 3×',num2str(directors(1)/lambda,2),'λ']}, ...
     'FitBoxToText', 'on', 'BackgroundColor', 'white');

%% Animación de rotación
for az = 0:2:360
    view(az, 25);
    drawnow;
end