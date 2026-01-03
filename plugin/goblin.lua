
if vim.g.loaded_goblin then
	return
end

vim.g.loaded_goblin = true

require("goblin").setup()
