local renderer = require("grove.renderer")
local state = require("grove.state")

local M = {}

M.open_window = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local bufdir = vim.fn.fnamemodify(bufname, ":h")
    local files = vim.fn.readdir(bufdir)

    state.current_directory = {}
    for i, file in ipairs(files) do
        state.current_directory[i] = file
    end

    state.buffer_id = vim.api.nvim_get_current_buf()
    state.buffer_lines =
        vim.api.nvim_buf_get_lines(state.buffer_id, 0, -1, true)

    renderer.render_current_directory()
end

M.close_window = function()
    vim.bo[state.buffer_id].modifiable = true
    vim.api.nvim_buf_set_lines(state.buffer_id, 0, -1, true, state.buffer_lines)
end

M.setup = function()
    vim.keymap.set(
        "n",
        "<leader><leader>=",
        "<cmd>lua require('grove').open_window()<cr>"
    )
    vim.keymap.set(
        "n",
        "<leader><leader>-",
        "<cmd>lua require('grove').close_window()<cr>"
    )
    vim.keymap.set("n", "<leader><leader>r", "<cmd>lua R('grove')<cr>")
end

M.setup()
M.open_window()
M.close_window()

return M
