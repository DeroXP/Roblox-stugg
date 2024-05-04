local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage["Pre-Loaded Events"].Flash

local plr = game.Players.LocalPlayer
local character
repeat
	character = plr.Character
	wait(1)
until character

local soundId = "rbxassetid://5991592592"
local sound = Instance.new("Sound")
sound.SoundId = soundId

local Flashlight = game.ReplicatedStorage.Flashlight:Clone()

local PartWithinFlashlight = Flashlight:FindFirstChild("Handle")
local Front = PartWithinFlashlight.MeshPart
local Light = PartWithinFlashlight.Front.SurfaceLight
Light.Brightness = 0

local workspace = game:GetService("Workspace")

local function updatePartCFrame()
	local camera = workspace.CurrentCamera
	if camera then
		local offset = CFrame.new(2, -2, -4)
		local lookVector = camera.CFrame.LookVector
		local rotatedLookVector = (lookVector * CFrame.Angles(0, math.rad(90), 0)).Unit
		local rotatedAngle = math.acos(rotatedLookVector:Dot(Vector3.new(0, 0, 1)))
		local rotatedLookVectorCFrame = CFrame.new(Vector3.new(), rotatedLookVector)
		local cFrame = camera.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0,  math.rad(180), 0) * CFrame.new(offset.p) * rotatedLookVectorCFrame * CFrame.Angles(0, 0, rotatedAngle)
		Front.CFrame = cFrame
	end
end

RunService.RenderStepped:Connect(updatePartCFrame)

--[[
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://16813458158"
]]

local function isXboxButtonPressed(input)
	return input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.F
end

--[[
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
	local state = newState or (Light.Brightness == 0)
	if state then
		RemoteEvent:FireServer(true)
		Front.Parent = workspace
	else
		RemoteEvent:FireServer(false)
		Front.Parent = game.ReplicatedStorage
		--stopAnimation(plr.Character)
	end
	sound:Play()
	Light.Brightness = state and 13.5 or 0
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if not gameProcessedEvent and isXboxButtonPressed(input) then
		local flashlightOn = Light.Brightness > 0
		toggleFlashlight(not flashlightOn)
		if not flashlightOn then
			--playAnimation(plr.Character)
		end
	end
end)
