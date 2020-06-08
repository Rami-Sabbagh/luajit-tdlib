package = "luajit-tdlib"
version = "scm-0"
source = {
    url = "git+https://github.com/RamiLego4Game/luajit-tdlib.git"
}
description = {
    summary = "A LuaJIT FFI binding for Telegram's Database Library (TDLib)'s JSON interface.",
    detailed = [[
        A LuaJIT FFI binding for Telegram's Database Library (TDLib)'s JSON interface.
    ]],
    homepage = "https://ramilego4game.github.io/luajit-tdlib",
    license = "MIT"
}
dependencies = {
    "lua = 5.1",
    "middleclass >= 4.1.1, < 5.0.0",
    "lua-cjson >= 2.1.0, < 3.0.0"
}
build = {
    type = "builtin",
    modules = {},
    copy_directories = {"docs"}
}