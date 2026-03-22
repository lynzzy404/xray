-- ADVANCED XRAY / ESP (STATIC SCAN)
-- single scan | lightweight | no auto update

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XraySystemGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,130,0,40)
ToggleBtn.Position = UDim2.new(0.1,0,0.5,0)
ToggleBtn.Text = "XRAY : OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

Instance.new("UICorner",ToggleBtn)

--------------------------------------------------
-- STATE
--------------------------------------------------

local enabled = false
local highlights = {}
local wallParts = {}

--------------------------------------------------
-- PLAYER CHECK
--------------------------------------------------

local function isPlayer(model)
	return Players:GetPlayerFromCharacter(model) ~= nil
end

--------------------------------------------------
-- NPC DETECTION
--------------------------------------------------

local function isNPC(model)

	if model:FindFirstChildWhichIsA("Humanoid") and not isPlayer(model) then
		return true
	end

	if model:FindFirstChildWhichIsA("AnimationController") then
		return true
	end

	if model:FindFirstChild("HumanoidRootPart") and not isPlayer(model) then
		return true
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
-- HIGHLIGHT CREATION
--------------------------------------------------

local function createHighlight(model,color)

	local hl = Instance.new("Highlight")
	hl.Name = "ESP_Highlight"
	hl.Adornee = model
	hl.FillTransparency = 1
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.OutlineColor = color
	hl.Parent = model

	table.insert(highlights,hl)

end

--------------------------------------------------
-- MODEL PROCESS
--------------------------------------------------

local function processModel(model)

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
-- WALL XRAY
--------------------------------------------------

local function applyWall(part)

	part.LocalTransparencyModifier = 0.5
	table.insert(wallParts,part)

end

--------------------------------------------------
-- WORLD SCAN
--------------------------------------------------

local function scanWorld()

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
-- DISABLE SYSTEM
--------------------------------------------------

local function disableXray()

	for _,p in ipairs(wallParts) do
		if p then
			p.LocalTransparencyModifier = 0
		end
	end

	for _,h in ipairs(highlights) do
		if h then
			h:Destroy()
		end
	end

	table.clear(wallParts)
	table.clear(highlights)

end

--------------------------------------------------
-- BUTTON
--------------------------------------------------

ToggleBtn.MouseButton1Click:Connect(function()

	enabled = not enabled

	if enabled then

		ToggleBtn.Text = "XRAY : ON"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)

		scanWorld()

	else

		ToggleBtn.Text = "XRAY : OFF"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)

		disableXray()

	end

end)
