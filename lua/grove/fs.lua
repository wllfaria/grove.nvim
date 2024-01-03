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
        self:_create_history_file()
    end
    local file = io.open(self.history_path, "r")
    if not file then
        return {}
    end
    local content = file:read("*a")
    file:close()
    if content == "" then
        return {}
    end
    return vim.fn.json_decode(content)
end

function GroveFileSystem:_create_history_file()
    if vim.fn.filereadable(self.history_path) == 0 then
        local file = io.open(self.history_path, "w")
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

---@param path string
---@return string
function GroveFileSystem:get_current_project_name(path)
    local segments = {}
    local separator = package.config:sub(1, 1)
    for segment in path:gmatch("[^" .. separator .. "]+") do
        table.insert(segments, segment)
    end
    return segments[#segments]
end

return GroveFileSystem
