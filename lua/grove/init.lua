local GroveConfig = require("grove.config")
local GroveFileSystem = require("grove.fs")
local GroveState = require("grove.state")
local GroveView = require("grove.view")

---@class Grove
local Grove = {}

function Grove:open_window()
    GroveView:update_projects()
    GroveView:open_window()
end

function Grove:close_window()
    if vim.api.nvim_buf_is_valid(GroveState.buf_id) then
        GroveView:close_window()
    end
end

function Grove:select_project()
    GroveView:select_project()
end

function Grove:add_project()
    GroveView:add_project()
end

function Grove:confirm_changes()
    GroveView:confirm_changes()
end

function Grove:cancel_changes()
    GroveView:close_confirm_float()
end

function Grove.setup()
    -- TODO: move this to a colorscheme file
    -- maybe also make this configurable
    vim.cmd([[
        hi GroveDirectory guifg=#90a4b4
        hi GroveDeletedProject guifg=#C3423F
    ]])
    vim.keymap.set(
        "n",
        GroveConfig.keymap.open,
        "<cmd>lua require('grove'):open_window()<cr>"
    )
    vim.keymap.set(
        "n",
        "<leader><leader>a",
        "<cmd>lua require('grove'):add_project()<cr>"
    )
    vim.keymap.set("n", "<leader><leader>r", "<cmd>lua R('grove')<cr>")
    GroveFileSystem:load_sessions()
end

Grove.setup()

return Grove
