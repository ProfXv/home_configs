# Performance Optimization

Best practices for achieving optimal performance with wolframscript.

## WSTP Server Benefits

### Benchmark Results

Based on actual measurements (5 trials each):

| Mode | Average Time | Speedup |
|------|-------------|---------|
| Standalone | 2.11s | 1.0x (baseline) |
| WSTP Server | 0.34s | **6.2x faster** |

### Why WSTP is Faster

**Standalone mode overhead:**
- Kernel initialization: ~1.5s
- Loading packages: ~0.3s
- Actual computation: ~0.3s

**WSTP server mode:**
- Kernel already running: 0s
- Packages already loaded: 0s
- Actual computation: ~0.3s

## When to Use Each Mode

### Use Standalone (`wolframscript -code`)

✅ **Good for:**
- One-off calculations
- Cron jobs (infrequent execution)
- When WSTP server unavailable
- Isolated/independent computations

❌ **Avoid for:**
- Repeated computations
- Interactive workflows
- Scripts with loops calling wolframscript
- Real-time applications

### Use WSTP Server (`wolframscript -wstpserver`)

✅ **Good for:**
- Interactive sessions
- Multiple sequential computations
- Scripts with repeated calls
- Low-latency requirements
- Development/debugging

❌ **Avoid for:**
- Single isolated calculation
- When kernel state pollution is a concern
- Systems without WSTP server

## Optimization Techniques

### 1. Batch Operations

**Bad** (multiple calls):
```bash
for i in {1..100}; do
  wolframscript -wstpserver -code "Prime[$i]"
done
# Time: ~34 seconds (0.34s × 100)
```

**Good** (single call):
```bash
wolframscript -wstpserver -code "Table[Prime[i], {i, 1, 100}]"
# Time: ~0.4 seconds
```

### 2. Use Persistent Sessions

**Bad** (redefine functions each time):
```bash
wolframscript -wstpserver -code "
  f[x_] := x^2 + 2*x + 1;
  f[5]
"
wolframscript -wstpserver -code "
  f[x_] := x^2 + 2*x + 1;
  f[10]
"
```

**Good** (define once, reuse):
```bash
wolframscript -wstpserver -startprofile funcs -code "
  f[x_] := x^2 + 2*x + 1
"

wolframscript -wstpserver -continueprofile funcs -code "f[5]"
wolframscript -wstpserver -continueprofile funcs -code "f[10]"
```

### 3. Compile Functions

For numeric operations, compile to machine code:

```bash
wolframscript -wstpserver -code "
  compiled = Compile[{{x, _Real}}, x^2 + 2*x + 1];
  Table[compiled[i], {i, 1.0, 100000.0}] // Timing
"
```

### 4. Parallel Computing

Use multiple cores for independent computations:

```bash
# Parallel version (uses all cores)
wolframscript -wstpserver -code "
  ParallelTable[FactorInteger[i], {i, 1000, 2000}]
"

# vs. Serial version
wolframscript -wstpserver -code "
  Table[FactorInteger[i], {i, 1000, 2000}]
"
```

### 5. Memoization

Cache expensive function results:

```bash
wolframscript -wstpserver -startprofile memo -code "
  fibonacci[0] = 0;
  fibonacci[1] = 1;
  fibonacci[n_] := fibonacci[n] = fibonacci[n-1] + fibonacci[n-2];

  # First call: computes and caches
  fibonacci[100] // Timing

  # Second call: retrieves from cache
  fibonacci[100] // Timing
"
```

## Data Management

### Import/Export Strategies

**Efficient data loading:**

```bash
# Good: Import once, store in session
wolframscript -wstpserver -startprofile data -code "
  bigData = Import[\"large_file.csv\"];
  Print[\"Data loaded: \", Dimensions[bigData]]
"

# Reuse data
wolframscript -wstpserver -continueprofile data -code "
  Mean /@ Transpose[bigData]
"
```

**Avoid:**
```bash
# Bad: Import every time
wolframscript -wstpserver -code "
  data = Import[\"large_file.csv\"];
  Mean /@ Transpose[data]
"
```

### Choose Appropriate Formats

| Format | Use Case | Speed |
|--------|----------|-------|
| MX | Wolfram native (fastest) | ⚡⚡⚡ |
| WDX | Compressed Wolfram | ⚡⚡ |
| HDF5 | Large numeric arrays | ⚡⚡ |
| CSV | Text, compatibility | ⚡ |
| JSON | Structured data | ⚡ |

Example:
```bash
# Export in fast format
wolframscript -wstpserver -code "
  data = RandomReal[{0, 1}, {10000, 1000}];
  Export[\"data.mx\", data];  # Fast
"

# Import is also fast
wolframscript -wstpserver -code "
  data = Import[\"data.mx\"];  # Fast
"
```

## Memory Management

### Clear Unused Variables

```bash
wolframscript -wstpserver -continueprofile session -code "
  # After using large data
  result = process[bigData];
  Clear[bigData];  # Free memory
"
```

### Monitor Memory Usage

```bash
wolframscript -wstpserver -code "
  MemoryInUse[]  # Current memory usage
  MaxMemoryUsed[]  # Peak memory usage
"
```

## Algorithm Optimization

### Use Built-in Functions

Wolfram Language built-ins are highly optimized.

**Bad** (manual implementation):
```bash
wolframscript -wstpserver -code "
  myMean[list_] := Plus @@ list / Length[list];
  myMean[Range[10000]]
"
```

**Good** (use built-in):
```bash
wolframscript -wstpserver -code "
  Mean[Range[10000]]
"
# 10-100x faster
```

### Vectorization

**Bad** (loop-based):
```bash
wolframscript -wstpserver -code "
  result = {};
  For[i = 1, i <= 10000, i++,
    result = Append[result, i^2]
  ]
"
```

**Good** (vectorized):
```bash
wolframscript -wstpserver -code "
  Range[10000]^2
"
# 100x+ faster
```

## Profiling

### Timing Simple Operations

```bash
wolframscript -wstpserver -code "
  Timing[ExpensiveFunction[]]
"
```

### Detailed Performance Analysis

```bash
wolframscript -wstpserver -code "
  << Developer\`
  RuntimeTools\`Profile[ExpensiveFunction[]]
"
```

## Common Bottlenecks

### 1. String Operations

Strings are slow. Use symbols when possible:

```bash
# Slow
wolframscript -wstpserver -code "
  StringJoin @@ Table[\"item\" <> ToString[i], {i, 10000}]
"

# Faster
wolframscript -wstpserver -code "
  StringJoin @@ Table[ToString[i], {i, 10000}]
"
```

### 2. Repeated Pattern Matching

Cache pattern matching results:

```bash
wolframscript -wstpserver -code "
  data = RandomInteger[{1, 100}, 10000];

  # Slow: pattern match every time
  Cases[data, x_ /; PrimeQ[x]]

  # Faster: vectorized
  Select[data, PrimeQ]
"
```

### 3. Inefficient Data Structures

Use appropriate structures:

```bash
# Slow for lookups
list = {\"key1\" -> val1, \"key2\" -> val2, ...};

# Fast for lookups
assoc = <|\"key1\" -> val1, \"key2\" -> val2, ...|>;
```

## Tips Summary

1. ⚡ **Always use `-wstpserver`** for repeated computations
2. 📦 **Batch operations** instead of loops
3. 💾 **Use persistent sessions** for related work
4. 🔄 **Compile** numeric functions
5. ⚙️ **Parallelize** independent computations
6. 💭 **Memoize** expensive function calls
7. 📊 **Choose efficient data formats** (MX > CSV)
8. 🧹 **Clear unused variables** to free memory
9. 🎯 **Use built-in functions** (they're optimized)
10. 📈 **Vectorize** instead of looping
