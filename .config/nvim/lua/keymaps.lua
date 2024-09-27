-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

vim.api.nvim_set_keymap('n', '<leader>rf', ':lua RenameFile("full")<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>rb', ':lua RenameFile("base")<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>re', ':lua RenameFile("ext")<CR>', opts)

function RenameFile(operation)
  local path = vim.fn.expand('%:h')
  local old = vim.fn.expand('%:t')
  local function generate_name(base, ext)
    local parts = {}
    for _, v in ipairs({base, ext}) do
      if v ~= '' then
        table.insert(parts, v)
      end
    end
    return table.concat(parts, '.')
  end
  local function get_input(prompt, default)
    return vim.fn.input(prompt, default)
  end
  local new
  if operation == "full" then
    new = get_input("New full: ", old)
  elseif operation == "base" then
    new = generate_name(get_input("New base: ", vim.fn.expand('%:t:r')), vim.fn.expand('%:e'))
  elseif operation == "ext" then
    new = generate_name(vim.fn.expand('%:t:r'), get_input("New ext: ", vim.fn.expand('%:e')))
  end
  if new ~= old and #new > 0 then
    vim.cmd('saveas ' .. path .. '/' .. new)
    vim.cmd('silent !rm ' .. path .. '/' .. old)
    vim.cmd('bdelete ' .. old)
  end
end

vim.api.nvim_set_keymap('n', '<leader>s', ':e ~/Documents/Obsidian/tmp.md<CR>', opts)
