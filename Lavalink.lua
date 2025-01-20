local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LavalinkClient = {}
LavalinkClient.__index = LavalinkClient

local config = {
    host = "",
    password = "",
    port = 133,
    secure = false,
    name = "",
    version = "v4" 
}

local function debugPrint(...)
    print("[Lavalink Debug]:", ...)
end

function LavalinkClient.new()
    local self = setmetatable({}, LavalinkClient)
    self.baseUrl = string.format("http%s://%s:%d", 
        config.secure and "s" or "", 
        config.host, 
        config.port
    )
    self.headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = config.password
    }
    self.calls = 0
    return self
end

function LavalinkClient:makeRequest(method, endpoint, body)
    debugPrint("Making request:", method, endpoint)

    local options = {
        Url = self.baseUrl .. endpoint,
        Method = method,
        Headers = self.headers
    }

    if body then
        options.Body = HttpService:JSONEncode(body)
    end

    local success, response = pcall(function()
        return request(options)
    end)

    if not success then
        warn("[Lavalink Error]: Request failed:", response)
        return nil, "Request failed"
    end

    if response.StatusCode == 204 then
        return nil
    end

    self.calls += 1 

    local decodedResponse
    success, decodedResponse = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)

    if not success then
        warn("[Lavalink Error]: Failed to decode response:", decodedResponse)
        return nil, "Failed to decode response"
    end

    return decodedResponse, nil
end

function LavalinkClient:connect()
    debugPrint("Connecting to Lavalink server...")

    local response, err = self:makeRequest("POST", "/loadtracks", {
        op = "identify",
        d = {
            name = config.name,
            password = config.password
        }
    })

    if err or not response then
        debugPrint("Connection failed:", err or "Unknown error")
        return false
    end

    debugPrint("Successfully connected to Lavalink server!")
    return true
end

function LavalinkClient:getTracks(identifier)
    debugPrint("Getting tracks for identifier:", identifier)
    local endpoint = string.format("/%s/loadtracks?identifier=%s", config.version, HttpService:UrlEncode(identifier))
    local tracks, err = self:makeRequest("GET", endpoint)
    if err then
        warn("Failed to fetch tracks:", err)
        return nil
    end
    return tracks
end

function LavalinkClient:decodeTrack(track)
    debugPrint("Decoding track:", track)
    local endpoint = string.format("/%s/decodetrack?encodedTrack=%s", config.version, HttpService:UrlEncode(track))
    local decodedTrack, err = self:makeRequest("GET", endpoint)
    if err then
        warn("Failed to decode track:", err)
        return nil
    end
    return decodedTrack
end

-- Create GUI
local function createMusicPlayer()
    local client = LavalinkClient.new()

    if not client:connect() then
        warn("Failed to connect to Lavalink server")
        return
    end

    local player = Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MusicPlayer"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 180)
    frame.Position = UDim2.new(0.5, -150, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 0, 30)
    textBox.Position = UDim2.new(0, 10, 0, 10)
    textBox.Text = "Enter YouTube URL"
    textBox.TextColor3 = Color3.new(1, 1, 1)
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    textBox.BorderSizePixel = 0
    textBox.ClearTextOnFocus = false
    textBox.Parent = frame

    local playButton = Instance.new("TextButton")
    playButton.Size = UDim2.new(0.5, -15, 0, 30)
    playButton.Position = UDim2.new(0, 10, 0, 50)
    playButton.Text = "Play"
    playButton.TextColor3 = Color3.new(1, 1, 1)
    playButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    playButton.BorderSizePixel = 0
    playButton.Parent = frame

    local debugLabel = Instance.new("TextLabel")
    debugLabel.Size = UDim2.new(1, -20, 0, 60)
    debugLabel.Position = UDim2.new(0, 10, 0, 90)
    debugLabel.Text = "Debug info will appear here"
    debugLabel.TextColor3 = Color3.new(1, 1, 1)
    debugLabel.BackgroundTransparency = 1
    debugLabel.TextWrapped = true
    debugLabel.TextXAlignment = Enum.TextXAlignment.Left
    debugLabel.Parent = frame

    playButton.MouseButton1Click:Connect(function()
        local url = textBox.Text
        if url ~= "" and url ~= "Enter YouTube URL" then
            debugLabel.Text = "Resolving track..."

            local success, tracksOrError = pcall(function()
                return client:getTracks(url)
            end)

            if success and tracksOrError then
                debugLabel.Text = "Got tracks: " .. HttpService:JSONEncode(tracksOrError)
                local track = tracksOrError.data

                if track then
                    local success, decodedTrackOrError = pcall(function()
                        return client:decodeTrack(track.encoded)
                    end)

                    if success and decodedTrackOrError then
                        debugLabel.Text = "Decoded track successfully."

                        local audio = Instance.new("Sound")
                        audio.SoundId = "rbxassetid://0"
                        audio.Volume = 1
                        audio.PlaybackSpeed = 1
                        audio.Parent = player.Character or player

                        -- Set the Opus data
                        -- audio.SoundId = "rbxassetid://" .. decodedTrackOrError.data

                        debugLabel.Text = "Playing track..."
                    else
                        debugLabel.Text = "Error decoding track: " .. tostring(decodedTrackOrError)
                    end
                else
                    debugLabel.Text = "No tracks found."
                end
            else
                debugLabel.Text = "Error: " .. tostring(tracksOrError)
            end
        else
            debugLabel.Text = "Please enter a valid URL"
        end
    end)
end

createMusicPlayer()
