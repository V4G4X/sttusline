local colors = require("sttusline.utils.color")

local function all_trim(s)
    return s:match("^%s*(.-)%s*$")
end

return {
    name = "git-branch",
    event = "BufEnter",
    user_event = { "VeryLazy", "GitSignsUpdate" },
    configs = {
        icon = "",
    },
    colors = { fg = colors.pink },
    space = {
        get_branch = function()
            local file = io.popen('git branch --show-current 2> /dev/null')
            local output = file:read('*a')
            file:close()
            return all_trim(output)
        end,
    },
    update = function(configs, space)
        local branch = space.get_branch()
        return branch ~= "" and configs.icon .. " " .. branch or ""
    end,
    condition = function() return vim.api.nvim_buf_get_option(0, "buflisted") end,
}
