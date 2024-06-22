function air_intake_model_gui()
    % Create the GUI
    fig = uifigure('Position', [100, 100, 400, 300], 'Name', 'Air Intake Model');

    % Create input fields and labels
    uilabel(fig, 'Position', [20, 240, 100, 22], 'Text', 'Mach Number:');
    machField = uieditfield(fig, 'numeric', 'Position', [150, 240, 100, 22]);
    
    uilabel(fig, 'Position', [20, 200, 100, 22], 'Text', 'Altitude (m):');
    altitudeField = uieditfield(fig, 'numeric', 'Position', [150, 200, 100, 22]);
    
    uilabel(fig, 'Position', [20, 160, 100, 22], 'Text', 'Volume (m^3):');
    volumeField = uieditfield(fig, 'numeric', 'Position', [150, 160, 100, 22]);
    
    uilabel(fig, 'Position', [20, 120, 100, 22], 'Text', 'Throughput (kg/s):');
    throughputField = uieditfield(fig, 'numeric', 'Position', [150, 120, 100, 22]);

    % Create a button to run the model
    runButton = uibutton(fig, 'Position', [150, 80, 100, 22], 'Text', 'Run Model', ...
                         'ButtonPushedFcn', @(btn, event) runModel());

    function runModel()
        % Get user inputs
        M = machField.Value;
        altitude = altitudeField.Value;
        V = volumeField.Value;
        G0 = throughputField.Value;

        % Constants
        k = 1.4; % Specific heat ratio for air
        R = 287; % Specific gas constant for air in J/(kg*K)

        % Atmospheric conditions at the specified altitude
        [P0, T0] = get_atmospheric_conditions(altitude);

        % Initial conditions based on ambient conditions and Mach number
        P_init = P0 * (1 + (k-1)/2 * M^2)^(k/(k-1)); % Stagnation pressure
        T_init = T0 * (1 + (k-1)/2 * M^2); % Stagnation temperature

        % Initial mass flow rates
        G1_init = G0; % Initial mass flow rate in kg/s
        G2_init = G0; % Initial mass flow rate in kg/s

        % Time span
        tspan = [0 10];

        % Initial state vector [P1, P2, G1, G2]
        initial_conditions = [P_init; P_init; G1_init; G2_init];

        % Solve ODE system
        [t, Y] = ode45(@(t, y) odesystem(t, y, V, k, R, T0, G0, P0), tspan, initial_conditions);

        % Plot results
        figure;
        subplot(2, 1, 1);
        plot(t, Y(:, 1), t, Y(:, 2));
        xlabel('Time (s)');
        ylabel('Pressure (Pa)');
        legend('P1', 'P2');

        subplot(2, 1, 2);
        plot(t, Y(:, 3), t, Y(:, 4));
        xlabel('Time (s)');
        ylabel('Mass Flow Rate (kg/s)');
        legend('G1', 'G2');
    end

    function dydt = odesystem(t, y, V, k, R, T0, G0, P0)
        % Unpack state vector
        P1 = y(1);
        P2 = y(2);
        G1 = y(3);
        G2 = y(4);

        % Define the ODE system
        dP1dt = (k * R / V) * (G1 * T0 - G2 * T0); % Change in pressure in volume 1
        dP2dt = (k * R / V) * (G2 * T0 - G0 * T0); % Change in pressure in volume 2

        dG1dt = (P1 - P2) / V; % Change in mass flow rate in volume 1
        dG2dt = (P2 - P0) / V; % Change in mass flow rate in volume 2

        % Pack the derivatives into a column vector
        dydt = [dP1dt; dP2dt; dG1dt; dG2dt];
    end

    function [P0, T0] = get_atmospheric_conditions(altitude)
        % Function to get standard atmospheric conditions at a given altitude
        % Simple atmospheric model (valid for up to 20 km)
        if altitude < 0
            error('Altitude cannot be negative.');
        elseif altitude <= 11000
            T0 = 288.15 - 0.00649 * altitude; % Temperature in K
            P0 = 101325 * (T0 / 288.15)^(-9.81 / (0.00649 * 287)); % Pressure in Pa
        elseif altitude <= 20000
            T0 = 216.65; % Temperature in K
            P0 = 22632 * exp(-9.81 * (altitude - 11000) / (287 * 216.65)); % Pressure in Pa
        else
            error('Altitude out of range for this simple model (0-20 km).');
        end
    end
end
