using Pkg
Pkg.activate(".")
using MeshCat
using GeometryBasics
using Colors
using CoordinateTransformations
using LinearAlgebra 
using Random
using FileIO

println("Starting MeshCat Server inside WSL...")
vis = Visualizer()

println("\n========================================================")
println("🚀 OPENING THIS LINK IN YOUR WINDOWS WEB BROWSER:")
println("   ", vis)
println("========================================================\n")

# Generating 3D Flight Data (Spiral Path)
N_steps = 150 # Increased for a longer, smoother flight
t = range(0, 10pi, length=N_steps)
true_x = cos.(t) .* 5.0
true_y = sin.(t) .* 5.0
true_z = range(0, 20.0, length=N_steps)

println("Loading 3D drone mesh...")

# Pointing to the asset folder
drone_path = joinpath(@__DIR__, "..", "assets", "new_dronev_whole.stl") 
println("Loading 3D drone mesh from: ", drone_path)

if isfile(drone_path)
    drone_mesh = load(drone_path)
else
    error("❌ File not found! Make sure 'new_dronev_whole.stl' is inside the 'assets/' folder.")
end

drone_material = MeshLambertMaterial(color=colorant"darkgrey")

# Parent-Child Hierarchy for the Mesh
setobject!(vis["drone"]["geometry"], drone_mesh, drone_material)

# Applying the scale and the offset to the CHILD node to fix the CAD center-of-mass
scale_factor = 0.005
local_offset = Translation(0.0, -1.5, 0.0) ∘ LinearMap(UniformScaling(scale_factor))
settransform!(vis["drone"]["geometry"], local_offset)

# Drawing the true flight path as a faint blue trail of dots
path_points = [Point3f(true_x[i], true_y[i], true_z[i]) for i in 1:N_steps]
path_colors = fill(RGBA(0.0, 0.0, 1.0, 0.3), N_steps)
setobject!(vis["path"], PointCloud(path_points, path_colors))

println("Waiting 10 seconds for you to open the browser link...")
sleep(10)

println("Simulating flight...")
noise_level = 1.0

# The Animation Loop
for i in 1:N_steps
    # Because we fixed the geometry in the child node, we only move the PARENT node here.
    # No scaling is needed here; the parent just represents the exact (X, Y, Z) coordinate.
    settransform!(vis["drone"], Translation(true_x[i], true_y[i], true_z[i]))
    
    # Generating 500 "ghost" particles representing the Particle Filter's uncertainty
    particles = [
        Point3f(
            true_x[i] + randn() * noise_level, 
            true_y[i] + randn() * noise_level, 
            true_z[i] + randn() * noise_level
        ) for _ in 1:500
    ]
    
    # Updating the red uncertainty cloud
    cloud_colors = fill(RGBA(1.0, 0.0, 0.0, 0.3), 500)
    setobject!(vis["uncertainty_cloud"], PointCloud(particles, cloud_colors))
    
    sleep(0.06)
end

println("Simulation complete! Press Enter in this terminal to close the server.")
readline()