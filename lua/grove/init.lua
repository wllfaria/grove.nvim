local GroveActions = require("grove.actions")
local GroveConfig = require("grove.config")
local GroveFileSystem = require("grove.fs")
local GroveState = require("grove.state")

---@class Grove
local Grove = {}

function Grove:open_window()
    GroveActions:update_projects()
    GroveActions:open_window()
end

function Grove:close_window()
    GroveActions:restore_original()
end

function Grove:switch_project()
    -- TODO: should probably check if any buffers are modified and prompt to save
    if GroveState.recover_buf.is_modified then
        vim.notify(
            "Modified buffers, please save before switching projects",
            vim.log.levels.WARN
        )
        return
    end
    local line = vim.api.nvim_get_current_line()
    local project = GroveState.projects[line]
    if project then
        vim.cmd("cd " .. project.path)
    end
    if project.entrypoint ~= "" then
        vim.api.nvim_command(
            ":edit " .. project.path .. "/" .. project.entrypoint
        )
    else
        vim.api.nvim_command(":edit " .. project.path)
    end
    vim.api.nvim_win_set_cursor(
        GroveState.win_id,
        { project.cursor.row, project.cursor.col }
    )
end

function Grove:add_project()
    GroveActions:add_project()
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
