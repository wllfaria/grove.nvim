local GroveState = require("grove.state")

---@class GroveFileSystem
local GroveFileSystem = {}

function GroveFileSystem:load_sessions()
    local file_path = vim.fn.stdpath("data") .. "/grove_history.json"

    if vim.fn.filereadable(file_path) == 0 then
        GroveFileSystem:_create_sessions_dir()
    end

    local file = io.open(file_path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        GroveState.projects = vim.fn.json_decode(content)
    end
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

---@return GroveProject?
function GroveFileSystem:get_current_project()
    local cwd = vim.fn.getcwd()
    local separator = package.config:sub(1, 1)

    if not cwd then
        return nil
    end

    local segments = {}
    for segment in cwd:gmatch("[^" .. separator .. "]+") do
        segments[#segments + 1] = segment
    end

    return GroveState.projects[segments[#segments]]
end

---@param project_path string
---@param file_path string
---
---@return string
function GroveFileSystem:get_relative_path(project_path, file_path)
    local relative_path = file_path:gsub(project_path, "")
    return relative_path
end

function GroveFileSystem:write_projects()
    local file_path = vim.fn.stdpath("data") .. "/grove_history.json"
    local file = io.open(file_path, "w")
    if file then
        local content = vim.fn.json_encode(GroveState.projects)
        file:write(content)
        file:close()
    end
end

return GroveFileSystem