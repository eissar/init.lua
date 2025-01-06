local iron = require("iron.core")

iron.setup {
    config = {
        -- Whether a repl should be discarded or not
        scratch_repl = true,
        -- Your repl definitions come here
        repl_definition = {
            ps1 = {
                -- Can be a table or a function that returns a table (see below)
                command = {"pwsh.exe"}
            },
            python = {
                command = { "python3" },  -- or { "ipython", "--no-autoindent" }
                --format = require("iron.fts.common").bracketed_paste_python
            }
        },
        -- How the repl window will be displayed
        -- See below for more information
        --repl_open_cmd = require('iron.view').bottom(40),
    },
}
