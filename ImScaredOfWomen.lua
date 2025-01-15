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

local Connection = game:GetService("ReplicatedStorage"):WaitForChild("Connection")
local FunctionConnections = game:GetService("ReplicatedStorage"):WaitForChild("FunctionConnections")
local NewAERequestSetCheesyEffect = FunctionConnections:WaitForChild("NewAERequestSetCheesyEffect")
local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local CharacterTab = Window:CreateTab("Character", 4483362458)

MainTab:CreateSection("Toddys rewrite")
PlayerTab:CreateSection("Player Mods")
VisualTab:CreateSection("Visual Effects")
CharacterTab:CreateSection("Character Modifications")

local args1 = {201, 1314, {}}
local args2 = {202}

-- Function to create spawner
local function createSpawner()
    while true do
        local randX = math.random(-500, 500)
        local randY = math.random(0, 500)
        local randZ = math.random(-500, 500)
        local spawnerPart = Instance.new("Part")
        spawnerPart.Position = Vector3.new(randX, randY, randZ)
        spawnerPart.Anchored = true
        spawnerPart.Transparency = 1
        spawnerPart.Name = "SpawnerPart"
        spawnerPart.BrickColor = BrickColor.new(math.random(1, 128))
        spawnerPart.Size = Vector3.new(10, 10, 10)
        spawnerPart.Material = Enum.Material.Neon
        spawnerPart.CanCollide = false
        spawnerPart.Parent = game.Workspace

        local function spawnBalloons()
            local args1 = { [1] = 201, [2] = 1312, [3] = {} }
            local args2 = { [1] = 202 }
            while true do
                game:GetService("ReplicatedStorage"):WaitForChild("Connection"):InvokeServer(unpack(args1))
                game:GetService("ReplicatedStorage"):WaitForChild("Connection"):InvokeServer(unpack(args2))
                task.wait(0.05)
            end
        end

        task.spawn(function()
            spawnBalloons()
        end)
        task.wait(0.01)
    end
end

MainTab:CreateButton({
    Name = "Spawn Parts with Balloons",
    Callback = function()
        task.spawn(createSpawner)
    end,
})

MainTab:CreateInput({
   Name = "Music background",
   CurrentValue = "",
   PlaceholderText = "Id here",
   RemoveTextAfterFocusLost = false,
   Flag = "Input1",
   Callback = function(Text)
   local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Global = require(ReplicatedStorage:WaitForChild("Global"))

local BackgroundAudioPlayer = nil
local BackgroundAudioFader = nil

local MUSIC_ID = "rbxassetid://" .. Text

function StopExistingAudio()
    local existingAudio = PlayerGui:FindFirstChild("BackgroundAudioPlayer")
    if existingAudio then
        existingAudio:Stop()  
        existingAudio:Destroy()  
    end
end

function InitializeBackgroundMusic()
    StopExistingAudio()  

    local sound = Instance.new("Sound")
    sound.Name = "BackgroundAudioPlayer"
    sound.Looped = false
    sound.SoundId = MUSIC_ID
    
    local audioFader = Instance.new("Sound")
    audioFader.Name = "BackgroundAudioFader"
    audioFader.Volume = 0 

    sound.Parent = PlayerGui  
    audioFader.Parent = sound  

    BackgroundAudioPlayer = sound   
    BackgroundAudioFader = audioFader 

    task.spawn(function()
        local volume = Players.LocalPlayer:GetAttribute("SettingBackgroundMusicVolume")
        if not volume then
            print("[NewVirtualWorld.InitializeBackgroundMusic]", "Waiting for SettingBackgroundMusicVolume")
            Players.LocalPlayer:GetAttributeChangedSignal("SettingBackgroundMusicVolume"):Wait()
            volume = Players.LocalPlayer:GetAttribute("SettingBackgroundMusicVolume")
            print("[NewVirtualWorld.InitializeBackgroundMusic]", "SettingBackgroundMusicVolume Replicated!")
        end
        Global.AssertVar(volume, "number", "PlayerSavedBackgroundMusicVolume")
        sound.Volume = volume 
    end)

    sound:Play()  
end

InitializeBackgroundMusic()
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "Spam balloons",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       if Value then
           getgenv().LoopActive = true
           task.spawn(function()
               while getgenv().LoopActive and task.wait(0.0000001) do
                   Connection:InvokeServer(unpack(args1))
                   Connection:InvokeServer(unpack(args2))
               end
           end)
       else
           getgenv().LoopActive = false
       end
   end,
})

local Toggle = MainTab:CreateToggle({
    Name = 'Crazy Effects',
    CurrentValue = false,
    Flag = "Toggle2",
    Callback = function(Value)
       if Value then
           getgenv().stupidity = true
           task.spawn(function()
               while getgenv().stupidity and task.wait(0.0000001) do
                   NewAERequestSetCheesyEffect:InvokeServer(3, true)
                   wait(1)
                   NewAERequestSetCheesyEffect:InvokeServer(1, true)
                   wait(0.5)
                   NewAERequestSetCheesyEffect:InvokeServer(2, true)
                   wait(1)
               end
           end)
       else
           getgenv().stupidity = false
       end
   end,
})

-- WalkSpeed Slider
local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
})

-- JumpPower Slider
local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end,
})

-- Infinite Jump Toggle
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        getgenv().InfiniteJump = Value
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if getgenv().InfiniteJump then
                game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
            end
        end)
    end,
})

-- Rainbow Character Toggle
local Toggle = VisualTab:CreateToggle({
    Name = "Rainbow Character",
    CurrentValue = false,
    Flag = "RainbowToggle",
    Callback = function(Value)
        if Value then
            getgenv().rainbow = true
            task.spawn(function()
                while getgenv().rainbow and task.wait() do
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if character then
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                            end
                        end
                    end
                end
            end)
        else
            getgenv().rainbow = false
        end
    end,
})

-- Remove Textures Button
VisualTab:CreateButton({
    Name = "Remove Textures",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    end,
})

-- Notify Function
local function Notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
    })
end

-- Make Giant Function
local function makeGiant()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    if character and humanoid then
        if not getgenv().originalSizes then
            getgenv().originalSizes = {}
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    getgenv().originalSizes[part] = part.Size
                end
            end
        end
        -- Scale the character
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = getgenv().originalSizes[part] * 5
            end
        end
        humanoid.HipHeight = humanoid.HipHeight * 5
    end
end

-- Reset Size Function
local function resetSize()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    if character and humanoid and getgenv().originalSizes then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and getgenv().originalSizes[part] then
                part.Size = getgenv().originalSizes[part]
            end
        end
        humanoid.HipHeight = 2
        getgenv().originalSizes = nil
    end
end

-- Character Size Slider
local SizeSlider = CharacterTab:CreateSlider({
    Name = "Character Size",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "CharacterSizeSlider",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoid = character:FindFirstChild("Humanoid")
        if character and humanoid then
            if not getgenv().originalSizes then
                getgenv().originalSizes = {}
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        getgenv().originalSizes[part] = part.Size
                    end
                end
            end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and getgenv().originalSizes[part] then
                    part.Size = getgenv().originalSizes[part] * Value
                end
            end
            humanoid.HipHeight = 2 * Value
        end
    end,
})

-- Giant Mode Toggle
CharacterTab:CreateToggle({
    Name = "Giant Mode",
    CurrentValue = false,
    Flag = "GiantToggle",
    Callback = function(Value)
        if Value then
            makeGiant()
        else
            resetSize()
        end
    end,
})

-- Reset Size Button
CharacterTab:CreateButton({
    Name = "Reset Size",
    Callback = function()
        resetSize()
        SizeSlider:Set(1)
    end,
})

-- Fly Feature
local FlyToggle = PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("Humanoid") then return end
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")

        local flySpeed = 100  -- Speed while flying
        local bodyVelocity
        local heartbeatConnection
        local deathConnection

        local function handleInput()
            if not rootPart or not bodyVelocity then return end
            local moveDirection = Vector3.new(0, 0, 0)
            local camera = workspace.CurrentCamera
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector

            -- Forward/Backward relative to camera
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            end
            -- Left/Right relative to camera
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - Vector3.new(rightVector.X, 0, rightVector.Z).Unit
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + Vector3.new(rightVector.X, 0, rightVector.Z).Unit
            end
            -- Up/Down
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            -- Apply movement
            bodyVelocity.Velocity = moveDirection.Unit * flySpeed
        end

        local function startFlying()
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Parent = rootPart

            rootPart.Anchored = false
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

            heartbeatConnection = RunService.Heartbeat:Connect(handleInput)
        end

        local function stopFlying()
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
            if heartbeatConnection then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
            end
            if humanoid and humanoid.Parent then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            end
            if rootPart then
                rootPart.Anchored = false
            end
        end

        if Value then
            startFlying()
        else
            stopFlying()
        end

        if deathConnection then
            deathConnection:Disconnect()
        end
        deathConnection = humanoid.Died:Connect(function()
            stopFlying()
        end)
    end,
})

-- Reset original sizes on character added
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    getgenv().originalSizes = nil
    task.wait(0.5)
    if CharacterTab.Flags.GiantToggle then
        makeGiant()
    end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    Notify("Anti-AFK", "Prevented AFK kick", 3)
end)
