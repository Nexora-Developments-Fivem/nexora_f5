local CURRENT_VERSION = "1.0.0"
local GITHUB_REPO = "Nexora-Developments-Fivem/nexora_f5"
local GITHUB_API_URL = ("https://api.github.com/repos/%s/releases/latest"):format(GITHUB_REPO)
local RESOURCE_NAME = GetCurrentResourceName()

local function Log(level, message)
    local prefix = ("^7[^5%s^7]"):format(RESOURCE_NAME)
    local levelColors = {
        INFO = "^4[INFO]^7",
        SUCCESS = "^2[SUCCESS]^7",
        WARNING = "^3[WARNING]^7",
        ERROR = "^1[ERROR]^7",
        DEBUG = "^6[DEBUG]^7"
    }
    print(("%s %s %s"):format(prefix, levelColors[level] or "", message))
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
    print("")
    Log("WARNING", "^3UPDATE AVAILABLE^7")
    Log("INFO", ("Current version: ^1%s^7"):format(CURRENT_VERSION))
    Log("INFO", ("Latest version: ^2%s^7"):format(latestVersion))
    Log("INFO", ("Download: ^6%s^7"):format(releaseUrl))
    print("")
end

local function DisplayUpToDate()
    Log("SUCCESS", ("Version ^2%s^7 is up to date"):format(CURRENT_VERSION))
end

local function CheckForUpdates()
    Log("INFO", "Checking for updates...")
    
    -- Vérifier d'abord si le repo existe
    local repoCheckUrl = ("https://api.github.com/repos/%s"):format(GITHUB_REPO)
    
    PerformHttpRequest(repoCheckUrl, function(repoStatus, repoData, repoHeaders)
        if repoStatus == 404 then
            Log("ERROR", "Repository not found on GitHub")
            Log("WARNING", ("Check if '%s' exists and is public"):format(GITHUB_REPO))
            return
        elseif repoStatus == 403 then
            Log("ERROR", "GitHub API rate limit exceeded")
            Log("WARNING", "Wait a few minutes before restarting the server")
            return
        elseif repoStatus ~= 200 then
            Log("ERROR", ("Failed to verify repository: HTTP %d"):format(repoStatus))
            return
        end
        
        -- Le repo existe, maintenant vérifier les releases
        PerformHttpRequest(GITHUB_API_URL, function(statusCode, responseData, headers)
            if statusCode == 0 then
                Log("ERROR", "Failed to connect to GitHub API")
                Log("WARNING", "Check your internet connection")
                return
            end
            
            if statusCode == 404 then
                Log("WARNING", "No releases found for this repository")
                Log("INFO", "Create a release on GitHub with a version tag (e.g., v1.0.0)")
                Log("INFO", ("https://github.com/%s/releases/new"):format(GITHUB_REPO))
                return
            end
            
            if statusCode == 403 then
                Log("ERROR", "GitHub API rate limit exceeded")
                Log("WARNING", "Try again in a few minutes")
                return
            end
            
            if statusCode ~= 200 then
                Log("ERROR", ("GitHub API error: HTTP %d"):format(statusCode))
                return
            end
            
            local success, data = pcall(function()
                return json.decode(responseData)
            end)
            
            if not success or not data then
                Log("ERROR", "Failed to parse GitHub API response")
                return
            end
            
            local latestVersion = data.tag_name or data.name
            local releaseUrl = data.html_url
            
            if not latestVersion then
                Log("ERROR", "Unable to extract version from GitHub release")
                Log("WARNING", "Make sure your release has a valid tag (e.g., v1.0.0)")
                return
            end
            
            if CompareVersions(CURRENT_VERSION, latestVersion) then
                DisplayUpdateAvailable(latestVersion, releaseUrl)
            else
                DisplayUpToDate()
            end
            
        end, "GET", "", {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "FiveM-Resource-Checker"
        })
        
    end, "GET", "", {
        ["Content-Type"] = "application/json",
        ["User-Agent"] = "FiveM-Resource-Checker"
    })
end

CreateThread(function()
    Wait(1000)
    CheckForUpdates()
end)

-- by tarek.dev
