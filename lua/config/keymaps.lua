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

-- Intelligent Run command that detects CMake projects
vim.api.nvim_create_user_command('Run', function(opts)
  -- Check if we're in a CMake project by looking for CMakeLists.txt
  local function find_cmake_root()
    local path = vim.fn.expand("%:p:h")
    while path ~= "/" do
      if vim.fn.filereadable(path .. "/CMakeLists.txt") == 1 then
        return path
      end
      path = vim.fn.fnamemodify(path, ":h")
    end
    return nil
  end

  local cmake_root = find_cmake_root()
  if cmake_root then
    -- CMake project: try to find and run the executable
    local build_dir = cmake_root .. "/build"
    if vim.fn.isdirectory(build_dir) == 0 then
      print("Build directory not found. Run make first!")
      return
    end

    -- Look for executable in build directory (recursively)
    local function find_executable(dir)
      -- Try common executable locations and patterns
      local patterns = {
        dir .. "/*",           -- Direct in build
        dir .. "/*/",          -- Subdirectories
        dir .. "/*/*",         -- Files in subdirectories
      }

      for _, pattern in ipairs(patterns) do
        local files = vim.fn.glob(pattern, false, true)
        for _, file in ipairs(files) do
          -- Skip directories and common non-executables
          if vim.fn.isdirectory(file) == 0 and
             not file:match("%.o$") and
             not file:match("%.a$") and
             not file:match("%.so$") and
             not file:match("%.cmake$") and
             not file:match("CMakeFiles") and
             not file:match("Makefile") and
             vim.fn.executable(file) == 1 then
            return file
          end
        end
      end
      return nil
    end

    local exe_path = find_executable(build_dir)
    if exe_path then
      print("Running: " .. vim.fn.fnamemodify(exe_path, ":t"))
      -- Run from project root directory for proper relative paths
      local cmd = 'cd ' .. vim.fn.shellescape(cmake_root) .. ' && ' .. vim.fn.shellescape(exe_path)
      if opts.args ~= '' then
        cmd = cmd .. ' ' .. opts.args
      end
      vim.cmd('!' .. cmd)
    else
      print("No executable found in build directory. Available files:")
      local all_files = vim.fn.glob(build_dir .. "/**/*", false, true)
      for i, file in ipairs(all_files) do
        if i <= 5 then -- Show only first 5 files
          print("  " .. vim.fn.fnamemodify(file, ":t"))
        end
      end
    end
  else
    -- Traditional make project: try make run
    vim.cmd('make run ' .. opts.args)
  end
end, { nargs = '*' })

vim.keymap.set('n', '<leader>mm', function()
  -- Sauvegarder tous les buffers modifiés avant le build
  vim.cmd('silent! wall')
  -- Exécuter la commande Make
  vim.cmd('Make')
end, { desc = 'Make with auto save and quickfix' })

-- Make with specific targets
vim.keymap.set('n', '<leader>mc', ':Make clean<CR>', { desc = '[M]ake [c]lean' })
vim.keymap.set('n', '<leader>mr', function()
  vim.cmd('Make')
  vim.schedule(function()
    vim.cmd('Run')
  end)
end, { desc = 'Make then run project executable' })
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