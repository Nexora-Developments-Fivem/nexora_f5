if not Config.Billing.Enabled then return end

if Config.Framework == "esx" then
    if Config.ESX.UseNewESX then
        ESX = exports[Config.ESX.ResourceName]:getSharedObject()
    else
        CreateThread(function()
            while ESX == nil do
                TriggerEvent(Config.ESX.SharedObject, function(obj)
                    ESX = obj
                end)
                Wait(100)
            end
        end)
    end
elseif Config.Framework == "qbcore" then
    QBCore = exports[Config.QBCore.ResourceName]:GetCoreObject()
end

--- @param source number
--- @return string
local function GetIdentifier(source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
    elseif Config.Framework == "qbcore" then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    end
end

if Config.Framework == "esx" then
    ESX.RegisterServerCallback('nexora:getBills', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return cb({}) end

        local result = MySQL.query.await(
            'SELECT amount, id, label FROM billing WHERE identifier = ?',
            { xPlayer.identifier }
        )

        cb(result or {})
    end)

    ESX.RegisterServerCallback('nexora:payBill', function(source, cb, billId)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return cb(false) end

        local result = MySQL.single.await(
            'SELECT sender, target_type, target, amount FROM billing WHERE id = ?',
            { billId }
        )

        if not result then return cb(false) end

        local amount = result.amount
        local xTarget = ESX.GetPlayerFromIdentifier(result.sender)

        if result.target_type == 'player' then
            if not xTarget then
                xPlayer.showNotification("~r~Le joueur n'est pas en ligne.")
                return cb(false)
            end

            local account = 'money'
            if xPlayer.getMoney() < amount then
                account = 'bank'
                if xPlayer.getAccount('bank').money < amount then
                    xPlayer.showNotification("~r~Vous n'avez pas assez d'argent.")
                    xTarget.showNotification("~r~Le joueur n'a pas assez d'argent.")
                    return cb(false)
                end
            end

            local rows = MySQL.update.await(
                'DELETE FROM billing WHERE id = ?',
                { billId }
            )

            if rows ~= 1 then return cb(false) end

            xPlayer.removeAccountMoney(account, amount, "Facture payée")
            xTarget.addAccountMoney(account, amount, "Paiement facture")

            xPlayer.showNotification("~g~Facture payée avec succès.")
            xTarget.showNotification("~g~Paiement reçu.")

            return cb(true)
        end

        TriggerEvent('esx_addonaccount:getSharedAccount', result.target, function(account)
            local payment = 'money'

            if xPlayer.getMoney() < amount then
                payment = 'bank'
                if xPlayer.getAccount('bank').money < amount then
                    xPlayer.showNotification("~r~Vous n'avez pas assez d'argent.")
                    return cb(false)
                end
            end

            local rows = MySQL.update.await(
                'DELETE FROM billing WHERE id = ?',
                { billId }
            )

            if rows ~= 1 then return cb(false) end

            xPlayer.removeAccountMoney(payment, amount, "Facture payée")
            account.addMoney(amount)

            xPlayer.showNotification("~g~Facture payée avec succès.")
            cb(true)
        end)
    end)

elseif Config.Framework == "qbcore" then
    QBCore.Functions.CreateCallback('nexora:getBills', function(source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return cb({}) end

        local result = MySQL.query.await(
            'SELECT amount, id, label FROM bills WHERE citizenid = ?',
            { Player.PlayerData.citizenid }
        )

        cb(result or {})
    end)

    QBCore.Functions.CreateCallback('nexora:payBill', function(source, cb, billId)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return cb(false) end

        local result = MySQL.single.await(
            'SELECT amount FROM bills WHERE id = ?',
            { billId }
        )

        if not result then return cb(false) end

        if Player.Functions.RemoveMoney('bank', result.amount, 'bill-paid') then
            MySQL.update.await('DELETE FROM bills WHERE id = ?', { billId })
            TriggerClientEvent('QBCore:Notify', source, 'Bill paid successfully!', 'success')
            cb(true)
        else
            TriggerClientEvent('QBCore:Notify', source, 'Not enough money!', 'error')
            cb(false)
        end
    end)
end
