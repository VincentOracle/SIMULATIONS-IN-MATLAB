% Number of cycles for the net-like pattern
n_cycles = 8;

% Generate data for the net-like pattern
delta = linspace(-100, 100, 100); % X-axis data
P_base = 100 * tanh(0.05 * delta); % Base pattern for P (Y-axis)

% Create figure
figure;
hold on;

% Loop to create multiple overlapping rectangles
for i = 1:n_cycles
    shift = 10 * i; % Shift each cycle to create the net-like pattern
    P_experimental = P_base + shift * randn(size(delta)); % Dotted line data with some randomness
    P_calculated = P_base; % Solid line data
    
    % Plot experimental data (dotted line)
    plot(delta, P_experimental, 'k:', 'LineWidth', 1.5); 
    
    % Plot calculated data (solid line)
    plot(delta, P_calculated, 'r-', 'LineWidth', 1.5);
end

% Set axis limits
xlim([-100 100]);
ylim([-150 150]);

% Add labels
xlabel('\Delta (mm)', 'FontSize', 12);
ylabel('P (kN)', 'FontSize', 12);

% Add legend
legend({'试验', '计算'}, 'FontSize', 12, 'Location', 'best');

% Add grid
grid on;

% Set font size for axes
set(gca, 'FontSize', 12);

% Box around the plot
box on;

% Save the figure
saveas(gcf, 'final_drawing.png');
