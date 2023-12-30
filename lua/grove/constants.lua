---@class GroveConstants
---@field entrypoint_patterns table<string, string[]>
local GroveConstants = {
    entrypoint_patterns = {
        ["main"] = { "main", "src/main" },
        ["lib"] = { "lib", "src/lib" },
        ["index"] = { "index", "src/index" },
        ["app"] = { "app", "src/app" },
        ["application"] = { "application", "src/application" },
        ["entry"] = { "entry", "src/entry" },
        ["entrypoint"] = { "entrypoint", "src/entrypoint" },
        ["initialize"] = { "initialize", "src/initialize" },
        ["init"] = { "init", "src/init" },
        ["start"] = { "start", "src/start" },
    },
}

return GroveConstants
