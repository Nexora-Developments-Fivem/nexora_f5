radioEnabled = false
playerHasRadio = false
radioFrequency = 0
micClicks = false

function CheckRadio()
    Framework.TriggerCallback("nexora:getPlayerInventory", function(inventory)
        playerHasRadio = false
        for _, item in pairs(inventory.items) do
            if item.name == Config.Radio.ItemName and item.count > 0 then
                playerHasRadio = true
                break
            end
        end
    end)
end

CreateThread(function()
    while not Framework.Ready do
        Wait(100)
    end
    CheckRadio()
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
    CheckRadio()
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    CheckRadio()
end)

AddEventHandler("esx:addInventoryItem", function(item, count)
    if item == Config.Radio.ItemName and count > 0 then
        playerHasRadio = true
    end
end)

AddEventHandler("esx:removeInventoryItem", function(item)
    if item == Config.Radio.ItemName then
        CheckRadio()
    end
end)

function KeyboardInput(entryTitle, textEntry, maxLength)
    AddTextEntry("FMMC_KEY_TIP1", entryTitle)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", textEntry, "", "", "", maxLength)
    
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    
    if UpdateOnscreenKeyboard() ~= 2 then
        return GetOnscreenKeyboardResult()
    else
        return nil
    end
end