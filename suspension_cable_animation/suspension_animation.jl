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

Returns
`Vector{Float64}`
Vector of solutions to the tension equation.
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

"""
    curve(; xs::Vector{Float64}, dist_from_support::Float64, w::Float64, s::Float64, guess_lower::Float64, guess_upper::Float64)

Calculate curve of a suspension cable (supported by two supports) from one support to another.

Arguments
1. `xs::Vector{Float64}` Vector of x coordinates along which to calculate the curve.
2. `dist_from_support::Float64` Distance of the bottom of the cable from the support.
3. `w::Float64` Weight of the cable in lb/ft
4. `s::Float64` Total length of the cable in feet.
5. `guess_lower::Float64` Lower bound of guessed tension range. For the solver. Should encompass all possible ranges of tensions.
6. `guess_upper::Float64` Upper bound of guessed tension range. For the solver. Should encompass all possible ranges of tensions.

Returns
`Vector{Float64}`
Y coordinates corresponding to each x coordinate.
"""
function curve(; xs::Vector{Float64}, dist_from_support::Float64, w::Float64, s::Float64, guess_lower::Float64, guess_upper::Float64)
    ys = zeros(Float64, length(xs))
    for (i, x) ∈ enumerate(xs)
        h = tension(x = dist_from_support, w = w, s = s, guess_lower = guess_lower, guess_upper = guess_upper)
        if length(h) < 1
            throw(ErrorException("No solutions for tension! s=$s, w=$w, x=$x, guess_lower=$guess_lower, guess_upper=$guess_upper"))
        end
        ys[i] = h[1] / w * cosh(w * x / h[1])
    end
    ys
end
