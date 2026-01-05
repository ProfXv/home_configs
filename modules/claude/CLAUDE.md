# Development Environment and Best Practices


## Part 1: Environment Definition (What This System Is)

### 1.1 System Information
**Environment**: NixOS 25.11pre888552.b3d51a0365f6 (Xantusia) x86_64
**Host**: Khadas Mind-K1014-PCB
**Kernel**: 6.176-zen1
**CPU**: 13th Gen Intel i7-1360P (16) @ 5.000GHz
**GPU**: Intel Raptor Lake-P [Iris Xe Graphics]
**Memory**: 31837MiB
**Desktop**: Hyprland (Wayland)
**Shell**: zsh 5.9
**Terminal**: claude

### 1.2 Directory Structure

#### Standard Project Directory Structure
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

#### System-Level Directories
- **Configuration Management**: `~/.config/home-manager/` - System-wide configuration managed as code (NixOS home-manager)
- **System Tools**: `~/.config/home-manager/modules/local/bin/` - System tool scripts directory
- **Primary Project Repository**: `~/Desktop/Projects/` - Centralized storage for all project repositories
- **User-Level Cron Jobs**: `~/.cron` - Source file for user-level scheduled tasks

### 1.3 Key Files and Their Purposes

#### CLAUDE.md (Strategic Configuration Document)
- **Purpose**: The authoritative specification of project objectives and high-level goals
- **Status Declaration**: Represents the "desired state" for the entire project
- **Update Policy**: Modified only when strategic goals or architecture fundamentally change (by designated developers only)
- **Authority**: Source of truth for project vision and scope

#### README.md (Current State Declaration)
- **Purpose**: Tracks actual progress after each development cycle compared to the strategic plan
- **Update Requirement**: Must be updated at the END of every development session
- **Comparison Mandate**: MUST clearly compare current progress against the strategic goals in CLAUDE.md
- **Format**: Explicitly show what has been completed, what's in progress, and what's pending

#### shell.nix (Dependency Management)
- **Purpose**: Defines all project dependencies in a reproducible Nix environment
- **Mandatory Requirement**: All dependencies must be declared and managed through this file
- **Core Philosophy**: Environment-as-code with zero-command operation (edit → save → test immediately)

#### .envrc (Direnv Integration)
- **Purpose**: Automatically activates the Nix environment when entering the project directory

#### main (Mandatory Entry Point Script)
- **Purpose**: Unified interface for all project functionality
- **Requirements**:
  - Must support running without any parameters to execute primary functionality
  - Must display complete usage documentation in English via `main --help` or `main -h`
  - Must support test execution: `main --test` (run all tests) and `main --test <path>` (run tests in specific directory)
  - Must use `#!/usr/bin/env <interpreter>` shebang for portability, never hardcode interpreter paths

### 1.4 System Tools

#### Database Log System Overview
The system includes a continuously running database log system (`~/.log.db`) that automatically records various interaction data while the machine is powered on, including voice recordings, intent recognition, physiological data, and focus changes. Use the `get_intent.sh` script to query these records: without parameters returns total record count, `-t` for time-based search, `-s` for text search, `-n` to limit number of results, `--start/--end` for time range filtering.

#### System Tools Directory
- **Script directory**: `/home/paradoxist/.config/home-manager/modules/local/bin/`


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
