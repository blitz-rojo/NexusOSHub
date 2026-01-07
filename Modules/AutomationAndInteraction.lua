
-- =============================================
-- NEXUS OS - AUTOMATION AND INTERACTION MODULE
-- Arquivo: AutomationAndInteraction.lua
-- Local: src/Modules/AutomationAndInteraction.lua
-- =============================================

local AutomationAndInteraction = {
    Name = "AutomationAndInteraction",
    Version = "3.0.0",
    Description = "Módulo de automação avançada com 30 features",
    Author = "Nexus Team",
    
    Features = {},
    Config = {},
    State = {
        Enabled = false,
        ActiveFeatures = {},
        Targets = {},
        Farming = {},
        Connections = {}
    },
    
    Dependencies = {"StateManager", "Network"}
}

-- ============ CONFIGURAÇÕES PADRÃO ============
AutomationAndInteraction.DefaultConfig = {
    Aimbot = {
        Enabled = false,
        Keybind = "MouseButton2",
        Smoothing = 0.5,
        FOV = 50,
        Priority = "Closest", -- Closest, Health, Distance
        HitPart = "Head", -- Head, Torso, Random
        Prediction = true,
        PredictionMultiplier = 1.5,
        TeamCheck = true,
        VisibleCheck = true
    },
    TriggerBot = {
        Enabled = false,
        Keybind = "MouseButton1",
        Delay = 0.1,
        Randomization = 0.05,
        HitChance = 100,
        TeamCheck = true
    },
    AutoFarm = {
        Enabled = false,
        FarmSpeed = 1,
        Range = 50,
        CollectItems = true,
        AutoSell = false,
        SellAfter = 100,
        AvoidPlayers = true,
        SafeDistance = 20
    },
    Combat = {
        AutoAttack = false,
        AttackDelay = 0.5,
        CriticalHit = false,
        CriticalChance = 10,
        AutoBlock = false,
        BlockDelay = 0.2,
        AutoDodge = false,
        DodgeChance = 30
    },
    Interaction = {
        AutoClick = false,
        ClickSpeed = 10,
        ClickRange = 10,
        AutoCollect = false,
        CollectRange = 30,
        AutoQuest = false,
        QuestPriority = "Closest"
    }
}
-- ============ OTIMIZAÇÃO E SEGURANÇA (NEXUS CRYPTO) ============
-- Cache local para performance
local NexusCrypto = _G.NexusCrypto
local patternAvoidance = NexusCrypto and NexusCrypto.Config.AntiBan.BehaviorProtection.PatternAvoidance

function AutomationAndInteraction:PerformSafeAction(action)
    -- Validação básica
    if type(action) ~= "function" then
        warn("[Automation] Action must be a function")
        return nil
    end

    -- 1. Randomização de Timing e Input via NexusCrypto
    if NexusCrypto then
        local randomized = NexusCrypto:RandomizeAction(action, 0.05)
        if type(randomized) == "function" then
            action = randomized
        end
    end
    
    -- 2. Evitar Padrões (Behavior Protection)
    if patternAvoidance then
        local patternCheck = NexusCrypto.BehaviorRandomizer and NexusCrypto.BehaviorRandomizer.AvoidPatterns
        if patternCheck then
            local safeAction = patternCheck(action)
            if type(safeAction) == "function" then
                action = safeAction
            end
        end
    end
    
    -- 3. Execução Protegida (Anti-Crash)
    local success, result = pcall(action)
    
    if not success then
        warn("[Automation] Action failed safely: " .. tostring(result))
        return nil
    end

    return result
end

-- ============ SISTEMA DE ALVO ============
local TargetSystem = {
    CurrentTarget = nil,
    TargetHistory = {},
    TargetLock = false,
    TargetDistance = 0,
    TargetLastSeen = 0
}

function TargetSystem:FindTarget(criteria)
    local players = game:GetService("Players"):GetPlayers()
    local localPlayer = game:GetService("Players").LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then
        return nil
    end
    
    local bestTarget = nil
    local bestScore = -math.huge
    
    for _, player in ipairs(players) do
        if player == localPlayer then
            continue
        end
        
        local character = player.Character
        if not character then
            continue
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not root or humanoid.Health <= 0 then
            continue
        end
        
        -- Verificar time
        if AutomationAndInteraction.Config.Aimbot.TeamCheck then
            if player.Team == localPlayer.Team then
                continue
            end
        end
        
        -- Verificar visibilidade
        if AutomationAndInteraction.Config.Aimbot.VisibleCheck then
            local camera = workspace.CurrentCamera
            local origin = camera.CFrame.Position
            local direction = (root.Position - origin).Unit
            local ray = Ray.new(origin, direction * 1000)
            local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {localCharacter, character})
            
            if not hit or not hit:IsDescendantOf(character) then
                continue
            end
        end
        
        -- Calcular distância
        local distance = (root.Position - localRoot.Position).Magnitude
        
        -- Verificar FOV
        if AutomationAndInteraction.Config.Aimbot.FOV > 0 then
            local screenPoint, visible = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            if visible then
                local screenSize = workspace.CurrentCamera.ViewportSize
                local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
                local point = Vector2.new(screenPoint.X, screenPoint.Y)
                local fovDistance = (point - center).Magnitude
                
                if fovDistance > AutomationAndInteraction.Config.Aimbot.FOV then
                    continue
                end
            else
                continue
            end
        end
        
        -- Calcular pontuação baseado no critério
        local score = 0
        
        if criteria == "Closest" then
            score = -distance -- Quanto menor a distância, maior a pontuação
        elseif criteria == "Health" then
            score = -humanoid.Health -- Quanto menos saúde, maior a pontuação
        elseif criteria == "Distance" then
            score = -distance
        end
        
        if score > bestScore then
            bestScore = score
            bestTarget = {
                Player = player,
                Character = character,
                Humanoid = humanoid,
                Root = root,
                Distance = distance,
                Health = humanoid.Health,
                LastUpdate = tick()
            }
        end
    end
    
    self.CurrentTarget = bestTarget
    return bestTarget
end

function TargetSystem:GetTargetHitPart(target)
    if not target or not target.Character then
        return nil
    end
    
    local hitPartName = AutomationAndInteraction.Config.Aimbot.HitPart
    local character = target.Character
    
    if hitPartName == "Head" then
        return character:FindFirstChild("Head")
    elseif hitPartName == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    elseif hitPartName == "Random" then
        local parts = {}
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                table.insert(parts, part)
            end
        end
        return parts[math.random(1, #parts)]
    end
    
    return character:FindFirstChild("Head")
end

function TargetSystem:CalculatePrediction(target, weaponVelocity)
    if not target or not target.Root then
        return target and target.Root.Position
    end
    
    if not AutomationAndInteraction.Config.Aimbot.Prediction then
        return target.Root.Position
    end
    
    local root = target.Root
    local velocity = root.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    local distance = target.Distance
    local timeToHit = distance / weaponVelocity
    local multiplier = AutomationAndInteraction.Config.Aimbot.PredictionMultiplier
    
    -- Predição linear simples
    local predictedPosition = root.Position + (velocity * timeToHit * multiplier)
    
    return predictedPosition
end

function TargetSystem:LockOnTarget()
    if not self.CurrentTarget then
        return false
    end
    
    local target = self.CurrentTarget
    local localPlayer = game:GetService("Players").LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then
        return false
    end
    
    local hitPart = self:GetTargetHitPart(target)
    if not hitPart then
        return false
    end
    
    -- Calcular predição
    local weaponVelocity = 1000 -- Velocidade padrão de projétil
    local predictedPosition = self:CalculatePrediction(target, weaponVelocity)
    
    -- Calcular CFrame para mirar
    local camera = workspace.CurrentCamera
    local smoothing = AutomationAndInteraction.Config.Aimbot.Smoothing
    
    -- Interpolar suavemente para a posição
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)
    
    local newCFrame = currentCFrame:Lerp(targetCFrame, smoothing)
    
    -- Aplicar à câmera (em jogos que permitem)
    -- Nota: Isso pode não funcionar em todos os jogos
    camera.CFrame = newCFrame
    
    return true
end

function TargetSystem:ReleaseTarget()
    self.CurrentTarget = nil
    self.TargetLock = false
end

-- ============ SISTEMA DE FARMING ============
local FarmingSystem = {
    Active = false,
    CurrentTask = nil,
    FarmQueue = {},
    CollectedItems = 0,
    StartTime = 0
}

function FarmingSystem:StartFarming(targetType, options)
    if self.Active then
        return false, "Already farming"
    end
    
    self.Active = true
    self.StartTime = tick()
    self.CollectedItems = 0
    self.FarmQueue = {}
    
    -- Configurar tarefa de farming
    self.CurrentTask = {
        Type = targetType,
        Options = options or {},
        LastAction = tick(),
        State = "SEARCHING"
    }
    
    -- Iniciar loop de farming
    local connection = game:GetService("RunService").Heartbeat:Connect(function()
        self:FarmLoop()
    end)
    
    self.Connection = connection
    
    return true
end

function FarmingSystem:StopFarming()
    if not self.Active then
        return false
    end
    
    self.Active = false
    
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    self.CurrentTask = nil
    self.FarmQueue = {}
    
    return true
end

function FarmingSystem:FarmLoop()
    if not self.Active or not self.CurrentTask then
        return
    end
    
    local task = self.CurrentTask
    local currentTime = tick()
    
    -- Verificar se é hora de agir
    if currentTime - task.LastAction < (1 / AutomationAndInteraction.Config.AutoFarm.FarmSpeed) then
        return
    end
    
    task.LastAction = currentTime
    
    -- Executar ação baseada no estado
    if task.State == "SEARCHING" then
        self:SearchForTargets()
    elseif task.State == "MOVING" then
        self:MoveToTarget()
    elseif task.State == "INTERACTING" then
        self:InteractWithTarget()
    elseif task.State == "COLLECTING" then
        self:CollectItems()
    end
end

function FarmingSystem:SearchForTargets()
    local task = self.CurrentTask
    local range = AutomationAndInteraction.Config.AutoFarm.Range
    
    -- Buscar alvos baseado no tipo
    if task.Type == "Coins" then
        -- Procurar moedas no workspace
        local coins = workspace:FindFirstChild("Coins")
        if coins then
            for _, coin in ipairs(coins:GetChildren()) do
                if coin:IsA("BasePart") then
                    table.insert(self.FarmQueue, {
                        Object = coin,
                        Type = "Coin",
                        Position = coin.Position
                    })
                end
            end
        end
    elseif task.Type == "Items" then
        -- Procurar itens dropados
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name:find("Item") then
                table.insert(self.FarmQueue, {
                    Object = obj,
                    Type = "Item",
                    Position = obj.Position
                })
            end
        end
    end
    
    -- Ordenar por proximidade
    local localPlayer = game:GetService("Players").LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    if localRoot then
        table.sort(self.FarmQueue, function(a, b)
            local distA = (a.Position - localRoot.Position).Magnitude
            local distB = (b.Position - localRoot.Position).Magnitude
            return distA < distB
        end)
    end
    
    if #self.FarmQueue > 0 then
        task.State = "MOVING"
    end
end

function FarmingSystem:MoveToTarget()
    if #self.FarmQueue == 0 then
        self.CurrentTask.State = "SEARCHING"
        return
    end
    
    local target = self.FarmQueue[1]
    local localPlayer = game:GetService("Players").LocalPlayer
    local localCharacter = localPlayer.Character
    local localHumanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
    
    if not localHumanoid then
        return
    end
    
    -- Calcular distância
    local distance = (target.Position - localCharacter:GetPivot().Position).Magnitude
    
    if distance < 5 then
        self.CurrentTask.State = "INTERACTING"
    else
        -- Mover em direção ao alvo
        localHumanoid:MoveTo(target.Position)
    end
end

function FarmingSystem:InteractWithTarget()
    if #self.FarmQueue == 0 then
        self.CurrentTask.State = "SEARCHING"
        return
    end
    
    local target = self.FarmQueue[1]
    
    -- Simular interação (coletar item)
    if target.Object and target.Object.Parent then
        -- Aqui você implementaria a lógica específica do jogo para coletar
        -- Por exemplo, firetouchinterest, remoteevents, etc.
        
        -- Simulação:
        target.Object:Destroy()
        self.CollectedItems = self.CollectedItems + 1
        
        -- Verificar se deve vender
        if AutomationAndInteraction.Config.AutoFarm.AutoSell then
            if self.CollectedItems >= AutomationAndInteraction.Config.AutoFarm.SellAfter then
                self:SellItems()
            end
        end
    end
    
    -- Remover da fila
    table.remove(self.FarmQueue, 1)
    
    if #self.FarmQueue == 0 then
        self.CurrentTask.State = "SEARCHING"
    else
        self.CurrentTask.State = "MOVING"
    end
end

function FarmingSystem:CollectItems()
    -- Implementar coleta de itens no chão
    -- Similar ao sistema de farming, mas para itens específicos
end

function FarmingSystem:SellItems()
    -- Implementar venda automática
    -- Depende do jogo específico
    print("[FarmingSystem] Sold", self.CollectedItems, "items")
    self.CollectedItems = 0
end

-- ============ FEATURE 1: AIMBOT ============
AutomationAndInteraction.Features[1] = {
    Name = "Aimbot",
    Description = "Mira automática em jogadores",
    Category = "Combat",
    DefaultKeybind = "MouseButton2",
    
    Activate = function()
        local config = AutomationAndInteraction.Config.Aimbot
        
        -- Registrar keybind
        local UserInputService = game:GetService("UserInputService")
        local aimbotActive = false
        
        local inputConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                aimbotActive = true
            end
        end)
        
        local inputEndConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                aimbotActive = false
                TargetSystem:ReleaseTarget()
            end
        end)
        
        -- Loop de aimbot
        local renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if not aimbotActive then
                return
            end
            
            -- Encontrar alvo
            if not TargetSystem.CurrentTarget then
                TargetSystem:FindTarget(config.Priority)
            end
            
            -- Travar no alvo
            if TargetSystem.CurrentTarget then
                TargetSystem:LockOnTarget()
            end
        end)
        
        AutomationAndInteraction.State.ActiveFeatures[1] = {
            InputConnection = inputConnection,
            InputEndConnection = inputEndConnection,
            RenderConnection = renderConnection,
            Active = true
        }
        
        return true
    end,
    
    Deactivate = function()
        local feature = AutomationAndInteraction.State.ActiveFeatures[1]
        if not feature then
            return false
        end
        
        -- Desconectar
        if feature.InputConnection then
            feature.InputConnection:Disconnect()
        end
        
        if feature.InputEndConnection then
            feature.InputEndConnection:Disconnect()
        end
        
        if feature.RenderConnection then
            feature.RenderConnection:Disconnect()
        end
        
        -- Liberar alvo
        TargetSystem:ReleaseTarget()
        
        AutomationAndInteraction.State.ActiveFeatures[1] = nil
        
        return true
    end
}

-- ============ FEATURE 2: TRIGGER BOT ============
AutomationAndInteraction.Features[2] = {
    Name = "Trigger Bot",
    Description = "Atira automaticamente quando a mira está no alvo",
    Category = "Combat",
    DefaultKeybind = "MouseButton1",
    
    Activate = function()
        local config = AutomationAndInteraction.Config.TriggerBot
        
        -- Registrar keybind
        local UserInputService = game:GetService("UserInputService")
        local triggerActive = false
        
        local inputConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                triggerActive = true
            end
        end)
        
        local inputEndConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                triggerActive = false
            end
        end)
        
        -- Loop de trigger bot
        local heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not triggerActive then
                return
            end
            
            -- Verificar se há alvo
            local target = TargetSystem.CurrentTarget or TargetSystem:FindTarget("Closest")
            if not target then
                return
            end
            
            -- Verificar chance de acerto
            if math.random(1, 100) > config.HitChance then
                return
            end
            
            -- Calcular delay randomizado
            local delay = config.Delay + (math.random() * config.Randomization * 2 - config.Randomization)
            
            -- Disparar (simulado)
            wait(delay)
            -- Aqui viria a lógica real de disparo do jogo
            print("[TriggerBot] Fired at target:", target.Player.Name)
        end)
        
        AutomationAndInteraction.State.ActiveFeatures[2] = {
            InputConnection = inputConnection,
            InputEndConnection = inputEndConnection,
            HeartbeatConnection = heartbeatConnection,
            Active = true
        }
        
        return true
    end,
    
    Deactivate = function()
        local feature = AutomationAndInteraction.State.ActiveFeatures[2]
        if not feature then
            return false
        end
        
        -- Desconectar
        if feature.InputConnection then
            feature.InputConnection:Disconnect()
        end
        
        if feature.InputEndConnection then
            feature.InputEndConnection:Disconnect()
        end
        
        if feature.HeartbeatConnection then
            feature.HeartbeatConnection:Disconnect()
        end
        
        AutomationAndInteraction.State.ActiveFeatures[2] = nil
        
        return true
    end
}

-- ============ FEATURE 6: AUTO FARM COINS ============
AutomationAndInteraction.Features[6] = {
    Name = "Auto Farm Coins",
    Description = "Coleta moedas automaticamente",
    Category = "Farming",
    DefaultKeybind = "F6",
    
    Activate = function()
        local success, err = FarmingSystem:StartFarming("Coins", {
            Range = AutomationAndInteraction.Config.AutoFarm.Range,
            CollectItems = AutomationAndInteraction.Config.AutoFarm.CollectItems
        })
        
        if success then
            AutomationAndInteraction.State.ActiveFeatures[6] = {
                FarmingSystem = FarmingSystem,
                Active = true
            }
            return true
        else
            return false, err
        end
    end,
    
    Deactivate = function()
        local feature = AutomationAndInteraction.State.ActiveFeatures[6]
        if not feature then
            return false
        end
        
        local success = FarmingSystem:StopFarming()
        
        if success then
            AutomationAndInteraction.State.ActiveFeatures[6] = nil
            return true
        else
            return false
        end
    end
}

-- ============ FEATURE 10: AUTO CLICKER ============
AutomationAndInteraction.Features[10] = {
    Name = "Auto Clicker",
    Description = "Clica automaticamente em objetos",
    Category = "Interaction",
    DefaultKeybind = "F7",
    
    Activate = function()
        local config = AutomationAndInteraction.Config.Interaction
        
        -- Sistema de auto click
        local autoClicker = {
            Active = true,
            LastClick = tick(),
            ClickCount = 0
        }
        
        -- Função para simular clique
        local function simulateClick(position)
            -- Esta função simula um clique do mouse
            -- Em implementação real, você usaria fireclickdetector ou remoteevents
            
            -- Exemplo com FireClickDetector
            local ray = Ray.new(workspace.CurrentCamera.CFrame.Position, 
                (position - workspace.CurrentCamera.CFrame.Position).Unit * 100)
            local hit, hitPosition = workspace:FindPartOnRay(ray)
            
            if hit then
                local clickDetector = hit:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    return true
                end
            end
            
            return false
        end
        
        -- Loop de auto click
        local connection = game:GetService("RunService").Heartbeat:Connect(function()
            if not autoClicker.Active then
                return
            end
            
            local currentTime = tick()
            local clickInterval = 1 / config.ClickSpeed
            
            if currentTime - autoClicker.LastClick >= clickInterval then
                -- Encontrar alvo para clicar
                local localPlayer = game:GetService("Players").LocalPlayer
                local localCharacter = localPlayer.Character
                local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
                
                if not localRoot then
                    return
                end
                
                -- Procurar objetos clicáveis no range
                local bestTarget = nil
                local bestDistance = math.huge
                
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:FindFirstChildOfClass("ClickDetector") then
                        local distance = (obj.Position - localRoot.Position).Magnitude
                        if distance <= config.ClickRange and distance < bestDistance then
                            bestTarget = obj
                            bestDistance = distance
                        end
                    end
                end
                
                -- Clicar no alvo
                if bestTarget then
                    local success = simulateClick(bestTarget.Position)
                    if success then
                        autoClicker.ClickCount = autoClicker.ClickCount + 1
                        autoClicker.LastClick = currentTime
                    end
                end
            end
        end)
        
        autoClicker.Connection = connection
        
        AutomationAndInteraction.State.ActiveFeatures[10] = autoClicker
        
        return true
    end,
    
    Deactivate = function()
        local feature = AutomationAndInteraction.State.ActiveFeatures[10]
        if not feature then
            return false
        end
        
        feature.Active = false
        
        if feature.Connection then
            feature.Connection:Disconnect()
        end
        
        AutomationAndInteraction.State.ActiveFeatures[10] = nil
        
        return true
    end
}

-- ============ FEATURE 15: AUTO QUEST ============
AutomationAndInteraction.Features[15] = {
    Name = "Auto Quest",
    Description = "Completa missões automaticamente",
    Category = "Interaction",
    DefaultKeybind = "F8",
    
    Activate = function()
        local config = AutomationAndInteraction.Config.Interaction
        
        -- Sistema de auto quest
        local autoQuest = {
            Active = true,
            CurrentQuest = nil,
            QuestProgress = {},
            State = "FINDING_QUEST"
        }
        
        -- Funções para gerenciar quests
        local function findAvailableQuests()
            -- Esta função busca por missões disponíveis
            -- Implementação específica do jogo
            
            local quests = {}
            
            -- Exemplo: procurar por NPCs com quests
            for _, npc in ipairs(workspace:GetChildren()) do
                if npc:FindFirstChild("QuestGiver") or npc.Name:find("NPC") then
                    table.insert(quests, {
                        NPC = npc,
                        Name = npc.Name,
                        Position = npc:GetPivot().Position
                    })
                end
            end
            
            return quests
        end
        
        local function acceptQuest(quest)
            -- Aceitar a missão
            -- Implementação específica do jogo
            
            print("[AutoQuest] Accepting quest:", quest.Name)
            autoQuest.CurrentQuest = quest
            autoQuest.State = "DOING_QUEST"
            
            return true
        end
        
        local function completeQuest(quest)
            -- Completar a missão
            -- Implementação específica do jogo
            
            print("[AutoQuest] Completing quest:", quest.Name)
            autoQuest.CurrentQuest = nil
            autoQuest.State = "FINDING_QUEST"
            
            return true
        end
        
        -- Loop de auto quest
        local connection = game:GetService("RunService").Heartbeat:Connect(function()
            if not autoQuest.Active then
                return
            end
            
            if autoQuest.State == "FINDING_QUEST" then
                local quests = findAvailableQuests()
                if #quests > 0 then
                    -- Aceitar a primeira quest disponível
                    acceptQuest(quests[1])
                end
            elseif autoQuest.State == "DOING_QUEST" then
                -- Implementar lógica para completar a quest
                -- Isso é altamente específico do jogo
                
                -- Simulação: completar após 5 segundos
                wait(5)
                if autoQuest.CurrentQuest then
                    completeQuest(autoQuest.CurrentQuest)
                end
            end
        end)
        
        autoQuest.Connection = connection
        
        AutomationAndInteraction.State.ActiveFeatures[15] = autoQuest
        
        return true
    end,
    
    Deactivate = function()
        local feature = AutomationAndInteraction.State.ActiveFeatures[15]
        if not feature then
            return false
        end
        
        feature.Active = false
        
        if feature.Connection then
            feature.Connection:Disconnect()
        end
        
        AutomationAndInteraction.State.ActiveFeatures[15] = nil
        
        return true
    end
}

-- ============ FUNÇÕES AUXILIARES DO MÓDULO ============
function AutomationAndInteraction:Initialize()
    print("[AutomationAndInteraction] Initializing module...")
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Inicializar sistemas
    TargetSystem:ReleaseTarget()
    FarmingSystem:StopFarming()
    
    -- Preencher features restantes (3-5, 7-9, 11-14, 16-30)
    for i = 3, 30 do
        if not self.Features[i] then
            self.Features[i] = {
                Name = "Automation Feature " .. i,
                Description = "Automation feature placeholder " .. i,
                Category = "Placeholder",
                Activate = function() 
                    print("Automation Feature " .. i .. " activated")
                    return true 
                end,
                Deactivate = function() 
                    print("Automation Feature " .. i .. " deactivated")
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
    
    print("[AutomationAndInteraction] Module initialized with 30 features")
    
    return true
end

function AutomationAndInteraction:EnableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    local feature = self.Features[featureId]
    
    if self.State.ActiveFeatures[featureId] then
        return false, "Feature already active"
    end
    
    local success, err = feature.Activate()
    
    if success then
        print("[AutomationAndInteraction] Feature enabled: " .. feature.Name)
        
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

function AutomationAndInteraction:DisableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    if not self.State.ActiveFeatures[featureId] then
        return false, "Feature not active"
    end
    
    local feature = self.Features[featureId]
    local success = feature.Deactivate()
    
    if success then
        print("[AutomationAndInteraction] Feature disabled: " .. feature.Name)
        
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

function AutomationAndInteraction:ToggleFeature(featureId)
    if self.State.ActiveFeatures[featureId] then
        return self:DisableFeature(featureId)
    else
        return self:EnableFeature(featureId)
    end
end

function AutomationAndInteraction:GetFeatureStatus(featureId)
    return {
        Active = self.State.ActiveFeatures[featureId] ~= nil,
        Feature = self.Features[featureId],
        State = self.State.ActiveFeatures[featureId]
    }
end

function AutomationAndInteraction:UpdateConfig(newConfig)
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

function AutomationAndInteraction:Shutdown()
    print("[AutomationAndInteraction] Shutting down module...")
    
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
    
    -- Parar sistemas
    TargetSystem:ReleaseTarget()
    FarmingSystem:StopFarming()
    
    -- Atualizar estado
    if _G.NexusStateManager then
        _G.NexusStateManager:SetStateStatus(self.Name, "INACTIVE")
    end
    
    self.State.Enabled = false
    
    print("[AutomationAndInteraction] Module shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusModules then
    _G.NexusModules = {}
end

_G.NexusModules.AutomationAndInteraction = AutomationAndInteraction

return AutomationAndInteraction
