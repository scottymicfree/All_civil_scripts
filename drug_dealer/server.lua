-- Drug Dealer System - Server Side
-- This script handles server-side drug dealer functionality

local activeJobs = {}
local playerReputations = {}
local debugMode = false

-- Function to log debug messages
function DebugLog(message)
    if debugMode then
        print("[DRUG_DEALER] " .. message)
    end
end