-- Staff management system for standalone-framework
-- Path: resources/standalone-framework/server/staff.lua

-- Table to store staff members
local staffList = {
    -- Default staff members (you can customize this list)
    ["license:1234567890abcdef"] = {
        name = "Admin",
        level = 100,
        permissions = {"all"}
    }
}

-- Function to check if a player is staff
function IsPlayerStaff(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    for _, identifier in ipairs(identifiers) do
        if staffList[identifier] then
            return true, staffList[identifier]
        end
    end
    
    return false
end

-- Function to get staff level
function GetStaffLevel(source)
    local isStaff, staffData = IsPlayerStaff(source)
    
    if isStaff then
        return staffData.level
    end
    
    return 0
end

-- Function to add a staff member
function AddStaffMember(identifier, name, level, permissions)
    if not identifier then return false end
    
    staffList[identifier] = {
        name = name or "Staff Member",
        level = level or 1,
        permissions = permissions or {}
    }
    
    return true
end

-- Function to remove a staff member
function RemoveStaffMember(identifier)
    if not identifier or not staffList[identifier] then
        return false
    end
    
    staffList[identifier] = nil
    return true
end

-- Function to get the full staff list
function GetStaffList()
    return staffList
end

-- Register commands
RegisterCommand("addstaff", function(source, args, rawCommand)
    -- Only console or staff level 100 can add staff
    if source == 0 or GetStaffLevel(source) >= 100 then
        if #args < 2 then
            if source == 0 then
                print("Usage: addstaff [identifier] [level] [name]")
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"Staff", "Usage: /addstaff [identifier] [level] [name]"}
                })
            end
            return
        end
        
        local identifier = args[1]
        local level = tonumber(args[2]) or 1
        local name = args[3] or "Staff Member"
        
        if AddStaffMember(identifier, name, level) then
            if source == 0 then
                print("Added staff member: " .. identifier .. " (Level " .. level .. ")")
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 255, 0},
                    multiline = false,
                    args = {"Staff", "Added staff member: " .. identifier .. " (Level " .. level .. ")"}
                })
            end
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = false,
            args = {"Staff", "You don't have permission to use this command"}
        })
    end
end, true)

RegisterCommand("removestaff", function(source, args, rawCommand)
    -- Only console or staff level 100 can remove staff
    if source == 0 or GetStaffLevel(source) >= 100 then
        if #args < 1 then
            if source == 0 then
                print("Usage: removestaff [identifier]")
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"Staff", "Usage: /removestaff [identifier]"}
                })
            end
            return
        end
        
        local identifier = args[1]
        
        if RemoveStaffMember(identifier) then
            if source == 0 then
                print("Removed staff member: " .. identifier)
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {0, 255, 0},
                    multiline = false,
                    args = {"Staff", "Removed staff member: " .. identifier}
                })
            end
        else
            if source == 0 then
                print("Staff member not found: " .. identifier)
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = false,
                    args = {"Staff", "Staff member not found: " .. identifier}
                })
            end
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = false,
            args = {"Staff", "You don't have permission to use this command"}
        })
    end
end, true)

RegisterCommand("staff", function(source, args, rawCommand)
    if source > 0 then
        local isStaff, staffData = IsPlayerStaff(source)
        
        if isStaff then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 0},
                multiline = false,
                args = {"Staff", "You are a staff member (Level " .. staffData.level .. ")"}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = false,
                args = {"Staff", "You are not a staff member"}
            })
        end
    end
end, false)

-- Export functions
exports('IsPlayerStaff', IsPlayerStaff)
exports('GetStaffLevel', GetStaffLevel)
exports('AddStaffMember', AddStaffMember)
exports('RemoveStaffMember', RemoveStaffMember)
exports('GetStaffList', GetStaffList)
