---@class GroveBuffer
local GroveBuffer = {}

GroveBuffer.__index = GroveBuffer

---@param buf_id number
-- TODO: fix this absolute mess
local function handle_list_update(buf_id)
    local grove = require("grove")
    local GroveUtil = require("grove.util")

    local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, true)
    local lines_map = {}
    for _, line in pairs(lines) do
        lines_map[line] = true
    end

    local modified = { projects = {}, list = {}, highlights = {} }
    local projects_list = grove.view:_projects_as_list()
    for _, project in pairs(projects_list) do
        if lines_map[project] == nil then
            local prefix = " REMOVE "
            local project_name = GroveUtil:trim_trailing_slash(project)

            modified.projects[project_name] = grove.view.projects[project_name]
            table.insert(modified.list, prefix .. project)
            modified.highlights[#modified.list] = {
                group = "GroveDeletedProject",
                line = #modified.list - 1,
                col = 0,
                end_col = string.len(prefix),
            }
        end
    end

    if vim.tbl_isempty(modified.projects) then
        return
    end

    grove.view.modified_projects = modified.projects

    local lines_to_append = #modified.list < 8 and 2 or 1
    for _ = 1, lines_to_append do
        table.insert(modified.list, "")
    end
    local confirm, padding = grove.view:center_line(
        "[O]k   [Q]uit",
        grove.view.layout.confirm_float.width
    )
    table.insert(modified.list, confirm)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, modified.list)
    vim.bo[buf].modifiable = false

    grove.view:add_float_highlights(
        buf,
        modified.highlights,
        padding,
        #modified.list
    )

    GroveBuffer:set_confirm_keymaps(buf)
    grove.view:open_float(buf, #modified.list)
end

function GroveBuffer:new()
    return setmetatable({}, self)
end

local GROVE_GROUP = vim.api.nvim_create_augroup("Grove", {})

---@return GroveRecoverBuf
function GroveBuffer:current_buffer()
    local buf = vim.api.nvim_get_current_buf()
    local modified = vim.api.nvim_get_option_value("modified", { buf = buf })
    local modifiable = vim.bo[buf].modifiable
    return { buf_id = buf, is_modifiable = modifiable, is_modified = modified }
end

---@return number, number
---@param path string
function GroveBuffer:open_list(path)
    vim.cmd.edit(path)
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    return buf, win
end

---@param buf_id number
function GroveBuffer:close_list(buf_id)
    vim.api.nvim_buf_delete(buf_id, { force = true })
end

---@param buf_id number
function GroveBuffer:set_autocmds(buf_id)
    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
        group = GROVE_GROUP,
        buffer = buf_id,
        callback = function()
            handle_list_update(buf_id)
        end,
    })
end

---@param win_id number
---@param buf_id number
function GroveBuffer:set_float_autocmds(win_id, buf_id)
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        group = GROVE_GROUP,
        buffer = buf_id,
        callback = function()
            print("BufLeave")
            vim.api.nvim_win_close(win_id, true)
            vim.api.nvim_buf_delete(buf_id, { force = true })
        end,
    })
end

---@param buf_id number
function GroveBuffer:set_keymaps(buf_id)
    vim.keymap.set("n", "q", function()
        local grove = require("grove")
        grove:close_window()
    end, { silent = true, buffer = buf_id })
    vim.keymap.set("n", "<CR>", function()
        local grove = require("grove")
        grove:select_project()
    end, { silent = true, buffer = buf_id })
end

---@param buf_id number
function GroveBuffer:set_confirm_keymaps(buf_id)
    vim.keymap.set("n", "o", function()
        local grove = require("grove")
        grove:confirm_changes()
    end, { silent = true, buffer = buf_id })
    vim.keymap.set("n", "q", function()
        local grove = require("grove")
        grove:cancel_changes()
    end, { silent = true, buffer = buf_id })
    vim.keymap.set("n", "<C-c>", function()
        local grove = require("grove")
        grove:cancel_changes()
    end, { silent = true, buffer = buf_id })
end

return GroveBuffer
