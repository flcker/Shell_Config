################################################################################
# plugins — managed by sheldon

# sheldon 插件管理（config 在 submodule 中，data 目录机器特定）
export SHELDON_CONFIG_FILE="${ZSH_CONFIG_DIR}/submodule/sheldon/plugins.toml"
eval "$(sheldon source)"
