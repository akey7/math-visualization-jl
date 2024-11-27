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
    dist_from_support::Float64,
    w::Float64,
    guess_lower::Float64,
    guess_upper::Float64,
)
    partial(h) = h / w * sinh(w * dist_from_support / h) - s
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
function curve(;
    xs::Vector{Float64},
    dist_from_support::Float64,
    w::Float64,
    s::Float64,
    guess_lower::Float64,
    guess_upper::Float64,
)
    ys = zeros(Float64, length(xs))
    for (i, x) ∈ enumerate(xs)
        h = tension(
            dist_from_support = dist_from_support,
            w = w,
            s = s,
            guess_lower = guess_lower,
            guess_upper = guess_upper,
        )
        if length(h) < 1
            throw(
                ErrorException(
                    "No solutions for tension! s=$s, w=$w, dist_from_support=$dist_from_support, guess_lower=$guess_lower, guess_upper=$guess_upper",
                ),
            )
        end
        ys[i] = h[1] / w * cosh(w * x / h[1])
    end
    ys
end

function render_frame(anim::Plots.Animation, max_dist_from_support::Float64, dist_from_support::Float64)
    width = 1080
    height = 1920 / 2
    xs = collect(
        range(start = -max_dist_from_support, stop = max_dist_from_support, length = 100),
    )
    ys = curve(
        xs = xs,
        dist_from_support = dist_from_support,
        w = 5.0,
        s = 25.0,
        guess_lower = 0.0,
        guess_upper = 100.0,
    )
    plot(
        xs,
        ys,
        xlims = (-20.0, 25.0),
        ylims = (0.0, maximum(ys) * 1.1),
        legend = :none,
        linewidth = 3.0,
        height = height,
        width = width,
    )
    plot!([minimum(xs), minimum(xs)], [0.0, maximum(ys)], color = :red, linewidth = 7.0)
    plot!([maximum(xs), maximum(xs)], [0.0, maximum(ys)], color = :red, linewidth = 7.0)
    frame(anim)
end

function render_curve_animation()
    fps = 30
    seconds = 5
    n_frames = fps * seconds
    anim = Animation()
    dists_from_support = range(start = 15.0, stop = 20.0, length = n_frames)
    for dist_from_support ∈ dists_from_support
        render_frame(anim, 20.0, dist_from_support)
    end
    mp4(anim, "suspension_animation.mp4", fps = fps)
end

render_curve_animation()
