module Dynamics
using DifferentialEquations

# Simple 1-D Drone Physics
function drone_altitude!(du, u, p, t)
    z, v = u
    m, g, c = p

    Thrust = 15.0

    du[1] = v
    du[2] = (Thrust / m) - g - (c / m) * v * abs(v)
end

export drone_altitude!
end