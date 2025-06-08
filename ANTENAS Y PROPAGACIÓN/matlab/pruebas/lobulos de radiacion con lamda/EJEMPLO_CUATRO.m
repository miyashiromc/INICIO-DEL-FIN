% Dipole L = 2*lambda - Patrón 3D y cortes H-plane y E-plane
clc; clear; close all;

% Parámetros
f      = 2.6e9;
c      = 3e8;
lambda = c/f;
L      = 2*lambda;    % dipolo de longitud 2*lambda
k      = 2*pi/lambda;

% Malla angular
n     = 360;
theta = linspace(0,2*pi,n);
phi   = linspace(0,pi,n);
[Theta,Phi] = meshgrid(theta,phi);

% Patrón E(theta,phi) normalizado
E = abs((cos(k*L/2.*cos(Phi)) - cos(k*L/2))./(sin(Phi)+eps));
E = E / max(E(:));

% Patrón 3D
[X,Y,Z] = sph2cart(Theta,pi/2-Phi,E);
figure;
surf(X,Y,Z,E,'EdgeColor','none');
axis equal; axis off;
colormap jet; colorbar;
view(40,30);
lighting gouraud; camlight headlight;
title('3D - Dipole L=2*lambda');

% H-plane (phi = pi/2)
[~,i] = min(abs(phi - pi/2));
Eh = E(i,:);
figure;
polarplot(theta,Eh,'b','LineWidth',2);
title('H-plane (phi=pi/2) - L=2*lambda');

% E-plane (theta = 0)
[~,j] = min(abs(theta - 0));
Ev = E(:,j);
phi_full = [phi, phi+pi];
Ev_full  = [Ev.', Ev.'];
figure;
polarplot(phi_full,Ev_full,'r','LineWidth',2);
title('E-plane (theta=0) - L=2*lambda');
