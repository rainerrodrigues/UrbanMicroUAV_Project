module Optimization

using Optim
using Statistics

export optimize_uav_design

"""
    evaluate_design_cost(mass, simulate_func; target_altitude=15.0)

Calculates a 'Fitness Score' for a given drone mass. 
It runs the physics simulation and penalizes the design for deviating from the 
target altitude (due to urban wind gusts) and for being excessively heavy.
"""
function evaluate_design_cost(mass, simulate_func; target_altitude=15.0)
    #  Physics constraint: Drones cannot have zero or negative mass
    if mass <= 0.1
        return 99999.0 
    end
    
    # Morphological rule: A heavier drone requires a larger frame, 
    # which increases its aerodynamic drag coefficient.
    base_drag = 0.42
    dynamic_drag = base_drag * (mass / 0.5) 
    
    # Running the physics simulation (passed in from Dynamics.jl)
    sol = simulate_func(mass, dynamic_drag; tspan=(0.0, 10.0))
    
    # Calculating tracking error (Mean Squared Error from target altitude)
    altitudes = sol[1, :]
    mse = mean((altitudes .- target_altitude).^2)
    
    # Adding a battery/weight penalty (heavier drones drain batteries faster)
    weight_penalty = 2.0 * mass
    
    # Total Cost (Lower is better)
    return mse + weight_penalty
end

"""
    optimize_uav_design(simulate_func)

Uses the Nelder-Mead optimization algorithm to find the mathematically perfect 
drone mass that balances wind stability with battery efficiency.
"""
function optimize_uav_design(simulate_func)
    # Optim.jl expects a function that takes an array of parameters
    objective_function(params) = evaluate_design_cost(params[1], simulate_func)
    
    # Initial guess: Let's start by assuming a 1.0 kg drone
    initial_guess = [1.0]
    
    # Run the gradient-free Nelder-Mead solver
    result = optimize(objective_function, initial_guess, NelderMead())
    
    optimal_mass = Optim.minimizer(result)[1]
    min_cost = Optim.minimum(result)
    
    return optimal_mass, min_cost
end

end 