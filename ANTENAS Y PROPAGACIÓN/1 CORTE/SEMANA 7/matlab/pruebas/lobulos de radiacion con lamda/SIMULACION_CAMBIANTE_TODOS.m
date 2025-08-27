% Animación de patrones de radiación de un dipolo para L = [λ/2, λ, 3λ/2, 2λ]
clc; clear; close all;

%% Parámetros
f      = 2.6e9;       % Frecuencia (Hz)
c      = 3e8;         % Velocidad de la luz (m/s)
lambda = c/f;         % Longitud de onda (m)
k      = 2*pi/lambda; % Número de onda
lengths = [lambda/2, lambda, 3*lambda/2, 2*lambda];  % Longitudes de dipolo

%% Malla angular
n     = 360;
theta = linspace(0, 2*pi, n);  % ángulo azimutal θ
phi   = linspace(0, pi, n);    % ángulo polar   φ
[Theta, Phi] = meshgrid(theta, phi);

%% Figura y loop de animación
hFig = figure('Name','Animación Patrones Dipolo','Color','w');
while ishandle(hFig)
  for L = lengths
    % --- Cálculo del patrón Eθ ---
    E3d = abs( (cos(k*L/2 .* cos(Phi)) - cos(k*L/2)) ./ (sin(Phi) + eps) );
    E3d = E3d / max(E3d(:));  % normalizar a 1

    % --- Coordenadas cartesianas 3D ---
    [X, Y, Z] = sph2cart(Theta, pi/2 - Phi, E3d);

    % --- Corte H-plane (φ = 90°) ---
    [~, idx_phi90] = min(abs(phi - pi/2));
    E_h = E3d(idx_phi90, :);    % vector 1×n

    % --- Corte E-plane (θ = 0°) ---
    [~, idx_theta0] = min(abs(theta - 0));
    E_v = E3d(:, idx_theta0);   % vector n×1
    phi_full = [phi, phi + pi]; 
    E_full   = [E_v.', E_v.'];   % para 0°→360°

    % --- Dibujar en subplots ---
    clf;

    % 1) Patrón 3D
    subplot(1,3,1);
    surf(X, Y, Z, E3d, 'EdgeColor','none');
    axis equal tight off;
    view(45,30);
    lighting gouraud; camlight headlight;
    colormap jet; colorbar;
    title(sprintf('3D – L = %.2fλ', L/lambda),'FontSize',10);

    % 2) H-plane (panorámica horizontal)
    subplot(1,3,2);
    polarplot(theta, E_h, 'b-', 'LineWidth',2);
    title('H-plane (φ = 90°)','FontSize',10);
    rlim([0 1]);

    % 3) E-plane (corte vertical multilobular)
    subplot(1,3,3);
    polarplot(phi_full, E_full, 'r-', 'LineWidth',2);
    title('E-plane (θ = 0°)','FontSize',10);
    rlim([0 1]);

    drawnow;
    pause(1);  % pausa antes de siguiente L
  end
end
