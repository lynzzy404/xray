-- ADVANCED XRAY / ESP SYSTEM (FIXED VERSION)
-- Logic: Event-based | Anti-Lag | No Memory Leak

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- GUI SETUP (FIXED)
--------------------------------------------------
-- Hapus GUI lama kalau ada biar gak tumpang tindih
if CoreGui:FindFirstChild("AdvancedXrayGui_V2") then
    CoreGui.AdvancedXrayGui_V2:Destroy()
end

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
ToggleBtn.Draggable = true -- Note: Draggable sudah deprecated tapi masih jalan di banyak executor
ToggleBtn.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8) -- FIX: Pakai UDim, bukan ToolBuffer
UICorner.Parent = ToggleBtn

--------------------------------------------------
-- VARIABLES & CLEANUP SYSTEM
--------------------------------------------------
local xrayEnabled = false
local highlighted = {}
local connections = {}

local function cleanup()
    -- Putus semua event listener dulu
    for _, conn in ipairs(connections) do
        if conn then conn:Disconnect() end
    end
    connections = {}

    -- Hapus Highlight
    for model, hl in pairs(highlighted) do
        if hl and hl.Parent then hl:Destroy() end
    end
    highlighted = {}

    -- Reset Transparansi Part
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
    if not model:IsA("Model") then return false end
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
    if not model or highlighted[model] or model == LocalPlayer.Character then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.OutlineColor = color
    hl.FillColor = color
    hl.Adornee = model
    hl.Parent = CoreGui -- Taruh di CoreGui biar aman

    highlighted[model] = hl
end

local function processModel(model)
    if not xrayEnabled then return end

    if Players:GetPlayerFromCharacter(model) then
        createHighlight(model, Color3.fromRGB(0, 255, 0))
    elseif isNPC(model) then
        createHighlight(model, Color3.fromRGB(255, 0, 0))
    end
end

--------------------------------------------------
-- CORE FUNCTIONS
--------------------------------------------------
local function applyXray()
    -- Pake task.spawn biar tombolnya nggak 'freeze' pas lagi scan map gede
    task.spawn(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not xrayEnabled then break end -- Stop kalau dimatiin tengah jalan
            if obj:IsA("Model") then processModel(obj) end
            if obj:IsA("BasePart") then obj.LocalTransparencyModifier = 0.5 end
            
            -- Biar nggak kena limit rate/lag, kasih wait tiap 500 objek
            if _ % 500 == 0 then task.wait() end
        end
    end)

    local conn = Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        if not xrayEnabled then return end
        if obj:IsA("Model") then
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

print("Xray V2.1 Fixed & Loaded!")
