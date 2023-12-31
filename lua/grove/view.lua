local GroveUtil = require("grove.util")

---@class GroveCursor
---@field row number
---@field col number

---@class GroveRecoverBuf
---@field buf_id number
---@field is_modifiable boolean
---@field is_modified boolean

---@class GroveProject
---@field path string
---@field entrypoint string
---@field cursor GroveCursor

---@alias ProjectList table<string, GroveProject>

---@class ConfirmFloatLayout
---@field width number
---@field height number

---@class GroveLayout
---@field confirm_float ConfirmFloatLayout

---@class GroveView
---@field buf_id number
---@field win_id number
---@field float_buf_id number
---@field float_win_id number
---@field recover_buf GroveRecoverBuf
---@field config GroveConfig
---@field projects ProjectList
---@field layout GroveLayout
---@field modified_projects ProjectList
local GroveView = {}

GroveView.__index = GroveView

---@param config GroveConfig
---@param projects ProjectList
---@return GroveView
function GroveView:new(config, projects)
    local confirm_float = {
        width = math.floor(vim.o.columns * 0.6),
        height = math.floor(vim.o.lines * 0.8),
    }
    return setmetatable({
        buf_id = nil,
        win_id = nil,
        float_buf_ida = nil,
        float_win_id = nil,
        config = config,
        projects = projects,
        layout = {
            confirm_float = confirm_float,
        },
    }, self)
end

---@return string[]
function GroveView:_projects_as_list()
    local projects = {}
    for project in pairs(self.projects) do
        table.insert(projects, project .. "/")
    end
    return projects
end

---@param buf number
---@param win number
---@param recover_buf GroveRecoverBuf
function GroveView:open_window(buf, win, recover_buf)
    self.recover_buf = recover_buf
    print(recover_buf.buf_id)
    self.buf_id = buf
    self.win_id = win
end

function GroveView:close_window()
    local buf = self.recover_buf
    vim.api.nvim_win_set_buf(self.win_id, buf.buf_id)
    vim.bo[buf.buf_id].modifiable = buf.is_modifiable
end

---@param buf_id number
function GroveView:open_float(buf_id, lines)
    local grove = require("grove")
    local max_height = self.layout.confirm_float.height
    local height = max_height > lines and lines or max_height
    local width = math.floor(vim.o.columns * 0.6)
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
    self.float_win_id = win
    self.float_buf_id = buf_id
    grove.buffer:set_float_autocmds(win, buf_id)
end

function GroveView:close_confirm_float()
    vim.api.nvim_win_close(self.float_win_id, true)
    vim.api.nvim_buf_delete(self.float_buf_id, { force = true })
    vim.api.nvim_set_current_win(self.win_id)
    self.float_win_id = nil
    self.float_buf_id = nil
end

---@return ProjectList
function GroveView:confirm_changes()
    local remaining_projects = {}
    for name, project in pairs(self.projects) do
        if not self.modified_projects[name] then
            remaining_projects[name] = project
        end
    end
    return remaining_projects
end

function GroveView:select_project()
    -- TODO: should probably check if any buffers are modified and prompt to save
    if self.recover_buf.is_modified then
        vim.notify(
            "Modified buffers, please save before switching projects",
            vim.log.levels.WARN
        )
        return
    end
    local line = vim.api.nvim_get_current_line()
    local project = self.projects[line:sub(0, -2)]
    print("project", project)
    if not project then
        vim.notify("Project not found", vim.log.levels.ERROR)
    end
    vim.cmd.cd(project.path)
    local entrypoint = project.entrypoint ~= ""
            and project.path .. project.entrypoint
        or project.path
    vim.cmd.edit(entrypoint)
    vim.api.nvim_win_set_cursor(
        self.win_id,
        { project.cursor.row, project.cursor.col }
    )
end

---@param path string
---@param project_name string
function GroveView:add_project(path, project_name)
    local entrypoint = ""
    if self.config.enable_entrypoint then
        entrypoint = vim.fn.input("Entrypoint: ", "", "file")
    end
    self.projects[project_name] = {
        path = path,
        entrypoint = entrypoint,
        cursor = {
            col = self.config.enable_entrypoint and vim.fn.col(".") or 1,
            row = self.config.enable_entrypoint and vim.fn.line(".") or 1,
        },
    }
    return self.projects
end

---@param project_name string
function GroveView:update_projects(project_name)
    if not self.config.update_entrypoint then
        return
    end

    local project = self.projects[project_name]
    if not project then
        return
    end

    local current_file = vim.api.nvim_buf_get_name(0)
    project.cursor.col = vim.fn.col(".") and vim.fn.col(".") or 1
    project.cursor.row = vim.fn.line(".") and vim.fn.line(".") or 1
    project.entrypoint = GroveUtil:get_relative_path(project.path, current_file)
    return self.projects
end

---@param buf number
---@param highlights table<string, table>
---@param padding number
---@param total_lines number
function GroveView:add_float_highlights(buf, highlights, padding, total_lines)
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
        total_lines - 1,
        padding,
        padding + 3
    )
    vim.api.nvim_buf_add_highlight(
        buf,
        -1,
        "GroveDirectory",
        total_lines - 1,
        padding + 7,
        padding + 10
    )
end

---Center a line of text in a given width and returs `line`, `padding`.
---@param line string
---@param width number
---@return string, number
function GroveView:center_line(line, width)
    local line_length = string.len(line)
    local padding = math.floor((width - line_length) / 2)
    local centered_line = string.rep(" ", padding) .. line
    return centered_line, padding
end

return GroveView
