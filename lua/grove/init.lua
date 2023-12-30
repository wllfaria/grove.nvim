local GroveActions = require("grove.actions")
local GroveConfig = require("grove.config")
local GroveFileSystem = require("grove.fs")
local GroveRenderer = require("grove.renderer")
local GroveState = require("grove.state")

---@class Grove
local Grove = {}

function Grove:open_window()
    GroveActions:update_projects()
    GroveActions:open_window()
end

function Grove:close_window()
    GroveRenderer:render_original()
end

function Grove:switch_project()
    if GroveState.recover_buf.is_modified then
        vim.notify(
            "Please save your changes before switching projects",
            vim.log.levels.WARN
        )
        return
    end

    local line = vim.api.nvim_get_current_line()
    local project = GroveState.projects[line]

    if project then
        vim.cmd("cd " .. project.path)
    end

    vim.api.nvim_command(":edit " .. project.path .. "/" .. project.entrypoint)
    vim.api.nvim_win_set_cursor(
        GroveState.win_id,
        { project.cursor.row, project.cursor.col }
    )
end

function Grove.setup()
    vim.keymap.set(
        "n",
        GroveConfig.keymap.open,
        "<cmd>lua require('grove'):open_window()<cr>"
    )
    vim.keymap.set(
        "n",
        GroveConfig.keymap.close,
        "<cmd>lua require('grove'):close_window()<cr>"
    )

    vim.keymap.set("n", "<leader><leader>r", "<cmd>lua R('grove')<cr>")

    GroveFileSystem:load_sessions()
end

Grove.setup()

return Grove
