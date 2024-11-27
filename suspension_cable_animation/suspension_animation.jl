using Plots
using Roots

"""
    tension(; s::Float64, x::Float64, w::Float64, guess_lower::Float64, guess_upper::Float64)

Calculate tension at bottom of a suspension cable hung from two supports.

Arguments
1. `s::Float64` Total length of the cable in feet.
2. `x::Float64` Distance of bottom of cable from supports in feet.
3. `w::Float64` Weight of the cable in lb/ft
4. `guess_lower::Float64` Lower bound of guessed tension range. For the solver.
5. `guess_upper::Float64` Upper bound of guessed tension range. For the solver.
"""
function tension(;
    s::Float64,
    x::Float64,
    w::Float64,
    guess_lower::Float64,
    guess_upper::Float64,
)
    partial(h) = h / w * sinh(w * x / h) - s
    fzeros(partial, guess_lower, guess_upper)
end
