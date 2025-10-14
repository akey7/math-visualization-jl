using Random

Random.seed!(123)
transition_matrix = [0.5 0.1 0.4; 0.1 0.6 0.3; 0.7 0.15 0.15]
function run_chain(n_steps, initial_state)
    random_nums = rand(n_steps)
    steps = zeros(Int64, n_steps)
    steps[1] = initial_state
    for i in eachindex(steps)[2:end]
        prev_state = steps[i-1]
        prev_probs = transition_matrix[prev_state,:]
        random_num = random_nums[i-1]
        if random_num < prev_probs[1]
            steps[i] = 1
        elseif random_num < (prev_probs[1] + prev_probs[2])
            steps[i] = 2
        else
            steps[i] = 3
        end
    end
    return steps
end
println(run_chain(100, 1.0))
