local grove = require("grove")

describe("FileSystem", function()
    before_each(function()
        require("plenary.reload").reload_module("harpoon")
        grove = require("grove")
    end)

    it("should wrote the projects to a file", function()
        local projects = {
            {
                name = "test",
                path = "/tmp/test",
                entrypoint = "/tmp/test/main.lua",
            },
        }
        local path = vim.fn.stdpath("data") .. "/test_grove_history.json"
        grove.fs:_configure(path)
        grove.fs:write_projects(projects)
        local written = vim.fn.readfile(path)
        assert.are.same(projects, vim.fn.json_decode(written))
    end)
end)
