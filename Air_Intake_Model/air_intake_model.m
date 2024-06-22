function air_intake_model()
    % Define parameters (example values, need to be adjusted according to the specific system)
    V1 = 1; V2 = 1; % Volumes of control volumes
    F1 = 1; F2 = 1; % Cross-sectional areas
    k = 1.4; % Specific heat ratio
    R = 287; % Specific gas constant for air

    % Initial conditions
    P0 = 101325; % Initial pressure in Pa
    T0 = 300; % Initial temperature in K
    G0 = 1; % Initial mass flow rate in kg/s

    % Time span
    tspan = [0 10];

    % Initial state vector [P1, P2, G1, G2]
    initial_conditions = [P0; P0; G0; G0];

    % Solve ODE system
    [t, Y] = ode45(@(t, y) odesystem(t, y, V1, V2, F1, F2, k, R), tspan, initial_conditions);

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

    function dydt = odesystem(t, y, V1, V2, F1, F2, k, R)
        % Unpack state vector
        P1 = y(1);
        P2 = y(2);
        G1 = y(3);
        G2 = y(4);

        % Define the ODE system
        dP1dt = (k * R / V1) * (G1 * T0 - G2 * T0); % Change in pressure in volume 1
        dP2dt = (k * R / V2) * (G2 * T0 - G0 * T0); % Change in pressure in volume 2

        dG1dt = (F1 / V1) * ((P1 - P2) - (G1 + G2)); % Change in mass flow rate in volume 1
        dG2dt = (F2 / V2) * ((P2 - P0) - (G2 + G0)); % Change in mass flow rate in volume 2

        % Pack the derivatives into a column vector
        dydt = [dP1dt; dP2dt; dG1dt; dG2dt];
    end
end
