using Plots
using Roots
using Printf

"""
    tension(; s::Float64, x::Float64, w::Float64, guess_lower::Float64, guess_upper::Float64)

Calculate tension at bottom of a suspension cable hung from two supports.

Arguments
1. `s::Float64` Half the length of the cable in feet.
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
4. `s::Float64` Half the length of the cable in feet.
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

"""
    render_frame(anim::Plots.Animation, max_dist_from_support::Float64, dist_from_support::Float64)

Render a single frame of the suspension cable with the bottom at a particular distance from the supports and supports going up to where the supports would be.

Arguments
1. `anim::Plots.Animation` Animation to render into.
2. `max_dist_from_support::Float64` The maximum distance the bottom might be at from the supports to keep parts of the animation constant.
3. `dist_from_support::Float64` The distance from support of the center of the cable for this frame.
"""
function render_frame(
    anim::Plots.Animation,
    dist_from_support::Float64,
)
    xs = collect(
        range(start = -dist_from_support, stop = dist_from_support, length = 100),
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
        xlims = (-25.0, 25.0),
        ylims = (0.0, 30.0),
        legend = :none,
        linewidth = 10.0,
        size = (1080, 1920 / 2),
    )
    plot!([minimum(xs), minimum(xs)], [0.0, maximum(ys)], color = :red, linewidth = 7.0)
    plot!([maximum(xs), maximum(xs)], [0.0, maximum(ys)], color = :red, linewidth = 7.0)
    height_annotation = @sprintf("%.1f", maximum(ys))
    annotate!(minimum(xs), maximum(ys) + 1.0, text("$height_annotation ft", :black, 20))
    bottom_location = ys[Int64(length(ys) / 2)]
    bottom_annotation = @sprintf("%.1f", bottom_location)
    annotate!(0.0, bottom_location + 1.0, text("$bottom_annotation ft", :black, 20))
    quiver!([0.0], [0.0], quiver = ([0.0], [bottom_location - 0.5]), color = :orange, linewidth = 7.0)
    width_dimension = maximum(xs) - minimum(xs)
    width_annotation = @sprintf("%.1f", width_dimension)
    annotate!(0.0, maximum(ys), text("$width_annotation ft", :black, 20))
    quiver!([3.0], [maximum(ys)], quiver = ([maximum(xs) - 3.75], [0.0]), color = :orange, linewidth = 7.0)
    quiver!([-3.0], [maximum(ys)], quiver = ([minimum(xs) + 3.75], [0.0]), color = :orange, linewidth = 7.0)
    frame(anim)
end

"""
    render_curve_animation()

Render the animation by calling the frame generation function in a loop.
"""
function render_curve_animation()
    fps = 30
    seconds = 5
    n_frames = Int64(fps * seconds / 2)
    anim = Animation()
    seq1 = range(start = 18.0, stop = 15.0, length = n_frames)
    seq2 = range(start = 15.0, stop = 18.0, length = n_frames)
    dists_from_support = [seq1; seq2]
    for dist_from_support ∈ dists_from_support
        render_frame(anim, dist_from_support)
    end
    mp4(anim, "suspension_animation.mp4", fps = fps)
end

render_curve_animation()
