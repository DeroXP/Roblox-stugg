--!strict

--[[
Move script to:
	StarterCharacterScripts
	
Made by:
	@isPauI
	YT: @Paul1Rb


Updated: 10.07.2023 - 10:35 CET
Log:
	- Changed the Sway effect to work on CameraOffset because it caused the player to rotate on Y axis since they were in first person.
	
	- Changed line 65 [Cam.CameraType = Enum.CameraType.Scriptable] to .Custom
]]

--[[
Improvements from DeroVB:)
Including, Automatic FPS Adjust, and Walkspeed effected bobbing

4/5/2024 @ 3:26 PM

]]

local Settings : SettingsType = require(script:WaitForChild("Settings"))

type SettingsType = {
	BaseRot : number,
	SetRot : number,
	BaseFreq : number,
	SetFreq : number,
	BaseMult : number,
	BaseNumLerp: number,
	SwayStrenght : number,
	BaseSway : number,
	SetSway : number,
	CustomSwayZVal : number,
	DriftMin : number,
	DriftMax : number,
	Rate : number,
	MaxBlur : number,
	BlurMult : number,
}

local sway : CFrame
local MouseDelta : Vector2
local Vel,t,x,y : number

local sin = math.sin
local cos = math.cos
local rad = math.rad
local abs = math.abs
local sqrt = math.sqrt
local clamp = math.clamp
local round = math.round
local clock = os.clock

local CurrentVel = 0
local Drift = 0
local Limiter = 0

local RunServ = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local PlrServ = game:GetService("Players")
local workspace = game:GetService("Workspace")
local LightingServ = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlr : Player = PlrServ.LocalPlayer

local Cam : Camera = workspace.CurrentCamera
local BaseFov = Cam.FieldOfView

Cam.CameraType = Enum.CameraType.Custom
LocalPlr.CameraMode = Enum.CameraMode.LockFirstPerson

local char : Model = LocalPlr.Character or LocalPlr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid") :: Humanoid
local HRP = char:WaitForChild("HumanoidRootPart") :: BasePart

function NumLerp(num1: number, num2: number, rate: number) : number
	return num1 + (num2-num1)*rate
end

function CalculateCurve(Base : number, Set : number) : number
	return sin(clock() * Base) * Set
end

function GetVelMag() : number
	return round(Vector3.new(HRP.AssemblyLinearVelocity.X, HRP.AssemblyLinearVelocity.Y, HRP.AssemblyLinearVelocity.Z).Magnitude)
end

function GetMouseDrift(Drift : number, MouseDelta : Vector2, dt : number) : number
	return NumLerp(Drift, clamp(MouseDelta.X, Settings.DriftMin, Settings.DriftMax), (Settings.BaseMult * dt))
end

function GetSwayVal(x:number, y:number) : CFrame
	return CFrame.new(Vector3.new(x, y, 0), Vector3.new(x*.95, y*.95, Settings.CustomSwayZVal)) + Cam.CFrame.Position
end

local function setBlur() : BlurEffect
	local MotionBlur : BlurEffect = LightingServ:FindFirstChild("MotionBlur")
	
	if not MotionBlur then
		local newMotionBlur = Instance.new("BlurEffect")
		newMotionBlur.Size = 0
		newMotionBlur.Name = 'MotionBlur'
		newMotionBlur.Enabled = true
		newMotionBlur.Parent = LightingServ
		
		MotionBlur = newMotionBlur
	end
	
	return MotionBlur
end

local MotionBlur = setBlur()

function ConvCFrameToOrientation(_CFrame: CFrame)
	local setX, setY, setZ = _CFrame:ToOrientation()
	return Vector3.new(math.deg(setX), math.deg(setY), math.deg(setZ))
end

local FPS = 60 -- Default FPS
local updaterate = 0.5
local average_amount = 5
local fps_table = {}
local start = tick()

RunService.RenderStepped:Connect(function(frametime)
	if tick() >= start + ((updaterate) / average_amount) then
		local fps = 1 / frametime
		table.insert(fps_table, fps)
	end
	if tick() >= start + updaterate then
		start = tick()
		local current = 0
		local maxn = table.maxn(fps_table)
		for i = 1, maxn do
			current = current + fps_table[i]
		end
		FPS = math.floor(current / maxn)
		fps_table = {}
	end
end)

local function CameraUpdt(dt)
	Limiter += dt
	if Limiter >= 1 / (FPS + 10) then
		t = clock()
		MouseDelta = UIS:GetMouseDelta()

		Vel = NumLerp(CurrentVel, GetVelMag(), Settings.BaseNumLerp)

		x = cos(t * Settings.BaseSway) * Settings.SetSway
		y = sin(t * Settings.BaseSway) * Settings.SetSway 
		sway = GetSwayVal(x,y)

		Drift = GetMouseDrift(Drift, MouseDelta, dt)

		Cam.FieldOfView = BaseFov + sqrt(Vel)

		MotionBlur.Size = clamp(abs(Drift*Settings.BlurMult) --[[ & Vel with lower mult]], 0, Settings.MaxBlur)

		CurrentVel = Vel

		local walkspeed = hum.WalkSpeed
		local Maxwalkspeed = 24

		Cam.CFrame = Cam.CFrame
			* CFrame.new(0, CalculateCurve(Settings.BaseFreq, Settings.SetFreq) * Vel / Settings.BaseMult * walkspeed / Maxwalkspeed, 0)
			* CFrame.Angles(0, 0, rad(CalculateCurve(Settings.BaseRot, Settings.SetRot) * Vel / Settings.BaseMult * walkspeed / Maxwalkspeed) + rad(Drift))


		hum.CameraOffset = ConvCFrameToOrientation(sway)
	end
end

RunServ:BindToRenderStep("CamEffect", Enum.RenderPriority.Camera.Value, CameraUpdt)

local function reset() : ()
	LocalPlr.CameraMode = Enum.CameraMode.Classic
	Cam.CameraType = Enum.CameraType.Custom
	
	script:Destroy()
end

hum.Died:Once(reset)
