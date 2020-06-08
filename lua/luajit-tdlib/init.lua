--- A LuaJIT FFI binding for Telegram's Database Library (TDLib)'s JSON interface.
-- @module luajit-tdlib
-- @alias tdlib

local ffi = require("ffi")
local Client = require("luajit-tdlib.Client")

local tdlib = {}

--- The loaded FFI object of tdlib (clib or nil).
-- @local
-- @field _clib

--- Initializes the TDLib library, must be done before creating any client instances.
-- @tparam ?string libPath The path into the TDLib shared library, defaults to `./libtdjson.so`.
-- @raise Error on library loading failure.
-- @usage local tdlib = require("luajit-tdlib")
--tdlib.initialize("./libtdjson.so")
function tdlib.initialize(libPath)
    if tdlib._clib then return error("tdlib has been already initialized!") end

    ffi.cdef[[
        void * td_json_client_create();
        void td_json_client_send(void *client, const char *request);
        const char * td_json_client_receive(void *client, double timeout);
        const char * td_json_client_execute(void *client, const char *request);
        void td_json_client_destroy(void *client);
    ]]

    tdlib._clib = ffi.load(libPath or "./libtdjson.so")
end

--- Creates a new instance of TDLib.
-- @treturn Client The created instance of TDLib.
-- @raise Error if tdlib was not initialized.
-- @usage local tdlib = require("luajit-tdlib")
-- tdlib.initialize("./libtdjson.so")
-- local client = tdlib.newClient()
-- client:destroy()
function tdlib.newClient()
    if not tdlib._clib then return error("tdlib has not been initialized yet!") end
    return Client(tdlib._clib)
end

return tdlib