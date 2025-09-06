Config = {}

-- Core Settings
Config.ServerName = "Civil Unrest RP"
Config.MaxPlayers = 48
Config.DefaultSpawnPoint = vector3(195.17, -933.77, 30.69)
Config.DefaultHeading = 144.5

-- Economy Settings
Config.StartingCash = 2000
Config.StartingBank = 5000
Config.PaycheckInterval = 30 -- minutes
Config.TaxRate = 0.05 -- 5% tax on income

-- Gang Settings
Config.MaxGangMembers = 16
Config.TurfCaptureTime = 300 -- seconds
Config.TurfPayoutInterval = 60 -- minutes
Config.TurfIncomeMultiplier = 1.5

-- NPC Settings
Config.NPCDensity = 0.8 -- 0.0 to 1.0
Config.PoliceNPCCount = 24
Config.EMSNPCCount = 12
Config.GangNPCCount = 30
Config.CivilianNPCCount = 40

-- Controller Settings
Config.ControllerSupport = true
Config.ControllerVibration = true
Config.ControllerDeadzone = 0.25

-- Debug Settings
Config.DebugMode = false
Config.ShowCoords = false
Config.LogLevel = 1 -- 0=none, 1=errors, 2=warnings, 3=info, 4=debug
