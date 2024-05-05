local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
--local Settings : SettingsType = require(script:WaitForChild("FiredNo"))
local TweenService = game:GetService("TweenService")

local Humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

--local Shooting = Settings.Shooting

if Humanoid:GetAttribute("Equipped") == true then
	UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local newBullet = ReplicatedStorage.Bullet:Clone()
			newBullet.Parent = workspace
			newBullet.Position = workspace.CurrentCamera.CFrame.p
			
			newBullet.Velocity = workspace.CurrentCamera.CFrame.LookVector * 50
			
			wait(5)
			newBullet:Destroy()
		end
	end)
end
