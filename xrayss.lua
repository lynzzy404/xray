local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

--------------------------------------------------
-- PREVENT DUPLICATE
--------------------------------------------------

if CoreGui:FindFirstChild("UNIVERSAL_XRAY") then
    CoreGui.UNIVERSAL_XRAY:Destroy()
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "UNIVERSAL_XRAY"
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

--------------------------------------------------
-- STATE
--------------------------------------------------

local enabled = false
local highlights = {}
local processed = {}
local walls = {}

--------------------------------------------------
-- PLAYER CHARACTER TABLE
--------------------------------------------------

local playerCharacters = {}

local function updatePlayers()

    table.clear(playerCharacters)

    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character then
            playerCharacters[p.Character] = true
        end
    end

end

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

task.spawn(function()
    while true do
        updatePlayers()
        task.wait(2)
    end
end)

--------------------------------------------------
-- RIG DETECTION
--------------------------------------------------

local function isRig(model)

    if not model:IsA("Model") then
        return false
    end

    local partCount = 0
    local jointFound = false

    for _,obj in ipairs(model:GetDescendants()) do

        if obj:IsA("BasePart") then
            partCount += 1
        end

        if obj:IsA("Motor6D") or obj:IsA("Weld") then
            jointFound = true
        end

        if partCount >= 2 and jointFound then
            return true
        end

    end

    return false
end

--------------------------------------------------
-- HIGHLIGHT
--------------------------------------------------

local function addHighlight(model,color)

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

--------------------------------------------------
-- PROCESS MODEL
--------------------------------------------------

local function process(model)

    if processed[model] then return end
    if not model:IsA("Model") then return end

    processed[model] = true

    if playerCharacters[model] then
        addHighlight(model,Color3.fromRGB(0,255,0))
        return
    end

    if isRig(model) then
        addHighlight(model,Color3.fromRGB(255,0,0))
    end

end

--------------------------------------------------
-- XRAY WALL
--------------------------------------------------

local function applyWall(part)

    if walls[part] then return end

    part.LocalTransparencyModifier = 0.5
    walls[part] = true

end

--------------------------------------------------
-- INITIAL SCAN
--------------------------------------------------

local function scanWorld()

    for _,obj in ipairs(Workspace:GetDescendants()) do

        if obj:IsA("Model") then
            process(obj)
        end

        if obj:IsA("BasePart") then
            applyWall(obj)
        end

    end

end

--------------------------------------------------
-- SPAWN DETECTION
--------------------------------------------------

Workspace.DescendantAdded:Connect(function(obj)

    if not enabled then return end

    if obj:IsA("Model") then
        task.delay(0.2,function()
            process(obj)
        end)
    end

    if obj:IsA("BasePart") then
        applyWall(obj)
    end

end)

--------------------------------------------------
-- DISABLE
--------------------------------------------------

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
    table.clear(processed)
    table.clear(walls)

end

--------------------------------------------------
-- BUTTON
--------------------------------------------------

btn.MouseButton1Click:Connect(function()

    enabled = not enabled

    if enabled then

        btn.Text = "XRAY : ON"
        btn.BackgroundColor3 = Color3.fromRGB(0,180,0)

        task.wait(1)
        scanWorld()

    else

        btn.Text = "XRAY : OFF"
        btn.BackgroundColor3 = Color3.fromRGB(170,0,0)

        disable()

    end

end)
