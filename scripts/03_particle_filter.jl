using Pkg
Pkg.activate(".")

# Importing the State Estimation script
include("../src/StateEstimation.jl")
using .StateEstimation

using Turing
using Plots
using Statistics
using Random

Random.seed!(42)

println("Generating simulation data...")
N_steps = 30
true_x = zeros(N_steps) 
obs_y = zeros(N_steps)  

true_x[1] = 0.0
obs_y[1] = 0.0

# Generating Data (Physics & GPS Blackout)
for t in 2:N_steps
    true_x[t] = true_x[t-1] + 1.0 + 0.2 * randn()
    if t >= 10 && t <= 20
        obs_y[t] = true_x[t] + 10.0 * randn() 
    else
        obs_y[t] = true_x[t] + 0.5 * randn()  
    end
end

println("Running Particle Filter (SMC) via Module...")
# Calling the function cleanly from your module
model = smc_drone_tracker(obs_y, 10, 20)
chain = sample(model, SMC(), 1000)

println("Plotting the results...")
est_x = [mean(chain[Symbol("x[$i]")]) for i in 1:N_steps]

gr()
p = plot(1:N_steps, true_x, label="True Flight Path", linewidth=3, color=:black, legend=:topleft)
scatter!(p, 1:N_steps, obs_y, label="Noisy GPS Readings", color=:red, alpha=0.6)
plot!(p, 1:N_steps, est_x, label="Particle Filter Estimate", linewidth=3, color=:blue, linestyle=:dash)
vspan!(p, [10, 20], color=:gray, alpha=0.2, label="Building (GPS Blackout)")

# Saving to the Results folder!
save_path = joinpath(@__DIR__, "..", "results", "particle_filter_tracking.png")
savefig(p, save_path)
println("Success! Saved to: ", save_path)