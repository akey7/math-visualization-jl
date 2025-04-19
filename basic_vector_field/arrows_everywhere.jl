using PlotlyJS

function f_xv(x::Float64, v::Float64, ω::Float64 = 1.0)
    (v, -ω^2*x)
end

annotations = []
xs::Vector{Float64} = []
vs::Vector{Float64} = []
for x ∈ range(-1.0, 1.0, 3)
    for v ∈ range(-1.0, 1.0, 3)
        push!(xs, x)
        push!(vs, v)
        (ẋ, v̇) = f_xv(x, v)
        annotation = attr(
            ax = x,
            ay = v,
            x = x + ẋ,
            y = v + v̇,
            axref = "x",
            ayref = "y",
            showarrow = true,
            arrowcolor = "black",
            arrowhead = 2,
            arrowsize = 2,
            text = "",
        )
        push!(annotations, annotation)
    end
end
trace1 = scatter(
    x = xs,
    y = vs,
    mode = "markers",
    marker = attr(color = "blue", size = 10),
)
layout = Layout(annotations = annotations, width = 500, height = 500)
p = plot([trace1], layout)
display(p)
println("Press enter to exit...")
readline()
