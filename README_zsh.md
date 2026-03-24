# zsh 配置使用说明

---

**需要使用分支 `zsh`**


## zsh 配置说明

1. 本仓库支持模块化拆分，所有功能性配置已拆分到 zsh 文件夹下的子文件：
	- starship.zsh：starship 主题配置与切换
	- brew.zsh：Homebrew 镜像源切换
	- functions.zsh：常用函数（如代理设置）
	- aliases.zsh：常用别名

2. 主配置文件 .zshrc 只负责加载上述子文件。

3. starship 配置文件位于 submodule/starship 下，随机主题只会从 starship*.toml 中选择。

4. 无需依赖 shuf 或 Python，随机主题选择使用 zsh 内置随机数即可。

---

## 快速使用

1. 推荐在 ~/.zshrc 中 source 本仓库的 .zshrc，不推荐直接软连接：
	> source ~/.zshrc

2. 启动 zsh 即可自动加载所有模块化配置。

3. 切换 starship 主题：
	> ssc
	> ssc custom|c
	> ssc powerline|p
	> ssc plaintextsymbols|t
    > ssc random|r

4. 如需自定义 starship 主题，可编辑 submodule/starship 下的 toml 文件。

---

## 目录结构示例

``` Plain Text
zsh/
├── .zshrc
├── zsh/
│   ├── starship.zsh
│   ├── brew.zsh
│   ├── functions.zsh
│   └── aliases.zsh
└── submodule/
	 └── starship/
		  ├── starship_custom.toml
		  ├── starship_powerline.toml
		  └── starship_plaintextsymbols.toml
```

---

如有问题或建议，欢迎 issue 或 PR。
