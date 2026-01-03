-- lua/goblin/init.lua
local M = {}
local timer = require("goblin.htimer")

function M.setup(opts)
  opts = opts or {}

  vim.api.nvim_create_user_command("Goblin.HydarationStart", function()
    timer.start()
  end, {})

  vim.api.nvim_create_user_command("Goblin.HydarationStop", function()
    timer.stop()
  end, {})

end

return M
