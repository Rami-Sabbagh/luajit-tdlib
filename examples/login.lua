local tdlib = require("luajit-tdlib")

--The appID, and appHash, obtained from https://my.telegram.org/apps
print("Please input the app id:")
local appID = io.read("*l")
print("= Please input the app hash:")
local appHash = io.read("*l")

print("== Initialize TDLib...")
tdlib.initialize("./libtdjson.so")

print("== Creating a new client...")
local client = tdlib.newClient()

print("== Setting logging level...")
client:execute{
    ["@type"] = "setLogVerbosityLevel",
    new_verbosity_level = 1 --We don't want the logging messages to fill our terminal
}

print("== Listening for responses...")
while true do
    local response = client:receive(10)

    if response then
        local rtype = response["@type"]

        if rtype == "authorizedStateClosed" then
            print("== Exiting...")
            break
        elseif rtype == "error" then
            print("== ERROR:", response.code, response.message)
        elseif rtype == "updateAuthorizationState" then
            local authorizationState = response.authorization_state["@type"]

            if authorizationState == "authorizationStateWaitTdlibParameters" then
                print("- Sending TDLib Parameters")
                client:send{
                    ["@type"] = "setTdlibParameters",
                    parameters = {
                        ["@type"] = "tdlibParameters",
                        use_message_database = true,
                        api_id = appID,
                        api_hash = appHash,
                        system_language_code = "en",
                        device_model = "luajit-tdlua",
                        system_version = "dev",
                        application_version = "0.0.0",
                        enable_storage_optimizer = true,
                        use_pfs = true,
                        database_directory = "./tdlib-db"
                    }
                }
            elseif authorizationState == "authorizationStateWaitEncryptionKey" then
                print("- Sending encryption key")
                client:send{
                    ["@type"] = "checkDatabaseEncryptionKey",
                    encryption_key = "" --No encryption
                }
            elseif authorizationState == "authorizationStateWaitPhoneNumber" then
                print("= Please input the phone number:")
                local phoneNumber = io.read("*l")
                print("Sending phone number")
                client:send{
                    ["@type"] = "setAuthenticationPhoneNumber",
                    phone_number = phoneNumber
                }
            elseif authorizationState == "authorizationStateWaitCode" then
                print("= Please input the authorization code:")
                local code = io.read("*l")
                client:send{
                    ["@type"] = "checkAuthenticationCode",
                    code = code
                }
            elseif authorizationState == "authorizationStateWaitPassword" then
                print("= Please input the authorization password:")
                local password = io.read("*l")
                client:send{
                    ["@type"] = "checkAuthenticationPassword",
                    password = password
                }
            elseif authorizationState == "authorizationStateReady" then
                print("----------------------------------------")
                print("----------------LOGGED IN---------------")
                print("----------------------------------------")
                break
            end

        end
    end
end

print("End of script")