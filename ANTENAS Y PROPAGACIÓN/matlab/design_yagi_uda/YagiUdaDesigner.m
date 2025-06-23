classdef YagiUdaDesigner < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                matlab.ui.Figure
        FrequencyMHzLabel       matlab.ui.control.Label
        FrequencyEditField      matlab.ui.control.NumericEditField
        NumberofDirectorsLabel  matlab.ui.control.Label
        DirectorsSpinner        matlab.ui.control.Spinner
        ReflectorLengthmLabel   matlab.ui.control.Label
        ReflectorLengthEditField matlab.ui.control.NumericEditField
        DipoleLengthmLabel      matlab.ui.control.Label
        DipoleLengthEditField   matlab.ui.control.NumericEditField
        DirectorLengthmLabel    matlab.ui.control.Label
        DirectorLengthEditField matlab.ui.control.NumericEditField
        ReflectorSpacingmLabel  matlab.ui.control.Label
        ReflectorSpacingEditField matlab.ui.control.NumericEditField
        DirectorSpacingmLabel   matlab.ui.control.Label
        DirectorSpacingEditField matlab.ui.control.NumericEditField
        DiameterLabel           matlab.ui.control.Label
        DiameterEditField       matlab.ui.control.NumericEditField
        SimulateButton          matlab.ui.control.Button
        UIAxes3D               matlab.ui.control.UIAxes
        UIAxesAzimuth          matlab.ui.control.UIAxes
        UIAxesElevation        matlab.ui.control.UIAxes
        ResultsTextArea        matlab.ui.control.TextArea
    end

    methods (Access = private)

        function SimulateButtonPushed(app, ~)
            % Get user inputs
            f_MHz = app.FrequencyEditField.Value;
            f = f_MHz * 1e6; % Convert MHz to Hz
            c = 3e8; % Speed of light
            lambda = c / f; % Wavelength in meters
            num_directors = app.DirectorsSpinner.Value;
            conductor_diameter = app.DiameterEditField.Value;
            
            % Calculate element lengths based on document formulas (pages 34-35)
            L_reflector = 150 / f_MHz; % Reflector length (page 34)
            L_dipole = 143 / f_MHz;    % Dipole length (page 34)
            L_director = 138 / f_MHz;   % Director length (page 35)
            
            % Calculate spacings based on optimal values (page 35)
            s_reflector = 0.15 * lambda; % Reflector spacing (page 14)
            s_director = 0.11 * lambda;  % Director spacing (page 3)
            
            % Update UI fields with calculated values
            app.ReflectorLengthEditField.Value = L_reflector;
            app.DipoleLengthEditField.Value = L_dipole;
            app.DirectorLengthEditField.Value = L_director;
            app.ReflectorSpacingEditField.Value = s_reflector;
            app.DirectorSpacingEditField.Value = s_director;
            
            % Element positions and lengths
            positions = zeros(1, num_directors + 2); % Reflector, Dipole, Directors
            lengths = zeros(1, num_directors + 2);
            positions(1) = 0; % Reflector at origin
            positions(2) = s_reflector; % Dipole position
            lengths(1) = L_reflector;
            lengths(2) = L_dipole;
            for i = 1:num_directors
                positions(i + 2) = positions(2) + i * s_director;
                lengths(i + 2) = L_director * (1 - 0.02*i); % Slightly shorter directors
            end
            
            % Phase shifts based on document (page 14)
            % Reflector: inductive, phase lag; Directors: capacitive, phase lead
            phases = zeros(1, num_directors + 2);
            phases(1) = -180 * pi/180 + -40 * pi/180; % Reflector (page 14)
            phases(2) = 0; % Active dipole
            for i = 1:num_directors
                phases(i + 2) = -165 * pi/180 + 20 * pi/180; % Director (page 14)
            end
            
            % Calculate array factor
            theta = linspace(0, pi, 181); % 0 to 180 degrees
            phi = linspace(0, 2*pi, 361); % 0 to 360 degrees
            [THETA, PHI] = meshgrid(theta, phi);
            k = 2 * pi / lambda;
            AF = zeros(size(THETA));
            
            for i = 1:length(positions)
                % Array factor contribution
                AF = AF + lengths(i)/lambda * exp(1j * (k * positions(i) * sin(THETA) + phases(i));
            end
            
            AF = abs(AF).^2; % Magnitude squared for power
            AF = AF / max(AF(:)); % Normalize
            
            % Dipole pattern (sin^2 for half-wave dipole)
            dipole_pattern = (cos(pi/2 * cos(THETA))./sin(THETA)).^2;
            dipole_pattern(isnan(dipole_pattern)) = 0;
            
            % Total pattern (array factor * element pattern)
            pattern = AF .* dipole_pattern;
            pattern = pattern / max(pattern(:)); % Normalize
            pattern_db = 10 * log10(pattern + eps); % Convert to dB
            
            % Calculate gain (page 7: 5-20 dB typical)
            max_gain = 5 + num_directors; % Approximate formula from document
            pattern_db = pattern_db + max_gain; % Scale to expected gain
            
            % Folded dipole impedance (page 36)
            Z_dipole = 73.1; % Standard half-wave dipole impedance
            Z_folded = 4 * Z_dipole; % Folded dipole impedance
            
            % Calculate front-to-back ratio (page 7: 5-15 dB)
            fbr = 10 + num_directors; % Approximate from document
            
            % Plot 3D pattern
            cla(app.UIAxes3D);
            [X, Y, Z] = sph2cart(PHI, pi/2 - THETA, pattern_db + 30); % +30 to avoid negative values
            surf(app.UIAxes3D, X, Y, Z, pattern_db, 'EdgeColor', 'none');
            title(app.UIAxes3D, '3D Radiation Pattern (dB)');
            xlabel(app.UIAxes3D, 'X');
            ylabel(app.UIAxes3D, 'Y');
            zlabel(app.UIAxes3D, 'Z');
            colormap(app.UIAxes3D, 'jet');
            colorbar(app.UIAxes3D);
            view(app.UIAxes3D, 45, 30);
            axis(app.UIAxes3D, 'equal');
            
            % Azimuth cut (theta = 90 degrees)
            cla(app.UIAxesAzimuth);
            azimuth_cut = pattern_db(:, 91); % theta = 90 degrees
            plot(app.UIAxesAzimuth, linspace(0, 360, 361), azimuth_cut);
            title(app.UIAxesAzimuth, 'Azimuth Cut (theta = 90°)');
            xlabel(app.UIAxesAzimuth, 'Phi (degrees)');
            ylabel(app.UIAxesAzimuth, 'Gain (dB)');
            grid(app.UIAxesAzimuth, 'on');
            ylim(app.UIAxesAzimuth, [0 max_gain+5]);
            
            % Elevation cut (phi = 0 degrees)
            cla(app.UIAxesElevation);
            elevation_cut = pattern_db(1, :); % phi = 0 degrees
            plot(app.UIAxesElevation, linspace(0, 180, 181), elevation_cut);
            title(app.UIAxesElevation, 'Elevation Cut (phi = 0°)');
            xlabel(app.UIAxesElevation, 'Theta (degrees)');
            ylabel(app.UIAxesElevation, 'Gain (dB)');
            grid(app.UIAxesElevation, 'on');
            ylim(app.UIAxesElevation, [0 max_gain+5]);
            
            % Display results
            results_text = {
                sprintf('Antena Yagi-Uda de %d elementos', num_directors+2);
                sprintf('Frecuencia: %.2f MHz (λ = %.3f m)', f_MHz, lambda);
                sprintf('Ganancia máxima: %.1f dB', max_gain);
                sprintf('Relación frente/atrás: %.1f dB', fbr);
                sprintf('Impedancia del dipolo doblado: %.1f Ω', Z_folded);
                sprintf('Longitud total de la antena: %.3f m', positions(end));
                '';
                'Parámetros de los elementos:';
                sprintf('Reflector: L=%.3fm, d=%.3fλ', L_reflector, s_reflector/lambda);
                sprintf('Dipolo activo: L=%.3fm', L_dipole);
                sprintf('Directores: L=%.3fm, d=%.3fλ', L_director, s_director/lambda);
                sprintf('Diámetro conductor: %.1f mm', conductor_diameter*1000);
            };
            
            app.ResultsTextArea.Value = results_text;
        end
    end

    methods (Access = private)

        function createComponents(app)
            % Create UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1000 700];
            app.UIFigure.Name = 'Yagi-Uda Antenna Designer - Teoría Aplicada';
            
            % Create input controls
            y_pos = 650;
            label_width = 120;
            field_width = 100;
            
            % Frequency input
            app.FrequencyMHzLabel = uilabel(app.UIFigure);
            app.FrequencyMHzLabel.Position = [20 y_pos label_width 22];
            app.FrequencyMHzLabel.Text = 'Frequency (MHz)';
            
            app.FrequencyEditField = uieditfield(app.UIFigure, 'numeric');
            app.FrequencyEditField.Position = [140 y_pos field_width 22];
            app.FrequencyEditField.Value = 650; % Default from document
            
            % Number of directors
            y_pos = y_pos - 30;
            app.NumberofDirectorsLabel = uilabel(app.UIFigure);
            app.NumberofDirectorsLabel.Position = [20 y_pos label_width 22];
            app.NumberofDirectorsLabel.Text = 'Number of Directors';
            
            app.DirectorsSpinner = uispinner(app.UIFigure);
            app.DirectorsSpinner.Limits = [1 20];
            app.DirectorsSpinner.Position = [140 y_pos field_width 22];
            app.DirectorsSpinner.Value = 3; % Default for 8 dB gain
            
            % Reflector length
            y_pos = y_pos - 30;
            app.ReflectorLengthmLabel = uilabel(app.UIFigure);
            app.ReflectorLengthmLabel.Position = [20 y_pos label_width 22];
            app.ReflectorLengthmLabel.Text = 'Reflector Length (m)';
            
            app.ReflectorLengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.ReflectorLengthEditField.Position = [140 y_pos field_width 22];
            app.ReflectorLengthEditField.Value = 0.230769; % From page 34
            
            % Dipole length
            y_pos = y_pos - 30;
            app.DipoleLengthmLabel = uilabel(app.UIFigure);
            app.DipoleLengthmLabel.Position = [20 y_pos label_width 22];
            app.DipoleLengthmLabel.Text = 'Dipole Length (m)';
            
            app.DipoleLengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.DipoleLengthEditField.Position = [140 y_pos field_width 22];
            app.DipoleLengthEditField.Value = 0.22; % From page 34
            
            % Director length
            y_pos = y_pos - 30;
            app.DirectorLengthmLabel = uilabel(app.UIFigure);
            app.DirectorLengthmLabel.Position = [20 y_pos label_width 22];
            app.DirectorLengthmLabel.Text = 'Director Length (m)';
            
            app.DirectorLengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.DirectorLengthEditField.Position = [140 y_pos field_width 22];
            app.DirectorLengthEditField.Value = 0.198; % From page 35
            
            % Reflector spacing
            y_pos = y_pos - 30;
            app.ReflectorSpacingmLabel = uilabel(app.UIFigure);
            app.ReflectorSpacingmLabel.Position = [20 y_pos label_width 22];
            app.ReflectorSpacingmLabel.Text = 'Reflector Spacing (m)';
            
            app.ReflectorSpacingEditField = uieditfield(app.UIFigure, 'numeric');
            app.ReflectorSpacingEditField.Position = [140 y_pos field_width 22];
            app.ReflectorSpacingEditField.Value = 0.092; % From page 35
            
            % Director spacing
            y_pos = y_pos - 30;
            app.DirectorSpacingmLabel = uilabel(app.UIFigure);
            app.DirectorSpacingmLabel.Position = [20 y_pos label_width 22];
            app.DirectorSpacingmLabel.Text = 'Director Spacing (m)';
            
            app.DirectorSpacingEditField = uieditfield(app.UIFigure, 'numeric');
            app.DirectorSpacingEditField.Position = [140 y_pos field_width 22];
            app.DirectorSpacingEditField.Value = 0.069; % From page 35
            
            % Conductor diameter
            y_pos = y_pos - 30;
            app.DiameterLabel = uilabel(app.UIFigure);
            app.DiameterLabel.Position = [20 y_pos label_width 22];
            app.DiameterLabel.Text = 'Conductor Diameter (m)';
            
            app.DiameterEditField = uieditfield(app.UIFigure, 'numeric');
            app.DiameterEditField.Position = [140 y_pos field_width 22];
            app.DiameterEditField.Value = 0.009; % From page 35 (λ/50)
            
            % Simulate button
            app.SimulateButton = uibutton(app.UIFigure, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.Position = [20 y_pos-40 200 30];
            app.SimulateButton.Text = 'Simular Antena Yagi-Uda';
            app.SimulateButton.FontWeight = 'bold';
            
            % Results text area
            app.ResultsTextArea = uitextarea(app.UIFigure);
            app.ResultsTextArea.Position = [20 20 260 200];
            app.ResultsTextArea.Value = {'Resultados de la simulación aparecerán aquí...'};
            
            % Create axes for plots
            app.UIAxes3D = uiaxes(app.UIFigure);
            title(app.UIAxes3D, 'Patrón de Radiación 3D')
            xlabel(app.UIAxes3D, 'X')
            ylabel(app.UIAxes3D, 'Y')
            zlabel(app.UIAxes3D, 'Z')
            app.UIAxes3D.Position = [300 350 650 300];
            
            app.UIAxesAzimuth = uiaxes(app.UIFigure);
            title(app.UIAxesAzimuth, 'Corte Azimutal (θ=90°)')
            xlabel(app.UIAxesAzimuth, 'φ (grados)')
            ylabel(app.UIAxesAzimuth, 'Ganancia (dB)')
            app.UIAxesAzimuth.Position = [300 200 300 120];
            
            app.UIAxesElevation = uiaxes(app.UIFigure);
            title(app.UIAxesElevation, 'Corte de Elevación (φ=0°)')
            xlabel(app.UIAxesElevation, 'θ (grados)')
            ylabel(app.UIAxesElevation, 'Ganancia (dB)')
            app.UIAxesElevation.Position = [650 200 300 120];
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = YagiUdaDesigner
            createComponents(app)
            registerApp(app, app.UIFigure)
            
            if nargout == 0
                clear app
            end
        end
        
        function delete(app)
            delete(app.UIFigure)
        end
    end
end