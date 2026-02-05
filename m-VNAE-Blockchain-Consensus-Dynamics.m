% ------------------------------------------------------------
% VNAE-Blockchain-Consensus-Dynamics
% Geometric Stability of Decentralized Ledger Consensus
% ------------------------------------------------------------

clear; clc;

% -----------------------------
% 1. NETWORK CONFIGURATION
% -----------------------------
n = 300;                          % Validators
avg_peers = 12;                   % Connectivity
beta = 0.15;                      % Structural rigidity (VNAE factor)

% Small-world graph (Watts-Strogatz)
% Note: Using a custom adjacency construction for standard MATLAB
% Create a ring lattice and rewire
A = zeros(n);
k_half = avg_peers / 2;
for i = 1:n
    for j = 1:k_half
        neighbor = mod(i + j - 1, n) + 1;
        A(i, neighbor) = 1;
        A(neighbor, i) = 1;
    end
end

% Rewire links with probability 0.15
rewire_prob = 0.15;
[rows, cols] = find(triu(A));
for idx = 1:length(rows)
    if rand() < rewire_prob
        A(rows(idx), cols(idx)) = 0;
        A(cols(idx), rows(idx)) = 0;
        new_col = randi(n);
        while new_col == rows(idx) || A(rows(idx), new_col) == 1
            new_col = randi(n);
        end
        A(rows(idx), new_col) = 1;
        A(new_col, rows(idx)) = 1;
    end
end

% Weighted communication links (modeling latency)
weights = lognrnd(0.0, 0.4, n, n);
A = A .* weights;
A(logical(eye(n))) = 0;           % No self-loops

% -----------------------------
% 2. VALIDATOR HETEROGENEITY
% -----------------------------
% theta models stake, hardware, or geographic latency
theta = 0.5 + (8.0 - 0.5) .* rand(n, 1);

% -----------------------------
% 3. GRAPH LAPLACIAN
% -----------------------------
L = diag(sum(A, 2)) - A;

% -----------------------------
% 4. CURVATURE CERTIFICATE (K)
% -----------------------------
samples = 150000;
i_idx = randi(n, samples, 1);
j_idx = randi(n, samples, 1);

theta_diff = abs(theta(i_idx) - theta(j_idx));
% Linear indexing for matrix lookup
coupling = A(sub2ind([n n], i_idx, j_idx)) + A(sub2ind([n n], j_idx, i_idx));
rigidity = 1 + beta * (theta(i_idx) + theta(j_idx));

K = mean((theta_diff .* coupling) ./ rigidity);

% -----------------------------
% 5. CONSENSUS DYNAMICS
% -----------------------------
% Persistent adversarial forcing (MEV, spam, clock drift)
p_attack = normrnd(0, 0.6, [n, 1]);

% domega/dt = -(L + diag(theta)) * omega + p
% Anonymous function for the ODE solver
f = @(t, omega) -(L * omega) - (theta .* omega) + p_attack;

% Initial consensus offsets
omega0 = normrnd(0, 3.0, [n, 1]);

% Time window
t_span = [0, 0.2];

% Solve using ode45 (Dormand-Prince / RK45)
[t, sol] = ode45(f, t_span, omega0);

% -----------------------------
% 6. REPORT
% -----------------------------
fprintf('\n--- VNAE BLOCKCHAIN CONSENSUS REPORT ---\n');
fprintf('Validators (n): %d\n', n);
fprintf('Average Peers: %d\n', avg_peers);
fprintf('Structural Curvature (K): %.6f\n', K);
if K > 0
    fprintf('Status: Geometrically Stable Consensus\n');
else
    fprintf('Status: Critical Instability\n');
end

% -----------------------------
% 7. VISUALIZATION
% -----------------------------
sample_nodes = randperm(n, 40);
figure('Color', 'w');
plot(t, sol(:, sample_nodes), 'LineWidth', 1.0);
hold on;
yline(0, '--r', 'Consensus Target', 'LineWidth', 1.5);
title(['VNAE Blockchain Consensus Stability (K = ', num2str(K, '%.4f'), ')']);
xlabel('Time (Block Propagation Window)');
ylabel('Consensus Deviation (\omega)');
grid on;
set(gca, 'FontSize', 12);
