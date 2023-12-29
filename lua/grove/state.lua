---@class GroveState
---@field buffer_id number | nil
---@field buffer_lines string[] | nil
---@field current_directory table
local M = {
    buffer_id = nil,
    buffer_lines = nil,
    current_directory = {},
}

return M
