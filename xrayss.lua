-- ADVANCED XRAY / ESP SYSTEM (STABLE VERSION)
-- Optimized by Gemini | Event-based | Anti-Lag

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- GUI SETUP
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedXrayGui_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 140, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.Text = "XRAY : OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = ToolBuffer.new(0, 8) -- Simple rounding
UICorner.Parent = ToggleBtn

--------------------------------------------------
-- VARIABLES & CLEANUP SYSTEM
--------------------------------------------------
local xrayEnabled = false
local highlighted = {}
local connections = {} -- Tempat simpan event biar bisa di-disconnect

local function cleanup()
    -- Hapus semua Highlight
    for model, hl in pairs(highlighted) do
        if hl then hl:Destroy() end
    end
    highlighted = {}

    -- Putus semua koneksi event (mencegah lag bertumpuk)
    for _, conn in ipairs(connections) do
        if conn then conn:Disconnect() end
    end
    connections = {}

    -- Balikin transparansi part (Hanya yang pernah diubah)
    -- Kita pakai cara lebih ringan: cuma balikin yang kelihatan
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = 0
        end
    end
end

--------------------------------------------------
-- DETECTION LOGIC
--------------------------------------------------
local function isNPC(model)
    if Players:GetPlayerFromCharacter(model) then return false end
    
    if model:FindFirstChildWhichIsA("Humanoid") or model:FindFirstChildWhichIsA("AnimationController") then
        return true
    end

    local name = string.lower(model.Name)
    local keywords = {"npc","enemy","monster","mob","boss","zombie","dummy","bot","ai"}
    for _, k in ipairs(keywords) do
        if string.find(name, k) then return true end
    end
    return false
end

local function createHighlight(model, color)
    if highlighted[model] or model == LocalPlayer.Character then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.OutlineColor = color
    hl.FillColor = color
    hl.Adornee = model
    hl.Parent = CoreGui

    highlighted[model] = hl
end

local function processModel(model)
    if not xrayEnabled or not model:IsA("Model") then return end

    if Players:GetPlayerFromCharacter(model) then
        createHighlight(model, Color3.fromRGB(0, 255, 0)) -- Player = Hijau
    elseif isNPC(model) then
        createHighlight(model, Color3.fromRGB(255, 0, 0)) -- NPC = Merah
    end
end

--------------------------------------------------
-- CORE FUNCTIONS
--------------------------------------------------
local function applyXray()
    -- Scan awal
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then processModel(obj) end
        if obj:IsA("BasePart") then obj.LocalTransparencyModifier = 0.5 end
    end

    -- Pantau objek baru masuk Workspace
    local conn = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            task.wait(0.1) -- Kasih jeda dikit biar part model keload semua
            processModel(obj)
        elseif obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = 0.5
        end
    end)
    table.insert(connections, conn)
end

--------------------------------------------------
-- BUTTON INTERACTION
--------------------------------------------------
ToggleBtn.MouseButton1Click:Connect(function()
    xrayEnabled = not xrayEnabled

    if xrayEnabled then
        ToggleBtn.Text = "XRAY : ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        applyXray()
    else
        ToggleBtn.Text = "XRAY : OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        cleanup()
    end
end)

print("Advanced Xray System Loaded!")
