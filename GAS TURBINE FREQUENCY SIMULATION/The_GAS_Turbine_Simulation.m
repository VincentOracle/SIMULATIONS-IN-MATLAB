% The GAS Turbine power_plant_simulation.m

% Main script to run the power plant simulation with a GUI

function power_plant_simulation
    % Create the GUI
    createGUI();
end

function createGUI()
    % Create a figure for the GUI
    fig = uifigure('Position', [100, 100, 640, 480], 'Name', 'GAS Turbine Power Plant Simulation');
    
    % Create UI components
    uilabel(fig, 'Position', [120, 417, 60, 22], 'Text', 'Fuel Input');
    fuelInput = uieditfield(fig, 'numeric', 'Position', [195, 417, 100, 22], 'Value', 100);
    
    uilabel(fig, 'Position', [120, 377, 70, 22], 'Text', 'Water Flow');
    waterFlow = uieditfield(fig, 'numeric', 'Position', [195, 377, 100, 22], 'Value', 50);
    
    startButton = uibutton(fig, 'push', 'Position', [262, 42, 100, 22], 'Text', 'Start', ...
        'ButtonPushedFcn', @(btn, event) startButtonPushed(fuelInput, waterFlow));
    
    % Create axes for plotting
    ax = uiaxes(fig, 'Position', [50, 100, 540, 250]);
    title(ax, 'Power Plant Simulation');
    xlabel(ax, 'Time (s)');
    ylabel(ax, 'Value');
end

function startButtonPushed(fuelInput, waterFlow)
    % Get user inputs
    fuel_input = fuelInput.Value;
    water_flow = waterFlow.Value;
    
    % Run the simulation
    [time, frequency, power_output] = frequency_response_model(fuel_input, water_flow);
    
    % Plot results
    fig = ancestor(fuelInput, 'figure');
    ax = findall(fig, 'Type', 'axes');
    plot(ax, time, frequency, 'r', time, power_output, 'b');
    legend(ax, {'Frequency', 'Power Output'});
end

function [steam_flow, pressure] = boiler_model(fuel_input, water_flow)
  
% THE BOILER
    % Simplified boiler dynamics
    steam_flow = fuel_input * 0.9;  % Example efficiency
    pressure = steam_flow * 1.5;    % Example pressure calculation
end

function power_output = steam_turbine_model(steam_flow, pressure)
       
 %mTHE STEAM TURBINE
    % A Simplified steam turbine model
    power_output = steam_flow * pressure * 0.85;  % Example efficiency
end

function [valve_position, steam_flow] = deh_system(frequency_diff)

%THE DEH CONTROL LOGIC
    % DEH control logic
    Kp = 0.1;
    valve_position = Kp * frequency_diff;
    steam_flow = valve_position * 100;  % Example flow rate
end

function co2_captured = ccs_system(flue_gas_flow)

% THE CCS MODEL
    % Simplified CCS model
    capture_efficiency = 0.9;
    co2_captured = flue_gas_flow * capture_efficiency;
end

function [time, frequency, power_output] = frequency_response_model(fuel_input, water_flow)
    % Simulation parameters
    sim_time = 1000;  % Simulation time in seconds
    dt = 1;  % Time step in seconds
    
    % Initialize arrays for storing results
    time = 0:dt:sim_time;
    frequency = zeros(size(time));
    power_output = zeros(size(time));
    
    % Initial conditions
    frequency(1) = 50;  % Nominal frequency in Hz
    power_output(1) = 600;  % Initial power output in MW
    load = 600;  % Initial load in MW
    
    % Simulation loop
    for t = 2:length(time)
        % Calculate frequency difference
        frequency_diff = load - power_output(t-1);
        
        % DEH system response
        [valve_position, steam_flow] = deh_system(frequency_diff);
        
        % Boiler dynamics
        [steam_flow, pressure] = boiler_model(fuel_input, water_flow);
        
        % Steam turbine dynamics
        power_output(t) = steam_turbine_model(steam_flow, pressure);
        
        % CCS system
        co2_captured = ccs_system(steam_flow); %#ok<NASGU>  % Not used in this example
        
        % Update frequency
        frequency(t) = 50 + (power_output(t) - load) * 0.1;  % Simplified frequency update
    end
end
