local grove = require("grove")

local list_path = vim.fn.stdpath("data") .. "/test_grove_list"
local history_path = vim.fn.stdpath("data") .. "/test_grove_history.json"
local test_list = { "test" }

describe("Buffer", function()
    before_each(function()
        require("plenary.reload").reload_module("harpoon")
        grove = require("grove")
        grove.fs:_configure(history_path, list_path)
        grove.fs:write_list(test_list)
    end)

    after_each(function()
        vim.cmd("silent! !rm -rf " .. list_path)
        vim.cmd("silent! !rm -rf " .. history_path)
    end)

    it("should get the current buffer to store as recover", function()
        local buf = grove.buffer:current_buffer()
        local expect = {
            buf_id = 1,
            is_modified = false,
            is_modifiable = true,
        }

        assert.are.same(expect, buf)
    end)

    it("should open a list buffer", function()
        local buf, win = grove.buffer:open_list(list_path)
        local written = vim.fn.readfile(list_path)
        local current_buf = vim.api.nvim_get_current_buf()

        assert.is_not_nil(buf)
        assert.is_not_nil(win)
        assert.are.same(test_list, written)
        assert.are.same(current_buf, buf)
        assert.is_true(vim.api.nvim_buf_is_valid(buf))
        assert.is_true(vim.api.nvim_win_is_valid(win))
    end)

    it("should close a list buffer", function()
        grove.fs:_configure(history_path, list_path)
        grove.fs:write_list(test_list)
        local buf, win = grove.buffer:open_list(list_path)
        local written = vim.fn.readfile(list_path)
        local buf_before_quit = vim.api.nvim_get_current_buf()

        assert.is_not_nil(buf)
        assert.is_not_nil(win)
        assert.are.same(test_list, written)
        assert.are.same(buf_before_quit, buf)
        assert.is_true(vim.api.nvim_buf_is_valid(buf))
        assert.is_true(vim.api.nvim_win_is_valid(win))

        grove.buffer:close_list(buf)

        assert.is_false(vim.api.nvim_buf_is_valid(buf))
        assert.is_true(vim.api.nvim_win_is_valid(win))
        assert.are.same(test_list, written)
    end)
end)
