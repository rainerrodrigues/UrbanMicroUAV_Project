using Pkg
Pkg.activate(".")
using Turing
using Plots
using LinearAlgebra
using Random

println("Generating Sim-to-Real Flight Data...")

# Creating Synthetic "Real World" Data
# We simulate data collected from physical test flights.
# X contains 50 data points of [altitude, velocity]
Random.seed!(42)
N_samples = 50
X = rand(2, N_samples) .* 5.0 

# Y is the measured "unmodeled turbulence" during those physical flights
# It has a highly non-linear relationship to altitude/velocity, plus sensor noise.
true_turbulence = sin.(X[1, :]) .* cos.(X[2, :])
Y = true_turbulence .+ 0.2 .* randn(N_samples)

# Defining the Bayesian Neural Network
@model function bnn_turbulence(X, Y)
    # NEURAL NETWORK ARCHITECTURE: 2 Inputs -> 3 Hidden Nodes -> 1 Output
    
    # Layer 1 Priors (Weights and Biases)
    # filldist creates a matrix of Normal distributions
    W1 ~ filldist(Normal(0, 1), 3, 2)
    b1 ~ filldist(Normal(0, 1), 3)
    
    # Layer 2 Priors (Weights and Biases)
    W2 ~ filldist(Normal(0, 1), 1, 3)
    b2 ~ filldist(Normal(0, 1), 1)
    
    # Forward Pass through the network
    for i in eachindex(X, 2)
        # Hidden layer with a 'tanh' non-linear activation function
        hidden = tanh.(W1 * X[:, i] .+ b1)
        
        # Output layer
        pred_Y = (W2 * hidden .+ b2)[1]
        
        # Likelihood: Compare the BNN's prediction against the real flight data
        Y[i] ~ Normal(pred_Y, 0.1)
    end
end

println("Training the Bayesian Neural Network (this takes a moment)...")
# We use the NUTS sampler to train the network weights
model = bnn_turbulence(X, Y)
chain = sample(model, NUTS(), 300)

println("\n--- BNN Training Complete ---")
# Displaying the learned distributions for the neural network weights
display(describe(chain))

println("\nSuccess! The BNN has learned the turbulence patterns with uncertainty bounds.")