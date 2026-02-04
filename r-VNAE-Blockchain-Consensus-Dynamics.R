# ------------------------------------------------------------
# VNAE-Blockchain-Consensus-Dynamics
# Geometric Stability of Decentralized Ledger Consensus
# ------------------------------------------------------------

# Load required libraries
if (!require("igraph")) install.packages("igraph")
if (!require("deSolve")) install.packages("deSolve")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("reshape2")) install.packages("reshape2")

library(igraph)
library(deSolve)
library(ggplot2)
library(reshape2)

# -----------------------------
# 1. NETWORK CONFIGURATION
# -----------------------------
n <- 300                          # Number of Validators
avg_peers <- 12                   # P2P Network Degree
beta <- 0.15                      # Structural rigidity (VNAE scaling factor)

# Small-world graph (Watts-Strogatz model)
# nei: number of neighbors, p: rewiring probability
g <- watts.strogatz.game(dim = 1, size = n, nei = avg_peers / 2, p = 0.15)
A <- as.matrix(as_adjacency_matrix(g))

# Weighted communication links (modeling latency and bandwidth variance)
# Element-wise multiplication by a log-normal distribution
weights <- matrix(rlnorm(n * n, meanlog = 0.0, sdlog = 0.4), nrow = n)
A <- A * weights
diag(A) <- 0                      # Remove self-loops

# -----------------------------
# 2. VALIDATOR HETEROGENEITY
# -----------------------------
# Represents stake distribution, hardware capacity, and geographic latency
theta <- runif(n, min = 0.5, max = 8.0)

# -----------------------------
# 3. GRAPH LAPLACIAN
# -----------------------------
# L = D - A (Diffusion operator on the graph)
D <- diag(rowSums(A))
L <- D - A

# -----------------------------
# 4. CURVATURE CERTIFICATE (K)
# -----------------------------
# Monte Carlo sampling to estimate the geometric stability coefficient
samples <- 150000
i_idx <- sample(1:n, samples, replace = TRUE)
j_idx <- sample(1:n, samples, replace = TRUE)

theta_diff <- abs(theta[i_idx] - theta[j_idx])
coupling <- A[cbind(i_idx, j_idx)] + A[cbind(j_idx, i_idx)]
rigidity <- 1 + beta * (theta[i_idx] + theta[j_idx])

K <- mean((theta_diff * coupling) / rigidity)

# -----------------------------
# 5. CONSENSUS DYNAMICS
# -----------------------------
# Stochastic adversarial forcing (MEV interference, spam, clock drift)
p_attack <- rnorm(n, mean = 0, sd = 0.6)

# ODE System function
vnae_consensus <- function(t, omega, params) {
  # Equation: dω/dt = -(L + Θ)ω + p
  # In R deSolve, we return the derivative as a list
  d_omega <- -(L %*% omega) - (theta * omega) + p_attack
  return(list(as.vector(d_omega)))
}

# Initial consensus offsets (initial desynchronization)
omega0 <- rnorm(n, mean = 0, sd = 3.0)

# Time span (representing block propagation and finality windows)
t_eval <- seq(0, 0.2, length.out = 80)

# Solve ODE using lsoda (RK45 equivalent)
solution <- ode(y = omega0, times = t_eval, func = vnae_consensus, parms = NULL)

# -----------------------------
# 6. REPORT
# -----------------------------
cat("\n--- VNAE BLOCKCHAIN CONSENSUS REPORT ---\n")
cat(sprintf("Validators (n): %d\n", n))
cat(sprintf("Average Peers: %d\n", avg_peers))
cat(sprintf("Structural Curvature (K): %.6f\n", K))
status <- if (K > 0) "Geometrically Stable Consensus" else "Critical Instability"
cat(sprintf("Status: %s\n", status))

# -----------------------------
# 7. VISUALIZATION
# -----------------------------
# Select 40 random nodes for clarity in visualization
sample_nodes <- sample(2:(n+1), 40) # Col 1 is 'time', hence 2:(n+1)
df_plot <- as.data.frame(solution[, c(1, sample_nodes)])
df_melted <- melt(df_plot, id.vars = "time")



ggplot(df_melted, aes(x = time, y = value, group = variable)) +
  geom_line(alpha = 0.4, color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = paste("VNAE Blockchain Consensus Stability (K =", round(K, 4), ")"),
       subtitle = "Stochastic convergence of validator offsets",
       x = "Time (Block Propagation Window)",
       y = "Consensus Deviation (ω)") +
  theme_minimal()
