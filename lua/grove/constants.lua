---@class GroveConstants
---@field buffer_keymaps table<string, string>
local GroveConstants = {
    buffer_keymaps = {
        ["g?"] = "<cmd>lua require('grove'):show_help()",
        ["q"] = "<cmd>lua require('grove'):close_window()<cr>",
        ["<cr>"] = "<cmd>lua require('grove'):select_project()<cr>",
    },
}

return GroveConstants
