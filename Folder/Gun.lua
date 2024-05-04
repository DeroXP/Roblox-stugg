local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage.Flash

local plr = game.Players.LocalPlayer
local character
repeat
	character = plr.Character
	wait(1)
until character

local soundId = "rbxassetid://5991592592"
local sound = Instance.new("Sound")
sound.SoundId = soundId

local Auto = game.ReplicatedStorage.MeshPart:Clone()

local workspace = game:GetService("Workspace")

local function updatePartCFrame()
	local camera = workspace.CurrentCamera
	if camera then
		local offset = CFrame.new(2, -2, -4)
		Auto.CFrame = camera.CFrame:ToWorldSpace(offset)
	end
end

RunService.RenderStepped:Connect(updatePartCFrame)

local function isXboxButtonPressed(input)
	return input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.F
end

--[[local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://16813458158"

local function playAnimation(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator", humanoid)
	end
	local animationTrack = animator:LoadAnimation(animation)
	animationTrack:Play()
end

local function stopAnimation(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		track:Stop()
	end
end
]]

local function toggleFlashlight(newState)
	if Auto.Parent ~= workspace then
		RemoteEvent:FireServer(true)
		Auto.Parent = workspace
	else
		RemoteEvent:FireServer(false)
		Auto.Parent = game.ReplicatedStorage
		--stopAnimation(plr.Character)
	end
	sound:Play()
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and isXboxButtonPressed(input) then
		local Equipped = Auto.Parent == workspace
		toggleFlashlight(not Equipped)
		if not Equipped then
			--playAnimation(plr.Character)
		end
	end
end)
