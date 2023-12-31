local GroveConfig = require("grove.config")
local GroveFileSystem = require("grove.fs")
local GroveState = require("grove.state")

local GroveActions = {}

function GroveActions:update_projects()
    if not GroveConfig.update_entrypoint then
        return
    end
    local project = GroveFileSystem:get_current_project()
    if not project then
        return
    end
    local current_file = vim.api.nvim_buf_get_name(0)
    project.cursor.col = vim.fn.col(".") and vim.fn.col(".") or 1
    project.cursor.row = vim.fn.line(".") and vim.fn.line(".") or 1
    project.entrypoint = GroveFileSystem.get_relative_path(
        GroveFileSystem,
        project.path,
        current_file
    )
    GroveFileSystem:write_projects()
end

function GroveActions:add_project()
    local path = vim.fn.getcwd()
    if not path then
        return
    end
    local project_name = GroveFileSystem:get_project_name()
    local entrypoint = ""
    if GroveConfig.enable_entrypoint then
        entrypoint = vim.fn.input("Entrypoint: ", "", "file")
    end
    ---@type GroveProject
    local project = {
        path = path,
        entrypoint = entrypoint,
        cursor = {
            col = GroveConfig.enable_entrypoint and vim.fn.col(".") or 1,
            row = GroveConfig.enable_entrypoint and vim.fn.line(".") or 1,
        },
    }
    GroveState.projects[project_name] = project
    GroveFileSystem:write_projects()
end

return GroveActions
