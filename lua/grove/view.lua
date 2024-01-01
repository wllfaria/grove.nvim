local GroveBuffer = require("grove.buffer")
local GroveConfig = require("grove.config")
local GroveConstants = require("grove.constants")
local GroveFileSystem = require("grove.fs")
local GroveState = require("grove.state")
local GroveUtil = require("grove.util")

local GroveView = {}

---@param buf_id number
-- TODO: find the right place for this, and maybe split it up
local function handle_list_update(buf_id)
    local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, true)
    local lines_map = {}
    for _, line in pairs(lines) do
        lines_map[line] = true
    end
    local modified = {}
    local modified_list = {}
    local projects_list = GroveState:_projects_as_list()
    local highlights = {}
    for _, project in pairs(projects_list) do
        if lines_map[project] == nil then
            -- TODO: find a way to add/edit projects within the list
            local project_name = GroveUtil:trim_trailing_slash(project)
            local prefix = " REMOVE "
            modified[project] = GroveState.projects[project_name]
            table.insert(modified_list, prefix .. project)
            highlights[#modified_list] = {
                group = "GroveDeletedProject",
                line = #modified_list - 1,
                col = 0,
                end_col = string.len(prefix),
            }
        end
    end
    if #modified_list < 8 then
        for _ = 1, 2 do
            table.insert(modified_list, "")
        end
    else
        table.insert(modified_list, "")
    end
    local line, padding = GroveUtil:center_line(
        "[O]k   [C]ancel",
        GroveConstants.confirm_float_width
    )
    table.insert(modified_list, line)
    if vim.tbl_isempty(modified) then
        return
    end
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, modified_list)
    vim.bo[buf].modifiable = false
    for _, highlight in pairs(highlights) do
        vim.api.nvim_buf_add_highlight(
            buf,
            -1,
            highlight.group,
            highlight.line,
            highlight.col,
            highlight.end_col
        )
    end
    -- NOTE: I feel like there's a better way to do this
    vim.api.nvim_buf_add_highlight(
        buf,
        -1,
        "GroveDirectory",
        #modified_list - 1,
        padding,
        padding + 3
    )
    vim.api.nvim_buf_add_highlight(
        buf,
        -1,
        "GroveDirectory",
        #modified_list - 1,
        padding + 7,
        padding + 10
    )
    GroveBuffer:set_confirm_keymaps(buf)
    GroveView:open_float(buf, #modified_list)
end

function GroveView:open_window()
    GroveState.recover_buf = GroveBuffer:current_buffer()
    local buf, win = GroveBuffer:open_list()
    GroveState.buf_id = buf
    GroveState.win_id = win
    GroveBuffer:set_autocmds(buf, handle_list_update)
    GroveBuffer:set_keymaps(buf)
end

function GroveView:close_window()
    GroveBuffer:close_list(GroveState.buf_id)
    local buf = GroveState.recover_buf
    vim.api.nvim_win_set_buf(GroveState.win_id, buf.buf_id)
    vim.bo[buf.buf_id].modifiable = buf.is_modifiable
end

---@param buf_id number
function GroveView:open_float(buf_id, lines)
    local max_height = GroveConstants.confirm_float_height
    local height = max_height > lines and lines or max_height
    local width = GroveConstants.confirm_float_width
    local win = vim.api.nvim_open_win(buf_id, true, {
        relative = "editor",
        width = width,
        height = height,
        title = "Confirm changes",
        title_pos = "left",
        focusable = true,
        border = "rounded",
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        zindex = 150,
        style = "minimal",
    })
    -- HACK: this seems like a hack to me, why does it need to be deferred?
    vim.defer_fn(function()
        vim.api.nvim_set_current_win(win)
        vim.api.nvim_win_set_cursor(win, { 1, 0 })
    end, 10)
    GroveState.float_win_id = win
    GroveState.float_buf_id = buf_id
end

function GroveView:close_confirm_float()
    vim.api.nvim_win_close(GroveState.float_win_id, true)
    vim.api.nvim_buf_delete(GroveState.float_buf_id, { force = true })
end

function GroveView:confirm_changes()
    print("confirm changes")
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
    local entrypoint = project.entrypoint ~= ""
            and project.path .. project.entrypoint
        or project.path
    vim.cmd.edit(entrypoint)
    vim.api.nvim_win_set_cursor(
        GroveState.win_id,
        { project.cursor.row, project.cursor.col }
    )
end

function GroveView:add_project()
    local path = vim.fn.getcwd()
    if not path then
        return
    end
    local project_name = GroveFileSystem:get_project_name()
    local entrypoint = ""
    if GroveConfig.enable_entrypoint then
        entrypoint = vim.fn.input("Entrypoint: ", "", "file")
    end
    GroveState.projects[project_name] = {
        path = path,
        entrypoint = entrypoint,
        cursor = {
            col = GroveConfig.enable_entrypoint and vim.fn.col(".") or 1,
            row = GroveConfig.enable_entrypoint and vim.fn.line(".") or 1,
        },
    }
    GroveFileSystem:write_projects()
end

function GroveView:update_projects()
    if not GroveConfig.update_entrypoint then
        return
    end

    local project = GroveFileSystem:get_current_project()
    if not project then
        return
    end

    local current_file = vim.api.nvim_buf_get_name(0)
    project.cursor.col = vim.fn.col(".") and vim.fn.col(".") or 1
    project.cursor.row = vim.fn.line(".") and vim.fn.line(".") or 1
    project.entrypoint = GroveFileSystem.get_relative_path(
        GroveFileSystem,
        project.path,
        current_file
    )
    GroveFileSystem:write_projects()
end

return GroveView
