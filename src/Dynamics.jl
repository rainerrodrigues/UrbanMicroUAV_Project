module Dynamics

using DifferentialEquations

# Exporting the functions so your scripts can use them
export drone_altitude!, simulate_flight_dynamics

"""
    drone_altitude!(du, u, p, t)

The core physical Differential Equation governing 1D vertical drone flight.
Calculates acceleration based on thrust, gravity, aerodynamic drag, and wind.
"""
function drone_altitude!(du, u, p, t)
    # State variables: u[1] = altitude, u[2] = velocity
    velocity = u[2]
    
    # Parameters: p[1] = mass, p[2] = gravity, p[3] = drag coefficient (c)
    mass = p[1]
    gravity = p[2]
    drag_coeff = p[3]
    
    # Simple control logic: Thrust counters gravity plus a little extra to go up
    thrust = gravity * mass + 2.0 
    
    # Unpredictable urban wind gust simulation
    wind_disturbance = 0.5 * sin(t)
    
    # Rate of change of altitude is velocity
    du[1] = velocity
    
    # Rate of change of velocity is acceleration (F = ma)
    du[2] = (thrust / mass) - gravity - (drag_coeff / mass) * velocity + wind_disturbance
end

"""
    simulate_flight_dynamics(mass, drag_coeff; tspan=(0.0, 5.0))

A helper function that sets up and solves the ODE for a given mass and drag.
Returns the solved continuous-time flight trajectory.
"""
function simulate_flight_dynamics(mass, drag_coeff; tspan=(0.0, 5.0))
    u0 = [0.0, 0.0] # Start at ground level, zero velocity
    p = [mass, 9.81, drag_coeff]
    
    prob = ODEProblem(drone_altitude!, u0, tspan, p)
    sol = solve(prob, saveat=0.1)
    
    return sol
end

end 