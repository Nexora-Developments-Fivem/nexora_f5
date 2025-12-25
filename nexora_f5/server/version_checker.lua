local CURRENT_VERSION = "1.0.0"
local GITHUB_REPO = "Nexora-Developments-Fivem/nexora_f5"
local GITHUB_API_URL = ("https://api.github.com/repos/%s/releases/latest"):format(GITHUB_REPO)
local RESOURCE_NAME = GetCurrentResourceName()

local function PrintHeader()
    print("^0╔════════════════════════════════════════════════════════════╗^0")
    print("^0║^5              NEXORA DEVELOPMENTS - VERSION CHECK          ^0║^0")
    print("^0╚════════════════════════════════════════════════════════════╝^0")
end

local function PrintSuccess(message)
    print(("^0[^2Nexora Developments^0] ^2✓^0 %s^0"):format(message))
end

local function PrintWarning(message)
    print(("^0[^3Nexora Developments^0] ^3⚠^0 %s^0"):format(message))
end

local function PrintError(message)
    print(("^0[^1Nexora Developments^0] ^1✖^0 %s^0"):format(message))
end

local function PrintInfo(message)
    print(("^0[^4Nexora Developments^0] ^4ℹ^0 %s^0"):format(message))
end

local function PrintDivider()
    print("^0────────────────────────────────────────────────────────────^0")
end

---@param current string Current version (e.g., "1.0.0")
---@param latest string Latest version from GitHub (e.g., "1.2.0")
---@return boolean isOutdated True if an update is available
local function CompareVersions(current, latest)
    current = current:gsub("^v", "")
    latest = latest:gsub("^v", "")
    
    local currentParts = {}
    local latestParts = {}
    
    for part in current:gmatch("%d+") do
        table.insert(currentParts, tonumber(part))
    end
    
    for part in latest:gmatch("%d+") do
        table.insert(latestParts, tonumber(part))
    end
    
    for i = 1, math.max(#currentParts, #latestParts) do
        local currentPart = currentParts[i] or 0
        local latestPart = latestParts[i] or 0
        
        if latestPart > currentPart then
            return true
        elseif latestPart < currentPart then
            return false
        end
    end
    
    return false
end

local function DisplayUpdateAvailable(latestVersion, releaseUrl)
    print("\n")
    print("^0╔════════════════════════════════════════════════════════════╗^0")
    print("^0║^3                  ⚠ UPDATE AVAILABLE ⚠                    ^0║^0")
    print("^0╠════════════════════════════════════════════════════════════╣^0")
    print(("^0║  ^7Resource:       ^5%-37s^0║^0"):format(RESOURCE_NAME))
    print(("^0║  ^7Current Version: ^1%-37s^0║^0"):format(CURRENT_VERSION))
    print(("^0║  ^7Latest Version:  ^2%-37s^0║^0"):format(latestVersion))
    print("^0╠════════════════════════════════════════════════════════════╣^0")
    print("^0║  ^3A new version of this script is available.               ^0║^0")
    print("^0║  ^7Please update to benefit from the latest improvements,  ^0║^0")
    print("^0║  ^7bug fixes, and new features.                            ^0║^0")
    print("^0╠════════════════════════════════════════════════════════════╣^0")
    print(("^0║  ^4Download: ^6%-45s^0║^0"):format(releaseUrl))
    print("^0╚════════════════════════════════════════════════════════════╝^0")
    print("\n")
end

local function DisplayUpToDate()
    print("\n")
    PrintSuccess(("Script is up-to-date (Version: %s)"):format(CURRENT_VERSION))
    print("\n")
end

local function CheckForUpdates()
    PrintHeader()
    PrintInfo("Verifying script version with GitHub repository...")
    PrintDivider()
    
    PerformHttpRequest(GITHUB_API_URL, function(statusCode, responseData, headers)
        if statusCode == 0 then
            PrintError("Unable to connect to GitHub API.")
            PrintWarning("Please verify your internet connection or GitHub availability.")
            PrintInfo("Version check will be retried on next server restart.")
            PrintDivider()
            return
        end
        
        if statusCode ~= 200 then
            PrintError(("GitHub API returned error code: %d"):format(statusCode))
            
            if statusCode == 404 then
                PrintWarning("Repository not found. Please check GITHUB_REPO configuration.")
            elseif statusCode == 403 then
                PrintWarning("GitHub API rate limit exceeded. Try again later.")
            else
                PrintWarning("An unexpected error occurred during version check.")
            end
            
            PrintDivider()
            return
        end
        
        local success, data = pcall(function()
            return json.decode(responseData)
        end)
        
        if not success or not data then
            PrintError("Failed to parse GitHub API response.")
            PrintWarning("The response format may have changed or is corrupted.")
            PrintDivider()
            return
        end
        
        local latestVersion = data.tag_name or data.name
        local releaseUrl = data.html_url
        
        if not latestVersion then
            PrintError("Unable to extract version from GitHub release.")
            PrintWarning("Please verify that a release exists on GitHub.")
            PrintDivider()
            return
        end
        
        if CompareVersions(CURRENT_VERSION, latestVersion) then
            DisplayUpdateAvailable(latestVersion, releaseUrl)
        else
            DisplayUpToDate()
        end
        
    end, "GET", "", {
        ["Content-Type"] = "application/json",
        ["User-Agent"] = "Nexora-F5-Menu-Version-Checker"
    })
end

CreateThread(function()
    Wait(1000)
    
    CheckForUpdates()
end)