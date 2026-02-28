# Session Management

Complete guide to managing persistent sessions with wolframscript.

## Overview

Persistent sessions allow you to:
- Maintain variable state across multiple invocations
- Build up complex computations incrementally
- Share data between different scripts
- Avoid re-initialization overhead

## Basic Session Workflow

### Start a New Session

```bash
# Initialize session with variables
wolframscript -wstpserver -startprofile my_session -code "
  x = 42;
  y = x^2;
  data = Range[100];
  Print[\"Session initialized\"]
"
```

### Continue Existing Session

```bash
# Access previously defined variables
wolframscript -wstpserver -continueprofile my_session -code "x + y"
# Output: 1806

# Add new variables
wolframscript -wstpserver -continueprofile my_session -code "z = Sqrt[y]"
# Output: 42
```

### Check Session State

```bash
# List all variables
wolframscript -wstpserver -continueprofile my_session -code "Names[\"Global`*\"]"

# Check specific variable
wolframscript -wstpserver -continueprofile my_session -code "?x"
```

## Session Use Cases

### Incremental Data Analysis

```bash
# Session 1: Load data
wolframscript -wstpserver -startprofile analysis -code "
  data = Import[\"data.csv\"];
  Print[\"Loaded \", Length[data], \" rows\"]
"

# Session 2: Clean data
wolframscript -wstpserver -continueprofile analysis -code "
  cleaned = DeleteCases[data, {_, _Missing}];
  Print[\"Cleaned to \", Length[cleaned], \" rows\"]
"

# Session 3: Analyze
wolframscript -wstpserver -continueprofile analysis -code "
  mean = Mean[cleaned[[All, 2]]];
  stddev = StandardDeviation[cleaned[[All, 2]]];
  {mean, stddev}
"
```

### Interactive Exploration

```bash
# Start with function definitions
wolframscript -wstpserver -startprofile explore -code "
  fibonacci[n_] := If[n <= 1, n, fibonacci[n-1] + fibonacci[n-2]];
  isPrime[n_] := PrimeQ[n];
"

# Use functions
wolframscript -wstpserver -continueprofile explore -code "Table[fibonacci[i], {i, 1, 10}]"
# Output: {1, 1, 2, 3, 5, 8, 13, 21, 34, 55}

# Continue exploration
wolframscript -wstpserver -continueprofile explore -code "Select[Range[100], isPrime]"
```

### Building Complex Computations

```bash
# Define matrix
wolframscript -wstpserver -startprofile matrix -code "
  A = {{1, 2}, {3, 4}};
  B = {{5, 6}, {7, 8}};
"

# Compute products
wolframscript -wstpserver -continueprofile matrix -code "C = A.B"
# Output: {{19, 22}, {43, 50}}

# Eigenvalue analysis
wolframscript -wstpserver -continueprofile matrix -code "
  eigA = Eigenvalues[A];
  eigC = Eigenvalues[C];
  {eigA, eigC}
"
```

## Session Management

### List Active Sessions

Unfortunately, wolframscript doesn't provide a built-in command to list sessions.
You must track session names manually.

### Session Naming Conventions

Use descriptive names that indicate purpose:

```bash
# Good names
data_analysis_2024
matrix_experiment_1
optimization_run

# Avoid generic names
session1
temp
test
```

### Session Isolation

Each session is completely independent:

```bash
# Session A
wolframscript -wstpserver -startprofile sessionA -code "x = 10"

# Session B (x is undefined here)
wolframscript -wstpserver -startprofile sessionB -code "x = 20"

# Back to Session A (x is still 10)
wolframscript -wstpserver -continueprofile sessionA -code "x"
# Output: 10
```

## Session Lifecycle

### Session Duration

Sessions persist:
- Until kernel is restarted
- Until WSTP server is restarted
- Until system reboot

Sessions do NOT persist:
- Across system reboots
- When WSTP server restarts

### Clean Up Sessions

Clear all variables in a session:

```bash
wolframscript -wstpserver -continueprofile my_session -code "Clear[\"Global`*\"]"
```

Remove specific variables:

```bash
wolframscript -wstpserver -continueprofile my_session -code "Clear[x, y, z]"
```

## Advanced Patterns

### Session-Based Scripts

Create a script that uses sessions:

```bash
#!/usr/bin/env bash
# analysis.sh

SESSION="data_analysis_$(date +%Y%m%d)"

# Initialize
wolframscript -wstpserver -startprofile "$SESSION" -code "
  data = Import[\"$1\"];
  Print[\"Loaded data\"]
"

# Process
wolframscript -wstpserver -continueprofile "$SESSION" -code "
  result = Mean /@ Transpose[data];
  Export[\"result.csv\", result]
"
```

### Sharing Data Between Scripts

Script 1 (producer.sh):
```bash
#!/usr/bin/env bash
wolframscript -wstpserver -startprofile shared -code "
  results = Table[Prime[i], {i, 1, 1000}];
  Print[\"Generated \", Length[results], \" primes\"]
"
```

Script 2 (consumer.sh):
```bash
#!/usr/bin/env bash
wolframscript -wstpserver -continueprofile shared -code "
  stats = {Min[results], Max[results], Mean[results]};
  Print[stats]
"
```

### Checkpointing Long Computations

```bash
# Start computation
wolframscript -wstpserver -startprofile longrun -code "
  results = {};
  For[i = 1, i <= 100, i++,
    results = Append[results, ExpensiveComputation[i]];
    If[Mod[i, 10] == 0, Print[\"Progress: \", i, \"%\"]]
  ]
"

# If interrupted, resume from last state
wolframscript -wstpserver -continueprofile longrun -code "
  Print[\"Resuming from: \", Length[results], \" items\"]
  (* Continue from where you left off *)
"
```

## Troubleshooting

### Session Not Found

If you get "session not found" error:
1. Check session name spelling
2. Verify WSTP server is running
3. Ensure you used `-startprofile` first

### Variable Undefined

If a variable is unexpectedly undefined:
1. Check session name (wrong session?)
2. Verify variable was actually set (check for errors)
3. Check if session was cleared

### Session Conflicts

If multiple users/processes use same session name:
- Use unique prefixes: `user1_analysis`, `user2_analysis`
- Include timestamps: `analysis_20240217_1430`
- Use process IDs: `session_$$` (in bash scripts)

## Best Practices

1. **Use meaningful names**: `matrix_optimization` not `session1`
2. **Clean up**: Clear sessions when done
3. **Document state**: Add comments showing what variables exist
4. **Handle errors**: Check for undefined variables before use
5. **Avoid side effects**: Don't modify global state unintentionally
6. **Session per task**: Don't reuse sessions for unrelated work
7. **Save important results**: Export to files, don't rely on sessions forever
