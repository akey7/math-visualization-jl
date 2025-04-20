using PlotlyJS

x_eq(t, x0, a) = x0 * exp(a * t)
y_eq(t, y0) = y0 * exp(-t)

x0s::Vector{Float64} = []
y0s::Vector{Float64} = []
for angle in range(0, 2π, length=9)
    x0 = cos(angle)
    y0 = sin(angle)
    push!(x0s, x0)
    push!(y0s, y0)
end

ts = range(-1.0, 1.0, length=10)
a = -1.0
traces::Vector{GenericTrace} = []
for (x0, y0) ∈ zip(x0s, y0s)
    xs = x_eq.(ts, x0, a)
    ys = y_eq.(ts, y0)
    trace = scatter(x = xs, y = ys, mode = "lines")
    push!(traces, trace)
end
layout = Layout(width = 500, height = 500)
p = plot(traces, layout)
display(p)
println("Press enter to exit")
readline()
