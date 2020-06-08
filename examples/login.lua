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
                        use_test_dc = nil, -- If set to true, the Telegram test environment will be used instead of the production environment.
                        database_directory = "./tdlib-db", -- The path to the directory for the persistent database; if empty, the current working directory will be used.
                        files_directory = nil, -- The path to the directory for storing files; if empty, database_directory will be used.
                        use_file_database = nil, -- If set to true, information about downloaded and uploaded files will be saved between application restarts.
                        use_chat_info_database = nil, -- If set to true, the library will maintain a cache of users, basic groups, supergroups, channels and secret chats. Implies use_file_database.
                        use_message_database = true, -- If set to true, the library will maintain a cache of chats and messages. Implies use_chat_info_database.
                        use_secret_chats = nil, -- If set to true, support for secret chats will be enabled.
                        api_id = appID, -- Application identifier for Telegram API access, which can be obtained at https://my.telegram.org.
                        api_hash = appHash, -- Application identifier hash for Telegram API access, which can be obtained at https://my.telegram.org.
                        system_language_code = "en", -- IETF language tag of the user's operating system language; must be non-empty.
                        device_model = "luajit-tdlua", -- Model of the device the application is being run on; must be non-empty. 
                        system_version = "dev", -- Version of the operating system the application is being run on; must be non-empty.
                        application_version = "0.0.0", -- Application version; must be non-empty.
                        enable_storage_optimizer = true, -- If set to true, old files will automatically be deleted. 
                        ignore_file_names = nil -- If set to true, original file names will be ignored. Otherwise, downloaded files will be saved under names as close as possible to the original name.
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