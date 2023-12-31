local GroveBuffer = require("grove.buffer")
local GroveState = require("grove.state")

local GroveView = {}

function GroveView:open_window()
    GroveState.recover_buf = GroveBuffer:current_buffer()
    local buf, win = GroveBuffer:open_list()
    GroveState.buf_id = buf
    GroveState.win_id = win
    GroveBuffer:set_autocmds(buf)
    GroveBuffer:set_keymaps(buf)
end

function GroveView:close_window()
    GroveBuffer:close_list(GroveState.buf_id)
    local buf = GroveState.recover_buf
    vim.api.nvim_win_set_buf(GroveState.win_id, buf.buf_id)
    vim.bo[buf.buf_id].modifiable = buf.is_modifiable
end

function GroveView:select_project()
    -- TODO: should probably check if any buffers are modified and prompt to save
    if GroveState.recover_buf.is_modified then
        vim.notify(
            "Modified buffers, please save before switching projects",
            vim.log.levels.WARN
        )
        return
    end
    local line = vim.api.nvim_get_current_line()
    local project = GroveState.projects[line:sub(0, -2)]
    if not project then
        vim.notify("Project not found", vim.log.levels.ERROR)
    end
    vim.cmd.cd(project.path)
    local entrypoint = project.entrypoint ~= "" and project.entrypoint or ""
    vim.cmd.edit(entrypoint)
    vim.api.nvim_win_set_cursor(
        GroveState.win_id,
        { project.cursor.row, project.cursor.col }
    )
end

return GroveView
