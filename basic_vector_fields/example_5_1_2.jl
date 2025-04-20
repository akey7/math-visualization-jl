using PlotlyJS

x_eq(t, x0, a) = x0 * exp(a * t)
y_eq(t, y0) = y0 * exp(-t)


# x0s = range(-2.0, 2.0, 5)
# y0s = range(-2.0, 2.0, 5)

x0s::Vector{Float64} = []
y0s::Vector{Float64} = []
for r in [0.3, 0.7, 1.2, 1.8] # Different starting distances
    for angle in range(0, 2*pi, length=9)[1:end-1] # 8 angles around the circle
        x0 = r * cos(angle)
        y0 = r * sin(angle)
        push!(x0s, x0)
        push!(y0s, y0)
    end
end

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
