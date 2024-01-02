---@class GroveConfig
---@field enable_entrypoint boolean @whether to prompt for an entrypoint when adding a project
---@field update_entrypoint boolean @whether to update the entrypoint when switching projects
local GroveConfig = {}

GroveConfig.default_config = function()
    return {
        enalbe_entrypoint = false,
        update_entrypoint = false,
        keymap = {
            open = "cp",
            close = "q",
        },
    }
end

return GroveConfig
