-- Luacheck configuration for Cosmo terrain generation project
-- See: https://luacheck.readthedocs.io/

-- Standard Lua 5.1 + LuaJIT
std = "luajit"

-- Global variables from Love2d framework
globals = {
    "love"
}

-- Read-only globals
read_globals = {
    "math",
    "table",
    "string",
    "os",
    "io",
    "debug",
    "package",
    "require",
    "assert",
    "error",
    "print",
    "type",
    "tonumber",
    "tostring",
    "pairs",
    "ipairs",
    "next",
    "select",
    "unpack",
    "setmetatable",
    "getmetatable",
    "rawget",
    "rawset",
    "pcall",
    "xpcall",
}

-- Ignore specific warnings
ignore = {
    "212", -- Unused argument
    "213", -- Unused loop variable
    "631", -- Line is too long (we'll let StyLua handle formatting)
}

-- File-specific settings
files["test/**/*.lua"] = {
    -- Allow defining global functions in test files
    ignore = {"111", "112", "113"},
}

-- Maximum line length (optional, StyLua will handle this)
max_line_length = false

-- Maximum code complexity
max_cyclomatic_complexity = 20
