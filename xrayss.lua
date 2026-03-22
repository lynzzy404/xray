-- ADVANCED XRAY / ESP SYSTEM
-- event based | npc + player detection | lightweight

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
-- SYSTEM
--------------------------------------------------

local xrayEnabled = false
local highlighted = {}

--------------------------------------------------
-- TARGET DETECTION
--------------------------------------------------

local function isPlayer(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function isNPC(model)

    if model:FindFirstChildWhichIsA("Humanoid") then
        if not isPlayer(model) then
            return true
        end
    end

    if model:FindFirstChildWhichIsA("AnimationController") then
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
-- HIGHLIGHT
--------------------------------------------------

local function createHighlight(model,color)

    if highlighted[model] then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.OutlineColor = color
    hl.Adornee = model
    hl.Parent = CoreGui

    highlighted[model] = hl

    model.AncestryChanged:Connect(function()
        if not model:IsDescendantOf(game) then
            if highlighted[model] then
                highlighted[model]:Destroy()
                highlighted[model] = nil
            end
        end
    end)
end

--------------------------------------------------
-- PROCESS OBJECT
--------------------------------------------------

local function processModel(model)

    if not xrayEnabled then return end
    if not model:IsA("Model") then return end

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
-- XRAY WALL TRANSPARENCY
--------------------------------------------------

local function applyXray()

    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = 0.5
        end
    end

end

local function disableXray()

    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = 0
        end
    end

    for model,hl in pairs(highlighted) do
        if hl then
            hl:Destroy()
        end
        highlighted[model] = nil
    end

end

--------------------------------------------------
-- STORAGE DETECTION
--------------------------------------------------

local function scanContainer(container)

    for _,obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Model") then
            processModel(obj)
        end
    end

    container.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            processModel(obj)
        end
    end)

end

--------------------------------------------------
-- INITIAL SCAN
--------------------------------------------------

local function startDetection()

    scanContainer(Workspace)

    if game:FindFirstChild("ReplicatedStorage") then
        scanContainer(game.ReplicatedStorage)
    end

    if game:FindFirstChild("ServerStorage") then
        scanContainer(game.ServerStorage)
    end

end

--------------------------------------------------
-- BUTTON
--------------------------------------------------

ToggleBtn.MouseButton1Click:Connect(function()

    xrayEnabled = not xrayEnabled

    if xrayEnabled then

        ToggleBtn.Text = "XRAY : ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)

        applyXray()
        startDetection()

    else

        ToggleBtn.Text = "XRAY : OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)

        disableXray()

    end

end)
