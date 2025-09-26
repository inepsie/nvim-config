-- Universal Build System for Neovim
-- Auto-detects project type and provides generic build commands

local M = {}

-- Project type detection
function M.detect_project_type()
  local cwd = vim.fn.getcwd()

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

  return find_project_root(cwd)
end

-- Generic build command
function M.build()
  local root, project_type, build_dir = M.detect_project_type()

  if not root then
    vim.notify("No recognized project type found. Using 'make'", vim.log.levels.WARN)
    vim.cmd("make")
    return
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
    vim.notify("No recognized project type found", vim.log.levels.WARN)
    return
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
  end

  for _, dir in ipairs(search_dirs) do
    local files = vim.fn.glob(dir .. "/*", false, true)
    for _, file in ipairs(files) do
      if vim.fn.isdirectory(file) == 0 and
         vim.fn.executable(file) == 1 and
         not file:match("%.o$") and
         not file:match("%.so$") and
         not file:match("%.a$") then
        local cmd = string.format("cd %s && %s %s", vim.fn.shellescape(root), vim.fn.shellescape(file), args)
        vim.cmd("!" .. cmd)
        return
      end
    end
  end

  vim.notify("No executable found in " .. root, vim.log.levels.WARN)
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