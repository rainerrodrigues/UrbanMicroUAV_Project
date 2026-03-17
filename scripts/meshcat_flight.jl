using Pkg
Pkg.activate(".")
using MeshCat
using GeometryBasics
using Colors
using CoordinateTransformations
using Random

println("Starting MeshCat Server inside WSL...")
vis = Visualizer()


println("\n========================================================")
println("🚀 OPEN THIS LINK IN YOUR WINDOWS WEB BROWSER:")
println("   ", vis)
# println("   ", url(vis))
println("========================================================\n")

# Generating 3D Flight Data (Spiral Path)
N_steps = 50
t = range(0, 10pi, length=N_steps)
true_x = cos.(t) .* 5.0
true_y = sin.(t) .* 5.0
true_z = range(0, 20.0, length=N_steps)

# Setting up the 3D Scene Geometry
# Creating a simple "cyan box" to represent the drone
drone_shape = Rect3f(Vec3f(-0.2, -0.2, -0.1), Vec3f(0.4, 0.4, 0.2))
drone_material = MeshLambertMaterial(color=colorant"cyan")
setobject!(vis["drone"], drone_shape, drone_material)

# Drawing the true flight path as a faint blue trail of dots
path_points = [Point3f(true_x[i], true_y[i], true_z[i]) for i in 1:N_steps]
path_colors = fill(RGBA(0.0, 0.0, 1.0, 0.3), N_steps)
setobject!(vis["path"], PointCloud(path_points, path_colors))

println("Waiting 10 seconds for you to open the browser link...")
sleep(10)

println("Simulating flight...")
noise_level = 1.0

# Animation Loop
for i in 1:N_steps
    # Moving the physical drone to its true position
    settransform!(vis["drone"], Translation(true_x[i], true_y[i], true_z[i]))
    
    # Generating 500 "ghost" particles representing the Particle Filter's uncertainty
    particles = [
        Point3f(
            true_x[i] + randn() * noise_level, 
            true_y[i] + randn() * noise_level, 
            true_z[i] + randn() * noise_level
        ) for _ in 1:500
    ]
    
    # MeshCat handles 'PointCloud' objects incredibly fast.
    # We color the uncertainty cloud red with 30% opacity.
    cloud_colors = fill(RGBA(1.0, 0.0, 0.0, 0.3), 500)
    setobject!(vis["uncertainty_cloud"], PointCloud(particles, cloud_colors))
    
    # Pausing slightly so we can watch it happen in real-time (~15 FPS)
    sleep(0.06)
end

println("Simulation complete! Press Enter in this terminal to close the server.")
readline()