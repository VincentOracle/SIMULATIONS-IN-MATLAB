% Define DH parameters for a six-axis robot
% Example values are provided, please adjust them according to your specific robot configuration
theta = [0, 0, 0, 0, 0, 0];   % Joint angles for all links
d = [0.5, 0, 0.6, 0, 0, 0.1]; % Link offsets for all links
a = [0.5, 0.3, 0.2, 0.4, 0.2, 0.1]; % Link lengths for all links
alpha = [0, -pi/2, 0, -pi/2, pi/2, -pi/2]; % Link twists for all links

% Create the robot model using DH parameters
robot = createRobot(theta, d, a, alpha);

% Display the robot
figure;
robotPlot(robot, [0 0 0 0 0 0]);

% Generate sinusoidal trajectory for the end effector
t = linspace(0, 10, 100); % Time vector
x = 0.5 * cos(t);         % Sinusoidal trajectory in x-coordinate
y = 0.5 * sin(t);         % Sinusoidal trajectory in y-coordinate
z = 0.5 + 0.1 * sin(2 * t); % Sinusoidal trajectory in z-coordinate

% Allocate memory for joint angles
q = zeros(length(t), 6);

% Inverse kinematics to find the joint angles for the trajectory
for i = 1:length(t)
    T = [1, 0, 0, x(i);
         0, 1, 0, y(i);
         0, 0, 1, z(i);
         0, 0, 0, 1]; % Translation matrix
    q(i, :) = inverseKinematics(T);
end

% Plot the robot following the trajectory
figure;
for i = 1:length(t)
    robotPlot(robot, q(i, :));
    pause(0.1);
end

% Function to create robot model using DH parameters
function robot = createRobot(theta, d, a, alpha)
    n = length(theta); % Number of joints/links
    
    % Create link objects for each link
    for i = 1:n
        links(i) = struct('theta', theta(i), 'd', d(i), 'a', a(i), 'alpha', alpha(i));
    end
    
    % Define the robot structure
    robot = struct('links', links);
end

% Function to plot the robot
function robotPlot(robot, q)
    % Initialize transformation matrix
    T = eye(4);
    
    % Plot each link of the robot
    for i = 1:length(robot.links)
        link = robot.links(i);
        T = T * dhMatrix(link.theta, link.d, link.a, link.alpha);
        plotLink(T);
    end
    
    % Plot end effector
    plot3(T(1, 4), T(2, 4), T(3, 4), 'ro');
    
    % Set plot properties
    axis equal;
    view(3);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    title('Robot Model');
    grid on;
end

% Function to plot a link given its transformation matrix
function plotLink(T)
    % Define vertices of link
    vertices = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
    
    % Transform vertices
    vertices = (T * [vertices, ones(size(vertices, 1), 1)]')';
    
    % Plot link
    faces = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
    patch('Vertices', vertices(:, 1:3), 'Faces', faces, 'FaceColor', 'b', 'FaceAlpha', 0.3);
end

% Function to calculate the DH transformation matrix
function T = dhMatrix(theta, d, a, alpha)
    T = [cos(theta), -sin(theta) * cos(alpha), sin(theta) * sin(alpha), a * cos(theta);
         sin(theta), cos(theta) * cos(alpha), -cos(theta) * sin(alpha), a * sin(theta);
         0, sin(alpha), cos(alpha), d;
         0, 0, 0, 1];
end

% Inverse Kinematics function for a simple 6-DOF robot
function q = inverseKinematics(T)
    % Solve inverse kinematics for a 6-DOF robot
    % This is a simplified example, please replace with your actual IK solution
    
    % Example: assume first three joints are position controlled and last three are orientation controlled
    % For position control, we can simply use the first three elements of the translation vector
    q_position = T(1:3, 4)';
    
    % For orientation control, we can use a simple rotation matrix decomposition
    R = T(1:3, 1:3);
    q_orientation = rotm2eul(R, 'XYZ'); % Assuming XYZ Euler angles
    
    % Combine position and orientation joint angles
    q = [q_position, q_orientation];
end
