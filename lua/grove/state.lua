---@class CursorPosition
---@field row number
---@field col number

---@class GroveProject
---@field path string
---@field entrypoint string
---@field cursor CursorPosition

---@class GroveRecoverBuf
---@field buf_id number
---@field is_modifiable boolean
---@field is_modified boolean

---@class GroveState
---@field buf_id? number
---@field win_id? number
---@field recover_buf GroveRecoverBuf
---@field projects table<string, GroveProject>
local GroveState = {
    buf_id = nil,
    win_id = nil,
    recover_buf = {
        buf_id = 0,
        is_modifiable = false,
        is_modified = false,
    },
    projects = {},
}

---@return string[]
function GroveState:_projects_as_list()
    local projects = {}
    for project in pairs(self.projects) do
        table.insert(projects, project .. "/")
    end
    return projects
end

return GroveState
