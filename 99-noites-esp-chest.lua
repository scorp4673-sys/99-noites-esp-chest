-- LocalScript: Chest Markers + GUI com contador + distância até os baús
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local MAX_VISIBLE_DISTANCE = 100000 -- distância máxima em studs para mostrar o marcador
local markersEnabled = true -- começa ligado

-- ========= GUI =========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChestGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- botão de ligar/desligar
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Text = "Baús: ON"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = screenGui

-- contador de baús
local chestCounter = Instance.new("TextLabel")
chestCounter.Size = UDim2.new(0, 200, 0, 40)
chestCounter.Position = UDim2.new(0, 20, 0, 160)
chestCounter.BackgroundTransparency = 0.3
chestCounter.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
chestCounter.TextColor3 = Color3.fromRGB(255, 255, 0)
chestCounter.TextScaled = true
chestCounter.Font = Enum.Font.SourceSansBold
chestCounter.Text = "Baús: 0"
chestCounter.Parent = screenGui

toggleButton.MouseButton1Click:Connect(function()
    markersEnabled = not markersEnabled
    if markersEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        toggleButton.Text = "Baús: ON"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        toggleButton.Text = "Baús: OFF"
    end
end)

-- ========= Funções de marcador =========
local function makeMarkerForPart(part)
    if not part or not part:IsA("BasePart") then return nil end
    if part:FindFirstChild("ChestMarker") then return part.ChestMarker end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ChestMarker"
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 140, 0, 50)
    billboard.MaxDistance = 0
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Name = "ChestLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "💰 BAÚ"
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.TextStrokeTransparency = 0.6
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.Parent = billboard

    return billboard
end

local function createMarkerForChestModel(model)
    if not model or not model.Parent then return end
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end
    return makeMarkerForPart(part)
end

local function removeMarkerFromChestModel(model)
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if part and part:FindFirstChild("ChestMarker") then
        part.ChestMarker:Destroy()
    end
end

-- Atualiza visibilidade e distância
local function updateMarkers()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    local allChests = CollectionService:GetTagged("Chest")

    -- contador na GUI
    chestCounter.Text = "Baús: " .. tostring(#allChests)

    for _, chest in pairs(allChests) do
        local part = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart", true)
        if part and part:FindFirstChild("ChestMarker") then
            local dist = (part.Position - hrp.Position).Magnitude
            local label = part.ChestMarker:FindFirstChild("ChestLabel")

            -- Atualiza o texto com distância arredondada
            if label then
                label.Text = "💰 BAÚ — " .. math.floor(dist) .. "m"
            end

            -- Controle de visibilidade
            part.ChestMarker.Enabled = (markersEnabled and dist <= MAX_VISIBLE_DISTANCE)
        end
    end
end

-- ========= Inicialização =========
for _, chest in ipairs(CollectionService:GetTagged("Chest")) do
    createMarkerForChestModel(chest)
end

CollectionService:GetInstanceAddedSignal("Chest"):Connect(function(instance)
    task.defer(function()
        createMarkerForChestModel(instance)
    end)
end)

CollectionService:GetInstanceRemovedSignal("Chest"):Connect(removeMarkerFromChestModel)

RunService.RenderStepped:Connect(updateMarkers)
