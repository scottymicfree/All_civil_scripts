-- NPC Full Time Logic Script
-- This script manages NPC behavior and schedules

-- Configuration
local Config = {
    -- NPC types and their schedules
    NPCTypes = {
        police = {
            models = {
                "s_m_y_cop_01",
                "s_f_y_cop_01",
                "s_m_y_hwaycop_01"
            },
            schedules = {
                {
                    timeStart = 6, -- 6 AM
                    timeEnd = 14, -- 2 PM
                    activities = {
                        {
                            type = "patrol",
                            duration = 45, -- minutes
                            locations = {
                                { coords = vector3(426.1, -979.5, 30.7), radius = 100.0 }, -- Mission Row PD
                                { coords = vector3(-1095.02, -836.14, 19.0), radius = 100.0 } -- Vespucci PD
                            }
                        },
                        {
                            type = "break",
                            duration = 15, -- minutes
                            locations = {
                                { coords = vector3(443.4, -981.9, 30.7), radius = 5.0 }, -- Mission Row PD Break Room
                                { coords = vector3(-1090.0, -840.0, 19.0), radius = 5.0 } -- Vespucci PD Break Room
                            }
                        }
                    }
                },
                {
                    timeStart = 14, -- 2 PM
                    timeEnd = 22, -- 10 PM
                    activities = {
                        {
                            type = "patrol",
                            duration = 45, -- minutes
                            locations = {
                                { coords = vector3(300.0, -900.0, 29.0), radius = 200.0 }, -- Downtown
                                { coords = vector3(-1300.0, -1200.0, 4.0), radius = 200.0 } -- Vespucci Beach
                            }
                        },
                        {
                            type = "break",
                            duration = 15, -- minutes
                            locations = {
                                { coords = vector3(443.4, -981.9, 30.7), radius = 5.0 }, -- Mission Row PD Break Room
                                { coords = vector3(-1090.0, -840.0, 19.0), radius = 5.0 } -- Vespucci PD Break Room
                            }
                        }
                    }
                },
                {
                    timeStart = 22, -- 10 PM
                    timeEnd = 6, -- 6 AM
                    activities = {
                        {
                            type = "patrol",
                            duration = 45, -- minutes
                            locations = {
                                { coords = vector3(200.0, -800.0, 30.0), radius = 150.0 }, -- Night Patrol Area 1
                                { coords = vector3(-1100.0, -1400.0, 5.0), radius = 150.0 } -- Night Patrol Area 2
                            }
                        },
                        {
                            type = "break",
                            duration = 15, -- minutes
                            locations = {
                                { coords = vector3(443.4, -981.9, 30.7), radius = 5.0 }, -- Mission Row PD Break Room
                                { coords = vector3(-1090.0, -840.0, 19.0), radius = 5.0 } -- Vespucci PD Break Room
                            }
                        }
                    }
                }
            }
        },
        ems = {
            models = {
                "s_m_m_paramedic_01",
                "s_f_y_scrubs_01"
            },
            schedules = {
                {
                    timeStart = 7, -- 7 AM
                    timeEnd = 15, -- 3 PM
                    activities = {
                        {
                            type = "work",
                            duration = 50, -- minutes
                            locations = {
                                { coords = vector3(307.4, -595.3, 43.3), radius = 90.0 }, -- Pillbox Hill Medical
                                { coords = vector3(1839.6, 3672.93, 34.28), radius = 40.0 } -- Sandy Shores Medical
                            }
                        },
                        {
                            type = "work",
                            duration = 10, -- minutes
                            locations = {
                                { coords = vector3(309.0, -590.0, 43.3), radius = 5.0 }, -- Pillbox Hill Break Room
                                { coords = vector3(1835.0, 3675.0, 34.28), radius = 5.0 } -- Sandy Shores Break Room
                            }
                        }
                    }
                },
                {
                    timeStart = 15, -- 3 PM
                    timeEnd = 23, -- 11 PM
                    activities = {
                        {
                            type = "work",
                            duration = 50, -- minutes
                            locations = {
                                { coords = vector3(307.4, -595.3, 43.3), radius = 90.0 }, -- Pillbox Hill Medical
                                { coords = vector3(1839.6, 3672.93, 34.28), radius = 40.0 } -- Sandy Shores Medical
                            }
                        },
                        {
                            type = "work",
                            duration = 10, -- minutes
                            locations = {
                                { coords = vector3(309.0, -590.0, 43.3), radius = 5.0 }, -- Pillbox Hill Break Room
                                { coords = vector3(1835.0, 3675.0, 34.28), radius = 5.0 } -- Sandy Shores Break Room
                            }
                        }
                    }
                },
                {
                    timeStart = 23, -- 11 PM
                    timeEnd = 7, -- 7 AM
                    activities = {
                        {
                            type = "work",
                            duration = 50, -- minutes
                            locations = {
                                { coords = vector3(307.4, -595.3, 43.3), radius = 90.0 }, -- Pillbox Hill Medical
                                { coords = vector3(1839.6, 3672.93, 34.28), radius = 40.0 } -- Sandy Shores Medical
                            }
                        },
                        {
                            type = "work",
                            duration = 10, -- minutes
                            locations = {
                                { coords = vector3(309.0, -590.0, 43.3), radius = 5.0 }, -- Pillbox Hill Break Room
                                { coords = vector3(1835.0, 3675.0, 34.28), radius = 5.0 } -- Sandy Shores Break Room
                            }
                        }
                    }
                }
            }
        },
        fire = {
            models = {
                "s_m_y_fireman_01"
            },
            schedules = {
                {
                    timeStart = 8, -- 8 AM
                    timeEnd = 20, -- 8 PM
                    activities = {
                        {
                            type = "work",
                            duration = 55, -- minutes
                            locations = {
                                { coords = vector3(-701.37, -148.97, 37.49), radius = 80.0 }, -- Davis Fire Station
                                { coords = vector3(277.62, -1632.74, 29.29), radius = 80.0 } -- South LS Fire Station
                            }
                        },
                        {
                            type = "break",
                            duration = 5, -- minutes
                            locations = {
                                { coords = vector3(-700.0, -145.0, 37.49), radius = 5.0 }, -- Davis Fire Station Break Room
                                { coords = vector3(275.0, -1630.0, 29.29), radius = 5.0 } -- South LS Fire Station Break Room
                            }
                        }
                    }
                },
                {
                    timeStart = 20, -- 8 PM
                    timeEnd = 8, -- 8 AM
                    activities = {
                        {
                            type = "work",
                            duration = 55, -- minutes
                            locations = {
                                { coords = vector3(-701.37, -148.97, 37.49), radius = 80.0 }, -- Davis Fire Station
                                { coords = vector3(277.62, -1632.74, 29.29), radius = 80.0 } -- South LS Fire Station
                            }
                        },
                        {
                            type = "break",
                            duration = 5, -- minutes
                            locations = {
                                { coords = vector3(-700.0, -145.0, 37.49), radius = 5.0 }, -- Davis Fire Station Break Room
                                { coords = vector3(275.0, -1630.0, 29.29), radius = 5.0 } -- South LS Fire Station Break Room
                            }
                        }
                    }
                }
            }
        },
        gang = {
            models = {
                "g_m_y_lost_03",
                "g_m_m_mexboss_01",
                "g_f_y_vagos_01"
            },
            schedules = {
                {
                    timeStart = 12, -- 12 PM
                    timeEnd = 4, -- 4 AM
                    activities = {
                        {
                            type = "hangout",
                            duration = 120, -- minutes
                            locations = {
                                { coords = vector3(966.45, -123.77, 74.35), radius = 50.0 }, -- Biker Gang Area
                                { coords = vector3(-1154.32, -2022.88, 13.18), radius = 50.0 }, -- Cartel Area
                                { coords = vector3(342.12, -871.53, 28.29), radius = 50.0 }, -- Divine Gang Area
                                { coords = vector3(-578.31, -1058.17, 22.35), radius = 50.0 } -- Queens Gang Area
                            }
                        },
                        {
                            type = "patrol",
                            duration = 60, -- minutes
                            locations = {
                                { coords = vector3(970.0, -130.0, 74.35), radius = 100.0 }, -- Biker Gang Territory
                                { coords = vector3(-1160.0, -2030.0, 13.18), radius = 100.0 }, -- Cartel Territory
                                { coords = vector3(350.0, -880.0, 28.29), radius = 100.0 }, -- Divine Gang Territory
                                { coords = vector3(-580.0, -1060.0, 22.35), radius = 100.0 } -- Queens Gang Territory
                            }
                        }
                    }
                },
                {
                    timeStart = 4, -- 4 AM
                    timeEnd = 12, -- 12 PM
                    activities = {
                        {
                            type = "sleep",
                            duration = 480, -- minutes (8 hours)
                            locations = {
                                { coords = vector3(970.0, -120.0, 74.35), radius = 20.0 }, -- Biker Gang Hideout
                                { coords = vector3(-1150.0, -2020.0, 13.18), radius = 20.0 }, -- Cartel Hideout
                                { coords = vector3(340.0, -870.0, 28.29), radius = 20.0 }, -- Divine Gang Hideout
                                { coords = vector3(-575.0, -1055.0, 22.35), radius = 20.0 } -- Queens Gang Hideout
                            }
                        }
                    }
                }
            }
        },
        drugdealer = {
            models = {
                "a_m_y_hipster_01",
                "a_m_m_skater_01",
                "a_m_y_stwhi_01"
            },
            schedules = {
                {
                    timeStart = 18, -- 6 PM
                    timeEnd = 6, -- 6 AM
                    activities = {
                        {
                            type = "deal",
                            duration = 180, -- minutes
                            locations = {
                                { coords = vector3(412.45, -1903.77, 25.35), radius = 30.0 }, -- Weed Dealer Area
                                { coords = vector3(-1146.32, -1514.88, 4.18), radius = 30.0 }, -- Meth Dealer Area
                                { coords = vector3(233.12, -1761.53, 28.29), radius = 30.0 } -- Cocaine Dealer Area
                            }
                        },
                        {
                            type = "hide",
                            duration = 60, -- minutes
                            locations = {
                                { coords = vector3(410.0, -1900.0, 25.35), radius = 10.0 }, -- Weed Dealer Hideout
                                { coords = vector3(-1145.0, -1510.0, 4.18), radius = 10.0 }, -- Meth Dealer Hideout
                                { coords = vector3(230.0, -1760.0, 28.29), radius = 10.0 } -- Cocaine Dealer Hideout
                            }
                        }
                    }
                },
                {
                    timeStart = 6, -- 6 AM
                    timeEnd = 18, -- 6 PM
                    activities = {
                        {
                            type = "sleep",
                            duration = 720, -- minutes (12 hours)
                            locations = {
                                { coords = vector3(410.0, -1900.0, 25.35), radius = 10.0 }, -- Weed Dealer Hideout
                                { coords = vector3(-1145.0, -1510.0, 4.18), radius = 10.0 }, -- Meth Dealer Hideout
                                { coords = vector3(230.0, -1760.0, 28.29), radius = 10.0 } -- Cocaine Dealer Hideout
                            }
                        }
                    }
                }
            }
        }
    },
    
    -- Maximum number of NPCs to spawn per type
    MaxNPCs = {
        police = 10,
        ems = 6,
        fire = 6,
        gang = 12,
        drugdealer = 6
    },
    
    -- Distance from player to spawn NPCs
    SpawnDistance = 100.0,
    
    -- Distance from player to despawn NPCs
    DespawnDistance = 150.0,
    
    -- Update interval (in milliseconds)
    UpdateInterval = 10000 -- 10 seconds
}

-- Variables
local spawnedNPCs = {}
local debugMode = false

-- Function to get current game hour
function GetCurrentHour()
    return GetClockHours()
end

-- Function to get current schedule for NPC type
function GetCurrentSchedule(npcType)
    local currentHour = GetCurrentHour()
    local schedules = Config.NPCTypes[npcType].schedules
    
    for _, schedule in ipairs(schedules) do
        if schedule.timeStart <= schedule.timeEnd then
            -- Simple time range (e.g., 8 AM to 5 PM)
            if currentHour >= schedule.timeStart and currentHour < schedule.timeEnd then
                return schedule
            end
        else
            -- Overnight time range (e.g., 10 PM to 6 AM)
            if currentHour >= schedule.timeStart or currentHour < schedule.timeEnd then
                return schedule
            end
        end
    end
    
    -- Default to first schedule if none found
    return schedules[1]
end

-- Function to get current activity for NPC type
function GetCurrentActivity(npcType)
    local schedule = GetCurrentSchedule(npcType)
    local currentTime = GetGameTimer()
    local activityIndex = (math.floor(currentTime / 60000) % #schedule.activities) + 1
    
    return schedule.activities[activityIndex]
}

-- Function to get random location for activity
function GetRandomLocationForActivity(npcType, activityType)
    local activity = nil
    
    -- Find activity with matching type
    local schedule = GetCurrentSchedule(npcType)
    for _, act in ipairs(schedule.activities) do
        if act.type == activityType then
            activity = act
            break
        end
    end
    
    -- If activity not found, use first activity
    if not activity then
        activity = schedule.activities[1]
    end
    
    -- Get random location from activity
    local locations = activity.locations
    local location = locations[math.random(1, #locations)]
    
    return location
}

-- Function to spawn NPC
function SpawnNPC(npcType, coords)
    -- Check if we've reached the maximum number of NPCs for this type
    local typeCount = 0
    for _, npc in ipairs(spawnedNPCs) do
        if npc.type == npcType then
            typeCount = typeCount + 1
        end
    end
    
    if typeCount >= Config.MaxNPCs[npcType] then
        if debugMode then
            print("Maximum number of NPCs reached for type: " .. npcType)
        end
        return nil
    end
    
    -- Get random model for NPC type
    local models = Config.NPCTypes[npcType].models
    local modelName = models[math.random(1, #models)]
    local model = GetHashKey(modelName)
    
    -- Request model
    RequestModel(model)
    local timeout = 5000
    local startTime = GetGameTimer()
    while not HasModelLoaded(model) do
        if GetGameTimer() - startTime > timeout then
            if debugMode then
                print("Failed to load model for NPC type: " .. npcType)
            end
            return nil
        end
        Citizen.Wait(100)
    end
    
    -- Spawn NPC
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, math.random(0, 359), false, true)
    
    if not ped or not DoesEntityExist(ped) then
        if debugMode then
            print("Failed to create ped for NPC type: " .. npcType)
        end
        return nil
    end
    
    -- Configure NPC
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    
    -- Set NPC behavior based on type
    if npcType == "police" then
        GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 100, false, true)
        SetPedArmour(ped, 100)
        SetPedAccuracy(ped, 60)
    elseif npcType == "ems" then
        GiveWeaponToPed(ped, GetHashKey("WEAPON_FLASHLIGHT"), 1, false, true)
    elseif npcType == "fire" then
        GiveWeaponToPed(ped, GetHashKey("WEAPON_FIREEXTINGUISHER"), 1000, false, true)
    elseif npcType == "gang" then
        GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 100, false, true)
        SetPedArmour(ped, 50)
        SetPedAccuracy(ped, 40)
    elseif npcType == "drugdealer" then
        GiveWeaponToPed(ped, GetHashKey("WEAPON_SWITCHBLADE"), 1, false, true)
    end
    
    -- Get current activity
    local activity = GetCurrentActivity(npcType)
    
    -- Set NPC task based on activity type
    if activity.type == "patrol" then
        TaskWanderInArea(ped, coords.x, coords.y, coords.z, 20.0, 1.0, 10000.0)
    elseif activity.type == "work" or activity.type == "deal" then
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
    elseif activity.type == "break" then
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_AA_COFFEE", 0, true)
    elseif activity.type == "hangout" then
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_HANG_OUT_STREET", 0, true)
    elseif activity.type == "sleep" then
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_BUM_SLUMPED", 0, true)
    elseif activity.type == "hide" then
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    end
    
    -- Store NPC data
    local npcData = {
        ped = ped,
        type = npcType,
        model = modelName,
        spawnTime = GetGameTimer(),
        lastUpdate = GetGameTimer(),
        activity = activity.type,
        location = coords
    }
    
    table.insert(spawnedNPCs, npcData)
    
    if debugMode then
        print("Spawned NPC of type: " .. npcType .. " with activity: " .. activity.type)
    end
    
    -- Return NPC data
    return npcData
end

-- Function to update NPC behavior
function UpdateNPC(npcData)
    -- Check if NPC still exists
    if not DoesEntityExist(npcData.ped) then
        return false
    end
    
    -- Get current activity
    local activity = GetCurrentActivity(npcData.type)
    
    -- If activity changed, update NPC task
    if activity.type ~= npcData.activity then
        -- Get random location for new activity
        local location = GetRandomLocationForActivity(npcData.type, activity.type)
        local coords = location.coords
        
        -- Set NPC task based on activity type
        if activity.type == "patrol" then
            TaskWanderInArea(npcData.ped, coords.x, coords.y, coords.z, 20.0, 1.0, 10000.0)
        elseif activity.type == "work" or activity.type == "deal" then
            TaskStartScenarioInPlace(npcData.ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
        elseif activity.type == "break" then
            TaskStartScenarioInPlace(npcData.ped, "WORLD_HUMAN_AA_COFFEE", 0, true)
        elseif activity.type == "hangout" then
            TaskStartScenarioInPlace(npcData.ped, "WORLD_HUMAN_HANG_OUT_STREET", 0, true)
        elseif activity.type == "sleep" then
            TaskStartScenarioInPlace(npcData.ped, "WORLD_HUMAN_BUM_SLUMPED", 0, true)
        elseif activity.type == "hide" then
            TaskStartScenarioInPlace(npcData.ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
        end
        
        -- Update NPC data
        npcData.activity = activity.type
        npcData.location = coords
        npcData.lastUpdate = GetGameTimer()
        
        if debugMode then
            print("Updated NPC of type: " .. npcData.type .. " with new activity: " .. activity.type)
        end
    }
    
    return true
}

-- Function to despawn NPC
function DespawnNPC(npcData)
    -- Check if NPC still exists
    if DoesEntityExist(npcData.ped) then
        -- Delete NPC
        DeleteEntity(npcData.ped)
        
        if debugMode then
            print("Despawned NPC of type: " .. npcData.type)
        end
    end
}

-- Function to spawn NPCs around player
function SpawnNPCsAroundPlayer()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Spawn NPCs for each type
    for npcType, _ in pairs(Config.NPCTypes) do
        -- Get current activity
        local activity = GetCurrentActivity(npcType)
        
        -- Get random location for activity
        local location = GetRandomLocationForActivity(npcType, activity.type)
        
        -- Calculate spawn position (within location radius)
        local angle = math.random() * 2 * math.pi
        local radius = math.sqrt(math.random()) * location.radius
        local spawnX = location.coords.x + radius * math.cos(angle)
        local spawnY = location.coords.y + radius * math.sin(angle)
        local spawnZ = location.coords.z
        
        -- Check if spawn position is within range of player
        local spawnCoords = vector3(spawnX, spawnY, spawnZ)
        local distance = #(playerCoords - spawnCoords)
        
        if distance <= Config.SpawnDistance then
            -- Get ground Z
            local ground, groundZ = GetGroundZFor_3dCoord(spawnX, spawnY, spawnZ + 100.0, 0)
            if ground then
                spawnZ = groundZ
            end
            
            -- Spawn NPC
            SpawnNPC(npcType, vector3(spawnX, spawnY, spawnZ))
        end
    end
}

-- Function to update NPCs
function UpdateNPCs()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local newNPCs = {}
    
    -- Update or despawn existing NPCs
    for _, npcData in ipairs(spawnedNPCs) do
        -- Check if NPC still exists
        if DoesEntityExist(npcData.ped) then
            -- Get NPC position
            local npcCoords = GetEntityCoords(npcData.ped)
            local distance = #(playerCoords - npcCoords)
            
            -- If NPC is too far away, despawn it
            if distance > Config.DespawnDistance then
                DespawnNPC(npcData)
            else
                -- Update NPC behavior
                if UpdateNPC(npcData) then
                    table.insert(newNPCs, npcData)
                end
            end
        end
    end
    
    -- Replace spawnedNPCs with updated list
    spawnedNPCs = newNPCs
    
    -- Spawn new NPCs if needed
    if #spawnedNPCs < 20 then -- Limit total NPCs to 20
        SpawnNPCsAroundPlayer()
    end
}

-- Main thread
Citizen.CreateThread(function()
    -- Wait for resource to fully start
    Citizen.Wait(500)
    
    while true do
        -- Update NPCs
        UpdateNPCs()
        
        -- Wait before next update
        Citizen.Wait(Config.UpdateInterval)
    end
end)

-- Debug command
RegisterCommand("npc_debug", function()
    debugMode = not debugMode
    
    if debugMode then
        -- Show current NPCs
        print("Current NPCs:")
        for i, npcData in ipairs(spawnedNPCs) do
            print(i .. ": Type = " .. npcData.type .. ", Activity = " .. npcData.activity)
        end
    end
    
    TriggerEvent('fxcode:utils:notify', "NPC debug mode: " .. (debugMode and "Enabled" or "Disabled"), "info")
end, false)

-- Export functions
exports('SpawnNPC', SpawnNPC)
exports('DespawnNPC', DespawnNPC)
exports('GetCurrentActivity', GetCurrentActivity)