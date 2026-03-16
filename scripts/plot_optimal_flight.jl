using Pkg
Pkg.activate(".")
using DifferentialEquations
using Plots

# Copying the exact same physics from scripts/optimize_design.jl 
function drone_wind!(du, u, p, t)
    z, v = u
    m = p[1] 
    
    g = 9.81
    c = 0.42 
    
    wind_gust = 5.0 * sin(t * 3.0) 
    
    error = 10.0 - z
    Thrust = (m * g) + (3.0 * error) - (2.0 * v)
    
    du[1] = v
    du[2] = (Thrust / m) - g - (c / m) * v * abs(v) + (wind_gust / m)
end

println("Simulating optimized drone flight...")

# Setting up the simulation with our optimal mass (Obtained as m = 0.5186 from the optimization script)
optimal_mass = 0.5186 # The mean value Turing found
u0 = [0.0, 0.0]       # Start at ground level (0m)
tspan = (0.0, 10.0)   # Let's watch it fly for 10 seconds

prob = ODEProblem(drone_wind!, u0, tspan, [optimal_mass])
sol = solve(prob, Tsit5(), saveat=0.1)

# Creating the visual plot
println("Generating plot...")
gr() # Using the default GR backend

# Plotting the actual flight path
p = plot(sol.t, sol[1, :], 
    linewidth = 2, 
    label = "Drone Altitude (m)", 
    xlabel = "Time (seconds)", 
    ylabel = "Altitude (meters)", 
    title = "Optimized 0.52kg Drone vs. Wind Gusts",
    legend = :bottomright,
    color = :blue
)

# Adding a dashed line showing where the drone is TRYING to go
hline!(p, [10.0], 
    linewidth = 2, 
    linestyle = :dash, 
    color = :red, 
    label = "Target Altitude (10m)"
)

# Save the plot
savefig(p, "optimal_flight_path.png")
println("Success! Open 'optimal_flight_path.png' to see your drone fly.")