-- =============================================
-- NEXUS OS - VISUAL DEBUGGER MODULE
-- Arquivo: VisualDebugger.lua
-- Local: src/Modules/VisualDebugger.lua
-- =============================================

local VisualDebugger = {
    Name = "VisualDebugger",
    Version = "3.0.0",
    Description = "Sistema avançado de debug visual com ESP, trajetórias e informações",
    Author = "Nexus Team",
    
    Features = {},
    Config = {},
    State = {
        Enabled = false,
        ActiveFeatures = {},
        Drawings = {},
        ESPObjects = {},
        Connections = {},
        Players = {}
    },
    
    Dependencies = {"StateManager"}
}

-- ============ CONFIGURAÇÕES PADRÃO ============
VisualDebugger.DefaultConfig = {
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Distance = true,
        Health = true,
        Weapon = true,
        Tracer = false,
        Skeleton = false,
        MaxDistance = 1000,
        BoxColor = Color3.fromRGB(0, 255, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextFont = 2, -- 0=Legacy, 1=System, 2=Monospace
        TeamCheck = true,
        TeamColor = true
    },
    Chams = {
        Enabled = false,
        Material = "ForceField",
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.3,
        Wireframe = false,
        WireframeColor = Color3.fromRGB(0, 255, 255),
        FillColor = Color3.fromRGB(255, 0, 0),
        FillTransparency = 0.5
    },
    Trajectory = {
        Enabled = false,
        PredictionTime = 1,
        LineColor = Color3.fromRGB(255, 255, 0),
        LineThickness = 2,
        DotColor = Color3.fromRGB(255, 0, 0),
        DotSize = 5,
        ShowVelocity = true
    },
    Camera = {
        FreeCam = false,
        FreeCamSpeed = 50,
        FOV = 70,
        LockOnTarget = false,
        SmoothLock = true,
        ThirdPerson = false,
        ThirdPersonDistance = 10
    },
    Environment = {
        FullBright = false,
        AmbientColor = Color3.fromRGB(128, 128, 128),
        OutdoorAmbient = Color3.fromRGB(128, 128, 128),
        ClockTime = 14,
        FogEnabled = false,
        FogColor = Color3.fromRGB(191, 191, 191),
        FogStart = 0,
        FogEnd = 1000
    }
}

-- ============ SISTEMA DE DESENHO 2D ============
local DrawingSystem = {
    Objects = {},
    ZIndex = 0,
    Visible = true
}

function DrawingSystem:CreateLine(name)
    local line = {
        Type = "Line",
        Visible = true,
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        From = Vector2.new(0, 0),
        To = Vector2.new(0, 0),
        ZIndex = self.ZIndex
    }
    
    self.Objects[name] = line
    self.ZIndex = self.ZIndex + 1
    
    return line
end

function DrawingSystem:CreateSquare(name)
    local square = {
        Type = "Square",
        Visible = true,
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        Filled = false,
        FillColor = Color3.new(0, 0, 0),
        Position = Vector2.new(0, 0),
        Size = Vector2.new(0, 0),
        ZIndex = self.ZIndex
    }
    
    self.Objects[name] = square
    self.ZIndex = self.ZIndex + 1
    
    return square
end

function DrawingSystem:CreateCircle(name)
    local circle = {
        Type = "Circle",
        Visible = true,
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        Filled = false,
        FillColor = Color3.new(0, 0, 0),
        Position = Vector2.new(0, 0),
        Radius = 10,
        ZIndex = self.ZIndex
    }
    
    self.Objects[name] = circle
    self.ZIndex = self.ZIndex + 1
    
    return circle
end

function DrawingSystem:CreateText(name)
    local text = {
        Type = "Text",
        Visible = true,
        Color = Color3.new(1, 1, 1),
        Text = "",
        Size = 14,
        Font = 2,
        Position = Vector2.new(0, 0),
        Center = false,
        Outline = true,
        OutlineColor = Color3.new(0, 0, 0),
        ZIndex = self.ZIndex
    }
    
    self.Objects[name] = text
    self.ZIndex = self.ZIndex + 1
    
    return text
end

function DrawingSystem:RemoveObject(name)
    self.Objects[name] = nil
end

function DrawingSystem:ClearAll()
    self.Objects = {}
    self.ZIndex = 0
end

function DrawingSystem:Render()
    if not self.Visible then
        return
    end
    
    -- Em um executor real, aqui seria o código para renderizar os objetos
    -- Esta é uma implementação simulada
    for name, obj in pairs(self.Objects) do
        if obj.Visible then
            -- Simulação de renderização
            -- print("[DrawingSystem] Rendering:", name, obj.Type)
        end
    end
end

-- ============ SISTEMA ESP ============
local ESPSystem = {
    Players = {},
    Objects = {},
    Boxes = {},
    TextLabels = {},
    Tracers = {},
    Skeletons = {}
}

function ESPSystem:WorldToScreen(position)
    local camera = workspace.CurrentCamera
    if not camera then
        return nil
    end
    
    local screenPoint, visible = camera:WorldToViewportPoint(position)
    
    return Vector2.new(screenPoint.X, screenPoint.Y), visible, screenPoint.Z
end

function ESPSystem:CalculateBox(character)
    if not character then
        return nil
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid then
        return nil
    end
    
    -- Calcular bounding box aproximada
    local position = root.Position
    local size = Vector3.new(4, 6, 4) -- Tamanho aproximado do personagem
    
    -- Obter pontos dos cantos da caixa
    local corners = {
        position + Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
        position + Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
        position + Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
        position + Vector3.new(size.X/2, size.Y/2, -size.Z/2),
        position + Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
        position + Vector3.new(size.X/2, -size.Y/2, size.Z/2),
        position + Vector3.new(-size.X/2, size.Y/2, size.Z/2),
        position + Vector3.new(size.X/2, size.Y/2, size.Z/2)
    }
    
    -- Converter para coordenadas de tela
    local screenCorners = {}
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    
    for _, corner in ipairs(corners) do
        local screenPos, visible = self:WorldToScreen(corner)
        if visible and screenPos then
            table.insert(screenCorners, screenPos)
            minX = math.min(minX, screenPos.X)
            minY = math.min(minY, screenPos.Y)
            maxX = math.max(maxX, screenPos.X)
            maxY = math.max(maxY, screenPos.Y)
        end
    end
    
    if #screenCorners == 0 then
        return nil
    end
    
    return {
        Position = Vector2.new(minX, minY),
        Size = Vector2.new(maxX - minX, maxY - minY),
        Corners = screenCorners
    }
end

function ESPSystem:CreateESP(player)
    if not player or not player.Character then
        return
    end
    
    local character = player.Character
    local playerName = player.Name
    local playerTeam = player.Team
    
    -- Verificar se já existe ESP para este jogador
    if self.Players[playerName] then
        return
    end
    
    -- Criar objetos de desenho
    local espObject = {
        Box = DrawingSystem:CreateSquare(playerName .. "_Box"),
        NameLabel = DrawingSystem:CreateText(playerName .. "_Name"),
        DistanceLabel = DrawingSystem:CreateText(playerName .. "_Distance"),
        HealthLabel = DrawingSystem:CreateText(playerName .. "_Health"),
        WeaponLabel = DrawingSystem:CreateText(playerName .. "_Weapon"),
        Tracer = DrawingSystem:CreateLine(playerName .. "_Tracer"),
        Skeleton = {}
    }
    
    -- Criar esqueleto (linhas conectando joints)
    local skeletonJoints = {
        "Head", "UpperTorso", "LowerTorso",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "RightUpperLeg", "RightLowerLeg", "RightFoot"
    }
    
    for i = 1, #skeletonJoints - 1 do
        espObject.Skeleton[skeletonJoints[i]] = DrawingSystem:CreateLine(playerName .. "_Skeleton_" .. skeletonJoints[i])
    end
    
    self.Players[playerName] = {
        Object = espObject,
        Player = player,
        Character = character,
        LastUpdate = tick()
    }
    
    return espObject
end

function ESPSystem:UpdateESP(playerName)
    local espData = self.Players[playerName]
    if not espData then
        return
    end
    
    local player = espData.Player
    local character = espData.Character
    local espObject = espData.Object
    
    if not player or not character or not espObject then
        self:RemoveESP(playerName)
        return
    end
    
    -- Verificar distância máxima
    local localPlayer = game:GetService("Players").LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid or not localRoot then
        return
    end
    
    -- Calcular distância
    local distance = (root.Position - localRoot.Position).Magnitude
    local maxDistance = VisualDebugger.Config.ESP.MaxDistance
    
    if distance > maxDistance then
        espObject.Box.Visible = false
        espObject.NameLabel.Visible = false
        espObject.DistanceLabel.Visible = false
        espObject.HealthLabel.Visible = false
        espObject.WeaponLabel.Visible = false
        espObject.Tracer.Visible = false
        
        for _, line in pairs(espObject.Skeleton) do
            line.Visible = false
        end
        
        return
    end
    
    -- Calcular caixa ESP
    local box = self:CalculateBox(character)
    if not box then
        return
    end
    
    -- Configurar cores baseado no time
    local boxColor = VisualDebugger.Config.ESP.BoxColor
    local textColor = VisualDebugger.Config.ESP.TextColor
    
    if VisualDebugger.Config.ESP.TeamCheck and VisualDebugger.Config.ESP.TeamColor then
        local localTeam = localPlayer.Team
        local playerTeam = player.Team
        
        if localTeam == playerTeam then
            boxColor = Color3.fromRGB(0, 100, 255) -- Azul para aliados
            textColor = Color3.fromRGB(200, 200, 255)
        else
            boxColor = Color3.fromRGB(255, 50, 50) -- Vermelho para inimigos
            textColor = Color3.fromRGB(255, 200, 200)
        end
    end
    
    -- Atualizar caixa
    if VisualDebugger.Config.ESP.Box then
        espObject.Box.Visible = true
        espObject.Box.Position = box.Position
        espObject.Box.Size = box.Size
        espObject.Box.Color = boxColor
        espObject.Box.Thickness = 2
        espObject.Box.Filled = false
    else
        espObject.Box.Visible = false
    end
    
    -- Atualizar nome
    if VisualDebugger.Config.ESP.Name then
        espObject.NameLabel.Visible = true
        espObject.NameLabel.Text = player.Name
        espObject.NameLabel.Position = Vector2.new(box.Position.X + box.Size.X/2, box.Position.Y - 20)
        espObject.NameLabel.Color = textColor
        espObject.NameLabel.Size = VisualDebugger.Config.ESP.TextSize
        espObject.NameLabel.Font = VisualDebugger.Config.ESP.TextFont
        espObject.NameLabel.Center = true
        espObject.NameLabel.Outline = true
    else
        espObject.NameLabel.Visible = false
    end
    
    -- Atualizar distância
    if VisualDebugger.Config.ESP.Distance then
        espObject.DistanceLabel.Visible = true
        espObject.DistanceLabel.Text = string.format("%.1f studs", distance)
        espObject.DistanceLabel.Position = Vector2.new(box.Position.X + box.Size.X/2, box.Position.Y + box.Size.Y + 5)
        espObject.DistanceLabel.Color = textColor
        espObject.DistanceLabel.Size = VisualDebugger.Config.ESP.TextSize - 2
        espObject.DistanceLabel.Font = VisualDebugger.Config.ESP.TextFont
        espObject.DistanceLabel.Center = true
        espObject.DistanceLabel.Outline = true
    else
        espObject.DistanceLabel.Visible = false
    end
    
    -- Atualizar saúde
    if VisualDebugger.Config.ESP.Health then
        espObject.HealthLabel.Visible = true
        espObject.HealthLabel.Text = string.format("HP: %d/%d", humanoid.Health, humanoid.MaxHealth)
        espObject.HealthLabel.Position = Vector2.new(box.Position.X - 60, box.Position.Y)
        espObject.HealthLabel.Color = Color3.fromRGB(0, 255, 0)
        espObject.HealthLabel.Size = VisualDebugger.Config.ESP.TextSize - 2
        espObject.HealthLabel.Font = VisualDebugger.Config.ESP.TextFont
        espObject.HealthLabel.Center = false
        espObject.HealthLabel.Outline = true
    else
        espObject.HealthLabel.Visible = false
    end
    
    -- Atualizar arma
    if VisualDebugger.Config.ESP.Weapon then
        local weapon = "None"
        
        -- Verificar se está segurando algo
        local rightHand = character:FindFirstChild("RightHand")
        if rightHand then
            local tool = rightHand:FindFirstChildOfClass("Tool")
            if tool then
                weapon = tool.Name
            end
        end
        
        espObject.WeaponLabel.Visible = true
        espObject.WeaponLabel.Text = "Weapon: " .. weapon
        espObject.WeaponLabel.Position = Vector2.new(box.Position.X + box.Size.X + 5, box.Position.Y)
        espObject.WeaponLabel.Color = textColor
        espObject.WeaponLabel.Size = VisualDebugger.Config.ESP.TextSize - 2
        espObject.WeaponLabel.Font = VisualDebugger.Config.ESP.TextFont
        espObject.WeaponLabel.Center = false
        espObject.WeaponLabel.Outline = true
    else
        espObject.WeaponLabel.Visible = false
    end
    
    -- Atualizar tracer
    if VisualDebugger.Config.ESP.Tracer then
        local screenSize = workspace.CurrentCamera.ViewportSize
        espObject.Tracer.Visible = true
        espObject.Tracer.From = Vector2.new(screenSize.X/2, screenSize.Y)
        espObject.Tracer.To = Vector2.new(box.Position.X + box.Size.X/2, box.Position.Y + box.Size.Y)
        espObject.Tracer.Color = boxColor
        espObject.Tracer.Thickness = 1
    else
        espObject.Tracer.Visible = false
    end
    
    -- Atualizar esqueleto
    if VisualDebugger.Config.ESP.Skeleton then
        local joints = {
            Head = character:FindFirstChild("Head"),
            UpperTorso = character:FindFirstChild("UpperTorso"),
            LowerTorso = character:FindFirstChild("LowerTorso"),
            LeftUpperArm = character:FindFirstChild("LeftUpperArm"),
            LeftLowerArm = character:FindFirstChild("LeftLowerArm"),
            LeftHand = character:FindFirstChild("LeftHand"),
            RightUpperArm = character:FindFirstChild("RightUpperArm"),
            RightLowerArm = character:FindFirstChild("RightLowerArm"),
            RightHand = character:FindFirstChild("RightHand"),
            LeftUpperLeg = character:FindFirstChild("LeftUpperLeg"),
            LeftLowerLeg = character:FindFirstChild("LeftLowerLeg"),
            LeftFoot = character:FindFirstChild("LeftFoot"),
            RightUpperLeg = character:FindFirstChild("RightUpperLeg"),
            RightLowerLeg = character:FindFirstChild("RightLowerLeg"),
            RightFoot = character:FindFirstChild("RightFoot")
        }
        
        -- Conexões do esqueleto
        local connections = {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"RightLowerArm", "RightHand"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"},
            {"RightUpperLeg", "RightLowerLeg"},
            {"RightLowerLeg", "RightFoot"}
        }
        
        for i, connection in ipairs(connections) do
            local joint1 = joints[connection[1]]
            local joint2 = joints[connection[2]]
            local skeletonLine = espObject.Skeleton[connection[1]]
            
            if joint1 and joint2 and skeletonLine then
                local screenPos1, visible1 = self:WorldToScreen(joint1.Position)
                local screenPos2, visible2 = self:WorldToScreen(joint2.Position)
                
                if visible1 and visible2 and screenPos1 and screenPos2 then
                    skeletonLine.Visible = true
                    skeletonLine.From = screenPos1
                    skeletonLine.To = screenPos2
                    skeletonLine.Color = Color3.fromRGB(255, 255, 255)
                    skeletonLine.Thickness = 1
                else
                    skeletonLine.Visible = false
                end
            end
        end
    else
        for _, line in pairs(espObject.Skeleton) do
            line.Visible = false
        end
    end
    
    espData.LastUpdate = tick()
end

function ESPSystem:RemoveESP(playerName)
    local espData = self.Players[playerName]
    if not espData then
        return
    end
    
    local espObject = espData.Object
    
    -- Remover todos os objetos de desenho
    DrawingSystem:RemoveObject(playerName .. "_Box")
    DrawingSystem:RemoveObject(playerName .. "_Name")
    DrawingSystem:RemoveObject(playerName .. "_Distance")
    DrawingSystem:RemoveObject(playerName .. "_Health")
    DrawingSystem:RemoveObject(playerName .. "_Weapon")
    DrawingSystem:RemoveObject(playerName .. "_Tracer")
    
    for jointName, _ in pairs(espObject.Skeleton) do
        DrawingSystem:RemoveObject(playerName .. "_Skeleton_" .. jointName)
    end
    
    self.Players[playerName] = nil
end

function ESPSystem:UpdateAllESP()
    local players = game:GetService("Players"):GetPlayers()
    local localPlayer = game:GetService("Players").LocalPlayer
    
    for _, player in ipairs(players) do
        if player ~= localPlayer and player.Character then
            if not self.Players[player.Name] then
                self:CreateESP(player)
            end
            
            self:UpdateESP(player.Name)
        end
    end
    
    -- Remover ESP de jogadores que saíram
    for playerName, _ in pairs(self.Players) do
        local stillExists = false
        for _, player in ipairs(players) do
            if player.Name == playerName then
                stillExists = true
                break
            end
        end
        
        if not stillExists then
            self:RemoveESP(playerName)
        end
    end
end

function ESPSystem:ClearAllESP()
    for playerName, _ in pairs(self.Players) do
        self:RemoveESP(playerName)
    end
    self.Players = {}
end

-- ============ FEATURE 1: ESP BOX ============
VisualDebugger.Features[1] = {
    Name = "ESP Box",
    Description = "Mostra caixas ao redor dos jogadores",
    Category = "ESP",
    DefaultKeybind = "F1",
    
    Activate = function()
        VisualDebugger.Config.ESP.Box = true
        
        -- Iniciar loop de atualização
        VisualDebugger.State.Connections.ESP = game:GetService("RunService").RenderStepped:Connect(function()
            if VisualDebugger.Config.ESP.Enabled then
                ESPSystem:UpdateAllESP()
                DrawingSystem:Render()
            end
        end)
        
        return true
    end,
    
    Deactivate = function()
        VisualDebugger.Config.ESP.Box = false
        
        -- Desconectar loop
        if VisualDebugger.State.Connections.ESP then
            VisualDebugger.State.Connections.ESP:Disconnect()
            VisualDebugger.State.Connections.ESP = nil
        end
        
        -- Limpar ESP
        ESPSystem:ClearAllESP()
        DrawingSystem:ClearAll()
        
        return true
    end
}

-- ============ FEATURE 2: ESP NAME ============
VisualDebugger.Features[2] = {
    Name = "ESP Name",
    Description = "Mostra nomes dos jogadores",
    Category = "ESP",
    DefaultKeybind = "F2",
    
    Activate = function()
        VisualDebugger.Config.ESP.Name = true
        return true
    end,
    
    Deactivate = function()
        VisualDebugger.Config.ESP.Name = false
        return true
    end
}

-- ============ FEATURE 3: ESP DISTANCE ============
VisualDebugger.Features[3] = {
    Name = "ESP Distance",
    Description = "Mostra distância dos jogadores",
    Category = "ESP",
    DefaultKeybind = "F3",
    
    Activate = function()
        VisualDebugger.Config.ESP.Distance = true
        return true
    end,
    
    Deactivate = function()
        VisualDebugger.Config.ESP.Distance = false
        return true
    end
}

-- ============ FEATURE 16: FREE CAMERA ============
VisualDebugger.Features[16] = {
    Name = "Free Camera",
    Description = "Câmera livre para explorar o ambiente",
    Category = "Camera",
    DefaultKeybind = "F4",
    
    Activate = function()
        local camera = workspace.CurrentCamera
        if not camera then
            return false
        end
        
        -- Salvar configurações originais
        local originalCFrame = camera.CFrame
        local originalType = camera.CameraType
        
        -- Criar estado da câmera livre
        local freeCamState = {
            Camera = camera,
            OriginalCFrame = originalCFrame,
            OriginalType = originalType,
            Speed = VisualDebugger.Config.Camera.FreeCamSpeed,
            Position = originalCFrame.Position,
            Rotation = {
                X = 0,
                Y = 0
            },
            Active = true
        }
        
        -- Configurar câmera
        camera.CameraType = Enum.CameraType.Scriptable
        
        -- Sistema de input para mover câmera
        local UserInputService = game:GetService("UserInputService")
        local inputs = {
            W = false,
            A = false,
            S = false,
            D = false,
            Space = false,
            LeftControl = false
        }
        
        -- Configurar inputs
        local inputConnections = {}
        
        inputConnections.Began = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.W then inputs.W = true end
                if input.KeyCode == Enum.KeyCode.A then inputs.A = true end
                if input.KeyCode == Enum.KeyCode.S then inputs.S = true end
                if input.KeyCode == Enum.KeyCode.D then inputs.D = true end
                if input.KeyCode == Enum.KeyCode.Space then inputs.Space = true end
                if input.KeyCode == Enum.KeyCode.LeftControl then inputs.LeftControl = true end
            end
            
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                freeCamState.Rotation.X = freeCamState.Rotation.X - input.Delta.X * 0.003
                freeCamState.Rotation.Y = freeCamState.Rotation.Y - input.Delta.Y * 0.003
                freeCamState.Rotation.Y = math.clamp(freeCamState.Rotation.Y, -math.pi/2, math.pi/2)
            end
        end)
        
        inputConnections.Ended = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.W then inputs.W = false end
                if input.KeyCode == Enum.KeyCode.A then inputs.A = false end
                if input.KeyCode == Enum.KeyCode.S then inputs.S = false end
                if input.KeyCode == Enum.KeyCode.D then inputs.D = false end
                if input.KeyCode == Enum.KeyCode.Space then inputs.Space = false end
                if input.KeyCode == Enum.KeyCode.LeftControl then inputs.LeftControl = false end
            end
        end)
        
        -- Loop de atualização
        local renderConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
            if not freeCamState.Active then
                return
            end
            
            -- Calcular direção
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            local up = camera.CFrame.UpVector
            
            local direction = Vector3.new()
            
            if inputs.W then direction = direction + forward end
            if inputs.S then direction = direction - forward end
            if inputs.D then direction = direction + right end
            if inputs.A then direction = direction - right end
            if inputs.Space then direction = direction + up end
            if inputs.LeftControl then direction = direction - up end
            
            -- Normalizar e aplicar velocidade
            if direction.Magnitude > 0 then
                direction = direction.Unit
            end
            
            freeCamState.Position = freeCamState.Position + (direction * freeCamState.Speed * deltaTime)
            
            -- Calcular rotação
            local rotX = freeCamState.Rotation.X
            local rotY = freeCamState.Rotation.Y
            
            local cframe = CFrame.new(freeCamState.Position)
                * CFrame.fromEulerAnglesYXZ(rotY, rotX, 0)
            
            camera.CFrame = cframe
        end)
        
        freeCamState.InputConnections = inputConnections
        freeCamState.RenderConnection = renderConnection
        
        VisualDebugger.State.ActiveFeatures[16] = freeCamState
        VisualDebugger.Config.Camera.FreeCam = true
        
        return true
    end,
    
    Deactivate = function()
        local feature = VisualDebugger.State.ActiveFeatures[16]
        if not feature then
            return false
        end
        
        -- Restaurar câmera
        if feature.Camera and feature.Camera.Parent then
            feature.Camera.CameraType = feature.OriginalType
            feature.Camera.CFrame = feature.OriginalCFrame
        end
        
        -- Desconectar
        if feature.InputConnections then
            if feature.InputConnections.Began then
                feature.InputConnections.Began:Disconnect()
            end
            if feature.InputConnections.Ended then
                feature.InputConnections.Ended:Disconnect()
            end
        end
        
        if feature.RenderConnection then
            feature.RenderConnection:Disconnect()
        end
        
        VisualDebugger.State.ActiveFeatures[16] = nil
        VisualDebugger.Config.Camera.FreeCam = false
        
        return true
    end
}

-- ============ FEATURE 26: FULL BRIGHT ============
VisualDebugger.Features[26] = {
    Name = "Full Bright",
    Description = "Remove sombras e escuridão do ambiente",
    Category = "Environment",
    DefaultKeybind = "F5",
    
    Activate = function()
        local lighting = game:GetService("Lighting")
        
        -- Salvar configurações originais
        local originalSettings = {
            Ambient = lighting.Ambient,
            OutdoorAmbient = lighting.OutdoorAmbient,
            Brightness = lighting.Brightness,
            GlobalShadows = lighting.GlobalShadows,
            Technology = lighting.Technology
        }
        
        -- Aplicar Full Bright
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        lighting.Brightness = 2
        lighting.GlobalShadows = false
        lighting.Technology = Enum.Technology.Compatibility
        
        -- Monitorar mudanças na iluminação
        local connections = {}
        
        connections.Ambient = lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
            if VisualDebugger.Config.Environment.FullBright then
                lighting.Ambient = Color3.fromRGB(255, 255, 255)
            end
        end)
        
        connections.Brightness = lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
            if VisualDebugger.Config.Environment.FullBright then
                lighting.Brightness = 2
            end
        end)
        
        VisualDebugger.State.ActiveFeatures[26] = {
            Lighting = lighting,
            OriginalSettings = originalSettings,
            Connections = connections
        }
        
        VisualDebugger.Config.Environment.FullBright = true
        
        return true
    end,
    
    Deactivate = function()
        local feature = VisualDebugger.State.ActiveFeatures[26]
        if not feature then
            return false
        end
        
        -- Restaurar configurações
        local lighting = feature.Lighting
        
        if lighting and lighting.Parent then
            lighting.Ambient = feature.OriginalSettings.Ambient
            lighting.OutdoorAmbient = feature.OriginalSettings.OutdoorAmbient
            lighting.Brightness = feature.OriginalSettings.Brightness
            lighting.GlobalShadows = feature.OriginalSettings.GlobalShadows
            lighting.Technology = feature.OriginalSettings.Technology
        end
        
        -- Desconectar
        for _, connection in pairs(feature.Connections) do
            connection:Disconnect()
        end
        
        VisualDebugger.State.ActiveFeatures[26] = nil
        VisualDebugger.Config.Environment.FullBright = false
        
        return true
    end
}

-- ============ FUNÇÕES AUXILIARES DO MÓDULO ============
function VisualDebugger:Initialize()
    print("[VisualDebugger] Initializing module...")
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Inicializar sistemas
    DrawingSystem:ClearAll()
    ESPSystem:ClearAllESP()
    
    -- Preencher features restantes (4-15, 17-25, 27-30)
    for i = 4, 30 do
        if not self.Features[i] then
            self.Features[i] = {
                Name = "Visual Feature " .. i,
                Description = "Visual feature placeholder " .. i,
                Category = "Placeholder",
                Activate = function() 
                    print("Visual Feature " .. i .. " activated")
                    return true 
                end,
                Deactivate = function() 
                    print("Visual Feature " .. i .. " deactivated")
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
    
    print("[VisualDebugger] Module initialized with 30 features")
    
    return true
end

function VisualDebugger:EnableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    local feature = self.Features[featureId]
    
    if self.State.ActiveFeatures[featureId] then
        return false, "Feature already active"
    end
    
    local success, err = feature.Activate()
    
    if success then
        print("[VisualDebugger] Feature enabled: " .. feature.Name)
        
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

function VisualDebugger:DisableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    if not self.State.ActiveFeatures[featureId] then
        return false, "Feature not active"
    end
    
    local feature = self.Features[featureId]
    local success = feature.Deactivate()
    
    if success then
        print("[VisualDebugger] Feature disabled: " .. feature.Name)
        
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

function VisualDebugger:ToggleFeature(featureId)
    if self.State.ActiveFeatures[featureId] then
        return self:DisableFeature(featureId)
    else
        return self:EnableFeature(featureId)
    end
end

function VisualDebugger:GetFeatureStatus(featureId)
    return {
        Active = self.State.ActiveFeatures[featureId] ~= nil,
        Feature = self.Features[featureId],
        State = self.State.ActiveFeatures[featureId]
    }
end

function VisualDebugger:UpdateConfig(newConfig)
    for category, settings in pairs(newConfig) do
        if self.Config[category] then
            for key, value in pairs(settings) do
                self.Config[category][key] = value
            end
        end
    end
    
    -- Reaplicar configurações a features ativas
    for featureId, _ in pairs(self.State.ActiveFeatures) do
        self:DisableFeature(featureId)
        self:EnableFeature(featureId)
    end
    
    return true
end

function VisualDebugger:Shutdown()
    print("[VisualDebugger] Shutting down module...")
    
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
    
    -- Limpar desenhos
    DrawingSystem:ClearAll()
    ESPSystem:ClearAllESP()
    
    -- Atualizar estado
    if _G.NexusStateManager then
        _G.NexusStateManager:SetStateStatus(self.Name, "INACTIVE")
    end
    
    self.State.Enabled = false
    
    print("[VisualDebugger] Module shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusModules then
    _G.NexusModules = {}
end

_G.NexusModules.VisualDebugger = VisualDebugger

return VisualDebugger
