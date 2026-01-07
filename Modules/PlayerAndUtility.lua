-- =============================================
-- NEXUS OS - PLAYER AND UTILITY MODULE
-- Arquivo: PlayerAndUtility.lua
-- Local: src/Modules/PlayerAndUtility.lua
-- =============================================

local PlayerAndUtility = {
    Name = "PlayerAndUtility",
    Version = "3.0.0",
    Description = "Módulo de utilitários para o jogador com 30 features",
    Author = "Nexus Team",
    
    Features = {},
    Config = {},
    State = {
        Enabled = false,
        ActiveFeatures = {},
        Character = nil,
        Humanoid = nil,
        Connections = {},
        SavedPositions = {}
    },
    
    Dependencies = {"StateManager", "Memory"}
}

-- ============ CONFIGURAÇÕES PADRÃO ============
PlayerAndUtility.DefaultConfig = {
    Character = {
        GodMode = false,
        InfiniteJump = false,
        NoFallDamage = true,
        AutoRespawn = true,
        RespawnDelay = 3,
        AntiStun = true,
        AntiGrab = true,
        AntiPush = true
    },
    Server = {
        RejoinServer = false,
        ServerHop = false,
        HopDelay = 30,
        AvoidAdmins = true,
        AdminCheck = true,
        Blacklist = {},
        Whitelist = {}
    },
    Utility = {
        AntiAFK = true,
        AFKInterval = 30,
        AutoScreenshot = false,
        ScreenshotInterval = 300,
        ChatLogger = false,
        ChatSavePath = "NexusOS/Chats/",
        FPSUnlocker = true,
        MaxFPS = 144,
        MemoryCleaner = true,
        CleanInterval = 60
    },
    Teleport = {
        SavePosition = true,
        MaxSaved = 10,
        VisualMarkers = true,
        MarkerColor = Color3.fromRGB(255, 255, 0),
        MarkerSize = 5
    }
}

-- ============ SISTEMA DE GOD MODE ============
local GodModeSystem = {
    OriginalHealth = 100,
    OriginalMaxHealth = 100,
    DamageConnections = {},
    Invincible = false
}

function GodModeSystem:Enable()
    local character = PlayerAndUtility.State.Character
    if not character then
        return false, "Character not found"
    end
    
    local humanoid = PlayerAndUtility.State.Humanoid
    if not humanoid then
        return false, "Humanoid not found"
    end
    
    -- Salvar valores originais
    self.OriginalHealth = humanoid.Health
    self.OriginalMaxHealth = humanoid.MaxHealth
    
    -- Configurar god mode
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
    
    -- Prevenir dano
    self.DamageConnections.TakingDamage = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health < math.huge then
            humanoid.Health = math.huge
        end
    end)
    
    -- Prevenir morte
    self.DamageConnections.Died = humanoid.Died:Connect(function()
        if PlayerAndUtility.Config.Character.AutoRespawn then
            wait(PlayerAndUtility.Config.Character.RespawnDelay)
            humanoid.Health = math.huge
        end
    end)
    
    self.Invincible = true
    
    return true
end

function GodModeSystem:Disable()
    local humanoid = PlayerAndUtility.State.Humanoid
    if humanoid and humanoid.Parent then
        humanoid.MaxHealth = self.OriginalMaxHealth
        humanoid.Health = math.min(self.OriginalHealth, self.OriginalMaxHealth)
    end
    
    -- Desconectar
    for _, connection in pairs(self.DamageConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    self.DamageConnections = {}
    self.Invincible = false
    
    return true
end

-- ============ SISTEMA DE TELEPORT ============
local TeleportSystem = {
    SavedPositions = {},
    Markers = {},
    MaxSaved = 10
}

function TeleportSystem:SavePosition(name, position)
    if not position then
        local character = PlayerAndUtility.State.Character
        if not character then
            return false, "Character not found"
        end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then
            return false, "Root part not found"
        end
        
        position = root.Position
    end
    
    -- Limitar número de posições salvas
    if #self.SavedPositions >= self.MaxSaved then
        table.remove(self.SavedPositions, 1)
    end
    
    local savedPosition = {
        Name = name or "Position_" .. #self.SavedPositions + 1,
        Position = position,
        Timestamp = os.time(),
        Map = game.PlaceId
    }
    
    table.insert(self.SavedPositions, savedPosition)
    
    -- Criar marcador visual
    if PlayerAndUtility.Config.Teleport.VisualMarkers then
        self:CreateMarker(savedPosition)
    end
    
    return true, savedPosition
end

function TeleportSystem:CreateMarker(positionData)
    -- Criar um marcador visual no mapa
    local marker = Instance.new("Part")
    marker.Name = "NexusMarker_" .. positionData.Name
    marker.Position = positionData.Position + Vector3.new(0, 2, 0)
    marker.Size = Vector3.new(PlayerAndUtility.Config.Teleport.MarkerSize, 5, PlayerAndUtility.Config.Teleport.MarkerSize)
    marker.Color = PlayerAndUtility.Config.Teleport.MarkerColor
    marker.Material = Enum.Material.Neon
    marker.Anchored = true
    marker.CanCollide = false
    marker.Transparency = 0.3
    
    -- Adicionar guia
    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(PlayerAndUtility.Config.Teleport.MarkerColor)
    beam.Width0 = 1
    beam.Width1 = 1
    beam.Attachment0 = Instance.new("Attachment")
    beam.Attachment0.Parent = marker
    beam.Attachment1 = Instance.new("Attachment")
    beam.Attachment1.Parent = marker
    beam.Attachment1.Position = Vector3.new(0, -10, 0)
    beam.Parent = marker
    
    -- Texto
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MarkerLabel"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 100
    billboard.Parent = marker
    
    local label = Instance.new("TextLabel")
    label.Text = positionData.Name
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard
    
    marker.Parent = workspace
    
    self.Markers[positionData.Name] = marker
    
    return marker
end

function TeleportSystem:TeleportToPosition(positionName)
    local positionData = nil
    
    -- Encontrar posição pelo nome
    for _, pos in ipairs(self.SavedPositions) do
        if pos.Name == positionName then
            positionData = pos
            break
        end
    end
    
    if not positionData then
        return false, "Position not found"
    end
    
    local character = PlayerAndUtility.State.Character
    if not character then
        return false, "Character not found"
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return false, "Root part not found"
    end
    
    -- Executar teleporte
    root.CFrame = CFrame.new(positionData.Position)
    
    return true, positionData.Position
end

function TeleportSystem:ClearMarkers()
    for name, marker in pairs(self.Markers) do
        if marker and marker.Parent then
            marker:Destroy()
        end
    end
    
    self.Markers = {}
end

-- ============ SISTEMA ANTI-AFK ============
local AntiAFKSystem = {
    Active = false,
    LastMovement = tick(),
    VirtualInputs = {},
    Connection = nil
}

function AntiAFKSystem:Enable()
    if self.Active then
        return false, "Already active"
    end
    
    self.Active = true
    self.LastMovement = tick()
    
    -- Sistema de input virtual
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    
    -- Função para simular movimento
    local function simulateMovement()
        if not self.Active then
            return
        end
        
        -- Simular pequeno movimento do mouse
        VirtualInputManager:SendMouseMoveEvent(10, 10)
        wait(0.1)
        VirtualInputManager:SendMouseMoveEvent(-10, -10)
        
        -- Simular tecla pressionada
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, nil)
        wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, nil)
        
        self.LastMovement = tick()
    end
    
    -- Loop anti-AFK
    self.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        local currentTime = tick()
        local interval = PlayerAndUtility.Config.Utility.AFKInterval
        
        if currentTime - self.LastMovement >= interval then
            simulateMovement()
        end
    end)
    
    return true
end

function AntiAFKSystem:Disable()
    if not self.Active then
        return false
    end
    
    self.Active = false
    
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    return true
end

-- ============ FEATURE 1: GOD MODE ============
PlayerAndUtility.Features[1] = {
    Name = "God Mode",
    Description = "Torne-se invencível",
    Category = "Character",
    DefaultKeybind = "G",
    
    Activate = function()
        return GodModeSystem:Enable()
    end,
    
    Deactivate = function()
        return GodModeSystem:Disable()
    end
}

-- ============ FEATURE 2: INFINITE JUMP ============
PlayerAndUtility.Features[2] = {
    Name = "Infinite Jump",
    Description = "Pule infinitamente no ar",
    Category = "Character",
    DefaultKeybind = "H",
    
    Activate = function()
        local character = PlayerAndUtility.State.Character
        if not character then
            return false, "Character not found"
        end
        
        local humanoid = PlayerAndUtility.State.Humanoid
        if not humanoid then
            return false, "Humanoid not found"
        end
        
        -- Sistema de infinite jump
        local infiniteJump = {
            Jumping = false,
            JumpCount = 0
        }
        
        local function onJumping()
            if not PlayerAndUtility.Config.Character.InfiniteJump then
                return
            end
            
            infiniteJump.Jumping = true
            infiniteJump.JumpCount = infiniteJump.JumpCount + 1
            
            -- Permitir pulo extra
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        
        local function onStateChanged(old, new)
            if new == Enum.HumanoidStateType.Landed then
                infiniteJump.Jumping = false
                infiniteJump.JumpCount = 0
            end
        end
        
        -- Conexões
        local jumpConnection = humanoid.Jumping:Connect(onJumping)
        local stateConnection = humanoid.StateChanged:Connect(onStateChanged)
        
        -- Keybind para pulo extra
        local UserInputService = game:GetService("UserInputService")
        local inputConnection = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
                if infiniteJump.Jumping and infiniteJump.JumpCount < 5 then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        
        PlayerAndUtility.State.ActiveFeatures[2] = {
            JumpConnection = jumpConnection,
            StateConnection = stateConnection,
            InputConnection = inputConnection,
            InfiniteJump = infiniteJump
        }
        
        return true
    end,
    
    Deactivate = function()
        local feature = PlayerAndUtility.State.ActiveFeatures[2]
        if not feature then
            return false
        end
        
        -- Desconectar
        if feature.JumpConnection then
            feature.JumpConnection:Disconnect()
        end
        
        if feature.StateConnection then
            feature.StateConnection:Disconnect()
        end
        
        if feature.InputConnection then
            feature.InputConnection:Disconnect()
        end
        
        PlayerAndUtility.State.ActiveFeatures[2] = nil
        
        return true
    end
}

-- ============ FEATURE 5: SAVE POSITION ============
PlayerAndUtility.Features[5] = {
    Name = "Save Position",
    Description = "Salva sua posição atual",
    Category = "Teleport",
    DefaultKeybind = "P",
    
    Activate = function()
        local success, positionData = TeleportSystem:SavePosition("Manual_Save_" .. os.time())
        
        if success then
            if _G.NexusOS and _G.NexusOS.NotificationSystem then
                _G.NexusOS.NotificationSystem:Notify({
                    Title = "Position Saved",
                    Text = "Position: " .. positionData.Name,
                    Duration = 3,
                    Type = "SUCCESS"
                })
            end
            return true
        else
            return false, positionData
        end
    end,
    
    Deactivate = function()
        -- Esta feature não precisa de deactivate
        return true
    end
}

-- ============ FEATURE 6: LOAD POSITION ============
PlayerAndUtility.Features[6] = {
    Name = "Load Position",
    Description = "Teleporta para uma posição salva",
    Category = "Teleport",
    DefaultKeybind = "O",
    
    Activate = function()
        if #TeleportSystem.SavedPositions == 0 then
            return false, "No saved positions"
        end
        
        -- Teleportar para a última posição salva
        local lastPosition = TeleportSystem.SavedPositions[#TeleportSystem.SavedPositions]
        local success, position = TeleportSystem:TeleportToPosition(lastPosition.Name)
        
        if success then
            if _G.NexusOS and _G.NexusOS.NotificationSystem then
                _G.NexusOS.NotificationSystem:Notify({
                    Title = "Position Loaded",
                    Text = "Teleported to: " .. lastPosition.Name,
                    Duration = 3,
                    Type = "SUCCESS"
                })
            end
            return true
        else
            return false, position
        end
    end,
    
    Deactivate = function()
        -- Esta feature não precisa de deactivate
        return true
    end
}

-- ============ FEATURE 10: ANTI-AFK ============
PlayerAndUtility.Features[10] = {
    Name = "Anti-AFK",
    Description = "Previne que você seja kickado por AFK",
    Category = "Utility",
    DefaultKeybind = "F9",
    
    Activate = function()
        return AntiAFKSystem:Enable()
    end,
    
    Deactivate = function()
        return AntiAFKSystem:Disable()
    end
}

-- ============ FEATURE 12: FPS UNLOCKER ============
PlayerAndUtility.Features[12] = {
    Name = "FPS Unlocker",
    Description = "Remove o limite de FPS do Roblox",
    Category = "Utility",
    DefaultKeybind = "F10",
    
    Activate = function()
        if not PlayerAndUtility.Config.Utility.FPSUnlocker then
            return false, "FPS Unlocker disabled in config"
        end
        
        -- Desbloquear FPS
        local RunService = game:GetService("RunService")
        local UserSettings = UserSettings()
        local GameSettings = settings()
        
        -- Salvar configurações originais
        local originalSettings = {
            FPS = GameSettings.Rendering.Framerate,
            VSync = GameSettings.Rendering.EnableFRM
        }
        
        -- Configurar FPS alto
        GameSettings.Rendering.Framerate = PlayerAndUtility.Config.Utility.MaxFPS
        GameSettings.Rendering.EnableFRM = false
        
        -- Monitorar mudanças
        local settingsConnection = GameSettings:GetPropertyChangedSignal("Rendering"):Connect(function()
            if PlayerAndUtility.Config.Utility.FPSUnlocker then
                GameSettings.Rendering.Framerate = PlayerAndUtility.Config.Utility.MaxFPS
                GameSettings.Rendering.EnableFRM = false
            end
        end)
        
        PlayerAndUtility.State.ActiveFeatures[12] = {
            OriginalSettings = originalSettings,
            SettingsConnection = settingsConnection,
            CurrentFPS = PlayerAndUtility.Config.Utility.MaxFPS
        }
        
        return true
    end,
    
    Deactivate = function()
        local feature = PlayerAndUtility.State.ActiveFeatures[12]
        if not feature then
            return false
        end
        
        -- Restaurar configurações
        local GameSettings = settings()
        GameSettings.Rendering.Framerate = feature.OriginalSettings.FPS
        GameSettings.Rendering.EnableFRM = feature.OriginalSettings.VSync
        
        -- Desconectar
        if feature.SettingsConnection then
            feature.SettingsConnection:Disconnect()
        end
        
        PlayerAndUtility.State.ActiveFeatures[12] = nil
        
        return true
    end
}

-- ============ FEATURE 13: MEMORY CLEANER ============
PlayerAndUtility.Features[13] = {
    Name = "Memory Cleaner",
    Description = "Limpa a memória para melhor performance",
    Category = "Utility",
    DefaultKeybind = "F11",
    
    Activate = function()
        if not PlayerAndUtility.Config.Utility.MemoryCleaner then
            return false, "Memory Cleaner disabled in config"
        end
        
        local memoryCleaner = {
            Active = true,
            LastClean = tick(),
            TotalCleaned = 0
        }
        
        local function cleanupMemory()
            if not memoryCleaner.Active then
                return
            end
            
            -- Forçar garbage collection
            local stats = game:GetService("Stats")
            local beforeMemory = stats:GetTotalMemoryUsageMb()
            
            collectgarbage()
            collectgarbage()
            
            local afterMemory = stats:GetTotalMemoryUsageMb()
            local cleaned = beforeMemory - afterMemory
            
            memoryCleaner.TotalCleaned = memoryCleaner.TotalCleaned + cleaned
            memoryCleaner.LastClean = tick()
            
            if _G.NexusOS and _G.NexusOS.Logger then
                _G.NexusOS.Logger:Log("INFO", 
                    string.format("Memory cleaned: %.2f MB (Total: %.2f MB)", 
                    cleaned, memoryCleaner.TotalCleaned), 
                    "MemoryCleaner")
            end
        end
        
        -- Loop de limpeza
        local connection = game:GetService("RunService").Heartbeat:Connect(function()
            local currentTime = tick()
            local interval = PlayerAndUtility.Config.Utility.CleanInterval
            
            if currentTime - memoryCleaner.LastClean >= interval then
                cleanupMemory()
            end
        end)
        
        memoryCleaner.Connection = connection
        
        -- Limpar uma vez agora
        cleanupMemory()
        
        PlayerAndUtility.State.ActiveFeatures[13] = memoryCleaner
        
        return true
    end,
    
    Deactivate = function()
        local feature = PlayerAndUtility.State.ActiveFeatures[13]
        if not feature then
            return false
        end
        
        feature.Active = false
        
        if feature.Connection then
            feature.Connection:Disconnect()
        end
        
        PlayerAndUtility.State.ActiveFeatures[13] = nil
        
        return true
    end
}

-- ============ FEATURE 20: SERVER REJOIN ============
PlayerAndUtility.Features[20] = {
    Name = "Server Rejoin",
    Description = "Reconecta ao servidor atual",
    Category = "Server",
    DefaultKeybind = "F12",
    
    Activate = function()
        if not PlayerAndUtility.Config.Server.RejoinServer then
            return false, "Server Rejoin disabled in config"
        end
        
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        
        local placeId = game.PlaceId
        local jobId = game.JobId
        
        -- Tentar reconectar
        local success, result = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, localPlayer)
        end)
        
        if success then
            return true
        else
            return false, result
        end
    end,
    
    Deactivate = function()
        -- Esta feature não precisa de deactivate
        return true
    end
}

-- ============ FUNÇÕES AUXILIARES DO MÓDULO ============
function PlayerAndUtility:ValidateCharacter()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    
    self.State.Character = localPlayer.Character
    self.State.Humanoid = self.State.Character and self.State.Character:FindFirstChildOfClass("Humanoid")
    
    return self.State.Humanoid ~= nil
end

function PlayerAndUtility:Initialize()
    print("[PlayerAndUtility] Initializing module...")
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Validar character
    if not self:ValidateCharacter() then
        -- Esperar character carregar
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        
        local function onCharacterAdded(character)
            self.State.Character = character
            self.State.Humanoid = character:WaitForChild("Humanoid", 5)
            
            if self.State.Humanoid then
                print("[PlayerAndUtility] Character loaded")
            end
        end
        
        if localPlayer.Character then
            onCharacterAdded(localPlayer.Character)
        end
        
        self.State.Connections.CharacterAdded = localPlayer.CharacterAdded:Connect(onCharacterAdded)
    end
    
    -- Inicializar sistemas
    TeleportSystem.MaxSaved = self.Config.Teleport.MaxSaved
    
    -- Carregar posições salvas
    if self.Config.Teleport.SavePosition then
        self:LoadSavedPositions()
    end
    
    -- Preencher features restantes (3-4, 7-9, 11, 14-19, 21-30)
    for i = 3, 30 do
        if not self.Features[i] then
            self.Features[i] = {
                Name = "Player Feature " .. i,
                Description = "Player feature placeholder " .. i,
                Category = "Placeholder",
                Activate = function() 
                    print("Player Feature " .. i .. " activated")
                    return true 
                end,
                Deactivate = function() 
                    print("Player Feature " .. i .. " deactivated")
                    return true 
                end
            }
        end
    end
    
    -- Registrar no StateManager
    if _G.NexusStateManager then
        _G.NexusStateManager:CreateState(self.Name, "MODULE")
        _G.NexusStateManager:SetStateStatus(self.Name, "ACTIVE")
    end
    
    self.State.Enabled = true
    
    print("[PlayerAndUtility] Module initialized with 30 features")
    
    return true
end

function PlayerAndUtility:LoadSavedPositions()
    local filePath = "NexusOS/SavedPositions.json"
    
    local success, fileData = pcall(readfile, filePath)
    if not success then
        print("[PlayerAndUtility] No saved positions file found")
        return false
    end
    
    local success, data = pcall(game:GetService("HttpService").JSONDecode, 
        game:GetService("HttpService"), fileData)
    
    if success and data and type(data) == "table" then
        TeleportSystem.SavedPositions = data
        
        -- Recriar marcadores
        if self.Config.Teleport.VisualMarkers then
            for _, position in ipairs(data) do
                if position.Map == game.PlaceId then
                    TeleportSystem:CreateMarker(position)
                end
            end
        end
        
        print("[PlayerAndUtility] Loaded", #data, "saved positions")
        return true
    end
    
    return false
end

function PlayerAndUtility:SavePositions()
    local filePath = "NexusOS/SavedPositions.json"
    local jsonData = game:GetService("HttpService"):JSONEncode(TeleportSystem.SavedPositions)
    
    pcall(writefile, filePath, jsonData)
    
    print("[PlayerAndUtility] Saved", #TeleportSystem.SavedPositions, "positions")
    return true
end

function PlayerAndUtility:EnableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    local feature = self.Features[featureId]
    
    if self.State.ActiveFeatures[featureId] then
        return false, "Feature already active"
    end
    
    local success, err = feature.Activate()
    
    if success then
        print("[PlayerAndUtility] Feature enabled: " .. feature.Name)
        
        if _G.NexusStateManager then
            _G.NexusStateManager:CreateState(
                self.Name .. "_Feature_" .. featureId,
                "FEATURE",
                self.Name
            )
            _G.NexusStateManager:SetStateStatus(
                self.Name .. "_Feature_" .. featureId,
                "ACTIVE"
            )
        end
        
        return true
    else
        return false, err or "Activation failed"
    end
end

function PlayerAndUtility:DisableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    if not self.State.ActiveFeatures[featureId] then
        return false, "Feature not active"
    end
    
    local feature = self.Features[featureId]
    local success = feature.Deactivate()
    
    if success then
        print("[PlayerAndUtility] Feature disabled: " .. feature.Name)
        
        if _G.NexusStateManager then
            _G.NexusStateManager:SetStateStatus(
                self.Name .. "_Feature_" .. featureId,
                "INACTIVE"
            )
        end
        
        return true
    else
        return false, "Deactivation failed"
    end
end

function PlayerAndUtility:ToggleFeature(featureId)
    if self.State.ActiveFeatures[featureId] then
        return self:DisableFeature(featureId)
    else
        return self:EnableFeature(featureId)
    end
end

function PlayerAndUtility:GetFeatureStatus(featureId)
    return {
        Active = self.State.ActiveFeatures[featureId] ~= nil,
        Feature = self.Features[featureId],
        State = self.State.ActiveFeatures[featureId]
    }
end

function PlayerAndUtility:UpdateConfig(newConfig)
    for category, settings in pairs(newConfig) do
        if self.Config[category] then
            for key, value in pairs(settings) do
                self.Config[category][key] = value
            end
        end
    end
    
    -- Atualizar sistemas
    TeleportSystem.MaxSaved = self.Config.Teleport.MaxSaved
    
    -- Reaplicar configurações a features ativas
    for featureId, _ in pairs(self.State.ActiveFeatures) do
        self:DisableFeature(featureId)
        self:EnableFeature(featureId)
    end
    
    return true
end

function PlayerAndUtility:Shutdown()
    print("[PlayerAndUtility] Shutting down module...")
    
    -- Desativar todas as features
    for featureId, _ in pairs(self.State.ActiveFeatures) do
        self:DisableFeature(featureId)
    end
    
    -- Desconectar conexões
    for _, connection in pairs(self.State.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Salvar posições
    if self.Config.Teleport.SavePosition then
        self:SavePositions()
    end
    
    -- Limpar marcadores
    TeleportSystem:ClearMarkers()
    
    -- Atualizar estado
    if _G.NexusStateManager then
        _G.NexusStateManager:SetStateStatus(self.Name, "INACTIVE")
    end
    
    self.State.Enabled = false
    
    print("[PlayerAndUtility] Module shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusModules then
    _G.NexusModules = {}
end

_G.NexusModules.PlayerAndUtility = PlayerAndUtility

return PlayerAndUtility
