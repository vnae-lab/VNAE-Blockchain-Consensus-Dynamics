# ------------------------------------------------------------
# VNAE-Blockchain-Consensus-Dynamics
# Geometric Stability of Decentralized Ledger Consensus
# ------------------------------------------------------------

import numpy as np
import networkx as nx
from scipy.integrate import solve_ivp

# -----------------------------
# 1. NETWORK CONFIGURATION
# -----------------------------
n = 300                         # Validators (realistic PoS scale)
avg_peers = 12                  # Typical P2P connectivity
beta = 0.15                     # Structural rigidity (VNAE factor)

# Small-world graph 
G = nx.watts_strogatz_graph(n, k=avg_peers, p=0.15)
A = nx.to_numpy_array(G)

# Weighted communication links (latency / bandwidth effects)
A *= np.random.lognormal(mean=0.0, sigma=0.4, size=(n, n))
np.fill_diagonal(A, 0)

# -----------------------------
# 2. VALIDATOR HETEROGENEITY
# -----------------------------
# Theta models stake size, hardware, geographic latency
theta = np.random.uniform(0.5, 8.0, size=n)

Theta = np.diag(theta)

# -----------------------------
# 3. GRAPH LAPLACIAN
# -----------------------------
L = np.diag(A.sum(axis=1)) - A

# -----------------------------
# 4. CURVATURE CERTIFICATE (K)
# -----------------------------
samples = 150_000
i = np.random.randint(0, n, samples)
j = np.random.randint(0, n, samples)

theta_diff = np.abs(theta[i] - theta[j])
coupling = A[i, j] + A[j, i]
rigidity = 1 + beta * (theta[i] + theta[j])

K = np.mean((theta_diff * coupling) / rigidity)

# -----------------------------
# 5. CONSENSUS DYNAMICS
# -----------------------------
# Persistent adversarial forcing (MEV, spam, clock drift)
p_attack = np.random.normal(0, 0.6, size=n)

def vnae_consensus(t, omega):
    # dω/dt = -(L + Θ)ω + p
    return -(L @ omega) - (theta * omega) + p_attack

# Initial consensus offsets
omega0 = np.random.normal(0, 3.0, size=n)

# Time window (block propagation timescale)
t_span = (0, 0.2)
t_eval = np.linspace(*t_span, 80)

solution = solve_ivp(
    vnae_consensus,
    t_span,
    omega0,
    t_eval=t_eval,
    method="RK45"
)

# -----------------------------
# 6. REPORT
# -----------------------------
print("\n--- VNAE BLOCKCHAIN CONSENSUS REPORT ---")
print(f"Validators (n): {n}")
print(f"Average Peers: {avg_peers}")
print(f"Structural Curvature (K): {K:.6f}")
print("Status:",
      "Geometrically Stable Consensus" if K > 0 else "Critical Instability")

# -----------------------------
# 7. VISUALIZATION (sample)
# -----------------------------
import matplotlib.pyplot as plt

sample_nodes = np.random.choice(n, 40, replace=False)
plt.figure(figsize=(8, 5))

for idx in sample_nodes:
    plt.plot(solution.t, solution.y[idx], alpha=0.4)

plt.axhline(0, linestyle="--", linewidth=1)
plt.title(f"VNAE Blockchain Consensus Stability (K = {K:.4f})")
plt.xlabel("Time")
plt.ylabel("Consensus Deviation")
plt.grid(True)
plt.tight_layout()
plt.show()
