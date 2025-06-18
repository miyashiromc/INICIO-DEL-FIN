classdef YagiUdaDesigner < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        LeftPanel               matlab.ui.container.Panel
        RightPanel              matlab.ui.container.Panel
        FrequencyMHzLabel       matlab.ui.control.Label
        FrequencyEditField      matlab.ui.control.NumericEditField
        NumDirectorsLabel       matlab.ui.control.Label
        NumDirectorsSpinner     matlab.ui.control.Spinner
        ReflectorLengthLabel    matlab.ui.control.Label
        ReflectorLengthEditField matlab.ui.control.NumericEditField
        DipoleLengthLabel       matlab.ui.control.Label
        DipoleLengthEditField   matlab.ui.control.NumericEditField
        DirectorLengthLabel     matlab.ui.control.Label
        DirectorLengthEditField matlab.ui.control.NumericEditField
        ReflectorSpacingLabel   matlab.ui.control.Label
        ReflectorSpacingEditField matlab.ui.control.NumericEditField
        DirectorSpacingLabel    matlab.ui.control.Label
        DirectorSpacingEditField matlab.ui.control.NumericEditField
        ElementDiameterLabel    matlab.ui.control.Label
        ElementDiameterEditField matlab.ui.control.NumericEditField
        DesignButton            matlab.ui.control.Button
        DefaultValuesButton     matlab.ui.control.Button
        Antenna3DAxes           matlab.ui.control.UIAxes
        RadiationPatternAxes    matlab.ui.control.UIAxes
        AzimuthPatternAxes      matlab.ui.control.UIAxes
        ElevationPatternAxes    matlab.ui.control.UIAxes
        ResultsTextArea         matlab.ui.control.TextArea
    end

    methods (Access = private)

        % Button pushed function: DesignButton
        function DesignButtonPushed(app, event)
            try
                % Get input parameters
                freq = app.FrequencyEditField.Value; % MHz
                num_directors = app.NumDirectorsSpinner.Value;
                L_reflector = app.ReflectorLengthEditField.Value; % m
                L_dipole = app.DipoleLengthEditField.Value; % m
                L_director = app.DirectorLengthEditField.Value; % m
                s_reflector = app.ReflectorSpacingEditField.Value; % m
                s_director = app.DirectorSpacingEditField.Value; % m
                d_element = app.ElementDiameterEditField.Value; % m
                
                % Calculate wavelength
                c = 3e8; % speed of light
                lambda = c / (freq * 1e6);
                
                % Clear previous plots
                cla(app.Antenna3DAxes);
                cla(app.RadiationPatternAxes);
                cla(app.AzimuthPatternAxes);
                cla(app.ElevationPatternAxes);
                
                % Create Yagi-Uda antenna
                yagi = yagiUda;
                
                % Configure antenna elements
                yagi.NumDirectors = num_directors;
                yagi.ReflectorLength = L_reflector;
                yagi.ReflectorSpacing = s_reflector;
                yagi.DirectorLength = L_director * ones(1, num_directors);
                yagi.DirectorSpacing = s_director * ones(1, num_directors);
                
                % Configure folded dipole exciter
                yagi.Exciter = dipoleFolded;
                yagi.Exciter.Length = L_dipole;
                yagi.Exciter.Width = cylinder2strip(d_element/2);
                yagi.Exciter.Spacing = yagi.Exciter.Width * 4;
                
                % Set element diameters
                yagi.ReflectorWidth = cylinder2strip(d_element/2);
                yagi.DirectorWidth = cylinder2strip(d_element/2);
                
                % Display antenna geometry
                show(yagi, 'Parent', app.Antenna3DAxes);
                title(app.Antenna3DAxes, ['Yagi-Uda Geometry - ' num2str(freq) ' MHz']);
                view(app.Antenna3DAxes, 3);
                axis(app.Antenna3DAxes, 'equal');
                grid(app.Antenna3DAxes, 'on');
                
                % Calculate and plot radiation pattern
                freq_hz = freq * 1e6;
                
                % Main radiation pattern
                pattern(yagi, freq_hz, 'Type', 'directivity', ...
                       'CoordinateSystem', 'rectangular', 'Parent', app.RadiationPatternAxes);
                title(app.RadiationPatternAxes, '3D Radiation Pattern (dBi)');
                view(app.RadiationPatternAxes, 45, 30);
                colorbar(app.RadiationPatternAxes);
                
                % Azimuth cut (phi = 0°)
                pattern(yagi, freq_hz, 0, 0:1:360, 'Type', 'directivity', ...
                       'CoordinateSystem', 'polar', 'Parent', app.AzimuthPatternAxes);
                title(app.AzimuthPatternAxes, 'Azimuth Cut (φ = 0°)');
                
                % Elevation cut (theta = 90°)
                pattern(yagi, freq_hz, -90:1:90, 0, 'Type', 'directivity', ...
                       'CoordinateSystem', 'polar', 'Parent', app.ElevationPatternAxes);
                title(app.ElevationPatternAxes, 'Elevation Cut (θ = 90°)');
                
                % Calculate antenna parameters
                Z = impedance(yagi, freq_hz);
                [gain, ~] = pattern(yagi, freq_hz, 0, 0);
                bw = beamwidth(yagi, freq_hz);
                fbr = app.calculateFBRatio(yagi, freq_hz);
                
                % Display results
                results_str = sprintf(['ANTENA YAGI-UDA - RESULTADOS\n\n'...
                                      'Frecuencia: %.2f MHz\n'...
                                      'Longitud de onda: %.4f m\n\n'...
                                      'PARÁMETROS DE DISEÑO:\n'...
                                      'Número de elementos: %d\n'...
                                      ' - Reflector: %.4f m (%.3fλ)\n'...
                                      ' - Dipolo: %.4f m (%.3fλ)\n'...
                                      ' - Directores: %.4f m (%.3fλ)\n'...
                                      'Espaciamientos:\n'...
                                      ' - Reflector-Dipolo: %.4f m (%.3fλ)\n'...
                                      ' - Director-Director: %.4f m (%.3fλ)\n\n'...
                                      'RESULTADOS:\n'...
                                      'Ganancia máxima: %.2f dBi\n'...
                                      'Ancho de haz: %.2f°\n'...
                                      'Relación F/B: %.2f dB\n'...
                                      'Impedancia: %.2f + j%.2f Ω\n\n'...
                                      'Fórmulas usadas:\n'...
                                      'Reflector: 150/f (MHz)\n'...
                                      'Dipolo: 143/f (MHz)\n'...
                                      'Director: 138/f (MHz)'],...
                    freq, lambda, num_directors+2,...
                    L_reflector, L_reflector/lambda,...
                    L_dipole, L_dipole/lambda,...
                    L_director, L_director/lambda,...
                    s_reflector, s_reflector/lambda,...
                    s_director, s_director/lambda,...
                    gain, bw, fbr, real(Z), imag(Z));
                
                app.ResultsTextArea.Value = results_str;
                
            catch ME
                uialert(app.UIFigure, ME.message, 'Error en el diseño');
            end
        end

        % Button pushed function: DefaultValuesButton
        function DefaultValuesButtonPushed(app, event)
            % Set default values based on 650 MHz design from document
            freq = 650; % MHz
            c = 3e8;
            lambda = c / (freq * 1e6);
            
            app.FrequencyEditField.Value = freq;
            app.NumDirectorsSpinner.Value = 3;
            app.ReflectorLengthEditField.Value = 150/freq;
            app.DipoleLengthEditField.Value = 143/freq;
            app.DirectorLengthEditField.Value = 138/freq;
            app.ReflectorSpacingEditField.Value = 0.15*lambda;
            app.DirectorSpacingEditField.Value = 0.11*lambda;
            app.ElementDiameterEditField.Value = lambda/50;
            
            % Auto-run the design
            app.DesignButtonPushed(event);
        end
    end
    
    methods (Access = private)
        function fbr = calculateFBRatio(app, yagi, freq)
            % Calculate front-to-back ratio
            [gmax, angmax] = pattern(yagi, freq, 0, 0);
            gback = pattern(yagi, freq, angmax(1), mod(angmax(2)+180, 0);
            fbr = gmax - gback;
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1200 800];
            app.UIFigure.Name = 'Yagi-Uda Antenna Designer - Simulador Completo';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'0.7x', '1.3x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.BackgroundColor = [0.96 0.96 0.96];

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Title = 'Parámetros de Diseño';
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.BackgroundColor = [0.98 0.98 0.98];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Title = 'Visualización y Resultados';
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            app.RightPanel.BackgroundColor = [0.98 0.98 0.98];

            % Create parameter controls
            app.createParameterControls();
            
            % Create visualization components
            app.createVisualizationComponents();
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
        
        function createParameterControls(app)
            % Grid for parameters
            paramGrid = uigridlayout(app.LeftPanel);
            paramGrid.RowHeight = [repmat({30}, 1, 9), 40, 40];
            paramGrid.ColumnWidth = {'1x', '1x'};
            paramGrid.RowSpacing = 10;
            paramGrid.Padding = [10 10 10 10];
            
            % Frequency
            app.FrequencyMHzLabel = uilabel(paramGrid);
            app.FrequencyMHzLabel.Text = 'Frecuencia (MHz):';
            app.FrequencyMHzLabel.Layout.Row = 1;
            app.FrequencyMHzLabel.Layout.Column = 1;
            app.FrequencyMHzLabel.FontWeight = 'bold';
            
            app.FrequencyEditField = uieditfield(paramGrid, 'numeric');
            app.FrequencyEditField.Value = 650;
            app.FrequencyEditField.Limits = [50 3000];
            app.FrequencyEditField.Layout.Row = 1;
            app.FrequencyEditField.Layout.Column = 2;
            
            % Number of directors
            app.NumDirectorsLabel = uilabel(paramGrid);
            app.NumDirectorsLabel.Text = 'Número de Directores:';
            app.NumDirectorsLabel.Layout.Row = 2;
            app.NumDirectorsLabel.Layout.Column = 1;
            app.NumDirectors