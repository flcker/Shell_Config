################################################################################
# nvim
# alias vim/vi
if command -v nvim >/dev/null 2>&1; then
    # 使用 nvim 替代 vim, 并加载submodule中的配置 `../submodule/nvim/init.lua`
    function nvim_fun() {
        # 使用环境变量 ZSH_CONFIG_NVIM_DIR 作为 nvim 配置目录
        local local_config="${ZSH_CONFIG_NVIM_DIR}/init.lua"
        # echo "nvim local_config: $local_config"
        if [ -f "$local_config" ]; then
            command nvim -u "$local_config" "$@"
        else
            command nvim "$@"
        fi
    }

    alias vim='nvim_fun'
    alias vi='nvim_fun'
fi
