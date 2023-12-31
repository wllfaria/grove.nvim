-- TODO: I really should separate this into a view and a buffer manager
local GroveKeymapper = require("grove.keymapper")
local GroveState = require("grove.state")

local GroveRenderer = {}

local GroveGroup = vim.api.nvim_create_augroup("Grove", {})

local function get_grove_buffer_name()
    return "Grove_" .. os.time()
end

---@param buffer_id number
function GroveRenderer:setup_aucmds(buffer_id)
    if vim.api.nvim_buf_get_name(buffer_id) == "" then
        vim.api.nvim_buf_set_name(buffer_id, get_grove_buffer_name())
    end
    vim.api.nvim_set_option_value("filetype", "grove", { buf = buffer_id })
    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buffer_id })
    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
        group = GroveGroup,
        buffer = buffer_id,
        callback = function()
            vim.schedule(function()
                -- TODO: actually update the project list when user saves
                print("BufWriteCmd")
            end)
        end,
    })
end

function GroveRenderer:render_projects()
    GroveState.buf_id = vim.api.nvim_create_buf(false, true)
    vim.bo[GroveState.buf_id].modifiable = true
    GroveState.win_id = vim.api.nvim_get_current_win()
    ---@type GroveRecoverBuf
    local recover_buf = {
        buf_id = vim.api.nvim_get_current_buf(),
        is_modifiable = vim.bo[GroveState.recover_buf.buf_id].modifiable,
        is_modified = vim.api.nvim_get_option_value(
            "modified",
            { buf = GroveState.recover_buf.buf_id }
        ),
    }
    GroveState.recover_buf = recover_buf
    local render_table = {
        lines = {},
        highlights = {},
    }
    local i = 0
    for project in pairs(GroveState.projects) do
        local name = project .. "/"
        table.insert(render_table.lines, name)
        table.insert(
            render_table.highlights,
            { line = i, len = #name, name = "GroveDirectory" }
        )
        i = i + 1
    end
    vim.api.nvim_buf_set_lines(
        GroveState.buf_id,
        0,
        -1,
        false,
        render_table.lines
    )
    for _, highlight in ipairs(render_table.highlights) do
        vim.api.nvim_buf_add_highlight(
            GroveState.buf_id,
            -1,
            highlight.name,
            highlight.line,
            0,
            highlight.len
        )
    end
    GroveRenderer:setup_aucmds(GroveState.buf_id)
    vim.api.nvim_win_set_buf(GroveState.win_id, GroveState.buf_id)
    GroveKeymapper:set_buf_keymaps()
end

function GroveRenderer:render_original()
    local buf = GroveState.recover_buf
    vim.api.nvim_buf_delete(GroveState.buf_id, { force = true })
    vim.api.nvim_win_set_buf(GroveState.win_id, buf.buf_id)
    vim.bo[buf.buf_id].modifiable = buf.is_modifiable
end

return GroveRenderer
