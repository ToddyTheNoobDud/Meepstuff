local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local CONFIG = {
    ATTACK_RANGE = 50,
    DANGER_THRESHOLD = 0.75,
    REACTION_TIME = 0.02,
    SHIELD_COOLDOWN = 0.2,
    BLOCK_DURATION = 0.3,
    VELOCITY_IMPACT_FACTOR = 0.3,
    DASH_VELOCITY_THRESHOLD = 25,
    MINIMUM_VELOCITY_FOR_THREAT = 5,
    TRAJECTORY_PRECISION = 15,
    -- Threat Weights
    M1_ATTACK_WEIGHT = 0.8,
    ANIMATION_WEIGHT = 0.4,
    DASH_WEIGHT = 0.3,
    PROXIMITY_WEIGHT = 0.2,
    VELOCITY_WEIGHT = 0.2,
    TRAJECTORY_WEIGHT = 0.3,
    -- Animation Configuration
    ANIMATIONS_THREAT_KEYWORDS = {
        "slash", "stab", "swing", "punch", "kick", "attack", "m1", "strike", "lunge", "dash",
    },
    MINIMUM_ANIMATION_DURATION = 0.1,
    -- Debug and History
    DEBUG_MODE = true,
    ADDITIONAL_BLOCK_DISTANCE = 8,
    VELOCITY_HISTORY_LIMIT = 15,
    -- Combo Prevention
    COMBO_DETECTION_TIME = 0.5, -- Time window to detect combos
    MAX_ATTACKS_IN_COMBO = 3    -- Maximum attacks before considering it a combo
}

local State = {
    autoParryEnabled = true,
    lastShieldTime = 0,
    playerVelocities = {},
    trackedAnimations = {},
    activeAttackers = {},
    attackHistory = {}, -- Track recent attacks for combo detection
    lastAttackTimes = {} -- Track timing of attacks
}

local function debugLog(message)
    if CONFIG.DEBUG_MODE then
        print("[[mushroom0162]] " .. message)
    end
end

-- Enhanced isAlive check
local function isAlive(player)
    local character = player.Character
    if not character then return false end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") and (accessory.Name == "Ragdoll" or accessory.Name == "RagdollSim") then
            return false
        end
    end

    return true
end

local ThreatSystem = {}

-- Track attack patterns
function ThreatSystem:updateAttackHistory(player)
    if not State.attackHistory[player] then
        State.attackHistory[player] = {}
        State.lastAttackTimes[player] = {}
    end

    local currentTime = tick()
    
    -- Clean up old attack history
    while #State.lastAttackTimes[player] > 0 and 
          currentTime - State.lastAttackTimes[player][1] > CONFIG.COMBO_DETECTION_TIME do
        table.remove(State.lastAttackTimes[player], 1)
        table.remove(State.attackHistory[player], 1)
    end

    -- Add new attack
    table.insert(State.lastAttackTimes[player], currentTime)
    table.insert(State.attackHistory[player], true)
end

-- Enhanced M1ing detection with combo awareness
function ThreatSystem:checkM1ing(player)
    local character = player.Character
    if not character then return false end

    local isM1ing = false
    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") and accessory.Name == "M1ing" then
            isM1ing = true
            self:updateAttackHistory(player)
            if not State.activeAttackers[player] then
                State.activeAttackers[player] = tick()
                debugLog(player.Name .. " started attacking (M1ing detected)")
            end
            break
        end
    end

    if not isM1ing and State.activeAttackers[player] then
        State.activeAttackers[player] = nil
        debugLog(player.Name .. " stopped attacking")
    end

    return isM1ing
end

function ThreatSystem:updatePlayerVelocity(player)
    if not State.playerVelocities[player] then
        State.playerVelocities[player] = {}
    end

    local history = State.playerVelocities[player]
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if rootPart then
        table.insert(history, rootPart.Velocity)
        if #history > CONFIG.VELOCITY_HISTORY_LIMIT then
            table.remove(history, 1)
        end
    end
end

-- Enhanced dash detection
function ThreatSystem:isPlayerDashing(player)
    local history = State.playerVelocities[player]
    if not history or #history < 3 then return false end

    local currentVelocity = history[#history]
    local previousVelocity = history[#history - 1]
    local oldVelocity = history[#history - 2]

    local recentAcceleration = (currentVelocity - previousVelocity).Magnitude
    local sustainedAcceleration = (currentVelocity - oldVelocity).Magnitude

    return recentAcceleration > CONFIG.DASH_VELOCITY_THRESHOLD and
           sustainedAcceleration > CONFIG.DASH_VELOCITY_THRESHOLD * 0.8
end

function ThreatSystem:predictPlayerPosition(player)
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local velocity = rootPart.Velocity
    local futurePosition = rootPart.Position + (velocity * (CONFIG.REACTION_TIME + CONFIG.BLOCK_DURATION))
    return futurePosition
end

-- Check for threatening animations
function ThreatSystem:checkThreateningAnimations(player)
    local character = player.Character
    if not character then return false end

    local humanoid = character:FindFirstChild("Humanoid")
    local animator = humanoid and humanoid:FindFirstChild("Animator")
    if not animator then return false end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.TimePosition > CONFIG.MINIMUM_ANIMATION_DURATION then
            local animName = track.Animation.Name:lower()
            for _, keyword in ipairs(CONFIG.ANIMATIONS_THREAT_KEYWORDS) do
                if animName:find(keyword) then
                    return true
                end
            end
        end
    end
    return false
end

-- Comprehensive threat evaluation
function ThreatSystem:evaluateThreat(player)
    if not player.Character or not isAlive(player) or not LocalPlayer.Character then return 0 end

    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot or not localRoot then return 0 end

    local currentDistance = (localRoot.Position - playerRoot.Position).Magnitude
    if currentDistance > CONFIG.ATTACK_RANGE then return 0 end

    local threatLevel = 0
    local hasM1ing = self:checkM1ing(player)
    
    -- Base threat from M1ing
    if hasM1ing then
        threatLevel = threatLevel + CONFIG.M1_ATTACK_WEIGHT
    end

    -- Proximity threat (weighted more heavily if attacking)
    local proximityFactor = (1 - (currentDistance / CONFIG.ATTACK_RANGE))
    threatLevel = threatLevel + (proximityFactor * CONFIG.PROXIMITY_WEIGHT * (hasM1ing and 2 or 1))

    -- Animation threat
    if self:checkThreateningAnimations(player) then
        threatLevel = threatLevel + CONFIG.ANIMATION_WEIGHT
    end

    -- Velocity and dash threat
    if playerRoot.Velocity.Magnitude > CONFIG.MINIMUM_VELOCITY_FOR_THREAT then
        local velocityImpact = math.clamp(playerRoot.Velocity.Magnitude / 25, 0, 1)
        threatLevel = threatLevel + (velocityImpact * CONFIG.VELOCITY_WEIGHT)

        if self:isPlayerDashing(player) then
            threatLevel = threatLevel + CONFIG.DASH_WEIGHT
        end
    end

    -- Trajectory threat
    local futurePosition = self:predictPlayerPosition(player)
    if futurePosition and (futurePosition - localRoot.Position).Magnitude < CONFIG.ADDITIONAL_BLOCK_DISTANCE then
        threatLevel = threatLevel + CONFIG.TRAJECTORY_WEIGHT
    end

    -- Combo detection adjustment
    if State.attackHistory[player] and #State.attackHistory[player] >= CONFIG.MAX_ATTACKS_IN_COMBO then
        threatLevel = threatLevel * 1.5 -- Increase threat level for combo attacks
        debugLog(player.Name .. " is performing a combo attack!")
    end

    return math.clamp(threatLevel, 0, 1)
end

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

local function activateShield()
    if not State.autoParryEnabled then return end

    local currentTime = tick()
    if currentTime - State.lastShieldTime < CONFIG.SHIELD_COOLDOWN then return end

    local threateningPlayer, highestThreat = ThreatSystem:getHighestThreatPlayer()
    
    if threateningPlayer and highestThreat >= CONFIG.DANGER_THRESHOLD then
        debugLog("Activating shield due to threat from: " .. threateningPlayer.Name .. " (Threat Level: " .. highestThreat .. ")")

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        State.lastShieldTime = currentTime

        task.delay(CONFIG.BLOCK_DURATION, function()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            debugLog("Shield deactivated.")
        end)
    end
end

local function monitorThreats()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ThreatSystem:updatePlayerVelocity(player)
        end
    end
    activateShield()
end

RunService.RenderStepped:Connect(monitorThreats)
