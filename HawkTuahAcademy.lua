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
local passes = localPlayer.PlayerData.Passes:GetChildren()


local cameraToggle = MainTab:CreateToggle({
    Name = "AutoClick",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(Value)
       getgenv().autoclick = Value
       while autoclick do 
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Click"):FireServer()
        task.wait(0.01)
       end
    end
})

MainTab:CreateButton({
    Name = 'Get All gamepasses',
    Callback = function()
        for _, pass in ipairs(passes) do
            pass.Value = true
        end
    end
})

MainTab:CreateButton({
    Name = 'Get Group Chest (bypass group req)',
    Callback = function()
    fireproximityprompt(workspace.GroupChest["Meshes/groupchest_Cube.109"].ReceiveRewardPrompt)
    end
})

local cameraToggle = MainTab:CreateToggle({
    Name = "Free potions (unlimited)",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(Value)
       getgenv().fucking = Value
       while fucking do 
        fireproximityprompt(workspace.GroupChest["Meshes/groupchest_Cube.109"].ReceiveRewardPrompt)
        task.wait(0.01)
       end
    end
})


local StuffToggle = MainTab:CreateToggle({
    Name = "Auto collect SnowFlakes (TouchInterest, Can crash)",
    CurrentValue = false,
    Flag = "Snowflake",
    Callback = function(Value)
        getgenv().yes = Value
    end
})

local function getVisibleSnowflakes()
    local success, result = pcall(function() return workspace.Scripted.Islands.Christmas.VisibleSnowflakes end)
    if not success then warn("Failed to find VisibleSnowflakes container") return nil end
    return result
end

local function getCharacter()
    if not localPlayer then warn("LocalPlayer not found") return nil end
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    if not character then warn("Character not found") return nil end
    for i = 1, 50 do
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then return character, humanoidRootPart end
        task.wait(0.1)
    end
    warn("HumanoidRootPart not found after waiting")
end

local function collectSnowflakes()
    local visibleSnowflakes = getVisibleSnowflakes()
    if not visibleSnowflakes then return end
    local character, humanoidRootPart = getCharacter()
    if not character or not humanoidRootPart then return end
    
    for _, snowflake in ipairs(visibleSnowflakes:GetChildren()) do
        if snowflake:IsA("BasePart") and snowflake:FindFirstChild("TouchInterest") then
            local success, err = pcall(function()
                firetouchinterest(humanoidRootPart, snowflake, 0)
                task.wait(0.1)
                firetouchinterest(humanoidRootPart, snowflake, 1)
            end)
            if not success then warn("Failed to fire touch interest for", snowflake.Name, "-", err) end
            task.wait(0.2)
        end
    end
end


local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    if getgenv().yes then
        pcall(collectSnowflakes)
        task.wait(0.6)
    end
end)

local StuffToggle = MainTab:CreateToggle({
    Name = "Auto collect SnowFlakes (Remotes)",
    CurrentValue = false,
    Flag = "SnowflakeRemote",
    Callback = function(Value)
        getgenv().no = Value
        while no do 
        local args = {
    [1] = 1000
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CollectSnowflake"):FireServer(unpack(args))
task.wait(0.1)
    end
    end
})

MainTab:CreateButton({
    Name = 'Unlock All Portals',
    Callback = function()
        local portals = workspace.Scripted.Portals:GetChildren()
        local unlockedCount = 0
        
        for _, portal in ipairs(portals) do
            if portal:IsA("Model") then
                local lockMesh = portal:FindFirstChild("Lock")
                if lockMesh then
                    lockMesh.CanCollide = false
                    unlockedCount = unlockedCount + 1
                end
            end
        end

        Rayfield:Notify({
            Title = "Portal Unlock Status",
            Content = "Successfully unlocked " .. unlockedCount .. " portals!",
            Duration = 1.2,
            Image = 4483362458,
        })
    end
})

MainTab:CreateSection("Teleport Area")
local workspace = game:GetService("Workspace")
local Islands = {}

local islands = workspace.Scripted.Islands:GetChildren()
for _, island in ipairs(islands) do
    if island:IsA("Model") then
        table.insert(Islands, island.Name)
    end
end

local State = {
    currentIsland = nil
}

local DropdownSingle = MainTab:CreateDropdown({
    Name = "Select Island",
    Options = Islands,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "DropdownSingle",
    Callback = function(Options)
        if Options[1] then
            State.currentIsland = Options[1]
        end
    end,
})

local function getMeshes(model)
    local meshes = {}
    
    local function scanForMeshes(instance)
        for _, child in ipairs(instance:GetChildren()) do
            if child:IsA("MeshPart") then
                table.insert(meshes, child)
            end
            scanForMeshes(child)
        end
    end
    
    scanForMeshes(model)
    return meshes
end

MainTab:CreateButton({
    Name = 'Teleport to Island',
    Callback = function()
        if not State.currentIsland then
            warn("No island selected! Please select an island from the dropdown.")
            return
        end
        
        local selectedIslandModel = workspace.Scripted.Islands:FindFirstChild(State.currentIsland)
        if selectedIslandModel then
            local spawnPortal = selectedIslandModel:FindFirstChild("SpawnPortal")
            if spawnPortal then
                local decore = spawnPortal:FindFirstChild("decore")
                if decore then
                    local meshes = getMeshes(decore)
                    
                    if #meshes > 0 then
                        localPlayer.Character:SetPrimaryPartCFrame(meshes[1].CFrame)
                    else
                        warn("No meshes found in the selected island's decore!")
                    end
                else
                    warn("No 'decore' found for the selected island!")
                end
            else
                warn("No 'SpawnPortal' found for the selected island!")
            end
        else
            warn("Island model not found!")
        end
    end
})

MainTab:CreateButton({
    Name = 'Teleport to Spawn',
    Callback = function()
        localPlayer.Character:SetPrimaryPartCFrame(CFrame.new(265, 91.9280396, 64))
    end
})


local eggs = workspace.Scripted.EggHolders:GetChildren()
local eggOptions = {}
local UnboxFunction = game:GetService("ReplicatedStorage"):WaitForChild("Functions"):WaitForChild("Hatch")

for _, egg in ipairs(eggs) do
    table.insert(eggOptions, egg.Name)
end

table.sort(eggOptions)

local State = {
    isAutoHatching = false,
    currentEgg = nil,
    hatchType = "Single",
    cooldown = 0.9
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
            local eggToHighlight = workspace.Scripted.EggHolders:FindFirstChild(State.currentEgg)
            
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
local UpgradesTab = Window:CreateTab("Upgrades", 4483362458)
UpgradesTab:CreateSection("Toddys rewrite")


local selectedPotions = {}
local potionQuantity = 1
local autoBuyPotions = false

UpgradesTab:CreateDropdown({
    Name = "Select Upgrades",
    Options = {"Click Multiplier", "Gem Multiplier", "Rebirth Buttons", "Walkspeed", "Storage"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "PotionDropdown", 
    Callback = function(Options)
        selectedPotions = Options
    end,
})

UpgradesTab:CreateToggle({
    Name = "Auto buy selected Upgrades",
    CurrentValue = false,
    Flag = "AutoBuyPotions",
    Callback = function(Value)
        autoBuyPotions = Value
        
        if Value then
            coroutine.wrap(function()
                while autoBuyPotions do
                    for _, potion in ipairs(selectedPotions) do
                        local args = {"Spawn", potion}
                        if potion == "Click Multiplier" then
                            args = {"Spawn", "ClickMultiplier"}
                        elseif potion == "Gem Multiplier" then
                            args = {"Spawn", "GemMultiplier"}
                        elseif potion == "Rebirth Buttons" then
                            args = {"Spawn", "RebirthButtons"}
                        elseif potion == "Walkspeed" then
                            args = {"Spawn", "MoreWalkSpeed"}
                        elseif potion == "Storage" then
                            args = {"Spawn", "MoreStorage"}
                        elseif potion == "2x Hatch Speed" then
                            args = {"Spawn", "ClickMultiplier"}
                        end
                        
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PurchaseUpgrade"):FireServer(unpack(args))
                    end
                    task.wait(0.5)
                end
            end)()
        end
    end,
})

getgenv().AutoBuyPotions = autoBuyPotions
