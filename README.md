# Shell_Config
终端配置文件

---

## branch

|分支|说明|
| :---: | :--- |
| main | 空置分支, 用来写说明 |
|pwsh | PowerShell 7的配置文件|
|zsh | zsh 的配置 | 


---

## pwsh 安装、依赖与配置

[pwsh 使用说明](./README_pwsh.md)


---


## zsh 安装、依赖与配置

[zsh 使用说明](./README_zsh.md)


---


## submodule

跨平台工具配置统一存放于 [ShellCfgSubmodule](https://github.com/flcker/ShellCfgSubmodule)，各工具对应一个独立分支：

| 分支 | 说明 |
| :---: | :--- |
| starship | starship 主题配置 |
| nvim | Neovim 配置 |

新增工具：在 ShellCfgSubmodule 创建对应分支，在本仓库执行 `git submodule add -b <branch>`。
