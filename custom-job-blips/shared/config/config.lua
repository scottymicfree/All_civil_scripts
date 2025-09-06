{
    "menuItems": [
        {
            "name": "Player Interactions",
            "description": "Manage your character and economy.",
            "type": "submenu",
            "submenu": {
                "items": [
                    {
                        "name": "Change Job",
                        "description": "Select a job from available locations.",
                        "type": "command",
                        "command": "jobmenu",
                        "permission": "vmenu.menu.job"
                    },
                    {
                        "name": "Buy Ammo",
                        "description": "Purchase ammunition for your weapons.",
                        "type": "command",
                        "command": "buyammo",
                        "permission": "vmenu.menu.ammo"
                    },
                    {
                        "name": "Manage Inventory",
                        "description": "View and manage your items.",
                        "type": "command",
                        "command": "inventory",
                        "permission": "vmenu.menu.inventory"
                    },
                    {
                        "name": "Check Bank",
                        "description": "View or manage your bank account.",
                        "type": "command",
                        "command": "bank",
                        "permission": "vmenu.menu.options"
                    },
                    {
                        "name": "Buy Vehicle",
                        "description": "Purchase a new vehicle.",
                        "type": "command",
                        "command": "buyvehicle",
                        "permission": "vmenu.menu.vehicle"
                    },
                    {
                        "name": "Manage Traffic",
                        "description": "Control traffic settings.",
                        "type": "command",
                        "command": "traffic",
                        "permission": "vmenu.menu.online_players"
                    }
                ]
            }
        },
        {
            "name": "Admin Tools",
            "description": "Administrative controls.",
            "type": "submenu",
            "submenu": {
                "items": [
                    {
                        "name": "Ban Player",
                        "description": "Ban a player from the server.",
                        "type": "command",
                        "command": "banplayer",
                        "permission": "vmenu.menu.ban"
                    },
                    {
                        "name": "Kick Player",
                        "description": "Kick a player from the server.",
                        "type": "command",
                        "command": "kick",
                        "permission": "vmenu.menu.kick"
                    }
                ]
            },
            "permission": "vmenu.menu.online_players"
        }
    ],
    "commands": {
        "jobmenu": { "description": "Opens the job selection menu.", "script": "custom-job-blips:openJobMenu" },
        "buyammo": { "description": "Opens the ammo purchase menu.", "script": "custom-player-data:buyAmmo" },
        "inventory": { "description": "Opens the inventory menu.", "script": "ox_inventory:openInventory" },
        "bank": { "description": "Opens the bank menu.", "script": "omes_banking:openBankUI" },
        "buyvehicle": { "description": "Opens the vehicle purchase menu.", "script": "vehicle_menu:buyVehicle" },
        "traffic": { "description": "Opens the traffic control menu.", "script": "traffic_control:openTrafficMenu" }
    }
}