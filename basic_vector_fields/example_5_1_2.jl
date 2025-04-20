using PlotlyJS

x_eq(t, x0, a) = x0 * exp(a * t)
y_eq(t, y0) = y0 * exp(-t)
x0s = range(-1.0, 1.0, 3)
y0s = range(-1.0, 1.0, 3)
ts = range(-1.0, 1.0, length=10)
a = -2.0
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
