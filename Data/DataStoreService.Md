# Example

### Press (Server Script)

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:FindFirstChild("Fire") or Instance.new("RemoteEvent", ReplicatedStorage)
Event.Name = "Fire"

local pprompt = script.Parent

local function onPromptTriggered(player)
	local message = " triggered the button."
	Event:FireClient(player, message)
end

pprompt.Triggered:Connect(onPromptTriggered)
```

### Client (Local Script)

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Event = ReplicatedStorage:WaitForChild("Fire", 5)
local Points = ReplicatedStorage:WaitForChild("Points", 5)

Event.OnClientEvent:Connect(function(message)
	local player = Players.LocalPlayer
	print(player.Name .. message)
	
	local point = 1
	
	Points:FireServer(player, point)
end)

Points.OnClientEvent:Connect(function(player, points)
	local plr = Players.LocalPlayer
	local pgui = plr.PlayerGui
	
	local pointGui = pgui.ScreenGui.point
	
	pointGui.Text = tostring(points)
end)
```

### Points (Server Script)

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local fireClientEvent = ReplicatedStorage:WaitForChild("Fire", 5)
local updatePointsEvent = ReplicatedStorage:WaitForChild("Points", 5)

local pointsDataStore = DataStoreService:GetDataStore("PlayerPoints")

local function updatePoints(player)
	local userId = player.UserId
	local points = 0
	local success, err

	success, err = pcall(function()
		points = pointsDataStore:GetAsync(userId) or 0
	end)

	if not success then
		warn("Failed to retrieve points for player " .. player.Name .. ": " .. err)
	else
		print(player.Name .. " has " .. points .. " points currently.")
	end

	points = points + 1

	success, err = pcall(function()
		pointsDataStore:SetAsync(userId, points)
	end)

	if not success then
		warn("Failed to save points for player " .. player.Name .. ": " .. err)
	else
		print(player.Name .. " now has " .. points .. " points.")
	end

	updatePointsEvent:FireClient(player, points)
end

fireClientEvent.OnServerEvent:Connect(updatePoints)
```
