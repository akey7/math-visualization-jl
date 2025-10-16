using Random

Random.seed!(123)
transition_matrix = [0.5 0.1 0.4; 0.1 0.6 0.3; 0.7 0.15 0.15]
function run_chain(n_steps, initial_state)
    random_nums = rand(n_steps)
    chain = zeros(Int64, n_steps)
    chain[1] = initial_state
    for i in eachindex(chain)[2:end]
        prev_state = chain[i-1]
        prev_probs = transition_matrix[prev_state, :]
        random_num = random_nums[i-1]
        if random_num < prev_probs[1]
            chain[i] = 1
        elseif random_num < (prev_probs[1] + prev_probs[2])
            chain[i] = 2
        else
            chain[i] = 3
        end
    end
    return chain
end
function count_states(chain)
    counts = zeros(Int64, 3)
    for state in chain
        counts[state] += 1
    end
    fractions = counts ./ length(chain)
    return fractions
end
single_chain = run_chain(10_000, 1)
println(count_states(single_chain))
