---
name: wolframscript
description: Execute Wolfram Language computations. Use for symbolic math, calculus, algebra, solving equations, matrix operations, statistics, numerical methods, and data analysis. Connects to WSTP server for 6x faster execution.
---

# WolframScript - Wolfram Language CLI

Execute Wolfram Language computations with optional WSTP server for high performance.

## Quick Start

### Basic Execution

```bash
# Simple calculation
wolframscript -code "2+2"

# With WSTP server (6x faster)
wolframscript -wstpserver -code "Integrate[x^2, x]"
```

### Performance

- **Standalone**: ~2.1s (starts new kernel each time)
- **WSTP server** (`-wstpserver`): ~0.34s (connects to existing kernel)
- **Speedup**: 6.2x faster with WSTP server

**Recommendation**: Use `-wstpserver` flag for repeated computations.

## Common Patterns

### Execute Code

```bash
# Direct expression
wolframscript -wstpserver -code "Solve[x^2 - 5*x + 6 == 0, x]"

# Multiple statements
wolframscript -wstpserver -code "x = 5; y = x^2; x + y"
```

### Persistent Sessions

Maintain state across invocations:

```bash
# Start session
wolframscript -wstpserver -startprofile my_session -code "x = 42"

# Continue session (variables persist)
wolframscript -wstpserver -continueprofile my_session -code "x + 10"
# Returns: 52
```

### Run Script Files

```bash
# Execute .wls file
wolframscript -wstpserver script.wls

# Pass arguments
wolframscript -wstpserver script.wls arg1 arg2
```

## Key Options

- `-code "expr"` — Execute expression
- `-wstpserver` — Connect to WSTP server (port 31415)
- `-startprofile name` — Start persistent session
- `-continueprofile name` — Continue existing session
- `-format format` — Output format (Text, JSON, XML)
- `-timeout seconds` — Execution timeout

## Quick Examples by Category

### Calculus
```bash
# Integration
wolframscript -wstpserver -code "Integrate[x^2, x]"
# Output: x^3/3

# Differentiation
wolframscript -wstpserver -code "D[Sin[x]*Cos[x], x]"
# Output: Cos[x]^2 - Sin[x]^2
```

### Algebra
```bash
# Solve equations
wolframscript -wstpserver -code "Solve[x^2 - 4 == 0, x]"
# Output: {{x -> -2}, {x -> 2}}

# Simplify
wolframscript -wstpserver -code "Simplify[(x+1)^2 - (x^2 + 2*x + 1)]"
# Output: 0
```

### Linear Algebra
```bash
# Matrix determinant
wolframscript -wstpserver -code "Det[{{1, 2}, {3, 4}}]"
# Output: -2

# Eigenvalues
wolframscript -wstpserver -code "Eigenvalues[{{1, 2}, {2, 1}}]"
# Output: {3, -1}
```

### Numerical Methods
```bash
# Find roots
wolframscript -wstpserver -code "FindRoot[Cos[x] == x, {x, 1}]"
# Output: {x -> 0.739085}

# High-precision arithmetic
wolframscript -wstpserver -code "N[Pi, 50]"
```

### Statistics
```bash
# Mean
wolframscript -wstpserver -code "Mean[{1, 2, 3, 4, 5}]"
# Output: 3

# Standard deviation
wolframscript -wstpserver -code "StandardDeviation[Range[10]]"
```

## Detailed References

For comprehensive documentation on specific topics, see:

- **[calculus.md](references/calculus.md)** — Integration, differentiation, limits, series
- **[algebra.md](references/algebra.md)** — Equation solving, simplification, factoring
- **[linear-algebra.md](references/linear-algebra.md)** — Matrices, eigenvalues, decompositions
- **[statistics.md](references/statistics.md)** — Descriptive stats, distributions, hypothesis testing
- **[numerical.md](references/numerical.md)** — Root finding, optimization, numerical integration
- **[data-manipulation.md](references/data-manipulation.md)** — Lists, tables, strings, import/export
- **[sessions.md](references/sessions.md)** — Session management, state persistence
- **[performance.md](references/performance.md)** — Optimization tips, best practices
- **[advanced.md](references/advanced.md)** — Plotting, parallel computing, script integration

## Best Practices

### When to Use WSTP Server

✅ **Use `-wstpserver` for:**
- Multiple sequential computations
- Interactive workflows
- Scripts with repeated calls

❌ **Skip `-wstpserver` for:**
- Single isolated calculation
- When server not available

### Syntax Notes

- Commands are **case-sensitive** (`Integrate` not `integrate`)
- Use `;` to suppress output: `x = 5;`
- Multiple statements: separate with `;`
- String literals: use double quotes `"text"`
- Comments: `(* comment *)`

## Troubleshooting

### Common Issues

1. **Syntax errors**: Check Wolfram Language syntax (case-sensitive)
2. **Undefined symbols**: Verify function names
3. **Timeout**: Use `-timeout` option for long computations
4. **Server unavailable**: Verify WSTP server running on port 31415

### Check Server Status

```bash
# Verify server is running
ss -tlnp | grep 31415

# Test connection
wolframscript -wstpserver -code "2+2"
```

## Resources

- Official: https://reference.wolfram.com/language/ref/program/wolframscript.html
- Function reference: https://reference.wolfram.com/language/
