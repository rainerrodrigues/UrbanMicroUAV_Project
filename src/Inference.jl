module Inference

# Explicitly declaring dependencies for this module
using Turing
using Distributions
using LinearAlgebra

# Exporting this functions for scripts/ folder
export hierarchical_swarm_id

"""
    hierarchical_swarm_id(fleet_telemetry, drone_masses)

A Hierarchical Bayesian model for a UAV swarm. 
It identifies a shared "Global Wind" disturbance while estimating the 
individual, local aerodynamic degradation (drag) of each drone in the fleet.
"""
@model function hierarchical_swarm_id(fleet_telemetry, drone_masses)
    num_drones = length(fleet_telemetry)
    
    # Global Priors: The shared environment (e.g., Wind in the corridor)
    # We assume the swarm is flying in the same general wind conditions
    global_wind_μ ~ Normal(5.0, 2.0)
    global_wind_σ ~ Exponential(1.0)
    
    # Local Priors: Drone-specific physics
    drone_drag = Vector{Real}(undef, num_drones)
    
    for i in 1:num_drones
        # The drag of drone 'i' is fundamentally linked to the global wind, 
        # but modulated by its specific physical design (its mass in kg)
        expected_drag = global_wind_μ * (1.0 / drone_masses[i])
        
        # Each drone draws its individual drag from the global distribution
        drone_drag[i] ~ Normal(expected_drag, global_wind_σ)
        
        # Likelihood: Fit the model to the actual sensor data of drone 'i'
        telemetry_data = fleet_telemetry[i]
        for t in 1:length(telemetry_data)
            telemetry_data[t] ~ Normal(drone_drag[i], 0.5) # 0.5 is the assumed sensor noise
        end
    end
end

end 