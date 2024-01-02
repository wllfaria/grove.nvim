local grove = require("grove")

describe("Buffer", function()
    before_each(function()
        require("plenary.reload").reload_module("harpoon")
        grove = require("grove")
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
        local list = { "test" }
        -- the file must exists for the buffer to open
        grove.fs:write_list(list)
        local buf, win = grove.buffer:open_list()
        local written = vim.fn.readfile(vim.fn.stdpath("data") .. "/grove_list")

        assert.is_not_nil(buf)
        assert.is_not_nil(win)
        assert.are.same(list, written)
    end)

    it("should close a list buffer", function()
        local list = { "test" }
        grove.fs:write_list(list)
        local buf, win = grove.buffer:open_list()
        local written = vim.fn.readfile(vim.fn.stdpath("data") .. "/grove_list")

        assert.is_not_nil(buf)
        assert.is_not_nil(win)
        assert.are.same(list, written)

        grove.buffer:close_list(buf)

        print(vim.api.nvim_buf_is_valid(buf))
        assert.is_false(vim.api.nvim_buf_is_valid(buf))
        assert.is_false(vim.api.nvim_win_is_valid(buf))
    end)
end)
