local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

-- prevent duplicate
if CoreGui:FindFirstChild("XRAY_UNIVERSAL") then
	CoreGui.XRAY_UNIVERSAL:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "XRAY_UNIVERSAL"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,130,0,40)
btn.Position = UDim2.new(0.1,0,0.5,0)
btn.Text = "XRAY : OFF"
btn.BackgroundColor3 = Color3.fromRGB(170,0,0)
btn.TextColor3 = Color3.new(1,1,1)
btn.Draggable = true
btn.Parent = gui

Instance.new("UICorner",btn)

local enabled = false
local highlights = {}
local processed = {}
local walls = {}

local function isPlayer(model)
	return Players:GetPlayerFromCharacter(model) ~= nil
end

local function getCharacterModel(obj)
	local m = obj
	while m and not m:IsA("Model") do
		m = m.Parent
	end
	return m
end

local function createHighlight(model,color)

	if highlights[model] then return end

	local hl = Instance.new("Highlight")
	hl.FillTransparency = 1
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.OutlineColor = color
	hl.Adornee = model
	hl.Parent = model

	highlights[model] = hl
end

local function classify(model)

	if isPlayer(model) then
		return "player"
	end

	if model:FindFirstChildWhichIsA("Humanoid") then
		return "npc"
	end

	if model:FindFirstChildWhichIsA("AnimationController") then
		return "npc"
	end

	if model:FindFirstChild("HumanoidRootPart") then
		return "npc"
	end

	return nil
end

local function process(obj)

	local model = getCharacterModel(obj)
	if not model or processed[model] then return end

	local class = classify(model)
	if not class then return end

	processed[model] = true

	if class == "player" then
		createHighlight(model,Color3.fromRGB(0,255,0))
	else
		createHighlight(model,Color3.fromRGB(255,0,0))
	end
end

local function applyWall(part)
	if walls[part] then return end
	part.LocalTransparencyModifier = 0.5
	walls[part] = true
end

local function rescanLoop()

	task.spawn(function()

		for i=1,5 do

			if not enabled then return end

			for _,obj in ipairs(Workspace:GetDescendants()) do

				if obj:IsA("Humanoid")
				or obj:IsA("AnimationController")
				or obj.Name == "HumanoidRootPart" then
					process(obj)
				end

				if obj:IsA("BasePart") then
					applyWall(obj)
				end

			end

			task.wait(0.5)

		end

	end)

end

Workspace.DescendantAdded:Connect(function(obj)

	if not enabled then return end

	if obj:IsA("Humanoid")
	or obj:IsA("AnimationController")
	or obj.Name == "HumanoidRootPart" then

		task.delay(0.2,function()
			process(obj)
		end)

	end

	if obj:IsA("BasePart") then
		applyWall(obj)
	end

end)

local function disable()

	for part in pairs(walls) do
		if part then
			part.LocalTransparencyModifier = 0
		end
	end

	for _,hl in pairs(highlights) do
		if hl then
			hl:Destroy()
		end
	end

	table.clear(highlights)
	table.clear(walls)
	table.clear(processed)

end

btn.MouseButton1Click:Connect(function()

	enabled = not enabled

	if enabled then

		btn.Text = "XRAY : ON"
		btn.BackgroundColor3 = Color3.fromRGB(0,180,0)

		task.wait(1)

		rescanLoop()

	else

		btn.Text = "XRAY : OFF"
		btn.BackgroundColor3 = Color3.fromRGB(170,0,0)

		disable()

	end

end)
