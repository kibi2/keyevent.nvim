local M = {}

local default_config = {
    threshold = {
        delta = 10,
        interval = 83,
        delay = 500,
        tap = 500,
    }
}

function M.setup(opts)
    local config =
        vim.tbl_deep_extend("force", vim.deepcopy(default_config), opts or {})
    for key, value in pairs(config) do
        M[key] = value
    end
end

return M
