--- TDLib client.
-- @classmod Client

local ffi = require("ffi")
local cjson = require("cjson")
local class = require("middleclass")

local Client = class("luajit-tdlib.Client")

function Client:initialize(clib)
    --- The internal loaded FFI object of tdlib (clib).
    -- @local
    self._clib = clib

    --- The internal void* pointer to the tdlib client (ctype).
    -- @local
    self._client = self._clib.td_json_client_create()

    -- Set the finalizer.
    local client = self._client
    ffi.gc(self._client, function() clib.td_json_client_destroy(client) end)
end

--- Sends a request to the TDLib client.
-- May be called from any thread.
-- @tparam table request The request content (JSON-serialized internally).
-- @raise Error on json encoding failure, or if the client was destroyed.
function Client:send(request)
    if not self._client then return error("The client is destroyed!") end
    request = cjson.encode(request)
    self._clib.td_json_client_send(self._client, request)
end

--- Receives incoming updates and request responses from the TDLib client.
-- May be called from any thread, but shouldn't be called simultaneously from two different threads.
-- @tparam ?number timeout The maximum number of seconds allowed for this function to wait for new data.
-- @treturn ?table The request response, may be `nil` if the timeout expires.
-- @raise Error on json decoding failure, or if the client was destroyed.
function Client:receive(timeout)
    if not self._client then return error("The client is destroyed!") end
    local response = self._clib.td_json_client_receive(self._client, timeout)

    response = ffi.string(response)
    if response == "" then return end
    response = cjson.decode(response)

    return response
end

--- Synchronously executes TDLib request.
-- May be called from any thread.
--
-- Only a few requests can be executed synchronously.
-- @tparam table request The request content (JSON-serialized internally).
-- @treturn table The request response.
-- @raise Error on json en/decoding failure, or if the client was destroyed.
function Client:execute(request)
    if not self._client then return error("The client is destroyed!") end
    request = cjson.encode(request)
    local response = self._clib.td_json_client_execute(self._client, request)

    response = ffi.string(response)
    response = cjson.decode(response)

    return response
end

--- Check if the tdlib client was destroyed or not.
-- @treturn boolean Whether the client was destroyed or not.
function Client:isDestoyed()
    return not self._client
end

--- Destroy the tdlib client, automatically happens in garbage collection.
-- @raise Error if the client was already destroyed.
function Client:destroy()
    if not self._client then return error("The client was already destroyed!") end
    self._client = nil
end

return Client