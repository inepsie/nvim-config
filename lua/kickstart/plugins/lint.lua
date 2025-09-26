return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- Portable GCC-based linter for C/C++
      lint.linters.gcc_lint = {
        cmd = 'gcc',
        stdin = false,
        args = {
          '-fsyntax-only',
          '-Wall',
          '-Wextra',
          '-Wpedantic',
          '-std=c17',
        },
        stream = 'stderr',
        ignore_exitcode = true,
        parser = function(output)
          local diagnostics = {}
          for line in output:gmatch('[^\r\n]+') do
            local file, row, col, severity, message = line:match('([^:]+):(%d+):(%d+):%s*(%w+):%s*(.+)')
            if file and row and col and severity and message then
              table.insert(diagnostics, {
                lnum = tonumber(row) - 1,
                col = tonumber(col) - 1,
                severity = severity == 'error' and vim.diagnostic.severity.ERROR
                        or severity == 'warning' and vim.diagnostic.severity.WARN
                        or severity == 'note' and vim.diagnostic.severity.INFO
                        or vim.diagnostic.severity.HINT,
                message = message,
                source = 'gcc',
              })
            end
          end
          return diagnostics
        end,
      }

      -- GCC-based linter for C++
      lint.linters.gpp_lint = {
        cmd = 'g++',
        stdin = false,
        args = {
          '-fsyntax-only',
          '-Wall',
          '-Wextra',
          '-Wpedantic',
          '-std=c++17',
        },
        stream = 'stderr',
        ignore_exitcode = true,
        parser = function(output)
          local diagnostics = {}
          for line in output:gmatch('[^\r\n]+') do
            local file, row, col, severity, message = line:match('([^:]+):(%d+):(%d+):%s*(%w+):%s*(.+)')
            if file and row and col and severity and message then
              table.insert(diagnostics, {
                lnum = tonumber(row) - 1,
                col = tonumber(col) - 1,
                severity = severity == 'error' and vim.diagnostic.severity.ERROR
                        or severity == 'warning' and vim.diagnostic.severity.WARN
                        or severity == 'note' and vim.diagnostic.severity.INFO
                        or vim.diagnostic.severity.HINT,
                message = message,
                source = 'g++',
              })
            end
          end
          return diagnostics
        end,
      }

      -- Auto-detect available linters and configure accordingly
      local function setup_linters_by_ft()
        local linters_by_ft = {
          markdown = { 'markdownlint' },
        }

        -- Check for cppcheck (recommended)
        if vim.fn.executable('cppcheck') == 1 then
          linters_by_ft.c = { 'cppcheck' }
          linters_by_ft.cpp = { 'cppcheck' }
          linters_by_ft.cc = { 'cppcheck' }
          linters_by_ft.cxx = { 'cppcheck' }
          vim.notify('Using cppcheck for C/C++ linting', vim.log.levels.INFO)
        -- Try built-in compiler linter (uses makeprg/errorformat)
        elseif vim.fn.executable('gcc') == 1 then
          linters_by_ft.c = { 'gcc_lint' }
          linters_by_ft.cpp = { 'gpp_lint' }
          linters_by_ft.cc = { 'gpp_lint' }
          linters_by_ft.cxx = { 'gpp_lint' }
          vim.notify('Using GCC for C/C++ linting', vim.log.levels.INFO)
        else
          vim.notify('Aucun linter C/C++ trouvé. Installer cppcheck: sudo apt install cppcheck', vim.log.levels.WARN)
        end

        return linters_by_ft
      end

      lint.linters_by_ft = setup_linters_by_ft()

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })

      -- Manual linting function for keybindings
      vim.api.nvim_create_user_command('LintFile', function()
        -- Clear previous message after a short delay
        vim.notify('Linting file...', vim.log.levels.INFO)

        lint.try_lint()

        -- Clear the linting message after 3 seconds
        vim.defer_fn(function()
          vim.notify('', vim.log.levels.INFO) -- Clear notification
        end, 3000)
      end, { desc = 'Run linters on current file' })

      -- Function to toggle automatic linting
      local auto_lint_enabled = true
      vim.api.nvim_create_user_command('LintToggle', function()
        if auto_lint_enabled then
          vim.api.nvim_del_augroup_by_id(lint_augroup)
          auto_lint_enabled = false
          vim.notify('Auto-linting disabled', vim.log.levels.INFO)
        else
          lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
          vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
            group = lint_augroup,
            callback = function()
              if vim.bo.modifiable then
                lint.try_lint()
              end
            end,
          })
          auto_lint_enabled = true
          vim.notify('Auto-linting enabled', vim.log.levels.INFO)
        end
      end, { desc = 'Toggle automatic linting' })
    end,
  },
}
