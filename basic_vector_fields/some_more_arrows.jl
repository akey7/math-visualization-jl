using PlotlyJS

function f_xv(x::Float64, v::Float64, ω::Float64 = 1.0)
    (v, -ω^2*x)
end


