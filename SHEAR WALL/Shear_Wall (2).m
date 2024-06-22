
% THE CALCULATION OF SHEAR WALL RESTORATION FORCE (MATLAB)
% MATLAB Code to Produce the Desired Hysteresis Curve

% Given data
initial_stiffness = 6.25; % Initial stiffness K1 in kN/mm
x_points = [-101.6, -75.58, -31.03, -3.95, 0, 3.95, 31.03, 75.58, 101.6]; % Displacement in mm
y_points = [-52.47, -61.73, -44.87, -24.69, 0, 24.69, 44.87, 61.73, 52.47]; % Load in kN
displacements = [3.0, -3.0, 6.0, -6.0, 9.0, -9.0, 12.0, -12.0, 15.0, -15.0, 30.0, -30.0, 31.27, -31.27, 31.27, -31.27, 45.0, -45.0, 46.907, -46.907, 46.46, -46.46, 60.0, -60.0, 62.1, -62.1, 62.1, -62.1, 75.0, -75.0, 77.18, -77.18, 77.18, -77.18, 90.0, -90.0, 94.25, -94.25, 94.25, -94.25, 105.0, -105.0, 109.28, -109.28, 110.26, 110.26, 120.0, -120.0, 124.18, -124.18, 124.6, -124.6];

% Skeleton curve fitting
skeleton_fit = fit(x_points', y_points', 'pchipinterp');

% Initialize variables for the restoring force model
P = zeros(size(displacements));
unload_stiffness = initial_stiffness;
alpha = 0.54;
lambda = -0.799;

% Calculate the restoring force for each displacement
for i = 2:length(displacements)
    delta = displacements(i);
    prev_delta = displacements(i-1);
    
    % Determine if the displacement exceeds 15mm for pinching effect
    if abs(delta) > 15
        unload_stiffness = initial_stiffness * (alpha * exp(lambda * (abs(delta) / 15)));
    end
    
    % Load or unload calculation
    if delta * prev_delta > 0 % Same direction, loading
        P(i) = skeleton_fit(delta);
    else % Opposite direction, unloading
        P(i) = P(i-1) + unload_stiffness * (delta - prev_delta);
    end
end

% Plot the graph
figure;
plot(x_points, y_points, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Skeleton Curve');
hold on;
plot(displacements, P, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Calculation');
legend('Location', 'NorthWest');
xlabel('\Delta (mm)');
ylabel('P (kN)');
title('Hysteresis Curve of Shear Wall');
grid on;
axis([-130 130 -160 160]);
hold off;

% Display the figure
set(gca, 'FontSize', 12);
set(gcf, 'Position', [100, 100, 600, 400]);


% Generate synthetic data for multiple hysteresis loops
num_loops = 10;
max_displacement = 100;
max_force = 150;

% Generate displacement data starting from -75 mm to +100 mm
D = linspace(-75, max_displacement, 100); % Displacement in mm

% Initialize force arrays
P1 = zeros(num_loops, length(D));
P2 = zeros(num_loops, length(D));

% Create loops with slight variations
for i = 1:num_loops
    % Adjust initial force to start from around -100 kN
    initial_force = -100 + (i - 1) * 10; 
    P1(i, :) = initial_force + max_force * sin(2 * pi * (i/num_loops) * (D / max_displacement));
    P2(i, :) = initial_force + 0.9 * max_force * sin(2 * pi * (i/num_loops) * (D / max_displacement) + pi/10);
end

% Create the figure
figure;

% Plot the experimental data (dotted lines)
for i = 1:num_loops
    plot(D, P1(i, :), 'k:', 'LineWidth', 1.5);
    hold on;
end

% Plot the calculated data (solid lines)
for i = 1:num_loops
    plot(D, P2(i, :), 'r-', 'LineWidth', 1.5);
end

% Set axis limits
xlim([-100 max_displacement]);
ylim([-150 max_force]);

% Label the axes
xlabel('\Delta (mm)', 'FontSize', 12, 'Interpreter', 'tex');
ylabel('P (kN)', 'FontSize', 12, 'Interpreter', 'tex');

% Add grid lines
grid on;

% Add a legend
legend({'试验', '计算'}, 'FontSize', 10, 'Location', 'NorthWest');

% Set the font and size for the axes
set(gca, 'FontName', 'Arial', 'FontSize', 10);

% Add title
title('Hysteresis Loop', 'FontSize', 12);

% Add box around the plot
box on;

% Make the plot background white
set(gcf, 'Color', 'w');

% Display the plot
hold off;
