local GroveState = require("grove.state")

local GroveKeymapper = {}

function GroveKeymapper:_buf_keymap(buf_id, mode, lhs, rhs, opts)
    vim.api.nvim_buf_set_keymap(buf_id, mode, lhs, rhs, opts)
end

function GroveKeymapper:set_keymaps()
    GroveKeymapper:_buf_keymap(
        GroveState.buf_id,
        "n",
        "q",
        "<cmd>lua require('grove'):close_window()<cr>",
        {}
    )
    GroveKeymapper:_buf_keymap(
        GroveState.buf_id,
        "n",
        "<cr>",
        "<cmd>lua require('grove'):switch_project()<cr>",
        {}
    )
end

return GroveKeymapper
