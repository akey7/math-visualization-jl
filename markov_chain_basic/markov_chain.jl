using Random

Random.seed!(123)
transition_matrix = [0.5 0.1 0.4; 0.1 0.6 0.3; 0.7 0.15 0.15]
function run_chain(n_steps, initial_state)
    random_nums = rand(Float64, n_steps)
    steps = zeros(Float64, n_steps)
    return steps[1:100]
end
println(run_chain(10_000, 1))
