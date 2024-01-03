local GroveBuffer = require("grove.buffer")
local GroveConfig = require("grove.config")
local GroveFileSystem = require("grove.fs")
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
    local history_path = vim.fn.stdpath("data") .. "/grove_history.json"
    local list_path = vim.fn.stdpath("data") .. "/grove_list"
    local fs = GroveFileSystem:new(history_path, list_path)
    local grove = setmetatable({
        config = config,
        fs = fs,
        view = GroveView:new(config, fs:load_sessions()),
        buffer = GroveBuffer:new(),
    }, self)

    return grove
end

function Grove:open_window()
    local project_name = self.fs:get_current_project_name()
    self.view:update_projects(project_name)
    self.fs:write_list(self.view:_projects_as_list())
    local recover_buf = self.buffer:current_buffer()
    local buf, win = self.buffer:open_list(self.fs.list_path)
    self.view:open_window(buf, win, recover_buf)
    self.buffer:set_keymaps(buf)
    self.buffer:set_autocmds(buf)
end

function Grove:close_window()
    self.view:close_window()
    self.buffer:close_list(self.view.buf_id)
    self.view.buf_id = nil
end

function Grove:select_project()
    self.view:select_project()
end

function Grove:add_project()
    local project_name = self.fs:get_current_project_name()
    print(project_name)
    local cwd = vim.fn.getcwd()
    if not cwd then
        error("Could not get current working directory")
        return
    end
    local projects = self.view:add_project(cwd, project_name)
    self.fs:write_projects(projects)
end

function Grove:confirm_changes()
    print(vim.inspect(self.view.float_win_id))
    print(vim.inspect(self.view.float_buf_id))
    self.view:close_confirm_float()
    local remaining_projects = self.view:confirm_changes()
    self.view.projects = remaining_projects
    self.view.modified_projects = {}
    self.fs:write_projects(remaining_projects)
end

function Grove:cancel_changes()
    self.view:close_confirm_float()
end

local grove = Grove:new()

---@param _ table
function Grove.setup(self, _)
    if self ~= grove then
        _ = self
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
