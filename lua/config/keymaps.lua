-- Basic keymaps configuration

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Tab management
vim.keymap.set('n', '<leader>tc', ':tabclose<CR>', { desc = 'Close current tab' })

-- CMake and Build keymaps
vim.keymap.set('n', '<F5>', ':CMakeBuild<CR>', { desc = 'CMake Build' })
vim.keymap.set('n', '<F6>', ':CMakeRun<CR>', { desc = 'CMake Run' })
vim.keymap.set('n', '<leader>cg', ':CMakeGenerate<CR>', { desc = 'CMake Generate' })
vim.keymap.set('n', '<leader>cb', ':CMakeBuild<CR>', { desc = 'CMake Build' })
vim.keymap.set('n', '<leader>cr', ':CMakeRun<CR>', { desc = 'CMake Run' })
vim.keymap.set('n', '<leader>ct', ':CMakeRunTest<CR>', { desc = 'CMake Run Tests' })

-- Quickfix navigation
vim.keymap.set('n', '<leader>co', ':copen<CR>', { desc = 'Open quickfix list' })
vim.keymap.set('n', '<leader>cc', ':cclose<CR>', { desc = 'Close quickfix list' })
vim.keymap.set('n', '<leader>cn', ':cnext<CR>', { desc = 'Next quickfix item' })
vim.keymap.set('n', '<leader>cp', ':cprev<CR>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', '<leader>cf', ':cfirst<CR>', { desc = 'First quickfix item' })
vim.keymap.set('n', '<leader>cl', ':clast<CR>', { desc = 'Last quickfix item' })

-- Custom Make command that opens quickfix automatically
vim.api.nvim_create_user_command('Make', function(opts)
  vim.cmd('make ' .. opts.args)
  vim.cmd('cwindow')
end, { nargs = '*' })

vim.keymap.set('n', '<leader>m', ':Make<CR>', { desc = 'Make with auto quickfix' })