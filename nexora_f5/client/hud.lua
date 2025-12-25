HUD = {
    DetectedResource = nil,
    Config = nil,
    Available = false
}

function HUD.DetectResource()
    if not Config then
        print("^1[Nexora HUD]^0 Config not loaded")
        HUD.Available = false
        return false
    end
    
    if not Config.Framework then
        print("^1[Nexora HUD]^0 Config.Framework not set")
        HUD.Available = false
        return false
    end
    
    if not Config.HUDResources then
        print("^1[Nexora HUD]^0 Config.HUDResources not found")
        HUD.Available = false
        return false
    end
    
    local hudResources = Config.HUDResources[Config.Framework]
    if not hudResources then
        print("^3[Nexora HUD]^0 No HUD config for framework")
        return false
    end

    for _, hud in ipairs(hudResources) do
        if GetResourceState(hud.resource) == "started" then
            HUD.DetectedResource = hud.resource
            HUD.Config = hud
            HUD.Available = true

            print(("^2[Nexora HUD]^0 Detected: ^3%s^0 (%s)"):format(
                hud.resource,
                hud.type
            ))
            return true
        end
    end

    print("^3[Nexora HUD]^0 No external HUD detected, using native")
    HUD.Available = false
    return false
end

function HUD.Show()
    CreateThread(function()
        Wait(100)
        
        if not HUD.Available then
            DisplayHud(true)
            return
        end

        local cfg = HUD.Config

        if cfg.type == "export" then
            if cfg.exportName then
                pcall(function()
                    exports[HUD.DetectedResource][cfg.exportName](true)
                end)
            elseif cfg.show then
                pcall(function()
                    exports[HUD.DetectedResource][cfg.show]()
                end)
            end

        elseif cfg.type == "event" then
            if cfg.show then
                TriggerEvent(cfg.show)
            end

        elseif cfg.type == "nui" then
            SendNUIMessage(cfg.show or { type = "SHOW", value = true })
        end
        
        Wait(100)
        
        if HUD.DetectedResource == "esx_hud" then
           exports["esx_hud"]:HudToggle(true)
        end

    end)
end

function HUD.Hide()
    CreateThread(function()
        Wait(100)
        
        if not HUD.Available then
            DisplayHud(false)
            return
        end

        local cfg = HUD.Config

        if cfg.type == "export" then
            if cfg.exportName then
                pcall(function()
                    exports[HUD.DetectedResource][cfg.exportName](false)
                end)
            elseif cfg.hide then
                pcall(function()
                    exports[HUD.DetectedResource][cfg.hide]()
                end)
            end

        elseif cfg.type == "event" then
            if cfg.hide then
                TriggerEvent(cfg.hide)
            end

        elseif cfg.type == "nui" then
            SendNUIMessage(cfg.hide or { type = "SHOW", value = false })
        end
        
        Wait(100)
        
        if HUD.DetectedResource == "esx_hud" then
            exports["esx_hud"]:HudToggle(false)
        end
    end)
end

function HUD.Toggle(visible)
    if visible then
        HUD.Show()
    else
        HUD.Hide()
    end
end

CreateThread(function()
    while not Config do
        Wait(100)
    end
    
    while not Framework or not Framework.Ready do
        Wait(100)
    end

    Wait(500)
    HUD.DetectResource()
end)