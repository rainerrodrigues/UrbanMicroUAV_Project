using Pkg
Pkg.activate(".")

include("../src/Inference.jl")
using .Inference

using Turing
using Plots
using StatsPlots # Required for the density curves
using Statistics
using Random

Random.seed!(42)

println("Generating Swarm Telemetry Data...")

# 1. Setup the Swarm
num_drones = 3
drone_masses = [0.5, 0.8, 1.2]
true_wind_mu = 6.0 
fleet_data = Vector{Vector{Float64}}(undef, num_drones)

for i in 1:num_drones
    true_drag = true_wind_mu * (1.0 / drone_masses[i])
    fleet_data[i] = true_drag .+ 0.5 .* randn(50) 
end

println("Running Hierarchical Bayesian Swarm Inference...")

# 2. THE MISSING LINES: Running the actual model
model = hierarchical_swarm_id(fleet_data, drone_masses)
chain = sample(model, NUTS(), 500; check_model=false)

println("\n--- Swarm Inference Results ---")
display(describe(chain))

# 3. Analyze Results
mean_wind = mean(chain[:global_wind_μ])
println("\nTrue Global Wind Factor: ", true_wind_mu)
println("Estimated Global Wind Factor: ", round(mean_wind, digits=3))

# 4. Plot and Save safely
println("\nGenerating swarm plots...")
gr() 
p = plot(chain)

save_path = joinpath(@__DIR__, "..", "results", "swarm_posterior_plot.png")
savefig(p, save_path) 
println("Success! Saved to: ", save_path)