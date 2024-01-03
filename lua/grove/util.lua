---@class GroveUtil
local GroveUtil = {}

---@param path string
---@return string
function GroveUtil:trim_trailing_slash(path)
    local new_path = path:gsub("/$", "")
    return new_path
end

---@param project_path string
---@param file_path string
---@return string
function GroveUtil:get_relative_path(project_path, file_path)
    local relative_path = file_path:gsub(project_path, "")
    return relative_path
end

return GroveUtil
