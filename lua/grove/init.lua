local GroveBuffer = require("grove.buffer")
local GroveConfig = require("grove.config")
local GroveConstants = require("grove.constants")
local GroveFileSystem = require("grove.fs")
local GroveUtil = require("grove.util")
local GroveView = require("grove.view")

---@class Grove
---@field view GroveView
---@field config GroveConfig
---@field fs GroveFileSystem
---@field buffer GroveBuffer
local Grove = {}

Grove.__index = Grove

function Grove:new()
    local config = GroveConfig:default_config()
    local fs = GroveFileSystem:new()
    local grove = setmetatable({
        config = config,
        fs = fs,
        view = GroveView:new(config, fs:load_sessions()),
        buffer = GroveBuffer:new(),
    }, self)

    return grove
end

---@param buf_id number
-- TODO: fix this absolute mess
function Grove:handle_list_update(buf_id)
    local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, true)
    local lines_map = {}
    for _, line in pairs(lines) do
        lines_map[line] = true
    end
    local modified = {}
    local modified_list = {}
    local projects_list = self.view:_projects_as_list()
    local highlights = {}
    for _, project in pairs(projects_list) do
        if lines_map[project] == nil then
            -- TODO: find a way to add/edit projects within the list
            local project_name = GroveUtil:trim_trailing_slash(project)
            local prefix = " REMOVE "
            modified[project] = self.view.projects[project_name]
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

function Grove:open_window()
    local project_name = self.fs:get_current_project_name()
    self.view:update_projects(project_name)
    local buf, win = self.buffer:open_list(self.view:_projects_as_list())
    local recover_buf = self.buffer:current_buffer()
    self.view:open_window(buf, win, recover_buf)
    self.buffer:set_autocmds(buf, self.handle_list_update)
    self.buffer:set_keymaps(buf)
end

function Grove:close_window()
    self.buffer:close_list(self.view.buf_id)
    self.view:close_window()
end

function Grove:select_project()
    self.view:select_project()
end

function Grove:add_project()
    local project_name = self.fs:get_current_project_name()
    local cwd = vim.fn.getcwd()
    if not cwd then
        error("Could not get current working directory")
        return
    end
    local projects = self.view:add_project(cwd, project_name)
    self.fs:write_projects(projects)
end

function Grove:confirm_changes()
    self.view:confirm_changes()
end

function Grove:cancel_changes()
    self.view:close_confirm_float()
end

local grove = Grove:new()

---@param opts table
function Grove.setup(self, opts)
    if self ~= grove then
        ---@diagnostic disable-next-line: cast-local-type
        opts = self
        self = grove
    end
    local config = GroveConfig:default_config()
    -- TODO: move this to a colorscheme file
    -- maybe also make this configurable
    vim.cmd([[
        hi GroveDirectory guifg=#90a4b4
        hi GroveDeletedProject guifg=#C3423F
    ]])
    vim.keymap.set(
        "n",
        config.keymap.open,
        "<cmd>lua require('grove'):open_window()<cr>"
    )
    vim.keymap.set(
        "n",
        "<leader><leader>a",
        "<cmd>lua require('grove'):add_project()<cr>"
    )
    vim.keymap.set("n", "<leader><leader>r", "<cmd>lua R('grove')<cr>")
    return self
end

return grove
