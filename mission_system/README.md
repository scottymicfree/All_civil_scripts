FiveM Mission System

A comprehensive mission system for FiveM servers that provides dynamic missions for different job types and gang activities.


Features
• **Multiple Mission Types**: Gang, Drug, Police, EMS, and Fire Department missions
• **Difficulty Levels**: Low, Medium, and High risk missions with appropriate rewards
• **Dynamic Objectives**: Various objective types including goto, collect, deliver, kill, arrest, rescue, heal, and extinguish
• **Reward System**: XP and money rewards based on mission difficulty and completion time
• **Cooldown System**: Prevents mission spamming with configurable cooldown periods
• **Controller Support**: Full compatibility with Xbox controllers
• **Mission History**: Track completed and failed missions


Installation
1. Create a new folder named `mission_system` in your server's resources directory
2. Copy all files to this folder:
- `mission_system.lua`
- `mission_system_server.lua`
- `config.lua`
- `fxmanifest.lua`
3. Add `ensure mission_system` to your server.cfg


Usage

Player Commands
• `/startmission [type] [difficulty]` - Start a mission of the specified type and difficulty
- Types: gang, drug, police, ems, fire
- Difficulties: low, mid, high
• `/cancelmission` - Cancel the current active mission
• `/missioncooldown` - Check the remaining cooldown time before starting a new mission
• `/missionhistory` - View your recent mission history
• `/mission_debug` - Toggle debug mode (for developers)


Exports (Client)

-- Start a mission
exports['mission_system']:StartMission(missionType, difficulty)

-- Complete the current mission
exports['mission_system']:CompleteMission()

-- Fail the current mission with a reason
exports['mission_system']:FailMission(reason)

-- Get the active mission data
local mission = exports['mission_system']:GetActiveMission()


Exports (Server)

-- Check if a player is on cooldown
local onCooldown = exports['mission_system']:IsPlayerOnCooldown(playerId)

-- Get a player's mission history
local history = exports['mission_system']:GetPlayerMissionHistory(playerId)

-- Get a player's remaining cooldown time in seconds
local cooldown = exports['mission_system']:GetPlayerCooldown(playerId)


Configuration

The mission system is highly configurable through the `config.lua` file:


Mission Types

Configure different mission types, their descriptions, and rewards:


Config.MissionTypes = {
    gang = {
        name = "Gang Mission",
        description = "Complete tasks for your gang",
        difficulties = {
            low = {
                name = "Low Risk",
                reward = 500,
                xp = 100
            },
            -- More difficulties...
        }
    },
    -- More mission types...
}


Mission Locations

Define locations for each mission type:


Config.MissionLocations = {
    gang = {
        { coords = vector3(970.0, -130.0, 74.35), radius = 100.0, name = "Biker Gang Territory" },
        -- More locations...
    },
    -- More mission types...
}


Mission Objectives

Configure objectives for each mission type and difficulty:


Config.MissionObjectives = {
    gang = {
        low = {
            { type = "goto", description = "Go to the specified location" },
            { type = "collect", description = "Collect the package" },
            { type = "deliver", description = "Deliver the package" }
        },
        -- More difficulties...
    },
    -- More mission types...
}


Server Configuration

Configure server-side settings:


Config.Server = {
    -- XP multipliers by difficulty
    XPMultipliers = {
        low = 1.0,
        mid = 1.5,
        high = 2.0
    },
    -- More settings...
}


Integration with Other Resources

Standalone Framework Integration

The mission system is designed to work with the standalone framework:


-- In mission_system_server.lua
if GetResourceState('standalone-framework') == 'started' then
    -- Use standalone-framework if available
    exports['standalone-framework']:AddXP(source, xp)
    exports['standalone-framework']:AddMoney(source, money)
else
    -- Fallback to basic events
    TriggerEvent("myframework:addXP", source, xp)
    TriggerEvent("myframework:addMoney", source, money)
end


Custom Framework Integration

To integrate with a custom framework, modify the reward distribution in `mission_system_server.lua`:


-- Add rewards to player
-- Replace this with your framework's functions
YourFramework.AddXP(source, xp)
YourFramework.AddMoney(source, money)


Extending the System

Adding New Mission Types
1. Add the new mission type to `Config.MissionTypes`
2. Add locations for the new mission type to `Config.MissionLocations`
3. Add objectives for the new mission type to `Config.MissionObjectives`


Adding New Objective Types

To add a new objective type:

1. Add the new objective type to the mission objectives in `Config.MissionObjectives`
2. Add handling for the new objective type in the `SetupObjective` function in `mission_system.lua`
3. Add completion checking for the new objective type in the `CheckObjectiveCompletion` function


Troubleshooting
• **Mission not starting**: Check if you're on cooldown with `/missioncooldown`
• **Objectives not completing**: Make sure you're close enough to the objective marker
• **Rewards not being received**: Check if the standalone-framework is running properly


Credits

Created by NinjaTech AI for your custom FiveM server framework.