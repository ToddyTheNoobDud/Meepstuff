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

local function lerpColor(color1, color2, alpha)
    return Color3.new(
        color1.R + (color2.R - color1.R) * alpha,
        color1.G + (color2.G - color1.G) * alpha,
        color1.B + (color2.B - color1.B) * alpha
    )
end

local function findMainPart(pet)
    return pet:FindFirstChild("main") or pet:FindFirstChild("Main")
end

local function startPetColorChange(pet)
    local mainPart = findMainPart(pet)
    if mainPart then
        if not RainbowState.originalColors[pet] then
            RainbowState.originalColors[pet] = mainPart.Color
        end
        
        local thread = task.spawn(function()
            local currentColor = mainPart.Color
            local targetColor = getRandomBrightColor()
            
            while RainbowState.enabled do
                for i = 0, 1, 0.002 do
                    if not RainbowState.enabled then break end
                    if not mainPart or not mainPart.Parent then return end
                    
                    mainPart.Color = lerpColor(currentColor, targetColor, i)
                    task.wait(0.02)
                end
                
                if RainbowState.enabled then
                    currentColor = targetColor
                    local nextColor = getRandomBrightColor()
                    targetColor = lerpColor(currentColor, nextColor, 0.7)
                    task.wait(0.030)
                end
            end
        end)
        
        RainbowState.activeThreads[pet] = thread
    end
end

local function handlePetUpdate(pet)
    local mainPart = findMainPart(pet)
    if mainPart then
        if RainbowState.enabled then
            startPetColorChange(pet)
        end
    else
        local connection
        connection = pet.ChildAdded:Connect(function(child)
            if child.Name:lower() == "main" then
                connection:Disconnect()
                if RainbowState.enabled then
                    startPetColorChange(pet)
                end
            end
        end)
        RainbowState.connections[pet] = connection
    end
end

local function restoreOriginalColors()
    for pet, originalColor in pairs(RainbowState.originalColors) do
        local mainPart = findMainPart(pet)
        if mainPart then
            mainPart.Color = originalColor
        end
    end
end

local function cleanupPet(pet)
    if RainbowState.connections[pet] then
        RainbowState.connections[pet]:Disconnect()
        RainbowState.connections[pet] = nil
    end
    
    if RainbowState.activeThreads[pet] then
        task.cancel(RainbowState.activeThreads[pet])
        RainbowState.activeThreads[pet] = nil
    end
    
    RainbowState.originalColors[pet] = nil
end

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
            for pet, thread in pairs(RainbowState.activeThreads) do
                task.cancel(thread)
            end
            restoreOriginalColors()
            RainbowState.activeThreads = {}
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

-- Function to convert table or any result to string
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
