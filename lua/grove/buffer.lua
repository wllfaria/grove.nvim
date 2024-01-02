---@class GroveBuffer
local GroveBuffer = {}

GroveBuffer.__index = GroveBuffer

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
---@param write_cb function
function GroveBuffer:set_autocmds(buf_id, write_cb)
    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
        group = GROVE_GROUP,
        buffer = buf_id,
        callback = function()
            write_cb(buf_id)
        end,
    })
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        group = GROVE_GROUP,
        buffer = buf_id,
        callback = function()
            -- GroveBuffer:close_list(buf_id)
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
    vim.keymap.set("n", "c", function()
        local grove = require("grove")
        grove:cancel_changes()
    end, { silent = true, buffer = buf_id })
    vim.keymap.set("n", "<C-c>", function()
        local grove = require("grove")
        grove:cancel_changes()
    end, { silent = true, buffer = buf_id })
end

return GroveBuffer
