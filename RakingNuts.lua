local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Toddy's hub v2",
    Icon = 0,
    LoadingTitle = "Back for more lol",
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

local teleporting = false
local targetPart = nil
local detectionRange = 50

local function runAwayFromTarget(speaker, targetPart)
    local character = speaker.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = humanoid.WalkSpeed * 2
        end
    end

    while teleporting do
        if speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = speaker.Character.HumanoidRootPart
            local humanoid = speaker.Character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.SeatPart then
                humanoid.Sit = false
                task.wait(0.0001)
            end

            if targetPart and targetPart:IsDescendantOf(workspace) then
                local targetPosition = targetPart.Position
                local distance = (targetPosition - humanoidRootPart.Position).Magnitude

                if distance <= detectionRange then
                    local runDistance = math.min(40, math.max(20, distance * 0.75))

                    local directionAwayFromTarget = (humanoidRootPart.Position - targetPosition).Unit
                    local desiredPosition = humanoidRootPart.Position + (directionAwayFromTarget * runDistance)

                    local rayOrigin = desiredPosition + Vector3.new(0, 5, 0)
                    local rayDirection = Vector3.new(0, -10, 0)
                    local collision = workspace:FindPartOnRayWithIgnoreList(
                        Ray.new(rayOrigin, rayDirection),
                        {speaker.Character}
                    )

                    if collision then
                        local alternativePositions = {
                            desiredPosition + Vector3.new(5, 0, 5),
                            desiredPosition + Vector3.new(-5, 0, 5),
                            desiredPosition + Vector3.new(5, 0, -5),
                            desiredPosition + Vector3.new(-5, 0, -5)
                        }

                        for _, pos in ipairs(alternativePositions) do
                            local altRayOrigin = pos + Vector3.new(0, 5, 0)
                            local altCollision = workspace:FindPartOnRayWithIgnoreList(
                                Ray.new(altRayOrigin, rayDirection),
                                {speaker.Character}
                            )

                            if not altCollision then
                                desiredPosition = pos
                                break
                            end
                        end
                    end

                    local targetLook = CFrame.new(desiredPosition, targetPosition)
                    local smoothness = distance < 10 and 0.05 or 0.1
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetLook, smoothness)

                    if humanoid then
                        humanoid:MoveTo(desiredPosition)
                    end
                end

            else
                warn("Target part does not exist or is not in the workspace!")
            end
        else
            warn("Speaker character or HumanoidRootPart not found!")
        end
        
        local distanceToTarget = (targetPart.Position - speaker.Character.HumanoidRootPart.Position).Magnitude
        local delay = math.max(0.01, math.min(0.05, distanceToTarget / 200))
        task.wait(delay)
    end
end

local function toggleRunningAway(value)
    teleporting = value
    local player = game.Players.LocalPlayer
    targetPart = workspace:FindFirstChild("Rake") and workspace.Rake:FindFirstChild("HumanoidRootPart")

    if teleporting and targetPart then
        runAwayFromTarget(player, targetPart)
    elseif not teleporting then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = humanoid.WalkSpeed / 2
        end
    end
end

local cameraToggle = MainTab:CreateToggle({
    Name = "Anti-Rake chase",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        toggleRunningAway(Value)
    end,
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

MainTab:CreateSection("ESP Stuff")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ESPEnabled = false

local function createHighlightForCharacter(character)
    if character and character:FindFirstChild("Humanoid") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.Adornee = character 
        highlight.FillColor = Color3.new(0, 0, 255) 
        highlight.FillTransparency = 0.8
        highlight.OutlineColor = Color3.new(0, 0, 255)
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end
end

local function removeHighlightFromCharacter(character)
    local highlight = character:FindFirstChild("Highlight")
    if highlight then
        highlight:Destroy()
    end
end

local function managePlayerHighlights(player)
    player.CharacterAdded:Connect(function(character)
        if ESPEnabled and player ~= LocalPlayer then
            createHighlightForCharacter(character)
        end
    end)

    if player.Character and ESPEnabled and player ~= LocalPlayer then
        createHighlightForCharacter(player.Character)
    end

    player.CharacterRemoving:Connect(function(character)
        removeHighlightFromCharacter(character)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    managePlayerHighlights(player)
end

Players.PlayerAdded:Connect(managePlayerHighlights)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeHighlightFromCharacter(player.Character)
    end
end)

-- Create the toggle for ESP
local cameraToggle = MainTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESPEnabled = Value

        -- Update highlights based on toggle state
        if ESPEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createHighlightForCharacter(player.Character)
                end
            end
        else
            -- Remove highlights for all players when toggled off
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    removeHighlightFromCharacter(player.Character)
                end
            end
        end
    end,
})

local cameraToggle = MainTab:CreateToggle({
    Name = "ESP Rake",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
            local eggToHighlight = workspace.Rake
            
            if eggToHighlight then
                local highlight = eggToHighlight:FindFirstChild("Highlight")

                if Value then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "Highlight"
                        highlight.Adornee = eggToHighlight
                        highlight.FillColor = Color3.new(1, 1, 0) 
                        highlight.FillTransparency = 0.5 
                        highlight.OutlineColor = Color3.new(1, 0, 0)
                        highlight.OutlineTransparency = 0
                        highlight.Parent = eggToHighlight
                    end
                else
                    if highlight then
                        highlight:Destroy()
                end
            end
        end
    end,
})

local cameraToggle = MainTab:CreateToggle({
    Name = "ESP Flare gun",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
            local eggToHighlight = workspace.FlareGunPickUp
            
            if eggToHighlight then
                local highlight = eggToHighlight:FindFirstChild("Highlight")

                if Value then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "Highlight"
                        highlight.Adornee = eggToHighlight
                        highlight.FillColor = Color3.new(1, 1, 0) 
                        highlight.FillTransparency = 0.5 
                        highlight.OutlineColor = Color3.new(1, 0, 0)
                        highlight.OutlineTransparency = 0
                        highlight.Parent = eggToHighlight
                    end
                else
                    if highlight then
                        highlight:Destroy()
                end
            end
        end
    end,
})

local cameraToggle = MainTab:CreateToggle({
    Name = "ESP Create box",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
            local eggToHighlight = workspace.Debris.SupplyCrates.Box
            
            if eggToHighlight then
                local highlight = eggToHighlight:FindFirstChild("Highlight")

                if Value then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "Highlight"
                        highlight.Adornee = eggToHighlight
                        highlight.FillColor = Color3.new(1, 1, 0) 
                        highlight.FillTransparency = 0.5 
                        highlight.OutlineColor = Color3.new(1, 0, 0)
                        highlight.OutlineTransparency = 0
                        highlight.Parent = eggToHighlight
                    end
                else
                    if highlight then
                        highlight:Destroy()
                end
            end
        end
    end,
})

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
