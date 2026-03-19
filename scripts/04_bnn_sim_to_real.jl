using Pkg
Pkg.activate(".")

# Importing my State Estimation file
include("../src/StateEstimation.jl")
using .StateEstimation

using Turing
using Plots
using Distributions
using Random
using StatsPlots

Random.seed!(42)

println("Initializing Sim-to-Real BNN Pipeline...")
println("Simulating complex aerodynamic turbulence...\n")

# Generating Synthetic "Real World" Data
# Let's assume X represents the drone's velocity (vx, vy)
N_samples = 50
X_train = rand(Uniform(-5.0, 5.0), 2, N_samples) 

# The TRUE complex physics (turbulence) we are trying to learn, plus sensor noise
true_turbulence(x) = sin(x[1]) + cos(x[2]) * 0.5
Y_train = [true_turbulence(X_train[:, i]) + 0.1 * randn() for i in 1:N_samples]

println("Training Bayesian Neural Network on Flight Data...")
println("(This will take a moment as it calculates the Epistemic Uncertainty...)")

# Calling the BNN from your module
bnn_model = bnn_turbulence_model(X_train, Y_train)

# Sampling the posterior using the NUTS sampler
chain = sample(bnn_model, NUTS(), 300)

println("\n✅ BNN Training Complete!")

# Plotting the Neural Network's learned weights and uncertainty
gr()
p = plot(chain)

# Saving to the results folder
savefig(p, "../results/bnn_uncertainty_bounds.png")
println("Success! Open 'results/bnn_uncertainty_bounds.png' to see the network's confidence distributions.")