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

MainTab:CreateSection("Toddys rewrite")

local cameraToggle = MainTab:CreateToggle({
    Name = "Unblock camera",
    CurrentValue = false,
    Flag = "CameraToggle",
    Callback = function(Value)
        if Value then
            game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = 10
            game:GetService("Players").LocalPlayer.CameraMinZoomDistance = 0
            game:GetService("Players").LocalPlayer.PlayerGui.FirstPerson.Value = false
        else
            game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = 10
            game:GetService("Players").LocalPlayer.CameraMinZoomDistance = 100
            game:GetService("Players").LocalPlayer.PlayerGui.FirstPerson.Value = true
        end
    end
})


MainTab:CreateButton({
    Name = "Collect all batteries",
    Callback = function()
        local batteryNames = {"Battery1", "Battery2", "Battery3", "Battery4"}
        
        for _, batteryName in pairs(batteryNames) do
            local battery = workspace:FindFirstChild("SpawnedObjects"):FindFirstChild(batteryName)
            
            if battery and battery:FindFirstChild("Handle") then
                local clickDetector = battery.Handle:FindFirstChild("ClickDetector")
                
                if clickDetector then
                    fireclickdetector(clickDetector)
                else
                    warn("ClickDetector not found for " .. batteryName)
                end
            else
                warn(batteryName .. " not found or missing Handle.")
            end
        end
    end
})


MainTab:CreateToggle({
    Name = "Spam axes (funny temp lag)",
    CurrentValue = false,
    Flag = "SpawnPartsToggle",
    Callback = function(Value)
    local player = game.Players.LocalPlayer
getgenv().active = Value
local targetAxCount = 5

local axe = workspace:WaitForChild("Axe")
local handle = axe:WaitForChild("Handle")
local clickDetector = handle:WaitForChild("ClickDetector")

local function acquireTool()
    fireclickdetector(clickDetector)
end

local function cloneAxe()
    if axe and axe:IsA("Tool") then
        local clonedAxe = axe:Clone()
        
        if clonedAxe:IsA("Tool") then
            clonedAxe.Parent = player.Backpack
            return clonedAxe
        else
            warn("Cloned object is not a Tool")
            return nil
        end
    else
        warn("Axe is not valid or not a Tool")
        return nil
    end
end

local function equipAllTools()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Axe" then
                humanoid:EquipTool(tool)
                wait(0.05)
            end
        end
    else
        warn("Humanoid not found in Character")
    end
end

local function dropAllAxes()
    local character = player.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Axe" then
                tool.Parent = workspace
            end
        end
    else
        warn("Character not found")
    end
end

while getgenv().active do
    local currentAxCount = 0

    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Axe" then
            currentAxCount = currentAxCount + 1
        end
    end

    while currentAxCount < targetAxCount do
        acquireTool()
        wait(0.05)
        currentAxCount = currentAxCount + 1
    end

    equipAllTools()
    dropAllAxes()
    wait(0.05)
end
    end,
})

local HighlightToggle = MainTab:CreateToggle({
    Name = "Highlight Orotund",
    CurrentValue = false,
    Flag = "HighlightToggle",
    Callback = function(Value)
        local orotund = workspace:FindFirstChild("TheOrotund")
        
        if orotund then
            if Value then
                local highlight = Instance.new("Highlight")
                highlight.Parent = orotund
                highlight.FillColor = Color3.new(1, 0, 0) 
                highlight.OutlineColor = Color3.new(1, 1, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0 
            else
                local highlight = orotund:FindFirstChildOfClass("Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        else
            warn("The object 'TheOrotund' not found in workspace")
        end
    end
})

local teleporting = false

local function teleportPlayerLoop(speaker, targetPart)
    local character = speaker.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 1000
            humanoid.Health = 1000
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
                local targetCFrame = targetPart.CFrame
                local targetPosition = targetCFrame.Position
                local targetLookVector = targetCFrame.LookVector
                local targetUpVector = targetCFrame.UpVector

                local offsetPosition = targetPosition + (targetLookVector * 40)

                local collision = workspace:FindPartOnRayWithIgnoreList(Ray.new(offsetPosition, Vector3.new(0, -10, 0)), {speaker.Character})

                if not collision then
                    humanoidRootPart.CFrame = CFrame.new(offsetPosition, targetPosition)
                else
                    local safePosition = offsetPosition
                    local safe = false

                    for i = 1, 10 do
                        safePosition = offsetPosition + (targetUpVector * i)
                        collision = workspace:FindPartOnRayWithIgnoreList(Ray.new(safePosition, Vector3.new(0, -10, 0)), {speaker.Character})

                        if not collision then
                            safe = true
                            break
                        end

                        safePosition = offsetPosition - (targetUpVector * i)
                        collision = workspace:FindPartOnRayWithIgnoreList(Ray.new(safePosition, Vector3.new(0, -10, 0)), {speaker.Character})

                        if not collision then
                            safe = true
                            break
                        end
                    end

                    if safe then
                        humanoidRootPart.CFrame = CFrame.new(safePosition, targetPosition)
                    end
                end
            else
                warn("Target part does not exist or is not in the workspace!")
            end
        else
            warn("Speaker character or HumanoidRootPart not found!")
        end

        task.wait(0.0001)

        if character and humanoid then
            humanoid.Health = 1000
        end
    end
end

local HighlightToggle = MainTab:CreateToggle({
    Name = "Make him chase you (Experimental)",
    CurrentValue = false,
    Flag = "TeleportToggle",
    Callback = function(Value)
        teleporting = Value

        local player = game.Players.LocalPlayer
        local targetPart = workspace.TheOrotund.HumanoidRootPart

        if teleporting then
            teleportPlayerLoop(player, targetPart)
        end
    end,
})
