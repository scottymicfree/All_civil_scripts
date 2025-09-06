-- Loading screen killer
Citizen.CreateThread(function()
    -- Wait for game to initialize
    Citizen.Wait(10000)
    
    -- Try to shut down loading screen
    ShutdownLoadingScreenNui()
    print("Loading screen killer: First attempt")
    
    -- Try again after a delay
    Citizen.Wait(5000)
    ShutdownLoadingScreenNui()
    print("Loading screen killer: Second attempt")
    
    -- Final attempt
    Citizen.Wait(5000)
    ShutdownLoadingScreenNui()
    print("Loading screen killer: Final attempt")
end)
