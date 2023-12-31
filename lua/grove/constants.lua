---@class GroveConstants
---@field buffer_keymaps table<string, string>
local GroveConstants = {
    buffer_keymaps = {
        ["g?"] = "<cmd>lua require('grove'):show_help()",
        ["q"] = "<cmd>lua require('grove'):close_window()<cr>",
        ["<cr>"] = "<cmd>lua require('grove'):select_project()<cr>",
    },
    confirm_keymaps = {
        ["o"] = "<cmd>lua require('grove'):confirm_changes()<cr>",
        ["c"] = "<cmd>lua require('grove'):cancel_changes()<cr>",
        ["<c-c>"] = "<cmd>lua require('grove'):cancel_changes()<cr>",
    },
    confirm_float_width = math.floor(vim.o.columns * 0.6),
    confirm_float_height = math.floor(vim.o.lines * 0.8),
}

return GroveConstants
