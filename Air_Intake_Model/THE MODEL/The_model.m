function air_intake_model_gui
    % Create the GUI figure
    f = uifigure('Name', 'Air Intake Model', 'Position', [100 100 400 300]);
    
    % Mach number input
    uilabel(f, 'Position', [20 250 100 22], 'Text', 'Mach Number:');
    machEdit = uieditfield(f, 'numeric', 'Position', [120 250 100 22], 'Value', 2);
    
    % Altitude input
    uilabel(f, 'Position', [20 220 100 22], 'Text', 'Altitude (km):');
    altitudeEdit = uieditfield(f, 'numeric', 'Position', [120 220 100 22], 'Value', 16);
    
    % Volume input
    uilabel(f, 'Position', [20 190 100 22], 'Text', 'Volume (m^3):');
    volumeEdit = uieditfield(f, 'numeric', 'Position', [120 190 100 22], 'Value', 8.8);
    
    % Throughput input
    uilabel(f, 'Position', [20 160 100 22], 'Text', 'Throughput (kg/s):');
    throughputEdit = uieditfield(f, 'numeric', 'Position', [120 160 100 22], 'Value', 100);
    
    % Run button
    runButton = uibutton(f, 'push', 'Position', [150 100 100 22], 'Text', 'Run Simulation', ...
                         'ButtonPushedFcn', @(btn, event) runModel());
    
    function runModel()
        % Get user inputs
        M = machEdit.Value;
        altitude = altitudeEdit.Value * 1000; % convert km to m
        V = volumeEdit.Value;
        G = throughputEdit.Value;
        
        % Get atmospheric conditions
        [P0, T0] = get_atmospheric_conditions(altitude);
        
        % Set constants
        k = 1.4; % Ratio of specific heats for air
        R = 287; % Specific gas constant for air
        
        % Initial conditions
        P_initial = P0; % Initial pressure
        G_initial = G; % Initial mass flow rate
        
        % Solve the ODE
        y0 = [P_initial; P_initial; G_initial; G_initial];
        tspan = [0 10];
        [t, y] = ode45(@(t, y) odesystem(t, y, V, k, R, T0, G_initial, P0), tspan, y0);
        
        % Plot results
        figure;
        subplot(2, 1, 1);
        plot(t, y(:, 1), 'b', 'DisplayName', 'P1');
        hold on;
        plot(t, y(:, 2), 'r', 'DisplayName', 'P2');
        xlabel('Time (s)');
        ylabel('Pressure (Pa)');
        legend show;
        
        subplot(2, 1, 2);
        plot(t, y(:, 3), 'b', 'DisplayName', 'G1');
        hold on;
        plot(t, y(:, 4), 'r', 'DisplayName', 'G2');
        xlabel('Time (s)');
        ylabel('Mass Flow Rate (kg/s)');
        legend show;
    end

    function dydt = odesystem(t, y, V, k, R, T0, G0, P0)
        % Unpack state vector
        P1 = y(1);
        P2 = y(2);
        G1 = y(3);
        G2 = y(4);
        
        % Define the ODE system
        dP1dt = (k * R / V) * (G1 * T0 - G2 * T0);
        dP2dt = (k * R / V) * (G2 * T0 - G0 * T0);
        
        dG1dt = (P1 - P2) / V;
        dG2dt = (P2 - P0) / V;
        
        % Pack the derivatives
        dydt = [dP1dt; dP2dt; dG1dt; dG2dt];
    end

    function [P0, T0] = get_atmospheric_conditions(altitude)
        % Atmospheric conditions for standard atmosphere
        if altitude == 16000
            P0 = 12110; % Pa
            T0 = 216.65; % K
        else
            error('Atmospheric conditions for this altitude are not predefined.');
        end
    end
end
