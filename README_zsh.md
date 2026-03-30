# zsh 配置使用说明

---

**需要使用分支 `zsh`**


## zsh 配置说明

1. 本仓库支持模块化拆分，所有功能性配置已拆分到 zsh 文件夹下的子文件：
	- starship.zsh：starship 主题配置与切换
	- brew.zsh：Homebrew 镜像源切换
	- functions.zsh：常用函数（如代理设置）
	- aliases.zsh：常用别名
	- zoxide.zsh：zoxide 快速目录跳转初始化
	- nodejs.zsh：npm 镜像源切换

2. 主配置文件 .zshrc 只负责加载上述子文件。

3. 初始化脚本 init.sh 支持自动安装所有依赖工具，并分类输出安装结果与版本。

4. starship 配置文件位于 submodule/starship 下，随机主题只会从 starship*.toml 中选择。

5. 无需依赖 shuf 或 Python，随机主题选择使用 zsh 内置随机数即可。

---

## 快速使用

1. 运行 init.sh 自动安装所有依赖工具：
	> bash ~/.config/zsh/init.sh

2. 在用户 ~/.zshrc 末尾添加以下内容以加载本仓库配置：
	> source ~/.config/zsh/.zshrc

3. 启动 zsh 即可自动加载所有模块化配置。

4. 切换 starship 主题：
	> ssc
	> ssc custom|c
	> ssc powerline|p
	> ssc plaintextsymbols|t
	> ssc random|r

5. 切换 npm 镜像源：
	> npmswitch official|o
	> npmswitch taobao|t
	> npmswitch list

6. 切换 Homebrew 镜像源：
	> brewswitch tsinghua|t
	> brewswitch ustc|u
	> brewswitch official|o
	> brewswitch list

7. 如需自定义 starship 主题，可编辑 submodule/starship 下的 toml 文件。

---

## 目录结构示例

``` Plain Text
zsh/
├── .zshrc
├── init.sh
├── zsh/
│   ├── starship.zsh
│   ├── brew.zsh
│   ├── functions.zsh
│   ├── aliases.zsh
│   ├── zoxide.zsh
│   └── nodejs.zsh
└── submodule/
    └── starship/
        ├── starship_custom.toml
        ├── starship_powerline.toml
        └── starship_plaintextsymbols.toml
```

---

如有问题或建议，欢迎 issue 或 PR。
