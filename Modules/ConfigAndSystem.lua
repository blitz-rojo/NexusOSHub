-- =============================================
-- NEXUS OS - CONFIG AND SYSTEM MODULE
-- Arquivo: ConfigAndSystem.lua
-- Local: src/Modules/ConfigAndSystem.lua
-- =============================================

local ConfigAndSystem = {
    Name = "ConfigAndSystem",
    Version = "3.0.0",
    Description = "Sistema de configuração e gerenciamento do Nexus OS",
    Author = "Nexus Team",
    
    Features = {},
    Config = {},
    State = {
        Enabled = false,
        ActiveFeatures = {},
        Configurations = {},
        Themes = {},
        Plugins = {},
        PerformanceData = {}
    },
    
    Dependencies = {"StateManager", "Crypto"}
}

-- ============ CONFIGURAÇÕES PADRÃO ============
ConfigAndSystem.DefaultConfig = {
    System = {
        AutoSave = true,
        SaveInterval = 60,
        AutoBackup = true,
        MaxBackups = 10,
        UpdateCheck = true,
        UpdateInterval = 3600,
        Language = "en-US",
        Region = "US",
        Timezone = "UTC-3"
    },
    UI = {
        Scale = 1,
        Opacity = 0.95,
        Animations = true,
        AnimationSpeed = 1,
        NotificationDuration = 5,
        Tooltips = true,
        Watermark = true,
        WatermarkPosition = "TopRight",
        WatermarkText = "Nexus OS v18.0"
    },
    Security = {
        EncryptConfig = true,
        EncryptKey = "NEXUS_OS_SECURE_KEY_2024",
        AutoLock = false,
        LockTimeout = 300,
        RequirePassword = false,
        PasswordHash = "",
        SessionTimeout = 86400
    },
    Performance = {
        MonitorEnabled = true,
        MonitorInterval = 5,
        LogPerformance = true,
        MaxLogSize = 1000,
        AutoOptimize = false,
        OptimizationLevel = 2,
        MemoryWarning = 500,
        FPSWarning = 30
    },
    Modules = {
        AutoLoad = {
            PhysicsAndMovement = false,
            VisualDebugger = false,
            AutomationAndInteraction = false,
            PlayerAndUtility = false,
            ConfigAndSystem = true
        },
        LoadOrder = {
            "ConfigAndSystem",
            "PhysicsAndMovement",
            "VisualDebugger",
            "AutomationAndInteraction",
            "PlayerAndUtility"
        },
        UpdateCheck = true
    }
}

-- ============ SISTEMA DE CONFIGURAÇÃO ============
local ConfigurationSystem = {
    Configs = {},
    CurrentConfig = "default",
    ConfigPath = "NexusOS/Configs/",
    BackupPath = "NexusOS/Backups/",
    DefaultConfig = {}
}

function ConfigurationSystem:CreateConfig(name, basedOn)
    if self.Configs[name] then
        return false, "Config already exists"
    end
    
    local baseConfig = basedOn and self.Configs[basedOn] or ConfigAndSystem.DefaultConfig
    
    if not baseConfig then
        baseConfig = ConfigAndSystem.DefaultConfig
    end
    
    -- Deep copy da configuração base
    local newConfig = game:GetService("HttpService"):JSONDecode(
        game:GetService("HttpService"):JSONEncode(baseConfig)
    )
    
    -- Adicionar metadados
    newConfig.Metadata = {
        Created = os.time(),
        Modified = os.time(),
        Version = ConfigAndSystem.Version,
        Author = game:GetService("Players").LocalPlayer.Name,
        BasedOn = basedOn or "default"
    }
    
    self.Configs[name] = newConfig
    
    -- Salvar em arquivo
    self:SaveConfig(name)
    
    return true, newConfig
end

function ConfigurationSystem:SaveConfig(configName)
    local config = self.Configs[configName]
    if not config then
        return false, "Config not found"
    end
    
    -- Atualizar metadados
    config.Metadata.Modified = os.time()
    config.Metadata.Version = ConfigAndSystem.Version
    
    -- Serializar para JSON
    local jsonData = game:GetService("HttpService"):JSONEncode(config)
    
    -- Criptografar se necessário
    if ConfigAndSystem.Config.Security.EncryptConfig then
        if _G.NexusOS and _G.NexusOS.Crypto then
            jsonData = _G.NexusOS.Crypto:Encrypt(jsonData)
        end
    end
    
    -- Garantir que o diretório existe
    if not isfolder(self.ConfigPath) then
        makefolder(self.ConfigPath)
    end
    
    -- Salvar arquivo
    local filePath = self.ConfigPath .. configName .. ".json"
    pcall(writefile, filePath, jsonData)
    
    -- Criar backup se configurado
    if ConfigAndSystem.Config.System.AutoBackup then
        self:CreateBackup(configName)
    end
    
    return true, filePath
end

function ConfigurationSystem:LoadConfig(configName)
    local filePath = self.ConfigPath .. configName .. ".json"
    
    local success, fileData = pcall(readfile, filePath)
    if not success then
        return false, "Config file not found"
    end
    
    -- Descriptografar se necessário
    if ConfigAndSystem.Config.Security.EncryptConfig then
        if _G.NexusOS and _G.NexusOS.Crypto then
            local success, decrypted = pcall(_G.NexusOS.Crypto.Decrypt, _G.NexusOS.Crypto, fileData)
            if success then
                fileData = decrypted
            end
        end
    end
    
    local success, config = pcall(game:GetService("HttpService").JSONDecode, 
        game:GetService("HttpService"), fileData)
    
    if not success then
        return false, "Invalid config file"
    end
    
    self.Configs[configName] = config
    self.CurrentConfig = configName
    
    -- Aplicar configuração
    ConfigAndSystem.Config = config
    
    return true, config
end

function ConfigurationSystem:DeleteConfig(configName)
    if not self.Configs[configName] then
        return false, "Config not found"
    end
    
    -- Remover do cache
    self.Configs[configName] = nil
    
    -- Remover arquivo
    local filePath = self.ConfigPath .. configName .. ".json"
    pcall(delfile, filePath)
    
    -- Se era a configuração atual, carregar default
    if self.CurrentConfig == configName then
        self.CurrentConfig = "default"
        self:LoadConfig("default")
    end
    
    return true
end

function ConfigurationSystem:ListConfigs()
    local configs = {}
    
    for name, config in pairs(self.Configs) do
        table.insert(configs, {
            Name = name,
            Created = config.Metadata and config.Metadata.Created or 0,
            Modified = config.Metadata and config.Metadata.Modified or 0,
            Version = config.Metadata and config.Metadata.Version or "Unknown",
            Size = #game:GetService("HttpService"):JSONEncode(config)
        })
    end
    
    return configs
end

function ConfigurationSystem:CreateBackup(configName)
    if not ConfigAndSystem.Config.System.AutoBackup then
        return false
    end
    
    local config = self.Configs[configName]
    if not config then
        return false, "Config not found"
    end
    
    -- Garantir diretório de backups
    if not isfolder(self.BackupPath) then
        makefolder(self.BackupPath)
    end
    
    -- Nome do backup com timestamp
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupName = configName .. "_backup_" .. timestamp
    
    -- Copiar configuração
    local backupConfig = game:GetService("HttpService"):JSONDecode(
        game:GetService("HttpService"):JSONEncode(config)
    )
    
    -- Adicionar metadados de backup
    backupConfig.Metadata = backupConfig.Metadata or {}
    backupConfig.Metadata.BackupDate = timestamp
    backupConfig.Metadata.OriginalConfig = configName
    
    -- Salvar backup
    local backupPath = self.BackupPath .. backupName .. ".json"
    local jsonData = game:GetService("HttpService"):JSONEncode(backupConfig)
    pcall(writefile, backupPath, jsonData)
    
    -- Limitar número de backups
    self:CleanupBackups(configName)
    
    return true, backupPath
end

function ConfigurationSystem:CleanupBackups(configName)
    local maxBackups = ConfigAndSystem.Config.System.MaxBackups
    local backups = {}
    
    -- Listar todos os arquivos no diretório de backups
    -- Nota: Esta é uma implementação simulada
    print("[ConfigSystem] CleanupBackups: Backup cleanup simulated")
    
    return true
end

-- ============ SISTEMA DE TEMAS ============
local ThemeSystem = {
    Themes = {},
    CurrentTheme = "Dark",
    DefaultThemes = {
        Dark = {
            Name = "Dark",
            Background = Color3.fromRGB(25, 25, 25),
            Foreground = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(240, 240, 240),
            Accent = Color3.fromRGB(52, 152, 219),
            Success = Color3.fromRGB(46, 204, 113),
            Warning = Color3.fromRGB(241, 196, 15),
            Error = Color3.fromRGB(231, 76, 60),
            Border = Color3.fromRGB(60, 60, 60),
            Shadow = Color3.fromRGB(0, 0, 0, 0.5)
        },
        Light = {
            Name = "Light",
            Background = Color3.fromRGB(240, 240, 240),
            Foreground = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(30, 30, 30),
            Accent = Color3.fromRGB(41, 128, 185),
            Success = Color3.fromRGB(39, 174, 96),
            Warning = Color3.fromRGB(230, 126, 34),
            Error = Color3.fromRGB(192, 57, 43),
            Border = Color3.fromRGB(200, 200, 200),
            Shadow = Color3.fromRGB(0, 0, 0, 0.2)
        },
        Blue = {
            Name = "Blue",
            Background = Color3.fromRGB(15, 30, 50),
            Foreground = Color3.fromRGB(25, 45, 70),
            Text = Color3.fromRGB(220, 230, 255),
            Accent = Color3.fromRGB(86, 152, 255),
            Success = Color3.fromRGB(72, 219, 176),
            Warning = Color3.fromRGB(255, 193, 86),
            Error = Color3.fromRGB(255, 96, 122),
            Border = Color3.fromRGB(40, 65, 100),
            Shadow = Color3.fromRGB(0, 10, 30, 0.6)
        },
        Green = {
            Name = "Green",
            Background = Color3.fromRGB(20, 40, 20),
            Foreground = Color3.fromRGB(30, 60, 30),
            Text = Color3.fromRGB(220, 255, 220),
            Accent = Color3.fromRGB(72, 219, 176),
            Success = Color3.fromRGB(46, 204, 113),
            Warning = Color3.fromRGB(241, 196, 15),
            Error = Color3.fromRGB(231, 76, 60),
            Border = Color3.fromRGB(50, 90, 50),
            Shadow = Color3.fromRGB(0, 20, 0, 0.5)
        }
    }
}

function ThemeSystem:LoadThemes()
    -- Carregar temas padrão
    for name, theme in pairs(self.DefaultThemes) do
        self.Themes[name] = theme
    end
    
    -- Carregar temas personalizados do diretório
    local themesPath = "NexusOS/Themes/"
    
    if isfolder(themesPath) then
        -- Implementação simulada - em produção, carregaria arquivos JSON
        print("[ThemeSystem] Loading custom themes from:", themesPath)
    end
    
    return true
end

function ThemeSystem:GetTheme(themeName)
    return self.Themes[themeName] or self.Themes[self.CurrentTheme]
end

function ThemeSystem:SetTheme(themeName)
    if not self.Themes[themeName] then
        return false, "Theme not found"
    end
    
    self.CurrentTheme = themeName
    
    -- Aplicar tema à UI
    if _G.NexusOS and _G.NexusOS.UI then
        _G.NexusOS.UI:ApplyTheme(self.Themes[themeName])
    end
    
    -- Salvar preferência
    ConfigAndSystem.Config.UI.Theme = themeName
    ConfigurationSystem:SaveConfig(ConfigurationSystem.CurrentConfig)
    
    return true
end

function ThemeSystem:CreateTheme(name, baseTheme, customizations)
    if self.Themes[name] then
        return false, "Theme already exists"
    end
    
    local base = baseTheme and self.Themes[baseTheme] or self.Themes["Dark"]
    if not base then
        return false, "Base theme not found"
    end
    
    -- Criar novo tema baseado no tema base
    local newTheme = game:GetService("HttpService"):JSONDecode(
        game:GetService("HttpService"):JSONEncode(base)
    )
    
    newTheme.Name = name
    
    -- Aplicar customizações
    if customizations then
        for key, value in pairs(customizations) do
            if newTheme[key] ~= nil then
                newTheme[key] = value
            end
        end
    end
    
    self.Themes[name] = newTheme
    
    -- Salvar tema em arquivo
    self:SaveTheme(name)
    
    return true, newTheme
end

function ThemeSystem:SaveTheme(themeName)
    local theme = self.Themes[themeName]
    if not theme then
        return false, "Theme not found"
    end
    
    local themesPath = "NexusOS/Themes/"
    if not isfolder(themesPath) then
        makefolder(themesPath)
    end
    
    local filePath = themesPath .. themeName .. ".json"
    local jsonData = game:GetService("HttpService"):JSONEncode(theme)
    
    pcall(writefile, filePath, jsonData)
    
    return true, filePath
end

-- ============ SISTEMA DE PERFORMANCE ============
local PerformanceSystem = {
    Metrics = {
        FPS = 0,
        Memory = 0,
        Ping = 0,
        CPU = 0,
        GPU = 0
    },
    History = {
        FPS = {},
        Memory = {},
        Ping = {}
    },
    Alerts = {},
    LastAlert = 0
}

function PerformanceSystem:StartMonitoring()
    -- Monitorar FPS
    task.spawn(function()
        while ConfigAndSystem.State.Enabled do
            local frames = 0
            local startTime = tick()
            
            while tick() - startTime < 1 do
                frames = frames + 1
                task.wait()
            end
            
            self.Metrics.FPS = frames
            table.insert(self.History.FPS, frames)
            
            -- Limitar histórico
            if #self.History.FPS > 100 then
                table.remove(self.History.FPS, 1)
            end
            
            -- Verificar alerta de FPS baixo
            if ConfigAndSystem.Config.Performance.FPSWarning > 0 and frames < ConfigAndSystem.Config.Performance.FPSWarning then
                self:AddAlert("LOW_FPS", string.format("FPS is low: %d", frames))
            end
        end
    end)
    
    -- Monitorar memória
    task.spawn(function()
        while ConfigAndSystem.State.Enabled do
            local stats = game:GetService("Stats")
            local memory = stats:GetTotalMemoryUsageMb()
            
            self.Metrics.Memory = memory
            table.insert(self.History.Memory, memory)
            
            -- Limitar histórico
            if #self.History.Memory > 100 then
                table.remove(self.History.Memory, 1)
            end
            
            -- Verificar alerta de memória alta
            if ConfigAndSystem.Config.Performance.MemoryWarning > 0 and memory > ConfigAndSystem.Config.Performance.MemoryWarning then
                self:AddAlert("HIGH_MEMORY", string.format("High memory usage: %.2f MB", memory))
            end
            
            task.wait(5)
        end
    end)
    
    -- Monitorar ping
    task.spawn(function()
        while ConfigAndSystem.State.Enabled do
            local stats = game:GetService("Stats")
            local network = stats.Network
            
            if network then
                self.Metrics.Ping = network.ServerStatsItem["Data Ping"] or 0
                table.insert(self.History.Ping, self.Metrics.Ping)
                
                -- Limitar histórico
                if #self.History.Ping > 100 then
                    table.remove(self.History.Ping, 1)
                end
            end
            
            task.wait(2)
        end
    end)
end

function PerformanceSystem:AddAlert(type, message)
    local currentTime = os.time()
    
    -- Evitar alertas muito frequentes
    if currentTime - self.LastAlert < 30 then
        return
    end
    
    local alert = {
        Type = type,
        Message = message,
        Timestamp = currentTime,
        Level = "WARNING"
    }
    
    table.insert(self.Alerts, alert)
    self.LastAlert = currentTime
    
    -- Limitar número de alertas
    if #self.Alerts > 50 then
        table.remove(self.Alerts, 1)
    end
    
    -- Notificar usuário
    if _G.NexusOS and _G.NexusOS.NotificationSystem then
        _G.NexusOS.NotificationSystem:Notify({
            Title = "Performance Alert",
            Text = message,
            Duration = 5,
            Type = "WARNING"
        })
    end
end

function PerformanceSystem:GetAverage(metric)
    local history = self.History[metric]
    if not history or #history == 0 then
        return 0
    end
    
    local total = 0
    for _, value in ipairs(history) do
        total = total + value
    end
    
    return total / #history
end

function PerformanceSystem:GetReport()
    return {
        Current = self.Metrics,
        Averages = {
            FPS = self:GetAverage("FPS"),
            Memory = self:GetAverage("Memory"),
            Ping = self:GetAverage("Ping")
        },
        Alerts = self.Alerts,
        HistorySize = {
            FPS = #self.History.FPS,
            Memory = #self.History.Memory,
            Ping = #self.History.Ping
        }
    }
end

-- ============ FEATURE 1: CONFIG MANAGER ============
ConfigAndSystem.Features[1] = {
    Name = "Config Manager",
    Description = "Gerencia configurações do sistema",
    Category = "System",
    DefaultKeybind = "F1",
    
    Activate = function()
        -- Inicializar sistema de configuração
        ConfigurationSystem.DefaultConfig = ConfigAndSystem.DefaultConfig
        
        -- Carregar configuração padrão
        local success, err = ConfigurationSystem:LoadConfig("default")
        if not success then
            -- Criar configuração padrão
            ConfigurationSystem:CreateConfig("default")
            ConfigurationSystem:LoadConfig("default")
        end
        
        -- Iniciar auto-save se configurado
        if ConfigAndSystem.Config.System.AutoSave then
            ConfigAndSystem:StartAutoSave()
        end
        
        ConfigAndSystem.State.ActiveFeatures[1] = {
            ConfigSystem = ConfigurationSystem,
            LastSave = os.time()
        }
        
        return true
    end,
    
    Deactivate = function()
        local feature = ConfigAndSystem.State.ActiveFeatures[1]
        if not feature then
            return false
        end
        
        -- Parar auto-save
        ConfigAndSystem:StopAutoSave()
        
        -- Salvar configuração atual
        ConfigurationSystem:SaveConfig(ConfigurationSystem.CurrentConfig)
        
        ConfigAndSystem.State.ActiveFeatures[1] = nil
        
        return true
    end
}

-- ============ FEATURE 2: THEME MANAGER ============
ConfigAndSystem.Features[2] = {
    Name = "Theme Manager",
    Description = "Gerencia temas da interface",
    Category = "UI",
    DefaultKeybind = "F2",
    
    Activate = function()
        -- Carregar temas
        ThemeSystem:LoadThemes()
        
        -- Aplicar tema configurado
        local themeName = ConfigAndSystem.Config.UI.Theme or "Dark"
        ThemeSystem:SetTheme(themeName)
        
        ConfigAndSystem.State.ActiveFeatures[2] = {
            ThemeSystem = ThemeSystem,
            CurrentTheme = themeName
        }
        
        return true
    end,
    
    Deactivate = function()
        local feature = ConfigAndSystem.State.ActiveFeatures[2]
        if not feature then
            return false
        end
        
        ConfigAndSystem.State.ActiveFeatures[2] = nil
        
        return true
    end
}

-- ============ FEATURE 3: PERFORMANCE MONITOR ============
ConfigAndSystem.Features[3] = {
    Name = "Performance Monitor",
    Description = "Monitora performance do sistema",
    Category = "Performance",
    DefaultKeybind = "F3",
    
    Activate = function()
        if not ConfigAndSystem.Config.Performance.MonitorEnabled then
            return false, "Performance monitor disabled"
        end
        
        -- Iniciar monitoramento
        PerformanceSystem:StartMonitoring()
        
        -- Loop de log de performance
        if ConfigAndSystem.Config.Performance.LogPerformance then
            local logConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local currentTime = os.time()
                local lastLog = ConfigAndSystem.State.PerformanceData.LastLog or 0
                local interval = ConfigAndSystem.Config.Performance.MonitorInterval
                
                if currentTime - lastLog >= interval then
                    local report = PerformanceSystem:GetReport()
                    
                    -- Armazenar dados
                    table.insert(ConfigAndSystem.State.PerformanceData, {
                        Timestamp = currentTime,
                        FPS = report.Current.FPS,
                        Memory = report.Current.Memory,
                        Ping = report.Current.Ping
                    })
                    
                    -- Limitar tamanho do log
                    if #ConfigAndSystem.State.PerformanceData > ConfigAndSystem.Config.Performance.MaxLogSize then
                        table.remove(ConfigAndSystem.State.PerformanceData, 1)
                    end
                    
                    ConfigAndSystem.State.PerformanceData.LastLog = currentTime
                end
            end)
            
            ConfigAndSystem.State.ActiveFeatures[3] = {
                PerformanceSystem = PerformanceSystem,
                LogConnection = logConnection
            }
        else
            ConfigAndSystem.State.ActiveFeatures[3] = {
                PerformanceSystem = PerformanceSystem
            }
        end
        
        return true
    end,
    
    Deactivate = function()
        local feature = ConfigAndSystem.State.ActiveFeatures[3]
        if not feature then
            return false
        end
        
        -- Desconectar
        if feature.LogConnection then
            feature.LogConnection:Disconnect()
        end
        
        ConfigAndSystem.State.ActiveFeatures[3] = nil
        
        return true
    end
}

-- ============ FUNÇÕES AUXILIARES DO MÓDULO ============
function ConfigAndSystem:StartAutoSave()
    if self.AutoSaveThread then
        return false, "AutoSave already running"
    end
    
    self.AutoSaveThread = task.spawn(function()
        while ConfigAndSystem.Config.System.AutoSave do
            task.wait(ConfigAndSystem.Config.System.SaveInterval)
            
            if _G.NexusOS and _G.NexusOS.Logger then
                _G.NexusOS.Logger:Log("INFO", "Auto-saving configuration...", "ConfigAndSystem")
            end
            
            ConfigurationSystem:SaveConfig(ConfigurationSystem.CurrentConfig)
        end
    end)
    
    return true
end

function ConfigAndSystem:StopAutoSave()
    if self.AutoSaveThread then
        task.cancel(self.AutoSaveThread)
        self.AutoSaveThread = nil
        return true
    end
    
    return false
end

function ConfigAndSystem:Initialize()
    print("[ConfigAndSystem] Initializing module...")
    
    -- Carregar configurações padrão
    self.Config = table.clone(self.DefaultConfig)
    
    -- Inicializar sistemas
    ConfigurationSystem.ConfigPath = "NexusOS/Configs/"
    ConfigurationSystem.BackupPath = "NexusOS/Backups/"
    
    -- Preencher features restantes (4-30)
    for i = 4, 30 do
        if not self.Features[i] then
            self.Features[i] = {
                Name = "Config Feature " .. i,
                Description = "Config feature placeholder " .. i,
                Category = "Placeholder",
                Activate = function() 
                    print("Config Feature " .. i .. " activated")
                    return true 
                end,
                Deactivate = function() 
                    print("Config Feature " .. i .. " deactivated")
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
    
    print("[ConfigAndSystem] Module initialized with 30 features")
    
    return true
end

function ConfigAndSystem:EnableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    local feature = self.Features[featureId]
    
    if self.State.ActiveFeatures[featureId] then
        return false, "Feature already active"
    end
    
    local success, err = feature.Activate()
    
    if success then
        print("[ConfigAndSystem] Feature enabled: " .. feature.Name)
        
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

function ConfigAndSystem:DisableFeature(featureId)
    if not self.Features[featureId] then
        return false, "Feature not found"
    end
    
    if not self.State.ActiveFeatures[featureId] then
        return false, "Feature not active"
    end
    
    local feature = self.Features[featureId]
    local success = feature.Deactivate()
    
    if success then
        print("[ConfigAndSystem] Feature disabled: " .. feature.Name)
        
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

function ConfigAndSystem:ToggleFeature(featureId)
    if self.State.ActiveFeatures[featureId] then
        return self:DisableFeature(featureId)
    else
        return self:EnableFeature(featureId)
    end
end

function ConfigAndSystem:GetFeatureStatus(featureId)
    return {
        Active = self.State.ActiveFeatures[featureId] ~= nil,
        Feature = self.Features[featureId],
        State = self.State.ActiveFeatures[featureId]
    }
end

function ConfigAndSystem:UpdateConfig(newConfig)
    for category, settings in pairs(newConfig) do
        if self.Config[category] then
            for key, value in pairs(settings) do
                self.Config[category][key] = value
            end
        end
    end
    
    -- Salvar configuração
    ConfigurationSystem:SaveConfig(ConfigurationSystem.CurrentConfig)
    
    -- Reaplicar configurações a features ativas
    for featureId, _ in pairs(self.State.ActiveFeatures) do
        self:DisableFeature(featureId)
        self:EnableFeature(featureId)
    end
    
    return true
end

function ConfigAndSystem:Shutdown()
    print("[ConfigAndSystem] Shutting down module...")
    
    -- Desativar todas as features
    for featureId, _ in pairs(self.State.ActiveFeatures) do
        self:DisableFeature(featureId)
    end
    
    -- Parar auto-save
    self:StopAutoSave()
    
    -- Salvar configuração final
    if ConfigurationSystem.CurrentConfig then
        ConfigurationSystem:SaveConfig(ConfigurationSystem.CurrentConfig)
    end
    
    -- Atualizar estado
    if _G.NexusStateManager then
        _G.NexusStateManager:SetStateStatus(self.Name, "INACTIVE")
    end
    
    self.State.Enabled = false
    
    print("[ConfigAndSystem] Module shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusModules then
    _G.NexusModules = {}
end

_G.NexusModules.ConfigAndSystem = ConfigAndSystem

return ConfigAndSystem
