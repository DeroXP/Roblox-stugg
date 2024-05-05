wait(.01)-- Just incase it timeouts the script cause of performance

-- Define the player and the blast radius and damage
local player = game.Players.LocalPlayer
local blastRadius = 10
local blastDamage = 50
local maxRange = 200
local blastSpeed = 500
local maxAmmo = 16
local currentAmmo = maxAmmo


local shootSound = Instance.new("Sound")
shootSound.SoundId = "rbxassetid://3603344430"
shootSound.Parent = game.SoundService


-- Define a function to create a blast and damage nearby players
function createBlast()
	if currentAmmo <= 0 then
		print("Out of ammo!")
		return
	end
	currentAmmo = currentAmmo - 1

	-- Clone the blast model
	local blast = game.ReplicatedStorage.Bullet:Clone()

	-- Set the blast's initial position to a point in front of the player's character's head
	local offset = player.Character.Head.CFrame.lookVector * 5
	blast.CFrame = player.Character.Head.CFrame + offset

	-- Calculate the direction from the player's character to the mouse position
	local mousePosition = game:GetService("Players").LocalPlayer:GetMouse().Hit.p
	local direction = (mousePosition - player.Character.Head.Position).Unit
	
	wait(0.1)
	
	shootSound:Play()

	-- Set the blast's velocity to the calculated direction, including the x and z components
	blast.Velocity = Vector3.new(direction.X * blastSpeed, 32, direction.Z * blastSpeed)

	-- Parent the blast to the workspace
	blast.Parent = game.Workspace

	-- Set the blast's CanCollide property to false so it doesn't collide with the player
	blast.CanCollide = false


	blast.Touched:Connect(function(hit)
		if hit.Parent == player.Character then
			return
		end

		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:TakeDamage(blastDamage)
		end

		blast:Destroy()
	end)

	local traveledDistance = 0
	while traveledDistance < maxRange do
		local distanceTraveled = math.abs(blast.Position.X - player.Character.Head.Position.X)
		if distanceTraveled >= maxRange then
			blast:Destroy()
			break
		end

		traveledDistance = distanceTraveled
	end

	blast.CanCollide = true
end

local Gui = game.StarterGui["In-GameGUI"]
local Frame = Gui.Frame
local Text = Frame.TextLabel

Text.Text = currentAmmo .. "/" .. maxAmmo

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
		createBlast()
	end
end)
