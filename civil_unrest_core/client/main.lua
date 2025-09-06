-- civil_unrest_core/client/main.lua
print("[civil_unrest_core] Client loaded.")

local hasSpawned = false

-- Trigger server-side setup after player has fully loaded
AddEventHandler("playerSpawned", function()
    if not hasSpawned then
        hasSpawned = true
        TriggerServerEvent("civil_unrest_core:playerReady")
        print("[civil_unrest_core] Player ready triggered.")
    end
end)

-- Welcome event from server
RegisterNetEvent("civil_unrest_core:welcome")
AddEventHandler("civil_unrest_core:welcome", function(data)
    local msg = data.message or "Welcome to Civil Unrest RP."
    print("[civil_unrest_core] Server:", msg)
    TriggerEvent("fxcode:utils:notify", msg, "success")
end)

-- Sync state
RegisterNetEvent("civil_unrest_core:syncState")
AddEventHandler("civil_unrest_core:syncState", function(state)
    print("[civil_unrest_core] Synced state:", json.encode(state))
end)

-- Reset on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
    hasSpawned = false
    print("[civil_unrest_core] Client reset due to resource stop")
    end
end)