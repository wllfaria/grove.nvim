local GroveConstants = require("grove.constants")

---@class GroveBuffer
local GroveBuffer = {}

GroveBuffer.__index = GroveBuffer

function GroveBuffer:new()
    return setmetatable({}, self)
end

local GROVE_GROUP = vim.api.nvim_create_augroup("Grove", {})
local LIST_PATH = vim.fn.stdpath("data") .. "/grove_list"

---@return GroveRecoverBuf
function GroveBuffer:current_buffer()
    local buf = vim.api.nvim_get_current_buf()
    local modified = vim.api.nvim_get_option_value("modified", { buf = buf })
    local modifiable = vim.bo[buf].modifiable
    return { buf_id = buf, is_modifiable = modifiable, is_modified = modified }
end

---@return number, number
function GroveBuffer:open_list()
    vim.cmd.edit(LIST_PATH)
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
    for lhs, rhs in pairs(GroveConstants.buffer_keymaps) do
        vim.api.nvim_buf_set_keymap(buf_id, "n", lhs, rhs, {})
    end
end

---@param buf_id number
function GroveBuffer:set_confirm_keymaps(buf_id)
    for lhs, rhs in pairs(GroveConstants.confirm_keymaps) do
        vim.api.nvim_buf_set_keymap(buf_id, "n", lhs, rhs, {})
    end
end

return GroveBuffer
