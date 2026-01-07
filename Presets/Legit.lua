
-- =============================================
-- NEXUS OS - LEGIT PRESET
-- Arquivo: Legit.lua
-- Local: src/Presets/Legit.lua
-- Descrição: Configurações para gameplay legítimo com proteção anti-ban
-- =============================================

local LegitPreset = {
    Name = "Legit",
    Version = "2.0.0",
    Description = "Preset para gameplay legítimo e discreto",
    Author = "Nexus Security Team",
    
    Config = {},
    State = {
        Initialized = false,
        Active = false,
        SecurityLayers = {},
        BehaviorRandomizer = {},
        DetectionAvoidance = {},
        Humanization = {},
        LastUpdate = 0
    },
    
    Dependencies = {"StateManager", "Crypto", "Performance"}
}

-- ============ CONFIGURAÇÕES DO PRESET ============
LegitPreset.DefaultConfig = {
    General = {
        Enabled = true,
        AutoApply = true,
        Priority = "SAFETY",
        Mode = "COMPETITIVE",
        Version = "2.0.0",
        
        Activation = {
            Delay = 2.5,
            Stagger = true,
            StaggerTime = 0.3,
            Silent = true,
            AntiDetection = true
        }
    },
    
    Behavior = {
        Humanization = {
            Enabled = true,
            Level = 3, -- 1: Basic, 2: Medium, 3: Advanced
            ReactionTime = {
                Min = 0.15,
                Max = 0.35,
                Variance = 0.1
            },
            MovementPatterns = {
                Randomize = true,
                NaturalMovement = true,
                AvoidPatterns = true,
                PatternLength = 5,
                BreakPatternAfter = 10
            },
            InputRandomization = {
                MouseJitter = 0.02,
                KeyPressVariance = 0.05,
                ClickDuration = {
                    Min = 0.08,
                    Max = 0.15
                }
            }
        },
        
        Timing = {
            RandomDelays = true,
            MinDelay = 0.05,
            MaxDelay = 0.2,
            Adaptive = true,
            LearningMode = false,
            
            ActionSpacing = {
                Combat = 0.2,
                Movement = 0.1,
                Interaction = 0.15
            }
        }
    },
    
    Security = {
        AntiDetection = {
            Enabled = true,
            Level = 4, -- 1-5
            EvasionTechniques = {
                MemoryObfuscation = true,
                PatternRandomization = true,
                TimingManipulation = true,
                FakeInputs = false,
                BehaviorCloaking = true
            },
            
            DetectionAvoidance = {
                CheckForAntiCheat = true,
                MonitorProcesses = true,
                ScanMemory = false,
                HideActivity = true,
                StealthMode = true
            },
            
            ResponseSystem = {
                AutoDisable = true,
                DisableThreshold = 3,
                CoolDownPeriod = 300,
                EmergencyProtocol = "FULL_DISABLE"
            }
        },
        
        RateLimiting = {
            Enabled = true,
            ActionsPerMinute = 120,
            BurstLimit = 15,
            BurstWindow = 5,
            
            Limits = {
                Teleports = 10,
                SpeedChanges = 20,
                FeatureToggles = 30,
                Inputs = 1000
            }
        },
        
        Obfuscation = {
            EncryptMemory = true,
            RandomizeCalls = true,
            FakeTraces = true,
            HidePatterns = true,
            
            Techniques = {
                StringEncryption = true,
                CodeFlowRandomization = false,
                DeadCodeInjection = true,
                VariableRenaming = true
            }
        }
    },
    
    Features = {
        PhysicsAndMovement = {
            Speed = {
                WalkSpeed = 20,
                RunSpeed = 32,
                JumpPower = 35,
                Enabled = true,
                MaxBoost = 1.3,
                SmoothTransition = true
            },
            
            Flight = {
                Enabled = false,
                Speed = 25,
                Smoothness = 0.8,
                VisualEffects = false
            },
            
            NoClip = {
                Enabled = false,
                AutoDisable = true,
                Timeout = 10
            }
        },
        
        VisualDebugger = {
            ESP = {
                Enabled = false,
                MaxDistance = 250,
                TeamOnly = true,
                MinimalInfo = true
            },
            
            Chams = {
                Enabled = false
            },
            
            Camera = {
                FOV = 70,
                Smoothing = 0.3
            }
        },
        
        AutomationAndInteraction = {
            Aimbot = {
                Enabled = false,
                Smoothing = 0.7,
                FOV = 35,
                MaxDistance = 150,
                OnlyVisible = true,
                TeamCheck = true
            },
            
            TriggerBot = {
                Enabled = false,
                Delay = 0.15,
                Randomization = 0.05,
                HitChance = 80
            },
            
            AutoFarm = {
                Enabled = false,
                SlowMode = true,
                HumanLike = true
            }
        },
        
        PlayerAndUtility = {
            GodMode = false,
            InfiniteJump = false,
            AntiAFK = true,
            AutoRespawn = true,
            
            Teleport = {
                SafetyCheck = true,
                VisualEffects = false,
                Cooldown = 3
            }
        }
    },
    
    Performance = {
        Optimization = {
            MaxFPS = 144,
            MemoryCleanup = true,
            RenderOptimization = true,
            NetworkOptimization = false
        },
        
        Monitoring = {
            LogActivity = false,
            AlertOnAnomaly = true,
            AutoOptimize = true
        }
    },
    
    Compatibility = {
        GameBlacklist = {
            "Jailbreak",
            "Arsenal",
            "Adopt Me"
        },
        
        ExecutorWhitelist = {
            "Synapse X",
            "ScriptWare",
            "Krnl"
        },
        
        SafetyChecks = {
            CheckGame = true,
            CheckExecutor = true,
            CheckEnvironment = true
        }
    }
}

-- ============ SISTEMA DE HUMANIZAÇÃO ============
local HumanizationSystem = {
    BehaviorProfiles = {},
    CurrentProfile = "DEFAULT",
    ActionHistory = {},
    PatternDetector = {},
    InputRandomizer = {},
    LastHumanization = 0
}

function HumanizationSystem:Initialize()
    print("[HumanizationSystem] Initializing...")
    
    -- Perfis de comportamento
    self.BehaviorProfiles = {
        DEFAULT = {
            ReactionTime = {0.15, 0.3},
            Accuracy = {0.85, 0.95},
            MovementSpeed = {0.9, 1.1},
            PatternLength = 7,
            BreakChance = 0.2
        },
        
        CASUAL = {
            ReactionTime = {0.2, 0.4},
            Accuracy = {0.7, 0.85},
            MovementSpeed = {0.8, 1.2},
            PatternLength = 5,
            BreakChance = 0.3
        },
        
        COMPETITIVE = {
            ReactionTime = {0.1, 0.25},
            Accuracy = {0.9, 0.98},
            MovementSpeed = {0.95, 1.05},
            PatternLength = 10,
            BreakChance = 0.1
        },
        
        NOOB = {
            ReactionTime = {0.3, 0.6},
            Accuracy = {0.5, 0.7},
            MovementSpeed = {0.7, 1.3},
            PatternLength = 3,
            BreakChance = 0.4
        }
    }
    
    -- Detector de padrões
    self.PatternDetector = {
        History = {},
        MaxHistory = 50,
        Patterns = {},
        
        Detect = function(self, action)
            table.insert(self.History, {
                Action = action,
                Time = tick(),
                Context = self:GetContext()
            })
            
            if #self.History > self.MaxHistory then
                table.remove(self.History, 1)
            end
            
            -- Detectar padrões repetitivos
            if #self.History >= 10 then
                local recent = {}
                for i = #self.History - 9, #self.History do
                    table.insert(recent, self.History[i].Action)
                end
                
                local isPattern = true
                for i = 2, #recent do
                    if recent[i] ~= recent[1] then
                        isPattern = false
                        break
                    end
                end
                
                if isPattern then
                    LegitPreset:LogSecurityEvent("PATTERN_DETECTED", 
                        "Repetitive pattern detected: " .. recent[1])
                    return true
                end
            end
            
            return false
        end,
        
        GetContext = function(self)
            return {
                GameTime = tick(),
                PlayerCount = #game:GetService("Players"):GetPlayers(),
                Location = game:GetService("Players").LocalPlayer.Character and 
                    game:GetService("Players").LocalPlayer.Character:GetPivot().Position or Vector3.new(0,0,0)
            }
        end,
        
        Clear = function(self)
            self.History = {}
            self.Patterns = {}
        end
    }
    
    -- Randomizador de input
    self.InputRandomizer = {
        LastMousePos = Vector2.new(0, 0),
        MouseDrift = 0,
        KeyPressTimes = {},
        
        ApplyMouseJitter = function(self, position)
            if not LegitPreset.Config.Behavior.Humanization.InputRandomization.MouseJitter then
                return position
            end
            
            local jitter = LegitPreset.Config.Behavior.Humanization.InputRandomization.MouseJitter
            local dx = (math.random() * 2 - 1) * jitter
            local dy = (math.random() * 2 - 1) * jitter
            
            -- Drift natural
            self.MouseDrift = self.MouseDrift * 0.9 + dx * 0.1
            
            return Vector2.new(
                position.X + self.MouseDrift,
                position.Y + dy
            )
        end,
        
        RandomizeClickDuration = function(self)
            local config = LegitPreset.Config.Behavior.Humanization.InputRandomization.ClickDuration
            local duration = math.random() * (config.Max - config.Min) + config.Min
            
            -- Registrar tempo
            self.KeyPressTimes[tick()] = duration
            
            -- Limitar histórico
            local toRemove = {}
            for time, _ in pairs(self.KeyPressTimes) do
                if tick() - time > 10 then
                    table.insert(toRemove, time)
                end
            end
            for _, time in ipairs(toRemove) do
                self.KeyPressTimes[time] = nil
            end
            
            return duration
        end,
        
        GetAverageClickDuration = function(self)
            local total = 0
            local count = 0
            
            for _, duration in pairs(self.KeyPressTimes) do
                total = total + duration
                count = count + 1
            end
            
            return count > 0 and total / count or 0.1
        end
    }
    
    -- Sistema de tempo de reação
    self.ReactionTimeSystem = {
        LastReaction = 0,
        ReactionTimes = {},
        
        GetReactionTime = function(self)
            local config = LegitPreset.Config.Behavior.Humanization.ReactionTime
            local base = math.random() * (config.Max - config.Min) + config.Min
            local variance = config.Variance
            
            -- Ajustar baseado no perfil
            local profile = HumanizationSystem.BehaviorProfiles[HumanizationSystem.CurrentProfile]
            if profile then
                base = math.random(profile.ReactionTime[1], profile.ReactionTime[2])
            end
            
            -- Adicionar variação aleatória
            base = base * (1 + (math.random() * 2 - 1) * variance)
            
            -- Manter histórico
            table.insert(self.ReactionTimes, base)
            if #self.ReactionTimes > 100 then
                table.remove(self.ReactionTimes, 1)
            end
            
            self.LastReaction = tick()
            
            return base
        end,
        
        GetAverageReactionTime = function(self)
            if #self.ReactionTimes == 0 then
                return 0.2
            end
            
            local total = 0
            for _, time in ipairs(self.ReactionTimes) do
                total = total + time
            end
            
            return total / #self.ReactionTimes
        end
    }
    
    self.LastHumanization = tick()
    
    print("[HumanizationSystem] Initialized with profile:", self.CurrentProfile)
    
    return true
end

function HumanizationSystem:ApplyToAction(action, context)
    if not LegitPreset.Config.Behavior.Humanization.Enabled then
        return action
    end
    
    local currentTime = tick()
    
    -- Verificar se precisa quebrar padrão
    if self.PatternDetector:Detect(action) then
        if math.random() < 0.3 then -- 30% de chance de quebrar padrão
            LegitPreset:LogEvent("PATTERN_BROKEN", "Breaking detected pattern")
            return "BREAK_" .. math.random(1, 3)
        end
    end
    
    -- Aplicar tempo de reação
    if context.requiresReaction then
        local reactionTime = self.ReactionTimeSystem:GetReactionTime()
        
        -- Atraso natural
        if LegitPreset.Config.Behavior.Timing.RandomDelays then
            local delay = math.random(
                LegitPreset.Config.Behavior.Timing.MinDelay * 1000,
                LegitPreset.Config.Behavior.Timing.MaxDelay * 1000
            ) / 1000
            
            reactionTime = reactionTime + delay
        end
        
        -- Registrar para análise
        self.ActionHistory[#self.ActionHistory + 1] = {
            Action = action,
            ReactionTime = reactionTime,
            Timestamp = currentTime,
            Context = context
        }
        
        -- Limitar histórico
        if #self.ActionHistory > 100 then
            table.remove(self.ActionHistory, 1)
        end
    end
    
    -- Aplicar variação de input se for movimento do mouse
    if context.inputType == "MOUSE" then
        action = self.InputRandomizer:ApplyMouseJitter(action)
    end
    
    self.LastHumanization = currentTime
    
    return action
end

function HumanizationSystem:SetProfile(profileName)
    if self.BehaviorProfiles[profileName] then
        self.CurrentProfile = profileName
        LegitPreset:LogEvent("PROFILE_CHANGED", "Behavior profile: " .. profileName)
        return true
    end
    
    return false
end

function HumanizationSystem:GetStatistics()
    return {
        CurrentProfile = self.CurrentProfile,
        ReactionTimes = {
            Average = self.ReactionTimeSystem:GetAverageReactionTime(),
            Last = self.ReactionTimeSystem.LastReaction
        },
        PatternDetection = {
            TotalDetected = #self.PatternDetector.Patterns,
            HistorySize = #self.PatternDetector.History
        },
        InputRandomization = {
            AverageClickDuration = self.InputRandomizer:GetAverageClickDuration(),
            MouseDrift = self.InputRandomizer.MouseDrift
        },
        ActionHistory = {
            TotalActions = #self.ActionHistory,
            RecentActions = {}
        }
    }
end

-- ============ SISTEMA ANTI-DETECTION ============
local AntiDetectionSystem = {
    DetectionCount = 0,
    LastDetection = 0,
    DetectionHistory = {},
    EvasionActive = false,
    SafetyMeasures = {},
    FakeBehavior = {}
}

function AntiDetectionSystem:Initialize()
    print("[AntiDetectionSystem] Initializing...")
    
    self.SafetyMeasures = {
        RateLimiter = {
            Actions = {},
            Limits = LegitPreset.Config.Security.RateLimiting.Limits,
            
            Check = function(self, actionType)
                local currentTime = tick()
                local limit = self.Limits[actionType] or 1000
                
                -- Limpar ações antigas
                local validActions = {}
                for _, action in ipairs(self.Actions) do
                    if currentTime - action.time < 60 then -- Último minuto
                        table.insert(validActions, action)
                    end
                end
                self.Actions = validActions
                
                -- Contar ações deste tipo
                local count = 0
                for _, action in ipairs(self.Actions) do
                    if action.type == actionType then
                        count = count + 1
                    end
                end
                
                -- Verificar limite
                if count >= limit then
                    LegitPreset:LogSecurityEvent("RATE_LIMIT_EXCEEDED", 
                        actionType .. ": " .. count .. "/" .. limit)
                    return false
                end
                
                -- Registrar ação
                table.insert(self.Actions, {
                    type = actionType,
                    time = currentTime
                })
                
                return true
            end,
            
            GetCount = function(self, actionType)
                local count = 0
                for _, action in ipairs(self.Actions) do
                    if action.type == actionType then
                        count = count + 1
                    end
                end
                return count
            end
        },
        
        EnvironmentScanner = {
            LastScan = 0,
            ScanInterval = 30,
            SuspiciousProcesses = {
                "CheatEngine",
                "ProcessHacker",
                "x64dbg",
                "OllyDbg",
                "Wireshark"
            },
            
            Scan = function(self)
                local currentTime = tick()
                if currentTime - self.LastScan < self.ScanInterval then
                    return true
                end
                
                self.LastScan = currentTime
                
                -- Verificar processos (simulado)
                if LegitPreset.Config.Security.AntiDetection.DetectionAvoidance.MonitorProcesses then
                    for _, proc in ipairs(self.SuspiciousProcesses) do
                        -- Em produção, verificar processos reais
                        LegitPreset:LogEvent("ENVIRONMENT_SCAN", "Checked for: " .. proc)
                    end
                end
                
                -- Verificar anti-cheat
                if LegitPreset.Config.Security.AntiDetection.DetectionAvoidance.CheckForAntiCheat then
                    self:CheckForAntiCheat()
                end
                
                return true
            end,
            
            CheckForAntiCheat = function(self)
                -- Verificar sinais de anti-cheat
                local warningSigns = 0
                
                -- Verificar scripts de segurança
                local securityScripts = {
                    "AntiCheat",
                    "AC_",
                    "Security",
                    "BanSystem",
                    "Detection"
                }
                
                for _, obj in ipairs(game:GetDescendants()) do
                    if obj:IsA("Script") or obj:IsA("LocalScript") then
                        local name = obj.Name:lower()
                        for _, pattern in ipairs(securityScripts) do
                            if string.find(name, pattern:lower()) then
                                warningSigns = warningSigns + 1
                                LegitPreset:LogSecurityEvent("ANTI_CHEAT_DETECTED", 
                                    "Security script: " .. obj.Name)
                            end
                        end
                    end
                end
                
                if warningSigns > 0 then
                    LegitPreset:LogSecurityEvent("HIGH_RISK_ENVIRONMENT", 
                        warningSigns .. " security scripts detected")
                    return false
                end
                
                return true
            end
        },
        
        BehaviorCloak = {
            Active = false,
            FakeActions = {},
            LastFakeAction = 0,
            
            GenerateFakeAction = function(self)
                local actions = {
                    "MOVE_RANDOM",
                    "LOOK_AROUND",
                    "CHECK_INVENTORY",
                    "ADJUST_SETTINGS",
                    "CHAT_MESSAGE"
                }
                
                local action = actions[math.random(1, #actions)]
                local delay = math.random(1, 5)
                
                self.FakeActions[#self.FakeActions + 1] = {
                    action = action,
                    delay = delay,
                    generated = tick()
                }
                
                return action, delay
            end,
            
            ExecuteFakeActions = function(self)
                local currentTime = tick()
                
                -- Executar ações pendentes
                for i = #self.FakeActions, 1, -1 do
                    local fake = self.FakeActions[i]
                    if currentTime - fake.generated >= fake.delay then
                        LegitPreset:LogEvent("FAKE_ACTION", "Executed: " .. fake.action)
                        table.remove(self.FakeActions, i)
                        self.LastFakeAction = currentTime
                    end
                end
                
                -- Gerar nova ação se passou tempo suficiente
                if currentTime - self.LastFakeAction > 10 then
                    local action, delay = self:GenerateFakeAction()
                    LegitPreset:LogEvent("FAKE_ACTION_GENERATED", 
                        action .. " in " .. delay .. "s")
                end
            end
        }
    }
    
    self.FakeBehavior = {
        InputGenerator = {
            GenerateNaturalInputs = function(self)
                -- Gerar inputs naturais periódicos
                local currentTime = tick()
                
                -- Movimento aleatório ocasional
                if math.random(1, 100) <= 5 then -- 5% de chance
                    local directions = {"W", "A", "S", "D"}
                    local direction = directions[math.random(1, #directions)]
                    LegitPreset:LogEvent("NATURAL_INPUT", "Random movement: " .. direction)
                end
                
                -- Olhar ao redor
                if math.random(1, 100) <= 3 then -- 3% de chance
                    LegitPreset:LogEvent("NATURAL_INPUT", "Looking around")
                end
            end
        }
    }
    
    print("[AntiDetectionSystem] Initialized with " .. 
        #self.SafetyMeasures.RateLimiter.SuspiciousProcesses .. 
        " process checks")
    
    return true
end

function AntiDetectionSystem:CheckSafety(action, context)
    if not LegitPreset.Config.Security.AntiDetection.Enabled then
        return true, "Security disabled"
    end
    
    -- Verificar rate limiting
    local actionType = context.actionType or "UNKNOWN"
    if not self.SafetyMeasures.RateLimiter:Check(actionType) then
        self:RecordDetection("RATE_LIMIT", actionType)
        return false, "Rate limit exceeded"
    end
    
    -- Escanear ambiente
    if not self.SafetyMeasures.EnvironmentScanner:Scan() then
        self:RecordDetection("ENVIRONMENT_RISK", "High risk environment")
        return false, "Unsafe environment"
    end
    
    -- Verificar padrões detectáveis
    if self:IsPatternDetectable(action, context) then
        self:RecordDetection("DETECTABLE_PATTERN", action)
        return false, "Detectable pattern"
    end
    
    return true, "Safe"
end

function AntiDetectionSystem:RecordDetection(type, details)
    self.DetectionCount = self.DetectionCount + 1
    self.LastDetection = tick()
    
    local detection = {
        Type = type,
        Details = details,
        Timestamp = tick(),
        Count = self.DetectionCount
    }
    
    table.insert(self.DetectionHistory, detection)
    
    -- Limitar histórico
    if #self.DetectionHistory > 100 then
        table.remove(self.DetectionHistory, 1)
    end
    
    LegitPreset:LogSecurityEvent("DETECTION_RECORDED", type .. ": " .. details)
    
    -- Verificar se excedeu limite
    if self.DetectionCount >= LegitPreset.Config.Security.AntiDetection.ResponseSystem.DisableThreshold then
        self:ActivateEmergencyProtocol()
    end
end

function AntiDetectionSystem:IsPatternDetectable(action, context)
    -- Verificar ações muito rápidas
    if context.speed and context.speed > 100 then -- Unidades por segundo
        return true
    end
    
    -- Verificar precisão perfeita
    if context.accuracy and context.accuracy >= 0.99 then
        return true
    end
    
    -- Verificar tempos de reação impossíveis
    if context.reactionTime and context.reactionTime < 0.05 then
        return true
    end
    
    return false
end

function AntiDetectionSystem:ActivateEmergencyProtocol()
    local protocol = LegitPreset.Config.Security.AntiDetection.ResponseSystem.EmergencyProtocol
    
    LegitPreset:LogSecurityEvent("EMERGENCY_PROTOCOL", 
        "Activating: " .. protocol .. " (Detections: " .. self.DetectionCount .. ")")
    
    if protocol == "FULL_DISABLE" then
        -- Desativar todas as features
        if _G.NexusOS and _G.NexusOS.ModuleManager then
            for moduleName, state in pairs(_G.NexusOS.ModuleManager.ModuleStates) do
                if state.features then
                    for featureId, active in pairs(state.features) do
                        if active then
                            _G.NexusOS.ModuleManager:DisableFeature(moduleName, featureId)
                        end
                    end
                end
            end
        end
        
        -- Ativar modo de segurança
        self.EvasionActive = true
        
        -- Limpar detecções após cooldown
        spawn(function()
            wait(LegitPreset.Config.Security.AntiDetection.ResponseSystem.CoolDownPeriod)
            self.DetectionCount = 0
            self.EvasionActive = false
            LegitPreset:LogEvent("SAFETY_RESET", "Safety cooldown complete")
        end)
    end
    
    return true
end

function AntiDetectionSystem:Update()
    -- Executar ações falsas se ativado
    if
