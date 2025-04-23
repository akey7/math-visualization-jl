using LinearAlgebra
using PlotlyJS

function solve_for_ics(A::Matrix{Float64}, ics::Vector{Float64})
    println("#####################################################")
    println("# BEGIN SOLVE                                       #")
    println("#####################################################")
    println("A:")
    display(A)
    println("Initial conditions:")
    display(ics)
    eig = eigen(A)
    println("Eigenvalues")
    λ = eig.values
    display(λ)
    println("Normalized eigenvectors")
    v = eig.vectors
    display(v)
    c = eig.vectors \ ics
    println("c1 and c2")
    display(c)
    x_eq(t::Float64) = c[1]*v[1, 1]*exp(λ[1]*t) + c[2]*v[1, 2]*exp(λ[2]*t)
    y_eq(t::Float64) = c[1]*v[1, 2]*exp(λ[1]*t) + c[2]*v[2, 2]*exp(λ[2]*t)
    x_eq, y_eq
end

function portrait(
    A::Matrix{Float64},
    r::Float64,
    ts::Vector{Float64},
    width::Int64 = 500,
    height::Int64 = 500,
)
    angles = [0.0, π/4, π/2, π, 3π/4, 5π/4, 3π/2, 7π/4]
    x0s = [r * cos(θ) for θ ∈ angles]
    y0s = [r * sin(θ) for θ ∈ angles]
    traces::Vector{GenericTrace} = []
    for (i, (x0, y0)) ∈ enumerate(Base.product(x0s, y0s))
        x_eq, y_eq = solve_for_ics(A, [x0, y0])
        xs = x_eq.(ts)
        ys = y_eq.(ts)
        showlegend = i == 1
        trace_start = scatter(
            x = [xs[1]],
            y = [ys[1]],
            mode = "markers",
            marker = attr(color = "blue", size = 10),
            name = "start",
            showlegend = showlegend,
        )
        trace_line = scatter(
            x = xs,
            y = ys,
            mode = "lines",
            marker = attr(color = "black"),
            name = "path",
            showlegend = showlegend,
        )
        trace_end = scatter(
            x = [xs[end]],
            y = [ys[end]],
            mode = "markers",
            marker = attr(color = "red", size = 10),
            name = "stop",
            showlegend = showlegend,
        )
        push!(traces, trace_start)
        push!(traces, trace_line)
        push!(traces, trace_end)
    end
    title = string(A)
    plot_bgcolor = "white"
    paper_bgcolor = "white"
    border_width = 1
    gridwidth = 1
    border_color = "black"
    gridcolor = "lightgray"
    layout = Layout(
        plot_bgcolor = plot_bgcolor,
        paper_bgcolor = paper_bgcolor,
        title = title,
        xaxis = attr(
            showline = true,
            linewidth = border_width,
            linecolor = border_color,
            mirror = true,
            showgrid = true,
            gridcolor = gridcolor,
            gridwidth = gridwidth,
        ),
        yaxis = attr(
            showline = true,
            linewidth = border_width,
            linecolor = border_color,
            mirror = true,
            showgrid = true,
            gridcolor = gridcolor,
            gridwidth = gridwidth,
        ),
        width = width,
        height = height,
    )
    plot(traces, layout)
end

display(portrait([1.0 1.0; 4.0 -2.0], 1.0, collect(range(-0.75, 0.75, 100))))
display(portrait([2.0 2.0; 3.0 -3.0], 1.0, collect(range(-0.5, 0.5, 100))))
println("Press enter to exit...")
readline()
