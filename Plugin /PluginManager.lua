-- =============================================
-- NEXUS OS - PLUGIN MANAGER WITH ADVANCED SECURITY
-- Arquivo: PluginManager.lua
-- Local: src/Plugins/PluginManager.lua
-- =============================================

local PluginManager = {
    Name = "PluginManager",
    Version = "4.0.0",
    Description = "Sistema avançado de gerenciamento de plugins com sandboxing e verificação de segurança",
    Author = "Nexus Security Team",
    
    Config = {},
    State = {
        Initialized = false,
        Plugins = {},
        SandboxEnvironments = {},
        SecurityChecks = {},
        PluginBlacklist = {},
        LoadedPlugins = 0,
        FailedPlugins = 0,
        SecurityIncidents = 0
    },
    
    Dependencies = {"Crypto", "Memory", "Network", "Custom"}
}

-- ============ CONFIGURAÇÕES DE SEGURANÇA DE PLUGINS ============
PluginManager.DefaultConfig = {
    Security = {
        PluginVerification = true,
        VerificationLevel = 3, -- 1-5 (5=max)
        
        Sandboxing = {
            Enabled = true,
            IsolationLevel = 4, -- 1-5 (5=max isolation)
            RestrictedAPIs = true,
            MemoryLimits = true,
            MaxMemoryPerPlugin = 50, -- MB
            CPUThrottling = true,
            MaxCPUUsage = 20, -- %
            NetworkRestrictions = true,
            MaxNetworkRequests = 10 -- per minute
        },
        
        CodeAnalysis = {
            StaticAnalysis = true,
            DetectMaliciousPatterns = true,
            PatternDatabaseUpdate = true,
            UpdateInterval = 86400, -- 24 horas
            HeuristicAnalysis = true,
            MaxComplexityScore = 100
        },
        
        RuntimeProtection = {
            MonitorPluginBehavior = true,
            BehaviorAnalysis = true,
            AnomalyDetection = true,
            AutoQuarantine = true,
            QuarantineThreshold = 3,
            KillSwitch = true,
            KillSwitchThreshold = 5
        },
        
        SignatureVerification = {
            RequireSignatures = true,
            SignatureDatabase = {},
            RevocationList = {},
            CheckRevocation = true,
            AutoUpdateSignatures = true
        }
    },
    
    Performance = {
        MaxConcurrentPlugins = 5,
        PluginLoadTimeout = 30, -- segundos
        MemoryCleanup = true,
        CleanupInterval = 60,
        
        Caching = {
            CacheVerifiedPlugins = true,
            CacheDuration = 3600,
            MaxCacheSize = 100 -- plugins
        }
    },
    
    Repository = {
        OfficialRepository = "https://plugins.nexusos.dev",
        MirrorRepositories = {
            "https://mirror1.nexusos.dev/plugins",
            "https://mirror2.nexusos.dev/plugins"
        },
        AutoUpdatePlugins = true,
        UpdateCheckInterval = 3600,
        
        TrustLevels = {
            OFFICIAL = 5,
            COMMUNITY_VERIFIED = 4,
            COMMUNITY = 3,
            UNVERIFIED = 2,
            EXPERIMENTAL = 1
        }
    },
    
    Logging = {
        LogAllPluginActivity = true,
        LogToFile = false,
        LogEncryption = true,
        MaxLogSize = 10000,
        
        AlertOn = {
            SecurityIncident = true,
            PluginCrash = true,
            MemoryLeak = true,
            SuspiciousBehavior = true
        }
    },
    
    Compatibility = {
        APILevel = 4,
        MinNexusVersion = "18.0.0",
        SupportedGames = {},
        GameSpecificRestrictions = true
    }
}

-- ============ SISTEMA DE SANDBOX AVANÇADO ============
local AdvancedSandbox = {
    Sandboxes = {},
    SecurityPolicies = {},
    ResourceMonitors = {},
    APIProxies = {}
}

function AdvancedSandbox:CreateSandbox(pluginId, trustLevel)
    local sandboxId = "SANDBOX_" .. pluginId
    
    -- Definir política de segurança baseada no nível de confiança
    local policy = self:CreateSecurityPolicy(trustLevel)
    
    -- Criar ambiente sandbox
    local sandbox = {
        id = sandboxId,
        pluginId = pluginId,
        trustLevel = trustLevel,
        policy = policy,
        
        environment = setmetatable({}, {
            __index = function(t, k)
                -- Permitir apenas APIs aprovadas
                if policy.allowedAPIs[k] then
                    return policy.allowedAPIs[k]
                end
                
                -- Bloquear acesso não autorizado
                PluginManager:LogSecurityEvent("UNAUTHORIZED_API_ACCESS",
                    "Plugin " .. pluginId .. " tried to access: " .. k)
                return nil
            end,
            
            __newindex = function(t, k, v)
                -- Prevenir modificação do ambiente
                PluginManager:LogSecurityEvent("SANDBOX_VIOLATION",
                    "Plugin " .. pluginId .. " tried to modify sandbox: " .. k)
            end
        }),
        
        resourceUsage = {
            memory = 0,
            cpu = 0,
            network = 0,
            startTime = os.time(),
            lastCheck = os.time()
        },
        
        restrictions = {
            maxMemory = policy.maxMemory,
            maxCPU = policy.maxCPU,
            maxNetwork = policy.maxNetwork,
            timeout = policy.timeout
        },
        
        monitors = {
            memoryMonitor = nil,
            cpuMonitor = nil,
            networkMonitor = nil,
            behaviorMonitor = nil
        },
        
        status = "ACTIVE"
    }
    
    -- Configurar APIs permitidas
    self:SetupAllowedAPIs(sandbox, policy)
    
    -- Iniciar monitores de recursos
    self:StartResourceMonitors(sandbox)
    
    self.Sandboxes[sandboxId] = sandbox
    
    return sandbox
end

function AdvancedSandbox:CreateSecurityPolicy(trustLevel)
    local policies = {
        [5] = { -- OFFICIAL
            allowedAPIs = {
                "print", "warn", "error",
                "wait", "spawn", "delay",
                "math", "string", "table",
                "NexusAPI", "GameAPI"
            },
            maxMemory = 100, -- MB
            maxCPU = 30, -- %
            maxNetwork = 50, -- requests/min
            timeout = 60, -- seconds
            allowFileAccess = true,
            allowNetworkAccess = true,
            allowSystemAccess = false
        },
        [4] = { -- COMMUNITY_VERIFIED
            allowedAPIs = {
                "print", "warn", "error",
                "wait", "spawn",
                "math", "string", "table",
                "NexusAPI"
            },
            maxMemory = 50,
            maxCPU = 20,
            maxNetwork = 30,
            timeout = 45,
            allowFileAccess = false,
            allowNetworkAccess = true,
            allowSystemAccess = false
        },
        [3] = { -- COMMUNITY
            allowedAPIs = {
                "print", "warn",
                "wait",
                "math", "string"
            },
            maxMemory = 25,
            maxCPU = 15,
            maxNetwork = 20,
            timeout = 30,
            allowFileAccess = false,
            allowNetworkAccess = false,
            allowSystemAccess = false
        },
        [2] = { -- UNVERIFIED
            allowedAPIs = {
                "print",
                "wait",
                "math"
            },
            maxMemory = 10,
            maxCPU = 10,
            maxNetwork = 5,
            timeout = 15,
            allowFileAccess = false,
            allowNetworkAccess = false,
            allowSystemAccess = false
        },
        [1] = { -- EXPERIMENTAL
            allowedAPIs = {
                "print"
            },
            maxMemory = 5,
            maxCPU = 5,
            maxNetwork = 0,
            timeout = 10,
            allowFileAccess = false,
            allowNetworkAccess = false,
            allowSystemAccess = false
        }
    }
    
    return policies[trustLevel] or policies[2] -- Default to UNVERIFIED
end

function AdvancedSandbox:SetupAllowedAPIs(sandbox, policy)
    -- Configurar APIs básicas
    sandbox.environment.print = function(...)
        local output = ""
        for i = 1, select("#", ...) do
            output = output .. tostring(select(i, ...)) .. "\t"
        end
        print("[Plugin:" .. sandbox.pluginId .. "]", output)
    end
    
    sandbox.environment.wait = function(seconds)
        local maxWait = 5
        local waitTime = math.min(seconds or 0.1, maxWait)
        return wait(waitTime)
    end
    
    sandbox.environment.spawn = function(func)
        -- Spawn controlado no sandbox
        task.spawn(function()
            local success, err = pcall(func)
            if not success then
                PluginManager:LogSecurityEvent("PLUGIN_SPAWN_ERROR",
                    "Plugin " .. sandbox.pluginId .. " spawn error: " .. err)
            end
        end)
    end
    
    -- Configurar APIs matemáticas
    sandbox.environment.math = {
        abs = math.abs,
        acos = math.acos,
        asin = math.asin,
        atan = math.atan,
        atan2 = math.atan2,
        ceil = math.ceil,
        cos = math.cos,
        cosh = math.cosh,
        deg = math.deg,
        exp = math.exp,
        floor = math.floor,
        fmod = math.fmod,
        frexp = math.frexp,
        huge = math.huge,
        ldexp = math.ldexp,
        log = math.log,
        log10 = math.log10,
        max = math.max,
        min = math.min,
        modf = math.modf,
        pi = math.pi,
        pow = math.pow,
        rad = math.rad,
        random = math.random,
        sin = math.sin,
        sinh = math.sinh,
        sqrt = math.sqrt,
        tan = math.tan,
        tanh = math.tanh
    }
    
    -- Configurar APIs de string
    sandbox.environment.string = {
        byte = string.byte,
        char = string.char,
        find = string.find,
        format = string.format,
        gmatch = string.gmatch,
        gsub = string.gsub,
        len = string.len,
        lower = string.lower,
        match = string.match,
        rep = string.rep,
        reverse = string.reverse,
        sub = string.sub,
        upper = string.upper
    }
    
    -- Configurar APIs de tabela
    sandbox.environment.table = {
        concat = table.concat,
        insert = table.insert,
        maxn = table.maxn,
        remove = table.remove,
        sort = table.sort
    }
    
    -- API Nexus (limitada)
    if policy.allowSystemAccess then
        sandbox.environment.NexusAPI = {
            GetVersion = function() return PluginManager.Version end,
            GetPluginInfo = function() return sandbox.pluginId end,
            Log = function(message)
                PluginManager:LogSecurityEvent("PLUGIN_LOG",
                    "Plugin " .. sandbox.pluginId .. ": " .. message)
            end
        }
    end
end

function AdvancedSandbox:StartResourceMonitors(sandbox)
    -- Monitor de memória
    sandbox.monitors.memoryMonitor = task.spawn(function()
        while sandbox.status == "ACTIVE" do
            local stats = game:GetService("Stats")
            sandbox.resourceUsage.memory = stats:GetTotalMemoryUsageMb()
            
            -- Verificar limite
            if sandbox.resourceUsage.memory > sandbox.restrictions.maxMemory then
                PluginManager:LogSecurityEvent("MEMORY_LIMIT_EXCEEDED",
                    "Plugin " .. sandbox.pluginId .. " exceeded memory limit: " ..
                    sandbox.resourceUsage.memory .. "MB")
                
                self:HandleViolation(sandbox, "MEMORY_OVERUSE")
            end
            
            wait(5)
        end
    end)
    
    -- Monitor de rede
    if sandbox.restrictions.maxNetwork > 0 then
        sandbox.monitors.networkMonitor = task.spawn(function()
            local requests = 0
            local lastReset = os.time()
            
            while sandbox.status == "ACTIVE" do
                local currentTime = os.time()
                
                -- Reset a cada minuto
                if currentTime - lastReset >= 60 then
                    requests = 0
                    lastReset = currentTime
                end
                
                sandbox.resourceUsage.network = requests
                
                if requests > sandbox.restrictions.maxNetwork then
                    PluginManager:LogSecurityEvent("NETWORK_LIMIT_EXCEEDED",
                        "Plugin " .. sandbox.pluginId .. " exceeded network limit: " ..
                        requests .. " requests/min")
                    
                    self:HandleViolation(sandbox, "NETWORK_OVERUSE")
                end
                
                wait(1)
            end
        end)
    end
    
    -- Monitor de comportamento
    if PluginManager.Config.Security.RuntimeProtection.BehaviorAnalysis then
        sandbox.monitors.behaviorMonitor = task.spawn(function()
            local suspiciousActions = 0
            
            while sandbox.status == "ACTIVE" do
                -- Monitorar padrões suspeitos (simulado)
                -- Em produção, analisaria o comportamento real
                
                wait(10)
            end
        end)
    end
end

function AdvancedSandbox:HandleViolation(sandbox, violationType)
    local violations = sandbox.violations or {}
    violations[violationType] = (violations[violationType] or 0) + 1
    sandbox.violations = violations
    
    local threshold = PluginManager.Config.Security.RuntimeProtection.QuarantineThreshold
    
    if violations[violationType] >= threshold then
        -- Colocar em quarentena
        self:QuarantinePlugin(sandbox.pluginId, violationType)
    end
    
    -- Kill switch
    local killThreshold = PluginManager.Config.Security.RuntimeProtection.KillSwitchThreshold
    local totalViolations = 0
    
    for _, count in pairs(violations) do
        totalViolations = totalViolations + count
    end
    
    if totalViolations >= killThreshold and PluginManager.Config.Security.RuntimeProtection.KillSwitch then
        self:KillPlugin(sandbox.pluginId, "Too many violations: " .. totalViolations)
    end
end

function AdvancedSandbox:QuarantinePlugin(pluginId, reason)
    local sandbox = self:GetSandboxByPluginId(pluginId)
    if not sandbox then return end
    
    sandbox.status = "QUARANTINED"
    
    -- Suspender todos os monitores
    for _, monitor in pairs(sandbox.monitors) do
        if monitor then
            pcall(task.cancel, monitor)
        end
    end
    
    -- Restringir ainda mais o ambiente
    sandbox.environment = setmetatable({}, {
        __index = function() return nil end,
        __newindex = function() end
    })
    
    PluginManager:LogSecurityEvent("PLUGIN_QUARANTINED",
        "Plugin " .. pluginId .. " quarantined. Reason: " .. reason)
end

function AdvancedSandbox:KillPlugin(pluginId, reason)
    local sandbox = self:GetSandboxByPluginId(pluginId)
    if not sandbox then return end
    
    sandbox.status = "KILLED"
    
    -- Parar todos os processos
    for _, monitor in pairs(sandbox.monitors) do
        if monitor then
            pcall(task.cancel, monitor)
        end
    end
    
    -- Remover sandbox
    self.Sandboxes[sandbox.id] = nil
    
    PluginManager:LogSecurityEvent("PLUGIN_KILLED",
        "Plugin " .. pluginId .. " killed. Reason: " .. reason)
end

function AdvancedSandbox:GetSandboxByPluginId(pluginId)
    for _, sandbox in pairs(self.Sandboxes) do
        if sandbox.pluginId == pluginId then
            return sandbox
        end
    end
    return nil
end

function AdvancedSandbox:ExecuteInSandbox(pluginId, code)
    local sandbox = self:GetSandboxByPluginId(pluginId)
    if not sandbox or sandbox.status ~= "ACTIVE" then
        return false, "Sandbox not available"
    end
    
    -- Configurar timeout
    local timeout = sandbox.restrictions.timeout
    local startTime = os.time()
    
    -- Executar código no sandbox
    local function execute()
        local chunk, err = loadstring(code)
        if not chunk then
            return false, "Compilation error: " .. err
        end
        
        setfenv(chunk, sandbox.environment)
        
        local success, result = pcall(chunk)
        if not success then
            return false, "Runtime error: " .. result
        end
        
        return true, result
    end
    
    -- Executar com timeout
    local completed = false
    local result = nil
    local error = nil
    
    task.spawn(function()
        local success, res = execute()
        completed = true
        result = res
        if not success then
            error = res
        end
    end)
    
    -- Esperar pelo resultado ou timeout
    while not completed do
        if os.time() - startTime > timeout then
            self:HandleViolation(sandbox, "TIMEOUT")
            return false, "Execution timeout"
        end
        wait(0.1)
    end
    
    if error then
        return false, error
    end
    
    return true, result
end

-- ============ SISTEMA DE ANÁLISE DE CÓDIGO ============
local CodeAnalyzer = {
    MaliciousPatterns = {},
    HeuristicRules = {},
    ComplexityMetrics = {},
    PatternDatabase = {}
}

function CodeAnalyzer:Initialize()
    -- Carregar padrões maliciosos
    self:LoadMaliciousPatterns()
    
    -- Carregar regras heurísticas
    self:LoadHeuristicRules()
    
    -- Carregar banco de dados de padrões
    self:LoadPatternDatabase()
end

function CodeAnalyzer:LoadMaliciousPatterns()
    -- Padrões comuns de código malicioso
    self.MaliciousPatterns = {
        -- Injeção de código
        {pattern = "loadstring%(.*getfenv.*%)", risk = 90, description = "Code injection attempt"},
        {pattern = "getfenv%(%d+%)", risk = 80, description = "Environment manipulation"},
        {pattern = "setfenv%(%d+,.*%)", risk = 85, description = "Environment hijacking"},
        
        -- Acesso a APIs perigosas
        {pattern = "hookfunction", risk = 95, description = "Function hooking"},
        {pattern = "newcclosure", risk = 70, description = "Closure creation"},
        {pattern = "checkcaller", risk = 60, description = "Caller checking"},
        
        -- Manipulação de memória
        {pattern = "writefile%(.*%.lua.*%)", risk = 75, description = "File write attempt"},
        {pattern = "delfile", risk = 80, description = "File deletion"},
        {pattern = "makefolder", risk = 50, description = "Folder creation"},
        
        -- Comunicação externa
        {pattern = "HttpGet%(.*%)", risk = 40, description = "HTTP GET request"},
        {pattern = "HttpPost%(.*%)", risk = 45, description = "HTTP POST request"},
        {pattern = "request", risk = 60, description = "HTTP request"},
        
        -- Process manipulation
        {pattern = "getrenv", risk = 85, description = "Environment access"},
        {pattern = "getgenv", risk = 80, description = "Global environment access"},
        {pattern = "getreg", risk = 90, description = "Registry access"},
        
        -- Anti-debug techniques
        {pattern = "debug%.traceback", risk = 30, description = "Debug traceback"},
        {pattern = "debug%.getinfo", risk = 40, description = "Debug info"},
        {pattern = "debug%.gethook", risk = 50, description = "Debug hook check"}
    }
    
    -- Atualizar do repositório se configurado
    if PluginManager.Config.Security.CodeAnalysis.PatternDatabaseUpdate then
        self:UpdatePatternDatabase()
    end
end

function CodeAnalyzer:LoadHeuristicRules()
    self.HeuristicRules = {
        {
            name = "EXCESSIVE_LOOPS",
            check = function(code)
                local loopCount = 0
                
                -- Contar loops
                for pattern in code:gmatch("for%s+") do loopCount = loopCount + 1 end
                for pattern in code:gmatch("while%s+") do loopCount = loopCount + 1 end
                for pattern in code:gmatch("repeat%s+") do loopCount = loopCount + 1 end
                
                return loopCount > 10, loopCount
            end,
            risk = function(count) return math.min(count * 5, 70) end
        },
        {
            name = "DEEP_NESTING",
            check = function(code)
                local maxDepth = 0
                local currentDepth = 0
                
                for char in code:gmatch(".") do
                    if char == "(" or char == "{" or char == "[" then
                        currentDepth = currentDepth + 1
                        maxDepth = math.max(maxDepth, currentDepth)
                    elseif char == ")" or char == "}" or char == "]" then
                        currentDepth = currentDepth - 1
                    end
                end
                
                return maxDepth > 8, maxDepth
            end,
            risk = function(depth) return math.min(depth * 8, 60) end
        },
        {
            name = "LONG_LINES",
            check = function(code)
                local longLines = 0
                
                for line in code:gmatch("[^\n]+") do
                    if #line > 200 then
                        longLines = longLines + 1
                    end
                end
                
                return longLines > 5, longLines
            end,
            risk = function(count) return math.min(count * 4, 40) end
        },
        {
            name = "EXCESSIVE_STRINGS",
            check = function(code)
                local stringCount = 0
                
                for pattern in code:gmatch('".-"') do stringCount = stringCount + 1 end
                for pattern in code:gmatch("'.-'") do stringCount = stringCount + 1 end
                for pattern in code:gmatch("%[%[.-%]%]") do stringCount = stringCount + 1 end
                
                return stringCount > 50, stringCount
            end,
            risk = function(count) return math.min(count * 2, 50) end
        }
    }
end

function CodeAnalyzer:LoadPatternDatabase()
    -- Carregar banco de dados local (se existir)
    local dbFile = "NexusOS/Plugins/PatternDatabase.json"
    
    if isfile and readfile and isfile(dbFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(dbFile))
        end)
        
        if success and data then
            self.PatternDatabase = data
            print("[CodeAnalyzer] Loaded pattern database with", #self.PatternDatabase, "patterns")
        end
    end
end

function CodeAnalyzer:UpdatePatternDatabase()
    if not PluginManager.Config.Security.CodeAnalysis.PatternDatabaseUpdate then
        return
    end
    
    local updateUrl = PluginManager.Config.Repository.OfficialRepository .. "/patterns.json"
    
    task.spawn(function()
        local success, response = pcall(game.HttpGet, game, updateUrl)
        if success and response then
            local success, data = pcall(game:GetService("HttpService").JSONDecode,
                game:GetService("HttpService"), response)
            
            if success and data then
                self.PatternDatabase = data
                
                -- Salvar localmente
                if writefile then
                    pcall(writefile, "NexusOS/Plugins/PatternDatabase.json",
                        game:GetService("HttpService"):JSONEncode(data))
                end
                
                print("[CodeAnalyzer] Pattern database updated")
            end
        end
    end)
end

function CodeAnalyzer:AnalyzeCode(code, pluginId)
    local analysis = {
        maliciousPatterns = {},
        heuristicWarnings = {},
        complexityScore = 0,
        totalRisk = 0,
        passed = true
    }
    
    -- Verificar padrões maliciosos
    for _, pattern in ipairs(self.MaliciousPatterns) do
        local match = code:match(pattern.pattern)
        if match then
            table.insert(analysis.maliciousPatterns, {
                pattern = pattern.description,
                risk = pattern.risk,
                match = match:sub(1, 100) .. "..."
            })
            
            analysis.totalRisk = analysis.totalRisk + pattern.risk
        end
    end
    
    -- Verificar banco de dados de padrões
    for _, pattern in ipairs(self.PatternDatabase) do
        if code:match(pattern.pattern) then
            table.insert(analysis.maliciousPatterns, {
                pattern = pattern.description,
                risk = pattern.risk or 50,
                source = "DATABASE"
            })
            
            analysis.totalRisk = analysis.totalRisk + (pattern.risk or 50)
        end
    end
    
    -- Análise heurística
    for _, rule in ipairs(self.HeuristicRules) do
        local triggered, value = rule.check(code)
        
        if triggered then
            local risk = rule.risk(value)
            
            table.insert(analysis.heuristicWarnings, {
                rule = rule.name,
                value = value,
                risk = risk
            })
            
            analysis.totalRisk = analysis.totalRisk + risk
        end
    end
    
    -- Calcular complexidade
    analysis.complexityScore = self:CalculateComplexity(code)
    
    -- Verificar limite de complexidade
    local maxComplexity = PluginManager.Config.Security.CodeAnalysis.MaxComplexityScore
    if analysis.complexityScore > maxComplexity then
        analysis.totalRisk = analysis.totalRisk + 30
        table.insert(analysis.heuristicWarnings, {
            rule = "HIGH_COMPLEXITY",
            value = analysis.complexityScore,
            risk = 30
        })
    end
    
    -- Determinar se passou
    local verificationLevel = PluginManager.Config.Security.VerificationLevel
    local riskThresholds = {50, 40, 30, 20, 10} -- Nível 1-5
    
    analysis.passed = analysis.totalRisk < (riskThresholds[verificationLevel] or 30)
    
    return analysis
end

function CodeAnalyzer:CalculateComplexity(code)
    local score = 0
    
    -- Contar declarações
    score = score + (code:gmatch("function"):count() * 5)
    score = score + (code:gmatch("local%s+"):count() * 1)
    score = score + (code:gmatch("="):count() * 1)
    
    -- Contar estruturas de controle
    score = score + (code:gmatch("if%s+"):count() * 3)
    score = score + (code:gmatch("for%s+"):count() * 4)
    score = score + (code:gmatch("while%s+"):count() * 4)
    
    -- Contar chamadas de função
    score = score + (code:gmatch("%(%s*[%)%)]"):count() * 2)
    
    -- Contar operadores
    score = score + (code:gmatch("[%+%-%*/%%%^<>]=?"):count() * 1)
    
    return score
end

-- ============ SISTEMA DE VERIFICAÇÃO DE ASSINATURA ============
local SignatureVerifier = {
    TrustedKeys = {},
    RevokedKeys = {},
    SignatureCache = {}
}

function SignatureVerifier:Initialize()
    -- Carregar chaves confiáveis
    self:LoadTrustedKeys()
    
    -- Carregar chaves revogadas
    self:LoadRevokedKeys()
end

function SignatureVerifier:LoadTrustedKeys()
    -- Chaves públicas oficiais (em produção, carregaria de fonte segura)
    self.TrustedKeys = {
        ["NEXUS_OFFICIAL"] = {
            key = "30819F300D06092A864886F70D010101050003818D0030818902818100" ..
                  "C1A6C7E8F9A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B0C1D2E3" ..
                  "F4A5B6C7D8E9F0A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B0" ..
                  "C1D2E3F4A5B6C7D8E9F0A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7",
            owner = "Nexus Development Team",
            validUntil = 1893456000 -- 2030-01-01
        }
    }
    
    -- Carregar do repositório se configurado
    if PluginManager.Config.Security.SignatureVerification.AutoUpdateSignatures then
        self:UpdateSignatureDatabase()
    end
end

function SignatureVerifier:LoadRevokedKeys()
    self.RevokedKeys = {}
    
    -- Carregar lista de revogação
    if PluginManager.Config.Security.SignatureVerification.CheckRevocation then
        local crlFile = "NexusOS/Plugins/RevokedKeys.json"
        
        if isfile and readfile and isfile(crlFile) then
            local success, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile(crlFile))
            end)
            
            if success and data then
                self.RevokedKeys = data
            end
        end
    end
end

function SignatureVerifier:UpdateSignatureDatabase()
    local updateUrl = PluginManager.Config.Repository.OfficialRepository .. "/signatures.json"
    
    task.spawn(function()
        local success, response = pcall(game.HttpGet, game, updateUrl)
        if success and response then
            local success, data = pcall(game:GetService("HttpService").JSONDecode,
                game:GetService("HttpService"), response)
            
            if success and data then
                -- Atualizar chaves confiáveis
                if data.trustedKeys then
                    for keyId, keyData in pairs(data.trustedKeys) do
                        self.TrustedKeys[keyId] = keyData
                    end
                end
                
                -- Atualizar lista de revogação
                if data.revokedKeys then
                    for _, keyId in ipairs(data.revokedKeys) do
                        self.RevokedKeys[keyId] = true
                    end
                end
                
                -- Salvar localmente
                if writefile then
                    pcall(writefile, "NexusOS/Plugins/SignatureDatabase.json",
                        game:GetService("HttpService"):JSONEncode(data))
                end
                
                print("[SignatureVerifier] Signature database updated")
            end
        end
    end)
end

function SignatureVerifier:VerifySignature(pluginData, signature, keyId)
    -- Verificar se a assinatura é necessária
    if not PluginManager.Config.Security.SignatureVerification.RequireSignatures then
        return true, "Signature not required"
    end
    
    -- Verificar se a chave existe
    if not self.TrustedKeys[keyId] then
        return false, "Unknown key: " .. keyId
    end
    
    -- Verificar se a chave foi revogada
    if self.RevokedKeys[keyId] then
        return false, "Key revoked: " .. keyId
    end
    
    -- Verificar validade da chave
    local keyData = self.TrustedKeys[keyId]
    if keyData.validUntil and os.time() > keyData.validUntil then
        return false, "Key expired: " .. keyId
    end
    
    -- Em produção, verificaria a assinatura usando criptografia real
    -- Esta é uma implementação simulada
    
    -- Para demonstração, aceitamos qualquer assinatura que comece com "VALID_"
    if signature and signature:sub(1, 6) == "VALID_" then
        return true, "Signature verified"
    end
    
    return false, "Invalid signature"
end

function SignatureVerifier:GenerateMockSignature(pluginData)
    -- Gerar assinatura simulada (apenas para demonstração)
    local mockSignature = "VALID_" .. PluginManager:HashString(pluginData) .. "_" .. tostring(os.time())
    return mockSignature
end

-- ============ SISTEMA DE REPOSITÓRIO ============
local RepositorySystem = {
    PluginCatalog = {},
    InstalledPlugins = {},
    UpdateChecker = nil
}

function RepositorySystem:Initialize()
    -- Carregar catálogo local
    self:LoadLocalCatalog()
    
    -- Iniciar verificador de atualizações
    if PluginManager.Config.Repository.AutoUpdatePlugins then
        self:StartUpdateChecker()
    end
end

function RepositorySystem:LoadLocalCatalog()
    local catalogFile = "NexusOS/Plugins/Catalog.json"
    
    if isfile and readfile and isfile(catalogFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(catalogFile))
        end)
        
        if success and data then
            self.PluginCatalog = data
            print("[RepositorySystem] Loaded local catalog with", #self.PluginCatalog, "plugins")
        end
    end
end

function RepositorySystem:StartUpdateChecker()
    self.UpdateChecker = task.spawn(function()
        while PluginManager.State.Initialized do
            self:CheckForUpdates()
            wait(PluginManager.Config.Repository.UpdateCheckInterval)
        end
    end)
end

function RepositorySystem:CheckForUpdates()
    print("[RepositorySystem] Checking for plugin updates...")
    
    local updateUrl = PluginManager.Config.Repository.OfficialRepository .. "/catalog.json"
    
    local success, response = pcall(game.HttpGet, game, updateUrl)
    if not success or not response then
        return false
    end
    
    local success, remoteCatalog = pcall(game:GetService("HttpService").JSONDecode,
        game:GetService("HttpService"), response)
    
    if not success or not remoteCatalog then
        return false
    end
    
    -- Verificar atualizações
    local updatesAvailable = 0
    
    for _, remotePlugin in ipairs(remoteCatalog) do
        local localPlugin = self:GetPluginById(remotePlugin.id)
        
        if localPlugin and remotePlugin.version > localPlugin.version then
            updatesAvailable = updatesAvailable + 1
            
            PluginManager:LogSecurityEvent("PLUGIN_UPDATE_AVAILABLE",
                "Plugin " .. remotePlugin.name .. " update: " ..
                localPlugin.version .. " -> " .. remotePlugin.version)
        end
    end
    
    if updatesAvailable > 0 then
        print("[RepositorySystem] Found", updatesAvailable, "plugin updates")
        
        -- Notificar sistema de notificações
        if _G.NexusNotifications then
            _G.NexusNotifications:Info(
                "Plugin Updates",
                updatesAvailable .. " plugin updates available",
                5
            )
        end
    end
    
    return updatesAvailable > 0
end

function RepositorySystem:GetPluginById(pluginId)
    for _, plugin in ipairs(self.PluginCatalog) do
        if plugin.id == pluginId then
            return plugin
        end
    end
    return nil
end

function RepositorySystem:SearchPlugins(query, category, trustLevel)
    local results = {}
    
    for _, plugin in ipairs(self.PluginCatalog) do
        local matches = true
        
        -- Filtrar por query
        if query and query ~= "" then
            if not (plugin.name:lower():find(query:lower()) or
                   plugin.description:lower():find(query:lower())) then
                matches = false
            end
        end
        
        -- Filtrar por categoria
        if category and category ~= "" then
            if not plugin.categories or not table.find(plugin.categories, category) then
                matches = false
            end
        end
        
        -- Filtrar por nível de confiança
        if trustLevel and trustLevel > 0 then
            local pluginTrust = PluginManager.Config.Repository.TrustLevels[plugin.trustLevel] or 3
            if pluginTrust < trustLevel then
                matches = false
            end
        end
        
        if matches then
            table.insert(results, plugin)
        end
    end
    
    return results
end

function RepositorySystem:DownloadPlugin(pluginId, version)
    local plugin = self:GetPluginById(pluginId)
    if not plugin then
        return false, "Plugin not found"
    end
    
    local downloadUrl = plugin.downloadUrl
    if version and plugin.versions then
        for _, v in ipairs(plugin.versions) do
            if v.version == version then
                downloadUrl = v.downloadUrl
                break
            end
        end
    end
    
    print("[RepositorySystem] Downloading plugin:", plugin.name)
    
    local success, response = pcall(game.HttpGet, game, downloadUrl)
    if not success or not response then
        return false, "Download failed"
    end
    
    return true, response
end

-- ============ FUNÇÕES PRINCIPAIS DO GERENCIADOR ============
function PluginManager:HashString(str)
    local hash = 0
    
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 2^32
    end
    
    return string.format("%08x", hash)
end

function PluginManager:LogSecurityEvent(eventType, details)
    if not PluginManager.Config.Logging.LogAllPluginActivity then
        return
    end
    
    local event = {
        type = eventType,
        details = details,
        timestamp = os.time(),
        pluginCount = PluginManager.State.LoadedPlugins
    }
    
    -- Criptografar log se configurado
    if PluginManager.Config.Logging.LogEncryption and _G.NexusCrypto then
        event.encrypted = true
        event.details = _G.NexusCrypto:Encrypt(details)
    end
    
    -- Log para arquivo se configurado
    if PluginManager.Config.Logging.LogToFile and writefile then
        local logFile = "NexusOS/Plugins/SecurityLog.json"
        local logs = {}
        
        if isfile(logFile) then
            local success, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile(logFile))
            end)
            
            if success and data then
                logs = data
            end
        end
        
        table.insert(logs, 1, event)
        
        -- Limitar tamanho
        if #logs > PluginManager.Config.Logging.MaxLogSize then
            table.remove(logs, #logs)
        end
        
        pcall(writefile, logFile, game:GetService("HttpService"):JSONEncode(logs))
    end
    
    print("[PluginManager Security]", eventType, "-", details)
    
    -- Alertar se configurado
    if PluginManager.Config.Logging.AlertOn.SecurityIncident and 
       eventType:find("SECURITY") then
        if _G.NexusNotifications then
            _G.NexusNotifications:Warning(
                "Plugin Security",
                eventType .. ": " .. details,
                5
            )
        end
    end
    
    PluginManager.State.SecurityIncidents = PluginManager.State.SecurityIncidents + 1
end

function PluginManager:RegisterPlugin(pluginData)
    local pluginId = pluginData.id or "PLUGIN_" .. tostring(math.random(100000, 999999))
    
    -- Verificar se já existe
    if PluginManager.State.Plugins[pluginId] then
        return false, "Plugin already registered"
    end
    
    -- Validar dados do plugin
    if not pluginData.name or not pluginData.version then
        return false, "Invalid plugin data"
    end
    
    -- Verificação de segurança
    if PluginManager.Config.Security.PluginVerification then
        local securityCheck = self:SecurityCheckPlugin(pluginData)
        
        if not securityCheck.passed then
            PluginManager:LogSecurityEvent("PLUGIN_REJECTED",
                "Plugin " .. pluginData.name .. " failed security check: " ..
                securityCheck.reason)
            
            return false, "Security check failed: " .. securityCheck.reason
        end
    end
    
    -- Verificar assinatura
    if PluginManager.Config.Security.SignatureVerification.RequireSignatures then
        local signature = pluginData.signature
        local keyId = pluginData.signatureKey
        
        if not signature or not keyId then
            return false, "Missing signature"
        end
        
        local valid, reason = SignatureVerifier:VerifySignature(pluginData, signature, keyId)
        if not valid then
            PluginManager:LogSecurityEvent("INVALID_SIGNATURE",
                "Plugin " .. pluginData.name .. " has invalid signature: " .. reason)
            
            return false, "Invalid signature: " .. reason
        end
    end
    
    -- Determinar nível de confiança
    local trustLevel = PluginManager.Config.Repository.TrustLevels[pluginData.trustLevel] or 3
    
    -- Criar sandbox
    local sandbox = AdvancedSandbox:CreateSandbox(pluginId, trustLevel)
    if not sandbox then
        return false, "Failed to create sandbox"
    end
    
    -- Registrar plugin
    PluginManager.State.Plugins[pluginId] = {
        id = pluginId,
        name = pluginData.name,
        version = pluginData.version,
        description = pluginData.description,
        author = pluginData.author,
        trustLevel = trustLevel,
        sandboxId = sandbox.id,
        code = pluginData.code,
        dependencies = pluginData.dependencies or {},
        installedAt = os.time(),
        lastUsed = os.time(),
        enabled = false,
        securityScore = 100 -- Começa com pontuação máxima
    }
    
    PluginManager.State.LoadedPlugins = PluginManager.State.LoadedPlugins + 1
    
    PluginManager:LogSecurityEvent("PLUGIN_REGISTERED",
        "Plugin registered: " .. pluginData.name .. " v" .. pluginData.version)
    
    return true, pluginId
end

function PluginManager:SecurityCheckPlugin(pluginData)
    local check = {
        passed = true,
        reasons = {},
        riskScore = 0
    }
    
    -- Análise de código estático
    if PluginManager.Config.Security.CodeAnalysis.StaticAnalysis and pluginData.code then
        local analysis = CodeAnalyzer:AnalyzeCode(pluginData.code, pluginData.id or "unknown")
        
        if not analysis.passed then
            check.passed = false
            table.insert(check.reasons, "Static analysis failed")
            check.riskScore = check.riskScore + analysis.totalRisk
        end
        
        if #analysis.maliciousPatterns > 0 then
            check.passed = false
            table.insert(check.reasons, "Malicious patterns detected")
            check.riskScore = check.riskScore + 50
        end
    end
    
    -- Verificar dependências
    if pluginData.dependencies then
        for _, dep in ipairs(pluginData.dependencies) do
            if PluginManager.State.PluginBlacklist[dep] then
                check.passed = false
                table.insert(check.reasons, "Blacklisted dependency: " .. dep)
                check.riskScore = check.riskScore + 30
            end
        end
    end
    
    -- Verificar compatibilidade
    if pluginData.minNexusVersion and pluginData.minNexusVersion > PluginManager.Version then
        check.passed = false
        table.insert(check.reasons, "Incompatible Nexus version")
    end
    
    -- Verificar limite de risco
    if check.riskScore > 50 then
        check.passed = false
    end
    
    return check
end

function PluginManager:LoadPlugin(pluginId)
    local plugin = PluginManager.State.Plugins[pluginId]
    if not plugin then
        return false, "Plugin not found"
    end
    
    -- Verificar se já está carregado
    if plugin.enabled then
        return false, "Plugin already loaded"
    end
    
    -- Verificar dependências
    for _, depId in ipairs(plugin.dependencies) do
        local dep = PluginManager.State.Plugins[depId]
        if not dep or not dep.enabled then
            return false, "Missing dependency: " .. depId
        end
    end
    
    print("[PluginManager] Loading plugin:", plugin.name)
    
    -- Executar código no sandbox
    local success, result = AdvancedSandbox:ExecuteInSandbox(pluginId, plugin.code)
    
    if not success then
        PluginManager.State.FailedPlugins = PluginManager.State.FailedPlugins + 1
        
        PluginManager:LogSecurityEvent("PLUGIN_LOAD_FAILED",
            "Plugin " .. plugin.name .. " failed to load: " .. result)
        
        return false, result
    end
    
    plugin.enabled = true
    plugin.lastUsed = os.time()
    
    PluginManager:LogSecurityEvent("PLUGIN_LOADED",
        "Plugin loaded: " .. plugin.name)
    
    return true, result
end

function PluginManager:UnloadPlugin(pluginId)
    local plugin = PluginManager.State.Plugins[pluginId]
    if not plugin or not plugin.enabled then
        return false, "Plugin not loaded"
    end
    
    print("[PluginManager] Unloading plugin:", plugin.name)
    
    -- Desativar plugin
    plugin.enabled = false
    
    -- Parar sandbox
    local sandbox = AdvancedSandbox:GetSandboxByPluginId(pluginId)
    if sandbox then
        sandbox.status = "INACTIVE"
        
        -- Parar monitores
        for _, monitor in pairs(sandbox.monitors) do
            if monitor then
                pcall(task.cancel, monitor)
            end
        end
    end
    
    PluginManager:LogSecurityEvent("PLUGIN_UNLOADED",
        "Plugin unloaded: " .. plugin.name)
    
    return true
end

function PluginManager:InstallFromRepository(pluginId, version)
    local success, pluginCode = RepositorySystem:DownloadPlugin(pluginId, version)
    if not success then
        return false, pluginCode -- pluginCode contém mensagem de erro
    end
    
    -- Obter metadados do plugin
    local pluginInfo = RepositorySystem:GetPluginById(pluginId)
    if not pluginInfo then
        return false, "Plugin info not found"
    end
    
    -- Preparar dados do plugin
    local pluginData = {
        id = pluginId,
        name = pluginInfo.name,
        version = version or pluginInfo.version,
        description = pluginInfo.description,
        author = pluginInfo.author,
        trustLevel = pluginInfo.trustLevel,
        code = pluginCode,
        dependencies = pluginInfo.dependencies or {},
        signature = pluginInfo.signature,
        signatureKey = pluginInfo.signatureKey
    }
    
    -- Registrar plugin
    return self:RegisterPlugin(pluginData)
end

function PluginManager:GetPluginInfo(pluginId)
    local plugin = PluginManager.State.Plugins[pluginId]
    if not plugin then
        return nil
    end
    
    local sandbox = AdvancedSandbox:GetSandboxByPluginId(pluginId)
    
    return {
        id = plugin.id,
        name = plugin.name,
        version = plugin.version,
        description = plugin.description,
        author = plugin.author,
        trustLevel = plugin.trustLevel,
        enabled = plugin.enabled,
        installedAt = plugin.installedAt,
        lastUsed = plugin.lastUsed,
        
        sandbox = sandbox and {
            status = sandbox.status,
            resourceUsage = sandbox.resourceUsage,
            violations = sandbox.violations or {}
        } or nil,
        
        security = {
            incidents = 0, -- Contaria incidentes relacionados
            lastScan = os.time()
        }
    }
end

function PluginManager:GetSystemStatus()
    return {
        initialized = PluginManager.State.Initialized,
        loadedPlugins = PluginManager.State.LoadedPlugins,
        failedPlugins = PluginManager.State.FailedPlugins,
        securityIncidents = PluginManager.State.SecurityIncidents,
        
        sandboxes = {
            total = 0,
            active = 0,
            quarantined = 0,
            killed = 0
        },
        
        repository = {
            catalogSize = #RepositorySystem.PluginCatalog,
            updatesAvailable = 0 -- Contaria atualizações disponíveis
        }
    }
end

function PluginManager:Initialize()
    print("[PluginManager] Initializing advanced plugin system with security...")
    
    -- Carregar configurações
    self.Config = table.clone(self.DefaultConfig)
    
    -- Inicializar sistemas
    CodeAnalyzer:Initialize()
    SignatureVerifier:Initialize()
    RepositorySystem:Initialize()
    
    -- Carregar lista negra
    self:LoadBlacklist()
    
    -- Configurar cache
    if self.Config.Performance.Caching.CacheVerifiedPlugins then
        print("[PluginManager] Plugin caching enabled")
    end
    
    PluginManager.State.Initialized = true
    
    print("[PluginManager] Plugin system initialized")
    print("[PluginManager] Security level:", self.Config.Security.VerificationLevel)
    print("[PluginManager] Sandbox isolation level:", self.Config.Security.Sandboxing.IsolationLevel)
    
    return true
end

function PluginManager:LoadBlacklist()
    local blacklistFile = "NexusOS/Plugins/Blacklist.json"
    
    if isfile and readfile and isfile(blacklistFile) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(blacklistFile))
        })
        
        if success and data then
            PluginManager.State.PluginBlacklist = data
            print("[PluginManager] Loaded blacklist with", #data, "entries")
        end
    end
end

function PluginManager:Shutdown()
    print("[PluginManager] Shutting down plugin system...")
    
    PluginManager.State.Initialized = false
    
    -- Descarregar todos os plugins
    for pluginId, plugin in pairs(PluginManager.State.Plugins) do
        if plugin.enabled then
            self:UnloadPlugin(pluginId)
        end
    end
    
    -- Limpar estado
    PluginManager.State.Plugins = {}
    PluginManager.State.SandboxEnvironments = {}
    
    print("[PluginManager] Plugin system shutdown complete")
end

-- ============ EXPORTAÇÃO ============
if not _G.NexusPluginManager then
    _G.NexusPluginManager = PluginManager
end

return PluginManager
