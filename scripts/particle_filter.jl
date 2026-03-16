using Pkg
Pkg.activate(".")
using Turing
using Plots
using Statistics

println("Generating simulation data...")

# Simulating the Real World (Ground Truth vs. Sensors)
N_steps = 30
true_x = zeros(N_steps) # The drone's true position
obs_y = zeros(N_steps)  # Based on what the GPS tells the drone

# Starting at position 0
true_x[1] = 0.0
obs_y[1] = 0.0

for t in 2:N_steps
    # Physics model where drone flies forward 1 meter per step, pushed slightly by wind (0.2 noise)
    true_x[t] = true_x[t-1] + 1.0 + 0.2 * randn()
    
    # Sensor model where GPS is normally accurate (0.5 noise)
    # BUT from step 10 to 20, it flies behind a building (GPS fails, 10.0 noise!)
    if t >= 10 && t <= 20
        obs_y[t] = true_x[t] + 10.0 * randn() 
    else
        obs_y[t] = true_x[t] + 0.5 * randn()  
    end
end

# Turing Particle Filter Model (Hidden Markov Model)
@model function drone_tracker(y)
    N = length(y)
    x = Vector{Real}(undef, N) # The drone's internal belief of its position
    
    # Step 1 Prior
    x[1] ~ Normal(0.0, 1.0)
    y[1] ~ Normal(x[1], 0.5)
    
    # Step through time
    for t in 2:N
        # The drone knows its own physics (moving forward ~1 meter)
        x[t] ~ Normal(x[t-1] + 1.0, 0.2)
        
        # The drone knows its GPS is terrible near the building (steps 10-20)
        if t >= 10 && t <= 20
            y[t] ~ Normal(x[t], 10.0) # Distrust the sensor
        else
            y[t] ~ Normal(x[t], 0.5)  # Trust the sensor
        end
    end
end

println("Running Particle Filter (SMC) with 1000 particles...")
# SMC stands for Sequential Monte Carlo - Turing's Particle Filter engine
# (Using this as EKF placeholder)
model = drone_tracker(obs_y)
chain = sample(model, SMC(), 1000)

println("Plotting the results...")
# Extracting the mean estimated position for each time step from the 1000 particles
est_x = [mean(chain[Symbol("x[$i]")]) for i in 1:N_steps]

# Visualizing True Position vs GPS vs Particle Filter
gr()
p = plot(1:N_steps, true_x, label="True Flight Path", linewidth=3, color=:black, legend=:topleft)
scatter!(p, 1:N_steps, obs_y, label="Noisy GPS Readings", color=:red, alpha=0.6)
plot!(p, 1:N_steps, est_x, label="Particle Filter Estimate", linewidth=3, color=:blue, linestyle=:dash)

# Highlighting the GPS blackout zone
vspan!(p, [10, 20], color=:gray, alpha=0.2, label="Building (GPS Blackout)")

savefig(p, "particle_filter_tracking.png")
println("Success! Open 'particle_filter_tracking.png' to see how well the drone tracked itself.")