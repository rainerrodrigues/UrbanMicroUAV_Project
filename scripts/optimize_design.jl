using Pkg
Pkg.activate(".")
using Turing
using DifferentialEquations
using SciMLSensitivity
using Statistics

# Controlling the physics: Drone with an active flight controller and turbulent wind
function drone_wind!(du, u, p, t)
    # Unpack state variables
    z, v = u
    # altitude, velocity = u
    m = p[1] # mass which we will optimize

    g = 9.81
    c = 0.42 # We use the exact drag coefficient
    
    # Simulate turbulent wind as a oscillating urban wind gust
    wind_gust = 5.0 * sin( t * 3.0)
    
    # We are keeping the Flight Controller as (PID loop)
    # It looks at the target altitude (10 meters) and adjusts thrust to get there.
    error = 10.0 - z
    Thrust = (m * g) + (3.0 * error) - (2.0 * v)
    
    # The equations of motion
    du[1] = v
    du[2] = (Thrust / m) - g - (c / m) * v * abs(v) + (wind_gust / m)
    
    # Drone dynamics with wind
    #du[1] = velocity
    #du[2] = (wind_force - drag_coeff * velocity^2 - mass * gravity) / mass
end

# Designing as Inference Model
@model function design_drone()
    # THE PRIOR: We can manufacture a drone weighing between 0.5kg and 3.0kg as the basic assumption
    # We use a truncated Normal so the sampler starts looking around 1.5kg.
    m ~ truncated(Normal(1.5, 1.0), 0.5, 3.0)
    
    # Running the simulation for 5 seconds starting at the ground (0.0)
    prob = ODEProblem(drone_wind!, [0.0, 0.0], (0.0, 5.0), [m])
    sol = solve(prob, Tsit5(), saveat=0.1)
    
    # Evaluating the drone's performance
    # Mean Squared Error (MSE) from the target altitude of 10m
    mse = mean(abs2.(sol[1, :] .- 10.0))
    
    # A heavier drone resists wind better (more inertia), 
    # but requires bigger batteries and stronger motors. We try to penalize heavy mass.
    total_cost = mse + (m * 2.0)
    
    # We "observe" a perfect cost of 0.0
    # The algorithm will automatically find the mass distribution that gets us closest to this.
    0.0 ~ Normal(total_cost, 1.0)
end

println("Running Probabilistic Design Optimization...")
model = design_drone()
# We use NUTS again to find the optimal physical mass
chain = sample(model, NUTS(), 500)

println("\n--- Optimal Design Results ---")
display(describe(chain))