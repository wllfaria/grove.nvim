local GroveFileSystem = require("grove.fs")
local GroveRenderer = require("grove.renderer")

local GroveActions = {}

function GroveActions:update_projects()
    local project = GroveFileSystem:get_current_project()

    if not project then
        return
    end

    local current_file = vim.api.nvim_buf_get_name(0)
    project.entrypoint = GroveFileSystem.get_relative_path(
        GroveFileSystem,
        project.path,
        current_file
    )

    local col = vim.fn.col(".")
    local row = vim.fn.line(".")

    if col ~= nil then
        project.cursor.col = col
    end
    if row ~= nil then
        project.cursor.row = row
    end

    GroveFileSystem:write_projects()
end

function GroveActions:open_window()
    GroveRenderer:render_projects()
end

return GroveActions
