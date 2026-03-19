module StateEstimation

using Turing
using Distributions
using LinearAlgebra
using Statistics

# Explicitly export the models so my scripts can use them
export smc_drone_tracker, bnn_turbulence_model

"""
    smc_drone_tracker(obs_y, blackout_start, blackout_end)

A Hidden Markov Model utilizing Sequential Monte Carlo (SMC) to estimate a drone's 
true position. Dynamically handles sensor degradation (e.g., GPS blackouts).
"""
@model function smc_drone_tracker(y, blackout_start=10, blackout_end=20)
    N = length(y)
    x = Vector{Real}(undef, N) # The drone's internal belief
    
    # Prior state
    x[1] ~ Normal(0.0, 1.0)
    y[1] ~ Normal(x[1], 0.5)
    
    for t in 2:N
        # Physics Step: Predict forward movement
        x[t] ~ Normal(x[t-1] + 1.0, 0.2)
        
        # Sensor Step: Filter updates based on environmental degradation
        if t >= blackout_start && t <= blackout_end
            # Factor Graph Logic: Discard sensor trust during blackout
            y[t] ~ Normal(x[t], 10.0) 
        else
            # Normal GPS operation
            y[t] ~ Normal(x[t], 0.5)  
        end
    end
end

"""
    bnn_turbulence_model(X, Y)

A Bayesian Neural Network that predicts unmodeled aerodynamic turbulence. 
Outputs both predictions and epistemic uncertainty (confidence bounds) for safe Sim-to-Real transfer.
"""
@model function bnn_turbulence_model(X, Y)
    # Architecture: 2 Inputs -> 3 Hidden Nodes -> 1 Output
    
    # Layer 1 Priors
    W1 ~ filldist(Normal(0, 1), 3, 2)
    b1 ~ filldist(Normal(0, 1), 3)
    
    # Layer 2 Priors
    W2 ~ filldist(Normal(0, 1), 1, 3)
    b2 ~ filldist(Normal(0, 1), 1)
    
    # Forward Pass
    for i in 1:size(X, 2)
        hidden = tanh.(W1 * X[:, i] .+ b1)
        pred_Y = (W2 * hidden .+ b2)[1]
        
        # Likelihood against real flight data
        Y[i] ~ Normal(pred_Y, 0.1)
    end
end

end 