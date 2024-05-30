local rp = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local mod = require(script.settings)

local probeTemplate = rp:WaitForChild("Probe", 5)
local atmosphereColor = Lighting.Atmosphere.Color
local cubeSize = 1			-- size of the cube (probes cube, not probe)
local gridSize = 4		-- keep this lower at 4 or 3
local spacing = 7			-- spacing of probe to probe in cube
local numRaysPerProbe = 90  -- number of rays per probe
local spreadAngle = 65      -- spread angle in degrees
local colorTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- easing for colors so its not snappy
local rayPoolSize = 500     -- size of the ray part pool
local rayPartPool = {}      -- table to store the ray parts pool
local activeRayParts = {}   -- table to track active ray parts

local function createProbe()
	local probe = probeTemplate:Clone()
	local light = probe:FindFirstChild("SpotLight") or Instance.new("SpotLight", probe)
	probe.Parent = workspace
	return probe
end

-- function to create and return a new ray part
local function createRayPart()
	local rayPart = Instance.new("Part")
	rayPart.Size = Vector3.new(0.1, 0.1, 1)
	rayPart.Anchored = true
	rayPart.CanCollide = false
	rayPart.Transparency = 0.01
	rayPart.Parent = workspace
	return rayPart
end

-- initialize the ray part pool
for i = 1, rayPoolSize do
	table.insert(rayPartPool, createRayPart())
end

-- function to get a ray part from the pool
local function getRayPart()
	if #rayPartPool > 0 then
		return table.remove(rayPartPool)
	else
		return createRayPart()  -- create a new one if the pool is empty
	end
end

-- function to return a ray part to the pool
local function returnRayPart(rayPart)
	rayPart.Size = Vector3.new(0.1, 0.1, 1)
	rayPart.Transparency = 1
	rayPart.Parent = nil
	table.insert(rayPartPool, rayPart)
end

-- function to clean up active ray parts
local function cleanUpRayParts()
	for _, rayPart in ipairs(activeRayParts) do
		if rayPart.Parent then
			wait(0.1)
			returnRayPart(rayPart)
		end
	end
	activeRayParts = {}
end

-- create the probes and store them in a table
local probes = {}
local numProbes = gridSize * gridSize * gridSize
for i = 1, numProbes do
	table.insert(probes, createProbe())
end

-- function to get a random spread direction based on the base direction and spread angle
local function getSpreadDirection(baseDirection, spreadAngle)
	local randomAngleX = math.rad(spreadAngle) * (math.random() - 0.5)
	local randomAngleZ = math.rad(spreadAngle) * (math.random() - 0.5)
	local spreadVector = Vector3.new(math.sin(randomAngleX), -1, math.sin(randomAngleZ))
	return (spreadVector + baseDirection).Unit
end

local function castRay(origin, direction, maxLength, ignoreList)
	local ray = Ray.new(origin, direction.Unit * maxLength)
	local hitPart, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
	if hitPart then
		return hitPosition, (hitPosition - origin).Magnitude, hitPart
	else
		return ray.Direction.Unit * maxLength, maxLength, nil
	end
end

RunService.RenderStepped:Connect(function()
	local player = game.Players.LocalPlayer
	if player and player.Character and player.Character:FindFirstChild("Humanoid") then
		local camera = workspace.CurrentCamera
		local humanoid = player.Character:WaitForChild("Humanoid", 5)
		local characterPosition = humanoid.RootPart.Position

		-- calculate probe offsets based on grid size and spacing
		local offsets = {}
		local halfGridSize = (gridSize - 1) / 2
		for x = -halfGridSize, halfGridSize do
			for y = -halfGridSize, halfGridSize do
				for z = -halfGridSize, halfGridSize do
					table.insert(offsets, Vector3.new(x * spacing, y * spacing + 10, z * spacing))
				end
			end
		end

		local ignoreList = {player.Character}
		for _, probe in ipairs(probes) do
			table.insert(ignoreList, probe)
		end
		
		for _, rayPart in ipairs(activeRayParts) do
			table.insert(ignoreList, rayPart)
		end

		-- table to store the brightness of each probe
		local probeBrightness = {}

		for i, probe in ipairs(probes) do
			local offset = offsets[i]
			probe.Position = characterPosition + offset + Vector3.new(0, 0, 0)

			local baseDirection = Lighting:GetSunDirection()
			probe.CFrame = CFrame.new(probe.Position, probe.Position - Lighting:GetSunDirection())  -- set orientation towards sun

			if mod.Invisible then -- to set it to automactically invis just do mod.Invisible == false
				probe.Transparency = 1
			else
				probe.Transparency = 0.5
			end

			local hitColors = {}
			local totalHits = 0
			local totalDistance = 0

			-- cast rays and gather hit information
			for _ = 1, numRaysPerProbe do
				local spreadDirection = getSpreadDirection(-baseDirection, spreadAngle)
				local hitPosition, hitDistance, hitPart = castRay(probe.Position, spreadDirection, 1000, ignoreList)
				if hitPart and hitPart.Color then
					table.insert(hitColors, hitPart.Color)
					totalHits = totalHits + 1
					totalDistance = totalDistance + hitDistance
				end
				-- visualize the ray (if enabled in settings)
				if mod.Visualize then
					local rayPart = getRayPart()
					rayPart.Size = Vector3.new(0.1, 0.1, hitDistance)
					rayPart.CFrame = CFrame.new((probe.Position + hitPosition) / 2, hitPosition)
					rayPart.Color = Color3.new(0, 1, 0)
					rayPart.Transparency = 0.01
					rayPart.Parent = workspace
					table.insert(activeRayParts, rayPart)  -- track the active ray part
					table.insert(ignoreList, rayPart)
				end
			end

			-- calculate the average color of the hit parts
			local averageColor = atmosphereColor
			if #hitColors > 0 then
				local totalR, totalG, totalB = 0, 0, 0
				for _, color in ipairs(hitColors) do
					totalR = totalR + color.R
					totalG = totalG + color.G
					totalB = totalB + color.B
				end
				averageColor = Color3.new(totalR / #hitColors, totalG / #hitColors, totalB / #hitColors)
			end

			-- tween to the new color
			local tween = TweenService:Create(probe.SpotLight, colorTweenInfo, {Color = averageColor})
			tween:Play()

			-- adjust brightness based on ray towards the sun
			local sunRayDirection = baseDirection
			local _, _, sunHitPart = castRay(probe.Position, sunRayDirection, 1000, ignoreList)
			local brightness = 0.1  -- Default brightness
			if totalHits > 0 then
				local averageDistance = totalDistance / totalHits
				brightness = math.clamp(1 / averageDistance, 0, 1)  -- adjust based on average distance (closer = dimmer)
			end
			-- dim brightness if the probe is not exposed to sunlight
			if sunHitPart then
				local transparencyFactor = 1 - sunHitPart.Transparency
				brightness = brightness * 0.01 * transparencyFactor  -- dimmer if not exposed to sunlight
			end

			probeBrightness[i] = brightness * 5  -- store scaled brightness
		end

		-- adjust each probe's brightness based on surrounding probes
		local probeRadius = spacing * 1.5  -- define the radius to consider nearby probes
		for i, probe in ipairs(probes) do
			local surroundingBrightness = 0
			local surroundingCount = 0
			for j, otherProbe in ipairs(probes) do
				if i ~= j and (probe.Position - otherProbe.Position).Magnitude <= probeRadius then
					surroundingBrightness = surroundingBrightness + probeBrightness[j]
					surroundingCount = surroundingCount + 1
				end
			end
			
			if surroundingCount > 0 then
				local averageSurroundingBrightness = surroundingBrightness / surroundingCount
				probe.SpotLight.Brightness = (probeBrightness[i] + averageSurroundingBrightness) / 2  -- average out brightness
			else
				probe.SpotLight.Brightness = probeBrightness[i]
			end
		end
		
		cleanUpRayParts()
	end
end)
