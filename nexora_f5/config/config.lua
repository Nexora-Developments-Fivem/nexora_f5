Config = Config or {}

--- Language configuration
--- @field Language string "en" or "fr"
Config.Language = "fr"

--- Menu key configuration
--- @field MenuKey string The key to open the menu
Config.MenuKey = "F5"

--- Discord and Rules links
--- @field Links table External links configuration
Config.Links = {
    Discord = "https://discord.gg/your-discord",
    Rules = "https://your-website.com/rules"
}

--- Key bindings information
--- @field KeyBindings table List of keybindings to display
Config.KeyBindings = {
    {key = "F5", label = "Open Menu", description = "Open the F5 menu"},
    {key = "F6", label = "Job Menu", description = "Open job menu"},
    {key = "T", label = "Chat", description = "Open chat"},
    {key = "X", label = "Hands Up", description = "Put hands up"},
    {key = "Z", label = "Vehicle Control", description = "Vehicle radio menu"}
}

--- Server commands information
--- @field Commands table List of commands to display
Config.Commands = {
    {command = "/me", usage = "/me [action]", description = "Perform an action"},
    {command = "/do", usage = "/do [description]", description = "Describe environment"},
    {command = "/report", usage = "/report [message]", description = "Report a player"},
    {command = "/id", usage = "/id", description = "Show your ID"}
}

--- Vehicle menu configuration
--- @field Vehicle table Vehicle menu options
Config.Vehicle = {
    EnableEngineToggle = true,
    EnableDoorControl = true,
    EnableWindowControl = true,
    EnableVehicleInfo = true
}

--- Identity documents configuration
--- @field Documents table Documents system configuration
Config.Documents = {
    EnableIdentityCard = true,
    EnableDriverLicense = true,
    EnableWeaponLicense = true
}

--- Radio configuration
--- @field Radio table Radio system configuration
Config.Radio = {
    Enabled = true,
    ItemName = "radio",
    UseVoiceSystem = "pma-voice" -- Options: "pma-voice", "saltychat", "tokovoip", "mumble-voip"
}

--- Cinematic mode configuration
--- @field Cinematic table Cinematic mode settings
Config.Cinematic = {
    Enabled = true,
    AnimationSpeed = 0.02,
    BarHeight = 0.15
}

--- Player proximity configuration
--- @field Proximity table Proximity detection settings
Config.Proximity = {
    ShowNearbyPlayers = true,
    MaxDistance = 3.0,
    ShowMarker = true,
    MarkerType = 20,
    MarkerSize = 0.4,
    MarkerColor = {r = 255, g = 255, b = 255, a = 100}
}

--- Billing system configuration
--- @field Billing table Billing system settings
Config.Billing = {
    Enabled = true,
    UseESXBilling = true,
    DatabaseTable = "billing"
}

--- Walking styles configuration
--- @field WalkingStyles table Available walking styles
Config.WalkingStyles = {
    {label = "Normal", style = "move_m@multiplayer"},
    {label = "Arrogant", style = "move_f@arrogant@a"},
    {label = "Casual", style = "move_m@casual@a"},
    {label = "Quick", style = "move_m@quick"},
    {label = "Slow", style = "move_m@fat@a"},
    {label = "Proud", style = "move_f@posh@"},
    {label = "Gangster", style = "move_m@gangster@generic"},
    {label = "Feminine", style = "move_f@maneater"},
    {label = "Drunk", style = "move_m@drunk@verydrunk"},
    {label = "Powerful", style = "move_m@brave"},
    {label = "Confident", style = "move_m@confident"},
    {label = "Business", style = "move_m@business@a"},
    {label = "Tired", style = "move_m@buzzed"},
    {label = "Injured", style = "move_m@injured"},
    {label = "Sad", style = "move_m@sad@a"},
    {label = "Scared", style = "move_f@scared"},
    {label = "Moderately Drunk", style = "move_m@drunk@moderatedrunk"}
}

--- Performance boost configuration
--- @field Performance table FPS boost settings
Config.Performance = {
    EnableFPSBoost = true,
    TimecycleModifier = "yell_tunnel_nodirect"
}