Framework = {}
Framework.Ready = false

--- Initialize the framework bridge
function Framework.Init()
    if Config.Framework == "esx" then
        Framework.InitESX()
    elseif Config.Framework == "qbcore" then
        Framework.InitQBCore()
    elseif Config.Framework == "custom" then
        Framework.InitCustom()
    else
        print("^1[Nexora F5] Unknown framework: " .. Config.Framework .. "^0")
    end
end

--- Initialize ESX framework
function Framework.InitESX()
    if Config.ESX.UseNewESX then
        Framework.Object = exports[Config.ESX.ResourceName]:getSharedObject()
    else
        TriggerEvent(Config.ESX.SharedObject, function(obj) 
            Framework.Object = obj 
        end)
    end
    
    while Framework.Object == nil do
        Wait(100)
    end
    
    Framework.PlayerData = Framework.Object.GetPlayerData()
    Framework.Ready = true
    
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        Framework.PlayerData = xPlayer
    end)
    
    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        Framework.PlayerData.job = job
    end)
end

--- Initialize QBCore framework
function Framework.InitQBCore()
    Framework.Object = exports[Config.QBCore.ResourceName]:GetCoreObject()
    
    while Framework.Object == nil do
        Wait(100)
    end
    
    Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
    Framework.Ready = true
    
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        Framework.PlayerData = Framework.Object.Functions.GetPlayerData()
    end)
    
    RegisterNetEvent('QBCore:Client:OnJobUpdate')
    AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
        Framework.PlayerData.job = job
    end)
end

--- Initialize custom framework
function Framework.InitCustom()
    if Config.Custom.GetFramework then
        Framework.Object = Config.Custom.GetFramework()
        Framework.Ready = true
    else
        print("^1[Nexora F5] Custom framework not properly configured^0")
    end
end

--- Get player data
--- @return table Player data
function Framework.GetPlayerData()
    if Config.Framework == "esx" then
        return Framework.Object.GetPlayerData()
    elseif Config.Framework == "qbcore" then
        return Framework.Object.Functions.GetPlayerData()
    elseif Config.Framework == "custom" then
        return Framework.PlayerData
    end
    return {}
end

--- Get player job
--- @return table Job data with name, label, grade, grade_label
function Framework.GetJob()
    local data = Framework.GetPlayerData()
    if Config.Framework == "esx" then
        return {
            name = data.job.name,
            label = data.job.label,
            grade = data.job.grade,
            grade_label = data.job.grade_label
        }
    elseif Config.Framework == "qbcore" then
        return {
            name = data.job.name,
            label = data.job.label,
            grade = data.job.grade.level,
            grade_label = data.job.grade.name
        }
    elseif Config.Framework == "custom" then
        return data.job or {}
    end
    return {}
end

--- Get player money
--- @return number Cash amount
function Framework.GetMoney()
    local data = Framework.GetPlayerData()
    if Config.Framework == "esx" then
        return data.money or 0
    elseif Config.Framework == "qbcore" then
        return data.money.cash or 0
    elseif Config.Framework == "custom" then
        return data.money or 0
    end
    return 0
end

--- Get account money
--- @param accountName string Account name
--- @return number Account balance
function Framework.GetAccount(accountName)
    local data = Framework.GetPlayerData()
    if Config.Framework == "esx" then
        for _, account in pairs(data.accounts or {}) do
            if account.name == accountName then
                return account.money
            end
        end
    elseif Config.Framework == "qbcore" then
        if accountName == "bank" then
            return data.money.bank or 0
        elseif accountName == "black_money" then
            return data.money.crypto or 0
        end
    elseif Config.Framework == "custom" then
        return data.accounts and data.accounts[accountName] or 0
    end
    return 0
end

--- Show notification
--- @param message string Notification message
function Framework.ShowNotification(message)
    if Config.Framework == "esx" then
        Framework.Object.ShowNotification(message)
    elseif Config.Framework == "qbcore" then
        Framework.Object.Functions.Notify(message)
    elseif Config.Framework == "custom" then
        -- Implement custom notification
        print(message)
    end
end

--- Get closest player
--- @return number, number Player ID and distance
function Framework.GetClosestPlayer()
    if Config.Framework == "esx" then
        return Framework.Object.Game.GetClosestPlayer()
    elseif Config.Framework == "qbcore" then
        local closestPlayer = Framework.Object.Functions.GetClosestPlayer()
        return closestPlayer, #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(closestPlayer)))
    elseif Config.Framework == "custom" then
        local players = GetActivePlayers()
        local closestDistance = -1
        local closestPlayer = -1
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for _, player in ipairs(players) do
            if player ~= PlayerId() then
                local targetCoords = GetEntityCoords(GetPlayerPed(player))
                local distance = #(playerCoords - targetCoords)
                
                if closestDistance == -1 or distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
        
        return closestPlayer, closestDistance
    end
    return -1, -1
end

--- Trigger server callback
--- @param name string Callback name
--- @param cb function Callback function
--- @param ... any Additional arguments
function Framework.TriggerCallback(name, cb, ...)
    if Config.Framework == "esx" then
        Framework.Object.TriggerServerCallback(name, cb, ...)
    elseif Config.Framework == "qbcore" then
        Framework.Object.Functions.TriggerCallback(name, cb, ...)
    elseif Config.Framework == "custom" then
        -- Implement custom callback
    end
end

CreateThread(function()
    Framework.Init()
end)