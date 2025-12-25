Config = Config or {}

--- Framework configuration
--- @field Framework string The framework to use ("esx", "qbcore", "custom")
Config.Framework = "esx"

--- Framework-specific settings
--- @field ESX table ESX framework configuration
Config.ESX = {
    ResourceName = "es_extended",
    UseNewESX = true,
    SharedObject = "esx:getSharedObject"
}

--- @field QBCore table QBCore framework configuration
Config.QBCore = {
    ResourceName = "qb-core",
    SharedObject = "QBCore:GetObject"
}

--- @field Custom table Custom framework configuration
Config.Custom = {
    ResourceName = "your_framework",
    GetFramework = function()
        -- Implement your custom framework getter
        return exports["your_framework"]:GetFramework()
    end
}