using Symbolics

@variables a b x y
x_dot = -x + a*y + x^2*y
y_dot = b - a*y - x^2*y
F = [x_dot, y_dot]
vars = [x, y]
J = Symbolics.jacobian(F, vars; simplify = true)
display(J)
