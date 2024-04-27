local player = game.Players.LocalPlayer

local characterAddedConnection

local c = player.Character or player:FindFirstChild("Character")
local h = c:WaitForChild("Humanoid")

local isPlayingSprint = false
local isPlayingWalk = false

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	local baseWalkSpeed = 12
	local ascendingSpeed = humanoid.WalkSpeed + 3
	local descendingSpeed = humanoid.WalkSpeed - 3
	local sprintSpeed = 20

	local jumpHeight = 40
	local jumpSpeedMultiplier = 1.5
	local jumpDelay = 1.5

	local isSprinting = false
	local isStopping = false
	local isJumping = false
	local isOnGround = true

	local pgui = game.Players.LocalPlayer.PlayerGui
	local gui = pgui.stam

	local staminaBarContainer = gui.Frame

	local staminaBar = staminaBarContainer.Frame

	local initialSize = UDim2.new(0, 0, 1, 0)
	local targetSize = UDim2.new(1, 0, 1, 0)
	local tweenDuration = 0.5
	local easingStyle = Enum.EasingStyle.Linear

	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")

	local function IsController()
		return UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1)
	end

	local function updateStaminaBar()
		local maxStamina = 100
		local currentStamina = maxStamina
		local momentum = 0.5
		local isInitialJump = true
		local isHoldingShift = false
		local jumpStaminaDrain = 3
		local sprintStaminaDrain = 1

		local minStaminaSize = UDim2.new(0.01, 0, 0.001, 0)
		local maxStaminaSize = UDim2.new(0.527, 0, 0.001, 0)

		local minStaminaPosition = UDim2.new(0.5, 0, 0.96, 0)
		local maxStaminaPosition = UDim2.new(0.236, 0, 0.96, 0)

		local minStaminaColor = Color3.fromRGB(255, 0, 0)
		local midStaminaColor = Color3.fromRGB(255, 255, 0)
		local maxStaminaColor = Color3.fromRGB(255, 255, 255)
		
		local isSprintingTimer = 0
		local fadeDuration = 2
		local initialTransparency = 0
		local targetTransparency = 1
		
		local sprintingLastFrame = false

		local breathing = Instance.new("Sound")
		breathing.SoundId = "rbxassetid://8258601891"
		breathing.Volume = 0
		breathing.Looped = true
		breathing.Parent = c.HumanoidRootPart

		--[[local heart = Instance.new("Sound")
		heart.SoundId = "rbxassetid://7188240609"
		heart.Volume = 0
		heart.Looped = true
		heart.Parent = c.HumanoidRootPart use this for adreanaline]]

		local function isMovementKeyDownOrControllerInput()
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

		while true do
			local isControllerConnected = IsController()

			if isControllerConnected then
				isSprinting = UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL3)
			else
				isSprinting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
			end
			
			local fadeStartTime = 0
			local delayDuration = 2

			if isSprinting then
				isSprintingTimer = tick()
			end

			local sprintingThisFrame = isSprinting and currentStamina == maxStamina

			if sprintingThisFrame then
				isSprintingTimer = tick()
			elseif tick() - isSprintingTimer >= fadeDuration and staminaBar.BackgroundTransparency ~= targetTransparency and currentStamina == maxStamina and not sprintingLastFrame and not isSprinting then
				if tick() - fadeStartTime >= delayDuration then
					local transparencyTweenInfo = TweenInfo.new(tweenDuration, easingStyle)
					local transparencyTween = TweenService:Create(staminaBar, transparencyTweenInfo, { BackgroundTransparency = targetTransparency })
					transparencyTween:Play()
				end
			elseif tick() - isSprintingTimer < fadeDuration and staminaBar.BackgroundTransparency ~= initialTransparency and isSprinting then
				local transparencyTweenInfo = TweenInfo.new(tweenDuration, easingStyle)
				local transparencyTween = TweenService:Create(staminaBar, transparencyTweenInfo, { BackgroundTransparency = initialTransparency })
				transparencyTween:Play()
				fadeStartTime = tick()
			end

			sprintingLastFrame = sprintingThisFrame

			if isSprinting and currentStamina > 0 and isMovementKeyDownOrControllerInput() then
				currentStamina = currentStamina - sprintStaminaDrain
				momentum = 0.5
			elseif currentStamina < maxStamina then
				currentStamina = currentStamina + momentum
				momentum = momentum + 0.1
			end

			currentStamina = math.clamp(currentStamina, 0, maxStamina)

			local staminaPercentage = currentStamina / maxStamina

			if isJumping then
				if isInitialJump then
					currentStamina = currentStamina - sprintStaminaDrain
					isInitialJump = false
				elseif isHoldingShift and humanoid.WalkSpeed > baseWalkSpeed then
					currentStamina = currentStamina - sprintStaminaDrain
				else
					currentStamina = currentStamina - jumpStaminaDrain
				end
			end

			if not isJumping then
				isInitialJump = true
			end

			local targetSize = minStaminaSize:Lerp(maxStaminaSize, currentStamina / maxStamina)
			local targetPosition = minStaminaPosition:Lerp(maxStaminaPosition, currentStamina / maxStamina)
			local tweenInfo = TweenInfo.new(tweenDuration, easingStyle)

			local sizeTween = TweenService:Create(staminaBar, tweenInfo, { Size = targetSize })
			local positionTween = TweenService:Create(staminaBar, tweenInfo, { Position = targetPosition })

			sizeTween:Play()
			positionTween:Play()

			local colorRanges = {
				{0.21, minStaminaColor},
				{0.41, midStaminaColor},
				{1, maxStaminaColor}
			}

			local targetColor = maxStaminaColor
			for _, range in ipairs(colorRanges) do
				if staminaPercentage < range[1] then
					targetColor = range[2]
					break
				end
			end

			local colorTween = TweenService:Create(staminaBar, tweenInfo, { BackgroundColor3 = targetColor })
			colorTween:Play()

			local MIN_STAMINA = 10
			local MAX_STAMINA = 30
			local BASE_WALK_SPEED = 9
			local LOW_WALK_SPEED = 6
			local TWEEN_TIME = 2

			local function handleBreathingSound(breathing, targetVolume)
				local volumeTween = TweenService:Create(breathing, TweenInfo.new(TWEEN_TIME), { Volume = targetVolume })
				if targetVolume > 0 then
					if not breathing.IsPlaying then
						breathing:Play()
					end
				else
					if breathing.IsPlaying and volumeTween.Completed then
						breathing:Stop()
					end
					return
				end
				
				volumeTween:Play()
			end

			local isWalkSpeedLocked = false

			local function LockWS(humanoid, locked)
				if isWalkSpeedLocked then
					humanoid.WalkSpeed = humanoid.WalkSpeed / 3
					isSprinting = false
				elseif isWalkSpeedLocked == false then
					humanoid.WalkSpeed = BASE_WALK_SPEED
				end
			end

			local function handleStaminaAndSpeed()
				local staminaPercentage = currentStamina / maxStamina

				if staminaPercentage <= 0.1 then
					isWalkSpeedLocked = true
					LockWS(humanoid)
					handleBreathingSound(breathing, 1)
				else
					if isWalkSpeedLocked then
						isWalkSpeedLocked = false
						LockWS(humanoid)
					end
					handleBreathingSound(breathing, 0)
				end
			end

			handleStaminaAndSpeed()

			wait(0.1)
		end
	end


	local humanoid = c:WaitForChild("Humanoid")

	local UserInputService = game:GetService("UserInputService")

	local function updateSpeed()
		local isOnGround = true
		local isInAir = false

		local currentWalkSpeed = humanoid.WalkSpeed

		local maxWalkSpeed = 27

		local function onLanding()
			isOnGround = true
			isInAir = false
			if not isPlayingSprint and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				isPlayingSprint = true
			end
			if isPlayingWalk then
				isPlayingWalk = false
			end
		end

		local function onJump()
			isOnGround = false
			isInAir = true
			if isPlayingSprint then
				isPlayingSprint = false
			end
			if isPlayingWalk then
				isPlayingWalk = false
			end
		end

		humanoid.StateChanged:Connect(function(oldState, newState)
			if newState == Enum.HumanoidStateType.Freefall and isOnGround then
				if isPlayingSprint then
					isPlayingSprint = false
				end
				if isPlayingWalk then
					isPlayingWalk = false
				end
			end
		end)

		humanoid.Jumping:Connect(onJump)

		local function isMoving()
			return UserInputService:IsKeyDown(Enum.KeyCode.W)
				or UserInputService:IsKeyDown(Enum.KeyCode.A)
				or UserInputService:IsKeyDown(Enum.KeyCode.S)
				or UserInputService:IsKeyDown(Enum.KeyCode.D)
				or UserInputService:IsKeyDown(Enum.KeyCode.Up)
				or UserInputService:IsKeyDown(Enum.KeyCode.Left)
				or UserInputService:IsKeyDown(Enum.KeyCode.Down)
				or UserInputService:IsKeyDown(Enum.KeyCode.Right)
				or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL3)
		end

		while isSprinting do
			if humanoid.WalkSpeed < sprintSpeed and humanoid.WalkSpeed ~= 8 then
				humanoid.WalkSpeed = humanoid.WalkSpeed + 1
			end
			humanoid.JumpPower = 30

			wait()
		end

		while isStopping do
			if humanoid.WalkSpeed > baseWalkSpeed and humanoid.WalkSpeed ~= 8 then
				humanoid.WalkSpeed = humanoid.WalkSpeed - 1
			end
			humanoid.JumpPower = 40

			wait()
		end

		if humanoid.WalkSpeed > 27 then
			humanoid.WalkSpeed = 27
		end
		
		wait(0.01)
	end

	local isHoldingShift = false
	local previousPosition = nil

	game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.LeftShift or (IsController() and input.KeyCode == Enum.KeyCode.ButtonL3) then
			if previousPosition ~= nil and humanoid.RootPart.Position ~= previousPosition then
				isSprinting = true
				isStopping = false
				updateSpeed()
				isHoldingShift = true
			end
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.LeftShift or (IsController() and input.KeyCode == Enum.KeyCode.ButtonL3) then
			isSprinting = false
			isStopping = true
			updateSpeed()
			isHoldingShift = false
		end
	end)

	previousPosition = humanoid.RootPart.Position

	humanoid.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.Landed then
			isJumping = false
			isOnGround = true

			if humanoid.WalkSpeed < baseWalkSpeed then
				humanoid.WalkSpeed = ascendingSpeed
			end

			wait(jumpDelay)

			if isOnGround then
				humanoid.WalkSpeed = baseWalkSpeed
				updateSpeed()
			end
		end
	end)

	rootPart.Touched:Connect(function(part)
		if part.CanCollide and not isJumping then
			isOnGround = true
		end
	end)

	updateSpeed()
	coroutine.wrap(updateStaminaBar)()

	characterAddedConnection:Disconnect()
end

characterAddedConnection = player.CharacterAdded:Connect(onCharacterAdded)

if c then
	onCharacterAdded(c)
else
	characterAddedConnection = player.CharacterAdded:Connect(function(character)
		onCharacterAdded(character)
		characterAddedConnection:Disconnect()
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end
