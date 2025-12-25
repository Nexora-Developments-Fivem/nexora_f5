if Config.Framework == "esx" then
    if Config.ESX.UseNewESX then
        ESX = exports[Config.ESX.ResourceName]:getSharedObject()
    else
        TriggerEvent(Config.ESX.SharedObject, function(obj)
            ESX = obj
        end)
    end
elseif Config.Framework == "qbcore" then
    QBCore = exports[Config.QBCore.ResourceName]:GetCoreObject()
end

CreateThread(function()
    Wait(1000)

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS nexora_playtime (
            identifier VARCHAR(64) NOT NULL,
            playtime INT NOT NULL DEFAULT 0,
            PRIMARY KEY (identifier)
        )
    ]])
end)

--- @param source number
--- @return table
local function GetPlayer(source)
    if Config.Framework == "esx" then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == "qbcore" then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == "custom" then
        return nil
    end
end

--- @param source number
--- @return string
local function GetIdentifier(source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier
    elseif Config.Framework == "qbcore" then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid
    end
    return nil
end

--- @param source number
--- @param message string
local function ShowNotification(source, message)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.showNotification(message)
        end
    elseif Config.Framework == "qbcore" then
        TriggerClientEvent('QBCore:Notify', source, message)
    end
end

if Config.Framework == "esx" then
    ESX.RegisterServerCallback('nexora:getPlayerInventory', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return cb({ items = {} }) end

        local inventoryItems = {}

        for _, item in pairs(xPlayer.inventory) do
            inventoryItems[#inventoryItems + 1] = {
                name = item.name,
                count = item.count
            }
        end

        cb({ items = inventoryItems })
    end)
elseif Config.Framework == "qbcore" then
    QBCore.Functions.CreateCallback('nexora:getPlayerInventory', function(source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return cb({ items = {} }) end

        local inventoryItems = {}

        for _, item in pairs(Player.PlayerData.items or {}) do
            inventoryItems[#inventoryItems + 1] = {
                name = item.name,
                count = item.amount
            }
        end

        cb({ items = inventoryItems })
    end)
end

local function FetchPlayTime(identifier, cb)
    MySQL.scalar(
        'SELECT playtime FROM nexora_playtime WHERE identifier = ?',
        { identifier },
        function(playtime)
            if playtime == nil then
                MySQL.execute(
                    'INSERT INTO nexora_playtime (identifier, playtime) VALUES (?, ?)',
                    { identifier, 0 }
                )
                cb(0)
            else
                cb(playtime)
            end
        end
    )
end

if Config.Framework == "esx" then
    ESX.RegisterServerCallback('nexora:getPlayTime', function(source, cb)
        local identifier = GetIdentifier(source)
        if not identifier then return cb(0) end
        FetchPlayTime(identifier, cb)
    end)
elseif Config.Framework == "qbcore" then
    QBCore.Functions.CreateCallback('nexora:getPlayTime', function(source, cb)
        local identifier = GetIdentifier(source)
        if not identifier then return cb(0) end
        FetchPlayTime(identifier, cb)
    end)
end

CreateThread(function()
    while true do
        Wait(60000)

        local players = {}

        if Config.Framework == "esx" then
            players = ESX.GetPlayers()
        elseif Config.Framework == "qbcore" then
            players = QBCore.Functions.GetPlayers()
        end

        for _, source in ipairs(players) do
            local identifier = GetIdentifier(source)
            if identifier then
                MySQL.execute(
                    'UPDATE nexora_playtime SET playtime = playtime + 60 WHERE identifier = ?',
                    { identifier }
                )
            end
        end
    end
end)