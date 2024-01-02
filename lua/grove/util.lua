---@class GroveUtil
local GroveUtil = {}

---@param path string
---@return string
function GroveUtil:trim_trailing_slash(path)
    local new_path = path:gsub("/$", "")
    return new_path
end

---Center a line of text in a given width and returs `line`, `padding`.
---@param line string
---@param width number
---@return string, number
function GroveUtil:center_line(line, width)
    local line_length = string.len(line)
    local padding = math.floor((width - line_length) / 2)
    local centered_line = string.rep(" ", padding) .. line
    return centered_line, padding
end

---@param project_path string
---@param file_path string
---@return string
function GroveUtil:get_relative_path(project_path, file_path)
    local relative_path = file_path:gsub(project_path, "")
    return relative_path
end

return GroveUtil
