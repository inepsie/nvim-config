-- Autocommands configuration

-- Fix for nvim-cmp LSP buffer error
vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
  pattern = "*",
  callback = function(args)
    -- Ensure we have a valid buffer number
    if not args.buf or type(args.buf) ~= "number" then
      return
    end
    -- Only proceed if buffer is valid and loaded
    if not vim.api.nvim_buf_is_valid(args.buf) or not vim.api.nvim_buf_is_loaded(args.buf) then
      return
    end
  end,
  desc = "Prevent LSP buffer errors in cmp"
})

-- Automatically open quickfix window after quickfix commands
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "[^l]*",
  nested = true,
  callback = function()
    vim.cmd("cwindow")
  end,
  desc = "Auto-open quickfix window after quickfix commands"
})

-- Automatically open location list window after location list commands
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "l*",
  nested = true,
  callback = function()
    vim.cmd("lwindow")
  end,
  desc = "Auto-open location list window after location list commands"
})

-- Close quickfix and location list with q
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf" },
  callback = function()
    vim.keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true })
  end,
  desc = "Close quickfix/location list with q"
})

-- Improved errorformat for C/C++ with gcc/clang
-- Using vim.cmd to avoid vim.opt.errorformat:prepend() bug
vim.cmd('set errorformat+=%f:%l:%c:\\ %trror:\\ %m')      -- gcc/clang format with column
vim.cmd('set errorformat+=%f:%l:%c:\\ %tarning:\\ %m')    -- warnings with column
vim.cmd('set errorformat+=%f:%l:%c:\\ %tote:\\ %m')       -- notes with column
vim.cmd('set errorformat+=%f:%l:\\ %trror:\\ %m')         -- format without column
vim.cmd('set errorformat+=%f:%l:\\ %tarning:\\ %m')       -- warnings without column
vim.cmd('set errorformat+=make:\\ ***\\ %m')              -- make errors
vim.cmd('set errorformat+=ld:\\ %m')                      -- linker errors

-- Set makeprg for CMake projects
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
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
      local build_dir = cmake_root .. "/build"
      -- Create build directory if it doesn't exist
      if vim.fn.isdirectory(build_dir) == 0 then
        vim.fn.mkdir(build_dir, "p")
      end
      -- Set makeprg to cmake build
      vim.opt_local.makeprg = "cmake --build " .. build_dir
    end
  end,
  desc = "Auto-configure makeprg for CMake projects"
})