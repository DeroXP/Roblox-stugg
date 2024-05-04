local ReplicateStorage = game:GetService("ReplicatedStorage")
local Auto = ReplicateStorage.HA

local UIS = game:GetService("UserInputService")

local MovementPart = Auto.MeshPart
local Left, Right = Auto.Left, Auto.Right

local moffest = CFrame.new(2, -2,-4)
local loffest = CFrame.new(1.5, -2.5,-4.4)
local roffest = CFrame.new(2.8, -2.5,-3)

local function updateCFrame ()
	local cam = workspace.CurrentCamera
	if cam then
		local y = cam.CFrame:ToOrientation()
		
		MovementPart.CFrame = cam.CFrame:ToWorldSpace(moffest)
		Left.CFrame = cam.CFrame:ToWorldSpace(loffest)
		Right.CFrame = cam.CFrame:ToWorldSpace(roffest)
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
