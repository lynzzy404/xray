-- ADVANCED XRAY / ESP ENGINE
-- stable event system | respawn tracking | lightweight

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedXrayGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,120,0,40)
ToggleBtn.Position = UDim2.new(0.1,0,0.5,0)
ToggleBtn.Text = "XRAY : OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Parent = ToggleBtn

--------------------------------------------------
-- STATE
--------------------------------------------------

local xrayEnabled = false
local detectionStarted = false

local processed = {}
local highlights = {}
local wallParts = {}

--------------------------------------------------
-- PLAYER CHECK
--------------------------------------------------

local function isPlayer(model)
	return Players:GetPlayerFromCharacter(model) ~= nil
end

--------------------------------------------------
-- NPC DETECTION ENGINE
--------------------------------------------------

local function isNPC(model)

	if model:FindFirstChildWhichIsA("Humanoid") then
		if not isPlayer(model) then
			return true
		end
	end

	if model:FindFirstChildWhichIsA("AnimationController") then
		return true
	end

	if model:FindFirstChild("HumanoidRootPart") then
		if not isPlayer(model) then
			return true
		end
	end

	if model.PrimaryPart then
		if not isPlayer(model) then
			return true
		end
	end

	local name = string.lower(model.Name)

	local keywords = {
		"npc","enemy","monster","mob",
		"boss","zombie","dummy","bot","ai"
	}

	for _,k in ipairs(keywords) do
		if string.find(name,k) then
			return true
		end
	end

	return false
end

--------------------------------------------------
-- HIGHLIGHT
--------------------------------------------------

local function createHighlight(model,color)

	if highlights[model] then return end

	local hl = Instance.new("Highlight")
	hl.Name = "ESP_Highlight"
	hl.FillTransparency = 1
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.OutlineColor = color
	hl.Adornee = model
	hl.Parent = model

	highlights[model] = hl

	model.Destroying:Connect(function()
		if highlights[model] then
			highlights[model]:Destroy()
			highlights[model] = nil
		end
		processed[model] = nil
	end)

end

--------------------------------------------------
-- MODEL PROCESSOR
--------------------------------------------------

local function processModel(model)

	if not xrayEnabled then return end
	if processed[model] then return end
	if not model:IsA("Model") then return end

	processed[model] = true

	if isPlayer(model) then
		createHighlight(model,Color3.fromRGB(0,255,0))
		return
	end

	if isNPC(model) then
		createHighlight(model,Color3.fromRGB(255,0,0))
		return
	end

end

--------------------------------------------------
-- XRAY WALL SYSTEM
--------------------------------------------------

local function applyWall(part)

	if not part:IsA("BasePart") then return end
	if wallParts[part] then return end

	wallParts[part] = true
	part.LocalTransparencyModifier = 0.5

	part.Destroying:Connect(function()
		wallParts[part] = nil
	end)

end

--------------------------------------------------
-- INITIAL WORLD SCAN
--------------------------------------------------

local function initialScan()

	for _,obj in ipairs(Workspace:GetDescendants()) do

		if obj:IsA("Model") then
			processModel(obj)
		end

		if obj:IsA("BasePart") then
			applyWall(obj)
		end

	end

end

--------------------------------------------------
-- GLOBAL EVENT TRACKING
--------------------------------------------------

local function startDetection()

	if detectionStarted then return end
	detectionStarted = true

	initialScan()

	Workspace.DescendantAdded:Connect(function(obj)

		if not xrayEnabled then return end

		if obj:IsA("Model") then
			processModel(obj)
		end

		if obj:IsA("BasePart") then
			applyWall(obj)
		end

	end)

end

--------------------------------------------------
-- DISABLE SYSTEM
--------------------------------------------------

local function disableXray()

	for part,_ in pairs(wallParts) do
		if part then
			part.LocalTransparencyModifier = 0
		end
	end

	for model,hl in pairs(highlights) do
		if hl then
			hl:Destroy()
		end
	end

	table.clear(wallParts)
	table.clear(highlights)
	table.clear(processed)

end

--------------------------------------------------
-- BUTTON
--------------------------------------------------

ToggleBtn.MouseButton1Click:Connect(function()

	xrayEnabled = not xrayEnabled

	if xrayEnabled then

		ToggleBtn.Text = "XRAY : ON"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)

		startDetection()

	else

		ToggleBtn.Text = "XRAY : OFF"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)

		disableXray()

	end

end)
