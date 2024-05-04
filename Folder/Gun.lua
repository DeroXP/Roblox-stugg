local ReplicateStorage = game:GetService("ReplicatedStorage")
local Auto = ReplicateStorage.HA

local UIS = game:GetService("UserInputService")

local MovementPart = Auto.MeshPart
local Left, Right = MovementPart.Left, MovementPart.Right

local function updateCFrame ()
	local cam = workspace.CurrentCamera
	if cam then
		local moffest = CFrame.new(2, -2,-4)
		local loffest = CFrame.new(1.5, -2.5,-4.4)
		local roffest = CFrame.new(2.8, -2.5,-3)
		Auto.PrimaryPart.CFrame = cam.CFrame:ToWorldSpace(moffest)
		Left.CFrame = cam.CFrame:ToWorldSpace(loffest)
		Right.CFrame = cam.CFrame:ToWorldSpace(roffest)
		Left.Orientation += Vector3.new(cam.CFrame.Rotation.X + 0.337, cam.CFrame.Rotation.Y - 90 - 11.035, cam.CFrame.Rotation.Z - 14.433)
		Right.Orientation += Vector3.new(cam.CFrame.Rotation.X + 1.55, cam.CFrame.Rotation.Y - 90 + 7.498, cam.CFrame.Rotation.Z - 11.669)
		Auto.PrimaryPart.Orientation += Vector3.new(cam.CFrame.Rotation.X , cam.CFrame.Rotation.Y - 90, cam.CFrame.Rotation.Z)
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
