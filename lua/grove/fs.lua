---@class GroveFileSystem
---@field history_path string
---@field list_path string
local GroveFileSystem = {}

GroveFileSystem.__index = GroveFileSystem

---@param history_path string
---@pahis list_path string
function GroveFileSystem:new(history_path, list_path)
    return setmetatable({
        history_path = history_path,
        list_path = list_path,
    }, self)
end

---@param history_path string
---@pahis list_path string
---This is for testing purposes only, you should not use it
function GroveFileSystem:_configure(history_path, list_path)
    self.history_path = history_path
    self.list_path = list_path
end

---@return ProjectList
function GroveFileSystem:load_sessions()
    if vim.fn.filereadable(self.history_path) == 0 then
        GroveFileSystem:_create_sessions_dir()
    end
    local file = io.open(self.history_path, "r")
    if not file then
        return {}
    end
    local content = file:read("*a")
    file:close()
    return vim.fn.json_decode(content)
end

function GroveFileSystem:_create_sessions_dir()
    local file_path = vim.fn.stdpath("data") .. "/grove_history.json"
    if vim.fn.filereadable(file_path) == 0 then
        local file = io.open(file_path, "w")
        if file then
            file:write("{}")
            file:close()
        end
    end
end

---@param list string[]
function GroveFileSystem:write_list(list)
    local file = io.open(self.list_path, "w")
    if file then
        for _, line in pairs(list) do
            file:write(line .. "\n")
        end
        file:close()
    end
end

---@param projects ProjectList
function GroveFileSystem:write_projects(projects)
    local file = io.open(self.history_path, "w")
    if file then
        local content = vim.fn.json_encode(projects)
        file:write(content)
        file:close()
    end
end

---@return string
function GroveFileSystem:get_current_project_name()
    local cwd = vim.fn.getcwd()
    if not cwd then
        return ""
    end
    ---@type string[]
    local segments = {}
    local separator = package.config:sub(1, 1)
    for segment in cwd:gmatch("[^" .. separator .. "]+") do
        segments[#segments + 1] = segment
    end
    return segments[#segments]
end

return GroveFileSystem
