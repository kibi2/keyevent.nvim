local log = require("keyevent.log")

local M = {}

local function find_tool()
    for _, root in ipairs(vim.api.nvim_list_runtime_paths()) do
        local path = root .. "/tools/macos/keyevent-macos"
        if vim.uv.fs_stat(path) then
            return path
        end
    end
end

---@return table|nil
local function get_mac_prefs()
    local path = find_tool()
    if not path then
        return
    end
    local result = vim.system({ path }):wait()
    if result.code ~= 0 then
        return
    end
    local ok, data = pcall(vim.json.decode, result.stdout)
    if ok then
        return data
    end
end

---@return table|nil
local function get_win_prefs()
    return
end

---@return table|nil
local function get_linux_prefs()
    return
end

local function get_os_prefs()
    if vim.fn.has("mac") == 1 then
        return get_mac_prefs()
    elseif vim.fn.has("win32") == 1 then
        return get_win_prefs()
    elseif vim.fn.has("unix") == 1 then
        return get_linux_prefs()
    end
end

function M.setup()
    local prefs = get_os_prefs()
    if prefs then
        M.delay = prefs.delay
        M.interval = prefs.interval
    end
    log.probe("delay = " .. (M.delay or "nil"))
    log.probe("interval = " .. (M.interval or "nil"))
end

return M
