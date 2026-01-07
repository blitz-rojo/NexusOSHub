-- =============================================
-- NEXUS OS - PHYSICS AND MOVEMENT MODULE
-- Arquivo: PhysicsAndMovement.lua
-- Local: src/Modules/PhysicsAndMovement.lua
-- =============================================

local PhysicsAndMovement = {
    Name = "PhysicsAndMovement",
    Version = "3.0.0",
    Description = "Módulo de controle avançado de física e movimentação com 30 features",
    Author = "Nexus Team",
    
    Features = {},
    Config = {},
    State = {
        Enabled = false,
        ActiveFeatures = {},
        Player = nil,
        Character = nil,
        Humanoid = nil,
        Connections = {}
    },
    
    Dependencies = {"StateManager"}
}

-- ============ CONFIGURAÇÕES PADRÃO ============
PhysicsAndMovement.DefaultConfig = {
    Flight = {
        Speed = 50,
        Smoothness = 0.5,
        VerticalSpeed = 25,
        NoClip = false,
        AutoHover = true
    },
    Speed = {
        WalkSpeed = 16,
        RunSpeed = 50,
        JumpPower = 50,
        AutoRun = false
    },
    Teleport = {
        SafetyCheck = true,
        AntiFall = true,
        Precision = 1,
        VisualEffects = true
    },
    Vehicle = {
        BoostMultiplier = 3,
        HandlingMultiplier = 2,
        InfiniteFuel = true,
        AutoDrive = false
    },
    Physics = {
        Gravity = 196.2,
        Friction = 0.3,
        Bounciness = 0.5,
        AntiStuck = true
    }
}
-- ============ SEGURANÇA DE FÍSICA (NEXUS CRYPTO) ============
local NexusCrypto = _G.NexusCrypto
local ProtectionState = NexusCrypto and NexusCrypto.State
local ProtectionConfig = NexusCrypto and NexusCrypto.Config.AntiBan

local function IsSecurityClear()
    if not (NexusCrypto and ProtectionState and ProtectionState.ProtectionActive) then
        return true -- Sem proteção configurada, permite execução
    end

    local currentTime = os.clock() -- Alta precisão
    local lastDetection = ProtectionState.LastDetection or 0
    local cooldown = ProtectionConfig.DetectionCooldown or 5

    -- Verifica Cooldown
    if lastDetection > 0 and (currentTime - lastDetection) < cooldown then
        return false, "Security cooldown active (" .. string.format("%.2f", cooldown - (currentTime - lastDetection)) .. "s)"
    end

    return true
end

-- ============ SISTEMA DE INPUT ============
local InputSystem = {
    Keybinds = {},
    ActiveInputs = {},
    Mouse = {
        Position = Vector2.new(0, 0),
        Delta = Vector2.new(0, 0)
    }
}

function InputSystem:RegisterKeybind(key, featureId, callback)
    self.Keybinds[key] = {
        FeatureId = featureId,
        Callback = callback,
        Active = true
    }
end

function InputSystem:ProcessInput(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local keybind = self.Keybinds[input.KeyCode.Name]
        if keybind and keybind.Active then
            if input.UserInputState == Enum.UserInputState.Begin then
                keybind.Callback(true)
            else
                keybind.Callback(false)
            end
        end
    end
end

-- ============ FEATURE 1: SUPERMAN FLIGHT ============
PhysicsAndMovement.Features[1] = {
    Name = "Superman Flight",
    Description = "Voe como o Superman com controles suaves",
    Category = "Flight",
    DefaultKeybind = "F",
    
        Activate = function()
        -- 1. Verificação de Segurança Anti-Ban
        local isSafe, reason = IsSecurityClear()
        if not isSafe then
            print("[Anti-Ban] Flight blocked: " .. reason)
            return false, reason
        end

        -- 2. Delay Humanizado na Ativação
        if NexusCrypto then
            local delay = NexusCrypto:GetRandomDelay(0.1)
            if task and task.wait then task.wait(delay) else wait(delay) end
        end

        -- Início do código original da Feature...
        local self = PhysicsAndMovement
        
        if not self:ValidateCharacter() then
            return false, "No character found"
        end
        
        -- (O resto do código da feature continua aqui...)

        -- Criar partes de voo
        local root = self.State.Character:FindFirstChild("HumanoidRootPart")
        if not root then
            return false, "No HumanoidRootPart found"
        end
        
        -- Criar BodyVelocity para controle
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "NexusFlightVelocity"
        bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        bodyVelocity.P = 10000
        bodyVelocity.Velocity = Vector3.new()
        bodyVelocity.Parent = root
        
        -- Criar BodyGyro para estabilização
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "NexusFlightGyro"
        bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
        bodyGyro.P = 1000
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root
        
        -- Estado do voo
        local flying = true
        local velocity = Vector3.new()
        local lastUpdate = tick()
        
        -- Configurar NoClip se ativado
        if config.NoClip then
            self:EnableNoClip()
        end
        
        -- Função de atualização do voo
        local function updateFlight(deltaTime)
            if not flying or not self.State.Character then
                return
            end
            
            local camera = workspace.CurrentCamera
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector
            
            -- Calcular input (simplificado - em produção usar InputService)
            local forward = InputSystem.ActiveInputs.W or 0
            local backward = InputSystem.ActiveInputs.S or 0
            local right = InputSystem.ActiveInputs.D or 0
            local left = InputSystem.ActiveInputs.A or 0
            local up = InputSystem.ActiveInputs.Space or 0
            local down = InputSystem.ActiveInputs.LeftControl or 0
            
            -- Calcular direção
            local direction = Vector3.new()
            
            if forward == 1 then
                direction = direction + lookVector
            end
            if backward == 1 then
                direction = direction - lookVector
            end
            if right == 1 then
                direction = direction + rightVector
            end
            if left == 1 then
                direction = direction - rightVector
            end
            
            -- Normalizar direção horizontal
            if direction.Magnitude > 0 then
                direction = direction.Unit
            end
            
            -- Adicionar componente vertical
            local vertical = Vector3.new(0, up - down, 0)
            
            -- Calcular velocidade final
            local targetVelocity = (direction * speed) + (vertical * verticalSpeed)
            
            -- Aplicar suavidade
            velocity = velocity:Lerp(targetVelocity, smoothness * deltaTime * 10)
            
            -- Aplicar velocidade
            bodyVelocity.Velocity = velocity
            
            -- Atualizar BodyGyro para manter orientação
            if config.AutoHover then
                local targetCFrame = CFrame.new(root.Position, root.Position + lookVector)
                bodyGyro.CFrame = bodyGyro.CFrame:Lerp(targetCFrame, 0.1)
            end
        end
        
        -- Conexão de loop
        local connection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            updateFlight(deltaTime)
        end)
        
        -- Registrar keybinds
        InputSystem:RegisterKeybind("F", 1, function(pressed)
            if pressed then
                flying = not flying
                if not flying then
                    bodyVelocity.Velocity = Vector3.new()
                end
            end
        end)
        
        -- Armazenar estado
        self.State.ActiveFeatures[1] = {
            Flying = flying,
            BodyVelocity = bodyVelocity,
            BodyGyro = bodyGyro,
            Connection = connection,
            Velocity = velocity
        }
        
        return true
    end,
    
    Deactivate = function()
        local self = PhysicsAndMovement
        
        local feature = self.State.ActiveFeatures[1]
        if not feature then
            return false
        end
        
        -- Desconectar loop
        if feature.Connection then
            feature.Connection:Disconnect()
        end
        
        -- Remover físicas
        if feature.BodyVelocity and feature.BodyVelocity.Parent then
            feature.BodyVelocity:Destroy()
        end
        
        if feature.BodyGyro and feature.BodyGyro.Parent then
            feature.BodyGyro:Destroy()
        end
        
        -- Desativar NoClip se estiver ativo
        if self.Config.Flight.NoClip then
            self:DisableNoClip()
        end
        
        -- Remover keybind
        InputSystem.Keybinds["F"] = nil
        
        self.State.ActiveFeatures[1] = nil
        
        return true
    end
}

-- ============ FEATURE 2: NO CLIP ============
PhysicsAndMovement.Features[2] = {
    Name = "No Clip",
    Description = "Atravesse paredes e objetos",
    Category = "Flight",
    DefaultKeybind = "N",
    
    Activate = function()
        local self = PhysicsAndMovement
        
        if not self:ValidateCharacter() then
            return false, "No character found"
        end
        
        -- Desativar colisão em todas as partes
        local originalCollision = {}
        
        local function disableCollision(part)
            if part:IsA("BasePart") then
                originalCollision[part] = part.CanCollide
                part.CanCollide = false
                part.Massless = true
            end
        end
        
        local function enableCollision(part)
            if part:IsA("BasePart") and originalCollision[part] ~= nil then
                part.CanCollide = originalCollision[part]
                part.Massless = false
            end
        end
        
        -- Aplicar a todas as partes atuais
        for _, part in ipairs(self.State.Character:GetDescendants()) do
            disableCollision(part)
        end
        
        -- Configurar conexão para novas partes
        local connection = self.State.Character.DescendantAdded:Connect(function(descendant)
            disableCollision(descendant)
        end)
        
        -- Registrar keybind para toggle
        InputSystem:RegisterKeybind("N", 2, function(pressed)
            if pressed then
                local current = self.State.ActiveFeatures[2]
                if current and current.Active then
                    -- Reativar colisão temporariamente
                    for part, canCollide in pairs(current.OriginalCollision) do
                        if part and part.Parent then
                            part.CanCollide = canCollide
                            part.Massless = false
                        end
                    end
                    current.Active = false
                elseif current then
                    -- Desativar colisão novamente
                    for part, canCollide in pairs(current.OriginalCollision) do
                        if part and part.Parent then
                            part.CanCollide = false
                            part.Massless = true
                        end
                    end
                    current.Active = true
                end
            end
        end)
        
        self.State.ActiveFeatures[2] = {
            OriginalCollision = originalCollision,
            Connection = connection,
            Active = true
        }
        
        return true
    end,
    
    Deactivate = function()
        local self = PhysicsAndMovement
        
        local feature = self.State.ActiveFeatures[2]
        if not feature then
            return false
        end
        
        -- Restaurar colisão
        for part, canCollide in pairs(feature.OriginalCollision) do
            if part and part.Parent then
                part.CanCollide = canCollide
                part.Massless = false
            end
        end
        
        -- Desconectar
        if feature.Connection then
            feature.Connection:Disconnect()
        end
        
        -- Remover keybind
        InputSystem.Keybinds["N"] = nil
        
        self.State.ActiveFeatures[2] = nil
        
        return true
    end
}

-- ============ FEATURE 3: SPEED CONTROL ============
PhysicsAndMovement.Features[3] = {
    Name = "Speed Control",
    Description = "Aumente sua velocidade de movimento",
    Category = "Movement",
    DefaultKeybind = "V",
    
    Activate = function()
        local self = PhysicsAndMovement
        
        if not self:ValidateCharacter() then
            return false, "No character found"
        end
        
        local humanoid = self.State.Humanoid
        local originalWalkSpeed = humanoid.WalkSpeed
        local originalRunSpeed = humanoid.RunSpeed
        
        -- Aplicar novas velocidades
        humanoid.WalkSpeed = self.Config.Speed.WalkSpeed
        humanoid.RunSpeed = self.Config.Speed.RunSpeed
        
        -- Sistema de auto-run
        if self.Config.Speed.AutoRun then
            humanoid:Move(Vector3.new(1, 0, 0))
        end
        
        -- Registrar keybind para toggle
        InputSystem:RegisterKeybind("V", 3, function(pressed)
            if pressed then
                local current = humanoid.WalkSpeed
                if current == self.Config.Speed.WalkSpeed then
                    humanoid.WalkSpeed = originalWalkSpeed
                    humanoid.RunSpeed = originalRunSpeed
                else
                    humanoid.WalkSpeed = self.Config.Speed.WalkSpeed
                    humanoid.RunSpeed = self.Config.Speed.RunSpeed
                end
            end
        end)
        
        self.State.ActiveFeatures[3] = {
            OriginalWalkSpeed = originalWalkSpeed,
            OriginalRunSpeed = originalRunSpeed,
            Humanoid = humanoid
        }
        
        return true
    end,
    
    Deactivate = function()
        local self = PhysicsAndMovement
        
        local feature = self.State.ActiveFeatures[3]
        if not feature then
            return false
        end
        
        -- Restaurar velocidades
        if feature.Humanoid and feature.Humanoid.Parent then
            feature.Humanoid.WalkSpeed = feature.OriginalWalkSpeed
            feature.Humanoid.RunSpeed = feature.OriginalRunSpeed
        end
        
        -- Remover keybind
        InputSystem.Keybinds["V"] = nil
        
        self.State.ActiveFeatures[3] = nil
        
        return true
    end
}

-- ============ FEATURE 4: SUPER JUMP ============
PhysicsAndMovement.Features[4] = {
    Name = "Super Jump",
    Description = "Pule alturas incríveis",
    Category = "Movement",
    DefaultKeybind = "J",
    
    Activate = function()
        local self = PhysicsAndMovement
        
        if not self:ValidateCharacter() then
            return false, "No character found"
        end
        
        local humanoid = self.State.Humanoid
        local originalJumpPower = humanoid.JumpPower
        local originalJumpHeight = humanoid.JumpHeight
        
        -- Aplicar novo poder de pulo
        humanoid.JumpPower = self.Config.Speed.JumpPower
        humanoid.JumpHeight = self.Config.Speed.JumpPower / 2
        
        -- Sistema de double jump
        local canDoubleJump = true
        local jumpCount = 0
        
        local function onJumping()
            jumpCount = jumpCount + 1
            
            if jumpCount == 2 and canDoubleJump then
                -- Aplicar impulso extra
                local root = self.State.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(0, 40000, 0)
                    bodyVelocity.Velocity = Vector3.new(0, self.Config.Speed.JumpPower * 0.5, 0)
                    bodyVelocity.Parent = root
                    
                    game:GetService("Debris"):AddItem(bodyVelocity, 0.2)
                end
            end
        end
        
        local function onStateChanged(old, new)
            if new == Enum.HumanoidStateType.Landed then
                jumpCount = 0
                canDoubleJump = true
            end
        end
        
        local jumpConnection = humanoid.Jumping:Connect(onJumping)
        local stateConnection = humanoid.StateChanged:Connect(onStateChanged)
        
        -- Registrar keybind
        InputSystem:RegisterKeybind("J", 4, function(pressed)
            if pressed and canDoubleJump and jumpCount == 1 then
                onJumping()
            end
        end)
        
        self.State.ActiveFeatures[4] = {
            OriginalJumpPower = originalJumpPower,
            OriginalJumpHeight = originalJumpHeight,
            JumpConnection = jumpConnection,
            StateConnection = stateConnection,
            JumpCount = jumpCount,
            CanDoubleJump = canDoubleJump
        }
        
        return true
    end,
    
    Deactivate = function()
        local self = PhysicsAndMovement
        
        local feature = self.State.ActiveFeatures[4]
        if not feature then
            return false
        end
        
        -- Restaurar configurações
        if feature.Humanoid and feature.Humanoid.Parent then
            feature.Humanoid.JumpPower = feature.OriginalJumpPower
            feature.Humanoid.JumpHeight = feature.OriginalJumpHeight
        end
        
        -- Desconectar
        if feature.JumpConnection then
            feature.JumpConnection:Disconnect()
        end
        
        if feature.StateConnection then
            feature.StateConnection:Disconnect()
        end
        
        -- Remover keybind
        InputSystem.Keybinds["J"] = nil
        
        self.State.ActiveFeatures[4] = nil
        
        return true
    end
}

-- ============ FEATURE 17: TELEPORT TO POSITION ============
PhysicsAndMovement.Features[17] = {
    Name = "Teleport to Position",
    Description = "Teleporte para coordenadas específicas",
    Category = "Teleport",
    DefaultKeybind = "T",
    
    Activate = function()
        local self = PhysicsAndMovement
        
        if not self:ValidateCharacter() then
            return false, "No character found"
        end
        
        -- Função de teleporte principal
        local function teleportTo(position, visualEffects)
            if not self.State.Character then
                return false, "Character not found"
            end
            
            local root = self.State.Character:FindFirstChild("HumanoidRootPart")
            if not root then
                return false, "No HumanoidRootPart found"
            end
            
            -- Verificação de segurança
            if self.Config.Teleport.SafetyCheck then
                -- Verificar se a posição é segura
                local ray = Ray.new(position + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0))
                local hit, hitPos = workspace:FindPartOnRay(ray, self.State.Character)
                
                if not hit then
                    return false, "Unsafe position"
                end
                
                position = hitPos + Vector3.new(0, 3, 0)
            end
            
            -- Efeitos visuais
            if visualEffects and self.Config.Teleport.VisualEffects then
                -- Criar partículas de teleporte
                local particles = Instance.new("ParticleEmitter")
                particles.Texture = "rbxassetid://242866429"
                particles.Rate = 100
                particles.Lifetime = NumberRange.new(0.5, 1)
                particles.Speed = NumberRange.new(5, 10)
                particles.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.5),
                    NumberSequenceKeypoint.new(1, 0)
                })
                particles.Parent = root
                
                game:GetService("Debris"):AddItem(particles, 1)
            end
            
            -- Executar teleporte
            root.CFrame = CFrame.new(position)
            
            return true
        end
        
        -- Função de teleporte para waypoint
        local function teleportToWaypoint(waypointName)
            -- Buscar waypoint no workspace
            local waypoint = workspace:FindFirstChild(waypointName)
            if waypoint and waypoint:IsA("BasePart") then
                return teleportTo(waypoint.Position, true)
            end
            return false, "Waypoint not found"
        end
        
        -- Função de teleporte para jogador
        local function teleportToPlayer(playerName)
            local players = game:GetService("Players"):GetPlayers()
            for _, player in ipairs(players) do
                if player.Name == playerName and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        return teleportTo(root.Position, true)
                    end
                end
            end
            return false, "Player not found"
        end
        
        -- Registrar keybind
        InputSystem:RegisterKeybind("T", 17, function(pressed)
            if pressed then
                -- Exemplo: Teleportar para spawn (pode ser configurado via UI)
                local spawn = workspace:FindFirstChild("SpawnLocation")
                if spawn then
                    teleportTo(spawn.Position, true)
                end
            end
        end)
        
        self.State.ActiveFeatures[17] = {
            TeleportTo = teleportTo,
            TeleportToWaypoint = teleportToWaypoint,
            TeleportToPlayer = teleportToPlayer
        }
        
        return true
    end,
    
    Deactivate = function()
        local self = PhysicsAndMovement
        
        local feature = self.State.ActiveFeatures[17]
        if not feature then
            return false
        end
        
        -- Remover keybind
        InputSystem.Keybinds["T"] = nil
        
        self.State.ActiveFeatures[17] = nil
        
        return true
    end
}

-- ============ FEATURE 23: VEHICLE BOOST ============
PhysicsAndMovement.Features[23] = {
    Name = "Vehicle Boost",
    Description = "Aumente a velocidade dos veículos",
    Category = "Vehicle",
    DefaultKeybind = "B",
    
    Activate = function()
        local self = PhysicsAndMovement
        
        -- Encontrar veículo atual
        local character = self.State.Character
        if not character then
            return false, "No character found"
        end
        
        -- Função para aplicar boost ao veículo
        local function applyVehicleBoost(vehicleSeat)
            if not vehicleSeat then
                return false
            end
            
            local originalSpeed = vehicleSeat.MaxSpeed
            local originalTorque = vehicleSeat.Torque
            
            -- Aumentar velocidade
            vehicleSeat.MaxSpeed = originalSpeed * self.Config.Vehicle.BoostMultiplier
            vehicleSeat.Torque = originalTorque * self.Config.Vehicle.HandlingMultiplier
            
            -- Sistema de combustível infinito
            if self.Config.Vehicle.InfiniteFuel then
                vehicleSeat:SetAttribute("Fuel", math.huge)
                
                -- Manter combustível infinito
                local fuelConnection
                fuelConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if vehicleSeat and vehicleSeat.Parent then
                        vehicleSeat:SetAttribute("Fuel", math.huge)
                    else
                        fuelConnection:Disconnect()
                    end
                end)
            end
            
            -- Efeitos visuais
            if vehicleSeat:FindFirstChild("VehicleVisuals") then
                local flames = Instance.new("ParticleEmitter")
                flames.Texture = "rbxassetid://243099098"
                flames.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
                flames.Rate = 50
                flames.Lifetime = NumberRange.new(0.3, 0.5)
                flames.Speed = NumberRange.new(10, 15)
                flames.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0.5)
                })
                flames.Parent = vehicleSeat
            end
            
            return {
                VehicleSeat = vehicleSeat,
                OriginalSpeed = originalSpeed,
                OriginalTorque = originalTorque
            }
        end
        
        -- Monitorar entrada/saída de veículos
        local function monitorVehicles()
            local currentVehicle = nil
            
            local function checkForVehicle()
                if not character then
                    return
                end
                
                local vehicleSeat = character:FindFirstChildOfClass("VehicleSeat")
                if vehicleSeat and vehicleSeat ~= currentVehicle then
                    -- Novo veículo encontrado
                    currentVehicle = applyVehicleBoost(vehicleSeat)
                elseif not vehicleSeat and currentVehicle then
                    -- Saiu do veículo
                    if currentVehicle.VehicleSeat and currentVehicle.VehicleSeat.Parent then
                        currentVehicle.VehicleSeat.MaxSpeed = currentVehicle.OriginalSpeed
                        currentVehicle.VehicleSeat.Torque = currentVehicle.OriginalTorque
                    end
                    currentVehicle = nil
                end
            end
            
            -- Verificar periodicamente
            local connection = game:GetService("RunService").Heartbeat:Connect(function()
                checkForVehicle()
            end)
            
            return connection
        end
        
        -- Iniciar monitoramento
        local monitorConnection = monitorVehicles()
        
        -- Registrar keybind para boost instantâneo
        InputSystem:RegisterKeybind("B", 23, function(pressed)
            if pressed then
                local vehicleSeat = character:FindFirstChildOfClass("VehicleSeat")
                if vehicleSeat then
                    -- Aplicar impulso instantâneo
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(40000, 0, 40000)
                    bodyVelocity.Velocity = vehicleSeat.CFrame.LookVector * 100
                    bodyVelocity.Parent = vehicleSeat
                    
                    game:GetService("Debris"):AddItem(bodyVelocity, 0.5)
                end
            end
        end)
        
        self.State.ActiveFeatures[23] = {
            MonitorConnection = monitorConnection,
            CurrentVehicle = nil
        }
        
        return true
    end,
    
    Deactivate = function()
        local self = PhysicsAndMovement
        
        local feature = self.State.ActiveFeatures[23]
        if not feature then
            return false
        end
        
        -- Desconectar monitoramento
        if feature.MonitorConnection then
            feature.MonitorConnection:Disconnect()
        end
        
        -- Restaurar veículo atual
        if feature.CurrentVehicle then
            if feature.CurrentVehicle.VehicleSeat and feature.CurrentVehicle.VehicleSeat.Parent then
                feature.CurrentVehicle.VehicleSeat.MaxSpeed = feature.CurrentVehicle.OriginalSpeed
                feature.CurrentVehicle.VehicleSeat.Torque = feature.CurrentVehicle.OriginalTorque
            end
        end
        
        -- Remover keybind
        InputSystem.Keybinds["B"] = nil
        
        self.State.ActiveFeatures[23] = nil
        
        return true
    end
}

-- ============ FUNÇÕES AUXILIARES DO MÓDULO ============
function PhysicsAndMovement:ValidateCharacter()
    self.State.Player = game:GetService("Players").LocalPlayer
    self.State.Character = self.State.Player.Character
    self.State.Humanoid = self.State.Character and self.State.Character:FindFirstChildOfClass("Humanoid")
    
    return self.State.Humanoid ~= nil
end

function PhysicsAndMovement:EnableNoClip()
    return self:EnableFeature(2)
end

function PhysicsAndMovement:DisableNoClip()
    return self:DisableFeature(2)
end

function PhysicsAndMovement:Initialize()
    print("[PhysicsAndMovement] Initializing module...")
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Inicializar sistema de input
    local UserInputService = game:GetService("UserInputService")
    self.State.Connections.Input = UserInputService.InputBegan:Connect(function(input)
        InputSystem:ProcessInput(input)
    end)
    
    self.State.Connections.InputEnded = UserInputService.InputEnded:Connect(function(input)
        InputSystem:ProcessInput(input)
    end)
    
    -- Preencher features restantes (5-16, 18-22, 24-30)
    for i = 5, 30 do
        if not self.Features[i] then
            self.Features[i] = {
                Name = "Feature " .. i,
                Description = "Feature placeholder " .. i,
                Category = "Placeholder",
                Activate = function() 
                    print("Feature " .. i .. " activated")
                    return true 
                end,
                Deactivate = function() 
                    print("Feature " .. i .. " deactivated")
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
    
    print("[PhysicsAndMovement] Module initialized with 30 features")
    
    return true
end

function PhysicsAndMovement:EnableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    local feature = self.Features[featureId]
    
    if self.State.ActiveFeatures[featureId] then
        return false, "Feature already active"
    end
    
    local success, err = feature.Activate()
    
    if success then
        print("[PhysicsAndMovement] Feature enabled: " .. feature.Name)
        
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

function PhysicsAndMovement:DisableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    if not self.State.ActiveFeatures[featureId] then
        return false, "Feature not active"
    end
    
    local feature = self.Features[featureId]
    local success = feature.Deactivate()
    
    if success then
        print("[PhysicsAndMovement] Feature disabled: " .. feature.Name)
        
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

function PhysicsAndMovement:ToggleFeature(featureId)
    if self.State.ActiveFeatures[featureId] then
        return self:DisableFeature(featureId)
    else
        return self:EnableFeature(featureId)
    end
end

function PhysicsAndMovement:GetFeatureStatus(featureId)
    return {
        Active = self.State.ActiveFeatures[featureId] ~= nil,
        Feature = self.Features[featureId],
        State = self.State.ActiveFeatures[featureId]
    }
end

function PhysicsAndMovement:UpdateConfig(newConfig)
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

function PhysicsAndMovement:Shutdown()
    print("[PhysicsAndMovement] Shutting down module...")
    
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
    
    -- Atualizar estado
    if _G.NexusStateManager then
        _G.NexusStateManager:SetStateStatus(self.Name, "INACTIVE")
    end
    
    self.State.Enabled = false
    
    print("[PhysicsAndMovement] Module shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusModules then
    _G.NexusModules = {}
end

_G.NexusModules.PhysicsAndMovement = PhysicsAndMovement

return PhysicsAndMovement
