local M = {}
_G.__git_check = _G.__git_check or {}

-- Use namespaced keys inside that table
local LAST_FETCH_KEY = 'last_fetch_ts'
local FETCH_INTERVAL = 5 * 60 -- 5 minutes in seconds

local async = require 'plenary.async'
local fidget = require 'fidget'

---@param remote string - branch ref, e.g., `origin/master`; `HEAD`
---@param rel_path string - filepath relative to project root (loc .git)
---@param progress_handle ProgressHandle|nil
---@return string|nil hash, string|nil err
function M.get_git_hash(remote, rel_path, progress_handle)
    assert(remote and rel_path ~= '', 'branch ref/ filepath must not be empty')
    local untracked_case = ("exists on disk, but not in 'HEAD'"):lower()

    local progress_message = function(msg)
        if progress_handle then
            progress_handle:message(msg)
        end
    end

    local git_identifier = string.format('%s:%s', remote, rel_path)

    local job = vim.system({ 'git', 'rev-parse', git_identifier }, { text = true })

    local result = job:wait()
    if result.code ~= 0 then
        if result.stderr and string.find(result.stderr:lower(), untracked_case) then
            progress_message 'file not tracked by local branch'
            return nil, 'untracked'
        end
        print('unknown error retrieving hash for local file.\n', 'stderr', result.stderr)
        return nil, result.stderr or 'unknown error'
    end

    -- strip trailing newline
    local hash = result.stdout:gsub('%s+$', '')

    if hash == '' then
        return nil, 'empty hash'
    end

    return hash
end

---@param callback function|nil
---@return integer -1 when not in repo, else job id
function M.fetch(callback)
    local now = os.time()
    local last = _G.__git_check[LAST_FETCH_KEY] or 0

    if now - last < FETCH_INTERVAL then
        if callback then
            vim.schedule(callback)
        end
        return 0
    end

    _G.__git_check[LAST_FETCH_KEY] = now -- update global state

    if vim.fn.isdirectory '.git' == 0 and vim.fn.finddir('.git', '.;') == '' then
        return -1 -- workspace not git repo
    end
    local handle = fidget.progress.handle.create {
        title = 'Fetching Remote',
        lsp_client = { name = 'git-check' },
    }
    return vim.fn.jobstart({ 'git', 'fetch' }, {
        on_exit = function(_, code)
            vim.schedule(function()
                local is_ok = code == 0
                handle.message = is_ok and 'Fetched from remote' or 'Git fetch failed'
                handle:finish()
                if callback then
                    callback()
                end
            end)
        end,
    })
end

-- vim.api.nvim_create_user_command('GitFetch', M.fetch, {
--     desc = 'Asynchronously run git fetch and show result in a notification.',
--     nargs = 0,
-- })

M.check_remote_changes = async.wrap(function(buf_path)
    local notify = require('fidget').notify

    local progress_handle = require('fidget').progress.handle.create {
        title = 'Comparing Remote Hash',
        lsp_client = { name = 'git-check' },
    }

    -- these two calls now block synchronously within the async.wrap thread
    local local_hash, local_err = M.get_git_hash('HEAD', buf_path, progress_handle)
    local remote_hash, remote_err = M.get_git_hash('origin/master', buf_path, progress_handle)

    if local_err or not local_hash or local_hash == '' then
        print('INVALID getting local hash from get_git_hash for', buf_path, local_err)
        progress_handle:finish()
        return
    end

    if remote_err or not remote_hash or remote_hash == '' then
        print('INVALID getting remote hash from get_git_hash for', buf_path, remote_err)
        progress_handle:finish()
        return
    end

    if local_hash ~= remote_hash then
        notify(string.format('The file "%s" has remote changes. Run :Git pull.', buf_path), vim.log.levels.WARN, { ttl = 8000 })
    end

    progress_handle:finish()
end, 1)

return M
