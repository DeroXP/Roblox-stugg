local ReplicateStorage = game:GetService("ReplicatedStorage")
local Auto = ReplicateStorage.HA

local UIS = game:GetService("UserInputService")

local MovementPart = Auto.MeshPart

local function updateCFrame ()
	local cam = workspace.CurrentCamera
	if cam then
		local offest = CFrame.new(2, -2,-4)
		Auto.PrimaryPart.CFrame = cam.CFrame:ToWorldSpace(offest)
		Auto.PrimaryPart.Orientation +=  Vector3.new(0, -90, 0)
	end
end

game:GetService("RunService").RenderStepped:Connect(updateCFrame)

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E then--or Enum.KeyCode.ButtonY
		if Auto.Parent ~= workspace then
			Auto.Parent = workspace
		else
			Auto.Parent = ReplicateStorage
		end
	end
end)
