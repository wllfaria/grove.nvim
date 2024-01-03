local grove = require("grove")

local history_path = vim.fn.stdpath("data") .. "/test_grove_history.json"
local list_path = vim.fn.stdpath("data") .. "/test_grove_list"

describe("FileSystem", function()
    before_each(function()
        require("plenary.reload").reload_module("harpoon")
        grove = require("grove")
        grove.fs:_configure(history_path, list_path)
        vim.cmd("silent! !rm -rf " .. list_path)
        vim.cmd("silent! !rm -rf " .. history_path)
    end)

    it("should write the projects to a file", function()
        local projects = {
            ["test.nvim"] = {
                name = "test",
                path = "/tmp/test",
                entrypoint = "/tmp/test/main.lua",
            },
        }
        grove.fs:write_projects(projects)
        local written = vim.fn.readfile(history_path)
        assert.are.same(projects, vim.fn.json_decode(written))
    end)

    it("should get the correct project name", function()
        local path_one = "/test/path/to/test/project.nvim"
        local path_two = "/test/path/to/test/.hidden/test-project.nvim"
        local expect_one = "project.nvim"
        local expect_two = "test-project.nvim"

        local result_one = grove.fs:get_current_project_name(path_one)
        local result_two = grove.fs:get_current_project_name(path_two)

        assert.are.same(result_one, expect_one)
        assert.are.same(result_two, expect_two)
    end)

    it("should correctly write the list when the buffer is active", function()
        -- make a string[]
        local list = { "test_one", "test_two", "test_three" }
        local expected = "test_one\ntest_two\ntest_three"

        grove.fs:write_list(list)
        local saved_list = vim.fn.readfile(list_path)

        assert.are.same(expected, table.concat(saved_list, "\n"))
    end)

    it("should create the history file when it does not exist", function()
        grove.fs:_create_history_file()
        local file = io.open(history_path, "r")
        assert(file)
        local content = file:read("*a")
        file:close()
        assert.are.same("{}", content)
    end)

    it("should load the sessions from the history file", function()
        local projects = {
            ["test.nvim"] = {
                name = "test",
                path = "/tmp/test",
                entrypoint = "/tmp/test/main.lua",
            },
        }
        grove.fs:write_projects(projects)
        local result = grove.fs:load_sessions()

        assert.are.same(projects, result)
    end)

    it(
        "should load an empty list when the list file does not exist, or is empty",
        function()
            local result = grove.fs:load_sessions()
            assert.are.same({}, result)
        end
    )
end)
