-- Universal Build System for Neovim
-- Auto-detects project type and provides generic build commands

local M = {}

-- Project type detection
function M.detect_project_type()
  -- Start from current working directory, not the current file
  local cwd = vim.fn.getcwd()

  -- If we're editing a file, also try from the file's directory
  local current_file = vim.fn.expand("%:p")
  local file_dir = current_file ~= "" and vim.fn.fnamemodify(current_file, ":h") or nil

  -- Check for various project files in order of preference
  local project_files = {
    { file = "CMakeLists.txt", type = "cmake", build_dir = "build" },
    { file = "Makefile", type = "make", build_dir = nil },
    { file = "build.ninja", type = "ninja", build_dir = nil },
    { file = "meson.build", type = "meson", build_dir = "build" },
    { file = "Cargo.toml", type = "cargo", build_dir = "target" },
    { file = "package.json", type = "npm", build_dir = "node_modules" },
    { file = "build.gradle", type = "gradle", build_dir = "build" },
    { file = "pom.xml", type = "maven", build_dir = "target" },
  }

  -- Walk up the directory tree to find project root
  local function find_project_root(start_path)
    local path = start_path
    while path ~= "/" do
      for _, project in ipairs(project_files) do
        if vim.fn.filereadable(path .. "/" .. project.file) == 1 then
          return path, project.type, project.build_dir
        end
      end
      path = vim.fn.fnamemodify(path, ":h")
    end
    return nil, "unknown", nil
  end

  -- Try current working directory first
  local root, ptype, bdir = find_project_root(cwd)
  if root then
    return root, ptype, bdir
  end

  -- If not found and we have a file open, try from file's directory
  if file_dir and file_dir ~= cwd then
    return find_project_root(file_dir)
  end

  return nil, "unknown", nil
end

-- Generic build command
function M.build()
  local root, project_type, build_dir = M.detect_project_type()

  if not root then
    -- Try to detect C/C++ files and build them directly
    local c_files = vim.fn.glob("*.c", false, true)
    local cpp_files = vim.fn.glob("*.{cpp,cxx,cc}", false, true)

    if #c_files > 0 then
      vim.notify("Building C files with gcc...", vim.log.levels.INFO)
      vim.cmd("!gcc -Wall -Wextra -std=c17 -o main " .. table.concat(c_files, " "))
      return
    elseif #cpp_files > 0 then
      vim.notify("Building C++ files with g++...", vim.log.levels.INFO)
      vim.cmd("!g++ -Wall -Wextra -std=c++17 -o main " .. table.concat(cpp_files, " "))
      return
    else
      vim.notify("No recognized project type found. Trying 'make'...", vim.log.levels.WARN)
      vim.cmd("make")
      return
    end
  end

  vim.notify("Building " .. project_type .. " project...", vim.log.levels.INFO)

  local commands = {
    cmake = function()
      -- Use cmake-tools plugin if available and loaded
      if vim.fn.exists(':CMakeBuild') == 2 then
        vim.cmd('CMakeBuild')
      else
        -- Fallback to direct cmake commands
        local build_path = root .. "/" .. (build_dir or "build")
        if vim.fn.isdirectory(build_path) == 0 then
          vim.fn.mkdir(build_path, "p")
          vim.cmd("!" .. string.format("cd %s && cmake -B %s", vim.fn.shellescape(root), vim.fn.shellescape(build_path)))
        end
        vim.cmd("!" .. string.format("cmake --build %s", vim.fn.shellescape(build_path)))
      end
    end,

    make = function()
      vim.cmd("make")
    end,

    ninja = function()
      vim.cmd("!ninja")
    end,

    meson = function()
      local build_path = root .. "/" .. (build_dir or "build")
      if vim.fn.isdirectory(build_path) == 0 then
        vim.cmd("!" .. string.format("cd %s && meson setup %s", vim.fn.shellescape(root), vim.fn.shellescape(build_path)))
      end
      vim.cmd("!" .. string.format("cd %s && meson compile", vim.fn.shellescape(build_path)))
    end,

    cargo = function()
      vim.cmd("!cargo build")
    end,

    npm = function()
      vim.cmd("!npm run build")
    end,

    gradle = function()
      vim.cmd("!./gradlew build")
    end,

    maven = function()
      vim.cmd("!mvn compile")
    end,
  }

  local build_fn = commands[project_type]
  if build_fn then
    -- Save all modified buffers before building
    vim.cmd('silent! wall')
    build_fn()
    vim.cmd('cwindow') -- Open quickfix if there are errors
  else
    vim.notify("Don't know how to build " .. project_type .. " projects", vim.log.levels.ERROR)
  end
end

-- Generic run command
function M.run(args)
  local root, project_type, build_dir = M.detect_project_type()

  if not root then
    -- Try to find and run executables in current directory
    local executables = {}
    local files = vim.fn.glob("*", false, true)

    for _, file in ipairs(files) do
      if vim.fn.isdirectory(file) == 0 and vim.fn.executable(file) == 1 then
        table.insert(executables, file)
      end
    end

    if #executables > 0 then
      -- Run the first executable found, or main if it exists
      local exec_to_run = "main"
      if vim.fn.executable("main") == 0 then
        exec_to_run = executables[1]
      end
      vim.notify("Running " .. exec_to_run .. "...", vim.log.levels.INFO)
      vim.cmd("!" .. vim.fn.shellescape(exec_to_run) .. " " .. (args or ""))
      return
    else
      -- Try to compile and run the current file if it's C/C++
      local current_file = vim.fn.expand("%:p")
      local ext = vim.fn.expand("%:e")

      if ext == "c" then
        vim.notify("Compiling and running C file...", vim.log.levels.INFO)
        local output = vim.fn.expand("%:r")
        vim.cmd("!gcc -Wall -Wextra -std=c17 -o " .. vim.fn.shellescape(output) .. " " .. vim.fn.shellescape(current_file) .. " && " .. vim.fn.shellescape(output) .. " " .. (args or ""))
        return
      elseif ext == "cpp" or ext == "cxx" or ext == "cc" then
        vim.notify("Compiling and running C++ file...", vim.log.levels.INFO)
        local output = vim.fn.expand("%:r")
        vim.cmd("!g++ -Wall -Wextra -std=c++17 -o " .. vim.fn.shellescape(output) .. " " .. vim.fn.shellescape(current_file) .. " && " .. vim.fn.shellescape(output) .. " " .. (args or ""))
        return
      end

      vim.notify("No recognized project type or executable found", vim.log.levels.WARN)
      return
    end
  end

  args = args or ""
  vim.notify("Running " .. project_type .. " project...", vim.log.levels.INFO)

  local commands = {
    cmake = function()
      if vim.fn.exists(':CMakeRun') == 2 then
        vim.cmd('CMakeRun')
      else
        -- Fallback: find executable in build directory
        M.find_and_run_executable(root, build_dir, args)
      end
    end,

    make = function()
      -- Try common make targets
      local targets = {"run", "test", ""}
      for _, target in ipairs(targets) do
        if vim.fn.system("make -q " .. target):find("No rule") == nil then
          vim.cmd("!make " .. target .. " " .. args)
          return
        end
      end
      -- Fallback: find executable
      M.find_and_run_executable(root, nil, args)
    end,

    ninja = function()
      M.find_and_run_executable(root, nil, args)
    end,

    meson = function()
      vim.cmd("!" .. string.format("cd %s && meson test", vim.fn.shellescape(root .. "/" .. build_dir)))
    end,

    cargo = function()
      vim.cmd("!cargo run " .. args)
    end,

    npm = function()
      vim.cmd("!npm start " .. args)
    end,

    gradle = function()
      vim.cmd("!./gradlew run " .. args)
    end,

    maven = function()
      vim.cmd("!mvn exec:java " .. args)
    end,
  }

  local run_fn = commands[project_type]
  if run_fn then
    run_fn()
  else
    vim.notify("Don't know how to run " .. project_type .. " projects", vim.log.levels.ERROR)
  end
end

-- Find and run executable (helper function)
function M.find_and_run_executable(root, build_subdir, args)
  local search_dirs = { root }
  if build_subdir then
    table.insert(search_dirs, root .. "/" .. build_subdir)
    -- Also search in common subdirectories of build
    table.insert(search_dirs, root .. "/" .. build_subdir .. "/bin")
    table.insert(search_dirs, root .. "/" .. build_subdir .. "/Release")
    table.insert(search_dirs, root .. "/" .. build_subdir .. "/Debug")
  end

  local candidates = {}

  for _, dir in ipairs(search_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      -- Search recursively in directory
      local files = vim.fn.glob(dir .. "/**/*", false, true)
      for _, file in ipairs(files) do
        if vim.fn.isdirectory(file) == 0 and
           vim.fn.executable(file) == 1 and
           not file:match("%.o$") and
           not file:match("%.so$") and
           not file:match("%.a$") and
           not file:match("%.cmake$") and
           not file:match("CMakeFiles") and
           not file:match("%.git/") and
           not file:match("_deps/") and -- Ignore dependencies
           not file:match("%.sh$") and -- Ignore shell scripts
           not file:match("%.exe$") and -- Ignore Windows executables
           not file:match("/hooks/") then -- Ignore git hooks

          local filename = vim.fn.fnamemodify(file, ":t")
          local priority = 0

          -- Prioritize executables with project-like names
          if filename:match("main") or filename:match("app") then
            priority = 100
          elseif filename:match(vim.fn.fnamemodify(root, ":t")) then
            priority = 90 -- Match project directory name
          elseif not filename:match("test") and not filename:match("sample") then
            priority = 50 -- Non-test executables
          end

          table.insert(candidates, { file = file, priority = priority, name = filename })
        end
      end
    end
  end

  -- Sort by priority (highest first)
  table.sort(candidates, function(a, b) return a.priority > b.priority end)

  if #candidates > 0 then
    local best = candidates[1]
    local cmd = string.format("cd %s && %s %s", vim.fn.shellescape(root), vim.fn.shellescape(best.file), args or "")
    vim.notify("Running: " .. best.name .. " (priority: " .. best.priority .. ")", vim.log.levels.INFO)
    vim.cmd("!" .. cmd)
    return
  end

  vim.notify("No suitable executable found in " .. root .. " (searched: " .. table.concat(search_dirs, ", ") .. ")", vim.log.levels.WARN)
end

-- Generic test command
function M.test()
  local root, project_type, build_dir = M.detect_project_type()

  if not root then
    vim.notify("No recognized project type found", vim.log.levels.WARN)
    return
  end

  vim.notify("Running " .. project_type .. " tests...", vim.log.levels.INFO)

  local commands = {
    cmake = function()
      if vim.fn.exists(':CMakeRunTest') == 2 then
        vim.cmd('CMakeRunTest')
      else
        local build_path = root .. "/" .. (build_dir or "build")
        vim.cmd("!" .. string.format("cd %s && ctest", vim.fn.shellescape(build_path)))
      end
    end,

    make = function()
      vim.cmd("!make test")
    end,

    cargo = function()
      vim.cmd("!cargo test")
    end,

    npm = function()
      vim.cmd("!npm test")
    end,

    gradle = function()
      vim.cmd("!./gradlew test")
    end,

    maven = function()
      vim.cmd("!mvn test")
    end,
  }

  local test_fn = commands[project_type] or function()
    vim.notify("Don't know how to test " .. project_type .. " projects", vim.log.levels.WARN)
  end

  test_fn()
  vim.cmd('cwindow')
end

-- Generic clean command
function M.clean()
  local root, project_type, build_dir = M.detect_project_type()

  if not root then
    vim.notify("No recognized project type found", vim.log.levels.WARN)
    return
  end

  vim.notify("Cleaning " .. project_type .. " project...", vim.log.levels.INFO)

  local commands = {
    cmake = function()
      local build_path = root .. "/" .. (build_dir or "build")
      if vim.fn.isdirectory(build_path) == 1 then
        vim.cmd("!" .. string.format("rm -rf %s", vim.fn.shellescape(build_path)))
      end
    end,

    make = function()
      vim.cmd("!make clean")
    end,

    ninja = function()
      vim.cmd("!ninja -t clean")
    end,

    cargo = function()
      vim.cmd("!cargo clean")
    end,

    npm = function()
      vim.cmd("!npm run clean")
    end,

    gradle = function()
      vim.cmd("!./gradlew clean")
    end,

    maven = function()
      vim.cmd("!mvn clean")
    end,
  }

  local clean_fn = commands[project_type] or function()
    vim.notify("Don't know how to clean " .. project_type .. " projects", vim.log.levels.WARN)
  end

  clean_fn()
end

return M