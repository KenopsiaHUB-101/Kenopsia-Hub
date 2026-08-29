-- ==========================================
-- KENOPSIA HUB - PREMIUM KEY SYSTEM
-- ==========================================

local Premium = {
    validKeys = {
        ["kenopsia_hub123"] = { 
            name = "Master Key",
            tier = "PREMIUM",
            features = { "bypass", "shop", "misc", "monitoring", "settings" },
            createdAt = os.time()
        }
    },
    currentKey = nil,
    isPremium = false,
    premiumFeatures = { "bypass" }
}

-- Validate key
function Premium:ValidateKey(key)
    if not key or type(key) ~= "string" then
        return false, "Invalid key format"
    end
    
    local trimmedKey = key:gsub("%s+", "")
    if self.validKeys[trimmedKey] then
        self.currentKey = trimmedKey
        self.isPremium = true
        local keyData = self.validKeys[trimmedKey]
        return true, keyData
    end
    
    return false, "Key not found or expired"
end

-- Check if key has access to feature
function Premium:HasFeature(feature)
    if not self.isPremium then
        return false
    end
    
    local keyData = self.validKeys[self.currentKey]
    if not keyData then
        return false
    end
    
    for _, f in ipairs(keyData.features) do
        if f == feature then
            return true
        end
    end
    
    return false
end

-- Add new key (for admin use)
function Premium:AddKey(key, name, tier, features)
    if not key or not name then return false end
    
    self.validKeys[key] = {
        name = name,
        tier = tier or "FREE",
        features = features or {},
        createdAt = os.time()
    }
    
    return true
end

-- Remove key
function Premium:RemoveKey(key)
    if self.validKeys[key] then
        self.validKeys[key] = nil
        if self.currentKey == key then
            self.currentKey = nil
            self.isPremium = false
        end
        return true
    end
    return false
end

-- Get key info
function Premium:GetKeyInfo()
    if not self.currentKey then
        return nil
    end
    
    return self.validKeys[self.currentKey]
end

-- Reset current key
function Premium:ResetKey()
    self.currentKey = nil
    self.isPremium = false
end

-- Expose to global
_G.KenopsiaPremium = Premium

return Premium
