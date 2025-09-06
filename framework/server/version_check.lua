-- Version Check System
-- Checks for framework updates and compatibility

local currentVersion = Config.Version
local latestVersion = currentVersion -- This would be fetched from a remote source in a real implementation

-- Check for updates
Citizen.CreateThread(function()
    -- In a real implementation, you would fetch the latest version from a remote source
    -- For now, we'll just simulate a version check
    Citizen.Wait(5000)
    checkVersion()
end)

-- Compare versions
function checkVersion()
    if currentVersion ~= latestVersion then
        print("^1[WARNING] You are running an outdated version of the framework!")
        print("^1Current version: " .. currentVersion)
        print("^1Latest version: " .. latestVersion)
        print("^1Please update to the latest version for bug fixes and new features.")
    else
        print("^2[INFO] You are running the latest version of the framework: " .. currentVersion)
    end
end

-- Export version information
exports('getFrameworkVersion', function()
    return {
        current = currentVersion,
        latest = latestVersion,
        upToDate = (currentVersion == latestVersion)
    }
end)
