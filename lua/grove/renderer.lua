local state = require("grove.state")

local M = {}

M.render_current_directory = function()
    vim.bo[state.buffer_id].modifiable = true
    vim.api.nvim_buf_set_lines(
        state.buffer_id,
        0,
        -1,
        true,
        state.current_directory
    )
    vim.bo[state.buffer_id].modifiable = true
end

return M
