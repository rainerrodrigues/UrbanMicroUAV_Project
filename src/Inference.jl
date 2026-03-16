module Inference
using Turing
using DifferentialEquations
using SciMLSensitivity # Needed for diff-eq gradients

@model function estimate_drag(noisy_altitude_data, prob)
    # Prior: We are guess the drag coefficient is somewhere around 0.5
    c ~ truncated(Normal(0.5, 0.2), 0.0, 2.0)
    
    # Updating the problem with the new guessed parameter
    # Parameters are: mass=1.0, gravity=9.81, drag=c
    p = [1.0, 9.81, c]
    new_prob = remake(prob, p=p)
    
    # Solving the differential equation
    sol = solve(new_prob, Tsit5(), saveat=0.1)
    
    # Observation Model: Comparing simulation to noisy sensor data
    for i in 1:length(noisy_altitude_data)
        noisy_altitude_data[i] ~ Normal(sol[1, i], 0.1) # 0.1 is sensor noise
    end
end

export estimate_drag
end