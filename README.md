# VNAE-Blockchain-Consensus-Dynamics
VNAE-Blockchain-Consensus-Dynamics explores the geometric stability of decentralized consensus protocols under heterogeneity, network sparsity, and persistent adversarial forcing.

Instead of relying on synchrony or local Lyapunov assumptions, the framework certifies global consensus stability through curvature-based volume contraction, even in large-scale, attack-prone validator networks.

# Motivation 

Classical consensus models often assume symmetry or linear stability. On the other hand, it is common to note that modern blockchain networks operate under:

- Heterogeneous validators
- Sparse peer-to-peer connectivity
- Asymmetric delays, incentives, and trust
- Persistent external perturbations (latency, congestion, adversarial noise), for example.

VNAE replaces this with a **geometric approach, where stability emerges from network curvature and volume contraction**, not from symmetry or equilibrium tuning.

# Core Dynamic Equation

The evolution of node states is governed by:

d(ω)/dt = − (L + θ) · ω + p

where:

ω = Vector of node states (e.g. block height deviation, clock skew, voting pressure, or local consensus error).

L = Directed graph Laplacian representing peer-to-peer communication and influence.

θ = Diagonal matrix encoding heterogeneous asymmetric dissipation per node. Each θi represents validator-specific inertia, trust weight, or responsiveness.

p = Persistent external forcing, such as network latency, transaction bursts, adversarial noise, or stochastic delays.

# Network Topology: Interpretation of the 12-Peer Model

This model does not assume a fixed-size blockchain network. Instead, it adopts a local connectivity assumption consistent with production systems.

Each node is modeled as a vertex in a directed graph, with:

- Average degree ≈ 12
- Roughly 12 active peer connections per node
- Edges represent state exchange, not full broadcasts

Mapping:

- Nodes → vertices
- Peer links → directed edges
- Degree ≈ local neighborhood size

This was an attempt to reflects how real blockchain nodes operate.

**Below we can see why ~12 peers tends to be realistic:**

Well, the empirical observations from production systems show similar regimes:

- Ethereum P2P layer
- Tendermint and Cosmos gossip
- Polkadot relay and parachain overlays
- Byzantine fault-tolerant consensus networks

We also can note that a degree between 10 and 15 provides:

- Fast information propagation
- Fault tolerance
- Resistance to partitioning
- Bounded bandwidth usage

This places the model between trivial toy graphs and unrealistic fully connected networks.

# The Role of Asymmetry (θ)

Each node i is assigned a parameter theta_i.

We can draw some analogies. So, in this context, theta represents:

- Validator inertia
- Response delay
- Economic weight
- Slashing sensitivity
- Hardware or geographic latency

It is important to highlight that the **Asymmetry is not a bug**, it is a **structural feature of real networks**.

As a consequence, VNAE shows that:

- Stability does not require symmetric nodes
- Local instability does not imply global divergence
- Geometry dominates local dynamics.

# Geometric Stability Criterion

Instead of eigenvalue-based stability, VNAE uses a curvature-based metric:

K = average over node pairs of:
|θi − θj| × |A_ij| / (1 + β × (θi + θj))

where:

A_ij is the coupling strength between nodes i and j;

β controls global rigidity;

If **K > 0**, the system is geometrically stable, meaning:

- Phase-space volume contracts
- Consensus errors decay globally
- Perturbations cannot amplify indefinitely.
