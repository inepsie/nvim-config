-- Basic keymaps configuration

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror details' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })

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

-- Universal Build System keymaps
vim.keymap.set('n', '<F5>', ':Build<CR>', { desc = 'Build Project' })
vim.keymap.set('n', '<F6>', ':Run<CR>', { desc = 'Run Project' })
vim.keymap.set('n', '<leader>cb', ':Build<CR>', { desc = '[C]ode [B]uild' })
vim.keymap.set('n', '<leader>cr', ':Run<CR>', { desc = '[C]ode [R]un' })
vim.keymap.set('n', '<leader>cT', ':Test<CR>', { desc = '[C]ode [T]est (uppercase)' })
vim.keymap.set('n', '<leader>cx', ':Clean<CR>', { desc = '[C]ode Clean (e[x]tended)' })

-- Quickfix navigation
vim.keymap.set('n', '<leader>co', ':copen<CR>', { desc = 'Open quickfix list' })
vim.keymap.set('n', '<leader>cc', ':cclose<CR>', { desc = 'Close quickfix list' })
vim.keymap.set('n', '<leader>cn', ':cnext<CR>', { desc = 'Next quickfix item' })
vim.keymap.set('n', '<leader>cp', ':cprev<CR>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', '<leader>cf', ':cfirst<CR>', { desc = 'First quickfix item' })
vim.keymap.set('n', '<leader>cz', ':clast<CR>', { desc = 'Last quickfix item (z=end)' })

-- Custom Make command that opens quickfix automatically
vim.api.nvim_create_user_command('Make', function(opts)
  vim.cmd('make ' .. opts.args)
  vim.cmd('cwindow')
end, { nargs = '*' })

-- Universal Build System Commands
local build_system = require('config.build')

-- Create universal build commands
vim.api.nvim_create_user_command('Build', function()
  build_system.build()
end, { desc = 'Build current project (auto-detect)' })

vim.api.nvim_create_user_command('Run', function(opts)
  build_system.run(opts.args)
end, { nargs = '*', desc = 'Run current project (auto-detect)' })

vim.api.nvim_create_user_command('Test', function()
  build_system.test()
end, { desc = 'Test current project (auto-detect)' })

vim.api.nvim_create_user_command('Clean', function()
  build_system.clean()
end, { desc = 'Clean current project (auto-detect)' })

-- Debug command to show detected project type
vim.api.nvim_create_user_command('ProjectInfo', function()
  local root, project_type, build_dir = build_system.detect_project_type()
  if root then
    vim.notify(string.format("Project: %s (%s)\nRoot: %s\nBuild dir: %s",
      project_type, vim.fn.fnamemodify(root, ":t"), root, build_dir or "N/A"), vim.log.levels.INFO)
  else
    -- Show what files are available in current directory
    local cwd = vim.fn.getcwd()
    local c_files = vim.fn.glob("*.c", false, true)
    local cpp_files = vim.fn.glob("*.{cpp,cxx,cc}", false, true)
    local executables = {}
    local files = vim.fn.glob("*", false, true)

    for _, file in ipairs(files) do
      if vim.fn.isdirectory(file) == 0 and vim.fn.executable(file) == 1 then
        table.insert(executables, file)
      end
    end

    local info = "No recognized project type found in " .. cwd .. "\n"
    if #c_files > 0 then
      info = info .. "C files: " .. table.concat(c_files, ", ") .. "\n"
    end
    if #cpp_files > 0 then
      info = info .. "C++ files: " .. table.concat(cpp_files, ", ") .. "\n"
    end
    if #executables > 0 then
      info = info .. "Executables: " .. table.concat(executables, ", ")
    end

    vim.notify(info, vim.log.levels.INFO)
  end
end, { desc = 'Show detected project information' })

-- Quick compile current file command
vim.api.nvim_create_user_command('CompileThis', function()
  local current_file = vim.fn.expand("%:p")
  local ext = vim.fn.expand("%:e")
  local output = vim.fn.expand("%:r")

  if ext == "c" then
    vim.cmd("!gcc -Wall -Wextra -std=c17 -o " .. vim.fn.shellescape(output) .. " " .. vim.fn.shellescape(current_file))
  elseif ext == "cpp" or ext == "cxx" or ext == "cc" then
    vim.cmd("!g++ -Wall -Wextra -std=c++17 -o " .. vim.fn.shellescape(output) .. " " .. vim.fn.shellescape(current_file))
  else
    vim.notify("Cannot compile " .. ext .. " files", vim.log.levels.ERROR)
  end
end, { desc = 'Compile current file directly' })

-- Debug command to list all executable candidates
vim.api.nvim_create_user_command('ListExecutables', function()
  local root, project_type, build_dir = build_system.detect_project_type()
  if not root then
    vim.notify("No project detected", vim.log.levels.WARN)
    return
  end

  local search_dirs = { root }
  if build_dir then
    table.insert(search_dirs, root .. "/" .. build_dir)
    table.insert(search_dirs, root .. "/" .. build_dir .. "/bin")
    table.insert(search_dirs, root .. "/" .. build_dir .. "/Release")
    table.insert(search_dirs, root .. "/" .. build_dir .. "/Debug")
  end

  local candidates = {}
  for _, dir in ipairs(search_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      local files = vim.fn.glob(dir .. "/**/*", false, true)
      for _, file in ipairs(files) do
        if vim.fn.isdirectory(file) == 0 and vim.fn.executable(file) == 1 then
          table.insert(candidates, file)
        end
      end
    end
  end

  if #candidates > 0 then
    vim.notify("Found executables:\n" .. table.concat(candidates, "\n"), vim.log.levels.INFO)
  else
    vim.notify("No executables found in " .. table.concat(search_dirs, ", "), vim.log.levels.WARN)
  end
end, { desc = 'List all executable files in project' })

vim.keymap.set('n', '<leader>mm', function()
  -- Sauvegarder tous les buffers modifiés avant le build
  vim.cmd('silent! wall')
  -- Exécuter la commande Build universelle
  build_system.build()
end, { desc = 'Build with auto save (universal)' })

-- Universal build system with specific targets
vim.keymap.set('n', '<leader>mc', ':Clean<CR>', { desc = '[M]ake [c]lean (universal)' })
vim.keymap.set('n', '<leader>mr', function()
  build_system.build()
  vim.schedule(function()
    build_system.run()
  end)
end, { desc = 'Build then run project (universal)' })
vim.keymap.set('n', '<leader>mt', ':Test<CR>', { desc = '[M]ake [t]est (universal)' })


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

-- Linting keybindings
vim.keymap.set('n', '<leader>cl', ':LintFile<CR>', { desc = '[C]ode [L]int current file' })
vim.keymap.set('n', '<leader>cL', ':LintToggle<CR>', { desc = '[C]ode [L]int toggle auto-linting' })

-- Manual enhanced linting for thorough analysis
vim.keymap.set('n', '<leader>ct', function()
  local lint = require('lint')

  -- Check what linters are available
  if vim.fn.executable('cppcheck') == 1 then
    lint.try_lint({ 'cppcheck' })
    vim.notify('Running cppcheck analysis...', vim.log.levels.INFO)
  elseif vim.fn.executable('gcc') == 1 or vim.fn.executable('g++') == 1 then
    lint.try_lint() -- Use configured gcc/g++ linters
    vim.notify('Running GCC analysis...', vim.log.levels.INFO)
  else
    vim.notify('Aucun linter disponible. Installer cppcheck: sudo apt install cppcheck', vim.log.levels.WARN)
  end
end, { desc = '[C]ode [T]horough analysis' })