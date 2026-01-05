# 开发环境与最佳实践

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
1. **Environment Isolation**: Always use `shell.nix` to manage project virtual environments
2. **Dependency Management**: When new dependencies are needed, maintain them through `shell.nix` to ensure environment reproducibility
3. **No Global Dependencies**: Never install dependencies globally; everything must be contained within the project's Nix environment

### Core Workflow
**Core Philosophy**: Developers focus on business logic, environment follows automatically.

**Three-Step Workflow**:
1. **Discovery**: Runtime reveals missing command or library
2. **Declaration**: Add `pkgs.<package-name>` to `myPackages` list in `shell.nix`
3. **Automatic Activation**: Environment reloads automatically after save, new package immediately available

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

### Project Structure Expectations
For each new project:
1. Create a `shell.nix` defining all dependencies
2. Set up `.envrc` for direnv integration
3. Implement the minimal viable solution first
4. Iterate based on feedback and requirements

#### Special Directory Locations

##### Configuration Management Directory
- **Location**: `~/.config/home-manager`
- **Purpose**: System-wide configuration managed as code (NixOS home-manager)
- **Repository**: This is itself a git repository containing all system configurations
- **Usage**: When adjusting environment settings or dependencies, update this configuration directory

##### Project Repository Directory
- **Location**: `~/Desktop/Projects`
- **Purpose**: Centralized storage for all project repositories
- **Structure**: Each subdirectory represents one project (can be cloned from open-source or newly created)
- **Default Path**: All new projects should be created within this directory unless specified otherwise
- **Reference**: When looking for a project or creating a new one, start from this location

##### Primary Project Root Directory
- **Default Location**: `/home/paradoxist/Desktop/Projects` is the primary project root directory
- **Usage**: This is the default location for creating new projects, finding existing ones, or cloning repositories

## 系统工具使用指南

该系统包含一个持续运行的数据库日志系统（~/.log.db），在机器开启时自动记录各类交互数据，包括语音记录、意图识别、生理数据和焦点变化。使用 `get_intent.sh` 脚本可以查询这些记录：不加参数返回记录总数，`-t` 按时间搜索，`-s` 按文本搜索，`-n` 限制返回条数，`--start/--end` 按时间范围筛选。

- 脚本目录：/home/paradoxist/.config/home-manager/modules/local/bin/

### 1. 设置提醒的方式
使用 `execute_tool.sh` 命令结合 `at` 命令格式设置桌面提醒：

**命令格式：**
```bash
execute_tool.sh set_reminder <提醒时间> <提醒内容>
```

**示例：**
- 5分钟后提醒喝水：`execute_tool.sh set_reminder "now + 5 minutes" "喝水"`
- 明天下午3点提醒开会：`execute_tool.sh set_reminder "3:00 PM tomorrow" "开会"`

### 2. 进行桌面操作的方式
使用 `execute_tool.sh` 命令可以执行各种桌面快捷操作：

**命令格式：**
```bash
execute_tool.sh desktop_operation [<操作序号>]
```

**说明：**
- 当不提供 `<操作序号>` 时，会显示所有可用的桌面操作列表
- 当提供 `<操作序号>` 时，会执行对应序号的操作

**输出示例（显示操作列表）：**
```
0	"open terminal"
1	"open editor"
2	"open file manager"
...
```

**执行操作示例：**
- 打开终端：`execute_tool.sh desktop_operation 0`
- 打开浏览器：`execute_tool.sh desktop_operation 13`

### 3. 管理定时任务的方式
管理定时任务（cron jobs，包括每日提醒）的标准流程是：
1. **直接修改源文件**：编辑位于 `/home/paradoxist/.cron` 的源文件
2. **同步到系统**：执行 `crontab /home/paradoxist/.cron` 命令将修改后的内容应用到系统中

### 4. 检查当前情况的方式
当用户要求检查当前情况时，应读取 `/tmp/snapshot_picture.png` 文件来获取截图信息。

---

- 回复用户的时候，尽可能不要使用 echo 操作，而是直接使用文字。

## Development Constraints and Best Practices

### Document Management (Declarative Configuration)
Each project maintains exactly two declarative documentation files, akin to operating system configuration files:

1. **CLAUDE.md**: Strategic planning and declarative configuration for the entire project
   - **Purpose**: Describes what the entire project aims to achieve and its high-level goals
   - **Declaration**: This is the "desired state" - the authoritative specification of project objectives
   - **Update Frequency**: Modified only when strategic goals or architecture fundamentally change (by designated developers only)
   - **Authority**: Source of truth for project vision and scope

2. **README.md**: Current state declaration and progress tracking document
   - **Purpose**: Tracks actual progress after each development cycle compared to the strategic plan
   - **Declaration**: This is the "current state" - a explicit comparison with CLAUDE.md declarations
   - **Update Frequency**: Must be updated at the END of every development session
   - **Comparison Requirement**: MUST clearly compare current progress against the strategic goals in CLAUDE.md
   - **Format**: Explicitly show what has been completed, what's in progress, and what's pending

**Development Cycle Definition**:
- **Session Start**: Developer reads both documents to understand the gap between desired state (CLAUDE.md) and current state (README.md)
- **During Development**: Work toward closing the gap
- **Session End**: Developer MUST update README.md to declare new current state with explicit comparison to CLAUDE.md declarations
- **Completion Criteria**: Session is complete when README.md accurately reflects what was accomplished

**Document Update Triggers**:
- **CLAUDE.md**: Updated when project scope, goals, or architecture fundamentally changes (strategic changes only, by designated developers)
- **README.md**: Updated at the END of every development session to declare actual progress

**Declaration Principles**:
- **Clarity**: Both documents should be declarative statements, not procedural instructions
- **Contrast**: README.md must explicitly show the delta - what changed, what's been added, what's been removed
- **Alignment**: README.md progress should always be traceable back to specific goals in CLAUDE.md
- **Immutability**: Once declared in CLAUDE.md, strategic goals remain until formally updated

**Rule**: No additional documentation files should be created unless explicitly required.

#### Document Management Practices
- **Modifying Existing Instructions**: When managing or modifying existing memories in `.claude/CLAUDE.md`, use the "read file content, then use Edit tool for modification" approach
- **Commit Message Format**: Use single-line messages starting with a type indicator (e.g., 'feat:', 'fix:', 'refactor:'), with the first word after the type indicator not capitalized
- **Task Management**: All todos should be uniformly managed in the `~/README.md` file

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
Follow the Red-Green-Refactor cycle:

#### 1. Red Phase: Write a Failing Test
- Define expected behavior before implementation
- Run test to confirm failure
- Clear indication of what needs to be built

#### 2. Green Phase: Minimal Implementation
- Write the smallest code to make the test pass
- Focus on functionality over code quality
- Get to green as quickly as possible

#### 3. Refactor Phase: Improve Code Structure
- Optimize code while maintaining test pass
- Remove duplication, improve naming
- Tests provide safety net for changes

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
**Each test must be independent and self-contained:**
- No dependency on other tests' execution order
- Each test sets up its own data
- Tests can run in any order or parallel

#### 5. Proven Test Frameworks
**Use mature, established testing frameworks:**
- Python: pytest
- Go: go test
- Rust: cargo test
- Never write custom testing infrastructure

#### 6. Code Review for Tests
**Tests require the same scrutiny as production code:**
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

**Note**: The main script MUST use `#!/usr/bin/env < interpreter >` shebang for portability and flexibility, never hardcode interpreter paths.

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
- 写脚本的时候，在有可能的地方尽量使用短路表达式。

# 散碎要求与记录

- 我需要记住三个生物化学反应数据库网站：
  1. KEGG PATHWAY: https://www.genome.jp/kegg/pathway.html
  2. Reactome: https://reactome.org/
  3. BioCyc: https://biocyc.org/

- 灵感：文件管理 - 探索双曲（hyperbolic）文件浏览器。
- 灵感：浏览器定制 - 尝试使用Common Lisp定制Nyxt浏览器。
- 灵感：系统能力测试 - 卸载字体包并用此示例测试动态修改系统能力。

- 今天解了一个“鸡鸡毛结”。
- 用户自己养了猫。
