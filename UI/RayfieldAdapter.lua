-- =============================================
-- NEXUS OS - RAYFIELD UI ADAPTER (NO KEY SYSTEM)
-- Arquivo: RayfieldAdapter.lua
-- Local: src/UI/RayfieldAdapter.lua
-- =============================================

local RayfieldAdapter = {
    Name = "RayfieldAdapter",
    Version = "2.1.0", -- Versão atualizada
    Description = "Adaptador para a biblioteca de UI Rayfield (Sem Key System)",
    Author = "Nexus Team",
    
    Config = {},
    State = {
        Initialized = false,
        Window = nil,
        Tabs = {},
        Elements = {},
        Notifications = {},
        CurrentTheme = "Dark",
        MobileMode = false
    },
    
    Dependencies = {"ThemeManager", "NotificationSystem"}
}

-- ============ CONSTANTES E CONFIGURAÇÕES ============
RayfieldAdapter.DefaultConfig = {
    Window = {
        Title = "NEXUS OS v18.0",
        SubTitle = "Advanced Roblox Automation System",
        LoadingTitle = "Initializing Nexus OS...",
        LoadingSubtitle = "Loading modules and services",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "NexusOS",
            FileName = "RayfieldConfig"
        },
        Discord = {
            Enabled = true,
            Invite = "discord.gg/nexusos",
            RememberJoins = true
        },
        KeySystem = false, -- DESATIVADO: Sistema de chave removido
        KeySettings = {
            Title = "Nexus OS Authentication",
            Subtitle = "Enter your license key",
            Note = "Join our Discord for a key",
            FileName = "NexusKey",
            SaveKey = true,
            GrabKeyFromSite = false,
            Key = {"NEXUS-OS-2024", "DEVELOPMENT-KEY"}
        }
    },
    UI = {
        AutoScale = true,
        MinScale = 0.8,
        MaxScale = 1.2,
        DefaultScale = 1,
        AnimationSpeed = 1,
        ButtonHoverEffect = true,
        SliderFillEffect = true,
        RippleEffect = true,
        Watermark = true,
        WatermarkText = "Nexus OS v18.0 | FPS: %d",
        WatermarkPosition = "TopRight"
    },
    Tabs = {
        Main = {
            Name = "Main",
            Icon = "rbxassetid://10723361258",
            Order = 1
        },
        Visuals = {
            Name = "Visuals",
            Icon = "rbxassetid://10723423218",
            Order = 2
        },
        Automation = {
            Name = "Automation",
            Icon = "rbxassetid://10723434567",
            Order = 3
        },
        Player = {
            Name = "Player",
            Icon = "rbxassetid://10723445678",
            Order = 4
        },
        Config = {
            Name = "Configuration",
            Icon = "rbxassetid://10723456789",
            Order = 5
        }
    }
}

-- ============ SISTEMA DE CARREGAMENTO DA RAYFIELD ============
local RayfieldLoader = {
    Rayfield = nil,
    Loaded = false,
    LoadAttempts = 0,
    MaxAttempts = 3
}

function RayfieldLoader:Load()
    if self.Rayfield then
        return self.Rayfield
    end
    
    print("[RayfieldLoader] Loading Rayfield UI library...")
    
    local success, result = pcall(function()
        -- Tentar carregar a Rayfield
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua'))()
    end)
    
    if success then
        self.Rayfield = result
        self.Loaded = true
        print("[RayfieldLoader] Rayfield loaded successfully")
        return self.Rayfield
    else
        print("[RayfieldLoader] Failed to load Rayfield:", result)
        self.LoadAttempts = self.LoadAttempts + 1
        
        if self.LoadAttempts < self.MaxAttempts then
            wait(2)
            return self:Load()
        else
            return nil
        end
    end
end

function RayfieldLoader:Get()
    return self.Rayfield
end

function RayfieldLoader:IsLoaded()
    return self.Loaded and self.Rayfield ~= nil
end

-- ============ SISTEMA DE JANELA ============
local WindowSystem = {
    Window = nil,
    Tabs = {},
    Sections = {},
    Elements = {},
    Watermark = nil,
    WatermarkConnection = nil
}

function WindowSystem:CreateWindow(config)
    local Rayfield = RayfieldLoader:Get()
    if not Rayfield then
        return nil, "Rayfield not loaded"
    end
    
    -- Configuração da janela
    local windowConfig = {
        Name = config.Title or "Nexus OS",
        LoadingTitle = config.LoadingTitle or "Loading...",
        LoadingSubtitle = config.LoadingSubtitle or "Please wait",
        ConfigurationSaving = config.ConfigurationSaving or {
            Enabled = true,
            FolderName = "NexusOS",
            FileName = "Config"
        },
        Discord = config.Discord or {
            Enabled = false,
            Invite = "invite",
            RememberJoins = false
        },
        KeySystem = false, -- GARANTINDO QUE ESTEJA DESATIVADO
        KeySettings = config.KeySettings -- Mantido apenas para evitar erros se a lib exigir a tabela
    }
    
    -- Criar janela
    self.Window = Rayfield:CreateWindow(windowConfig)
    
    -- Configurar watermark se ativado
    if config.Watermark then
        self:CreateWatermark(config.WatermarkText, config.WatermarkPosition)
    end
    
    return self.Window
end

function WindowSystem:CreateWatermark(text, position)
    if not self.Window then
        return
    end
    
    -- Criar watermark (simulado - Rayfield tem watermark interno)
    print("[WindowSystem] Watermark enabled:", text)
    
    -- Atualizar FPS no watermark
    self.WatermarkConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if self.Window and self.Window.Watermark then
            local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
            local watermarkText = string.gsub(text, "%%d", tostring(fps))
            
            -- Atualizar texto do watermark (se a Rayfield permitir)
            -- Esta é uma implementação simulada
        end
    end)
end

function WindowSystem:CreateTab(tabName, tabIcon)
    if not self.Window then
        return nil, "Window not created"
    end
    
    local tab = self.Window:CreateTab(tabName, tabIcon)
    self.Tabs[tabName] = tab
    
    return tab
end

function WindowSystem:GetTab(tabName)
    return self.Tabs[tabName]
end

function WindowSystem:CreateSection(tab, sectionName)
    if not tab then
        return nil, "Tab not found"
    end
    
    local section = tab:CreateSection(sectionName)
    self.Sections[sectionName] = section
    
    return section
end

function WindowSystem:CreateButton(tab, buttonConfig)
    if not tab then
        return nil, "Tab not found"
    end
    
    local button = tab:CreateButton({
        Name = buttonConfig.Name,
        Callback = buttonConfig.Callback
    })
    
    table.insert(self.Elements, button)
    
    return button
end

function WindowSystem:CreateToggle(tab, toggleConfig)
    if not tab then
        return nil, "Tab not found"
    end
    
    local toggle = tab:CreateToggle({
        Name = toggleConfig.Name,
        CurrentValue = toggleConfig.Default or false,
        Callback = toggleConfig.Callback
    })
    
    table.insert(self.Elements, toggle)
    
    return toggle
end

function WindowSystem:CreateSlider(tab, sliderConfig)
    if not tab then
        return nil, "Tab not found"
    end
    
    local slider = tab:CreateSlider({
        Name = sliderConfig.Name,
        Range = sliderConfig.Range or {0, 100},
        Increment = sliderConfig.Increment or 1,
        Suffix = sliderConfig.Suffix or "",
        CurrentValue = sliderConfig.Default or 50,
        Callback = sliderConfig.Callback
    })
    
    table.insert(self.Elements, slider)
    
    return slider
end

function WindowSystem:CreateDropdown(tab, dropdownConfig)
    if not tab then
        return nil, "Tab not found"
    end
    
    local dropdown = tab:CreateDropdown({
        Name = dropdownConfig.Name,
        Options = dropdownConfig.Options or {},
        CurrentOption = dropdownConfig.Default,
        Callback = dropdownConfig.Callback
    })
    
    table.insert(self.Elements, dropdown)
    
    return dropdown
end

function WindowSystem:CreateColorPicker(tab, colorPickerConfig)
    if not tab then
        return nil, "Tab not found"
    end
    
    local colorPicker = tab:CreateColorPicker({
        Name = colorPickerConfig.Name,
        Color = colorPickerConfig.Default or Color3.fromRGB(255, 255, 255),
        Callback = colorPickerConfig.Callback
    })
    
    table.insert(self.Elements, colorPicker)
    
    return colorPicker
end

function WindowSystem:CreateInput(tab, inputConfig)
    if not tab then
        return nil, "Tab not found"
    end
    
    local input = tab:CreateInput({
        Name = inputConfig.Name,
        PlaceholderText = inputConfig.Placeholder or "",
        RemoveTextAfterFocusLost = inputConfig.ClearOnFocusLost or false,
        Callback = inputConfig.Callback
    })
    
    table.insert(self.Elements, input)
    
    return input
end

function WindowSystem:CreateKeybind(tab, keybindConfig)
    if not tab then
        return nil, "Tab not found"
    end
    
    local keybind = tab:CreateKeybind({
        Name = keybindConfig.Name,
        CurrentKeybind = keybindConfig.Default or "F1",
        HoldToInteract = keybindConfig.HoldToInteract or false,
        Callback = keybindConfig.Callback
    })
    
    table.insert(self.Elements, keybind)
    
    return keybind
end

function WindowSystem:CreateLabel(tab, labelConfig)
    if not tab then
        return nil, "Tab not found"
    end
    
    local label = tab:CreateLabel(labelConfig.Text)
    
    table.insert(self.Elements, label)
    
    return label
end

function WindowSystem:CreateParagraph(tab, paragraphConfig)
    if not tab then
        return nil, "Tab not found"
    end
    
    local paragraph = tab:CreateParagraph({
        Title = paragraphConfig.Title,
        Content = paragraphConfig.Content
    })
    
    table.insert(self.Elements, paragraph)
    
    return paragraph
end

function WindowSystem:Destroy()
    if self.WatermarkConnection then
        self.WatermarkConnection:Disconnect()
        self.WatermarkConnection = nil
    end
    
    self.Tabs = {}
    self.Sections = {}
    self.Elements = {}
    
    if self.Window then
        -- A Rayfield não tem método Destroy explícito
        self.Window = nil
    end
end

-- ============ SISTEMA DE INTERFACE DO NEXUS OS ============
local NexusInterface = {
    ModulesUI = {},
    ModuleCallbacks = {},
    ModuleStates = {}
}

function NexusInterface:CreateModuleUI(moduleName, moduleData)
    if not WindowSystem.Window then
        return nil, "Window not created"
    end
    
    -- Determinar tab baseado no módulo
    local tabName = "Main"
    if moduleName == "VisualDebugger" then
        tabName = "Visuals"
    elseif moduleName == "AutomationAndInteraction" then
        tabName = "Automation"
    elseif moduleName == "PlayerAndUtility" then
        tabName = "Player"
    elseif moduleName == "ConfigAndSystem" then
        tabName = "Configuration"
    end
    
    local tab = WindowSystem:GetTab(tabName)
    if not tab then
        tab = WindowSystem:CreateTab(tabName, RayfieldAdapter.Config.Tabs[tabName].Icon)
    end
    
    -- Criar seção para o módulo
    local sectionName = moduleName
    local section = WindowSystem:CreateSection(tab, sectionName)
    
    -- Armazenar referências
    self.ModulesUI[moduleName] = {
        Tab = tab,
        Section = section,
        Elements = {}
    }
    
    -- Criar toggles para cada feature
    if moduleData.Features then
        for featureId, feature in pairs(moduleData.Features) do
            local toggleName = string.format("[%d] %s", featureId, feature.Name)
            
            local toggle = WindowSystem:CreateToggle(tab, {
                Name = toggleName,
                Default = false,
                Callback = function(value)
                    self:OnFeatureToggle(moduleName, featureId, value)
                end
            })
            
            table.insert(self.ModulesUI[moduleName].Elements, toggle)
        end
    end
    
    return self.ModulesUI[moduleName]
end

function NexusInterface:OnFeatureToggle(moduleName, featureId, value)
    print(string.format("[NexusInterface] %s Feature %d: %s", moduleName, featureId, value and "Enabled" or "Disabled"))
    
    -- Chamar callback do módulo
    if self.ModuleCallbacks[moduleName] and self.ModuleCallbacks[moduleName][featureId] then
        local callback = self.ModuleCallbacks[moduleName][featureId]
        callback(value)
    end
    
    -- Atualizar estado
    self.ModuleStates[moduleName] = self.ModuleStates[moduleName] or {}
    self.ModuleStates[moduleName][featureId] = value
    
    -- Notificar sistema
    if value then
        if _G.NexusOS and _G.NexusOS.NotificationSystem then
            _G.NexusOS.NotificationSystem:Notify({
                Title = "Feature Enabled",
                Text = string.format("%s: %s", moduleName, featureId),
                Duration = 2,
                Type = "SUCCESS"
            })
        end
    end
end

function NexusInterface:RegisterModuleCallback(moduleName, featureId, callback)
    self.ModuleCallbacks[moduleName] = self.ModuleCallbacks[moduleName] or {}
    self.ModuleCallbacks[moduleName][featureId] = callback
end

function NexusInterface:UpdateModuleState(moduleName, featureId, state)
    -- Atualizar toggle na UI
    local moduleUI = self.ModulesUI[moduleName]
    if moduleUI and moduleUI.Elements[featureId] then
        -- Esta é uma implementação simulada
        -- Em produção, atualizaria o estado do toggle
    end
    
    self.ModuleStates[moduleName] = self.ModuleStates[moduleName] or {}
    self.ModuleStates[moduleName][featureId] = state
end

function NexusInterface:CreateMainTab()
    local tab = WindowSystem:CreateTab("Main", RayfieldAdapter.Config.Tabs.Main.Icon)
    if not tab then
        return nil
    end
    
    -- Seção de status
    local statusSection = WindowSystem:CreateSection(tab, "System Status")
    
    -- Status do sistema
    WindowSystem:CreateLabel(tab, {
        Text = "Nexus OS v18.0 - Status Panel"
    })
    
    -- Botão de inicialização
    WindowSystem:CreateButton(tab, {
        Name = "Initialize Nexus OS",
        Callback = function()
            if _G.NexusOS then
                _G.NexusOS:Initialize()
            end
        end
    })
    
    -- Botão de desligar
    WindowSystem:CreateButton(tab, {
        Name = "Shutdown Nexus OS",
        Callback = function()
            if _G.NexusOS then
                _G.NexusOS:Shutdown()
            end
        end
    })
    
    -- Toggle de modo mobile
    WindowSystem:CreateToggle(tab, {
        Name = "Mobile Mode",
        Default = RayfieldAdapter.State.MobileMode,
        Callback = function(value)
            RayfieldAdapter.State.MobileMode = value
            RayfieldAdapter:UpdateMobileMode(value)
        end
    })
    
    return tab
end

function NexusInterface:CreateVisualsTab()
    local tab = WindowSystem:CreateTab("Visuals", RayfieldAdapter.Config.Tabs.Visuals.Icon)
    if not tab then
        return nil
    end
    
    -- Seção de ESP
    local espSection = WindowSystem:CreateSection(tab, "ESP Settings")
    
    WindowSystem:CreateToggle(tab, {
        Name = "Enable ESP",
        Default = false,
        Callback = function(value)
            -- Chamar módulo VisualDebugger
            if _G.NexusModules and _G.NexusModules.VisualDebugger then
                if value then
                    _G.NexusModules.VisualDebugger:EnableFeature(1) -- ESP Box
                    _G.NexusModules.VisualDebugger:EnableFeature(2) -- ESP Name
                    _G.NexusModules.VisualDebugger:EnableFeature(3) -- ESP Distance
                else
                    _G.NexusModules.VisualDebugger:DisableFeature(1)
                    _G.NexusModules.VisualDebugger:DisableFeature(2)
                    _G.NexusModules.VisualDebugger:DisableFeature(3)
                end
            end
        end
    })
    
    WindowSystem:CreateColorPicker(tab, {
        Name = "ESP Box Color",
        Default = Color3.fromRGB(0, 255, 0),
        Callback = function(color)
            if _G.NexusModules and _G.NexusModules.VisualDebugger then
                _G.NexusModules.VisualDebugger.Config.ESP.BoxColor = color
            end
        end
    })
    
    -- Seção de câmera
    local cameraSection = WindowSystem:CreateSection(tab, "Camera Controls")
    
    WindowSystem:CreateToggle(tab, {
        Name = "Free Camera",
        Default = false,
        Callback = function(value)
            if _G.NexusModules and _G.NexusModules.VisualDebugger then
                if value then
                    _G.NexusModules.VisualDebugger:EnableFeature(16)
                else
                    _G.NexusModules.VisualDebugger:DisableFeature(16)
                end
            end
        end
    })
    
    WindowSystem:CreateSlider(tab, {
        Name = "Camera Speed",
        Range = {1, 100},
        Increment = 1,
        Suffix = " studs/s",
        Default = 50,
        Callback = function(value)
            if _G.NexusModules and _G.NexusModules.VisualDebugger then
                _G.NexusModules.VisualDebugger.Config.Camera.FreeCamSpeed = value
            end
        end
    })
    
    return tab
end

function NexusInterface:CreateAutomationTab()
    local tab = WindowSystem:CreateTab("Automation", RayfieldAdapter.Config.Tabs.Automation.Icon)
    if not tab then
        return nil
    end
    
    -- Seção de combate
    local combatSection = WindowSystem:CreateSection(tab, "Combat Automation")
    
    WindowSystem:CreateToggle(tab, {
        Name = "Auto Aim",
        Default = false,
        Callback = function(value)
            -- Implementação simulada
            print("Auto Aim:", value)
        end
    })
    
    WindowSystem:CreateSlider(tab, {
        Name = "Aim Smoothness",
        Range = {1, 10},
        Increment = 0.1,
        Suffix = "x",
        Default = 3,
        Callback = function(value)
            print("Aim Smoothness:", value)
        end
    })
    
    -- Seção de farm
    local farmSection = WindowSystem:CreateSection(tab, "Farming Automation")
    
    WindowSystem:CreateToggle(tab, {
        Name = "Auto Farm",
        Default = false,
        Callback = function(value)
            print("Auto Farm:", value)
        end
    })
    
    WindowSystem:CreateDropdown(tab, {
        Name = "Farm Mode",
        Options = {"Coins", "XP", "Items", "All"},
        Default = "Coins",
        Callback = function(option)
            print("Farm Mode:", option)
        end
    })
    
    return tab
end

function NexusInterface:CreatePlayerTab()
    local tab = WindowSystem:CreateTab("Player", RayfieldAdapter.Config.Tabs.Player.Icon)
    if not tab then
        return nil
    end
    
    -- Seção de movimento
    local movementSection = WindowSystem:CreateSection(tab, "Movement")
    
    WindowSystem:CreateToggle(tab, {
        Name = "God Mode",
        Default = false,
        Callback = function(value)
            if _G.NexusModules and _G.NexusModules.PlayerAndUtility then
                if value then
                    _G.NexusModules.PlayerAndUtility:EnableFeature(1)
                else
                    _G.NexusModules.PlayerAndUtility:DisableFeature(1)
                end
            end
        end
    })
    
    WindowSystem:CreateToggle(tab, {
        Name = "Infinite Jump",
        Default = false,
        Callback = function(value)
            if _G.NexusModules and _G.NexusModules.PlayerAndUtility then
                if value then
                    _G.NexusModules.PlayerAndUtility:EnableFeature(2)
                else
                    _G.NexusModules.PlayerAndUtility:DisableFeature(2)
                end
            end
        end
    })
    
    WindowSystem:CreateSlider(tab, {
        Name = "Walk Speed",
        Range = {16, 200},
        Increment = 1,
        Suffix = " studs/s",
        Default = 50,
        Callback = function(value)
            if _G.NexusModules and _G.NexusModules.PhysicsAndMovement then
                _G.NexusModules.PhysicsAndMovement.Config.Speed.WalkSpeed = value
                _G.NexusModules.PhysicsAndMovement.Config.Speed.RunSpeed = value * 2
            end
        end
    })
    
    -- Seção de utilidades
    local utilitySection = WindowSystem:CreateSection(tab, "Utilities")
    
    WindowSystem:CreateToggle(tab, {
        Name = "Anti-AFK",
        Default = false,
        Callback = function(value)
            if _G.NexusModules and _G.NexusModules.PlayerAndUtility then
                if value then
                    _G.NexusModules.PlayerAndUtility:EnableFeature(10)
                else
                    _G.NexusModules.PlayerAndUtility:DisableFeature(10)
                end
            end
        end
    })
    
    WindowSystem:CreateButton(tab, {
        Name = "Save Position",
        Callback = function()
            if _G.NexusModules and _G.NexusModules.PlayerAndUtility then
                _G.NexusModules.PlayerAndUtility:EnableFeature(5)
            end
        end
    })
    
    WindowSystem:CreateButton(tab, {
        Name = "Load Position",
        Callback = function()
            if _G.NexusModules and _G.NexusModules.PlayerAndUtility then
                _G.NexusModules.PlayerAndUtility:EnableFeature(6)
            end
        end
    })
    
    return tab
end

function NexusInterface:CreateConfigTab()
    local tab = WindowSystem:CreateTab("Configuration", RayfieldAdapter.Config.Tabs.Config.Icon)
    if not tab then
        return nil
    end
    
    -- Seção de tema
    local themeSection = WindowSystem:CreateSection(tab, "Theme Settings")
    
    WindowSystem:CreateDropdown(tab, {
        Name = "Theme",
        Options = {"Dark", "Light", "Blue", "Green", "Custom"},
        Default = "Dark",
        Callback = function(option)
            RayfieldAdapter:ApplyTheme(option)
        end
    })
    
    WindowSystem:CreateColorPicker(tab, {
        Name = "Accent Color",
        Default = Color3.fromRGB(52, 152, 219),
        Callback = function(color)
            if _G.NexusOS and _G.NexusOS.ThemeManager then
                _G.NexusOS.ThemeManager:UpdateAccentColor(color)
            end
        end
    })
    
    WindowSystem:CreateSlider(tab, {
        Name = "UI Opacity",
        Range = {0.5, 1},
        Increment = 0.05,
        Suffix = "%",
        Default = 0.95,
        Callback = function(value)
            RayfieldAdapter.Config.UI.Opacity = value
            RayfieldAdapter:UpdateUIOpacity(value)
        end
    })
    
    -- Seção de configurações
    local configSection = WindowSystem:CreateSection(tab, "System Configuration")
    
    WindowSystem:CreateToggle(tab, {
        Name = "Auto Save Config",
        Default = true,
        Callback = function(value)
            RayfieldAdapter.Config.Window.ConfigurationSaving.Enabled = value
        end
    })
    
    WindowSystem:CreateToggle(tab, {
        Name = "Show Watermark",
        Default = true,
        Callback = function(value)
            RayfieldAdapter.Config.UI.Watermark = value
            RayfieldAdapter:UpdateWatermark(value)
        end
    })
    
    WindowSystem:CreateButton(tab, {
        Name = "Save Configuration",
        Callback = function()
            RayfieldAdapter:SaveConfiguration()
        end
    })
    
    WindowSystem:CreateButton(tab, {
        Name = "Load Configuration",
        Callback = function()
            RayfieldAdapter:LoadConfiguration()
        end
    })
    
    WindowSystem:CreateButton(tab, {
        Name = "Reset to Default",
        Callback = function()
            RayfieldAdapter:ResetToDefault()
        end
    })
    
    return tab
end

-- ============ FUNÇÕES PRINCIPAIS DO ADAPTADOR ============
function RayfieldAdapter:LoadRayfield()
    print("[RayfieldAdapter] Loading Rayfield UI...")
    
    -- Carregar biblioteca Rayfield
    local rayfield = RayfieldLoader:Load()
    if not rayfield then
        return false, "Failed to load Rayfield library"
    end
    
    -- Criar janela
    local window = WindowSystem:CreateWindow(self.Config.Window)
    if not window then
        return false, "Failed to create window"
    end
    
    self.State.Window = window
    
    -- Criar abas
    NexusInterface:CreateMainTab()
    NexusInterface:CreateVisualsTab()
    NexusInterface:CreateAutomationTab()
    NexusInterface:CreatePlayerTab()
    NexusInterface:CreateConfigTab()
    
    print("[RayfieldAdapter] UI created successfully")
    
    return true
end

function RayfieldAdapter:ApplyTheme(themeName)
    self.State.CurrentTheme = themeName
    
    -- Aplicar tema ao Rayfield
    if WindowSystem.Window then
        -- A Rayfield tem suporte a temas limitado
        -- Esta é uma implementação simulada
        print("[RayfieldAdapter] Applying theme:", themeName)
    end
    
    -- Aplicar tema ao ThemeManager
    if _G.NexusOS and _G.NexusOS.ThemeManager then
        _G.NexusOS.ThemeManager:SetTheme(themeName)
    end
end

function RayfieldAdapter:UpdateMobileMode(enabled)
    self.State.MobileMode = enabled
    
    if enabled then
        -- Ajustar UI para mobile
        self.Config.UI.Scale = 0.9
        self.Config.UI.AnimationSpeed = 0.8
        
        -- Notificar usuário
        if _G.NexusOS and _G.NexusOS.NotificationSystem then
            _G.NexusOS.NotificationSystem:Notify({
                Title = "Mobile Mode",
                Text = "UI optimized for touch devices",
                Duration = 3,
                Type = "INFO"
            })
        end
    else
        -- Restaurar configurações desktop
        self.Config.UI.Scale = 1
        self.Config.UI.AnimationSpeed = 1
    end
    
    self:UpdateUIScale(self.Config.UI.Scale)
end

function RayfieldAdapter:UpdateUIScale(scale)
    -- Atualizar escala da UI
    -- Esta é uma implementação simulada
    print("[RayfieldAdapter] UI Scale updated to:", scale)
end

function RayfieldAdapter:UpdateUIOpacity(opacity)
    -- Atualizar opacidade da UI
    -- Esta é uma implementação simulada
    print("[RayfieldAdapter] UI Opacity updated to:", opacity)
end

function RayfieldAdapter:UpdateWatermark(visible)
    -- Atualizar visibilidade do watermark
    -- Esta é uma implementação simulada
    print("[RayfieldAdapter] Watermark visibility:", visible)
end

function RayfieldAdapter:SaveConfiguration()
    local configData = {
        UI = self.Config.UI,
        Window = self.Config.Window,
        Theme = self.State.CurrentTheme,
        MobileMode = self.State.MobileMode
    }
    
    local filePath = "NexusOS/RayfieldConfig.json"
    local jsonData = game:GetService("HttpService"):JSONEncode(configData)
    
    pcall(writefile, filePath, jsonData)
    
    if _G.NexusOS and _G.NexusOS.NotificationSystem then
        _G.NexusOS.NotificationSystem:Notify({
            Title = "Configuration Saved",
            Text = "UI configuration saved successfully",
            Duration = 3,
            Type = "SUCCESS"
        })
    end
end

function RayfieldAdapter:LoadConfiguration()
    local filePath = "NexusOS/RayfieldConfig.json"
    
    local success, fileData = pcall(readfile, filePath)
    if not success then
        if _G.NexusOS and _G.NexusOS.NotificationSystem then
            _G.NexusOS.NotificationSystem:Notify({
                Title = "Configuration Error",
                Text = "No saved configuration found",
                Duration = 3,
                Type = "ERROR"
            })
        end
        return false
    end
    
    local success, config = pcall(game:GetService("HttpService").JSONDecode, 
        game:GetService("HttpService"), fileData)
    
    if success and config then
        -- Aplicar configurações
        if config.UI then
            self.Config.UI = config.UI
        end
        
        if config.Theme then
            self:ApplyTheme(config.Theme)
        end
        
        if config.MobileMode ~= nil then
            self:UpdateMobileMode(config.MobileMode)
        end
        
        if _G.NexusOS and _G.NexusOS.NotificationSystem then
            _G.NexusOS.NotificationSystem:Notify({
                Title = "Configuration Loaded",
                Text = "UI configuration loaded successfully",
                Duration = 3,
                Type = "SUCCESS"
            })
        end
        
        return true
    end
    
    return false
end

function RayfieldAdapter:ResetToDefault()
    self.Config = table.clone(self.DefaultConfig)
    self.State.CurrentTheme = "Dark"
    self.State.MobileMode = false
    
    -- Aplicar configurações padrão
    self:ApplyTheme("Dark")
    self:UpdateMobileMode(false)
    self:UpdateUIScale(1)
    self:UpdateUIOpacity(0.95)
    self:UpdateWatermark(true)
    
    if _G.NexusOS and _G.NexusOS.NotificationSystem then
        _G.NexusOS.NotificationSystem:Notify({
            Title = "Configuration Reset",
            Text = "UI configuration reset to default",
            Duration = 3,
            Type = "INFO"
        })
    end
    
    return true
end

function RayfieldAdapter:Initialize()
    print("[RayfieldAdapter] Initializing...")
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Detectar se é mobile
    local UserInputService = game:GetService("UserInputService")
    self.State.MobileMode = UserInputService.TouchEnabled
    
    if self.State.MobileMode then
        self.Config.UI.Scale = 0.9
        self.Config.UI.AnimationSpeed = 0.8
    end
    
    -- Carregar configuração salva
    self:LoadConfiguration()
    
    -- Carregar Rayfield
    local success, err = self:LoadRayfield()
    if not success then
        print("[RayfieldAdapter] Failed to initialize:", err)
        return false
    end
    
    self.State.Initialized = true
    
    print("[RayfieldAdapter] Initialization complete")
    
    return true
end

function RayfieldAdapter:Shutdown()
    print("[RayfieldAdapter] Shutting down...")
    
    -- Salvar configuração
    self:SaveConfiguration()
    
    -- Destruir janela
    WindowSystem:Destroy()
    
    -- Limpar estado
    self.State.Initialized = false
    self.State.Window = nil
    
    print("[RayfieldAdapter] Shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusUI then
    _G.NexusUI = RayfieldAdapter
end

return RayfieldAdapter

