local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

--------------------------------------------------
-- PREVENT DUPLICATE
--------------------------------------------------

if CoreGui:FindFirstChild("XRAY_MOVEMENT") then
    CoreGui.XRAY_MOVEMENT:Destroy()
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "XRAY_MOVEMENT"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,130,0,40)
btn.Position = UDim2.new(0.1,0,0.5,0)
btn.Text = "XRAY2 : OFF"
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
local walls = {}
local processed = {}

--------------------------------------------------
-- PLAYER CHECK
--------------------------------------------------

local function isPlayerModel(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
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
-- MOVEMENT DETECTION
--------------------------------------------------

local function isMoving(model)

    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return false end

    local pos1 = part.Position
    task.wait(0.5)
    local pos2 = part.Position

    return (pos1 - pos2).Magnitude > 0.1
end

--------------------------------------------------
-- PROCESS MODEL
--------------------------------------------------

local function process(model)

    if processed[model] then return end
    if not model:IsA("Model") then return end

    processed[model] = true

    if isPlayerModel(model) then
        addHighlight(model,Color3.fromRGB(0,255,0))
        return
    end

    task.spawn(function()

        if isMoving(model) then
            addHighlight(model,Color3.fromRGB(255,0,0))
        end

    end)

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
        process(obj)
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
    table.clear(walls)
    table.clear(processed)

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
