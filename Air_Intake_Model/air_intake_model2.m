function air_intake_model()
    % Define constants and parameters
    V = 8.8; % Volume in cubic meters
    F = 1; % Cross-sectional area (assumed for simplicity)
    k = 1.4; % Specific heat ratio for air
    R = 287; % Specific gas constant for air in J/(kg*K)
    
    % Ambient conditions at 16 km altitude
    P0 = 11974; % Pressure in Pa
    T0 = 216.65; % Temperature in K
    rho0 = P0 / (R * T0); % Density in kg/m^3
    
    % Mach number
    M = 2;
    
    % Throughput
    G0 = 100; % Throughput in kg/s
    
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
    [t, Y] = ode45(@(t, y) odesystem(t, y, V, F, k, R, T0, G0), tspan, initial_conditions);
    
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

    function dydt = odesystem(t, y, V, F, k, R, T0, G0)
        % Unpack state vector
        P1 = y(1);
        P2 = y(2);
        G1 = y(3);
        G2 = y(4);
        
        % Define the ODE system
        dP1dt = (k * R / V) * (G1 * T0 - G2 * T0); % Change in pressure in volume 1
        dP2dt = (k * R / V) * (G2 * T0 - G0 * T0); % Change in pressure in volume 2
        
        dG1dt = (F / V) * ((P1 - P2) - (G1 + G2)); % Change in mass flow rate in volume 1
        dG2dt = (F / V) * ((P2 - P0) - (G2 + G0)); % Change in mass flow rate in volume 2
        
        % Pack the derivatives into a column vector
        dydt = [dP1dt; dP2dt; dG1dt; dG2dt];
    end
end
