classdef untitled < matlab.apps.AppBase

    % Properties that correspond to app components
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
        SimulateButton          matlab.ui.control.Button
        UIAxes3D               matlab.ui.control.UIAxes
        UIAxesAzimuth          matlab.ui.control.UIAxes
        UIAxesElevation        matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            % Get user inputs
            f = app.FrequencyEditField.Value * 1e6; % Convert MHz to Hz
            c = 3e8; % Speed of light
            lambda = c / f; % Wavelength in meters
            num_directors = app.DirectorsSpinner.Value;
            L_reflector = app.ReflectorLengthEditField.Value;
            L_dipole = app.DipoleLengthEditField.Value;
            L_director = app.DirectorLengthEditField.Value;
            s_reflector = app.ReflectorSpacingEditField.Value;
            s_director = app.DirectorSpacingEditField.Value;

            % Element positions and lengths
            positions = zeros(1, num_directors + 2); % Reflector, Dipole, Directors
            lengths = zeros(1, num_directors + 2);
            positions(1) = 0; % Reflector at origin
            positions(2) = s_reflector; % Dipole position
            lengths(1) = L_reflector;
            lengths(2) = L_dipole;
            for i = 1:num_directors
                positions(i + 2) = s_reflector + i * s_director;
                lengths(i + 2) = L_director;
            end

            % Calculate phase shifts (based on document's reflector/director behavior)
            % Reflector: inductive, phase lag; Directors: capacitive, phase lead
            y1_ref = -180 * pi/180; % Reflector phase shift (page 14)
            y2_ref = -40 * pi/180;
            y1_dir = -165 * pi/180; % Director phase shift (page 14)
            y2_dir = 20 * pi/180;
            phases = [y1_ref + y2_ref, 0]; % Dipole phase = 0 (active element)
            for i = 1:num_directors
                phases(i + 2) = y1_dir + y2_dir;
            end

            % Calculate array factor
            theta = linspace(0, 2*pi, 360);
            phi = linspace(0, 2*pi, 360);
            [THETA, PHI] = meshgrid(theta, phi);
            k = 2 * pi / lambda;
            AF = zeros(size(THETA));
            for i = 1:length(positions)
                % Array factor contribution
                AF = AF + exp(1j * (k * positions(i) * cos(THETA) + phases(i)));
            end
            AF = abs(AF).^2; % Magnitude squared for power
            AF = AF / max(AF(:)); % Normalize

            % Approximate dipole pattern (sin^2 for half-wave dipole)
            dipole_pattern = (cos(pi/2 * cos(THETA))./sin(THETA)).^2;
            dipole_pattern(isnan(dipole_pattern)) = 0;
            pattern = AF .* dipole_pattern;
            pattern = pattern / max(pattern(:)); % Normalize
            pattern_db = 10 * log10(pattern + eps); % Convert to dB

            % Folded dipole impedance (approx 4x standard dipole, page 36)
            Z_dipole = 73.1; % Standard half-wave dipole impedance
            Z_folded = 4 * Z_dipole; % Folded dipole impedance

            % Plot 3D pattern
            cla(app.UIAxes3D);
            [X, Y, Z] = sph2cart(PHI, pi/2 - THETA, pattern_db);
            surf(app.UIAxes3D, X, Y, Z, 'EdgeColor', 'none');
            title(app.UIAxes3D, '3D Radiation Pattern (dB)');
            xlabel(app.UIAxes3D, 'X');
            ylabel(app.UIAxes3D, 'Y');
            zlabel(app.UIAxes3D, 'Z');
            colorbar(app.UIAxes3D);
            view(app.UIAxes3D, 45, 30);

            % Azimuth cut (theta = 90 degrees)
            cla(app.UIAxesAzimuth);
            phi_cut = linspace(0, 360, 360);
            idx = find(abs(THETA(1,:) - pi/2) < 0.01);
            plot(app.UIAxesAzimuth, phi_cut * 180/pi, pattern_db(:, idx));
            title(app.UIAxesAzimuth, 'Azimuth Cut (theta = 90°)');
            xlabel(app.UIAxesAzimuth, 'Phi (degrees)');
            ylabel(app.UIAxesAzimuth, 'Gain (dB)');
            grid(app.UIAxesAzimuth, 'on');

            % Elevation cut (phi = 0 degrees)
            cla(app.UIAxesElevation);
            theta_cut = linspace(0, 360, 360);
            idx = find(abs(PHI(:,1)) < 0.01);
            plot(app.UIAxesElevation, theta_cut * 180/pi, pattern_db(idx, :));
            title(app.UIAxesElevation, 'Elevation Cut (phi = 0°)');
            xlabel(app.UIAxesElevation, 'Theta (degrees)');
            ylabel(app.UIAxesElevation, 'Gain (dB)');
            grid(app.UIAxesElevation, 'on');

            % Display impedance
            msgbox(sprintf('Folded Dipole Impedance: %.2f + j%.2f ohms', real(Z_folded), imag(Z_folded)), 'Impedance');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 800 600];
            app.UIFigure.Name = 'Yagi-Uda Antenna Designer';

            % Create FrequencyMHzLabel
            app.FrequencyMHzLabel = uilabel(app.UIFigure);
            app.FrequencyMHzLabel.Position = [20 550 100 22];
            app.FrequencyMHzLabel.Text = 'Frequency (MHz)';

            % Create FrequencyEditField
            app.FrequencyEditField = uieditfield(app.UIFigure, 'numeric');
            app.FrequencyEditField.Position = [120 550 100 22];
            app.FrequencyEditField.Value = 650; % Default from document

            % Create NumberofDirectorsLabel
            app.NumberofDirectorsLabel = uilabel(app.UIFigure);
            app.NumberofDirectorsLabel.Position = [20 520 120 22];
            app.NumberofDirectorsLabel.Text = 'Number of Directors';

            % Create DirectorsSpinner
            app.DirectorsSpinner = uispinner(app.UIFigure);
            app.DirectorsSpinner.Limits = [1 20];
            app.DirectorsSpinner.Position = [140 520 100 22];
            app.DirectorsSpinner.Value = 3; % Default for 8 dB gain

            % Create ReflectorLengthmLabel
            app.ReflectorLengthmLabel = uilabel(app.UIFigure);
            app.ReflectorLengthmLabel.Position = [20 490 100 22];
            app.ReflectorLengthmLabel.Text = 'Reflector Length (m)';

            % Create ReflectorLengthEditField
            app.ReflectorLengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.ReflectorLengthEditField.Position = [120 490 100 22];
            app.ReflectorLengthEditField.Value = 0.230769; % From page 34

            % Create DipoleLengthmLabel
            app.DipoleLengthmLabel = uilabel(app.UIFigure);
            app.DipoleLengthmLabel.Position = [20 460 100 22];
            app.DipoleLengthmLabel.Text = 'Dipole Length (m)';

            % Create DipoleLengthEditField
            app.DipoleLengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.DipoleLengthEditField.Position = [120 460 100 22];
            app.DipoleLengthEditField.Value = 0.22; % From page 34

            % Create DirectorLengthmLabel
            app.DirectorLengthmLabel = uilabel(app.UIFigure);
            app.DirectorLengthmLabel.Position = [20 430 100 22];
            app.DirectorLengthmLabel.Text = 'Director Length (m)';

            % Create DirectorLengthEditField
            app.DirectorLengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.DirectorLengthEditField.Position = [120 430 100 22];
            app.DirectorLengthEditField.Value = 0.198; % From page 35

            % Create ReflectorSpacingmLabel
            app.ReflectorSpacingmLabel = uilabel(app.UIFigure);
            app.ReflectorSpacingmLabel.Position = [20 400 120 22];
            app.ReflectorSpacingmLabel.Text = 'Reflector Spacing (m)';

            % Create ReflectorSpacingEditField
            app.ReflectorSpacingEditField = uieditfield(app.UIFigure, 'numeric');
            app.ReflectorSpacingEditField.Position = [140 400 100 22];
            app.ReflectorSpacingEditField.Value = 0.092; % From page 35

            % Create DirectorSpacingmLabel
            app.DirectorSpacingmLabel = uilabel(app.UIFigure);
            app.DirectorSpacingmLabel.Position = [20 370 120 22];
            app.DirectorSpacingmLabel.Text = 'Director Spacing (m)';

            % Create DirectorSpacingEditField
            app.DirectorSpacingEditField = uieditfield(app.UIFigure, 'numeric');
            app.DirectorSpacingEditField.Position = [140 370 100 22];
            app.DirectorSpacingEditField.Value = 0.069; % From page 35

            % Create SimulateButton
            app.SimulateButton = uibutton(app.UIFigure, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.Position = [20 340 100 22];
            app.SimulateButton.Text = 'Simulate';

            % Create UIAxes3D
            app.UIAxes3D = uiaxes(app.UIFigure);
            title(app.UIAxes3D, '3D Radiation Pattern')
            xlabel(app.UIAxes3D, 'X')
            ylabel(app.UIAxes3D, 'Y')
            zlabel(app.UIAxes3D, 'Z')
            app.UIAxes3D.Position = [300 300 450 250];

            % Create UIAxesAzimuth
            app.UIAxesAzimuth = uiaxes(app.UIFigure);
            title(app.UIAxesAzimuth, 'Azimuth Cut')
            xlabel(app.UIAxesAzimuth, 'Phi (degrees)')
            ylabel(app.UIAxesAzimuth, 'Gain (dB)')
            app.UIAxesAzimuth.Position = [300 150 200 100];

            % Create UIAxesElevation
            app.UIAxesElevation = uiaxes(app.UIFigure);
            title(app.UIAxesElevation, 'Elevation Cut')
            xlabel(app.UIAxesElevation, 'Theta (degrees)')
            ylabel(app.UIAxesElevation, 'Gain (dB)')
            app.UIAxesElevation.Position = [550 150 200 100];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = untitled
            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end