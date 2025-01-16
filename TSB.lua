

-- THIS SCRIPT IS FOR  https://www.roblox.com/games/10449761463/KJ-The-Strongest-Battlegrounds



local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local CONFIG = {
    ATTACK_RANGE = 50, -- Maximum distance for evaluating threats
    DANGER_THRESHOLD = 0.8, -- Activation threshold for blocking interactions
    REACTION_TIME = 0.02, -- Reaction buffer (in seconds)
    SHIELD_COOLDOWN = 0.2, -- Time in seconds before shield can be activated again
    BLOCK_DURATION = 0.3, -- Time shield remains active
    VELOCITY_IMPACT_FACTOR = 0.6, -- Weight of calculated velocity for proximity-based threat
    DASH_VELOCITY_THRESHOLD = 20, -- Velocity threshold to identify dash-like movements
    MINIMUM_VELOCITY_FOR_THREAT = 0.1, -- Minimum velocity to consider a player moving
    TRAJECTORY_PRECISION = 15, -- Precision for predicted future positions in units
    ANIMATIONS_THREAT_KEYWORDS = { -- Keywords for attacks
        "slash", "stab", "swing", "punch", "kick", "attack", "m1", "strike", "jump", "lunge", "dash",
    },
    DEBUG_MODE = true, -- If true, logs debug messages
    ADDITIONAL_BLOCK_DISTANCE = 5, -- Buffer for detecting imminent and highly localized threats
    VELOCITY_HISTORY_LIMIT = 15, -- Number of velocity frames stored for patterns
}

-- Auto-parry System State
local State = {
    autoParryEnabled = true,
    lastShieldTime = 0,
    playerVelocities = {},
    trackedAnimations = {},
}

-- Debug Function
local function debugLog(message)
    if CONFIG.DEBUG_MODE then
        print("[DEBUG] " .. message)
    end
end

-- Utility Function: Check if a player is alive
local function isAlive(player)
    local character = player.Character
    if not character then return false end

    local humanoid = character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Threat System
local ThreatSystem = {}

-- Updates player's velocity history for more accurate movement prediction
function ThreatSystem:updatePlayerVelocity(player)
    if not State.playerVelocities[player] then
        State.playerVelocities[player] = {}
    end

    local history = State.playerVelocities[player]
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if rootPart then
        table.insert(history, rootPart.Velocity)
        if #history > CONFIG.VELOCITY_HISTORY_LIMIT then
            table.remove(history, 1) -- Remove oldest data to limit history size
        end
    end
end

-- Predicts a player's future position based on velocity
function ThreatSystem:predictPlayerPosition(player)
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local velocity = rootPart.Velocity
    local futurePosition = rootPart.Position + (velocity * (CONFIG.REACTION_TIME + CONFIG.BLOCK_DURATION))
    return futurePosition
end

-- Checks if a player is exhibiting behavior resembling a dash
function ThreatSystem:isPlayerDashing(player)
    local history = State.playerVelocities[player]
    if not history or #history < 2 then return false end

    local currentVelocity = history[#history]
    local previousVelocity = history[#history - 1]

    local velocityChange = (currentVelocity - previousVelocity).Magnitude
    return velocityChange > CONFIG.DASH_VELOCITY_THRESHOLD
end

-- Checks if a player has the "M1ing" accessory
function ThreatSystem:isPlayerAttacking(player)
    local character = player.Character
    if not character then return false end

    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") and accessory.Name == "M1ing" then
            return true
        end
    end
    return false
end

-- Checks if a player is ragdolling
function ThreatSystem:isPlayerRagdolling(player)
    local character = player.Character
    if not character then return false end

    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") and (accessory.Name == "Ragdoll" or accessory.Name == "RagdollSim") then
            return true
        end
    end
    return false
end

-- Evaluates the threat level of a specific player
-- Factors: Proximity, velocity, animations, and trajectory prediction
function ThreatSystem:evaluateThreat(player)
    if not player.Character or not isAlive(player) or not LocalPlayer.Character then return 0 end

    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not playerRoot or not localRoot then return 0 end

    -- Check velocity; ignore players who are idle
    if playerRoot.Velocity.Magnitude < CONFIG.MINIMUM_VELOCITY_FOR_THREAT then
        return 0
    end

    local currentDistance = (localRoot.Position - playerRoot.Position).Magnitude
    if currentDistance > CONFIG.ATTACK_RANGE then return 0 end

    -- Proximity-based threat factor
    local threatLevel = 1 - (currentDistance / CONFIG.ATTACK_RANGE)

    -- Add velocity impact
    local velocityImpact = math.clamp(playerRoot.Velocity.Magnitude / 25, 0, 1) * CONFIG.VELOCITY_IMPACT_FACTOR
    threatLevel = threatLevel + velocityImpact

    -- Detect imminent trajectory collisions
    local futurePosition = self:predictPlayerPosition(player)
    if (futurePosition - localRoot.Position).Magnitude < CONFIG.ADDITIONAL_BLOCK_DISTANCE then
        threatLevel = threatLevel + 0.4 -- Add extra weight for trajectory collision
        debugLog(player.Name .. " is dangerously close based on trajectory prediction!")
    end

    -- Detect dashing behavior
    if self:isPlayerDashing(player) then
        threatLevel = threatLevel + 0.5
        debugLog(player.Name .. " is dashing!")
    end

    -- Detect active attack animations
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local animator = humanoid and humanoid:FindFirstChild("Animator")

    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local animName = track.Animation.Name:lower()
            for _, keyword in ipairs(CONFIG.ANIMATIONS_THREAT_KEYWORDS) do
                if animName:find(keyword) then
                    threatLevel = threatLevel + 0.6 -- Add threat from animations
                    debugLog(player.Name .. " is playing a threatening animation (" .. animName .. ")!")
                    break
                end
            end
        end
    end

    -- Detect "M1ing" accessory
    if self:isPlayerAttacking(player) then
        threatLevel = threatLevel + 0.7
        debugLog(player.Name .. " is attacking with the 'M1ing' accessory!")
    end

    -- Detect ragdolling
    if self:isPlayerRagdolling(player) then
        threatLevel = threatLevel + 0.8
        debugLog(player.Name .. " is ragdolling!")
    end

    return math.clamp(threatLevel, 0, 1)
end

-- Finds the most threatening player in the vicinity
function ThreatSystem:getHighestThreatPlayer()
    local highestThreat = 0
    local threateningPlayer = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            local threatLevel = self:evaluateThreat(player)
            if threatLevel > highestThreat then
                highestThreat = threatLevel
                threateningPlayer = player
            end
        end
    end

    return threateningPlayer, highestThreat
end

-- Activates the shield when needed
local function activateShield()
    if not State.autoParryEnabled then return end

    local currentTime = tick()
    if currentTime - State.lastShieldTime < CONFIG.SHIELD_COOLDOWN then return end

    -- Find the most threatening player around
    local threateningPlayer, highestThreat = ThreatSystem:getHighestThreatPlayer()
    
    if threateningPlayer and highestThreat >= CONFIG.DANGER_THRESHOLD then
        debugLog("Activating shield due to threat from: " .. threateningPlayer.Name .. " (Threat Level: " .. highestThreat .. ")")

        -- Activate Auto-Parry
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game) -- Simulate key press for the shield
        State.lastShieldTime = currentTime

        -- Automatically release the shield after BLOCK_DURATION
        task.delay(CONFIG.BLOCK_DURATION, function()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game) -- Simulate key release for the shield
            debugLog("Shield deactivated.")
        end)
    end
end

-- Monitor threats and react accordingly
local function monitorThreats()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ThreatSystem:updatePlayerVelocity(player)
        end
    end

    -- Activate shield if a significant threat is detected
    activateShield()
end

-- Binding functionalities to the game's runtime
RunService.RenderStepped:Connect(monitorThreats)
