# Calculus Operations

Comprehensive reference for calculus operations in Wolfram Language.

## Integration

### Indefinite Integration

```bash
# Basic integration
wolframscript -wstpserver -code "Integrate[x^2, x]"
# Output: x^3/3

# Polynomial integration
wolframscript -wstpserver -code "Integrate[3*x^2 + 2*x + 1, x]"
# Output: x^3 + x^2 + x

# Trigonometric integration
wolframscript -wstpserver -code "Integrate[Sin[x], x]"
# Output: -Cos[x]

# Exponential integration
wolframscript -wstpserver -code "Integrate[Exp[x], x]"
# Output: E^x
```

### Definite Integration

```bash
# Numeric bounds
wolframscript -wstpserver -code "Integrate[x^2, {x, 0, 1}]"
# Output: 1/3

# Infinite bounds
wolframscript -wstpserver -code "Integrate[Exp[-x^2], {x, -Infinity, Infinity}]"
# Output: Sqrt[Pi]

# Complex definite integral
wolframscript -wstpserver -code "Integrate[x^3 * Exp[-x^2], {x, 0, Infinity}]"
# Output: 1/2
```

### Multiple Integration

```bash
# Double integral
wolframscript -wstpserver -code "Integrate[x*y, {x, 0, 1}, {y, 0, 1}]"
# Output: 1/4

# Triple integral
wolframscript -wstpserver -code "Integrate[x*y*z, {x, 0, 1}, {y, 0, 1}, {z, 0, 1}]"
# Output: 1/8
```

## Differentiation

### Basic Derivatives

```bash
# Power rule
wolframscript -wstpserver -code "D[x^3, x]"
# Output: 3*x^2

# Product rule
wolframscript -wstpserver -code "D[x*Sin[x], x]"
# Output: x*Cos[x] + Sin[x]

# Quotient rule
wolframscript -wstpserver -code "D[Sin[x]/Cos[x], x]"
# Output: Sec[x]^2
```

### Partial Derivatives

```bash
# With respect to x
wolframscript -wstpserver -code "D[x^2*y^3, x]"
# Output: 2*x*y^3

# With respect to y
wolframscript -wstpserver -code "D[x^2*y^3, y]"
# Output: 3*x^2*y^2

# Mixed partial derivative
wolframscript -wstpserver -code "D[x^2*y^3, x, y]"
# Output: 6*x*y^2
```

### Higher-Order Derivatives

```bash
# Second derivative
wolframscript -wstpserver -code "D[Sin[x], {x, 2}]"
# Output: -Sin[x]

# Third derivative
wolframscript -wstpserver -code "D[x^4, {x, 3}]"
# Output: 24*x
```

## Limits

### Basic Limits

```bash
# Simple limit
wolframscript -wstpserver -code "Limit[Sin[x]/x, x -> 0]"
# Output: 1

# Limit at infinity
wolframscript -wstpserver -code "Limit[(1 + 1/x)^x, x -> Infinity]"
# Output: E

# One-sided limit
wolframscript -wstpserver -code "Limit[1/x, x -> 0, Direction -> \"FromAbove\"]"
# Output: Infinity
```

### L'Hôpital's Rule

```bash
# Indeterminate form
wolframscript -wstpserver -code "Limit[(Exp[x] - 1)/x, x -> 0]"
# Output: 1

wolframscript -wstpserver -code "Limit[(x^2 - 1)/(x - 1), x -> 1]"
# Output: 2
```

## Series Expansions

### Taylor Series

```bash
# Around x=0
wolframscript -wstpserver -code "Series[Exp[x], {x, 0, 5}]"
# Output: 1 + x + x^2/2 + x^3/6 + x^4/24 + x^5/120 + O[x]^6

# Around x=1
wolframscript -wstpserver -code "Series[Log[x], {x, 1, 3}]"

# Sin[x] series
wolframscript -wstpserver -code "Series[Sin[x], {x, 0, 7}]"
# Output: x - x^3/6 + x^5/120 - x^7/5040 + O[x]^8
```

### Laurent Series

```bash
# Series with negative powers
wolframscript -wstpserver -code "Series[1/Sin[x], {x, 0, 3}]"
```

## Differential Equations

### Ordinary Differential Equations (ODEs)

```bash
# First-order ODE
wolframscript -wstpserver -code "DSolve[y'[x] == y[x], y[x], x]"
# Output: {{y[x] -> E^x*C[1]}}

# With initial condition
wolframscript -wstpserver -code "DSolve[{y'[x] == y[x], y[0] == 1}, y[x], x]"
# Output: {{y[x] -> E^x}}

# Second-order ODE
wolframscript -wstpserver -code "DSolve[y''[x] + y[x] == 0, y[x], x]"
# Output: {{y[x] -> C[1]*Cos[x] + C[2]*Sin[x]}}
```

### Numerical ODE Solutions

```bash
# NDSolve for complex equations
wolframscript -wstpserver -code "NDSolve[{y'[x] == -y[x], y[0] == 1}, y, {x, 0, 5}]"
```

## Vector Calculus

### Gradient

```bash
# Gradient of scalar field
wolframscript -wstpserver -code "Grad[x^2 + y^2 + z^2, {x, y, z}]"
# Output: {2*x, 2*y, 2*z}
```

### Divergence

```bash
# Divergence of vector field
wolframscript -wstpserver -code "Div[{x, y, z}, {x, y, z}]"
# Output: 3
```

### Curl

```bash
# Curl of vector field
wolframscript -wstpserver -code "Curl[{-y, x, 0}, {x, y, z}]"
# Output: {0, 0, 2}
```

## Advanced Topics

### Laplace Transform

```bash
wolframscript -wstpserver -code "LaplaceTransform[Sin[t], t, s]"
# Output: 1/(1 + s^2)

# Inverse Laplace
wolframscript -wstpserver -code "InverseLaplaceTransform[1/s, s, t]"
# Output: 1
```

### Fourier Transform

```bash
wolframscript -wstpserver -code "FourierTransform[Exp[-x^2], x, k]"
# Output: E^(-k^2/4)/Sqrt[2]
```

## Tips

1. **Symbolic vs. Numeric**: Use `Integrate` for symbolic, `NIntegrate` for numerical
2. **Assumptions**: Add assumptions for cleaner results: `Assuming[x > 0, Integrate[...]]`
3. **Simplification**: Use `Simplify` or `FullSimplify` on results
4. **Pattern matching**: Use `/.` for substitution: `D[f[x], x] /. x -> 2`
