-- =============================================
-- NEXUS OS - MAIN LOADER
-- Arquivo: MainLoader.lua
-- Local: src/MainLoader.lua
-- =============================================

local MainLoader = {
    LoadedComponents = {},
    LoadOrder = {
        "Core/StateManager",
        "Security/Crypto",
        "Services/Network",
        "Services/Memory",
        "Services/Performance",
        "UI/ThemeManager",
        "UI/NotificationSystem",
        "UI/RayfieldAdapter",
        "UI/MobileButton",
        "Modules/PhysicsAndMovement",
        "Modules/VisualDebugger",
        "Modules/AutomationAndInteraction",
        "Modules/PlayerAndUtility",
        "Modules/ConfigAndSystem",
        "Presets/Legit",
        "Presets/Visual",
        "Presets/Custom",
        "Plugins/PluginManager"
    },
    Dependencies = {
        ["UI/RayfieldAdapter"] = {"UI/ThemeManager", "UI/NotificationSystem"},
        ["Modules/PhysicsAndMovement"] = {"Core/StateManager"},
        ["Modules/VisualDebugger"] = {"UI/ThemeManager"},
        ["Modules/AutomationAndInteraction"] = {"Services/Network"},
        ["Modules/PlayerAndUtility"] = {"Services/Memory"},
        ["Modules/ConfigAndSystem"] = {"Security/Crypto"},
        ["Plugins/PluginManager"] = {"Modules/ConfigAndSystem"}
    }
}

-- ============ FUNÇÕES DE CARREGAMENTO ============
function MainLoader:LoadComponent(componentPath)
    if self.LoadedComponents[componentPath] then
        print("[Loader] Component already loaded:", componentPath)
        return true
    end
    
    -- Verificar dependências
    if self.Dependencies[componentPath] then
        for _, dep in ipairs(self.Dependencies[componentPath]) do
            if not self.LoadedComponents[dep] then
                print("[Loader] Missing dependency:", dep, "for", componentPath)
                return false
            end
        end
    end
    
    print("[Loader] Loading:", componentPath)
    
    -- Simular carregamento (em produção, carregaria o arquivo real)
    local success = true
    
    if success then
        self.LoadedComponents[componentPath] = {
            loaded = true,
            timestamp = os.time()
        }
        
        print("[Loader] Successfully loaded:", componentPath)
        return true
    else
        print("[Loader] Failed to load:", componentPath)
        return false
    end
end

function MainLoader:LoadAll()
    print("[Loader] === STARTING NEXUS OS LOAD ===")
    
    local loadedCount = 0
    local totalCount = #self.LoadOrder
    
    for _, component in ipairs(self.LoadOrder) do
        if self:LoadComponent(component) then
            loadedCount = loadedCount + 1
        end
        
        -- Pequena pausa entre carregamentos
        wait(0.1)
    end
    
    print(string.format("[Loader] Load complete: %d/%d components loaded", loadedCount, totalCount))
    
    -- Notificar sistema principal
    if _G.NexusOS and _G.NexusOS.EventSystem then
        _G.NexusOS.EventSystem:Trigger("LoaderComplete", loadedCount, totalCount)
    end
    
    return loadedCount == totalCount
end

function MainLoader:LoadModule(moduleName)
    local modulePaths = {
        PhysicsAndMovement = "Modules/PhysicsAndMovement",
        VisualDebugger = "Modules/VisualDebugger",
        AutomationAndInteraction = "Modules/AutomationAndInteraction",
        PlayerAndUtility = "Modules/PlayerAndUtility",
        ConfigAndSystem = "Modules/ConfigAndSystem"
    }
    
    if modulePaths[moduleName] then
        return self:LoadComponent(modulePaths[moduleName])
    end
    
    return false
end

function MainLoader:LoadUI()
    local uiComponents = {
        "UI/ThemeManager",
        "UI/NotificationSystem",
        "UI/RayfieldAdapter",
        "UI/MobileButton"
    }
    
    local loaded = 0
    for _, component in ipairs(uiComponents) do
        if self:LoadComponent(component) then
            loaded = loaded + 1
        end
    end
    
    return loaded == #uiComponents
end

function MainLoader:LoadServices()
    local services = {
        "Services/Network",
        "Services/Memory",
        "Services/Performance"
    }
    
    local loaded = 0
    for _, service in ipairs(services) do
        if self:LoadComponent(service) then
            loaded = loaded + 1
        end
    end
    
    return loaded == #services
end

function MainLoader:GetStatus()
    local loaded = 0
    local total = #self.LoadOrder
    
    for _, component in ipairs(self.LoadOrder) do
        if self.LoadedComponents[component] then
            loaded = loaded + 1
        end
    end
    
    return {
        loaded = loaded,
        total = total,
        percentage = math.floor((loaded / total) * 100),
        components = self.LoadedComponents
    }
end

-- ============ FUNÇÕES DE UNLOAD ============
function MainLoader:UnloadComponent(componentPath)
    if self.LoadedComponents[componentPath] then
        self.LoadedComponents[componentPath] = nil
        print("[Loader] Unloaded:", componentPath)
        return true
    end
    return false
end

function MainLoader:ReloadComponent(componentPath)
    self:UnloadComponent(componentPath)
    return self:LoadComponent(componentPath)
end

-- ============ INICIALIZAÇÃO ============
function MainLoader:Initialize()
    print("[Loader] MainLoader initialized")
    
    -- Iniciar carregamento automático se configurado
    if _G.NexusOS and _G.NexusOS.ConfigSystem then
        local config = _G.NexusOS.ConfigSystem.Settings
        if config.AutoLoad then
            spawn(function()
                wait(2) -- Esperar inicialização do sistema
                self:LoadAll()
            end)
        end
    end
    
    return true
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusLoader then
    _G.NexusLoader = MainLoader
end

return MainLoader
