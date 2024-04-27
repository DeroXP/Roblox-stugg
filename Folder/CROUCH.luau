local player = game.Players.LocalPlayer
local character = player.Character or player:FindFirstChild("Character")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = game.Workspace.CurrentCamera

local crouching = false
local normalHeight = 5
local crouchHeight = 2.5
local normalCameraHeight = 5
local crouchCameraHeight = 3

local humanoid = character:FindFirstChild("Humanoid")
local idleAnimTrack = nil
local movingAnimTrack = nil

local IDLE_ANIM_ID = "rbxassetid://17047960247"
local MOVING_ANIM_ID = "rbxassetid://17047964306"

local idleAnim = Instance.new("Animation")
idleAnim.AnimationId = IDLE_ANIM_ID

local movingAnim = Instance.new("Animation")
movingAnim.AnimationId = MOVING_ANIM_ID

local function IsController()
	return UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1)
end

if player.Character and player.Character:FindFirstChild("Humanoid") then
	humanoid:SetAttribute("Crouching", false)

	humanoid = player.Character.Humanoid
	idleAnimTrack = humanoid:LoadAnimation(idleAnim)
	idleAnimTrack.Looped = true
	idleAnimTrack.Priority = Enum.AnimationPriority.Action

	movingAnimTrack = humanoid:LoadAnimation(movingAnim)
	movingAnimTrack.Looped = true
	movingAnimTrack.Priority = Enum.AnimationPriority.Action
end

local function isMoving()
	return UserInputService:IsKeyDown(Enum.KeyCode.W)
		or UserInputService:IsKeyDown(Enum.KeyCode.A)
		or UserInputService:IsKeyDown(Enum.KeyCode.S)
		or UserInputService:IsKeyDown(Enum.KeyCode.D)
		or UserInputService:IsKeyDown(Enum.KeyCode.Up)
		or UserInputService:IsKeyDown(Enum.KeyCode.Down)
		or UserInputService:IsKeyDown(Enum.KeyCode.Left)
		or UserInputService:IsKeyDown(Enum.KeyCode.Right)
		or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL3)
end

local function HandleAnims()
	if crouching then
		if isMoving() then
			if not movingAnimTrack.IsPlaying then
				movingAnimTrack:Play()
				idleAnimTrack:Stop()

				humanoid:SetAttribute("Crouching", true)
			end
		else
			if not idleAnimTrack.IsPlaying then
				idleAnimTrack:Play()
				movingAnimTrack:Stop()

				humanoid:SetAttribute("Crouching", true)
			end
		end
	else
		movingAnimTrack:Stop()
		idleAnimTrack:Stop()
		humanoid:SetAttribute("Crouching", false)
	end
end

local function updateCrouchState()
	if crouching then
		if humanoid then
			humanoid.AutoRotate = true
			humanoid.HipHeight = 1.3
			camera.CameraSubject = player.Character.Humanoid
			camera.CameraType = Enum.CameraType.Custom
			camera.CFrame = camera.CFrame * CFrame.new(0, crouchCameraHeight, 0)
		end
	else
		if humanoid then
			humanoid.AutoRotate = true
			humanoid.HipHeight = 2
			camera.CameraSubject = player.Character.Humanoid
			camera.CameraType = Enum.CameraType.Custom
			camera.CFrame = camera.CFrame * CFrame.new(0, normalCameraHeight, 0)
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.C or (IsController() and input.KeyCode == Enum.KeyCode.ButtonL3) then
		crouching = true
		updateCrouchState()
		HandleAnims()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.C or (IsController() and input.KeyCode == Enum.KeyCode.ButtonR3) then
		crouching = false
		updateCrouchState()
		HandleAnims()
	end
end)

game.Players.LocalPlayer.Character.Humanoid.StateChanged:Connect(function(oldState, newState)
	if newState == Enum.HumanoidStateType.Running then
		if crouching then
			HandleAnims()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	HandleAnims()

	if humanoid:GetAttribute("Crouching") == true or crouching then
		if humanoid.WalkSpeed > 7 then
			humanoid.WalkSpeed = 7
		end
	elseif  humanoid:GetAttribute("Crouching") == false or not crouching then
		if humanoid.WalkSpeed < 15 then
			humanoid.WalkSpeed = 15
		end
	end

	wait(0.1)
end)
