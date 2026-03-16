using Pkg
Pkg.activate(".")

include("../src/Dynamics.jl")
include("../src/Inference.jl")

using .Dynamics
using .Inference
using DifferentialEquations
using Turing

# Setup True Simulation
u0 = [0.0, 0.0] # start at ground, 0 velocity
tspan = (0.0, 5.0)
true_p = [1.0, 9.81, 0.42] # The TRUE drag is 0.42 (our algorithm doesn't know this)

prob = ODEProblem(drone_altitude!, u0, tspan, true_p)
true_sol = solve(prob, saveat=0.1)

# Generating Fake "Noisy" Sensor Data
noisy_data = true_sol[1, :] .+ 0.1 .* randn(length(true_sol.t))

# Running Turing to find the hidden drag coefficient
println("Running Bayesian Inference...")
model = estimate_drag(noisy_data, prob)
chain = sample(model, NUTS(), 500) # Using the No-U-Turn Sampler

println("#n--- Inference Results---")
display(describe(chain))

mean_c = mean(chain[:c])
println("\nTrue Drag Coefficient: 0.42")
println("Estimated Drag Coefficient: ", round(mean_c, digits=3))