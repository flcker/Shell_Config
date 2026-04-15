# PowerShell 配置使用说明

---

## PowerShell 配置说明

1. 本仓库支持模块化拆分，所有功能性配置已拆分到 sh 文件夹下的子文件：
   - prompt.ps1：自定义提示符与窗口标题
   - starship.ps1：starship 主题配置与切换
   - modules.ps1：模块导入与 PSReadLine 设置
   - aliases_and_functions.ps1：常用别名与函数
   - config.ps1：zoxide 等工具初始化配置
   - nvim.ps1：Neovim 别名与配置加载（自动使用 submodule/nvim 下的 init.lua/init.vim）

2. 主配置入口文件 pwsh_profile.ps1 只负责加载上述子文件。

3. 初始化依赖脚本 init_profile_dependencies.ps1 支持自动安装所有依赖，并分类输出安装结果与版本。

4. starship 配置文件路径已适配多层目录结构，支持 profile/sh 子文件夹调用。

5. 推荐使用 PowerShell 7+，并确保 winget 可用。

---

## 快速使用

1. 在系统 profile 中加载本仓库入口文件（仅需配置一次）：

   在 `$PROFILE` 对应的文件中添加以下内容（路径替换为实际克隆位置）：

   ```powershell
   . "C:\Users\<用户名>\.config\pwsh\pwsh_profile.ps1"
   ```

   **不同宿主对应的 profile 文件：**

   | 宿主 | profile 文件 |
   |------|-------------|
   | PowerShell 终端 | `Microsoft.PowerShell_profile.ps1` |
   | VSCode 集成终端 | `Microsoft.VSCode_profile.ps1` |

   两个文件通常位于 `C:\Users\<用户名>\Documents\PowerShell\` 下，可以添加上述 dot-source 行才能生效。
   当`Microsoft.VSCode_profile.ps1` 不存在时, VSCode 集成终端会使用 `Microsoft.PowerShell_profile.ps1`,
   如果不需要区别对待，可以只留 `Microsoft.PowerShell_profile.ps1`。

2. 运行 init_profile_dependencies.ps1 自动安装所有依赖：

   ```powershell
   pwsh -File .\init_profile_dependencies.ps1
   ```

   支持以下参数：

   | 参数 | 说明 |
   |------|------|
   | `-ModuleScope CurrentUser`（默认） | 为当前用户安装 PowerShell 模块 |
   | `-ModuleScope AllUsers` 或 `-s a` | 为所有用户安装（需管理员权限） |
   | `-Help` 或 `-h` | 打印帮助信息 |

   示例：
   ```powershell
   # 为当前用户安装（默认）
   pwsh -File .\init_profile_dependencies.ps1

   # 为所有用户安装（需管理员）
   pwsh -File .\init_profile_dependencies.ps1 -s a
   ```

3. 重新启动 PowerShell 即可自动加载所有配置。

4. 如需自定义 starship 主题，可编辑 submodule/starship 下的 toml 文件。

---

## Submodule 说明

工具配置统一存放于 [ShellCfgSubmodule](https://github.com/flcker/ShellCfgSubmodule)，各工具对应独立分支，通过 git submodule 引入到 `submodule/` 目录下：

| Submodule | 路径 | 分支 | 说明 |
|-----------|------|------|------|
| starship | `submodule/starship/` | `starship` | starship 主题配置文件（toml） |
| nvim | `submodule/nvim/` | `nvim` | Neovim 配置，包含 init.lua 或 init.vim |
| git | `submodule/git/` | `git` | git alias & color 配置，通过 `[include]` 加载到 `~/.gitconfig` |

**初始化 submodule（首次克隆后执行）：**

```bash
git submodule update --init --recursive
```

**更新所有 submodule 到各分支最新：**

```bash
git submodule update --remote --merge
```

**新增工具配置：**

1. 在 ShellCfgSubmodule 创建对应分支（建议使用 `--orphan` 保持历史独立）
2. 在本仓库执行：

```bash
git submodule add -b <branch> git@github.com:flcker/ShellCfgSubmodule.git submodule/<name>
```

---

## 目录结构示例

```
pwsh/
├── pwsh_profile.ps1              # 主入口，dot-source 加载所有子文件
├── init_profile_dependencies.ps1 # 一键安装所有依赖
├── sh/
│   ├── prompt.ps1                # 自定义提示符与窗口标题
│   ├── starship.ps1              # starship 主题配置与切换
│   ├── modules.ps1               # 模块导入与 PSReadLine 设置
│   ├── aliases_and_functions.ps1 # 常用别名与函数
│   ├── config.ps1                # zoxide 等工具初始化
│   └── nvim.ps1                  # Neovim 别名与配置加载
└── submodule/
    ├── starship/
    │   ├── starship_custom.toml
    │   ├── starship_powerline.toml
    │   └── starship_plaintextsymbols.toml
    ├── nvim/
    │   └── init.lua                  # Neovim 配置入口（优先加载，也支持 init.vim）
    └── git/
        └── config                    # git alias & color，~/.gitconfig 通过 [include] 加载
```

---

## 常见问题

### 启动时提示模块未找到（如 posh-git、PSFzf）

**原因**：modules.ps1 在导入模块前会检查模块是否已安装，若未安装则会显示警告并跳过，不影响其他功能正常加载。但相关功能（如 git 状态提示、fzf 集成）将不可用。

**解决方法**：运行依赖安装脚本：

```powershell
pwsh -File path\to\init_profile_dependencies.ps1
```

安装完成后重启 PowerShell 即可。

### $PROFILE 路径在哪里？

在 PowerShell 中执行以下命令查看：

```powershell
$PROFILE
```

通常为 `C:\Users\<用户名>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`。

VSCode 集成终端使用的是同目录下的 `Microsoft.VSCode_profile.ps1`，可以单独添加 dot-source 行；若不存在，则会共用`Microsoft.PowerShell_profile.ps1`。

---

## 开发工具安装（devtools_install.ps1）

`devtools_install.ps1` 用于一键安装 Windows 常用开发工具，支持交互式选择或参数指定。

### 直接从 GitHub 下载运行（无需克隆仓库）

以管理员身份打开 PowerShell，执行以下命令：

```powershell
# 交互式菜单选择安装
irm https://raw.githubusercontent.com/flcker/Shell_Config/pwsh/devtools_install.ps1 | iex
```

> `irm` 是 `Invoke-RestMethod` 的别名，`iex` 是 `Invoke-Expression` 的别名。

若需传递参数（`iex` 不支持直接传参），改用临时文件方式：

```powershell
# 全部安装
$tmp = New-TemporaryFile | Rename-Item -NewName { $_.Name -replace '\.tmp$', '.ps1' } -PassThru
irm https://raw.githubusercontent.com/flcker/Shell_Config/pwsh/devtools_install.ps1 | Set-Content $tmp
pwsh -File $tmp -All
Remove-Item $tmp

# 指定工具安装
pwsh -File $tmp -Tools git,vscode,nanazip
```

### 参数说明

| 参数 | 说明 |
|------|------|
| 无参数 | 显示交互式选择菜单（默认勾选常用工具） |
| `-All` | 安装全部工具 |
| `-Tools git,vscode,...` | 只安装指定工具（逗号分隔，不区分大小写） |
| `-Help` 或 `-h` | 打印帮助信息 |

### 可安装工具

| Key | 工具 | 默认选中 |
|-----|------|----------|
| `pwsh` | PowerShell 7 | 是 |
| `git` | Git | 是 |
| `vscode` | VSCode | 是 |
| `nanazip` | NanaZip | 是 |
| `rust` | Rust (rustup) | 是 |
| `python` | Python 3（自动获取最新版） | 是 |
| `node` | Node.js LTS | 否 |
| `go` | Go | 否 |
| `java` | Java (Temurin 21) | 否 |
| `cmake` | CMake | 是 |
| `windbg` | WinDbg | 是 |

---

如有问题或建议，欢迎 issue 或 PR。
