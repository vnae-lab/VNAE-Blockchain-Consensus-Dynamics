# ------------------------------------------------------------
# VNAE-Blockchain-Consensus-Dynamics
# Geometric Stability of Decentralized Ledger Consensus
# ------------------------------------------------------------

using Graphs, LinearAlgebra, DifferentialEquations, Distributions, Plots

# -----------------------------
# 1. NETWORK CONFIGURATION
# -----------------------------
n = 300                           # Validators
avg_peers = 12                    # P2P Degree
beta = 0.15                       # Structural rigidity (VNAE factor)

# Small-world graph (Watts-Strogatz)
# k=12 (avg_peers), β=0.15 (rewiring)
g = watts_strogatz(n, avg_peers, 0.15)
A = Float64.(adjacency_matrix(g))

# Weighted communication links (modeling latency/bandwidth)
# Multiplied by a Log-Normal distribution
weights = rand(LogNormal(0.0, 0.4), n, n)
A = A .* weights
for i in 1:n A[i,i] = 0.0 end     # Ensure no self-loops

# -----------------------------
# 2. VALIDATOR HETEROGENEITY
# -----------------------------
# Stake size, hardware, geographic latency (Uniform Distribution)
theta = rand(Uniform(0.5, 8.0), n)

# -----------------------------
# 3. GRAPH LAPLACIAN
# -----------------------------
# L = D - A
D = Diagonal(sum(A, dims=2)[:])
L = D - A

# -----------------------------
# 4. CURVATURE CERTIFICATE (K)
# -----------------------------
samples = 150_000
i_idx = rand(1:n, samples)
j_idx = rand(1:n, samples)

theta_diff = abs.(theta[i_idx] .- theta[j_idx])
# Get coupling values (A[i,j] + A[j,i])
coupling = [A[i_idx[k], j_idx[k]] + A[j_idx[k], i_idx[k]] for k in 1:samples]
rigidity = 1 .+ beta .* (theta[i_idx] .+ theta[j_idx])

K = mean((theta_diff .* coupling) ./ rigidity)

# -----------------------------
# 5. CONSENSUS DYNAMICS
# -----------------------------
# Persistent adversarial forcing (MEV, spam, clock drift)
p_attack = rand(Normal(0, 0.6), n)

# ODE System definition: dω/dt = -(L + Θ)ω + p
function vnae_consensus!(domega, omega, p, t)
    # Using non-allocating matrix multiplication for speed
    mul!(domega, L, omega, -1.0, 0.0)
    domega .-= theta .* omega
    domega .+= p_attack
end

# Initial consensus offsets (initial chaos)
omega0 = rand(Normal(0, 3.0), n)

# Time window (block propagation timescale)
t_span = (0.0, 0.2)

# Define and solve the problem (Tsit5 is equivalent to RK45)
prob = ODEProblem(vnae_consensus!, omega0, t_span)
sol = solve(prob, Tsit5(), saveat=0.0025)

# -----------------------------
# 6. REPORT
# -----------------------------
println("\n--- VNAE BLOCKCHAIN CONSENSUS REPORT ---")
println("Validators (n): $n")
println("Average Peers: $avg_peers")
@printf("Structural Curvature (K): %.6f\n", K)
println("Status: ", K > 0 ? "Geometrically Stable Consensus" : "Critical Instability")

# -----------------------------
# 7. VISUALIZATION
# -----------------------------
# Selecting 40 random validators to plot
sample_indices = sort(rand(1:n, 40))
plot(sol, idxs=sample_indices, alpha=0.4, legend=false, 
     title="VNAE Blockchain Consensus Stability (K = $(round(K, digits=4)))",
     xlabel="Time (Block Propagation)", ylabel="Consensus Deviation (ω)",
     color=:steelblue)
hline!([0], line=(:dash, :red, 1))
