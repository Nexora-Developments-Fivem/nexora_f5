local isDead = false

local function OpenLink(url)
    SendNUIMessage({
        action = "openLink",
        url = url
    })
end

hudVisible = true
minimapVisible = true
cinematicMode = false
currentHudIndex = 1
selectedWalkingStyle = 1

local function ToggleCinematic()
    cinematicMode = not cinematicMode
    
    if cinematicMode then
        hudVisible = false
        minimapVisible = false
        currentHudIndex = 2
        
        HUD.Hide()
        DisplayRadar(false)
        
    else
        hudVisible = true
        minimapVisible = true
        currentHudIndex = 1
        
        HUD.Show()
        DisplayRadar(true)
    end
end

function OpenMainMenu()
    local listIndex = {id = 1, permis = 1, ppa = 1}
    local options = {_T("information.show"), _T("information.view")}
    
    local doorStates = {
        FrontLeft = false,
        FrontRight = false,
        BackLeft = false,
        BackRight = false,
        Hood = false,
        Trunk = false
    }
    
    local windowStates = {false, false, false, false}
    local selectedDoorIndex = 1
    local selectedAllDoorsIndex = 1
    local selectedWindowsIndex = 1
    
    local selectedBillId = nil
    local playerBills = {}

    local playerData = Framework.GetPlayerData()
    local job = Framework.GetJob()
    local playerBankMoney = Framework.GetAccount("bank")
    local playerBlackMoney = Framework.GetAccount("black_money")
    local playerCash = Framework.GetMoney()
    
    local mainMenu = RageUI.CreateMenu("", _T("menu.subtitle"))
    local informationMenu = RageUI.CreateSubMenu(mainMenu, "", _T("information.subtitle"))
    local preferencesMenu = RageUI.CreateSubMenu(mainMenu, "", _T("preferences.subtitle"))
    local keybindingsMenu = RageUI.CreateSubMenu(mainMenu, "", "Key Bindings")
    local vehicleMenu = RageUI.CreateSubMenu(mainMenu, "", _T("vehicle.subtitle"))
    local commandsMenu = RageUI.CreateSubMenu(mainMenu, "", "Commands")
    local billsMenu = RageUI.CreateSubMenu(informationMenu, "", _T("bills.subtitle"))
    local billDetailsMenu = RageUI.CreateSubMenu(billsMenu, "", _T("bills.subtitle"))
    local radioMenu = RageUI.CreateSubMenu(preferencesMenu, "", _T("radio.subtitle"))
    local nearbyMenu = RageUI.CreateSubMenu(preferencesMenu, "", _T("nearby.subtitle"))
    
    RageUI.Visible(mainMenu, true)

    while mainMenu do
        Wait(0)
        
        RageUI.IsVisible(mainMenu, function()
            local playerId = GetPlayerServerId(PlayerId())
            local playerName = GetPlayerName(PlayerId())
            
            RageUI.Line()
            RageUI.Separator(string.format("~w~%s : %d | %s : %s", _T("general.id"), playerId, _T("general.name"), playerName))
            RageUI.Line()
            
            RageUI.Button(_T("menu.information"), nil, { RightLabel = ">>" }, true, {}, informationMenu)
            RageUI.Button(_T("menu.preferences"), nil, { RightLabel = ">>" }, true, {}, preferencesMenu)
            RageUI.Button(_T("menu.keybindings"), nil, { RightLabel = ">>" }, true, {}, keybindingsMenu)
            
            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                RageUI.Button(_T("menu.vehicle"), nil, { RightLabel = ">>" }, true, {}, vehicleMenu)
            end
            
            RageUI.Button(_T("menu.commands"), nil, { RightLabel = ">>" }, true, {}, commandsMenu)
            
            RageUI.Button(_T("external.discord"), nil, { RightLabel = ">>" }, true, {
                onSelected = function()
                    OpenLink(Config.Links.Discord)
                end
            })
            
            RageUI.Button(_T("external.rules"), nil, { RightLabel = ">>" }, true, {
                onSelected = function()
                    OpenLink(Config.Links.Rules)
                end
            })
            
            if Config.Performance.EnableFPSBoost then
                RageUI.Checkbox(_T("preferences.fps_boost"), nil, FPSBoost, {}, {
                    onChecked = function()
                        SetTimecycleModifier(Config.Performance.TimecycleModifier)
                    end,
                    onUnChecked = function()
                        SetTimecycleModifier("")
                    end,
                    onSelected = function(Index)
                        FPSBoost = Index
                    end
                })
            end
        end)
        
        RageUI.IsVisible(informationMenu, function()
            RageUI.Line()
            RageUI.Separator(string.format("~w~%s : ~g~%s ~w~| ~w~%s : ~g~%s", 
                _T("information.job"), job.label or "Unknown", 
                _T("information.grade"), job.grade_label or "Unknown"))
            RageUI.Separator(string.format("~w~%s : ~g~%d$", _T("information.bank_money"), playerBankMoney))
            RageUI.Separator(string.format("~w~%s : ~g~%d$", _T("information.cash_money"), playerCash))
            RageUI.Separator(string.format("%s : ~r~%d$", _T("information.black_money"), playerBlackMoney))
            RageUI.Line()
            
            if Config.Documents.EnableIdentityCard then
                RageUI.List(_T("information.identity_card"), options, listIndex.id, nil, {}, true, {
                    onListChange = function(index)
                        listIndex.id = index
                    end,
                    onSelected = function(index)
                        if index == 1 then
                            local closestPlayer, closestDistance = Framework.GetClosestPlayer()
                            if closestDistance ~= -1 and closestDistance <= Config.Proximity.MaxDistance then
                                TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), 
                                    GetPlayerServerId(closestPlayer))
                            else
                                Framework.ShowNotification(_T("information.no_nearby"))
                            end
                        elseif index == 2 then
                            TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), 
                                GetPlayerServerId(PlayerId()))
                        end
                    end
                })
            end
            
            if Config.Documents.EnableDriverLicense then
                RageUI.List(_T("information.driver_license"), options, listIndex.permis, nil, {}, true, {
                    onListChange = function(index)
                        listIndex.permis = index
                    end,
                    onSelected = function(index)
                        if index == 1 then
                            local closestPlayer, closestDistance = Framework.GetClosestPlayer()
                            if closestDistance ~= -1 and closestDistance <= Config.Proximity.MaxDistance then
                                TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), 
                                    GetPlayerServerId(closestPlayer), "driver")
                            else
                                Framework.ShowNotification(_T("information.no_nearby"))
                            end
                        elseif index == 2 then
                            TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), 
                                GetPlayerServerId(PlayerId()), "driver")
                        end
                    end
                })
            end
            
            if Config.Documents.EnableWeaponLicense then
                RageUI.List(_T("information.weapon_license"), options, listIndex.ppa, nil, {}, true, {
                    onListChange = function(index)
                        listIndex.ppa = index
                    end,
                    onSelected = function(index)
                        if index == 1 then
                            local closestPlayer, closestDistance = Framework.GetClosestPlayer()
                            if closestDistance ~= -1 and closestDistance <= Config.Proximity.MaxDistance then
                                TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), 
                                    GetPlayerServerId(closestPlayer), "weapon")
                            else
                                Framework.ShowNotification(_T("information.no_nearby"))
                            end
                        elseif index == 2 then
                            TriggerServerEvent("jsfour-idcard:open", GetPlayerServerId(PlayerId()), 
                                GetPlayerServerId(PlayerId()), "weapon")
                        end
                    end
                })
            end
            
            if Config.Billing.Enabled then
                RageUI.Button(_T("information.bills"), nil, {RightLabel = ">>"}, true, {}, billsMenu)
            end
        end)
        
        RageUI.IsVisible(preferencesMenu, function()
            RageUI.Line()
            RageUI.Separator(_T("preferences.title"))
            RageUI.Line()
            
            if Config.Radio.Enabled then
                RageUI.Button(_T("preferences.radio"), nil, { RightLabel = ">>" }, true, {}, radioMenu)
            end
            
            RageUI.Button(_T("preferences.playtime"), nil, { RightLabel = ">>" }, true, {
                onSelected = function()
                    Framework.TriggerCallback('nexora:getPlayTime', function(playTime)
                        local pt = tonumber(playTime)
                        if pt then
                            local hours = math.floor(pt / 3600)
                            local mins = math.floor((pt % 3600) / 60)
                            Framework.ShowNotification(string.format(_T("preferences.playtime_text"), hours, mins))
                        else
                            Framework.ShowNotification(_T("preferences.playtime_error"))
                        end
                    end)
                end
            })
            
            if Config.Proximity.ShowNearbyPlayers then
                RageUI.Button(_T("preferences.nearby_players"), nil, { RightLabel = ">>" }, true, {}, nearbyMenu)
            end
            
            if Config.Cinematic.Enabled then
                RageUI.Button(
                    _T("preferences.cinematic"), 
                    cinematicMode and "~r~Mode actif~s~" or "~g~Mode inactif~s~",
                    { RightLabel = ">>" }, 
                    true, 
                    {
                        onSelected = function()
                            ToggleCinematic()
                            Framework.ShowNotification(cinematicMode and _T("preferences.cinematic_enabled") or _T("preferences.cinematic_disabled"))
                        end
                    }
                )
            end
            
            RageUI.List(
                _T("preferences.hud"),
                {
                    _T("preferences.hud_show"),
                    _T("preferences.hud_hide")
                },
                currentHudIndex,
                nil,
                {},
                not cinematicMode,
                {
                    onListChange = function(index)
                        if cinematicMode then return end
                        
                        currentHudIndex = index
                        
                        if index == 1 then
                            hudVisible = true
                            CreateThread(function()
                                Wait(100)
                                HUD.Show()
                            end)
                            Framework.ShowNotification(_T("preferences.hud_enabled"))
                        
                        elseif index == 2 then
                            hudVisible = false
                            CreateThread(function()
                                Wait(100)
                                HUD.Hide()
                            end)
                            Framework.ShowNotification(_T("preferences.hud_disabled"))
                        end
                    end
                }
            )
            
            RageUI.List(_T("preferences.minimap"), {_T("preferences.minimap_show"), _T("preferences.minimap_hide")}, 
                minimapVisible and 1 or 2, nil, {}, true, {
                onListChange = function(index)
                    if index == 1 then
                        minimapVisible = true
                        DisplayRadar(true)
                        Framework.ShowNotification(_T("preferences.minimap_enabled"))
                    elseif index == 2 then
                        minimapVisible = false
                        DisplayRadar(false)
                        Framework.ShowNotification(_T("preferences.minimap_hidden"))
                    end
                end
            })
            
            local walkingStyleLabels = {}
            for _, style in ipairs(Config.WalkingStyles) do
                table.insert(walkingStyleLabels, style.label)
            end
            
            RageUI.List(_T("preferences.walking_style"), walkingStyleLabels, selectedWalkingStyle, nil, {}, true, {
                onListChange = function(index)
                    selectedWalkingStyle = index
                end,
                onSelected = function()
                    local ped = PlayerPedId()
                    local style = Config.WalkingStyles[selectedWalkingStyle].style
                    
                    if style and ped then
                        RequestAnimSet(style)
                        while not HasAnimSetLoaded(style) do
                            Wait(10)
                        end
                        SetPedMovementClipset(ped, style, 0.25)
                    end
                end
            })
        end)
        
        RageUI.IsVisible(radioMenu, function()
            if playerHasRadio then
                RageUI.Line()
                RageUI.Separator(string.format("~w~%s : %s", 
                    _T("radio.status"), 
                    radioEnabled and "~g~" .. _T("radio.enabled") or "~r~" .. _T("radio.disabled")))
                RageUI.Line()
                
                RageUI.Button(_T("radio.enable"), nil, { RightLabel = ">>" }, true, {
                    onSelected = function()
                        if not radioEnabled then
                            radioEnabled = true
                            Framework.ShowNotification(_T("radio.enabled_notif"))
                            if Config.Radio.UseVoiceSystem == "pma-voice" then
                                exports['pma-voice']:setVoiceProperty('radioEnabled', true)
                            end
                        else
                            Framework.ShowNotification(_T("radio.already_enabled"))
                        end
                    end
                })
                
                RageUI.Button(_T("radio.disable"), nil, { RightLabel = ">>" }, true, {
                    onSelected = function()
                        if radioEnabled then
                            radioEnabled = false
                            Framework.ShowNotification(_T("radio.disabled_notif"))
                            if Config.Radio.UseVoiceSystem == "pma-voice" then
                                exports['pma-voice']:setVoiceProperty('radioEnabled', false)
                                exports["pma-voice"]:setRadioChannel(0)
                            end
                        else
                            Framework.ShowNotification(_T("radio.already_disabled"))
                        end
                    end
                })
                
                if radioEnabled then
                    RageUI.Button(_T("radio.frequency"), nil, { RightLabel = tostring(radioFrequency) }, true, {
                        onSelected = function()
                            local input = tonumber(KeyboardInput(_T("radio.frequency_prompt"), "", 10))
                            if input and input > 0 then
                                radioFrequency = input
                                if Config.Radio.UseVoiceSystem == "pma-voice" then
                                    exports["pma-voice"]:setRadioChannel(radioFrequency)
                                end
                                Framework.ShowNotification(string.format(_T("radio.frequency_set"), input))
                            else
                                Framework.ShowNotification(_T("radio.frequency_invalid"))
                            end
                        end
                    })
                    
                    RageUI.List(_T("radio.sounds"), {_T("radio.disabled"), _T("radio.enabled")}, 
                        micClicks and 2 or 1, nil, {}, true, {
                        onListChange = function(index)
                            micClicks = (index == 2)
                            if Config.Radio.UseVoiceSystem == "pma-voice" then
                                exports['pma-voice']:setVoiceProperty('micClicks', micClicks)
                            end
                            if micClicks then
                                Framework.ShowNotification(_T("radio.sounds_enabled"))
                            else
                                Framework.ShowNotification(_T("radio.sounds_disabled"))
                            end
                        end
                    })
                end
            else
                RageUI.Line()
                RageUI.Separator(_T("radio.no_radio"))
                RageUI.Line()
            end
        end)
        
        RageUI.IsVisible(nearbyMenu, function()
            local found = false
            
            for _, player in ipairs(GetActivePlayers()) do
                local playerPed = GetPlayerPed(player)
                local myPed = PlayerPedId()
                local dst = #(GetEntityCoords(playerPed) - GetEntityCoords(myPed))
                local coords = GetEntityCoords(playerPed)
                
                if IsEntityVisible(playerPed) and dst < Config.Proximity.MaxDistance and player ~= PlayerId() then
                    found = true
                    RageUI.Line()
                    RageUI.Button(string.format("%s : ~g~%d ~s~|~o~ %s", 
                        _T("nearby.id"), GetPlayerServerId(player), GetPlayerName(player)), 
                        { RightLabel = ">>" }, true, {
                        onActive = function()
                            if Config.Proximity.ShowMarker then
                                DrawMarker(Config.Proximity.MarkerType, 
                                    coords.x, coords.y, coords.z + 1.1, 
                                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                                    Config.Proximity.MarkerSize, Config.Proximity.MarkerSize, Config.Proximity.MarkerSize, 
                                    Config.Proximity.MarkerColor.r, Config.Proximity.MarkerColor.g, 
                                    Config.Proximity.MarkerColor.b, Config.Proximity.MarkerColor.a, 
                                    true, true, 2, nil, nil, false)
                            end
                        end,
                        onSelected = function()
                            Framework.ShowNotification(string.format(_T("nearby.id_notif"), GetPlayerServerId(player)))
                        end
                    })
                end
            end
            
            if not found then
                RageUI.Line()
                RageUI.Separator(_T("nearby.no_players"))
                RageUI.Line()
            end
        end)
        
        RageUI.IsVisible(keybindingsMenu, function()
            RageUI.Line()
            for _, binding in ipairs(Config.KeyBindings) do
                RageUI.Button(binding.label, binding.description, { RightLabel = binding.key }, true, {})
            end
        end)
        
        RageUI.IsVisible(vehicleMenu, function()
            local vehicle = GetVehiclePedIsUsing(PlayerPedId())
            local vehicleModel = GetEntityModel(vehicle)
            local vehiclePlate = GetVehicleNumberPlateText(vehicle)
            local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
            
            RageUI.Line()
            
            if Config.Vehicle.EnableVehicleInfo then
                RageUI.Button(_T("vehicle.info"), nil, { RightLabel = ">>" }, true, {
                    onSelected = function()
                        Framework.ShowNotification(string.format("%s : %s\n%s : %s", 
                            _T("vehicle.model"), vehicleName or "Unknown",
                            _T("vehicle.plate"), vehiclePlate or "Unknown"))
                    end
                })
            end
            
            if Config.Vehicle.EnableEngineToggle then
                RageUI.Button(_T("vehicle.engine"), nil, { RightLabel = ">>" }, true, {
                    onSelected = function()
                        if GetIsVehicleEngineRunning(vehicle) then
                            SetVehicleEngineOn(vehicle, false, false, true)
                            SetVehicleUndriveable(vehicle, true)
                            Framework.ShowNotification(_T("vehicle.engine_stopped"))
                        else
                            SetVehicleEngineOn(vehicle, true, false, true)
                            SetVehicleUndriveable(vehicle, false)
                            Framework.ShowNotification(_T("vehicle.engine_started"))
                        end
                    end
                })
            end
            
            if Config.Vehicle.EnableDoorControl then
                local doorOptions = {
                    _T("vehicle.door_front_left"),
                    _T("vehicle.door_front_right"),
                    _T("vehicle.door_back_left"),
                    _T("vehicle.door_back_right"),
                    _T("vehicle.door_hood"),
                    _T("vehicle.door_trunk")
                }
                
                RageUI.List(_T("vehicle.doors"), doorOptions, selectedDoorIndex, nil, {}, true, {
                    onListChange = function(index)
                        selectedDoorIndex = index
                    end,
                    onSelected = function(index)
                        local doorIndex = index - 1
                        local doorStateKeys = {"FrontLeft", "FrontRight", "BackLeft", "BackRight", "Hood", "Trunk"}
                        local stateKey = doorStateKeys[index]
                        
                        if stateKey then
                            doorStates[stateKey] = not doorStates[stateKey]
                            if doorStates[stateKey] then
                                SetVehicleDoorOpen(vehicle, doorIndex, false, false)
                            else
                                SetVehicleDoorShut(vehicle, doorIndex, false, false)
                            end
                        end
                    end
                })
                
                RageUI.List(_T("vehicle.all_doors"), {_T("vehicle.open"), _T("vehicle.close")}, 
                    selectedAllDoorsIndex, nil, {}, true, {
                    onListChange = function(index)
                        selectedAllDoorsIndex = index
                    end,
                    onSelected = function()
                        if selectedAllDoorsIndex == 1 then
                            for door = 0, 7 do
                                SetVehicleDoorOpen(vehicle, door, false, false)
                            end
                            Framework.ShowNotification(_T("vehicle.all_doors_opened"))
                        else
                            for door = 0, 7 do
                                SetVehicleDoorShut(vehicle, door, false)
                            end
                            Framework.ShowNotification(_T("vehicle.all_doors_closed"))
                        end
                    end
                })
            end
            
            if Config.Vehicle.EnableWindowControl then
                RageUI.List(_T("vehicle.windows"), {_T("vehicle.open"), _T("vehicle.close")}, 
                    selectedWindowsIndex, nil, {}, true, {
                    onListChange = function(index)
                        selectedWindowsIndex = index
                    end,
                    onSelected = function()
                        if selectedWindowsIndex == 1 then
                            for i = 0, 3 do
                                if not windowStates[i + 1] then
                                    windowStates[i + 1] = true
                                    RollDownWindow(vehicle, i)
                                end
                            end
                            Framework.ShowNotification(_T("vehicle.all_windows_opened"))
                        else
                            for i = 0, 3 do
                                if windowStates[i + 1] then
                                    windowStates[i + 1] = false
                                    RollUpWindow(vehicle, i)
                                end
                            end
                            Framework.ShowNotification(_T("vehicle.all_windows_closed"))
                        end
                    end
                })
            end
        end)
        
        RageUI.IsVisible(commandsMenu, function()
            RageUI.Line()
            for _, cmd in ipairs(Config.Commands) do
                RageUI.Button(cmd.command, cmd.description, { RightLabel = cmd.usage }, true, {})
            end
        end)
        
        RageUI.IsVisible(billsMenu, function()
            if #playerBills <= 0 then
                Framework.TriggerCallback('nexora:getBills', function(bills)
                    playerBills = bills or {}
                end)
            end
            
            if #playerBills <= 0 then
                RageUI.Line()
                RageUI.Button(_T("bills.no_bills"), nil, {}, true, {
                    onSelected = function()
                        Framework.ShowNotification(_T("bills.action_impossible"))
                    end
                })
                RageUI.Line()
            else
                for _, bill in ipairs(playerBills) do
                    RageUI.Line()
                    RageUI.Button(string.format('%s - ~r~%s~s~', bill.label, bill.amount), 
                        nil, { RightLabel = bill.amount .. " $" }, true, {
                        onSelected = function()
                            selectedBillId = bill.id
                        end
                    }, billDetailsMenu)
                end
            end
        end)
        
        RageUI.IsVisible(billDetailsMenu, function()
            if selectedBillId then
                RageUI.Button(_T("bills.pay"), nil, {RightLabel = ">>"}, true, {
                    onSelected = function()
                        Framework.TriggerCallback('nexora:payBill', function(success)
                            if success then
                                Framework.ShowNotification(_T("bills.paid"))
                                playerBills = {}
                                RageUI.GoBack()
                            else
                                Framework.ShowNotification(_T("bills.payment_error"))
                            end
                        end, selectedBillId)
                    end
                })
            end
        end)
        
        if not RageUI.Visible(mainMenu) and not RageUI.Visible(informationMenu) 
            and not RageUI.Visible(preferencesMenu) and not RageUI.Visible(keybindingsMenu)
            and not RageUI.Visible(vehicleMenu) and not RageUI.Visible(commandsMenu)
            and not RageUI.Visible(billsMenu) and not RageUI.Visible(billDetailsMenu)
            and not RageUI.Visible(radioMenu) and not RageUI.Visible(nearbyMenu) then
            mainMenu = false
        end
    end
end

CreateThread(function()
    while not Framework.Ready do
        Wait(100)
    end
    
    RegisterCommand('nexora_menu', function()
        if not isDead then
            OpenMainMenu()
        else
            Framework.ShowNotification(_T("general.cannot_open_while_dead"))
        end
    end, false)
    
    RegisterKeyMapping('nexora_menu', "Open Nexora Menu", 'keyboard', Config.MenuKey)
    
    AddEventHandler('esx:onPlayerDeath', function() 
        isDead = true 
        RageUI.CloseAll()
    end)
    
    AddEventHandler('esx:onPlayerSpawn', function() 
        isDead = false 
    end)
    
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        isDead = false
    end)
end)