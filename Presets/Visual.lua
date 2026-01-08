-- =============================================
-- NEXUS OS - VISUAL PRESET
-- Arquivo: Visual.lua
-- Local: src/Presets/Visual.lua
-- Descrição: Preset para foco em elementos visuais e ESP avançado
-- =============================================

local VisualPreset = {
    Name = "Visual",
    Version = "2.0.0",
    Description = "Preset para vantagens visuais com ESP, trajetórias e informações detalhadas",
    Author = "Nexus Visual Team",
    
    Config = {},
    State = {
        Initialized = false,
        Active = false,
        ESPInstances = {},
        Trajectories = {},
        InformationPanels = {},
        OverlaySystem = {},
        RenderOptimizer = {},
        LastRenderUpdate = 0,
        SecurityEvents = 0,
        DetectionCount = 0
    },
    
    Dependencies = {"StateManager", "Crypto", "Performance", "VisualDebugger"}
}

-- ============ CONFIGURAÇÕES DO PRESET VISUAL ============
VisualPreset.DefaultConfig = {
    General = {
        Enabled = true,
        AutoApply = false,
        Priority = "VISIBILITY",
        Mode = "ENHANCED",
        Version = "2.0.0",
        
        Activation = {
            StaggeredLoad = true,
            LoadOrder = {"ESP", "Trajectories", "Information", "Overlay"},
            LoadDelay = 0.5,
            AntiDetectionLoad = true,
            MemoryOptimized = true
        }
    },
    
    ESP = {
        MasterSwitch = true,
        SecurityLevel = 2, -- 1: Safe, 2: Moderate, 3: Risky
        
        Players = {
            Enabled = true,
            MaxDistance = 2000,
            TeamSettings = {
                Allies = {
                    BoxColor = Color3.fromRGB(0, 120, 255),
                    TextColor = Color3.fromRGB(180, 220, 255),
                    ShowInfo = true,
                    ShowDistance = true,
                    ShowHealth = true
                },
                Enemies = {
                    BoxColor = Color3.fromRGB(255, 50, 50),
                    TextColor = Color3.fromRGB(255, 180, 180),
                    ShowInfo = true,
                    ShowDistance = true,
                    ShowHealth = true
                },
                Neutral = {
                    BoxColor = Color3.fromRGB(255, 255, 50),
                    TextColor = Color3.fromRGB(255, 255, 180),
                    ShowInfo = false,
                    ShowDistance = true,
                    ShowHealth = false
                }
            },
            
            BoxStyle = {
                Type = "CORNER", -- CORNER, BOX, FILLED
                Thickness = 1,
                Transparency = 0.7,
                CornerSize = 4,
                Rounding = 2
            },
            
            Information = {
                ShowName = true,
                ShowDistance = true,
                ShowHealth = true,
                ShowWeapon = false,
                ShowRank = false,
                CustomText = "",
                TextSize = 14,
                TextFont = 2,
                TextOutline = true,
                MaxTextLength = 20
            },
            
            HealthBar = {
                Enabled = true,
                Position = "LEFT", -- LEFT, RIGHT, BOTTOM, TOP
                Width = 3,
                ShowText = false,
                Gradient = true,
                FullColor = Color3.fromRGB(0, 255, 0),
                EmptyColor = Color3.fromRGB(255, 0, 0)
            },
            
            Tracers = {
                Enabled = true,
                Origin = "BOTTOM", -- BOTTOM, MIDDLE, CURSOR
                ColorMode = "TEAM", -- TEAM, HEALTH, CUSTOM
                CustomColor = Color3.fromRGB(255, 255, 255),
                Thickness = 1,
                Transparency = 0.6
            },
            
            Skeleton = {
                Enabled = false,
                Color = Color3.fromRGB(255, 255, 255),
                Thickness = 1,
                Transparency = 0.5,
                ShowJoints = false
            },
            
            Chams = {
                Enabled = false,
                Material = "ForceField",
                ColorMode = "TEAM",
                Transparency = 0.3,
                Wireframe = false,
                FillColor = Color3.fromRGB(255, 0, 0),
                WireframeColor = Color3.fromRGB(0, 255, 255)
            }
        },
        
        NPCs = {
            Enabled = true,
            MaxDistance = 1000,
            Color = Color3.fromRGB(255, 165, 0),
            ShowName = true,
            ShowDistance = true,
            ShowHealth = true
        },
        
        Items = {
            Enabled = true,
            MaxDistance = 500,
            Categories = {
                Weapons = {
                    Color = Color3.fromRGB(255, 50, 50),
                    Icon = "🔫",
                    ShowDistance = true
                },
                Ammo = {
                    Color = Color3.fromRGB(255, 255, 50),
                    Icon = "💊",
                    ShowDistance = false
                },
                Health = {
                    Color = Color3.fromRGB(50, 255, 50),
                    Icon = "❤️",
                    ShowDistance = true
                },
                Money = {
                    Color = Color3.fromRGB(50, 255, 255),
                    Icon = "💰",
                    ShowDistance = true
                },
                Important = {
                    Color = Color3.fromRGB(255, 50, 255),
                    Icon = "⭐",
                    ShowDistance = true
                }
            }
        },
        
        Vehicles = {
            Enabled = true,
            MaxDistance = 1500,
            Color = Color3.fromRGB(0, 200, 255),
            ShowName = true,
            ShowDistance = true,
            ShowHealth = true,
            ShowOccupants = false
        },
        
        World = {
            Enabled = false,
            ShowWaypoints = true,
            ShowInteractables = true,
            ShowSecretAreas = false,
            MaxDistance = 3000
        }
    },
    
    Trajectories = {
        Enabled = true,
        SecurityLevel = 3, -- Mais detectável
        
        BulletTrajectory = {
            Enabled = true,
            PredictionTime = 1.5,
            LineColor = Color3.fromRGB(255, 255, 0),
            LineThickness = 2,
            DotColor = Color3.fromRGB(255, 0, 0),
            DotSize = 4,
            ShowVelocity = true,
            MaxLength = 1000
        },
        
        GrenadeTrajectory = {
            Enabled = true,
            PredictionSteps = 50,
            LineColor = Color3.fromRGB(0, 255, 255),
            LineThickness = 1.5,
            ShowBounce = true,
            ShowExplosionRadius = true,
            RadiusColor = Color3.fromRGB(255, 100, 0)
        },
        
        ThrowableTrajectory = {
            Enabled = true,
            LineColor = Color3.fromRGB(255, 165, 0),
            LineThickness = 1,
            ShowArc = true
        }
    },
    
    Information = {
        MasterSwitch = true,
        
        PlayerInfo = {
            Enabled = true,
            Position = "TOPLEFT", -- TOPLEFT, TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT
            Width = 300,
            Height = 200,
            BackgroundColor = Color3.fromRGB(0, 0, 0, 150),
            TextColor = Color3.fromRGB(255, 255, 255),
            ShowLocalPlayer = true,
            ShowTeam = true,
            ShowEnemies = true,
            SortBy = "DISTANCE", -- DISTANCE, HEALTH, NAME
            MaxPlayers = 10
        },
        
        Radar = {
            Enabled = false, -- Muito detectável
            Size = 200,
            Position = "TOPRIGHT",
            BackgroundColor = Color3.fromRGB(0, 0, 0, 100),
            PlayerSize = 6,
            ShowNames = false,
            MaxDistance = 500,
            Rotation = true
        },
        
        Minimap = {
            Enabled = false, -- Extremamente detectável
            Size = 150,
            Position = "BOTTOMRIGHT",
            Zoom = 1.0,
            ShowPlayers = true,
            ShowItems = false,
            ShowObjectives = true
        },
        
        Crosshair = {
            Enabled = true,
            Type = "CROSS", -- CROSS, DOT, CIRCLE, ARROW
            Size = 12,
            Thickness = 1,
            Color = Color3.fromRGB(255, 255, 255),
            Gap = 3,
            Dynamic = true,
            ShowTargetInfo = true,
            TargetInfoColor = Color3.fromRGB(255, 255, 0)
        },
        
        Watermark = {
            Enabled = true,
            Text = "Nexus OS | Visual Preset",
            Position = "TOP",
            Color = Color3.fromRGB(255, 255, 255),
            BackgroundColor = Color3.fromRGB(0, 0, 0, 100),
            Size = 14,
            ShowFPS = true,
            ShowPing = true,
            ShowTime = true
        }
    },
    
    Overlay = {
        Enabled = true,
        
        Performance = {
            ShowFPS = true,
            ShowPing = true,
            ShowMemory = false,
            ShowCPU = false,
            Position = "BOTTOMLEFT",
            Color = Color3.fromRGB(255, 255, 255),
            Background = true
        },
        
        Combat = {
            ShowDamage = true,
            DamageColor = Color3.fromRGB(255, 50, 50),
            ShowKills = true,
            KillColor = Color3.fromRGB(0, 255, 0),
            ShowAccuracy = false,
            Position = "TOP"
        },
        
        GameInfo = {
            ShowTime = true,
            ShowMap = true,
            ShowGamemode = true,
            ShowPlayers = true,
            Position = "BOTTOMRIGHT"
        }
    },
    
    Effects = {
        MasterSwitch = true,
        
        VisualEnhancements = {
            FullBright = true,
            NoFog = true,
            NoBlur = false,
            EnhancedShadows = false,
            ColorCorrection = {
                Enabled = false,
                Brightness = 0,
                Contrast = 0,
                Saturation = 0,
                TintColor = Color3.fromRGB(255, 255, 255)
            }
        },
        
        PostProcessing = {
            Bloom = false,
            DepthOfField = false,
            SunRays = false,
            ColorGrading = false
        },
        
        CustomShaders = {
            Enabled = false, -- Muito detectável
            OutlinePlayers = false,
            OutlineColor = Color3.fromRGB(255, 255, 0),
            GlowItems = false,
            GlowColor = Color3.fromRGB(0, 255, 255)
        }
    },
    
    Security = {
        AntiDetection = {
            Enabled = true,
            Level = 3,
            
            ESPProtection = {
                RandomizeUpdateRate = true,
                MinUpdateRate = 0.05,
                MaxUpdateRate = 0.2,
                DistanceBasedUpdates = true,
                FadeAtDistance = true,
                OcclusionCheck = true,
                VisibilityCheck = true
            },
            
            MemoryProtection = {
                LimitESPObjects = true,
                MaxESPObjects = 50,
                AutoCleanup = true,
                CleanupInterval = 30,
                MemoryOptimization = true
            },
            
            RenderingProtection = {
                HideFromScreenshots = false,
                ReduceVisualSignature = true,
                RandomizeColors = false,
                ColorVariance = 0.1,
                FakeLag = false,
                LagAmount = 0.05
            },
            
            DetectionResponse = {
                AutoDisableESP = true,
                DisableThreshold = 5,
                EmergencyMode = "REDUCE",
                RecoveryTime = 60,
                FakeDisable = false
            }
        },
        
        RateLimiting = {
            ESPUpdates = 30, -- Updates por segundo
            TrajectoryUpdates = 20,
            InformationUpdates = 10,
            MaxRenderCalls = 1000
        }
    },
    
    Performance = {
        Optimization = {
            Level = 2, -- 1: Max Performance, 2: Balanced, 3: Max Quality
            ESPCulling = true,
            DistanceCulling = true,
            OcclusionCulling = true,
            LODSystem = true,
            RenderBatching = true,
            
            Settings = {
                MaxRenderDistance = 2000,
                MinUpdateRate = 0.1,
                ObjectLimit = 100,
                MemoryLimit = 50 -- MB
            }
        },
        
        Monitoring = {
            ShowPerformance = false,
            LogRenderTimes = false,
            AlertOnLag = true,
            AutoOptimize = true,
            OptimizationThreshold = 30 -- FPS
        }
    }
}

-- ============ SISTEMA DE ESP AVANÇADO ============
local AdvancedESPSystem = {
    Players = {},
    NPCs = {},
    Items = {},
    Vehicles = {},
    WorldObjects = {},
    RenderObjects = {},
    UpdateQueue = {},
    LastUpdate = 0,
    ObjectCount = 0,
    MemoryUsage = 0
}

function AdvancedESPSystem:Initialize()
    print("[AdvancedESPSystem] Initializing...")
    
    self.Players = {
        Active = {},
        Cache = {},
        LastTeamCheck = 0
    }
    
    self.NPCs = {
        Active = {},
        Cache = {}
    }
    
    self.Items = {
        Active = {},
        Categories = {},
        Cache = {}
    }
    
    self.Vehicles = {
        Active = {},
        Cache = {}
    }
    
    self.WorldObjects = {
        Active = {},
        Cache = {}
    }
    
    self.RenderObjects = {
        Lines = {},
        Boxes = {},
        Text = {},
        Circles = {},
        Triangles = {}
    }
    
    self.UpdateQueue = {
        Players = {},
        NPCs = {},
        Items = {},
        Vehicles = {},
        Priority = 1
    }
    
    -- Inicializar sistema de renderização
    self:InitializeRendering()
    
    -- Configurar proteções
    self:InitializeProtections()
    
    print("[AdvancedESPSystem] Initialized with " .. self.ObjectCount .. " initial objects")
    
    return true
end

function AdvancedESPSystem:InitializeRendering()
    -- Sistema de renderização otimizado
    self.RenderEngine = {
        DrawCalls = 0,
        MaxDrawCalls = 1000,
        BatchSize = 50,
        LastOptimization = 0,
        
        CreateLine = function(self, name)
            if VisualPreset.Config.Security.MemoryProtection.LimitESPObjects then
                if self.ObjectCount >= VisualPreset.Config.Security.MemoryProtection.MaxESPObjects then
                    self:CleanupOldest()
                end
            end
            
            local line = {
                Type = "Line",
                Visible = false,
                Color = Color3.new(1, 1, 1),
                Thickness = 1,
                From = Vector2.new(0, 0),
                To = Vector2.new(0, 0),
                Transparency = 1,
                ZIndex = 1,
                Created = tick(),
                LastUpdate = 0
            }
            
            AdvancedESPSystem.RenderObjects.Lines[name] = line
            AdvancedESPSystem.ObjectCount = AdvancedESPSystem.ObjectCount + 1
            
            return line
        end,
        
        CreateBox = function(self, name)
            if VisualPreset.Config.Security.MemoryProtection.LimitESPObjects then
                if self.ObjectCount >= VisualPreset.Config.Security.MemoryProtection.MaxESPObjects then
                    self:CleanupOldest()
                end
            end
            
            local box = {
                Type = "Box",
                Visible = false,
                Color = Color3.new(1, 1, 1),
                Thickness = 1,
                Filled = false,
                FillColor = Color3.new(0, 0, 0),
                FillTransparency = 0.5,
                Position = Vector2.new(0, 0),
                Size = Vector2.new(0, 0),
                Transparency = 1,
                ZIndex = 1,
                Created = tick(),
                LastUpdate = 0
            }
            
            AdvancedESPSystem.RenderObjects.Boxes[name] = box
            AdvancedESPSystem.ObjectCount = AdvancedESPSystem.ObjectCount + 1
            
            return box
        end,
        
        CreateText = function(self, name)
            if VisualPreset.Config.Security.MemoryProtection.LimitESPObjects then
                if self.ObjectCount >= VisualPreset.Config.Security.MemoryProtection.MaxESPObjects then
                    self:CleanupOldest()
                end
            end
            
            local text = {
                Type = "Text",
                Visible = false,
                Text = "",
                Color = Color3.new(1, 1, 1),
                Size = 14,
                Font = 2,
                Position = Vector2.new(0, 0),
                Center = false,
                Outline = true,
                OutlineColor = Color3.new(0, 0, 0),
                Transparency = 1,
                ZIndex = 2,
                Created = tick(),
                LastUpdate = 0
            }
            
            AdvancedESPSystem.RenderObjects.Text[name] = text
            AdvancedESPSystem.ObjectCount = AdvancedESPSystem.ObjectCount + 1
            
            return text
        end,
        
        CreateCircle = function(self, name)
            if VisualPreset.Config.Security.MemoryProtection.LimitESPObjects then
                if self.ObjectCount >= VisualPreset.Config.Security.MemoryProtection.MaxESPObjects then
                    self:CleanupOldest()
                end
            end
            
            local circle = {
                Type = "Circle",
                Visible = false,
                Color = Color3.new(1, 1, 1),
                Thickness = 1,
                Filled = false,
                FillColor = Color3.new(0, 0, 0),
                FillTransparency = 0.5,
                Position = Vector2.new(0, 0),
                Radius = 10,
                Transparency = 1,
                ZIndex = 1,
                Created = tick(),
                LastUpdate = 0
            }
            
            AdvancedESPSystem.RenderObjects.Circles[name] = circle
            AdvancedESPSystem.ObjectCount = AdvancedESPSystem.ObjectCount + 1
            
            return circle
        end,
        
        CleanupOldest = function(self)
            local oldestTime = math.huge
            local oldestKey = nil
            local oldestType = nil
            
            -- Procurar objeto mais antigo
            for name, line in pairs(AdvancedESPSystem.RenderObjects.Lines) do
                if line.Created < oldestTime then
                    oldestTime = line.Created
                    oldestKey = name
                    oldestType = "Lines"
                end
            end
            
            for name, box in pairs(AdvancedESPSystem.RenderObjects.Boxes) do
                if box.Created < oldestTime then
                    oldestTime = box.Created
                    oldestKey = name
                    oldestType = "Boxes"
                end
            end
            
            for name, text in pairs(AdvancedESPSystem.RenderObjects.Text) do
                if text.Created < oldestTime then
                    oldestTime = text.Created
                    oldestKey = name
                    oldestType = "Text"
                end
            end
            
            for name, circle in pairs(AdvancedESPSystem.RenderObjects.Circles) do
                if circle.Created < oldestTime then
                    oldestTime = circle.Created
                    oldestKey = name
                    oldestType = "Circles"
                end
            end
            
            -- Remover objeto mais antigo
            if oldestKey and oldestType then
                AdvancedESPSystem.RenderObjects[oldestType][oldestKey] = nil
                AdvancedESPSystem.ObjectCount = AdvancedESPSystem.ObjectCount - 1
                VisualPreset:LogEvent("ESP_CLEANUP", "Removed old object: " .. oldestKey)
            end
        end,
        
        Optimize = function(self)
            local currentTime = tick()
            
            -- Otimizar apenas periodicamente
            if currentTime - self.LastOptimization < 5 then
                return
            end
            
            self.LastOptimization = currentTime
            
            -- Limpar objetos invisíveis antigos
            local cleanupThreshold = 30 -- segundos
            local removed = 0
            
            for typeName, objects in pairs(AdvancedESPSystem.RenderObjects) do
                local toRemove = {}
                for name, obj in pairs(objects) do
                    if not obj.Visible and currentTime - obj.LastUpdate > cleanupThreshold then
                        table.insert(toRemove, name)
                    end
                end
                
                for _, name in ipairs(toRemove) do
                    objects[name] = nil
                    AdvancedESPSystem.ObjectCount = AdvancedESPSystem.ObjectCount - 1
                    removed = removed + 1
                end
            end
            
            if removed > 0 then
                VisualPreset:LogEvent("ESP_OPTIMIZATION", "Removed " .. removed .. " inactive objects")
            end
            
            -- Otimizar memória
            if VisualPreset.Config.Performance.Optimization.LODSystem then
                self:ApplyLODOptimization()
            end
        end,
        
        ApplyLODOptimization = function(self)
            -- Level of Detail baseado em distância
            local camera = workspace.CurrentCamera
            if not camera then return end
            
            local localPlayer = game:GetService("Players").LocalPlayer
            local localCharacter = localPlayer.Character
            local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
            
            if not localRoot then return end
            
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local distance = (root.Position - localRoot.Position).Magnitude
                        local espName = "Player_" .. player.Name
                        
                        -- Ajustar detalhes baseado na distância
                        if distance > 1000 then
                            -- LOD baixo
                            local text = AdvancedESPSystem.RenderObjects.Text[espName .. "_Name"]
                            if text then
                                text.Size = math.max(8, text.Size * 0.7)
                            end
                        elseif distance > 500 then
                            -- LOD médio
                            local text = AdvancedESPSystem.RenderObjects.Text[espName .. "_Name"]
                            if text then
                                text.Size = math.max(10, text.Size * 0.8)
                            end
                        end
                        -- LOD alto (distância próxima) mantém tamanho original
                    end
                end
            end
        end,
        
        GetMemoryUsage = function(self)
            local total = 0
            local counts = {
                Lines = 0,
                Boxes = 0,
                Text = 0,
                Circles = 0
            }
            
            for typeName, objects in pairs(AdvancedESPSystem.RenderObjects) do
                counts[typeName] = counts[typeName] + #objects
                total = total + #objects
            end
            
            -- Estimativa de memória (aproximada)
            local memoryEstimate = total * 0.1 -- ~0.1 KB por objeto
            
            return {
                TotalObjects = total,
                MemoryKB = memoryEstimate,
                Counts = counts
            }
        end
    }
    
    self.ObjectCount = 0
    self.LastUpdate = tick()
    
    print("[AdvancedESPSystem] Render engine initialized")
end

function AdvancedESPSystem:InitializeProtections()
    self.ProtectionSystem = {
        DetectionCount = 0,
        LastDetection = 0,
        SafetyMeasures = {},
        
        CheckSafety = function(self, action)
            -- Verificar se há detecção recente
            local currentTime = tick()
            if self.DetectionCount > 0 and currentTime - self.LastDetection < 60 then
                VisualPreset:LogSecurityEvent("SAFETY_CHECK_FAILED", 
                    "Recent detection, blocking: " .. action)
                return false
            end
            
            -- Verificar rate limiting
            local rateLimit = VisualPreset.Config.Security.RateLimiting.ESPUpdates
            if AdvancedESPSystem.UpdateRate > rateLimit * 1.5 then
                self:RecordDetection("RATE_LIMIT", "ESP updates too high: " .. AdvancedESPSystem.UpdateRate)
                return false
            end
            
            return true
        end,
        
        RecordDetection = function(self, type, details)
            self.DetectionCount = self.DetectionCount + 1
            self.LastDetection = tick()
            
            VisualPreset.State.DetectionCount = VisualPreset.State.DetectionCount + 1
            VisualPreset:LogSecurityEvent("ESP_DETECTION", type .. ": " .. details)
            
            -- Resposta automática
            if self.DetectionCount >= VisualPreset.Config.Security.AntiDetection.DetectionResponse.DisableThreshold then
                self:ActivateEmergencyResponse()
            end
            
            return true
        end,
        
        ActivateEmergencyResponse = function(self)
            local response = VisualPreset.Config.Security.AntiDetection.DetectionResponse.EmergencyMode
            
            VisualPreset:LogSecurityEvent("EMERGENCY_RESPONSE", 
                "Activating: " .. response .. " (Detections: " .. self.DetectionCount .. ")")
            
            if response == "REDUCE" then
                -- Reduzir detalhes do ESP
                VisualPreset.Config.ESP.Players.Information.ShowName = false
                VisualPreset.Config.ESP.Players.Information.ShowDistance = false
                VisualPreset.Config.ESP.Players.Tracers.Enabled = false
                VisualPreset.Config.ESP.Players.HealthBar.Enabled = false
                
                -- Limitar distância
                VisualPreset.Config.ESP.Players.MaxDistance = 500
                
                VisualPreset:LogEvent("ESP_REDUCED", "Reduced ESP details for safety")
                
            elseif response == "DISABLE" then
                -- Desativar ESP completamente
                VisualPreset.Config.ESP.MasterSwitch = false
                self:DisableAllESP()
                
                VisualPreset:LogEvent("ESP_DISABLED", "ESP disabled for safety")
                
            elseif response == "FAKE_DISABLE" then
                -- Fingir desativação (mantém funcionalidade)
                VisualPreset.Config.ESP.Players.BoxStyle.Transparency = 0.9
                VisualPreset.Config.ESP.Players.Information.TextSize = 8
                VisualPreset.Config.Effects.MasterSwitch = false
                
                VisualPreset:LogEvent("ESP_FAKE_DISABLED", "ESP appears disabled but is active")
            end
            
            -- Programar recuperação
            spawn(function()
                wait(VisualPreset.Config.Security.AntiDetection.DetectionResponse.RecoveryTime)
                self.DetectionCount = 0
                VisualPreset:LogEvent("SAFETY_RECOVERED", "Safety measures lifted")
            end)
            
            return true
        end,
        
        DisableAllESP = function(self)
            -- Ocultar todos os objetos de renderização
            for _, objects in pairs(AdvancedESPSystem.RenderObjects) do
                for _, obj in pairs(objects) do
                    obj.Visible = false
                end
            end
            
            -- Limpar caches
            AdvancedESPSystem.Players.Active = {}
            AdvancedESPSystem.NPCs.Active = {}
            AdvancedESPSystem.Items.Active = {}
            AdvancedESPSystem.Vehicles.Active = {}
            
            VisualPreset:LogEvent("ESP_CLEARED", "All ESP objects cleared")
        end,
        
        GetStatus = function(self)
            return {
                DetectionCount = self.DetectionCount,
                LastDetection = self.LastDetection,
                SafetyActive = self.DetectionCount > 0
            }
        end
    }
    
    print("[AdvancedESPSystem] Protection system initialized")
end

function AdvancedESPSystem:UpdatePlayerESP(player)
    if not VisualPreset.Config.ESP.Players.Enabled then
        return false
    end
    
    local currentTime = tick()
    local config = VisualPreset.Config.ESP.Players
    
    -- Verificar segurança
    if not self.ProtectionSystem:CheckSafety("UpdatePlayerESP") then
        return false
    end
    
    local localPlayer = game:GetService("Players").LocalPlayer
    if player == localPlayer then
        return false
    end
    
    local character = player.Character
    if not character then
        self:RemovePlayerESP(player)
        return false
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or humanoid.Health <= 0 then
        self:RemovePlayerESP(player)
        return false
    end
    
    -- Verificar distância
    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then
        return false
    end
    
    local distance = (rootPart.Position - localRoot.Position).Magnitude
    if distance > config.MaxDistance then
        self:HidePlayerESP(player)
        return false
    end
    
    -- Verificar oclusão
    if config.SecurityLevel >= 2 then
        local camera = workspace.CurrentCamera
        local origin = camera.CFrame.Position
        local direction = (rootPart.Position - origin).Unit
        local ray = Ray.new(origin, direction * distance)
        local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, character})
        
        if hit and not hit:IsDescendantOf(character) then
            -- Jogador está atrás de algo
            if config.ESPProtection.OcclusionCheck then
                self:HidePlayerESP(player)
                return false
            end
        end
    end
    
    -- Calcular posição na tela
    local camera = workspace.CurrentCamera
    local screenPosition, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    
    if not onScreen then
        self:HidePlayerESP(player)
        return false
    end
    
    -- Configurações baseadas no time
    local teamConfig = config.TeamSettings.Neutral
    local localTeam = localPlayer.Team
    local playerTeam = player.Team
    
    if localTeam and playerTeam then
        if localTeam == playerTeam then
            teamConfig = config.TeamSettings.Allies
        else
            teamConfig = config.TeamSettings.Enemies
        end
    end
    
    -- Criar/atualizar objetos ESP
    local espName = "Player_" .. player.Name
    self:UpdatePlayerBox(espName, character, screenPosition, teamConfig, distance)
    self:UpdatePlayerInfo(espName, player, character, humanoid, screenPosition, teamConfig, distance)
    self:UpdatePlayerTracer(espName, screenPosition, teamConfig)
    self:UpdatePlayerHealthBar(espName, humanoid, screenPosition, teamConfig)
    
    if config.Skeleton.Enabled then
        self:UpdatePlayerSkeleton(espName, character, teamConfig)
    end
    
    -- Atualizar cache
    self.Players.Active[player.Name] = {
        Player = player,
        Character = character,
        LastUpdate = currentTime,
        Distance = distance,
        OnScreen = onScreen
    }
    
    return true
end

function AdvancedESPSystem:UpdatePlayerBox(espName, character, screenPosition, teamConfig, distance)
    local config = VisualPreset.Config.ESP.Players.BoxStyle
    
    -- Calcular tamanho da caixa baseado no personagem
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if not head or not root then
        return
    end
    
    local camera = workspace.CurrentCamera
    local headPos = camera:WorldToViewportPoint(head.Position)
    local rootPos = screenPosition
    
    local height = math.abs(headPos.Y - rootPos.Y) * 1.5
    local width = height * 0.6
    
    local boxPosition = Vector2.new(
        screenPosition.X - width / 2,
        screenPosition.Y - height / 2
    )
    
    -- Aplicar fade na distância
    local transparency = config.Transparency
    if VisualPreset.Config.Security.AntiDetection.ESPProtection.FadeAtDistance then
        local maxDistance = VisualPreset.Config.ESP.Players.MaxDistance
        transparency = transparency + (distance / maxDistance) * 0.5
        transparency = math.min(transparency, 0.9)
    end
    
    -- Criar ou atualizar caixa
    local box = self.RenderObjects.Boxes[espName .. "_Box"]
    if not box then
        box = self.RenderEngine:CreateBox(espName .. "_Box")
    end
    
    box.Visible = true
    box.Position = boxPosition
    box.Size = Vector2.new(width, height)
    box.Color = teamConfig.BoxColor
    box.Thickness = config.Thickness
    box.Filled = config.Type == "FILLED"
    box.FillColor = teamConfig.BoxColor
    box.FillTransparency = transparency
    box.Transparency = transparency
    box.LastUpdate = tick()
    
    -- Adicionar cantos se configurado
    if config.Type == "CORNER" then
        self:UpdateCornerBox(espName, boxPosition, Vector2.new(width, height), teamConfig.BoxColor, config)
    end
end

function AdvancedESPSystem:UpdateCornerBox(espName, position, size, color, config)
    local cornerSize = config.CornerSize
    local thickness = config.Thickness
    
    -- Canto superior esquerdo
    self:UpdateCornerLine(espName .. "_Corner_TL1", 
        position, 
        position + Vector2.new(cornerSize, 0),
        color, thickness)
    
    self:UpdateCornerLine(espName .. "_Corner_TL2", 
        position, 
        position + Vector2.new(0, cornerSize),
        color, thickness)
    
    -- Canto superior direito
    self:UpdateCornerLine(espName .. "_Corner_TR1",
        position + Vector2.new(size.X, 0),
        position + Vector2.new(size.X - cornerSize, 0),
        color, thickness)
    
    self:UpdateCornerLine(espName .. "_Corner_TR2",
        position + Vector2.new(size.X, 0),
        position + Vector2.new(size.X, cornerSize),
        color, thickness)
    
    -- Canto inferior esquerdo
    self:UpdateCornerLine(espName .. "_Corner_BL1",
        position + Vector2.new(0, size.Y),
        position + Vector2.new(cornerSize, size.Y),
        color, thickness)
    
    self:UpdateCornerLine(espName .. "_Corner_BL2",
        position + Vector2.new(0, size.Y),
        position + Vector2.new(0, size.Y - cornerSize),
        color, thickness)
    
    -- Canto inferior direito
    self:UpdateCornerLine(espName .. "_Corner_BR1",
        position + size,
        position + Vector2.new(size.X - cornerSize, size.Y),
        color, thickness)
    
    self:UpdateCornerLine(espName .. "_Corner_BR2",
        position + size,
        position + Vector2.new(size.X, size.Y - cornerSize),
        color, thickness)
end

function AdvancedESPSystem:UpdateCornerLine(name, from, to, color, thickness)
    local line = self.RenderObjects.Lines[name]
    if not line then
        line = self.RenderEngine:CreateLine(name)
    end
    
    line.Visible = true
    line.From = from
    line.To = to
    line.Color = color
    line.Thickness = thickness
    line.LastUpdate = tick()
end

function AdvancedESPSystem:UpdatePlayerInfo(espName, player, character, humanoid, screenPosition, teamConfig, distance)
    if not teamConfig.ShowInfo then
        return
    end
    
    local config = VisualPreset.Config.ESP.Players.Information
    local infoLines = {}
    
    -- Nome
    if config.ShowName then
        local name = player.Name
        if config.MaxTextLength > 0 and #name > config.MaxTextLength then
            name = string.sub(name, 1, config.MaxTextLength) .. "..."
        end
        table.insert(infoLines, name)
    end
    
    -- Distância
    if config.ShowDistance then
        table.insert(infoLines, string.format("%.1fm", distance))
    end
    
    -- Saúde
    if config.ShowHealth and humanoid then
        local health = math.floor(humanoid.Health)
        local maxHealth = math.floor(humanoid.MaxHealth)
        table.insert(infoLines, string.format("%d/%d HP", health, maxHealth))
    end
    
    -- Arma
    if config.ShowWeapon then
        local weapon = "No Weapon"
        local rightHand = character:FindFirstChild("RightHand")
        if rightHand then
            local tool = rightHand:FindFirstChildOfClass("Tool")
            if tool then
                weapon = tool.Name
            end
        end
        table.insert(infoLines, weapon)
    end
    
    -- Texto customizado
    if config.CustomText ~= "" then
        table.insert(infoLines, config.CustomText)
    end
    
    -- Criar/atualizar textos
    for i, line in ipairs(infoLines) do
        local textName = espName .. "_Info_" .. i
        local text = self.RenderObjects.Text[textName]
        
        if not text then
            text = self.RenderEngine:CreateText(textName)
        end
        
        local yOffset = (i - 1) * (config.TextSize + 2)
        local textPosition = Vector2.new(
            screenPosition.X,
            screenPosition.Y - VisualPreset.Config.ESP.Players.BoxStyle.CornerSize - yOffset - 5
        )
        
        text.Visible = true
        text.Text = line
        text.Color = teamConfig.TextColor
        text.Size = config.TextSize
        text.Font = config.TextFont
        text.Position = textPosition
        text.Center = true
        text.Outline = config.TextOutline
        text.OutlineColor = Color3.new(0, 0, 0)
        text.LastUpdate = tick()
    end
end

function AdvancedESPSystem:UpdatePlayerTracer(espName, screenPosition, teamConfig)
    if not VisualPreset.Config.ESP.Players.Tracers.Enabled then
        return
    end
    
    local config = VisualPreset.Config.ESP.Players.Tracers
    local screenSize = workspace.CurrentCamera.ViewportSize
    
    -- Determinar cor
    local color = teamConfig.BoxColor
    if config.ColorMode == "CUSTOM" then
        color = config.CustomColor
    end
    
    -- Determinar origem
    local origin = Vector2.new(screenSize.X / 2, screenSize.Y)
    if config.Origin == "MIDDLE" then
        origin = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    elseif config.Origin == "CURSOR" then
        local mouse = game:GetService("Players").LocalPlayer:GetMouse()
        origin = Vector2.new(mouse.X, mouse.Y)
    end
    
    -- Criar/atualizar tracer
    local tracer = self.RenderObjects.Lines[espName .. "_Tracer"]
    if not tracer then
        tracer = self.RenderEngine:CreateLine(espName .. "_Tracer")
    end
    
    tracer.Visible = true
    tracer.From = origin
    tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
    tracer.Color = color
    tracer.Thickness = config.Thickness
    tracer.Transparency = config.Transparency
    tracer.LastUpdate = tick()
end

function AdvancedESPSystem:UpdatePlayerHealthBar(espName, humanoid, screenPosition, teamConfig)
    if not VisualPreset.Config.ESP.Players.HealthBar.Enabled then
        return
    end
    
    local config = VisualPreset.Config.ESP.Players.HealthBar
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    healthPercent = math.max(0, math.min(1, healthPercent))
    
    -- Calcular posição e tamanho
    local boxConfig = VisualPreset.Config.ESP.Players.BoxStyle
    local head = humanoid.Parent:FindFirstChild("Head")
    local camera = workspace.CurrentCamera
    
    if not head then
        return
    end
    
    local headPos = camera:WorldToViewportPoint(head.Position)
    local rootPos = screenPosition
    
    local height = math.abs(headPos.Y - rootPos.Y) * 1.5
    local width = height * 0.6
    local barWidth = config.Width
    
    local boxPosition = Vector2.new(
        screenPosition.X - width / 2,
        screenPosition.Y - height / 2
    )
    
    -- Posição da barra de saúde
    local barPosition = boxPosition
    local barSize = Vector2.new(barWidth, height * healthPercent)
    
    if config.Position == "RIGHT" then
        barPosition = Vector2.new(boxPosition.X + width, boxPosition.Y + height * (1 - healthPercent))
        barSize = Vector2.new(barWidth, height * healthPercent)
    elseif config.Position == "BOTTOM" then
        barPosition = Vector2.new(boxPosition.X, boxPosition.Y + height)
        barSize = Vector2.new(width * healthPercent, barWidth)
    elseif config.Position == "TOP" then
        barPosition = boxPosition
        barSize = Vector2.new(width * healthPercent, barWidth)
    else -- LEFT (padrão)
        barPosition = Vector2.new(boxPosition.X - barWidth, boxPosition.Y + height * (1 - healthPercent))
        barSize = Vector2.new(barWidth, height * healthPercent)
    end
    
    -- Determinar cor
    local barColor = config.FullColor
    if config.Gradient then
        barColor = Color3.new(
            config.EmptyColor.R + (config.FullColor.R - config.EmptyColor.R) * healthPercent,
            config.EmptyColor.G + (config.FullColor.G - config.EmptyColor.G) * healthPercent,
            config.EmptyColor.B + (config.FullColor.B - config.EmptyColor.B) * healthPercent
        )
    end
    
    -- Criar/atualizar barra de saúde
    local healthBar = self.RenderObjects.Boxes[espName .. "_HealthBar"]
    if not healthBar then
        healthBar = self.RenderEngine:CreateBox(espName .. "_HealthBar")
    end
    
    healthBar.Visible = true
    healthBar.Position = barPosition
    healthBar.Size = barSize
    healthBar.Color = barColor
    healthBar.Filled = true
    healthBar.FillColor = barColor
    healthBar.FillTransparency = 0.3
    healthBar.Transparency = 0.3
    healthBar.LastUpdate = tick()
    
    -- Texto da saúde
    if config.ShowText then
        local healthText = self.RenderObjects.Text[espName .. "_HealthText"]
        if not healthText then
            healthText = self.RenderEngine:CreateText(espName .. "_HealthText")
        end
        
        local healthValue = math.floor(humanoid.Health)
        local maxHealth = math.floor(humanoid.MaxHealth)
        
        healthText.Visible = true
        healthText.Text = string.format("%d/%d", healthValue, maxHealth)
        healthText.Color = Color3.new(1, 1, 1)
        healthText.Size = 10
        healthText.Position = barPosition + Vector2.new(barWidth + 2, barSize.Y / 2)
        healthText.Center = false
        healthText.LastUpdate = tick()
    end
end

function AdvancedESPSystem:UpdatePlayerSkeleton(espName, character, teamConfig)
    local config = VisualPreset.Config.ESP.Players.Skeleton
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
    
    local camera = workspace.CurrentCamera
    
    for i, connection in ipairs(connections) do
        local joint1 = joints[connection[1]]
        local joint2 = joints[connection[2]]
        
        if joint1 and joint2 then
            local pos1, visible1 = camera:WorldToViewportPoint(joint1.Position)
            local pos2, visible2 = camera:WorldToViewportPoint(joint2.Position)
            
            if visible1 and visible2 then
                local lineName = espName .. "_Skeleton_" .. connection[1] .. "_" .. connection[2]
                local line = self.RenderObjects.Lines[lineName]
                
                if not line then
                    line = self.RenderEngine:CreateLine(lineName)
                end
                
                line.Visible = true
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Color = config.Color
                line.Thickness = config.Thickness
                line.Transparency = config.Transparency
                line.LastUpdate = tick()
            end
        end
    end
    
    -- Pontos das juntas
    if config.ShowJoints then
        for jointName, joint in pairs(joints) do
            if joint then
                local pos, visible = camera:WorldToViewportPoint(joint.Position)
                
                if visible then
                    local circleName = espName .. "_Joint_" .. jointName
                    local circle = self.RenderObjects.Circles[circleName]
                    
                    if not circle then
                        circle = self.RenderEngine:CreateCircle(circleName)
                    end
                    
                    circle.Visible = true
                    circle.Position = Vector2.new(pos.X, pos.Y)
                    circle.Radius = 2
                    circle.Color = config.Color
                    circle.Thickness = 1
                    circle.Filled = true
                    circle.FillColor = config.Color
                    circle.FillTransparency = 0.5
                    circle.Transparency = 0.5
                    circle.LastUpdate = tick()
                end
            end
        end
    end
end

function AdvancedESPSystem:HidePlayerESP(player)
    local espName = "Player_" .. player.Name
    
    -- Ocultar todos os objetos deste jogador
    for _, objects in pairs(self.RenderObjects) do
        for name, obj in pairs(objects) do
            if string.find(name, espName) then
                obj.Visible = false
            end
        end
    end
    
    -- Remover do cache ativo
    self.Players.Active[player.Name] = nil
end

function AdvancedESPSystem:RemovePlayerESP(player)
    self:HidePlayerESP(player)
    
    -- Remover completamente do sistema
    local espName = "Player_" .. player.Name
    
    for typeName, objects in pairs(self.RenderObjects) do
        local toRemove = {}
        for name, _ in pairs(objects) do
            if string.find(name, espName) then
                table.insert(toRemove, name)
            end
        end
        
        for _, name in ipairs(toRemove) do
            objects[name] = nil
            self.ObjectCount = self.ObjectCount - 1
        end
    end
    
    VisualPreset:LogEvent("ESP_REMOVED", "Removed ESP for: " .. player.Name)
end

function AdvancedESPSystem:UpdateAllESP()
    if not VisualPreset.Config.ESP.MasterSwitch then
        return
    end
    
    local currentTime = tick()
    
    -- Rate limiting
    local timeSinceLastUpdate = currentTime - self.LastUpdate
    local minUpdateRate = VisualPreset.Config.Security.AntiDetection.ESPProtection.MinUpdateRate or 0.05
    local maxUpdateRate = VisualPreset.Config.Security.AntiDetection.ESPProtection.MaxUpdateRate or 0.2
    
    if VisualPreset.Config.Security.AntiDetection.ESPProtection.RandomizeUpdateRate then
        local targetRate = math.random() * (maxUpdateRate - minUpdateRate) + minUpdateRate
        if timeSinceLastUpdate < targetRate then
            return
        end
    else
        if timeSinceLastUpdate < (1 / VisualPreset.Config.Security.RateLimiting.ESPUpdates) then
            return
        end
    end
    
    self.LastUpdate = currentTime
    
    -- Atualizar jogadores
    local players = game:GetService("Players"):GetPlayers()
    for _, player in ipairs(players) do
        self:UpdatePlayerESP(player)
    end
    
    -- Atualizar NPCs
    if VisualPreset.Config.ESP.NPCs.Enabled then
        self:UpdateNPCs()
    end
    
    -- Atualizar itens
    if VisualPreset.Config.ESP.Items.Enabled then
        self:UpdateItems()
    end
    
    -- Atualizar veículos
    if VisualPreset.Config.ESP.Vehicles.Enabled then
        self:UpdateVehicles()
    end
    
    -- Otimizar renderização
    self.RenderEngine:Optimize()
    
    -- Atualizar métricas
    self.UpdateRate = 1 / timeSinceLastUpdate
    self.MemoryUsage = self.RenderEngine:GetMemoryUsage().MemoryKB
end

function AdvancedESPSystem:UpdateNPCs()
    -- Implementar atualização de NPCs
    -- Similar aos jogadores, mas para NPCs do jogo
end

function AdvancedESPSystem:UpdateItems()
    -- Implementar atualização de itens
    -- Categorizar e mostrar itens do jogo
end

function AdvancedESPSystem:UpdateVehicles()
    -- Implementar atualização de veículos
end

function AdvancedESPSystem:GetStatistics()
    local memoryInfo = self.RenderEngine:GetMemoryUsage()
    local protectionStatus = self.ProtectionSystem:GetStatus()
    
    return {
        Objects = {
            Total = self.ObjectCount,
            Active = #self.Players.Active,
            MemoryKB = memoryInfo.MemoryKB,
            Counts = memoryInfo.Counts
        },
        Performance = {
            UpdateRate = self.UpdateRate or 0,
            LastUpdate = self.LastUpdate,
            RenderCalls = self.RenderEngine.DrawCalls
        },
        Security = {
            DetectionCount = protectionStatus.DetectionCount,
            SafetyActive = protectionStatus.SafetyActive,
            LastDetection = protectionStatus.LastDetection
        },
        Players = {
            Total = #game:GetService("Players"):GetPlayers(),
            WithESP = #self.Players.Active
        }
    }
end

-- ============ SISTEMA DE TRAJETÓRIAS ============
local TrajectorySystem = {
    ActiveTrajectories = {},
    PredictionCache = {},
    LastPrediction = 0,
    RenderObjects = {}
}

function TrajectorySystem:Initialize()
    print("[TrajectorySystem] Initializing...")
    
    self.ActiveTrajectories = {
        Bullets = {},
        Grenades = {},
        Throwables = {},
        Custom = {}
    }
    
    self.PredictionCache = {}
    self.RenderObjects = {
        Lines = {},
        Dots = {},
        Circles = {}
    }
    
    -- Inicializar renderização
    self:InitializeRendering()
    
    print("[TrajectorySystem] Initialized")
    
    return true
end

function TrajectorySystem:InitializeRendering()
    self.RenderEngine = {
        CreateTrajectoryLine = function(self, name)
            local line = {
                Type = "TrajectoryLine",
                Visible = false,
                Points = {},
                Color = Color3.new(1, 1, 1),
                Thickness = 2,
                Transparency = 0.7,
                Lifetime = 0,
                Created = tick()
            }
            
            TrajectorySystem.RenderObjects.Lines[name] = line
            return line
        end,
        
        CreatePredictionDot = function(self, name)
            local dot = {
                Type = "PredictionDot",
                Visible = false,
                Position = Vector2.new(0, 0),
                Color = Color3.new(1, 0, 0),
                Size = 4,
                Transparency = 0.8,
                Lifetime = 0,
                Created = tick()
            }
            
            TrajectorySystem.RenderObjects.Dots[name] = dot
            return dot
        end,
        
        CreateImpactCircle = function(self, name)
            local circle = {
                Type = "ImpactCircle",
                Visible = false,
                Position = Vector2.new(0, 0),
                Color = Color3.new(1, 0.5, 0),
                Radius = 20,
                Thickness = 2,
                Transparency = 0.6,
                Lifetime = 0,
                Created = tick()
            }
            
            TrajectorySystem.RenderObjects.Circles[name] = circle
            return circle
        end,
        
        Update = function(self)
            local currentTime = tick()
            local toRemove = {}
            
            -- Atualizar linhas
            for name, line in pairs(TrajectorySystem.RenderObjects.Lines) do
                if line.Lifetime > 0 then
                    line.Lifetime = line.Lifetime - (currentTime - line.LastUpdate)
                    if line.Lifetime <= 0 then
                        table.insert(toRemove, {type = "Lines", name = name})
                    else
                        line.Transparency = line.Lifetime / line.Created
                    end
                    line.LastUpdate = currentTime
                end
            end
            
            -- Atualizar dots
            for name, dot in pairs(TrajectorySystem.RenderObjects.Dots) do
                if dot.Lifetime > 0 then
                    dot.Lifetime = dot.Lifetime - (currentTime - dot.LastUpdate)
                    if dot.Lifetime <= 0 then
                        table.insert(toRemove, {type = "Dots", name = name})
                    else
                        dot.Transparency = dot.Lifetime / dot.Created
                    end
                    dot.LastUpdate = currentTime
                end
            end
            
            -- Atualizar círculos
            for name, circle in pairs(TrajectorySystem.RenderObjects.Circles) do
                if circle.Lifetime > 0 then
                    circle.Lifetime = circle.Lifetime - (currentTime - circle.LastUpdate)
                    if circle.Lifetime <= 0 then
                        table.insert(toRemove, {type = "Circles", name = name})
                    else
                        circle.Transparency = circle.Lifetime / circle.Created
                    end
                    circle.LastUpdate = currentTime
                end
            end
            
            -- Remover objetos expirados
            for _, removal in ipairs(toRemove) do
                TrajectorySystem.RenderObjects[removal.type][removal.name] = nil
            end
        end
    }
end

function TrajectorySystem:PredictBulletTrajectory(origin, direction, velocity, gravity, time)
    if not VisualPreset.Config.Trajectories.BulletTrajectory.Enabled then
        return nil
    end
    
    local config = VisualPreset.Config.Trajectories.BulletTrajectory
    local points = {}
    
    local currentPos = origin
    local currentVel = direction * velocity
    local stepTime = time / config.PredictionTime
    
    for i = 1, config.PredictionTime / stepTime do
        -- Aplicar gravidade
        currentVel = currentVel + Vector3.new(0, -gravity * stepTime, 0)
        
        -- Atualizar posição
        currentPos = currentPos + (currentVel * stepTime)
        
        -- Verificar colisão
        local ray = Ray.new(currentPos - (currentVel * stepTime), currentVel * stepTime)
        local hit, hitPos = workspace:FindPartOnRay(ray)
        
        if hit then
            table.insert(points, hitPos)
            break
        end
        
        table.insert(points, currentPos)
    end
    
    return points
end

function TrajectorySystem:RenderTrajectory(points, color, thickness, lifetime)
    local lineName = "Trajectory_" .. tostring(math.random(10000, 99999))
    local line = self.RenderEngine:CreateTrajectoryLine(lineName)
    
    line.Visible = true
    line.Points = points
    line.Color = color
    line.Thickness = thickness
    line.Lifetime = lifetime
    line.LastUpdate = tick()
    
    -- Renderizar pontos
    if #points > 0 then
        local dotName = "PredictionDot_" .. tostring(math.random(10000, 99999))
        local dot = self.RenderEngine:CreatePredictionDot(dotName)
        
        local lastPoint = points[#points]
        local camera = workspace.CurrentCamera
        local screenPos = camera:WorldToViewportPoint(lastPoint)
        
        dot.Visible = true
        dot.Position = Vector2.new(screenPos.X, screenPos.Y)
        dot.Color = Color3.new(1, 0, 0)
        dot.Lifetime = lifetime
        dot.LastUpdate = tick()
    end
    
    return lineName
end

function TrajectorySystem:Update()
    if not VisualPreset.Config.Trajectories.Enabled then
        return
    end
    
    local currentTime = tick()
    
    -- Rate limiting
    if currentTime - self.LastPrediction < 0.1 then
        return
    end
    
    self.LastPrediction = currentTime
    
    -- Atualizar renderização
    self.RenderEngine:Update()
    
    -- Prever trajetórias de projéteis
    if VisualPreset.Config.Trajectories.BulletTrajectory.Enabled then
        self:PredictActiveBullets()
    end
    
    -- Prever trajetórias de granadas
    if VisualPreset.Config.Trajectories.GrenadeTrajectory.Enabled then
        self:PredictActiveGrenades()
    end
end

function TrajectorySystem:PredictActiveBullets()
    -- Implementar detecção de projéteis ativos
    -- Esta é uma implementação simplificada
end

function TrajectorySystem:PredictActiveGrenades()
    -- Implementar detecção de granadas ativas
    -- Esta é uma implementação simplificada
end

-- ============ SISTEMA DE SEGURANÇA VISUAL ============
local VisualSecuritySystem = {
    DetectionHistory = {},
    SafetyMeasures = {},
    LastSafetyCheck = 0,
    EmergencyMode = false
}

function VisualSecuritySystem:Initialize()
    print("[VisualSecuritySystem] Initializing...")
    
    self.DetectionHistory = {
        ESP = {},
        Trajectories = {},
        Information = {},
        Overlay = {}
    }
    
    self.SafetyMeasures = {
        PatternDetection = {
            MaxPatternLength = 5,
            PatternThreshold = 3,
            BreakMethod = "RANDOM_DELAY"
        },
        
        BehaviorAnalysis = {
            MonitorUpdateRates = true,
            UpdateRateThreshold = 100, -- updates por segundo
            Response = "THROTTLE"
        },
        
        MemoryProtection = {
            MaxObjects = 500,
            CleanupThreshold = 100,
            AutoCleanup = true
        }
    }
    
    print("[VisualSecuritySystem] Initialized")
    
    return true
end

function VisualSecuritySystem:CheckSafety()
    local currentTime = tick()
    
    -- Verificar periodicamente
    if currentTime - self.LastSafetyCheck < 10 then
        return true
    end
    
    self.LastSafetyCheck = currentTime
    
    -- Verificar padrões detectáveis
    local patterns = self:DetectPatterns()
    if #patterns > 0 then
        for _, pattern in ipairs(patterns) do
            VisualPreset:LogSecurityEvent("PATTERN_DETECTED", pattern)
        end
        return false
    end
    
    -- Verificar uso de memória
    local memoryInfo = AdvancedESPSystem.RenderEngine:GetMemoryUsage()
    if memoryInfo.TotalObjects > self.SafetyMeasures.MemoryProtection.MaxObjects then
        VisualPreset:LogSecurityEvent("MEMORY_OVERFLOW", 
            "Objects: " .. memoryInfo.TotalObjects .. "/" .. self.SafetyMeasures.MemoryProtection.MaxObjects)
        return false
    end
    
    -- Verificar taxas de atualização
    if self.SafetyMeasures.BehaviorAnalysis.MonitorUpdateRates then
        if AdvancedESPSystem.UpdateRate and 
           AdvancedESPSystem.UpdateRate > self.SafetyMeasures.BehaviorAnalysis.UpdateRateThreshold then
            VisualPreset:LogSecurityEvent("HIGH_UPDATE_RATE", 
                "Rate: " .. AdvancedESPSystem.UpdateRate .. "/s")
            return false
        end
    end
    
    return true
end

function VisualSecuritySystem:DetectPatterns()
    local patterns = {}
    
    -- Verificar padrões de ESP
    local espPatterns = self:AnalyzeESPPatterns()
    for _, pattern in ipairs(espPatterns) do
        table.insert(patterns, "ESP: " .. pattern)
    end
    
    -- Verificar padrões de trajetória
    local trajectoryPatterns = self:AnalyzeTrajectoryPatterns()
    for _, pattern in ipairs(trajectoryPatterns) do
        table.insert(patterns, "Trajectory: " .. pattern)
    end
    
    return patterns
end

function VisualSecuritySystem:AnalyzeESPPatterns()
    local patterns = {}
    
    -- Verificar atualizações muito regulares
    if AdvancedESPSystem.LastUpdate then
        local updateHistory = {}
        for i = 1, 10 do
            -- Coletar histórico de atualizações (simulado)
            table.insert(updateHistory, tick())
        end
        
        -- Verificar variação mínima
        local minVariation = math.huge
        for i = 2, #updateHistory do
            local variation = updateHistory[i] - updateHistory[i-1]
            minVariation = math.min(minVariation, variation)
        end
        
        if minVariation < 0.001 then -- Variação muito pequena
            table.insert(patterns, "Regular ESP updates")
        end
    end
    
    return patterns
end

function VisualSecuritySystem:AnalyzeTrajectoryPatterns()
    local patterns = {}
    
    -- Verificar muitas trajetórias simultâneas
    local activeCount = 0
    for _, trajectories in pairs(TrajectorySystem.ActiveTrajectories) do
        activeCount = activeCount + #trajectories
    end
    
    if activeCount > 10 then
        table.insert(patterns, "Too many active trajectories: " .. activeCount)
    end
    
    return patterns
end

function VisualSecuritySystem:ActivateEmergencyMode(reason)
    if self.EmergencyMode then
        return
    end
    
    self.EmergencyMode = true
    VisualPreset:LogSecurityEvent("EMERGENCY_MODE_ACTIVATED", reason)
    
    -- Reduzir configurações visuais
    VisualPreset.Config.ESP.MasterSwitch = false
    VisualPreset.Config.Trajectories.Enabled = false
    VisualPreset.Config.Information.MasterSwitch = false
    VisualPreset.Config.Overlay.Enabled = false
    
    -- Limpar objetos
    AdvancedESPSystem.ProtectionSystem:DisableAllESP()
    
    -- Programar recuperação
    spawn(function()
        wait(60) -- 1 minuto
        self.EmergencyMode = false
        VisualPreset:LogEvent("EMERGENCY_MODE_DEACTIVATED", "Safety period ended")
    end)
end

-- ============ FUNÇÕES PRINCIPAIS DO PRESET ============
function VisualPreset:Initialize()
    print("[VisualPreset] Initializing Visual Preset v" .. self.Version .. "...")
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Inicializar sistemas
    AdvancedESPSystem:Initialize()
    TrajectorySystem:Initialize()
    VisualSecuritySystem:Initialize()
    
    -- Iniciar loops de atualização
    self:StartUpdateLoops()
    
    self.State.Initialized = true
    self.State.Active = true
    
    print("[VisualPreset] Initialization complete")
    print("[VisualPreset] ESP System: " .. (self.Config.ESP.MasterSwitch and "ENABLED" or "DISABLED"))
    print("[VisualPreset] Security Level: " .. self.Config.ESP.SecurityLevel)
    
    return true
end

function VisualPreset:StartUpdateLoops()
    -- Loop de atualização do ESP
    task.spawn(function()
        while self.State.Active do
            AdvancedESPSystem:UpdateAllESP()
            
            -- Rate limiting adaptativo
            local delay = 0.05
            if self.Config.Security.AntiDetection.ESPProtection.RandomizeUpdateRate then
                delay = math.random(
                    self.Config.Security.AntiDetection.ESPProtection.MinUpdateRate * 1000,
                    self.Config.Security.AntiDetection.ESPProtection.MaxUpdateRate * 1000
                ) / 1000
            end
            
            wait(delay)
        end
    end)
    
    -- Loop de atualização de trajetórias
    task.spawn(function()
        while self.State.Active do
            TrajectorySystem:Update()
            wait(0.1)
        end
    end)
    
    -- Loop de verificação de segurança
    task.spawn(function()
        while self.State.Active do
            if not VisualSecuritySystem:CheckSafety() then
                VisualSecuritySystem:ActivateEmergencyMode("Safety check failed")
            end
            wait(5)
        end
    end)
end

function VisualPreset:Enable()
    if not self.State.Initialized then
        self:Initialize()
    end
    
    self.State.Active = true
    self.Config.ESP.MasterSwitch = true
    
    print("[VisualPreset] Visual Preset enabled")
    return true
end

function VisualPreset:Disable()
    self.State.Active = false
    self.Config.ESP.MasterSwitch = false
    
    -- Limpar todos os objetos visuais
    AdvancedESPSystem.ProtectionSystem:DisableAllESP()
    
    print("[VisualPreset] Visual Preset disabled")
    return true
end

function VisualPreset:Toggle()
    if self.State.Active then
        return self:Disable()
    else
        return self:Enable()
    end
end

function VisualPreset:UpdateConfig(newConfig)
    for category, settings in pairs(newConfig) do
        if self.Config[category] then
            for key, value in pairs(settings) do
                self.Config[category][key] = value
            end
        end
    end
    
    print("[VisualPreset] Configuration updated")
    return true
end

function VisualPreset:GetStatistics()
    local espStats = AdvancedESPSystem:GetStatistics()
    local securityStatus = VisualSecuritySystem.EmergencyMode and "EMERGENCY" or "NORMAL"
    
    return {
        Status = {
            Active = self.State.Active,
            Security = securityStatus,
            DetectionCount = self.State.DetectionCount
        },
        ESP = espStats,
        Memory = {
            UsageMB = espStats.Objects.MemoryKB / 1024,
            Objects = espStats.Objects.Total,
            Players = espStats.Players.WithESP
        },
        Performance = {
            FPS = game:GetService("Stats").Workspace:GetRealPhysicsFPS(),
            Ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"] or 0
        }
    }
end

function VisualPreset:LogEvent(eventType, details)
    local event = {
        Type = eventType,
        Details = details,
        Timestamp = os.time(),
        Preset = "Visual"
    }
    
    print("[VisualPreset]", eventType, "-", details)
    
    -- Registrar no sistema principal se disponível
    if _G.NexusOS and _G.NexusOS.Logger then
        _G.NexusOS.Logger:Log("INFO", eventType .. ": " .. details, "VisualPreset")
    end
end

function VisualPreset:LogSecurityEvent(eventType, details)
    self.State.SecurityEvents = self.State.SecurityEvents + 1
    
    local event = {
        Type = eventType,
        Details = details,
        Timestamp = os.time(),
        Preset = "Visual",
        SecurityLevel = "HIGH"
    }
    
    print("[VisualPreset Security]", eventType, "-", details)
    
    -- Registrar no sistema de segurança se disponível
    if _G.NexusCrypto then
        _G.NexusCrypto:LogSecurityEvent("VISUAL_" .. eventType, details)
    end
end

function VisualPreset:Shutdown()
    print("[VisualPreset] Shutting down...")
    
    self:Disable()
    
    -- Limpar todos os sistemas
    AdvancedESPSystem = {
        Players = {},
        NPCs = {},
        Items = {},
        Vehicles = {},
        WorldObjects = {},
        RenderObjects = {},
        UpdateQueue = {},
        LastUpdate = 0,
        ObjectCount = 0,
        MemoryUsage = 0
    }
    
    TrajectorySystem = {
        ActiveTrajectories = {},
        PredictionCache = {},
        LastPrediction = 0,
        RenderObjects = {}
    }
    
    VisualSecuritySystem = {
        DetectionHistory = {},
        SafetyMeasures = {},
        LastSafetyCheck = 0,
        EmergencyMode = false
    }
    
    self.State.Initialized = false
    self.State.Active = false
    
    print("[VisualPreset] Shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusPresets then
    _G.NexusPresets = {}
end

_G.NexusPresets.Visual = VisualPreset

return VisualPreset
