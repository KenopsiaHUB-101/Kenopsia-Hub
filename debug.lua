-- ==========================================
-- KENOPSIA HUB - DEBUG MODULE
-- ==========================================

local Debug = {
    enabled = true,
    showInfo = true,
    showSuccess = true,
    showWarning = true,
    showError = true,
    showDebug = false,
    prefix = "[KENOPSIA]",
}

-- Console output function (plain text, no ANSI codes - Roblox console doesn't support them)
function Debug:_print(level, message)
    if not self.enabled then return end
    local output = string.format("%s [%s] %s", self.prefix, level, message)
    print(output)
end

-- Info level (General information)
function Debug:Info(message)
    if not self.showInfo then return end
    self:_print("INFO", message)
end

-- Success level (Operation completed successfully)
function Debug:Success(message)
    if not self.showSuccess then return end
    self:_print("SUCCESS", message)
end

-- Warning level (Warning, but not critical)
function Debug:Warning(message)
    if not self.showWarning then return end
    self:_print("WARN", message)
end

-- Error level (Critical errors)
function Debug:Error(message)
    if not self.showError then return end
    self:_print("ERROR", message)
end

-- Debug level (Detailed debugging info)
function Debug:Debug(message)
    if not self.showDebug then return end
    self:_print("DEBUG", message)
end

-- Table dump (For debugging complex data)
function Debug:DumpTable(tbl, indent)
    if not self.showDebug then return end
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            print(prefix .. key .. " = {")
            self:DumpTable(value, indent + 1)
            print(prefix .. "}")
        else
            print(prefix .. key .. " = " .. tostring(value))
        end
    end
end

-- Toggle functions
function Debug:Toggle()
    self.enabled = not self.enabled
    self:Info("Debug mode " .. (self.enabled and "ENABLED" or "DISABLED"))
end

function Debug:ToggleInfo()
    self.showInfo = not self.showInfo
end

function Debug:ToggleSuccess()
    self.showSuccess = not self.showSuccess
end

function Debug:ToggleWarning()
    self.showWarning = not self.showWarning
end

function Debug:ToggleError()
    self.showError = not self.showError
end

function Debug:ToggleDebug()
    self.showDebug = not self.showDebug
end

-- Safe execution with error logging
function Debug:SafeExecute(func, funcName)
    funcName = funcName or "Unknown Function"
    local success, result = pcall(func)
    if not success then
        self:Error("Failed to execute " .. funcName .. ": " .. tostring(result))
        return nil
    end
    self:Debug("Successfully executed: " .. funcName)
    return result
end

-- Initialize debug system
function Debug:Initialize()
    self:Info("Debug system initialized")
    self:Debug("All debug levels available: Info, Success, Warning, Error, Debug")
end

-- Expose to global
_G.KenopsiaDebug = Debug

return Debug
