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
local EggsTab = Window:CreateTab("Eggs", 4483362458)
local UpgradesTab = Window:CreateTab("Upgrades", 4483362458)

MainTab:CreateSection("Toddys rewrite")

local localPlayer = game:GetService("Players").LocalPlayer
local passes = localPlayer.Passes:GetChildren()

MainTab:CreateToggle({
    Name = "Autoclick",
    CurrentValue = false,
    Flag = "Autoclick",
    Callback = function(Value)
        getgenv().autoclick = Value
        if Value then
            coroutine.wrap(function()
                while getgenv().autoclick do
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Click4"):FireServer()
                    task.wait(0.01)
                end
            end)()
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto craft ALL (10s)",
    CurrentValue = false,
    Flag = "Craft",
    Callback = function(Value)
        getgenv().craft = Value
        if Value then
            coroutine.wrap(function()
                while getgenv().craft do
                   local args = {
    [1] = "CraftAll",
    [2] = {}
}

game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Request"):InvokeServer(unpack(args))

                    task.wait(10)
                end
            end)()
        end
    end,
})


MainTab:CreateButton({
    Name = 'Get All gamepasses',
    Callback = function()
        for _, pass in ipairs(passes) do
            if pass.Name ~= "AutoChestCollect" then
                pass.Value = true
            end
        end
    game:GetService("Players").LocalPlayer.SpaceUpgrades.Teleport.Value = 1
    end
})

MainTab:CreateButton({
    Name = 'Unlock portals',
    Callback = function()
        local portals = workspace.Scripts.Portals:GetChildren()

        for _, portal in ipairs(portals) do
            if portal:IsA("Model") then
                local airUnlocked = portal:FindFirstChild("Unlocked", true)
                if airUnlocked and airUnlocked:IsA("BoolValue") then
                    airUnlocked.Value = true
                end
                
                local labelUI = portal:FindFirstChild("LabelUI", true)
                if labelUI then
                    labelUI:Destroy()
                end
            end
        end
    end
})

MainTab:CreateSection("Funny stuff")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerPets = workspace.PlayerPets[LocalPlayer.Name]

local RainbowState = {
    enabled = false,
    connections = {},
    originalColors = {},
    activeThreads = {}
}

local function getRandomBrightColor()
    local hue = math.random()
    return Color3.fromHSV(hue, 0.8, 1)
end

local function findMainPart(pet)
    return pet:FindFirstChild("main") or pet:FindFirstChild("Main")
end

local function findMeshes(pet)
    local meshes = {}
    for _, child in ipairs(pet:GetDescendants()) do
        if child:IsA("MeshPart") or child:IsA("SpecialMesh") then
            table.insert(meshes, child)
        end
    end
    return meshes
end

local function startPetColorChange(pet)
    local mainPart = findMainPart(pet)
    local meshes = findMeshes(pet)
    if mainPart or #meshes > 0 then
        if not RainbowState.originalColors[pet] then
            RainbowState.originalColors[pet] = {}
            if mainPart then
                RainbowState.originalColors[pet].mainPart = mainPart.Color
            end
            for _, mesh in ipairs(meshes) do
                RainbowState.originalColors[pet][mesh] = mesh.Color
            end
        end
        
        if RainbowState.enabled then
            local thread = task.spawn(function()
                local currentHue = 0
                local colorChangeSpeed = 0.1
                local targetColor
                
                while RainbowState.enabled do
                    currentHue = (currentHue + colorChangeSpeed * task.wait()) % 1
                    targetColor = Color3.fromHSV(currentHue, 0.8, 1)

                    if mainPart and mainPart.Parent then
                        mainPart.Color = targetColor
                    end
                    
                    for _, mesh in ipairs(meshes) do
                        if mesh.Parent then
                            mesh.Color = targetColor
                        end
                    end
                    
                    task.wait(0.03)
                end
            end)
            
            RainbowState.activeThreads[pet] = thread
        end
    end
end

local function restoreOriginalPetColors(pet)
    local mainPart = findMainPart(pet)
    if mainPart and RainbowState.originalColors[pet] and RainbowState.originalColors[pet].mainPart then
        mainPart.Color = RainbowState.originalColors[pet].mainPart
    end
    
    for _, mesh in ipairs(findMeshes(pet)) do
        if RainbowState.originalColors[pet] and RainbowState.originalColors[pet][mesh] then
            mesh.Color = RainbowState.originalColors[pet][mesh]
        end
    end
end

local function cleanupPet(pet)
    if RainbowState.connections[pet] then
        RainbowState.connections[pet]:Disconnect()
        RainbowState.connections[pet] = nil
    end
    
    if RainbowState.activeThreads[pet] then
        if not RainbowState.activeThreads[pet]:isTerminated() then
            task.cancel(RainbowState.activeThreads[pet])
        end
        RainbowState.activeThreads[pet] = nil
    end
    
    RainbowState.originalColors[pet] = nil
end

local function handlePetUpdate(pet)
    if RainbowState.originalColors[pet] then
        restoreOriginalPetColors(pet)
    end
    
    if RainbowState.enabled then
        startPetColorChange(pet)
    else
        if RainbowState.originalColors[pet] then
            restoreOriginalPetColors(pet)
        end
        
        local mainPart = findMainPart(pet)
        local meshes = findMeshes(pet)
        if not mainPart and #meshes == 0 then
            local connection
            connection = pet.ChildAdded:Connect(function(child)
                if child.Name:lower() == "main" or child:IsA("MeshPart") or child:IsA("SpecialMesh") then
                    connection:Disconnect()
                    if RainbowState.enabled then
                        startPetColorChange(pet)
                    end
                end
            end)
            RainbowState.connections[pet] = connection
        end
    end
end

local function onPetAdded(pet)
    handlePetUpdate(pet)
end

local function onPetRemoved(pet)
    cleanupPet(pet)
end

for _, pet in ipairs(PlayerPets:GetChildren()) do
    onPetAdded(pet)
end

PlayerPets.ChildAdded:Connect(onPetAdded)
PlayerPets.ChildRemoved:Connect(onPetRemoved)

local RainbowToggle = MainTab:CreateToggle({
    Name = "Rainbow Pets",
    CurrentValue = false,
    Flag = "RainbowPetsToggle",
    Callback = function(Value)
        RainbowState.enabled = Value
        
        if Value then
            for _, pet in ipairs(PlayerPets:GetChildren()) do
                handlePetUpdate(pet)
            end
        else
            for _, pet in ipairs(PlayerPets:GetChildren()) do
                restoreOriginalPetColors(pet)
            end
        end
    end,
})

PlayerPets.ChildAdded:Connect(function(pet)
    if RainbowState.enabled then
        handlePetUpdate(pet)
    end
end)

PlayerPets.ChildRemoved:Connect(function(pet)
    cleanupPet(pet)
end)

EggsTab:CreateSection("Main")
local eggs = workspace.Scripts.Eggs:GetChildren()
local eggOptions = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnboxFunction = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("Unbox")

for _, egg in ipairs(eggs) do
    table.insert(eggOptions, egg.Name)
end

table.sort(eggOptions)

local State = {
    isAutoHatching = false,
    currentEgg = nil,
    hatchType = "Single",
    cooldown = 0.6
}

local NotificationQueue = {
    maxSize = 5,
    queue = {},
    lastNotificationTime = 0,
    minInterval = 0.5  
}

local function formatResult(result)
    if typeof(result) == "table" then
        local formatted = {}
        for i, item in ipairs(result) do
            table.insert(formatted, tostring(item))
        end
        return table.concat(formatted, ", ")
    end
    return tostring(result)
end

function NotificationQueue:Add(title, content)
    local currentTime = tick()
    
    if currentTime - self.lastNotificationTime >= self.minInterval then
        self.lastNotificationTime = currentTime
        
        table.insert(self.queue, {
            Title = title,
            Content = content,
            Duration = 1,
            Image = "rewind"
        })
        
        if #self.queue > self.maxSize then
            table.remove(self.queue, 1)
        end
        
        Rayfield:Notify(self.queue[#self.queue])
    end
end

local function HatchEgg()
    if not State.currentEgg then return end
    
    local args = {
        [1] = State.currentEgg,
        [2] = State.hatchType
    }
    
    local success, result = pcall(function()
        return UnboxFunction:InvokeServer(unpack(args))
    end)
    
    if success then
        local formattedResult = formatResult(result)
        NotificationQueue:Add(
            "Egg Hatched: " .. State.currentEgg,
            "You got: " .. formattedResult
        )
    end
end

local function StartAutoHatching()
    spawn(function()
        while State.isAutoHatching do
            HatchEgg()
            task.wait(State.cooldown)
        end
    end)
end

local DropdownSingle = EggsTab:CreateDropdown({
    Name = "Auto hatch egg ",
    Options = eggOptions,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "DropdownSingle",
    Callback = function(Options)
        if Options[1] then
            State.currentEgg = Options[1]
        end
    end,
})

local HatchTypeDropdown = EggsTab:CreateDropdown({
    Name = "Hatch Type",
    Options = {"Single", "Triple"},
    CurrentOption = {"Single"},
    MultipleOptions = false,
    Flag = "HatchTypeDropdown",
    Callback = function(Options)
        if Options[1] then
            State.hatchType = Options[1]
        end
    end,
})

local Toggle = EggsTab:CreateToggle({
    Name = "Enable Auto Hatch",
    CurrentValue = false,
    Flag = "ToggleAutoHatch",
    Callback = function(Value)
        State.isAutoHatching = Value
        if Value then
            StartAutoHatching()
        end
    end,
})

local HighlightToggle = EggsTab:CreateToggle({
    Name = "Highlight Selected Egg",
    CurrentValue = false,
    Flag = "HighlightToggle",
    Callback = function(Value)
        if State.currentEgg then
            local eggToHighlight = workspace.Scripts.Eggs:FindFirstChild(State.currentEgg)
            
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
        end
    end,
})


UpgradesTab:CreateSection("Main")

UpgradesTab:CreateToggle({
    Name = "Auto Upgrade Rebirth",
    CurrentValue = false,
    Flag = "Rebirth",
    Callback = function(Value)
        getgenv().Rebirth = Value
        if Value then
            coroutine.wrap(function()
                while getgenv().Rebirth do
                    local args = {
    [1] = "RebirthButtons"
}

game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Upgrade"):InvokeServer(unpack(args))

                    task.wait(0.5)
                end
            end)()
        end
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto Upgrade Click Multi",
    CurrentValue = false,
    Flag = "Rebirth",
    Callback = function(Value)
        getgenv().click = Value
        if Value then
            coroutine.wrap(function()
                while getgenv().click do
                    local args = {
    [1] = "ClickMultiplier"
}

game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Upgrade"):InvokeServer(unpack(args))

                    task.wait(0.5)
                end
            end)()
        end
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto Upgrade Speed",
    CurrentValue = false,
    Flag = "Rebirth",
    Callback = function(Value)
        getgenv().Speed = Value
        if Value then
            coroutine.wrap(function()
                while getgenv().Speed do
local args = {
    [1] = "WalkSpeed"
}

game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Upgrade"):InvokeServer(unpack(args))

                    task.wait(0.5)
                end
            end)()
        end
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto Upgrade Gems",
    CurrentValue = false,
    Flag = "Rebirth",
    Callback = function(Value)
        getgenv().Gems = Value
        if Value then
            coroutine.wrap(function()
                while getgenv().Gems do
local args = {
    [1] = "GemsMultiplier"
}

game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Upgrade"):InvokeServer(unpack(args))

                    task.wait(0.5)
                end
            end)()
        end
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto Upgrade Storage",
    CurrentValue = false,
    Flag = "Rebirth",
    Callback = function(Value)
        getgenv().Storage = Value
        if Value then
            coroutine.wrap(function()
                while getgenv().Storage do
local args = {
    [1] = "PetStorage"
}

game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Upgrade"):InvokeServer(unpack(args))

                    task.wait(0.5)
                end
            end)()
        end
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto Upgrade Luck",
    CurrentValue = false,
    Flag = "Rebirth",
    Callback = function(Value)
        getgenv().Luck = Value
        if Value then
            coroutine.wrap(function()
                while getgenv().Luck do
local args = {
    [1] = "LuckMultiplier"
}

game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Upgrade"):InvokeServer(unpack(args))

                    task.wait(0.5)
                end
            end)()
        end
    end,
})
