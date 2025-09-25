return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- Custom clang-tidy linter with personal installation path
      lint.linters.clang_tidy_custom = {
        cmd = '/home/e20230004281/clang-format/bin/clang-tidy',
        stdin = false,
        args = {
          '--format-style=file', -- Use .clang-format if available
          '--header-filter=', -- Don't check headers for speed
          '--checks=-*,readability-*,performance-*,bugprone-*,modernize-*', -- Only essential checks
        },
        stream = 'stdout',
        ignore_exitcode = true,
        parser = function(output)
          local diagnostics = {}
          -- Parse clang-tidy output format: file:line:col: severity: message [check-name]
          for line in output:gmatch('[^\r\n]+') do
            local file, row, col, severity, message = line:match('([^:]+):(%d+):(%d+):%s*(%w+):%s*(.+)')
            if file and row and col and severity and message then
              -- Extract check name if present
              local check_name = message:match('%[([^%]]+)%]$')
              if check_name then
                message = message:gsub('%s*%[' .. check_name .. '%]$', '')
              end

              table.insert(diagnostics, {
                lnum = tonumber(row) - 1,
                col = tonumber(col) - 1,
                severity = severity == 'error' and vim.diagnostic.severity.ERROR
                        or severity == 'warning' and vim.diagnostic.severity.WARN
                        or vim.diagnostic.severity.INFO,
                message = message .. (check_name and ' [' .. check_name .. ']' or ''),
                source = 'clang-tidy',
              })
            end
          end
          return diagnostics
        end,
      }

      -- Custom clang linter for comprehensive warnings
      lint.linters.clang_warnings = {
        cmd = '/home/e20230004281/clang-format/bin/clang',
        stdin = false,
        args = {
          '-fsyntax-only',
          '-Wall',
          '-Wextra',
          '-Wpedantic',
          '-Wconversion',
          '-Wshadow',
          '-Wunreachable-code',
          '-std=c++20',
          '--',
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
                source = 'clang',
              })
            end
          end
          return diagnostics
        end,
      }

      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        c = { 'clang_warnings' }, -- Only fast clang warnings for now
        cpp = { 'clang_warnings' },
        cc = { 'clang_warnings' },
        cxx = { 'clang_warnings' },
      }

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
        lint.try_lint()
        vim.notify('Linting file...', vim.log.levels.INFO)
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
