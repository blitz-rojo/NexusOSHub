-- =============================================
-- NEXUS OS - CUSTOM PRESET WITH ADVANCED ANTI-BAN
-- Arquivo: Custom.lua
-- Local: src/Presets/Custom.lua
-- =============================================

local Custom = {
    Name = "Custom",
    Version = "4.0.0",
    Description = "Preset personalizado com sistemas anti-ban avançados e proteção real-time",
    Author = "Nexus Security Team",
    
    Config = {},
    State = {
        Initialized = false,
        ProtectionActive = false,
        BehavioralPatterns = {},
        DetectionHistory = {},
        SafetyMeasures = {},
        EnvironmentHash = nil,
        RuntimeIntegrity = true
    },
    
    Dependencies = {"Crypto", "Memory", "Performance", "Network"}
}

-- ============ CONFIGURAÇÕES AVANÇADAS DE PROTEÇÃO ============
Custom.DefaultConfig = {
    Security = {
        ProtectionLevel = 4, -- 1-5 (5=max)
        AutoAdjustProtection = true,
        RiskAssessment = true,
        RealTimeMonitoring = true,
        
        BehavioralProtection = {
            HumanizeActions = true,
            ActionRandomization = 0.4,
            PatternAvoidance = true,
            MaxPatternLength = 3,
            DelayVariance = 0.3,
            InputRandomization = true,
            MouseJitter = 0.5,
            ClickVariance = 0.2
        },
        
        EnvironmentMasking = {
            MaskProcess = true,
            FakeProcessName = "robloxplayerbeta.exe",
            SpoofHardwareInfo = false,
            FakeHWID = true,
            EnvironmentHashCheck = true,
            HashCheckInterval = 30
        },
        
        MemoryProtection = {
            AntiDump = true,
            MemoryEncryption = true,
            HeapRandomization = true,
            GuardPages = true,
            MemoryTrapDensity = 0.15,
            EncryptionKeyRotation = true,
            RotationInterval = 180
        },
        
        NetworkProtection = {
            EncryptTraffic = true,
            FakePackets = true,
            PacketRandomization = true,
            RequestThrottling = true,
            MaxRequestsPerMinute = 40,
            MimicBrowserBehavior = true,
            UserAgentRotation = true
        },
        
        RuntimeProtection = {
            IntegrityChecks = true,
            ChecksumVerification = true,
            CodeObfuscation = true,
            AntiDebug = true,
            AntiTamper = true,
            HookDetection = true,
            APIHookProtection = true
        }
    },
    
    Performance = {
        OptimizationLevel = 3,
        SmartResourceManagement = true,
        
        FPS = {
            TargetFPS = 60,
            MinFPS = 30,
            MaxFPS = 144,
            SmoothFPS = true,
            FPSMasking = true,
            FPSVariance = 8
        },
        
        Memory = {
            TargetUsage = 250,
            MaxUsage = 400,
            AutoCleanup = true,
            CleanupThreshold = 300,
            MemoryPooling = true,
            StringInterning = true
        },
        
        CPU = {
            UsageLimit = 30,
            ThreadManagement = true,
            PriorityAdjustment = true,
            BackgroundThrottling = true
        }
    },
    
    Modules = {
        SmartActivation = true,
        RiskBasedActivation = true,
        
        PhysicsAndMovement = {
            SafetyDelay = 0.3,
            VelocityMasking = true,
            MaxSpeed = 100,
            SmoothAcceleration = true,
            AntiWarpDetection = true
        },
        
        VisualDebugger = {
            ESPFadeDistance = true,
            MaxESPPlayers = 10,
            ESPUpdateRate = 0.2,
            ChamsTransparency = 0.7,
            NoExtremeBrightness = true
        },
        
        AutomationAndInteraction = {
            HumanizedAimbot = true,
            MaxAimbotFOV = 30,
            SmoothAiming = 0.6,
            RandomMissChance = 15,
            TriggerBotDelay = 0.15,
            AutoFarmSafety = true,
            FarmRateLimit = 2.0
        },
        
        PlayerAndUtility = {
            GodModeCooldown = 5.0,
            TeleportSafety = true,
            MaxTeleportDistance = 500,
            AntiAFKRandomization = true,
            FPSUnlockSafe = true
        }
    },
    
    GameSpecific = {
        AutoDetection = true,
        GameBlacklist = {},
        GameWhitelist = {},
        SafetyProfiles = {
            ["2788229376"] = { -- Da Hood
                MaxSpeed = 80,
                ESPLimit = 8,
                NoExtremeFeatures = true
            },
            ["142823291"] = { -- Murder Mystery 2
                NoAimbot = true,
                ESPOnly = true,
                MinimalFeatures = true
            }
        }
    },
    
    Advanced = {
        LearningMode = false,
        AdaptiveProtection = true,
        ThreatLevel = 0,
        EmergencyProtocols = {
            AutoDisableOnHighRisk = true,
            RiskThreshold = 75,
            GracefulShutdown = true,
            DataWipeOnCritical = false
        },
        
        Logging = {
            SecurityEvents = true,
            PerformanceMetrics = true,
            UserActions = false,
            LogEncryption = true,
            MaxLogSize = 5000
        }
    }
}

-- ============ SISTEMA DE HASH DE AMBIENTE ============
local EnvironmentHasher = {
    CurrentHash = nil,
    HashComponents = {},
    LastHashCheck = 0,
    HashHistory = {}
}

function EnvironmentHasher:GenerateEnvironmentHash()
    local components = {}
    
    -- Coletar componentes do ambiente
    pcall(function()
        -- Informações do jogo
        components.GameId = game.GameId
        components.PlaceId = game.PlaceId
        components.JobId = game.JobId
        
        -- Informações do jogador
        local player = game:GetService("Players").LocalPlayer
        components.UserId = player.UserId
        components.AccountAge = player.AccountAge
        
        -- Informações da sessão
        components.SessionStart = os.time()
        components.SessionRandom = math.random(1000000, 9999999)
        
        -- Informações do sistema (simuladas)
        components.SystemTime = os.time()
        components.TickCount = tick()
        
        -- Componentes de segurança
        if _G.NexusCrypto then
            components.SecurityLevel = _G.NexusCrypto.State.SecurityLevel
            components.HWID = _G.NexusCrypto.State.HWID
        end
        
        -- Componentes de performance
        if _G.NexusPerformance then
            components.FPS = _G.NexusPerformance.State.PerformanceData.FPS or 0
            components.Memory = _G.NexusPerformance.State.PerformanceData.Memory or 0
        end
    end)
    
    self.HashComponents = components
    
    -- Gerar hash
    local hashString = ""
    for key, value in pairs(components) do
        hashString = hashString .. tostring(key) .. ":" .. tostring(value) .. "|"
    end
    
    self.CurrentHash = Custom:HashString(hashString)
    self.LastHashCheck = os.time()
    
    -- Registrar no histórico
    table.insert(self.HashHistory, {
        timestamp = os.time(),
        hash = self.CurrentHash,
        components = components
    })
    
    if #self.HashHistory > 50 then
        table.remove(self.HashHistory, 1)
    end
    
    return self.CurrentHash
end

function EnvironmentHasher:CheckEnvironmentChanges()
    local oldHash = self.CurrentHash
    local newHash = self:GenerateEnvironmentHash()
    
    if oldHash and newHash ~= oldHash then
        local changes = {}
        
        -- Detectar mudanças específicas
        if #self.HashHistory >= 2 then
            local oldComponents = self.HashHistory[#self.HashHistory - 1].components
            local newComponents = self.HashHistory[#self.HashHistory].components
            
            for key, oldValue in pairs(oldComponents) do
                local newValue = newComponents[key]
                if tostring(oldValue) ~= tostring(newValue) then
                    table.insert(changes, {
                        component = key,
                        old = oldValue,
                        new = newValue
                    })
                end
            end
        end
        
        Custom:LogSecurityEvent("ENVIRONMENT_CHANGE",
            "Environment hash changed. Changes: " .. #changes)
        
        -- Analisar risco das mudanças
        local riskLevel = self:AnalyzeEnvironmentRisk(changes)
        
        return true, changes, riskLevel
    end
    
    return false, {}, 0
end

function EnvironmentHasher:AnalyzeEnvironmentRisk(changes)
    local riskScore = 0
    
    for _, change in ipairs(changes) do
        -- Mudanças de alto risco
        if change.component == "JobId" then
            riskScore = riskScore + 30 -- Mudança de servidor
        elseif change.component == "HWID" then
            riskScore = riskScore + 100 -- HWID alterado (extremamente suspeito)
        elseif change.component == "SecurityLevel" then
            riskScore = riskScore + 20 -- Nível de segurança alterado
        elseif change.component == "GameId" then
            riskScore = riskScore + 50 -- Jogo diferente
        end
    end
    
    -- Muitas mudanças de uma vez
    if #changes > 5 then
        riskScore = riskScore + (#changes * 5)
    end
    
    return riskScore
end

-- ============ SISTEMA DE PADRÕES COMPORTAMENTAIS ============
local BehavioralSystem = {
    ActionHistory = {},
    PatternDatabase = {},
    CurrentPattern = {},
    LastActionTime = 0,
    PatternDetectionActive = true
}

function BehavioralSystem:RecordAction(actionType, metadata)
    local action = {
        type = actionType,
        metadata = metadata or {},
        timestamp = os.time(),
        preciseTime = tick(),
        riskLevel = 0
    }
    
    -- Calcular risco da ação
    action.riskLevel = self:CalculateActionRisk(action)
    
    table.insert(self.ActionHistory, action)
    
    -- Manter histórico limitado
    if #self.ActionHistory > 1000 then
        table.remove(self.ActionHistory, 1)
    end
    
    -- Atualizar padrão atual
    self:UpdateCurrentPattern(action)
    
    -- Detectar padrões suspeitos
    if self.PatternDetectionActive then
        self:DetectSuspiciousPatterns()
    end
    
    return action
end

function BehavioralSystem:CalculateActionRisk(action)
    local risk = 0
    
    -- Ações de alto risco
    local highRiskActions = {
        "TELEPORT",
        "FLIGHT_ACTIVATE",
        "AIMBOT_ACTIVATE",
        "AUTOFARM_START",
        "GODMODE_ACTIVATE"
    }
    
    for _, riskyAction in ipairs(highRiskActions) do
        if action.type:find(riskyAction) then
            risk = risk + 25
        end
    end
    
    -- Ações muito frequentes
    local recentActions = 0
    local oneSecondAgo = action.preciseTime - 1
    
    for _, pastAction in ipairs(self.ActionHistory) do
        if pastAction.preciseTime > oneSecondAgo and pastAction.type == action.type then
            recentActions = recentActions + 1
        end
    end
    
    if recentActions > 5 then
        risk = risk + (recentActions * 5)
    end
    
    -- Padrões repetitivos
    if self:IsRepeatingPattern(action.type) then
        risk = risk + 30
    end
    
    return math.min(risk, 100)
end

function BehavioralSystem:UpdateCurrentPattern(action)
    table.insert(self.CurrentPattern, action.type)
    
    local maxPatternLength = Custom.Config.Security.BehavioralProtection.MaxPatternLength
    if #self.CurrentPattern > maxPatternLength then
        table.remove(self.CurrentPattern, 1)
    end
end

function BehavioralSystem:IsRepeatingPattern(actionType)
    if #self.CurrentPattern < 3 then
        return false
    end
    
    -- Verificar se a ação atual completa um padrão repetitivo
    local patternString = table.concat(self.CurrentPattern, "->")
    
    -- Verificar no banco de dados de padrões
    if self.PatternDatabase[patternString] then
        self.PatternDatabase[patternString] = self.PatternDatabase[patternString] + 1
    else
        self.PatternDatabase[patternString] = 1
    end
    
    -- Se o padrão se repetiu muitas vezes
    if self.PatternDatabase[patternString] > 3 then
        return true
    end
    
    return false
end

function BehavioralSystem:DetectSuspiciousPatterns()
    local suspiciousPatterns = {
        "TELEPORT->TELEPORT->TELEPORT",
        "FLIGHT_ACTIVATE->FLIGHT_DEACTIVATE->FLIGHT_ACTIVATE",
        "AIMBOT_ACTIVATE->KILL->KILL->KILL",
        "AUTOFARM_START->COLLECT->COLLECT->COLLECT"
    }
    
    local currentPattern = table.concat(self.CurrentPattern, "->")
    
    for _, pattern in ipairs(suspiciousPatterns) do
        if string.find(currentPattern, pattern) then
            Custom:LogSecurityEvent("SUSPICIOUS_PATTERN",
                "Detected suspicious pattern: " .. pattern)
            
            -- Quebrar o padrão
            self:BreakPattern()
            
            return true
        end
    end
    
    return false
end

function BehavioralSystem:BreakPattern()
    -- Inserir ações neutras para quebrar o padrão
    local neutralActions = {
        "CAMERA_MOVE",
        "IDLE",
        "MENU_OPEN",
        "SETTINGS_CHANGE"
    }
    
    for i = 1, math.random(2, 4) do
        local action = neutralActions[math.random(1, #neutralActions)]
        self:RecordAction(action, {reason = "pattern_break"})
    end
    
    -- Limpar padrão atual
    self.CurrentPattern = {}
    
    Custom:LogSecurityEvent("PATTERN_BROKEN",
        "Behavioral pattern broken intentionally")
end

function BehavioralSystem:HumanizeDelay(baseDelay)
    if not Custom.Config.Security.BehavioralProtection.HumanizeActions then
        return baseDelay
    end
    
    local variance = Custom.Config.Security.BehavioralProtection.DelayVariance
    local randomized = baseDelay * (1 + (math.random() * variance * 2 - variance))
    
    -- Adicionar micro-variações
    randomized = randomized + (math.random() * 0.05)
    
    return randomized
end

function BehavioralSystem:GetActionStatistics()
    local stats = {
        totalActions = #self.ActionHistory,
        highRiskActions = 0,
        recentPatterns = #self.CurrentPattern,
        patternDatabaseSize = 0
    }
    
    for _, action in ipairs(self.ActionHistory) do
        if action.riskLevel > 50 then
            stats.highRiskActions = stats.highRiskActions + 1
        end
    end
    
    for _ in pairs(self.PatternDatabase) do
        stats.patternDatabaseSize = stats.patternDatabaseSize + 1
    end
    
    return stats
end

-- ============ SISTEMA DE MASCARAMENTO DE MEMÓRIA ============
local MemoryMaskingSystem = {
    MaskedRegions = {},
    FakeMemoryBlocks = {},
    EncryptionLayers = {},
    TrapRegions = {}
}

function MemoryMaskingSystem:Initialize()
    if not Custom.Config.Security.MemoryProtection.AntiDump then
        return
    end
    
    print("[MemoryMasking] Initializing advanced memory protection...")
    
    -- Criar regiões de memória falsas
    self:CreateFakeMemoryRegions()
    
    -- Configurar armadilhas de memória
    if Custom.Config.Security.MemoryProtection.MemoryTrapDensity > 0 then
        self:SetupMemoryTraps()
    end
    
    -- Configurar criptografia
    if Custom.Config.Security.MemoryProtection.MemoryEncryption then
        self:SetupMemoryEncryption()
    end
end

function MemoryMaskingSystem:CreateFakeMemoryRegions()
    local regionCount = math.floor(Custom.Config.Security.MemoryProtection.MemoryTrapDensity * 100)
    
    for i = 1, regionCount do
        local regionId = "FAKE_MEM_" .. tostring(math.random(100000, 999999))
        
        local fakeRegion = {
            id = regionId,
            type = self:GetRandomMemoryType(),
            data = self:GenerateFakeMemoryData(),
            size = math.random(1024, 10240),
            signature = Custom:GenerateRandomString(32),
            traps = {},
            encrypted = true,
            lastAccess = 0
        }
        
        -- Adicionar armadilhas à região
        for j = 1, math.random(1, 3) do
            table.insert(fakeRegion.traps, {
                type = "READ_TRAP",
                address = math.random(1, fakeRegion.size),
                response = "CORRUPT_DATA"
            })
        end
        
        self.FakeMemoryBlocks[regionId] = fakeRegion
        
        -- Registrar como região protegida
        if _G.NexusMemory then
            _G.NexusMemory:ProtectData(regionId, fakeRegion, "HIGH")
        end
    end
    
    print("[MemoryMasking] Created", regionCount, "fake memory regions")
end

function MemoryMaskingSystem:GetRandomMemoryType()
    local types = {
        "CONFIGURATION",
        "ENCRYPTION_KEY",
        "USER_DATA",
        "MODULE_CODE",
        "SECURITY_TOKEN",
        "SESSION_INFO",
        "PERFORMANCE_DATA",
        "GAME_STATE"
    }
    
    return types[math.random(1, #types)]
end

function MemoryMaskingSystem:GenerateFakeMemoryData()
    local data = {}
    
    for i = 1, math.random(5, 20) do
        local key = "key_" .. tostring(math.random(1000, 9999))
        
        if math.random(1, 3) == 1 then
            -- Dados aninhados
            data[key] = {
                nested = true,
                values = {}
            }
            for j = 1, math.random(2, 5) do
                data[key].values["nested_" .. j] = Custom:GenerateRandomString(10)
            end
        else
            -- Dados simples
            local dataType = math.random(1, 4)
            if dataType == 1 then
                data[key] = Custom:GenerateRandomString(math.random(10, 100))
            elseif dataType == 2 then
                data[key] = math.random(100000, 999999)
            elseif dataType == 3 then
                data[key] = math.random() > 0.5
            else
                data[key] = nil
            end
        end
    end
    
    return data
end

function MemoryMaskingSystem:SetupMemoryTraps()
    local trapCount = math.floor(Custom.Config.Security.MemoryProtection.MemoryTrapDensity * 50)
    
    for i = 1, trapCount do
        local trapId = "TRAP_" .. tostring(math.random(100000, 999999))
        
        local trap = {
            id = trapId,
            type = self:GetRandomTrapType(),
            triggerCondition = function(operation, address)
                -- Condição de trigger aleatória
                return math.random(1, 1000) == 1 -- 0.1% chance
            end,
            response = function()
                Custom:LogSecurityEvent("MEMORY_TRAP_TRIGGERED",
                    "Memory trap activated: " .. trapId)
                
                -- Resposta ao trigger
                local responseType = math.random(1, 3)
                if responseType == 1 then
                    self:ScrambleNearbyMemory()
                elseif responseType == 2 then
                    self:InjectFakeData()
                else
                    self:CorruptMemoryRegion()
                end
            end,
            location = math.random(1000000, 9000000)
        }
        
        self.TrapRegions[trapId] = trap
    end
    
    print("[MemoryMasking] Setup", trapCount, "memory traps")
end

function MemoryMaskingSystem:GetRandomTrapType()
    local types = {"READ_TRAP", "WRITE_TRAP", "EXECUTE_TRAP", "ACCESS_TRAP"}
    return types[math.random(1, #types)]
end

function MemoryMaskingSystem:ScrambleNearbyMemory()
    -- Embaralhar regiões de memória próximas
    for regionId, region in pairs(self.FakeMemoryBlocks) do
        if math.random(1, 3) == 1 then
            region.data = self:GenerateFakeMemoryData()
            region.lastAccess = os.time()
        end
    end
end

function MemoryMaskingSystem:InjectFakeData()
    -- Injetar dados falsos em regiões reais (simulado)
    print("[MemoryMasking] Injecting fake data into memory...")
end

function MemoryMaskingSystem:CorruptMemoryRegion()
    -- Corromper uma região de memória (simulado)
    print("[MemoryMasking] Corrupting memory region...")
end

function MemoryMaskingSystem:SetupMemoryEncryption()
    if not _G.NexusCrypto then
        return
    end
    
    self.EncryptionLayers = {
        {
            name = "LAYER_1",
            algorithm = "XOR_BASE64",
            key = Custom:GenerateRandomString(32),
            rotationInterval = Custom.Config.Security.MemoryProtection.RotationInterval
        },
        {
            name = "LAYER_2",
            algorithm = "CUSTOM",
            key = Custom:GenerateRandomString(32),
            rotationInterval = Custom.Config.Security.MemoryProtection.RotationInterval * 2
        }
    }
    
    print("[MemoryMasking] Memory encryption setup with", #self.EncryptionLayers, "layers")
end

-- ============ SISTEMA DE PROTEÇÃO DE RUNTIME ============
local RuntimeProtection = {
    IntegrityChecks = {},
    HookDetectors = {},
    TamperMonitors = {},
    LastIntegrityCheck = 0
}

function RuntimeProtection:Initialize()
    if not Custom.Config.Security.RuntimeProtection.IntegrityChecks then
        return
    end
    
    print("[RuntimeProtection] Initializing runtime protection...")
    
    -- Configurar verificações de integridade
    self:SetupIntegrityChecks()
    
    -- Configurar detecção de hooks
    if Custom.Config.Security.RuntimeProtection.HookDetection then
        self:SetupHookDetection()
    end
    
    -- Configurar monitoramento de adulteração
    if Custom.Config.Security.RuntimeProtection.AntiTamper then
        self:SetupTamperMonitoring()
    end
    
    -- Configurar proteção anti-debug
    if Custom.Config.Security.RuntimeProtection.AntiDebug then
        self:SetupAntiDebug()
    end
end

function RuntimeProtection:SetupIntegrityChecks()
    -- Verificação de checksum do código
    self.IntegrityChecks.CodeChecksum = {
        enabled = true,
        interval = 30,
        lastCheck = 0,
        expectedHash = nil,
        
        check = function()
            -- Em produção, calcularia hash do código atual
            -- Esta é uma implementação simulada
            local currentTime = os.time()
            
            if currentTime - self.lastCheck >= self.interval then
                self.lastCheck = currentTime
                
                -- Simular cálculo de hash
                local fakeHash = Custom:GenerateRandomString(64)
                
                if not self.expectedHash then
                    self.expectedHash = fakeHash
                elseif self.expectedHash ~= fakeHash then
                    Custom:LogSecurityEvent("CODE_INTEGRITY_FAIL",
                        "Code checksum mismatch detected")
                    return false
                end
                
                return true
            end
        end
    }
    
    -- Verificação de memória
    self.IntegrityChecks.MemoryIntegrity = {
        enabled = true,
        interval = 60,
        lastCheck = 0,
        
        check = function()
            local currentTime = os.time()
            
            if currentTime - self.lastCheck >= self.interval then
                self.lastCheck = currentTime
                
                -- Verificar regiões críticas
                if _G.NexusMemory then
                    local report = _G.NexusMemory:GetProtectionReport()
                    
                    if report.DumpAttempts > 0 then
                        Custom:LogSecurityEvent("MEMORY_INTEGRITY_FAIL",
                            "Memory dump attempts: " .. report.DumpAttempts)
                        return false
                    end
                end
                
                return true
            end
        end
    }
    
    -- Verificação de ambiente
    self.IntegrityChecks.EnvironmentIntegrity = {
        enabled = Custom.Config.Security.EnvironmentMasking.EnvironmentHashCheck,
        interval = Custom.Config.Security.EnvironmentMasking.HashCheckInterval,
        lastCheck = 0,
        
        check = function()
            local currentTime = os.time()
            
            if currentTime - self.lastCheck >= self.interval then
                self.lastCheck = currentTime
                
                local changed, changes, risk = EnvironmentHasher:CheckEnvironmentChanges()
                
                if changed and risk > 50 then
                    Custom:LogSecurityEvent("ENVIRONMENT_INTEGRITY_FAIL",
                        "High risk environment changes detected. Risk: " .. risk)
                    return false
                end
                
                return true
            end
        end
    }
end

function RuntimeProtection:SetupHookDetection()
    -- Detectar hooks em funções críticas (simulado)
    self.HookDetectors = {
        {
            target = "require",
            original = require,
            check = function()
                -- Verificar se require foi hookeado
                return true -- Simulado
            end
        },
        {
            target = "game.HttpGet",
            original = game.HttpGet,
            check = function()
                -- Verificar se HttpGet foi hookeado
                return true -- Simulado
            end
        }
    }
    
    -- Monitorar hooks periodicamente
    task.spawn(function()
        while Custom.State.ProtectionActive do
            for _, detector in ipairs(self.HookDetectors) do
                if not detector.check() then
                    Custom:LogSecurityEvent("HOOK_DETECTED",
                        "Hook detected on function: " .. detector.target)
                    
                    -- Tentar restaurar função original
                    if detector.original then
                        -- Em produção, restauraria a função
                        print("[RuntimeProtection] Attempting to restore hooked function")
                    end
                end
            end
            
            wait(10)
        end
    end)
end

function RuntimeProtection:SetupTamperMonitoring()
    -- Monitorar alterações em tabelas críticas
    self.TamperMonitors = {
        {
            target = _G,
            name = "GlobalTable",
            watchlist = {"NexusOS", "NexusCrypto", "NexusMemory"},
            lastState = {}
        },
        {
            target = getrenv and getrenv() or {},
            name = "Environment",
            watchlist = {"print", "warn", "error"},
            lastState = {}
        }
    }
    
    -- Verificar periodicamente
    task.spawn(function()
        while Custom.State.ProtectionActive do
            for _, monitor in ipairs(self.TamperMonitors) do
                self:CheckTampering(monitor)
            end
            
            wait(15)
        end
    end)
end

function RuntimeProtection:CheckTampering(monitor)
    for _, key in ipairs(monitor.watchlist) do
        local currentValue = monitor.target[key]
        local lastValue = monitor.lastState[key]
        
        if lastValue and tostring(currentValue) ~= tostring(lastValue) then
            Custom:LogSecurityEvent("TAMPER_DETECTED",
                "Tampering detected in " .. monitor.name .. "[" .. key .. "]")
            
            -- Tentar restaurar
            if type(lastValue) == "function" then
                -- Em produção, restauraria a função
                print("[RuntimeProtection] Function tampering detected")
            end
        end
        
        monitor.lastState[key] = currentValue
    end
end

function RuntimeProtection:SetupAntiDebug()
    -- Técnicas anti-debug básicas
    task.spawn(function()
        while Custom.State.ProtectionActive do
            -- Verificar tempo de execução (debuggers podem pausar)
            local startTime = tick()
            
            -- Loop intensivo
            for i = 1, 1000000 do
                -- Nada, apenas passar tempo
            end
            
            local endTime = tick()
            local elapsed = endTime - startTime
            
            -- Se o tempo for muito longo, possivelmente há debugger
            if elapsed > 0.2 then -- 200ms
                Custom:LogSecurityEvent("DEBUGGER_DETECTED",
                    "Possible debugger detected. Elapsed: " .. elapsed)
                
                -- Contramedidas
                self:AntiDebugResponse()
            end
            
            wait(math.random(30, 60))
        end
    end)
end

function RuntimeProtection:AntiDebugResponse()
    local responseLevel = Custom.Config.Security.ProtectionLevel
    
    if responseLevel >= 4 then
        -- Resposta agressiva
        Custom:EmergencyShutdown("Debugger detected")
    elseif responseLevel >= 2 then
        -- Resposta moderada
        Custom:DisableHighRiskFeatures()
        Custom:LogSecurityEvent("ANTI_DEBUG_RESPONSE",
            "High-risk features disabled due to debugger detection")
    end
end

function RuntimeProtection:RunIntegrityChecks()
    local allPassed = true
    
    for name, check in pairs(self.IntegrityChecks) do
        if check.enabled then
            local success = check.check()
            
            if not success then
                allPassed = false
                Custom.State.RuntimeIntegrity = false
                
                -- Resposta baseada na severidade
                if name == "CodeChecksum" then
                    Custom:EmergencyShutdown("Code integrity compromised")
                end
            end
        end
    end
    
    return allPassed
end

-- ============ SISTEMA DE AVALIAÇÃO DE RISCO ============
local RiskAssessmentSystem = {
    RiskFactors = {},
    CurrentRiskLevel = 0,
    RiskHistory = {},
    SafetyMeasures = {}
}

function RiskAssessmentSystem:Initialize()
    self.RiskFactors = {
        Behavioral = {weight = 0.3, value = 0},
        Environmental = {weight = 0.25, value = 0},
        Memory = {weight = 0.2, value = 0},
        Network = {weight = 0.15, value = 0},
        Runtime = {weight = 0.1, value = 0}
    }
    
    -- Iniciar monitoramento de risco
    self:StartRiskMonitoring()
end

function RiskAssessmentSystem:StartRiskMonitoring()
    task.spawn(function()
        while Custom.State.ProtectionActive do
            self:AssessRisk()
            wait(10) -- Avaliar a cada 10 segundos
        end
    end)
end

function RiskAssessmentSystem:AssessRisk()
    -- Avaliar fatores comportamentais
    local behaviorStats = BehavioralSystem:GetActionStatistics()
    self.RiskFactors.Behavioral.value = math.min(behaviorStats.highRiskActions * 10, 100)
    
    -- Avaliar fatores ambientais
    local envChanged, changes, envRisk = EnvironmentHasher:CheckEnvironmentChanges()
    self.RiskFactors.Environmental.value = envRisk
    
    -- Avaliar fatores de memória
    if _G.NexusMemory then
        local memReport = _G.NexusMemory:GetProtectionReport()
        self.RiskFactors.Memory.value = math.min(memReport.DumpAttempts * 20, 100)
    end
    
    -- Calcular risco total
    local totalRisk = 0
    for factor, data in pairs(self.RiskFactors) do
        totalRisk = totalRisk + (data.value * data.weight)
    end
    
    self.CurrentRiskLevel = math.floor(totalRisk)
    
    -- Registrar no histórico
    table.insert(self.RiskHistory, {
        timestamp = os.time(),
        riskLevel = self.CurrentRiskLevel,
        factors = self.RiskFactors
    })
    
    if #self.RiskHistory > 100 then
        table.remove(self.RiskHistory, 1)
    end
    
    -- Aplicar medidas de segurança baseadas no risco
    self:ApplySafetyMeasures()
    
    return self.CurrentRiskLevel
end

function RiskAssessmentSystem:ApplySafetyMeasures()
    local risk = self.CurrentRiskLevel
    
    if risk >= 80 then
        -- Risco crítico
        if Custom.Config.Advanced.EmergencyProtocols.AutoDisableOnHighRisk then
            Custom:EmergencyShutdown("Critical risk level: " .. risk)
        end
        
    elseif risk >= 60 then
        -- Risco alto
        self:EnableSafetyMeasure("DISABLE_HIGH_RISK_FEATURES")
        self:EnableSafetyMeasure("REDUCE_PERFORMANCE")
        self:EnableSafetyMeasure("INCREASE_MONITORING")
        
    elseif risk >= 40 then
        -- Risco médio
        self:EnableSafetyMeasure("ENABLE_BASIC_PROTECTION")
        self:EnableSafetyMeasure("REDUCE_LOGGING")
        
    elseif risk >= 20 then
        -- Risco baixo
        self:EnableSafetyMeasure("ENHANCED_MONITORING")
    end
    
    -- Risco mínimo (<20) - operação normal
end

function RiskAssessmentSystem:EnableSafetyMeasure(measure)
    if not self.SafetyMeasures[measure] then
        self.SafetyMeasures[measure] = {
            enabled = true,
            enabledAt = os.time()
        }
        
        Custom:LogSecurityEvent("SAFETY_MEASURE_ACTIVATED",
            "Safety measure activated: " .. measure)
    end
end

function RiskAssessmentSystem:GetRiskReport()
    return {
        currentRisk = self.CurrentRiskLevel,
        factors = self.RiskFactors,
        historySize = #self.RiskHistory,
        safetyMeasures = self.SafetyMeasures
    }
end

-- ============ FUNÇÕES PRINCIPAIS DO PRESET ============
function Custom:HashString(str)
    -- Hash simples (em produção usar algo mais robusto)
    local hash = 0
    
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 2^32
    end
    
    return string.format("%08x", hash)
end

function Custom:GenerateRandomString(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local str = ""
    
    for i = 1, length do
        str = str .. string.sub(chars, math.random(1, #chars), 1)
    end
    
    return str
end

function Custom:LogSecurityEvent(eventType, details)
    if not Custom.Config.Advanced.Logging.SecurityEvents then
        return
    end
    
    local event = {
        type = eventType,
        details = details,
        timestamp = os.time(),
        riskLevel = RiskAssessmentSystem.CurrentRiskLevel or 0,
        environmentHash = EnvironmentHasher.CurrentHash
    }
    
    table.insert(Custom.State.DetectionHistory, event)
    
    -- Limitar histórico
    if #Custom.State.DetectionHistory > Custom.Config.Advanced.Logging.MaxLogSize then
        table.remove(Custom.State.DetectionHistory, 1)
    end
    
    -- Criptografar log se configurado
    if Custom.Config.Advanced.Logging.LogEncryption and _G.NexusCrypto then
        event.encrypted = true
        event.details = _G.NexusCrypto:Encrypt(details)
    end
    
    print("[Custom Security]", eventType, "-", details)
    
    -- Notificar sistema principal
    if _G.NexusCrypto then
        _G.NexusCrypto:LogSecurityEvent("CUSTOM_" .. eventType, details)
    end
end

function Custom:HumanizeAction(actionFunc, baseDelay, actionType)
    return function(...)
        -- Aplicar delay humanizado
        local delay = BehavioralSystem:HumanizeDelay(baseDelay or 0.1)
        wait(delay)
        
        -- Registrar ação
        BehavioralSystem:RecordAction(actionType or "UNKNOWN_ACTION", {
            delay = delay,
            timestamp = os.time()
        })
        
        -- Executar ação
        return actionFunc(...)
    end
end

function Custom:EmergencyShutdown(reason)
    print("[Custom] EMERGENCY SHUTDOWN: " .. (reason or "Unknown reason"))
    
    Custom:LogSecurityEvent("EMERGENCY_SHUTDOWN",
        "Shutdown initiated. Reason: " .. (reason or "Unknown"))
    
    -- Desativar todas as features
    self:DisableAllFeatures()
    
    -- Limpar dados sensíveis
    self:WipeSensitiveData()
    
    -- Notificar usuário
    if _G.NexusNotifications then
        _G.NexusNotifications:Error(
            "Security Emergency",
            "Custom preset has been shut down for security reasons: " .. reason,
            10
        )
    end
    
    -- Desativar proteção
    Custom.State.ProtectionActive = false
    
    return true
end

function Custom:DisableHighRiskFeatures()
    print("[Custom] Disabling high-risk features...")
    
    -- Lista de features de alto risco
    local highRiskFeatures = {
        {module = "PhysicsAndMovement", features = {1, 2, 3, 17}}, -- Voo, NoClip, Speed, Teleport
        {module = "AutomationAndInteraction", features = {1, 2, 6}}, -- Aimbot, Trigger, Farm
        {module = "VisualDebugger", features = {16, 26}} -- FreeCam, FullBright
    }
    
    for _, moduleData in ipairs(highRiskFeatures) do
        if _G.NexusModules and _G.NexusModules[moduleData.module] then
            local module = _G.NexusModules[moduleData.module]
            
            for _, featureId in ipairs(moduleData.features) do
                if module.DisableFeature then
                    pcall(module.DisableFeature, featureId)
                end
            end
        end
    end
    
    Custom:LogSecurityEvent("HIGH_RISK_FEATURES_DISABLED",
        "High-risk features disabled due to security concerns")
end

function Custom:DisableAllFeatures()
    print("[Custom] Disabling all features...")
    
    if _G.NexusModules then
        for moduleName, module in pairs(_G.NexusModules) do
            if module.DisableFeature and module.State and module.State.ActiveFeatures then
                for featureId, _ in pairs(module.State.ActiveFeatures) do
                    pcall(module.DisableFeature, featureId)
                end
            end
        end
    end
end

function Custom:WipeSensitiveData()
    print("[Custom] Wiping sensitive data...")
    
    -- Limpar dados do preset
    Custom.State.BehavioralPatterns = {}
    Custom.State.DetectionHistory = {}
    Custom.State.SafetyMeasures = {}
    
    -- Limpar sistemas
    BehavioralSystem.ActionHistory = {}
    BehavioralSystem.PatternDatabase = {}
    BehavioralSystem.CurrentPattern = {}
    
    EnvironmentHasher.HashHistory = {}
    
    -- Coletar lixo
    collectgarbage()
    collectgarbage()
    
    print("[Custom] Sensitive data wiped")
end

function Custom:ApplyGameSpecificProfile(gameId)
    gameId = tostring(gameId)
    
    if Custom.Config.GameSpecific.SafetyProfiles[gameId] then
        local profile = Custom.Config.GameSpecific.SafetyProfiles[gameId]
        
        print("[Custom] Applying game-specific profile for", gameId)
        
        -- Aplicar configurações do perfil
        for key, value in pairs(profile) do
            if key == "MaxSpeed" then
                if _G.NexusModules.PhysicsAndMovement then
                    _G.NexusModules.PhysicsAndMovement.Config.Speed.WalkSpeed = math.min(
                        _G.NexusModules.PhysicsAndMovement.Config.Speed.WalkSpeed,
                        value
                    )
                end
            elseif key == "NoAimbot" and value then
                if _G.NexusModules.AutomationAndInteraction then
                    _G.NexusModules.AutomationAndInteraction.Config.Aimbot.Enabled = false
                end
            end
        end
        
        return true
    end
    
    return false
end

function Custom:Initialize()
    print("[Custom] Initializing advanced custom preset with anti-ban systems...")
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Verificar dependências
    for _, dep in ipairs(self.Dependencies) do
        if not _G["Nexus" .. dep] and not _G["Nexus" .. dep:gsub("^%l", string.upper)] then
            print("[Custom] Warning: Missing dependency:", dep)
        end
    end
    
    -- Inicializar sistemas
    EnvironmentHasher:GenerateEnvironmentHash()
    BehavioralSystem:Initialize()
    MemoryMaskingSystem:Initialize()
    RuntimeProtection:Initialize()
    RiskAssessmentSystem:Initialize()
    
    -- Aplicar perfil específico do jogo
    self:ApplyGameSpecificProfile(game.PlaceId)
    
    -- Configurar proteção automática
    if self.Config.Security.AutoAdjustProtection then
        print("[Custom] Auto-adjust protection enabled")
    end
    
    -- Iniciar monitoramento de integridade
    if self.Config.Security.RuntimeProtection.IntegrityChecks then
        task.spawn(function()
            while self.State.ProtectionActive do
                RuntimeProtection:RunIntegrityChecks()
                wait(60)
            end
        end)
    end
    
    self.State.ProtectionActive = true
    self.State.Initialized = true
    
    print("[Custom] Custom preset initialized at protection level", self.Config.Security.ProtectionLevel)
    print("[Custom] Environment hash:", EnvironmentHasher.CurrentHash)
    
    return true
end

function Custom:Shutdown()
    print("[Custom] Shutting down custom preset...")
    
    self.State.ProtectionActive = false
    self.State.Initialized = false
    
    -- Limpar sistemas
    BehavioralSystem.ActionHistory = {}
    MemoryMaskingSystem.FakeMemoryBlocks = {}
    
    print("[Custom] Custom preset shutdown complete")
end

function Custom:GetProtectionReport()
    return {
        status = self.State.ProtectionActive and "ACTIVE" or "INACTIVE",
        protectionLevel = self.Config.Security.ProtectionLevel,
        environmentHash = EnvironmentHasher.CurrentHash,
        riskAssessment = RiskAssessmentSystem:GetRiskReport(),
        behavioralStats = BehavioralSystem:GetActionStatistics(),
        integrityStatus = self.State.RuntimeIntegrity and "INTACT" or "COMPROMISED",
        securityEvents = #self.State.DetectionHistory
    }
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusPresets then
    _G.NexusPresets = {}
end

_G.NexusPresets.Custom = Custom

return Custom
