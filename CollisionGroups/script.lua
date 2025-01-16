local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local function Create(groupName)
	PhysicsService:RegisterCollisionGroup(groupName)
end

Create("Enemies")
Create("NonCollidable")
Create("Players")

PhysicsService:CollisionGroupSetCollidable("Enemies", "Enemies", false)
PhysicsService:CollisionGroupSetCollidable("Enemies", "NonCollidable", false)
PhysicsService:CollisionGroupSetCollidable("Enemies", "Players", false)

local function assignCollisionGroupToCharacter(character, groupName)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = groupName
		end
	end
end

local function onCharacterAdded(character)
	assignCollisionGroupToCharacter(character, "Players")
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
