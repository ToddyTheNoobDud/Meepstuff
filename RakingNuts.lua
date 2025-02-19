local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Toddy's hub v2",
    Icon = 0,
    LoadingTitle = "Back for more lol - Updated 02/19/2025 (19/02/2025)",
    LoadingSubtitle = "by mushroom0162",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "Big Hub"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = false
    },
    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

MainTab:CreateSection("Toddys rewrite")

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local Config = {
    DETECTION_RANGE = 50,
    MIN_RUN_DISTANCE = 20,
    MAX_RUN_DISTANCE = 40,
    SPEED_MULTIPLIER = 2,
    MIN_UPDATE_DELAY = 0.01,
    MAX_UPDATE_DELAY = 0.05,
    DISTANCE_SCALING = 200,
    CLOSE_RANGE = 10,
    SMOOTHNESS_CLOSE = 0.05,
    SMOOTHNESS_FAR = 0.1,
    RAY_HEIGHT = 5,
    RAY_DEPTH = -10,
    ALTERNATIVE_OFFSETS = {
        Vector3.new(5, 0, 5),
        Vector3.new(-5, 0, 5),
        Vector3.new(5, 0, -5),
        Vector3.new(-5, 0, -5)
    }
}

local State = {
    isActive = false,
    connections = {},
    originalWalkSpeed = nil,
    targetPart = nil
}


local function clearConnections()
    for _, connection in ipairs(State.connections) do
        connection:Disconnect()
    end
    table.clear(State.connections)
end

local function findSafePosition(desiredPosition, speaker)
    local rayOrigin = desiredPosition + Vector3.new(0, Config.RAY_HEIGHT, 0)
    local rayDirection = Vector3.new(0, Config.RAY_DEPTH, 0)
    
    local collision = workspace:FindPartOnRayWithIgnoreList(
        Ray.new(rayOrigin, rayDirection),
        {speaker.Character}
    )
    
    if not collision then
        return desiredPosition
    end
    
    for _, offset in ipairs(Config.ALTERNATIVE_OFFSETS) do
        local altPosition = desiredPosition + offset
        local altRayOrigin = altPosition + Vector3.new(0, Config.RAY_HEIGHT, 0)
        local altCollision = workspace:FindPartOnRayWithIgnoreList(
            Ray.new(altRayOrigin, rayDirection),
            {speaker.Character}
        )
        
        if not altCollision then
            return altPosition
        end
    end
    
    return desiredPosition + Vector3.new(0, 2, 0)
end

local function updateTargetPart()
    local rake = workspace:FindFirstChild("Rake")
    State.targetPart = rake and rake:FindFirstChild("HumanoidRootPart")
    return State.targetPart ~= nil
end

local function runAwayFromTarget(speaker)
    local character = speaker.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not (humanoidRootPart and humanoid) then return end
    
    if humanoid.SeatPart then
        humanoid.Sit = false
        task.wait(0.0001)
    end
    
    if not (State.targetPart and State.targetPart:IsDescendantOf(workspace)) then
        return
    end
    
    local targetPosition = State.targetPart.Position
    local currentPosition = humanoidRootPart.Position
    local distance = (targetPosition - currentPosition).Magnitude
    
    if distance <= Config.DETECTION_RANGE then
        local runDistance = math.min(
            Config.MAX_RUN_DISTANCE,
            math.max(Config.MIN_RUN_DISTANCE, distance * 0.75)
        )
        
        local directionAwayFromTarget = (currentPosition - targetPosition).Unit
        local desiredPosition = currentPosition + (directionAwayFromTarget * runDistance)
        
        local safePosition = findSafePosition(desiredPosition, speaker)
        
        local targetLook = CFrame.new(safePosition, targetPosition)
        local smoothness = distance < Config.CLOSE_RANGE and 
            Config.SMOOTHNESS_CLOSE or Config.SMOOTHNESS_FAR
        
        humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetLook, smoothness)
        humanoid:MoveTo(safePosition)
        
        local delay = math.max(
            Config.MIN_UPDATE_DELAY,
            math.min(Config.MAX_UPDATE_DELAY, distance / Config.DISTANCE_SCALING)
        )
        task.wait(delay)
    end
end

local function setupTargetTracking()
    local workspaceConnection = workspace.ChildAdded:Connect(function(child)
        if child.Name == "Rake" then
            task.wait()
            updateTargetPart()
        end
    end)
    table.insert(State.connections, workspaceConnection)
    
    workspace.ChildRemoved:Connect(function(child)
        if child.Name == "Rake" then
            State.targetPart = nil
        end
    end)
    table.insert(State.connections, workspaceConnection)
end

local function toggleRunningAway(value)
    if State.isActive == value then return end
    
    State.isActive = value
    local player = Players.LocalPlayer
    
    if value then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            State.originalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = State.originalWalkSpeed * Config.SPEED_MULTIPLIER
        end
        
        updateTargetPart()
        
        setupTargetTracking()
        
        local updateConnection = RunService.Heartbeat:Connect(function()
            if State.isActive then
                runAwayFromTarget(player)
            end
        end)
        table.insert(State.connections, updateConnection)
        
    else
        clearConnections()
        
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and State.originalWalkSpeed then
            humanoid.WalkSpeed = State.originalWalkSpeed
        end
    end
end


local antiRakeToggle = MainTab:CreateToggle({
    Name = "Anti-Rake Chase",
    CurrentValue = false,
    Flag = "AntiRake",
    Callback = function(Value)
        toggleRunningAway(Value)
    end
})

local Paragraph = MainTab:CreateParagraph({
    Title = "How it works?",
    Content = "Will detect rake, and auto run away from it no matter what. Like a barrier, also blocks you from aproximating him"
})


local cameraToggle = MainTab:CreateToggle({
    Name = "Make him Chase you (method 1, will Die)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        
    end,
})

local running = false
local targetPart = nil

local function FuckOn(speaker, targetPart)
    local character = speaker.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
    end

    while running do
        if speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = speaker.Character.HumanoidRootPart
            local humanoid = speaker.Character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.SeatPart then
                humanoid.Sit = false
                task.wait(0.1)
            end

            if targetPart and targetPart:IsDescendantOf(workspace) then
                local targetPosition = targetPart.Position
                local characterPosition = humanoidRootPart.Position
                
                local directionAway = (characterPosition - targetPosition).Unit
                
                local stepDistance = 2
                humanoidRootPart.CFrame = humanoidRootPart.CFrame + directionAway * stepDistance
            else
                warn("Target part does not exist or is not in the workspace!")
            end
        else
            warn("Speaker character or HumanoidRootPart not found!")
           
        end

        task.wait(0.1)
    end
end


local function FuckOff(value)
    running = value

    if running then
        local player = game.Players.LocalPlayer
        targetPart = workspace:FindFirstChild("Rake") and workspace.Rake:FindFirstChild("HumanoidRootPart")

        if targetPart then
            FuckOn(player, targetPart)
        else
            warn("Rake not found in workspace. Will stay running")
        end
    end
end

local cameraToggle = MainTab:CreateToggle({
    Name = "Experimental Autofarm",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        FuckOff(Value)
    end,
})

local Paragraph = MainTab:CreateParagraph({
    Title = "How it works?", 
    Content = "Simple. The player will always be running in the opposite direction of the rake, no matter what."
})

local cameraToggle = MainTab:CreateButton({
    Name = "Delete fall damage",
    Callback = function()
local event = replicatedStorage:WaitForChild("FD_Event")

if event then
    event:Destroy()
    print("Successfully deleted FD_Event from ReplicatedStorage")
else
    print("FD_Event not found in ReplicatedStorage.  Could not delete.")
end
    end,
})


local cameraToggle = MainTab:CreateButton({
    Name = "Delete Instamina (Infinite)",
    Callback = function()
local M_Hs = {}

local function isModuleInTable(module)
    for _, existingModule in ipairs(M_Hs) do
        if existingModule == module then
            return true
        end
    end
    return false
end

if replicatedStorage:FindFirstChild("TKSMNA") and replicatedStorage.TKSMNA:FindFirstChild("Event") then
    local event = replicatedStorage.TKSMNA.Event
    for _, connection in ipairs(getconnections(event)) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
end

for _, module in ipairs(getloadedmodules()) do
    if module.Name == "M_H" and not isModuleInTable(module) then
        table.insert(M_Hs, module)
        local moduleScript = require(module)
        if moduleScript and moduleScript.TakeStamina then
            local oldTakeStamina = moduleScript.TakeStamina
            moduleScript.TakeStamina = function(self, amount)
                if amount > 0 then
                    return oldTakeStamina(self, -0.5)
                end
                return oldTakeStamina(self, amount)
            end
        else
            warn("M_H module does not have a TakeStamina function or is incorrectly structured.")
        end
    end
end
    end,
})


MainTab:CreateSection("ESP Stuff")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Players = {
        Enabled = false,
        FillColor = Color3.fromRGB(0, 140, 255),
        FillTransparency = 0.7,
        OutlineColor = Color3.fromRGB(0, 80, 255),
        OutlineTransparency = 0
    },
    Rake = {
        Enabled = false,
        FillColor = Color3.fromRGB(255, 0, 0),
        FillTransparency = 0.5,
        OutlineColor = Color3.fromRGB(255, 100, 0),
        OutlineTransparency = 0
    },
    FlareGun = {
        Enabled = false,
        FillColor = Color3.fromRGB(255, 200, 0),
        FillTransparency = 0.3,
        OutlineColor = Color3.fromRGB(255, 100, 0),
        OutlineTransparency = 0
    },
    SupplyBox = {
        Enabled = false,
        FillColor = Color3.fromRGB(0, 255, 0),
        FillTransparency = 0.5,
        OutlineColor = Color3.fromRGB(0, 180, 0),
        OutlineTransparency = 0
    }
}

local ESP = {
    Highlights = {},
    Connections = {}
}

function ESP:CreateHighlight(object, settings)
    if not object then return end
    
    self:RemoveHighlight(object)
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Adornee = object
    highlight.FillColor = settings.FillColor
    highlight.FillTransparency = settings.FillTransparency
    highlight.OutlineColor = settings.OutlineColor
    highlight.OutlineTransparency = settings.OutlineTransparency
    highlight.Parent = object
    
    self.Highlights[object] = highlight
    
    return highlight
end

function ESP:RemoveHighlight(object)
    local highlight = self.Highlights[object]
    if highlight then
        highlight:Destroy()
        self.Highlights[object] = nil
    end
end

function ESP:CleanupConnections()
    for _, connection in pairs(self.Connections) do
        if connection then connection:Disconnect() end
    end
    self.Connections = {}
end

function ESP:SetupPlayerESP()
    local function handleCharacter(player)
        if not player or player == LocalPlayer then return end
        
        local function updatePlayerESP(character)
            if not character then return end
            
            if Config.Players.Enabled then
                self:CreateHighlight(character, Config.Players)
                
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    local deathConnection
                    deathConnection = humanoid.Died:Connect(function()
                        self:RemoveHighlight(character)
                        if deathConnection then
                            deathConnection:Disconnect()
                        end
                    end)
                end
            else
                self:RemoveHighlight(character)
            end
        end
        
        if player.Character then
            updatePlayerESP(player.Character)
        end
        
        local characterConnection = player.CharacterAdded:Connect(updatePlayerESP)
        table.insert(self.Connections, characterConnection)
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        handleCharacter(player)
    end
    
    local playerAddedConnection = Players.PlayerAdded:Connect(handleCharacter)
    table.insert(self.Connections, playerAddedConnection)
    
    local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            self:RemoveHighlight(player.Character)
        end
    end)
    table.insert(self.Connections, playerRemovingConnection)
end

function ESP:SetupObjectESP(objectPath, configKey)
    local function updateObjectESP()
        local object = workspace:FindFirstChild(objectPath, true)
        
        if object then
            if Config[configKey].Enabled then
                self:CreateHighlight(object, Config[configKey])
                
                local destructionConnection
                destructionConnection = object.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        self:RemoveHighlight(object)
                        if destructionConnection then
                            destructionConnection:Disconnect()
                        end
                    end
                end)
            else
                self:RemoveHighlight(object)
            end
        end
    end
    
    local objectUpdateConnection = RunService.Heartbeat:Connect(function()
        updateObjectESP()
    end)
    table.insert(self.Connections, objectUpdateConnection)
end

ESP:SetupPlayerESP()
ESP:SetupObjectESP("Rake", "Rake")
ESP:SetupObjectESP("FlareGunPickUp", "FlareGun")
ESP:SetupObjectESP("Debris.SupplyCrates.Box", "SupplyBox")

local function createToggle(tab, name, configKey)
    return tab:CreateToggle({
        Name = "ESP " .. name,
        CurrentValue = Config[configKey].Enabled,
        Flag = "ESP_" .. configKey,
        Callback = function(Value)
            Config[configKey].Enabled = Value
            
            if configKey == "Players" then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        if Value then
                            ESP:CreateHighlight(player.Character, Config.Players)
                        else
                            ESP:RemoveHighlight(player.Character)
                        end
                    end
                end
            end
        end,
    })
end

createToggle(MainTab, "Players", "Players")
createToggle(MainTab, "Rake", "Rake")
createToggle(MainTab, "Flare Gun", "FlareGun")
createToggle(MainTab, "Supply Box", "SupplyBox")

local isFullBrightEnabled = false
local brightLoop = nil

local function toggleFullBright()
    if isFullBrightEnabled then
        if brightLoop then
            brightLoop:Disconnect()
            brightLoop = nil
        end
        Lighting.Brightness = 1 
        Lighting.ClockTime = 12 
        Lighting.FogEnd = 1000 
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(213, 213, 213)
    else
        local function brightFunc()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end

        brightLoop = RunService.RenderStepped:Connect(brightFunc)
    end

    isFullBrightEnabled = not isFullBrightEnabled
end

local fullBrightToggle = MiscTab:CreateToggle({
    Name = "Full Brightness",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        toggleFullBright(Value)
    end,
})

local thirdPerson = MiscTab:CreateToggle({
    Name = 'Enable Third Person',
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        getgenv().stuff = Value
local localPlayer = game:GetService("Players").LocalPlayer
local function update()
    if getgenv().stuff then
        localPlayer.CameraMaxZoomDistance = 30
        localPlayer.CameraMinZoomDistance = 0.5
    else
        localPlayer.CameraMaxZoomDistance = 0.5
        localPlayer.CameraMinZoomDistance = 0.5
    end
end

update()

while true do 
    update()
    task.wait(0.1)
end
        
    end
})
