---@class GroveConfig
---@field enable_entrypoint boolean @whether to prompt for an entrypoint when adding a project
---@field update_entrypoint boolean @whether to update the entrypoint when switching projects
local GroveConfig = {
    enalbe_entrypoint = false,
    update_entrypoint = false,
    keymap = {
        open = "<leader><leader>=",
        close = "<leader><leader>-",
        refresh = "<leader><leader>r",
    },
}

return GroveConfig
