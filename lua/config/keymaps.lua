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
-- Use CTRL+<hl> to switch between windows (j/k reserved for quickfix)
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })

-- Use C-j/C-k for quickfix navigation instead of window navigation
vim.keymap.set('n', '<C-j>', ':cnext<CR>', { desc = 'Next quickfix item' })
vim.keymap.set('n', '<C-k>', ':cprev<CR>', { desc = 'Previous quickfix item' })

-- Extended window navigation with <leader>w
vim.keymap.set('n', '<leader>wh', '<C-w><C-h>', { desc = 'Fenêtre gauche' })
vim.keymap.set('n', '<leader>wj', '<C-w><C-j>', { desc = 'Fenêtre bas' })
vim.keymap.set('n', '<leader>wk', '<C-w><C-k>', { desc = 'Fenêtre haut' })
vim.keymap.set('n', '<leader>wl', '<C-w><C-l>', { desc = 'Fenêtre droite' })
vim.keymap.set('n', '<leader>ww', '<C-w>w', { desc = 'Fenêtre suivante' })
vim.keymap.set('n', '<leader>wq', '<C-w>q', { desc = 'Fermer fenêtre' })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Split vertical' })
vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = 'Split horizontal' })

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

-- Make with specific targets
vim.keymap.set('n', '<leader>mc', ':Make clean<CR>', { desc = '[M]ake [c]lean' })
vim.keymap.set('n', '<leader>mr', ':Make run<CR>', { desc = '[M]ake [r]un' })
vim.keymap.set('n', '<leader>mt', ':Make test<CR>', { desc = '[M]ake [t]est' })


-- Reload config quickly
vim.keymap.set('n', '<leader>rr', function()
  for name,_ in pairs(package.loaded) do
    if name:match('^plugins') or name:match('^config') or name:match('^custom') or name:match('^kickstart') then
      package.loaded[name] = nil
    end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify("Config rechargée!", vim.log.levels.INFO)
end, { desc = 'Recharger config' })

-- Display messages in a buffer
vim.keymap.set('n', '<leader>qm', function()
  -- Create a new temporary buffer
  vim.cmd('new')
  vim.cmd('setlocal buftype=nofile bufhidden=wipe noswapfile')
  vim.cmd('file Messages')
  -- Get and insert messages
  local messages = vim.fn.execute('messages')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(messages, '\n'))
  -- Make buffer read-only
  vim.bo.readonly = true
  vim.bo.modifiable = false
end, { desc = '[Q]uickfix [M]essages in buffer' })