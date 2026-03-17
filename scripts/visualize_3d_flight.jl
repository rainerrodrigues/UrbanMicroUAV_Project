using Pkg
Pkg.activate(".")
using WGLMakie
using GeometryBasics # Added for high-performance 3D types
using Random

println("Initializing High-Speed 3D Animation...")

# Generating 3D Flight Data 
N_steps = 100
t = range(0, 10pi, length=N_steps)

true_x = cos.(t) .* 5.0
true_y = sin.(t) .* 5.0
true_z = range(0, 20.0, length=N_steps)

fig = Figure(size = (1000, 800))
ax = Axis3(fig[1, 1], 
    title = "UAV 3D State Estimation (Optimized)",
    xlabel = "X Position (m)", 
    ylabel = "Y Position (m)", 
    zlabel = "Altitude (m)",
    elevation = pi/6, azimuth = pi/4
)

lines!(ax, true_x, true_y, true_z, color = :blue, linewidth = 4, label="True Trajectory")

# Instead of 3 separate Observables, we use ONE Observable holding a vector of 3D points
particles = Observable(fill(Point3f(0f0, 0f0, 0f0), 500))

meshscatter!(ax, particles, markersize = 0.3, color = (:red, 0.2))

record(fig, "fast_particle_flight.gif", 1:N_steps; framerate = 15) do i
    if i == 1
        println("\n✅ Compilation finished! Starting fast rendering loop...")
    end
    println("Rendering frame $i / $N_steps")

    noise = 1.0 
    
    particles[] = [
        Point3f(
            Float32(true_x[i] + randn() * noise), 
            Float32(true_y[i] + randn() * noise), 
            Float32(true_z[i] + randn() * noise)
        ) for _ in 1:500
    ]
end

println("Success! The animation has been saved to 'fast_particle_flight.gif'")