# Environment Overview

## System Information
**Environment**: NixOS 25.11pre888552.b3d51a0365f6 (Xantusia) x86_64
**Host**: Khadas Mind-K1014-PCB
**Kernel**: 6.176-zen1
**CPU**: 13th Gen Intel i7-1360P (16) @ 5.000GHz
**GPU**: Intel Raptor Lake-P [Iris Xe Graphics]
**Memory**: 31837MiB
**Desktop**: Hyprland (Wayland)
**Shell**: zsh 5.9
**Terminal**: claude

## Project Structure

### Standard Project Layout
Every project maintains this consistent structure:
```
[project-name]/
├── main
│   Unified entry point script (requires --help documentation, default run without parameters)
├── flake.nix
│   Primary Nix Flakes build system with automatic language detection
├── shell.nix
│   System-level dependencies (optional, for tools not in language packages)
├── .envrc
│   Direnv integration (auto-activates environment on directory entry)
├── CLAUDE.md
│   Strategic configuration document (desired state declaration, updated only for fundamental changes)
└── README.md
    Current state and progress tracking (explicit comparison to CLAUDE.md, updated every session)
```

### System-Level Directories
```
~/.config/home-manager/         System-wide configuration managed as code (NixOS home-manager)
~/.cron                         User-level scheduled tasks source file (apply with crontab)
~/Desktop/Projects/             Primary project repository directory (centralized storage)
```

## Development Environment Philosophy

### Sandbox Exploration Principle
1. **Safe to Experiment**: Operate within a completely safe sandbox environment
2. **Free to Explore**: Explore different approaches, technologies, and solutions
3. **No Risk Environment**: Experiments performed without fear of breaking production
4. **Encouraged Iteration**: Multiple iterations and refinements welcomed
5. **Creative Freedom**: Discover optimal solutions through experimentation
6. **Documentation of Discoveries**: Document interesting findings and alternatives
7. **Project Isolation**: Development occurs in sandbox environments with access limited to current directory and subdirectories

## Development Constraints

### Dependency Minimization Principle
1. **Limit Dependencies**: Restrict to only absolutely necessary packages
2. **Standard Library First**: Prefer standard libraries over external dependencies
3. **Critical Evaluation**: Every new dependency critically evaluated for necessity
4. **Centralized Management**: All dependencies declared and managed through appropriate project files
5. **Regular Review**: Periodically review dependencies to identify and remove unused ones
6. **Justification Required**: Major dependencies require clear justification

### Testing Requirements
1. **Native Frameworks Only**: Use each language's built-in test framework, never custom test scripts
   - Rust: `cargo test` (unit tests in `#[cfg(test)]` modules, integration tests in `tests/`)
   - Python: `pytest` (auto-discovers `test_*.py` files)
   - Node.js: `npm test` (configured in `package.json`)
   - Go: `go test ./...` (discovers `*_test.go` files)
   - Nix: `nix-instantiate --parse` for syntax validation
2. **Unit Tests**: Test individual functions in source files, co-located with implementation
3. **Integration Tests**: Test module interactions, placed in language-standard locations
4. **Property-Based Testing**: Prefer testing mathematical invariants over specific values
5. **Session End Auto-Test**: Stop hook automatically runs native tests and commits only if all pass

## System Tools Usage Guide

### Database Log System Overview
A continuously running database log system (`~/.log.db`) automatically records interaction data while powered on: voice recordings, intent recognition, physiological data, and focus changes. Use the `get_intent.sh` script to query these records: without parameters returns total record count, `-t` for time-based search, `-s` for text search, `-n` to limit number of results, `--start/--end` for time range filtering.

### System Tools Directory
- **Script directory**: `/home/paradoxist/.config/home-manager/modules/local/bin/`

### 1. Setting Reminders
Use `execute_tool.sh set_reminder <reminder_time> <reminder_content>`

**Examples:**
- `execute_tool.sh set_reminder "now + 5 minutes" "Drink water"`
- `execute_tool.sh set_reminder "3:00 PM tomorrow" "Meeting"`

### 2. Performing Desktop Operations
Use `execute_tool.sh desktop_operation [<operation_number>]`

**Instructions:**
- No number: display operation list
- With number: execute corresponding operation

**Output example:**
```
0	"open terminal"
1	"open editor"
2	"open file manager"
...
```

### 3. Checking Current Situation
Read `/tmp/snapshot_picture.png` for screenshot information.

# Operational Procedures

```
PROCESS DevelopmentDecision(requirement):
  IF IS_TEMPORARY_REQUIREMENT(requirement) THEN
    CALL TemporaryRequirementHandling(requirement)
  ELSE
    CALL CoreDevelopmentWorkflow(requirement)
  ENDIF
ENDPROCESS

FUNCTION IS_TEMPORARY_REQUIREMENT(requirement):
  criteria ← [
    "Appears one-time only (not recurring)",
    "Can be expressed as single command (with possible pipelines)",
    "No file creation or modification required",
    "Leverages existing system tools rather than new logic",
    "No persistent state or configuration needed"
  ]
  score ← EVALUATE_CRITERIA(requirement, criteria)
  THRESHOLD ← 3
  RETURN score > THRESHOLD
ENDFUNCTION
```

## Temporary Requirement Handling

```
PROCESS TemporaryRequirementHandling(requirement):
  command ← FORMULATE_COMPLETE_COMMAND(requirement)
  result ← EXECUTE(command)
  output ← GET_OUTPUT(result)

  IF output.matches_expectation THEN
    RETURN output
  ELSE
    simplified_command ← command
    WHILE HAS_PIPES(simplified_command) AND NOT HAS_CLUE(output) DO
      simplified_command ← REMOVE_LAST_PIPE(simplified_command)
      result ← EXECUTE(simplified_command)
      output ← GET_OUTPUT(result)
    ENDWHILE

    IF HAS_CLUE(output) THEN
      adjusted_command ← ADJUST_BY_CLUE(simplified_command, output)
      RETURN EXECUTE(adjusted_command)
    ELSE
      RETURN INITIATE_FULL_DEVELOPMENT(requirement)
    ENDIF
  ENDIF
ENDPROCESS
```

**When to Use:**
- Requirements appear one-time only
- Solution can be expressed as single command (even with complex pipelines)
- No persistent file modifications needed
- Leverages existing tools rather than new logic

## Core Development Workflow

```
PROCESS CoreDevelopmentWorkflow(requirement):
  WHILE developing DO:
    TRY execute command
    IF command_not_found THEN
      missing_pkg ← FIND_MISSING_PKG(command)
      # Edit appropriate dependency file based on project type, for example:
      # - shell.nix for system tools and C-family language libraries
      # - package.json for Node.js dependencies
      # - pyproject.toml for Python dependencies
      # - Cargo.toml for Rust dependencies
      # (These are examples - edit the appropriate file for your project's language)
      EDIT appropriate_dependency_file: ADD missing_pkg
      SAVE file
      env ← AUTO_REBUILD()
      ASSERT env.contains(missing_pkg)
      CONTINUE development
    ENDIF
  ENDWHILE
ENDPROCESS
```

**Real-World Example:**
```bash
# 1. Discover missing screenfetch command
$ screenfetch
zsh: command not found: screenfetch

# 2. Edit shell.nix, add one line:
#    pkgs.screenfetch

# 3. After environment auto-reloads:
$ screenfetch
[Successfully displays system information]
```

**For language-specific dependencies**, the same pattern applies:
- Edit `package.json` for Node.js packages
- Edit `pyproject.toml` for Python packages
- Edit `Cargo.toml` for Rust packages
Editing dependency files triggers automatic rebuild with the new dependencies.

This pattern reduces complex package management to **text editing**, truly achieving "environment-as-code".

## Implementation Guidelines

```
PROCESS LanguageSelection:
  default ← "Prioritize concise suitable language"
  native_dev ← "Default to native x86_64 optimization"
  perf_first ← "Evaluate Rust for critical performance projects"
  RETURN {default, native_dev, perf_first}
ENDPROCESS

PROCESS CodeImplementation:
  RULE minimal_first
  RULE no_bloat
  RULE simplicity_first
  RULE native_opt
  RULE reproducible
  RULE no_comments
ENDPROCESS

PROCESS RequirementDiscovery:
  q_flow ← [
    "Yes/No first",
    "Multiple choice second",
    "Limited options third",
    "Open-ended last (only after options exhausted)"
  ]
  goal ← "Transform vague ideas into clear requirements"
  RETURN {q_flow, goal}
ENDPROCESS

PROCESS ScriptWriting:
  PRINCIPLE simplicity_first
  PRINCIPLE intent_driven

  TECHNIQUE short_circuit_over_if
  TECHNIQUE one_line_logic
  TECHNIQUE remove_unnecessary
ENDPROCESS

PROCESS KeyPrinciples:
  PRINCIPLE ask_clarifying_questions
  PRINCIPLE prefer_stdlib
  PRINCIPLE document_tradeoffs
  PRINCIPLE ensure_nix_compatibility
ENDPROCESS
```

## Testing Strategy

### Automatic Testing and Commit
When a session ends, the system automatically:
1. Detects project type by config files (Cargo.toml → Rust, package.json → Node.js, pyproject.toml → Python)
2. Runs the native test command (`cargo test` / `npm test` / `pytest`)
3. If all tests pass → auto-commits all changes
4. If any test fails → reports errors, does NOT commit

**You do not need to run tests manually or commit manually.** Just write tests in the correct locations and the system handles the rest.

### Write Tests Using Native Frameworks
Place tests where the language expects them — the framework discovers them automatically:
- **Rust**: `#[cfg(test)] mod tests` in source files (unit), `tests/*.rs` at crate root (integration)
- **Python**: `test_*.py` files discovered by pytest
- **Node.js**: test script defined in `package.json`, framework discovers test files
- **Go**: `*_test.go` alongside source files

### Test-Driven Development
```
PROCESS TDD_Cycle(feature):
  test_case ← CREATE_TEST(feature.requirements)  # Use native framework
  RUN native_test_command                         # cargo test / pytest / npm test
  ASSERT test_case.fails()

  implementation ← MINIMAL_CODE(test_case)
  RUN native_test_command
  ASSERT test_case.passes()

  REFACTOR(implementation)
  RUN native_test_command
  ASSERT test_case.passes()
ENDPROCESS
```

## Development Cycle Definition

```
PROCESS DevelopmentSession:
  desired_state ← READ(CLAUDE.md)
  current_state ← READ(README.md)
  gap ← CALCULATE_GAP(desired_state, current_state)

  WHILE session_active AND gap > 0 DO:
    work_result ← EXECUTE_WORK(gap.priority_item)
    gap ← UPDATE_GAP(gap, work_result)
  ENDWHILE

  new_current_state ← GENERATE_STATE(work_results)
  WRITE(README.md, new_current_state)
  ASSERT STATE_MATCHES_WORK(new_current_state, work_results)

  session_complete ← VERIFY_COMPLETION(new_current_state)
  RETURN session_complete
ENDPROCESS
```

## Test Correctness Assurance

### 1. Red Phase Validation
**Critical Rule**: A test MUST fail before implementation
- Write test first
- Run test to confirm failure
- If test passes before implementation, test is incorrect

### 2. Positive and Negative Examples
Test both successful and failing cases:
```python
def test_login():
    result = login("alice", "correctpass")
    assert result.is_success == True

    result = login("alice", "wrongpass")
    assert result.is_success == False

    result = login("", "")
    assert result.is_success == False
```

### 3. Property-Based Testing
Use properties instead of specific values:
```python
# Instead of: assert add(2, 3) == 5
# Use: For any a, b, add(a, b) must equal add(b, a)
```

### 4. Independent Tests
- No dependency on other tests' execution order
- Each test sets up its own data
- Tests run in any order or parallel

### 5. Proven Test Frameworks
- Python: pytest
- Go: go test
- Rust: cargo test
- Never write custom testing infrastructure

### 6. Code Review for Tests
- Review test logic
- Validate expected outcomes
- Check for edge cases
- Confirm property assumptions

## Mandatory Main Entry Point
Each project MUST have a `main` script as unified entry point:

1. **Unified Interface**: Use `main` as primary interface
2. **Help Documentation**: `main --help` displays complete usage documentation
3. **Self-Documenting**: Script contains all usage instructions in English
4. **No Additional Docs**: No separate documentation files by default
5. **Flexible Parameters**: Project-specific parameters and flags allowed
6. **Default Run**: Run without parameters executes primary functionality

**Note**: Use `#!/usr/bin/env <interpreter>` shebang, never hardcode interpreter paths.

# Ad-hoc Requirements and Notes

- 我需要记住三个生物化学反应数据库网站：
  1. KEGG PATHWAY: https://www.genome.jp/kegg/pathway.html
  2. Reactome: https://reactome.org/
  3. BioCyc: https://biocyc.org/

- 灵感：文件管理 - 探索双曲（hyperbolic）文件浏览器。
- 灵感：浏览器定制 - 尝试使用Common Lisp定制Nyxt浏览器。
- 灵感：系统能力测试 - 卸载字体包并用此示例测试动态修改系统能力。

- 今天解了一个"鸡鸡毛结"。
- 用户自己养了猫。
- 需要测试窗口状态的时候，请直接打开窗口，然后用窗口管理器的接口去检查。
- 查找待办事项：下次找待办事项请到 /home/paradoxist/README.md 文件中查找。
- 系统重建命令：在用户系统上，重建NixOS系统的一字不差的命令是 `sudo rebuild_nixos.sh`（而不是通常的 `nixos-rebuild switch`）。这个自定义脚本会将home-manager配置复制到 `/etc/nixos/` 然后执行系统重建。
