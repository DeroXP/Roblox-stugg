local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Settings : SettingsType = require(script:WaitForChild("FiredNo"))

local Shooting = Settings.Shooting

if Shooting == 1 then
	local bullet = ReplicatedStorage.Bullet:Clone()
end
