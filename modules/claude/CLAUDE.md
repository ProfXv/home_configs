## System Memories and Instructions
- 我需要记住三个生物化学反应数据库网站：
1. KEGG PATHWAY: https://www.genome.jp/kegg/pathway.html
2. Reactome: https://reactome.org/
3. BioCyc: https://biocyc.org/
- 当需要管理或修改 .claude/CLAUDE.md 中已存在的记忆时，应采用“读取文件内容，然后使用 Edit 工具进行修改”的方式。
- 对于新项目，如果性能是关键考量，优先选择使用 Rust 语言；但在选择前，需优先评估项目生态的成熟度和对开发速度的要求。
- 开发图形界面应用时，首选的技术方案是 Tauri (Rust 后端 + Web 前端)。
- 在 /home/paradoxist/ 目录下使用 list_directory 工具时，必须设置 respect_git_ignore=False，因为该目录下的 .gitignore 文件会忽略所有文件。

- 在执行 npm 命令（如 npm run dev, npm install）时，为确保命令在正确的项目目录中运行，应在 shell 命令字符串内部明确使用 cd <project_directory> && <command>。
- The user's primary project *root* directory, where all individual projects are located, is /home/paradoxist/Desktop/Projects. This is the default location for creating new projects, finding existing ones, or cloning repositories.
- The user has explicitly stated that I do not need to ask for confirmation before executing commands. I should proceed with actions directly, and the user will interrupt if they disagree。
- Commit message preference: Use single-line messages, start with a type indicator (e.g., 'feat:', 'fix:', 'refactor:'), and the first word after the type indicator should not be capitalized.
- 灵感：知识管理 - 探索直接在浏览器中留下和管理笔记，而非转移到本地文件。
- 灵感：文件管理 - 探索双曲（hyperbolic）文件浏览器。
- 灵感：浏览器定制 - 尝试使用Common Lisp定制Nyxt浏览器。
- 灵感：系统能力测试 - 卸载字体包并用此示例测试动态修改系统能力。
- 灵感：个人发展 - 如何自发产生目的和意义，并为要做的事情寻找最合适的安排。
- 写代码时的注释规则：绝对不能用于说明当前代码的功能。代码注释应该在专门的地方插入，以说明这个地方将来可以添加什么功能。
- 不要添加任何代码注释。


- The command to create a new Tauri project is: npm create tauri-app@latest <package name> -- --template react --manager npm -y

- 管理定时任务（cron jobs，包括每日提醒）的标准流程是：首先，直接修改位于 `/home/paradoxist/.cron` 的源文件；然后，通过执行 `crontab /home/paradoxist/.cron` 命令，将修改后的内容同步并应用到系统中。


- 提醒用户：可以通过工作区选择方式查看最近活跃的工作区。
- 待办事项应统一在 ~/README.md 文件中进行管理。
- 当列出待办事项时，始终使用数字序号。
- 当用户询问理论问题时，必须先搜索最新的资料再作答。

- 当用户要求检查当前情况时，应读取 /tmp/snapshot_picture.png 文件来获取截图信息。

- 今天解了一个“鸡鸡毛结”。

- 在执行需要交互式操作的终端命令（包括需要sudo的命令）时，应在命令前加上 'kitty'。
- 在用户的家目录下添加文件时，应使用 `-f` 选项（例如：`git add -f <file>`）。
- 用户自己养了猫。
- 所有项目的开发都在沙箱环境中进行。只能访问当前工作目录及其子目录，但对当前目录下的所有内容拥有完全的读写和执行权限。


## 系统工具使用指南

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

---

- 回复用户的时候，尽可能不要使用 echo 操作，而是直接使用文字。
- 写脚本的时候，在有可能的地方尽量使用短路表达式。