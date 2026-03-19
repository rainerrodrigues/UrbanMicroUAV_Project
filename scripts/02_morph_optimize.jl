using Pkg
Pkg.activate(".")

# Importing Dynamics and Optimization modules
include("../src/Dynamics.jl")
include("../src/Optimization.jl")

using .Dynamics
using .Optimization

println("Initializing Morphological Co-Design...")
println("Target Environment: High-rise urban corridors (Pune)")
println("Optimizing for maximum stability and minimum battery weight...\n")

# Running the Optimizer
# Passing the simulate_flight_dynamics function directly into the optimizer
best_mass, best_score = optimize_uav_design(simulate_flight_dynamics)

# Calculating the resulting drag based on the optimal mass
optimal_drag = 0.42 * (best_mass / 0.5)

println("✅ Optimization Complete!")
println("-------------------------------------------------")
println("Optimal Drone Mass:       ", round(best_mass, digits=3), " kg")
println("Resulting Aerodynamic Drag: ", round(optimal_drag, digits=3))
println("Final Cost Score:         ", round(best_score, digits=3))
println("-------------------------------------------------")

# Verifying the result by simulating a flight with the winning design
println("\nVerifying optimal design in simulation...")
optimal_flight = simulate_flight_dynamics(best_mass, optimal_drag; tspan=(0.0, 10.0))
final_altitude = optimal_flight[1, end]

println("Altitude achieved at t=10s: ", round(final_altitude, digits=2), " meters")