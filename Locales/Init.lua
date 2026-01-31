--[[
================================================================================
Talon - Localization Initialization System
================================================================================
Description: Modern localization framework with fallback mechanism
Author: YourName
Version: 12.0.0
Architecture: Metatable-based dynamic string lookup
================================================================================
]]--

local ADDON_NAME, addon = ...

-- ============================================================================
-- Namespace Protection
-- ============================================================================

if not addon then
    error("Talon: Failed to initialize addon namespace", 2)
    return
end

-- ============================================================================
-- Localization Registry
-- ============================================================================

---@class LocalizationSystem
---@field private locales table<string, table> Storage for all locale strings
---@field private currentLocale string|nil Current active locale code
---@field private fallbackLocale string Fallback locale (enUS)
local LocalizationSystem = {
    locales = {},
    currentLocale = nil,
    fallbackLocale = "enUS"
}

-- ============================================================================
-- Public API: Register Locale
-- ============================================================================

---Register a locale table for a specific language
---@param locale string Locale code (e.g., "enUS", "zhCN")
---@param strings table Key-value pairs of localized strings
---@return boolean success True if registration succeeded
function LocalizationSystem:RegisterLocale(locale, strings)
    -- Input validation
    if type(locale) ~= "string" or locale == "" then
        print("|cffff0000[Talon Error]|r Invalid locale code: " .. tostring(locale))
        return false
    end
    
    if type(strings) ~= "table" then
        print("|cffff0000[Talon Error]|r Invalid locale data for: " .. locale)
        return false
    end
    
    -- Register locale data
    self.locales[locale] = strings
    return true
end

-- ============================================================================
-- Public API: Get Localized String
-- ============================================================================

---Get a localized string with fallback support
---@param key string Localization key
---@return string localizedString The localized string or key if not found
function LocalizationSystem:GetString(key)
    -- Validate input
    if type(key) ~= "string" then
        return tostring(key)
    end
    
    -- Try current locale
    local currentStrings = self.locales[self.currentLocale]
    if currentStrings and currentStrings[key] then
        return currentStrings[key]
    end
    
    -- Try fallback locale (enUS)
    local fallbackStrings = self.locales[self.fallbackLocale]
    if fallbackStrings and fallbackStrings[key] then
        return fallbackStrings[key]
    end
    
    -- Return key itself as last resort
    return key
end

-- ============================================================================
-- Initialization
-- ============================================================================

---Initialize the localization system with current client locale
---@return boolean success True if initialization succeeded
function LocalizationSystem:Initialize()
    -- Get client locale safely
    local clientLocale = GetLocale()
    
    if not clientLocale or clientLocale == "" then
        print("|cffff9900[Talon Warning]|r Could not detect client locale, using enUS")
        clientLocale = "enUS"
    end
    
    self.currentLocale = clientLocale
    
    return true
end

-- ============================================================================
-- Metatable for Easy Access
-- ============================================================================

---Metatable to allow direct access via addon.L.KEY
local LocalizationMetatable = {
    __index = function(t, key)
        return LocalizationSystem:GetString(key)
    end
}

-- Create the L table with metatable
addon.L = setmetatable({}, LocalizationMetatable)

-- ============================================================================
-- Public Interface
-- ============================================================================

---Public function to register locales from locale files
---@param locale string Locale code
---@param strings table Locale strings
function addon:RegisterLocale(locale, strings)
    return LocalizationSystem:RegisterLocale(locale, strings)
end

-- Initialize the system
LocalizationSystem:Initialize()

-- ============================================================================
-- Debug Support (disabled in production)
-- ============================================================================

-- Expose system for debugging only (set to false for production)
if false then
    addon.LocalizationSystem = LocalizationSystem
end