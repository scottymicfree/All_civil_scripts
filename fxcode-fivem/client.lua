RegisterNetEvent("civil_unrest_core:giveWeapon")
AddEventHandler("civil_unrest_core:giveWeapon", function(weapon)
    local ped = PlayerPedId()
    GiveWeaponToPed(ped, GetHashKey(weapon), 100, false, true)
    ShowNotification("Received weapon: " .. weapon)
end)

function ShowNotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(true, false)
end