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

### Standard Project Directory Structure
```
[project-name]/
├── main                    # Mandatory entry point script
├── shell.nix              # Project dependencies (Nix environment)
├── .envrc                 # Direnv integration
├── CLAUDE.md             # Strategic configuration document
├── README.md             # Current state and progress tracking
└── tests/                # Test directory structure
    ├── automated/        # Automated tests (unit, integration)
    ├── manual/          # Manual interaction tests
    └── hybrid/          # Tests with both automated and manual components
```

### System-Level Directories
- **Configuration Management**: `~/.config/home-manager/` - System-wide configuration managed as code (NixOS home-manager)
- **System Tools**: `~/.config/home-manager/modules/local/bin/` - System tool scripts directory
- **Primary Project Repository**: `~/Desktop/Projects/` - Centralized storage for all project repositories
- **User-Level Cron Jobs**: `~/.cron` - Source file for user-level scheduled tasks

## Document Management (Declarative Configuration)
Each project maintains exactly two declarative documentation files:

1. **CLAUDE.md**: Strategic planning and declarative configuration
   - **Purpose**: Describes what the entire project aims to achieve
   - **Declaration**: The "desired state" - authoritative specification
   - **Update Policy**: Modified only when strategic goals fundamentally change
   - **Authority**: Source of truth for project vision and scope

2. **README.md**: Current state declaration and progress tracking
   - **Purpose**: Tracks actual progress after each development cycle
   - **Declaration**: The "current state" - explicit comparison with CLAUDE.md
   - **Update Requirement**: Must be updated at the END of every development session
   - **Format**: Explicitly show completed, in-progress, and pending items

**Rule**: No additional documentation files should be created unless explicitly required.

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
4. **Centralized Management**: All dependencies declared and managed through `shell.nix`
5. **Regular Review**: Periodically review dependencies to identify and remove unused ones
6. **Justification Required**: Major dependencies require clear justification

### Testing Requirements
1. **Mandatory Testing**: Tests required for all project features
2. **Coverage Standard**: Minimum 80% test coverage for critical functionality
3. **Test Types**:
   - **Automated Tests**: Unit tests and integration tests
   - **Manual Tests**: Scripts requiring human input (stored in `tests/manual/`)
   - **Hybrid Tests**: Automated core logic + manual UI/UX validation
4. **Test Directory Structure**:
   ```
   tests/
   ├── automated/          # Automated tests
   ├── manual/            # Manual interaction tests
   └── hybrid/            # Tests with both automated and manual components
   ```

#### Manual Test Design
**Manual tests are scripts** that run via `main --test` but require human interaction:

**Structure:**
- Present test scenario
- Display expected outcome
- Prompt user for validation
- Record user response for test history
- Provide clear pass/fail criteria

**Interaction Methods:**
- **Choice-based**: "Does the button look correct? [y/n/q]"
- **Score-based**: "Rate UI clarity from 1-10: ___"
- **Input-based**: "Enter the text you see: ___"

**Test Data Collection:**
- Log to `tests/manual_results.log`
- Format: `TIMESTAMP | Test Name | Result | User Rating`

**Example Manual Test Script:**
```bash
#!/usr/bin/env bash
# tests/manual/test_ui_clarity.sh

echo "=== Testing UI Clarity at 4K Resolution ==="
echo "Expected: All text should be sharp, buttons clearly visible"
echo ""
echo "Please manually verify the login screen at 4K resolution"
echo ""
read -p "Is the text sharp and readable? (y/n/q): " response
case $response in
    y) echo "PASS: UI clarity test" >> /tmp/manual_results.log ;;
    n) echo "FAIL: UI clarity test" >> /tmp/manual_results.log ;;
    q) echo "SKIP: UI clarity test" >> /tmp/manual_results.log ;;
esac
```

## System Tools Usage Guide

### Database Log System Overview
The system includes a continuously running database log system (`~/.log.db`) that automatically records various interaction data while the machine is powered on, including voice recordings, intent recognition, physiological data, and focus changes. Use the `get_intent.sh` script to query these records: without parameters returns total record count, `-t` for time-based search, `-s` for text search, `-n` to limit number of results, `--start/--end` for time range filtering.

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

### 3. Managing User-Level Scheduled Tasks
Standard workflow:
1. Edit source file at `/home/paradoxist/.cron`
2. Execute `crontab /home/paradoxist/.cron`

### 4. Checking Current Situation
Read `/tmp/snapshot_picture.png` for screenshot information.

# Operational Procedures

## Core Development Workflow

```
PROCESS DeveloperWorkflow:
  WHILE developing DO:
    TRY execute command
    IF command_not_found THEN
      missing_package ← identify_missing_package(command)
      EDIT shell.nix: ADD pkgs.missing_package TO myPackages list
      SAVE shell.nix
      environment ← reload_environment()
      ASSERT environment.contains(missing_package)
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

This pattern reduces complex package management to **text editing**, truly achieving "environment-as-code".

## Implementation Guidelines

```
PROCESS LanguageSelection:
  default_approach ← "Prioritize most concise suitable language"
  native_development ← "Default to native x86_64 optimization"
  performance_first ← "Evaluate Rust for critical performance projects"
  RETURN {default_approach, native_development, performance_first}
ENDPROCESS

PROCESS CodeImplementation:
  RULE minimal_prototype_first
  RULE no_feature_bloat
  RULE simplicity_over_complexity
  RULE native_optimization
  RULE reproducible_builds
  RULE no_code_comments
ENDPROCESS

PROCESS RequirementDiscovery:
  // Question format priority
  question_flow ← [
    "Yes/No questions first",
    "Multiple choice questions second",
    "Limited options questions third",
    "Open-ended questions last (only after options exhausted)"
  ]
  goal ← "Transform vague ideas into clear, actionable requirements"
  RETURN {question_flow, goal}
ENDPROCESS

PROCESS ScriptWriting:
  PRINCIPLE simplicity_first
  PRINCIPLE intent_driven
  TECHNIQUE use_short_circuit_over_if_then_fi
  TECHNIQUE one_logic_per_line
  TECHNIQUE remove_unnecessary_output
ENDPROCESS

PROCESS KeyPrinciples:
  PRINCIPLE ask_clarifying_questions_before_over_engineering
  PRINCIPLE prefer_standard_library_over_dependencies
  PRINCIPLE document_trade_offs
  PRINCIPLE ensure_nix_build_compatibility
ENDPROCESS
```

## Test-Driven Development Process

```
PROCESS TDD_Cycle(feature):
  REPEAT UNTIL feature_complete:
    // Phase 1: Red - Write failing test
    test_case ← CREATE_TEST(feature.requirements)
    RUN test_case
    ASSERT test_case.fails()

    // Phase 2: Green - Minimal implementation
    implementation ← MINIMAL_CODE(test_case)
    RUN test_case
    ASSERT test_case.passes()

    // Phase 3: Refactor - Improve without changing behavior
    REPEAT UNTIL code_quality_acceptable:
      optimized_code ← REFACTOR(implementation)
      RUN test_case
      ASSERT test_case.passes()
    ENDREPEAT

    feature_complete ← EVALUATE(feature, implementation)
  ENDREPEAT
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
6. **Test Integration**: Support `main --test` and `main --test <path>`
7. **Default Run**: Run without parameters executes primary functionality

**Note**: Use `#!/usr/bin/env <interpreter>` shebang, never hardcode interpreter paths.

#### Implementation Pattern:
```bash
#!/usr/bin/env bash
# Project Summary: Brief description of the project
#
# Usage:
#   main [options]
#
# Options:
#   -h, --help              Show this help message
#   [additional project-specific options...]
#
# Examples:
#   main                 Run the primary functionality (no parameters required)
#   main --run-tests
#   main --build
#
# For more details, run: main --help
```

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
