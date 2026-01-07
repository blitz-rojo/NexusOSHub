-- =============================================
-- NEXUS OS - STATE MANAGER
-- Arquivo: StateManager.lua
-- Local: src/Core/StateManager.lua
-- =============================================

local StateManager = {
    Version = "2.0.0",
    States = {},
    StateHistory = {},
    MaxHistoryLength = 50,
    Events = {},
    Persistence = {
        Enabled = true,
        AutoSave = true,
        SaveInterval = 60, -- segundos
        FilePath = "NexusOS/States/"
    }
}

-- ============ CONSTANTES DE ESTADO ============
StateManager.StateTypes = {
    MODULE = "MODULE",
    FEATURE = "FEATURE",
    SYSTEM = "SYSTEM",
    UI = "UI",
    SECURITY = "SECURITY",
    NETWORK = "NETWORK"
}

StateManager.StateStatus = {
    INACTIVE = "INACTIVE",
    LOADING = "LOADING",
    ACTIVE = "ACTIVE",
    PAUSED = "PAUSED",
    ERROR = "ERROR",
    DISABLED = "DISABLED"
}

-- ============ ESTRUTURAS DE ESTADO ============
StateManager.DefaultState = {
    Type = "",
    Name = "",
    Status = StateManager.StateStatus.INACTIVE,
    Data = {},
    Timestamp = 0,
    Parent = nil,
    Children = {},
    Metadata = {
        Created = 0,
        Modified = 0,
        Version = "1.0",
        Author = "System"
    }
}

-- ============ FUNÇÕES DE GERENCIAMENTO ============
function StateManager:CreateState(stateName, stateType, parentName)
    if self.States[stateName] then
        return false, "State already exists"
    end
    
    local newState = {
        Type = stateType or self.StateTypes.SYSTEM,
        Name = stateName,
        Status = self.StateStatus.INACTIVE,
        Data = {},
        Timestamp = os.time(),
        Parent = parentName,
        Children = {},
        Metadata = {
            Created = os.time(),
            Modified = os.time(),
            Version = "1.0",
            Author = "System"
        }
    }
    
    self.States[stateName] = newState
    
    -- Se tiver pai, adicionar como filho
    if parentName and self.States[parentName] then
        table.insert(self.States[parentName].Children, stateName)
    end
    
    -- Registrar no histórico
    self:AddToHistory("CREATE", stateName, newState)
    
    -- Disparar evento
    self:TriggerEvent("StateCreated", stateName, newState)
    
    return true, newState
end

function StateManager:GetState(stateName)
    return self.States[stateName]
end

function StateManager:SetStateData(stateName, key, value)
    if not self.States[stateName] then
        return false, "State not found"
    end
    
    if type(key) == "table" then
        for k, v in pairs(key) do
            self.States[stateName].Data[k] = v
        end
    else
        self.States[stateName].Data[key] = value
    end
    
    self.States[stateName].Metadata.Modified = os.time()
    self:AddToHistory("UPDATE_DATA", stateName, {key = key, value = value})
    
    self:TriggerEvent("StateDataChanged", stateName, key, value)
    
    return true
end

function StateManager:GetStateData(stateName, key)
    if not self.States[stateName] then
        return nil
    end
    
    if key then
        return self.States[stateName].Data[key]
    else
        return self.States[stateName].Data
    end
end

function StateManager:SetStateStatus(stateName, status)
    if not self.States[stateName] then
        return false, "State not found"
    end
    
    local oldStatus = self.States[stateName].Status
    self.States[stateName].Status = status
    self.States[stateName].Timestamp = os.time()
    self.States[stateName].Metadata.Modified = os.time()
    
    self:AddToHistory("UPDATE_STATUS", stateName, {old = oldStatus, new = status})
    
    self:TriggerEvent("StateStatusChanged", stateName, oldStatus, status)
    
    -- Se for um estado de módulo, notificar o ModuleManager
    if self.States[stateName].Type == self.StateTypes.MODULE and _G.NexusOS then
        _G.NexusOS.EventSystem:Trigger("ModuleStateChanged", stateName, status)
    end
    
    return true
end

function StateManager:DeleteState(stateName)
    if not self.States[stateName] then
        return false, "State not found"
    end
    
    -- Remover dos filhos do pai
    local parent = self.States[stateName].Parent
    if parent and self.States[parent] then
        for i, child in ipairs(self.States[parent].Children) do
            if child == stateName then
                table.remove(self.States[parent].Children, i)
                break
            end
        end
    end
    
    -- Remover estado
    local deletedState = self.States[stateName]
    self.States[stateName] = nil
    
    self:AddToHistory("DELETE", stateName, deletedState)
    self:TriggerEvent("StateDeleted", stateName, deletedState)
    
    return true
end

-- ============ HISTÓRICO ============
function StateManager:AddToHistory(action, stateName, data)
    local historyEntry = {
        Action = action,
        StateName = stateName,
        Data = data,
        Timestamp = os.time(),
        CallStack = debug.traceback()
    }
    
    table.insert(self.StateHistory, historyEntry)
    
    -- Limitar histórico
    if #self.StateHistory > self.MaxHistoryLength then
        table.remove(self.StateHistory, 1)
    end
end

function StateManager:GetHistory(filter)
    if not filter then
        return self.StateHistory
    end
    
    local filtered = {}
    for _, entry in ipairs(self.StateHistory) do
        local match = true
        
        if filter.Action and entry.Action ~= filter.Action then
            match = false
        end
        
        if filter.StateName and entry.StateName ~= filter.StateName then
            match = false
        end
        
        if filter.StartTime and entry.Timestamp < filter.StartTime then
            match = false
        end
        
        if filter.EndTime and entry.Timestamp > filter.EndTime then
            match = false
        end
        
        if match then
            table.insert(filtered, entry)
        end
    end
    
    return filtered
end

function StateManager:ClearHistory()
    self.StateHistory = {}
    self:TriggerEvent("HistoryCleared")
end

-- ============ EVENTOS ============
function StateManager:RegisterEvent(eventName)
    if not self.Events[eventName] then
        self.Events[eventName] = {
            listeners = {},
            lastTrigger = nil
        }
    end
end

function StateManager:AddEventListener(eventName, callback, priority)
    self:RegisterEvent(eventName)
    
    table.insert(self.Events[eventName].listeners, {
        callback = callback,
        priority = priority or 5,
        active = true
    })
    
    -- Ordenar por prioridade
    table.sort(self.Events[eventName].listeners, function(a, b)
        return a.priority > b.priority
    end)
end

function StateManager:RemoveEventListener(eventName, callback)
    if not self.Events[eventName] then
        return false
    end
    
    for i, listener in ipairs(self.Events[eventName].listeners) do
        if listener.callback == callback then
            table.remove(self.Events[eventName].listeners, i)
            return true
        end
    end
    
    return false
end

function StateManager:TriggerEvent(eventName, ...)
    if not self.Events[eventName] then
        self:RegisterEvent(eventName)
    end
    
    self.Events[eventName].lastTrigger = os.time()
    
    local results = {}
    for _, listener in ipairs(self.Events[eventName].listeners) do
        if listener.active then
            local success, result = pcall(listener.callback, ...)
            if success then
                table.insert(results, result)
            else
                print("[StateManager] Error in event listener:", result)
            end
        end
    end
    
    return results
end

-- ============ PERSISTÊNCIA ============
function StateManager:SaveStateToFile(stateName, filePath)
    if not self.Persistence.Enabled then
        return false, "Persistence disabled"
    end
    
    local state = self:GetState(stateName)
    if not state then
        return false, "State not found"
    end
    
    -- Garantir que o diretório existe
    local directory = string.match(filePath or self.Persistence.FilePath .. stateName .. ".json", "^(.*[/\\])")
    if directory and not isfolder(directory) then
        makefolder(directory)
    end
    
    local dataToSave = {
        Type = state.Type,
        Name = state.Name,
        Status = state.Status,
        Data = state.Data,
        Metadata = state.Metadata
    }
    
    local jsonData = game:GetService("HttpService"):JSONEncode(dataToSave)
    local fullPath = filePath or self.Persistence.FilePath .. stateName .. ".json"
    
    local success, err = pcall(writefile, fullPath, jsonData)
    
    if success then
        self:TriggerEvent("StateSaved", stateName, fullPath)
        return true, fullPath
    else
        return false, err
    end
end

function StateManager:LoadStateFromFile(filePath)
    if not self.Persistence.Enabled then
        return false, "Persistence disabled"
    end
    
    local success, fileData = pcall(readfile, filePath)
    if not success then
        return false, "File not found"
    end
    
    local success, data = pcall(game:GetService("HttpService").JSONDecode, 
        game:GetService("HttpService"), fileData)
    
    if not success or not data then
        return false, "Invalid JSON"
    end
    
    -- Criar ou atualizar estado
    local stateName = data.Name
    local existing = self:GetState(stateName)
    
    if existing then
        -- Atualizar estado existente
        existing.Type = data.Type
        existing.Status = data.Status
        existing.Data = data.Data
        existing.Metadata = data.Metadata
        existing.Timestamp = os.time()
    else
        -- Criar novo estado
        self.States[stateName] = {
            Type = data.Type,
            Name = data.Name,
            Status = data.Status,
            Data = data.Data,
            Timestamp = os.time(),
            Parent = nil,
            Children = {},
            Metadata = data.Metadata
        }
    end
    
    self:TriggerEvent("StateLoaded", stateName, filePath)
    
    return true, self.States[stateName]
end

function StateManager:SaveAllStates()
    if not self.Persistence.Enabled then
        return false, "Persistence disabled"
    end
    
    local saved = 0
    local errors = {}
    
    for stateName, state in pairs(self.States) do
        local success, err = self:SaveStateToFile(stateName)
        if success then
            saved = saved + 1
        else
            table.insert(errors, {state = stateName, error = err})
        end
    end
    
    return saved, errors
end

function StateManager:LoadAllStates(directory)
    if not self.Persistence.Enabled then
        return false, "Persistence disabled"
    end
    
    local dir = directory or self.Persistence.FilePath
    if not isfolder(dir) then
        return false, "Directory not found"
    end
    
    local loaded = 0
    local errors = {}
    
    -- Nota: Esta função depende de listar arquivos, o que pode não estar disponível
    -- Em alguns ambientes. Vamos simular para agora.
    print("[StateManager] LoadAllStates: Not implemented in this environment")
    
    return loaded, errors
end

-- ============ AUTO SAVE ============
function StateManager:StartAutoSave()
    if not self.Persistence.Enabled or not self.Persistence.AutoSave then
        return false
    end
    
    if self.AutoSaveThread then
        return false, "AutoSave already running"
    end
    
    self.AutoSaveThread = task.spawn(function()
        while self.Persistence.Enabled and self.Persistence.AutoSave do
            wait(self.Persistence.SaveInterval)
            
            if _G.NexusOS and _G.NexusOS.Logger then
                _G.NexusOS.Logger:Log("INFO", "Auto-saving states...", "StateManager")
            end
            
            local saved, errors = self:SaveAllStates()
            
            if _G.NexusOS and _G.NexusOS.Logger then
                if #errors > 0 then
                    _G.NexusOS.Logger:Log("WARNING", 
                        string.format("Auto-save completed with %d errors", #errors), 
                        "StateManager")
                else
                    _G.NexusOS.Logger:Log("INFO", 
                        string.format("Auto-save completed: %d states saved", saved), 
                        "StateManager")
                end
            end
        end
    end)
    
    return true
end

function StateManager:StopAutoSave()
    if self.AutoSaveThread then
        task.cancel(self.AutoSaveThread)
        self.AutoSaveThread = nil
        return true
    end
    
    return false
end

-- ============ UTILITÁRIOS ============
function StateManager:GetStatesByType(type)
    local result = {}
    
    for name, state in pairs(self.States) do
        if state.Type == type then
            table.insert(result, state)
        end
    end
    
    return result
end

function StateManager:GetStatesByStatus(status)
    local result = {}
    
    for name, state in pairs(self.States) do
        if state.Status == status then
            table.insert(result, state)
        end
    end
    
    return result
end

function StateManager:GetActiveStates()
    return self:GetStatesByStatus(self.StateStatus.ACTIVE)
end

function StateManager:GetInactiveStates()
    return self:GetStatesByStatus(self.StateStatus.INACTIVE)
end

function StateManager:CountStates()
    local count = 0
    for _ in pairs(self.States) do
        count = count + 1
    end
    return count
end

function StateManager:SearchStates(query)
    local results = {}
    
    for name, state in pairs(self.States) do
        local match = false
        
        -- Busca no nome
        if string.find(string.lower(name), string.lower(query)) then
            match = true
        end
        
        -- Busca nos dados
        for key, value in pairs(state.Data) do
            if type(value) == "string" and string.find(string.lower(value), string.lower(query)) then
                match = true
                break
            end
        end
        
        if match then
            table.insert(results, state)
        end
    end
    
    return results
end

function StateManager:GetStateTree(parentName)
    local tree = {}
    
    local function buildTree(stateName, depth)
        local state = self:GetState(stateName)
        if not state then
            return nil
        end
        
        local node = {
            Name = state.Name,
            Type = state.Type,
            Status = state.Status,
            Depth = depth,
            Children = {}
        }
        
        for _, childName in ipairs(state.Children) do
            local childNode = buildTree(childName, depth + 1)
            if childNode then
                table.insert(node.Children, childNode)
            end
        end
        
        return node
    end
    
    return buildTree(parentName or "ROOT", 0)
end

-- ============ INICIALIZAÇÃO ============
function StateManager:Initialize()
    print("[StateManager] Initializing...")
    
    -- Criar estado raiz
    self:CreateState("ROOT", self.StateTypes.SYSTEM)
    self:SetStateStatus("ROOT", self.StateStatus.ACTIVE)
    
    -- Registrar eventos do sistema
    self:RegisterEvent("StateCreated")
    self:RegisterEvent("StateDeleted")
    self:RegisterEvent("StateDataChanged")
    self:RegisterEvent("StateStatusChanged")
    self:RegisterEvent("StateSaved")
    self:RegisterEvent("StateLoaded")
    self:RegisterEvent("HistoryCleared")
    
    -- Iniciar auto-save se configurado
    if self.Persistence.Enabled and self.Persistence.AutoSave then
        self:StartAutoSave()
    end
    
    -- Carregar estados salvos
    if self.Persistence.Enabled then
        spawn(function()
            wait(5) -- Esperar um pouco
            self:LoadAllStates()
        end)
    end
    
    print("[StateManager] Initialization complete")
    
    return true
end

-- ============ SHUTDOWN ============
function StateManager:Shutdown()
    print("[StateManager] Shutting down...")
    
    -- Parar auto-save
    self:StopAutoSave()
    
    -- Salvar todos os estados
    if self.Persistence.Enabled then
        self:SaveAllStates()
    end
    
    -- Limpar estados
    self.States = {}
    self.StateHistory = {}
    
    print("[StateManager] Shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusStateManager then
    _G.NexusStateManager = StateManager
end

return StateManager
