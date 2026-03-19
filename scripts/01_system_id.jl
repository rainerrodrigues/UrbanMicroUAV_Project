using Pkg
Pkg.activate(".")

# Importing the Inference script
include("../src/Inference.jl")
using .Inference

using Turing
using Statistics
using StatsPlots
using Random

Random.seed!(42) # For reproducibility

println("Generating Swarm Telemetry Data...")

# Setting up the Swarm (3 Drones)
num_drones = 3
drone_masses = [0.5, 0.8, 1.2] # Light, Medium, and Heavy drones

# Simulating the Real World (Hidden from the algorithm)
# Let's say the TRUE global wind factor in the corridor is 6.0
true_wind_mu = 6.0 
fleet_data = Vector{Vector{Float64}}(undef, num_drones)

for i in 1:num_drones
    # True drag is physically affected by the shared wind AND the drone's specific mass
    true_drag = true_wind_mu * (1.0 / drone_masses[i])
    
    # Simulate 50 noisy sensor readings for each drone during the flight
    fleet_data[i] = true_drag .+ 0.5 .* randn(50) 
end

println("Running Hierarchical Bayesian Swarm Inference...")

# Calling the Inference module function
# The algorithm only gets the noisy sensor data and the masses. It has to figure out the wind.
model = hierarchical_swarm_id(fleet_data, drone_masses)
chain = sample(model, NUTS(), 500)

println("\n--- Swarm Inference Results ---")
display(describe(chain))

# Analyzing the Collaborative Learning
mean_wind = mean(chain[:global_wind_μ])
println("\nTrue Global Wind Factor: ", true_wind_mu)
println("Estimated Global Wind Factor: ", round(mean_wind, digits=3))

println("\nGenerating swarm plots...")
gr() 
p = plot(chain)

# Saving to the structured folder
savefig(p, "../results/swarm_posterior_plot.png") 
println("Success! Open 'results/swarm_posterior_plot.png' to see how the fleet learned together.")