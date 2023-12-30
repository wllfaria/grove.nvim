local GroveKeymapper = require("grove.keymapper")
local GroveState = require("grove.state")

local GroveRenderer = {}

function GroveRenderer:render_projects()
    local projects = {}
    for project in pairs(GroveState.projects) do
        table.insert(projects, project)
    end
    GroveState.buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(GroveState.buf_id, 0, -1, true, projects)
    vim.bo[GroveState.buf_id].modifiable = true
    GroveState.win_id = vim.api.nvim_get_current_win()
    ---@class GroveRecoverBuf
    local recover_buf = {
        buf_id = vim.api.nvim_get_current_buf(),
        is_modifiable = vim.bo[GroveState.recover_buf.buf_id].modifiable,
        is_modified = vim.api.nvim_get_option_value(
            "modified",
            { buf = GroveState.recover_buf.buf_id }
        ),
    }
    GroveState.recover_buf = recover_buf
    vim.api.nvim_win_set_buf(GroveState.win_id, GroveState.buf_id)
    GroveKeymapper:set_keymaps()
end

function GroveRenderer:render_original()
    local buf = GroveState.recover_buf
    vim.api.nvim_buf_delete(GroveState.buf_id, { force = true })
    vim.api.nvim_win_set_buf(GroveState.win_id, buf.buf_id)
    vim.bo[buf.buf_id].modifiable = buf.is_modifiable
end

return GroveRenderer
