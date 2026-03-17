# PowerShell 配置使用说明

---

**需要使用分支 `pwsh`**


## PowerShell 配置说明

1. 本仓库支持模块化拆分，所有功能性配置已拆分到 sh 文件夹下的子文件：
   - prompt.ps1：自定义提示符与窗口标题
   - starship.ps1：starship 主题配置与切换
   - modules.ps1：模块导入与 PSReadLine 设置
   - aliases_and_functions.ps1：常用别名与函数

2. 主配置文件 Microsoft.PowerShell_profile.ps1 只负责加载上述子文件。

3. 初始化依赖脚本 init_profile_dependencies.ps1 支持自动安装所有依赖，并分类输出安装结果与版本。

4. starship 配置文件路径已适配多层目录结构，支持 profile/sh 子文件夹调用。

5. 推荐使用 PowerShell 7+，并确保 winget 可用。

---

## 快速使用

1. 运行 init_profile_dependencies.ps1 自动安装所有依赖：
   > powershell -File .\init_profile_dependencies.ps1

2. 启动 PowerShell 即可自动加载所有配置。

3. 如需自定义 starship 主题，可编辑 submodule/starship 下的 toml 文件。

---

## 目录结构示例

``` Plain Text
PowerShell/
├── Microsoft.PowerShell_profile.ps1
├── init_profile_dependencies.ps1
├── sh/
│   ├── prompt.ps1
│   ├── starship.ps1
│   ├── modules.ps1
│   └── aliases_and_functions.ps1
└── submodule/
    └── starship/
        ├── starship_custom.toml
        ├── starship_powerline.toml
        └── starship_plaintextsymbols.toml
```

---

如有问题或建议，欢迎 issue 或 PR。

