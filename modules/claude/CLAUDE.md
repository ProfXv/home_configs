# Development Environment and Best Practices


## Development Environment Configuration

### System Information
**Environment**: NixOS 25.11pre888552.b3d51a0365f6 (Xantusia) x86_64
**Host**: Khadas Mind-K1014-PCB
**Kernel**: 6.176-zen1
**CPU**: 13th Gen Intel i7-1360P (16) @ 5.000GHz
**GPU**: Intel Raptor Lake-P [Iris Xe Graphics]
**Memory**: 31837MiB
**Desktop**: Hyprland (Wayland)
**Shell**: zsh 5.9
**Terminal**: claude

### Mandatory Requirements
1. **Environment Isolation**: Maintain strict project isolation through Nix environments
2. **Dependency Management**: Centralize all dependencies in `shell.nix` for reproducibility
3. **No Global Dependencies**: Avoid global installations; all dependencies must be project-contained

### Core Workflow
**Core Philosophy**: Developers focus on business logic, environment follows automatically.

**Three-Step Workflow (Pseudocode)**:
```
PROCESS DeveloperWorkflow:
  // Runtime environment automatically manages dependencies

  WHILE developing DO:
    // Step 1: Discovery - Runtime reveals missing dependency
    TRY execute command
    IF command_not_found THEN
      missing_package ← identify_missing_package(command)

      // Step 2: Declaration - Edit shell.nix
      EDIT shell.nix:
        ADD pkgs.missing_package TO myPackages list
      SAVE shell.nix

      // Step 3: Automatic Activation - Environment reloads
      environment ← reload_environment()
      ASSERT environment.contains(missing_package)

      CONTINUE development
    ENDIF
  ENDWHILE
ENDPROCESS
```

**Key Advantages**:
- **Zero-Command Operation**: No `install`, `update`, or `remove` commands needed
- **Immediate Feedback**: Edit → Save → Test immediately
- **Environment-as-Code**: Dependency declarations stay perfectly synchronized with actual environment
- **Full Reproducibility**: Any developer, any machine gets identical environment

**Real-World Example**:
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

### Implementation Guidelines
**Language Selection**
- **Default Approach**: Prioritize the most concise and suitable programming language for the task
- **Native Development**: Default to developing native software optimized for this machine's architecture (x86_64)
- **Consider**: Performance requirements, development speed, and maintenance cost
- **Performance-First Projects**: For new projects where performance is critical, prioritize Rust language; however, first evaluate the maturity of the project ecosystem and development speed requirements

**Code Implementation Rules**
1. **Minimal Prototype First**: Always implement the smallest possible viable prototype
2. **No Feature Bloat**: Absolutely do not add any features that were not explicitly requested
3. **Simplicity Over Complexity**: Choose the simplest implementation that meets the requirements
4. **Native Optimization**: Leverage the native environment (NixOS + Intel/AMD x86_64) for optimal performance
5. **Reproducible Builds**: Use Nix for build processes to ensure reproducibility
6. **Requirement Discovery Through Questioning**: When starting a project without existing documentation and requirements are unclear, **always prioritize multiple-choice questions and yes/no questions** before asking open-ended questions. This approach accelerates requirement gathering and reduces ambiguity:
7. **No Code Comments**: Do not add any code comments. Code comments should only be inserted in dedicated places to indicate where future functionality can be added
   - **Question Format Priority**:
     1. **Yes/No Questions** (e.g., "Does it need to be web-based? [y/n]")
     2. **Multiple Choice Questions** (e.g., "Which option best describes your preference? A) CLI tool B) Web app C) Desktop app")
     3. **Limited Options Questions** (e.g., "Pick the top 3 priorities from: [A] Speed [B] Ease of use [C] Features [D] Cost")
     4. **Open-ended Questions** (only after options are exhausted)
   - **Example Question Flow**: "Is this for personal use or business? → If business, is it for: A) Internal team B) External clients C) Public use → ..."
   - **Goal**: Quickly narrow down to 2-3 clear directions before deep-diving into details
   The goal is to transform vague ideas into clear, actionable requirements through iterative questioning, then document the agreed-upon scope in CLAUDE.md and track progress in README.md.

**Script Writing Principles**
**Core**: Simplicity first, intent-driven.
- Use short-circuit expressions (`&&`) over `if-then-fi`
- One logic per line, no deep nesting
- Remove all unnecessary comments and output

**Key Principles**
- Ask clarifying questions before over-engineering
- Prefer standard library solutions over heavy dependencies
- Document trade-offs when choosing between multiple valid approaches
- Ensure all code can be built and run in the Nix environment defined by `shell.nix`

## Project and File Structure

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

### Document Management (Declarative Configuration)
Each project maintains exactly two declarative documentation files, akin to operating system configuration files:

1. **CLAUDE.md**: Strategic planning and declarative configuration for the entire project
   - **Purpose**: Describes what the entire project aims to achieve and its high-level goals
   - **Declaration**: This is the "desired state" - the authoritative specification of project objectives
   - **Update Policy**: Modified only when strategic goals or architecture fundamentally change (by designated developers only)
   - **Authority**: Source of truth for project vision and scope

2. **README.md**: Current state declaration and progress tracking document
   - **Purpose**: Tracks actual progress after each development cycle compared to the strategic plan
   - **Declaration**: This is the "current state" - a explicit comparison with CLAUDE.md declarations
   - **Update Requirement**: Must be updated at the END of every development session
   - **Comparison Mandate**: MUST clearly compare current progress against the strategic goals in CLAUDE.md
   - **Format**: Explicitly show what has been completed, what's in progress, and what's pending

**Development Cycle Definition (Pseudocode)**:
```
PROCESS DevelopmentSession:
  // Iterative cycle for working on projects

  // Phase 1: Session Start - Assess current state
  desired_state ← READ(CLAUDE.md)
  current_state ← READ(README.md)
  gap ← CALCULATE_GAP(desired_state, current_state)

  // Phase 2: During Development - Close the gap
  WHILE session_active AND gap > 0 DO:
    work_result ← EXECUTE_WORK(gap.priority_item)
    gap ← UPDATE_GAP(gap, work_result)
  ENDWHILE

  // Phase 3: Session End - Update documentation
  new_current_state ← GENERATE_STATE(work_results)
  WRITE(README.md, new_current_state)
  ASSERT STATE_MATCHES_WORK(new_current_state, work_results)

  // Completion check
  session_complete ← VERIFY_COMPLETION(new_current_state)
  RETURN session_complete
ENDPROCESS
```

**Document Update Triggers**:
- **CLAUDE.md**: Updated when project scope, goals, or architecture fundamentally change (strategic changes only, by designated developers)
- **README.md**: Updated at the END of every development session to declare actual progress

**Declaration Principles**:
- **Clarity**: Both documents should be declarative statements, not procedural instructions
- **Contrast**: README.md must explicitly show the delta - what changed, what's been added, what's been removed
- **Alignment**: README.md progress should always be traceable back to specific goals in CLAUDE.md
- **Immutability**: Once declared in CLAUDE.md, strategic goals remain until formally updated

**Rule**: No additional documentation files should be created unless explicitly required.

## Development Constraints and Best Practices

### Development Environment Philosophy

#### Sandbox Exploration Principle
1. **Safe to Experiment**: You operate within a completely safe sandbox environment
2. **Free to Explore**: Feel free to explore different approaches, technologies, and solutions
3. **No Risk Environment**: All experiments and trials can be performed without fear of breaking production systems
4. **Encouraged Iteration**: Multiple iterations and refinements are welcomed and expected
5. **Creative Freedom**: Leverage this safety to discover optimal solutions through experimentation
6. **Documentation of Discoveries**: Document interesting findings and alternatives discovered during exploration
7. **Project Isolation**: All project development occurs in sandbox environments with access limited to the current working directory and its subdirectories, but with complete read/write/execute permissions for all content within the current directory

### Dependency Minimization Principle
1. **Limit Dependencies**: Restrict project dependencies to only absolutely necessary packages
2. **Standard Library First**: Prefer using standard libraries over external dependencies
3. **Critical Evaluation**: Every new dependency must be critically evaluated for necessity
4. **Centralized Management**: All dependencies must be declared and managed through `shell.nix`
5. **Regular Review**: Periodically review dependencies to identify and remove unused ones
6. **Justification Required**: Major dependencies should have clear justification documented in development notes

### Testing Requirements
1. **Mandatory Testing**: Tests are required for all project features
2. **Coverage Standard**: Maintain minimum 80% test coverage for critical functionality
3. **Test Types**:
   - **Automated Tests**: Unit tests and integration tests that run without human intervention
   - **Manual Tests**: Scripts that require human input/interaction (stored in `tests/manual/`)
   - **Hybrid Tests**: Automated core logic + manual UI/UX validation via interactive prompts
4. **Test Directory Structure**:
   ```
   tests/
   ├── automated/          # Automated tests (unit, integration)
   ├── manual/            # Manual interaction tests
   └── hybrid/            # Tests with both automated and manual components
   ```

#### Manual Test Design
**Manual tests are also scripts** that run via `main --test` but require human interaction:

**Structure:**
- Script presents test scenario (e.g., "Test login UI at 4K resolution")
- Displays expected outcome
- Prompts user for validation via interactive choice or input
- Records user response for test history
- Provides clear pass/fail criteria

**Interaction Methods:**
- **Choice-based**: "Does the button look correct? [y/n/q]" (y=pass, n=fail, q=skip)
- **Score-based**: "Rate UI clarity from 1-10: ___"
- **Input-based**: "Enter the text you see: ___"

**Test Data Collection:**
- User responses should be logged to `tests/manual_results.log`
- Format: `TIMESTAMP | Test Name | Result | User Rating (if applicable)`
- Results integrated into overall test summary report

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
5. **Test Execution**:
   - Run all tests: `main --test` (includes both automated and manual tests)
   - Run tests in specific directory: `main --test tests/path/to/tests/`
   - Manual tests will pause for user interaction, automated tests run silently
   - Results from all tests consolidated into unified report
6. **Test Report**:
   - Each test reports its individual result
   - Summary shows overall success rate and failure count
   - Test history tracks pass/fail status for regression detection
   - Manual test results included in summary (pass/fail/skip counts)
7. **Pre-commit Testing**: All tests must pass before considering a development session complete
8. **Test Documentation**: Test cases should clearly demonstrate expected behavior
9. **Test Automation**: Both automated and manual tests are executed as part of the development workflow

### Test-Driven Development (TDD) Process
**Follow the Red-Green-Refactor cycle (Pseudocode)**:

```
PROCESS TDD_Cycle(feature):
  // Iterative development with test-first approach

  REPEAT UNTIL feature_complete:
    // Phase 1: Red - Write failing test
    test_case ← CREATE_TEST(feature.requirements)
    RUN test_case
    ASSERT test_case.fails()  // Must fail before implementation

    // Phase 2: Green - Minimal implementation
    implementation ← MINIMAL_CODE(test_case)
    RUN test_case
    ASSERT test_case.passes()  // Test must now pass

    // Phase 3: Refactor - Improve without changing behavior
    REPEAT UNTIL code_quality_acceptable:
      optimized_code ← REFACTOR(implementation)
      RUN test_case
      ASSERT test_case.passes()  // Safety net
    ENDREPEAT

    feature_complete ← EVALUATE(feature, implementation)
  ENDREPEAT
ENDPROCESS
```

**Loop**: Repeat for each feature or functionality

**Benefits**:
- Ensures all code has tests
- Prevents regressions
- Creates clear documentation of expected behavior
- Enables confident refactoring

### Test Correctness Assurance
**How to ensure tests themselves are correct:**

#### 1. Red Phase Validation
**Critical Rule**: A test MUST fail before implementation
- Write test first
- Run test to confirm it fails (Red)
- If test passes before implementation, the test is incorrect
- This is your first validation that test logic is sound

#### 2. Positive and Negative Examples
**Test both successful and failing cases:**
```python
def test_login():
    # Positive: correct credentials should succeed
    result = login("alice", "correctpass")
    assert result.is_success == True

    # Negative: wrong password should fail
    result = login("alice", "wrongpass")
    assert result.is_success == False

    # Negative: empty credentials should fail
    result = login("", "")
    assert result.is_success == False
```

**Why**: If test logic is wrong, it's unlikely to handle both positive and negative cases correctly.

#### 3. Property-Based Testing
**Use properties instead of specific values when applicable:**
```python
# Instead of: assert add(2, 3) == 5
# Use: For any a, b, add(a, b) must equal add(b, a)
```

#### 4. Independent Tests
**Each test must be independent and self-contained**:
- No dependency on other tests' execution order
- Each test sets up its own data
- Tests can run in any order or parallel

#### 5. Proven Test Frameworks
**Use mature, established testing frameworks**:
- Python: pytest
- Go: go test
- Rust: cargo test
- Never write custom testing infrastructure

#### 6. Code Review for Tests
**Tests require the same scrutiny as production code**:
- Review test logic
- Validate expected outcomes
- Check for edge cases
- Confirm property assumptions

### Mandatory Main Entry Point
Each project MUST have a `main` script as the unified entry point:

1. **Unified Interface**: All projects must use `main` as the primary interface
2. **Help Documentation**: `main --help` or `main -h` must display complete usage documentation in English
3. **Self-Documenting**: The script should contain all usage instructions and project summary in English
4. **No Additional Docs**: Do not maintain separate documentation files by default
5. **Flexible Parameters**: Script may include project-specific parameters and flags
6. **Test Integration**: The script MUST support these test-related options:
   - `main --test`: Run all tests and show detailed report with success rate
   - `main --test <path>`: Run tests in specific directory
   - Individual test results plus overall summary report
7. **Default Run**: The script MUST support running without any parameters to execute the project's primary functionality

**Note**: The main script MUST use `#!/usr/bin/env <interpreter>` shebang for portability and flexibility, never hardcode interpreter paths.

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


## System Tools Usage Guide

### Database Log System Overview
The system includes a continuously running database log system (`~/.log.db`) that automatically records various interaction data while the machine is powered on, including voice recordings, intent recognition, physiological data, and focus changes. Use the `get_intent.sh` script to query these records: without parameters returns total record count, `-t` for time-based search, `-s` for text search, `-n` to limit number of results, `--start/--end` for time range filtering.

### System Tools Directory
- **Script directory**: `/home/paradoxist/.config/home-manager/modules/local/bin/`

### 1. Setting Reminders
Use the `execute_tool.sh` command with `at` command format to set desktop reminders:

**Command format:**
```bash
execute_tool.sh set_reminder <reminder_time> <reminder_content>
```

**Examples:**
- Reminder to drink water in 5 minutes: `execute_tool.sh set_reminder "now + 5 minutes" "Drink water"`
- Meeting reminder tomorrow at 3 PM: `execute_tool.sh set_reminder "3:00 PM tomorrow" "Meeting"`

### 2. Performing Desktop Operations
Use the `execute_tool.sh` command to execute various desktop shortcut operations:

**Command format:**
```bash
execute_tool.sh desktop_operation [<operation_number>]
```

**Instructions:**
- When `<operation_number>` is not provided, displays all available desktop operation list
- When `<operation_number>` is provided, executes the corresponding numbered operation

**Output example (showing operation list):**
```
0	"open terminal"
1	"open editor"
2	"open file manager"
...
```

**Execution examples:**
- Open terminal: `execute_tool.sh desktop_operation 0`
- Open browser: `execute_tool.sh desktop_operation 13`

### 3. Managing User-Level Scheduled Tasks
The standard workflow for managing scheduled tasks (cron jobs, including daily reminders) is:
1. **Directly modify source file**: Edit the source file located at `/home/paradoxist/.cron`
2. **Synchronize to system**: Execute `crontab /home/paradoxist/.cron` command to apply the modified content to the system

### 4. Checking Current Situation
When the user requests to check the current situation, read the `/tmp/snapshot_picture.png` file to obtain screenshot information.

# Ad-hoc Requirements and Notes

- 我需要记住三个生物化学反应数据库网站：
  1. KEGG PATHWAY: https://www.genome.jp/kegg/pathway.html
  2. Reactome: https://reactome.org/
  3. BioCyc: https://biocyc.org/

- 灵感：文件管理 - 探索双曲（hyperbolic）文件浏览器。
- 灵感：浏览器定制 - 尝试使用Common Lisp定制Nyxt浏览器。
- 灵感：系统能力测试 - 卸载字体包并用此示例测试动态修改系统能力。

- 今天解了一个“鸡鸡毛结”。
- 用户自己养了猫。
