# 🚁 Urban Micro-UAV: Probabilistic Robotics Pipeline

![Julia](https://img.shields.io/badge/Language-Julia_1.10+-9558B2?style=for-the-badge&logo=julia)
![Framework](https://img.shields.io/badge/Inference-Turing.jl-blue?style=for-the-badge)
![Visualization](https://img.shields.io/badge/3D_Sim-MeshCat.jl-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-gray?style=for-the-badge)

> A complete, uncertainty-aware robotics software stack built entirely in Julia. This project bridges the gap between hardware co-design and software control, demonstrating advanced Bayesian methods for navigating highly turbulent, unpredictable urban environments (e.g., high-rise wind corridors).

![3D Flight Simulation](results/Meshcat_Julia_Drone.gif.gif)

## 🧠 Core Architecture

This pipeline moves beyond standard deterministic robotics by embracing **Epistemic and Aleatoric Uncertainty**. It is divided into four distinct mathematical modules:

```mermaid
graph TD
    A[Raw Flight Telemetry] --> B(Inference.jl: Hierarchical SysID)
    B -->|Estimated Drag & Wind| C(Dynamics.jl: Physics Engine)
    C --> D(Optimization.jl: Morphological Co-Design)
    D -->|Optimal Mass & Frame| E(StateEstimation.jl: Sim-to-Real)
    
    A --> F(StateEstimation.jl: Particle Filter)
    F -->|Position during GPS Blackout| E
    
    E --> G((MeshCat 3D Visualization))