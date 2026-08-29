-- ==========================================
-- KENOPSIA HUB - UI MODULE
-- ==========================================

-- Use the debug module from global (set by BuildAndCrush.lua loader)
local Debug = _G.KenopsiaDebug
if not Debug then
    Debug = {
        Info = function() end,
        Success = function() end,
        Error = function() end,
        Warning = function() end,
        Debug = function() end
    }
end

-- Load Fluent UI library with proper error handling
local Fluent = nil
local fluentLoaded, fluentErr = pcall(function()
    local content = game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
    if not content or content == "" then
        return nil
    end
    local fn = loadstring(content)
    if not fn then
        return nil
    end
    Fluent = fn()
end)

if not Fluent then
    if Debug.Error then Debug:Error("Failed to load Fluent library: " .. tostring(fluentErr)) end
    return nil
end

-- Load SaveManager addon
local SaveManager = nil
pcall(function()
    local content = game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
    if content and content ~= "" then
        local fn = loadstring(content)
        if fn then SaveManager = fn() end
    end
end)

if not SaveManager then
    if Debug.Warning then Debug:Warning("Failed to load SaveManager addon") end
end

-- Load InterfaceManager addon
local InterfaceManager = nil
pcall(function()
    local content = game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
    if content and content ~= "" then
        local fn = loadstring(content)
        if fn then InterfaceManager = fn() end
    end
end)

if not InterfaceManager then
    if Debug.Warning then Debug:Warning("Failed to load InterfaceManager addon") end
end

if Debug.Success then Debug:Success("Fluent libraries loaded successfully") end

local Window = Fluent:CreateWindow({
    Title = "Kenopsia HUB | Build & Crush",
    SubTitle = "Have a nice day!",
    TabWidth = 120,
    Size = UDim2.fromOffset(530, 450),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Store = Window:AddTab({ Title = "Store", Icon = "shopping-cart" }),
    Misc = Window:AddTab({ Title = "MISC", Icon = "wrench" }),
    Monitoring = Window:AddTab({ Title = "Monitoring", Icon = "activity" }),
    Bypass = Window:AddTab({ Title = "Bypass", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

if Debug.Debug then Debug:Debug("Created UI tabs") end

local HUB = {
    Fluent = Fluent,
    Window = Window,
    Tabs = Tabs,
    SaveManager = SaveManager or {},
    InterfaceManager = InterfaceManager or {},
    State = {
        selectedItems = {},
        serverStockCache = {},
        bufferCache = {},
        autoBuyActive = false,
        smartStockActive = true,
        antiAfkActive = true,
        autoReconnectActive = true,
        optimizeFpsActive = false,
        audioAlertActive = true,
        streamproofActive = false,
        webhookUrl = "",
        minCoinThreshold = 0,
        buyDelay = 0.2,
        currentLang = "English",
        sessionStats = { itemsBought = 0, startTime = os.time() },
        logHistory = {},
        addLog = nil
    }
}

-- Helper function to clean display names
HUB.getCleanDisplayName = function(rawName)
    if not rawName then return "Unknown" end
    local clean = rawName:gsub("(%l)(%u)", "%1 %2"):gsub("%-t%d+", ""):gsub("%-", " ")
    return clean:gsub("(%a)([%w_']*)", function(first, rest) 
        return first:upper() .. rest:lower() 
    end)
end

-- ==================== FLOATING BUTTON ====================
-- Wrap in pcall so floating button errors don't abort the whole UI module
if Debug.Debug then Debug:Debug("Creating floating button...") end

local floatingSuccess = pcall(function()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KenopsiaFloatingGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Parent = screenGui
    toggleBtn.Size = UDim2.fromOffset(50, 50)
    toggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    toggleBtn.Active = true
    toggleBtn.Draggable = true

    local corner = Instance.new("UICorner", toggleBtn)
    corner.CornerRadius = UDim.new(0, 12)

    -- Try to load logo
    local logoUrl = "https://raw.githubusercontent.com/KenopsiaHUB-101/Kenopsia-Hub/main/logo.png"
    local logoPath = "kenopsia_logo.png"

    pcall(function()
        if getcustomasset and writefile and isfile then
            if not isfile(logoPath) then
                local logoData = game:HttpGet(logoUrl, true)
                if logoData then
                    writefile(logoPath, logoData)
                    if Debug.Debug then Debug:Debug("Logo saved to file") end
                end
            end
            if isfile(logoPath) then
                toggleBtn.Image = getcustomasset(logoPath)
                if Debug.Success then Debug:Success("Kenopsia Logo loaded successfully") end
            end
        end
    end)

    -- Direct toggle: call Fluent's built-in Minimize() which flips
    -- Window.Minimized and Window.Root.Visible. This is far more reliable
    -- than simulating keypresses (VirtualInputManager:SendKeyEvent) which
    -- can double-toggle on mobile and interfere with the analog joystick /
    -- jump buttons.
    local isToggling = false
    local function safeToggleUI()
        if isToggling then return end
        isToggling = true
        pcall(function()
            if Window and Window.Minimize then
                Window:Minimize()
            end
        end)
        task.wait(0.25)
        isToggling = false
    end

    -- Handle button input - use MouseButton1Click + Activated for maximum
    -- compatibility across PC and mobile executors.
    -- (TouchEnded is not available on all executors and causes crashes.)
    -- The isToggling debounce above prevents double-toggle when both events fire.
    pcall(function()
        toggleBtn.MouseButton1Click:Connect(function()
            safeToggleUI()
        end)
    end)
    
    pcall(function()
        toggleBtn.Activated:Connect(function()
            safeToggleUI()
        end)
    end)

    HUB.FloatingButton = screenGui
end)

if floatingSuccess then
    if Debug.Success then Debug:Success("Floating button created successfully") end
else
    if Debug.Warning then Debug:Warning("Floating button failed to create (UI will still work, use RightCtrl to toggle)") end
end

-- ==================== NOTIFICATION ====================
pcall(function()
    Fluent:Notify({ 
        Title = "Kenopsia HUB", 
        Content = "UI loaded successfully! Premium features available.", 
        Duration = 4 
    })
end)

-- ==================== BYPASS TAB (PREMIUM ONLY) ====================
-- This tab uses _G.KenopsiaBypass (set by bypass.lua) to provide:
--   1. A button for each bypass feature
--   2. A detection safety check before running each feature
--   3. If SAFE  -> green confirmation notification
--   4. If CAUTION / DANGEROUS -> Fluent Dialog with Cancel / Continue buttons
-- The bypass module is only loaded for premium keys with the "bypass" feature,
-- so we guard the whole tab with a check.
pcall(function()
    local Bypass = _G.KenopsiaBypass
    local Premium = _G.KenopsiaPremium

    -- Helper: get the Fluent interface library from globals (Fluent is local
    -- to this module, so we use it directly).
    local FluentLib = Fluent

    if Bypass and Premium and Premium:HasFeature("bypass") then
        if Debug.Success then Debug:Success("Building Bypass tab (premium access confirmed)") end

        -- Header paragraph
        Tabs.Bypass:AddParagraph({
            Title = "🛡️ Anti-Cheat Bypass Suite",
            Content = "Each feature runs a detection safety check first. Safe features execute instantly. Dangerous features show a Cancel / Continue dialog."
        })

        -- Status paragraph (updated as features run)
        local StatusParagraph = Tabs.Bypass:AddParagraph({
            Title = "⚡ Bypass Status",
            Content = "Auto-bypass (safe features) runs automatically on load.\nAdvanced & permission features require manual activation below."
        })

        -- Helper: format the safety reasons into a readable string for the dialog
        local function formatReasons(reasons)
            local text = ""
            for _, r in ipairs(reasons) do
                text = text .. "• " .. r .. "\n"
            end
            return text ~= "" and text or "No specific reasons reported."
        end

        -- Core handler: called when any bypass button is pressed.
        -- Runs the safety check, then either notifies (SAFE) or shows
        -- a Cancel/Continue dialog (CAUTION / DANGEROUS).
        local function activateBypassFeature(feature)
            if not Bypass or not Bypass.CheckSafety then
                if Debug.Error then Debug:Error("Bypass module not ready") end
                return
            end

            -- Run the safety analysis (does NOT execute the bypass)
            local assessment = Bypass.CheckSafety(feature.name)
            local levelInfo = Bypass.SafetyChecker:GetLevelInfo(assessment.level)

            if Debug.Info then
                Debug:Info("Bypass safety: " .. feature.label .. " = " .. assessment.level)
            end

            -- If SAFE: execute immediately and show green confirmation
            if assessment.safe then
                local result = Bypass.ExecuteWithSafety(feature.name, true)
                pcall(function()
                    FluentLib:Notify({
                        Title = "✅ SAFE — " .. levelInfo.label,
                        Content = feature.label .. " activated successfully.\n" .. (assessment.reasons[1] or "No issues detected."),
                        Duration = 5
                    })
                end)
                if Debug.Success then
                    Debug:Success("Bypass activated (SAFE): " .. feature.label)
                end
                return
            end

            -- CAUTION or DANGEROUS: show Cancel / Continue dialog
            local dialogTitle = levelInfo.color .. " " .. levelInfo.label .. " — " .. feature.label
            local dialogContent = levelInfo.description .. "\n\n" .. formatReasons(assessment.reasons)

            -- Build the dialog content. Fluent Dialogs auto-size width but
            -- have a max width; we keep the content concise.
            if #dialogContent > 350 then
                dialogContent = dialogContent:sub(1, 347) .. "..."
            end

            pcall(function()
                Window:Dialog({
                    Title = dialogTitle,
                    Content = dialogContent,
                    Buttons = {
                        {
                            Title = "Continue",
                            Callback = function()
                                -- Force-execute even though it's dangerous
                                local result = Bypass.ExecuteWithSafety(feature.name, true)
                                if result and result.executed then
                                    pcall(function()
                                        FluentLib:Notify({
                                            Title = "Bypass Executed",
                                            Content = feature.label .. " has been activated (forced).",
                                            Duration = 5
                                        })
                                    end)
                                    if Debug.Success then
                                        Debug:Success("Bypass force-activated: " .. feature.label)
                                    end
                                else
                                    pcall(function()
                                        FluentLib:Notify({
                                            Title = "Bypass Failed",
                                            Content = feature.label .. " could not be activated.",
                                            Duration = 5
                                        })
                                    end)
                                    if Debug.Warning then
                                        Debug:Warning("Bypass failed: " .. feature.label)
                                    end
                                end
                            end
                        },
                        {
                            Title = "Cancel",
                            Callback = function()
                                pcall(function()
                                    FluentLib:Notify({
                                        Title = "Cancelled",
                                        Content = feature.label .. " was not activated.",
                                        Duration = 3
                                    })
                                end)
                                if Debug.Info then
                                    Debug:Info("User cancelled bypass: " .. feature.label)
                                end
                            end
                        }
                    }
                })
            end)
        end

        -- Group features by category and create buttons
        local categories = {
            { key = "standard",   title = "🔧 Standard Bypasses",     desc = "Low-risk bypass features. Auto-applied on load but can be re-run manually." },
            { key = "advanced",   title = "⚡ Advanced Bypasses",      desc = "Core script elevation & metamethod hooks. Requires manual activation." },
            { key = "permissions", title = "🔑 RobloxScript Permissions", desc = "⚠️ HIGH RISK — These can leak session cookies or make real transactions. Use with extreme caution." },
        }

        for _, cat in ipairs(categories) do
            -- Add a section header for each category
            Tabs.Bypass:AddParagraph({
                Title = cat.title,
                Content = cat.desc
            })

            -- Add a button for each feature in this category
            for _, feat in ipairs(Bypass.BypassFeatures) do
                if feat.category == cat.key then
                    Tabs.Bypass:AddButton({
                        Title = feat.label,
                        Callback = function()
                            activateBypassFeature(feat)
                        end
                    })
                end
            end
        end

        -- Add a "Run All Safe Bypasses" button at the bottom
        Tabs.Bypass:AddParagraph({
            Title = "🔄 Quick Actions",
            Content = "Re-run all safe (green) bypass features at once."
        })

        Tabs.Bypass:AddButton({
            Title = "Run All Safe Bypasses",
            Callback = function()
                if Debug.Info then Debug:Info("Manual: running all safe bypasses") end
                pcall(function()
                    FluentLib:Notify({
                        Title = "Running Safe Bypasses",
                        Content = "Re-applying all low-risk bypass features...",
                        Duration = 3
                    })
                end)
                -- Run auto-bypass sequence again (safe features only)
                if Bypass.RunAutoBypass then
                    task.spawn(function()
                        Bypass.RunAutoBypass()
                    end)
                end
            end
        })

        -- Add a "Check All Safety" button that reports the status of every feature
        Tabs.Bypass:AddButton({
            Title = "Check All Safety Levels",
            Callback = function()
                local counts = { SAFE = 0, CAUTION = 0, DANGEROUS = 0, UNKNOWN = 0 }
                for _, feat in ipairs(Bypass.BypassFeatures) do
                    local a = Bypass.CheckSafety(feat.name)
                    if counts[a.level] then
                        counts[a.level] = counts[a.level] + 1
                    else
                        counts.UNKNOWN = counts.UNKNOWN + 1
                    end
                end
                local summary = string.format(
                    "🟢 SAFE: %d  |  🟡 CAUTION: %d  |  🔴 DANGEROUS: %d",
                    counts.SAFE, counts.CAUTION, counts.DANGEROUS
                )
                pcall(function()
                    FluentLib:Notify({
                        Title = "Safety Report",
                        Content = summary,
                        Duration = 8
                    })
                end)
                if Debug.Info then Debug:Info("Safety report: " .. summary) end
            end
        })

        if Debug.Success then Debug:Success("Bypass tab built with " .. #Bypass.BypassFeatures .. " features") end
    else
        -- Premium bypass not available — show a locked message
        Tabs.Bypass:AddParagraph({
            Title = "🔒 Bypass Suite Locked",
            Content = "The bypass suite is a premium feature.\nUpgrade your key to access anti-cheat bypass capabilities."
        })

        Tabs.Bypass:AddButton({
            Title = "Check Premium Status",
            Callback = function()
                local isPrem = Premium and Premium.isPremium or false
                local hasBypass = false
                if Premium and Premium.HasFeature then
                    hasBypass = Premium:HasFeature("bypass")
                end
                pcall(function()
                    FluentLib:Notify({
                        Title = "Premium Status",
                        Content = "Premium: " .. tostring(isPrem) .. "\nBypass access: " .. tostring(hasBypass),
                        Duration = 6
                    })
                end)
            end
        })
    end
end)

if Debug.Success then Debug:Success("UI module initialization complete") end

return HUB
