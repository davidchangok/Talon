--[[
================================================================================
Talon - English (US) Localization
================================================================================
Description: English locale strings for all UI and system messages
Author: YourName
Version: 12.0.0
Locale: enUS (English - United States)
================================================================================
]]--

local _, addon = ...

-- ============================================================================
-- English Localization Registration
-- ============================================================================

addon:RegisterLocale("enUS", {
    
    -- ========================================================================
    -- System Messages
    -- ========================================================================
    ["ADDON_LOADED"] = "|cff00ffff[Talon]|r v%s loaded. Tracking %d achievements across %d expansions.",
    ["INDEXING_START"] = "|cff00ffff[Talon]|r Building quest index...",
    ["INDEXING_COMPLETE"] = "|cff00ffff[Talon]|r Index built: %d quests ready for tracking.",
    ["INDEXING_ERROR"] = "|cffff0000[Talon Error]|r Failed to build quest index.",
    
    -- ========================================================================
    -- Achievement Notification (UIErrorsFrame)
    -- ========================================================================
    ["RELATED_ACHIEVEMENT"] = "Related Achievement: %s",
    ["ACHIEVEMENT_PROGRESS"] = "%s (%d/%d)",
    ["CUSTOM_WATCH"] = "Custom Watch",
    ["QUEST_ID_PREFIX"] = "Quest ",
    
    -- ========================================================================
    -- Configuration UI
    -- ========================================================================
    ["CFG_TITLE"] = "Talon - Daily Quest Achievement Tracker",
    ["CFG_DESC"] = "Configure which expansions to track. Uncheck to disable notifications for that expansion.",
    ["CFG_PANEL_TITLE"] = "Talon Daily & Achievement Tracker",
    ["CFG_HEADER_FILTERS"] = "Expansion Filters",
    ["CFG_HEADER_OPTIONS"] = "Display Options",
    ["CFG_ENABLE_TRACKING"] = "Enable Tracking",
    ["CFG_ENABLE_TRACKING_DESC"] = "Scan map for world quests",
    ["CFG_SHOW_COMPLETED"] = "Show Completed Achievements",
    ["CFG_SHOW_COMPLETED_DESC"] = "Display notifications even if the achievement is already completed.",
    ["CFG_TRACK_CHAR_ONLY"] = "Track Character Achievements Only",
    ["CFG_TRACK_CHAR_ONLY_DESC"] = "If enabled, tracks achievements not completed by this character, ignoring account-wide progress.",
    ["CFG_ENABLE_SOUND"] = "Enable Sound Alerts",
    ["CFG_ENABLE_SOUND_DESC"] = "Play a sound when achievement-related quests are detected.",
    ["CFG_DEBUG_MODE"] = "Debug Mode",
    ["CFG_DEBUG_MODE_DESC"] = "Enable verbose debug output to chat window.",
    ["CFG_DEBOUNCE_TIME"] = "Anti-Spam Duration",
    ["CFG_DEBOUNCE_TIME_DESC"] = "Prevent duplicate notifications for the same achievement within this time (seconds).",
    ["CFG_RESET_FILTERS"] = "Reset All Filters",
    ["CFG_RESET_FILTERS_DESC"] = "Enable all expansion filters.",
    ["CFG_STATS"] = "Statistics",
    ["CFG_STATS_DESC"] = "Tracking %d achievements with %d quests across %d expansions.",
    ["CFG_HEADER_CUSTOM_QUESTS"] = "Custom Quest Tracking",
    ["CFG_CUSTOM_QUESTS_DESC"] = "Add specific daily quest IDs here to prioritize them during scans.",
    ["CFG_ADD_QUEST"] = "Add Quest ID",
    ["CFG_ADD_QUEST_HINT"] = "(Enter Quest ID)",
    ["CFG_MANUAL_SCAN"] = "Manual Scan",
    ["CFG_ADD_ACHIEVEMENT_ID"] = "Add Achievement ID",
    ["CFG_HEADER_SESSION_RESULTS"] = "Session Scan Results",
    ["CFG_EXPORT"] = "Export List",
    ["CFG_EXPORT_TITLE"] = "Talon Custom Quests (Ctrl+C to copy):",
    ["CFG_BTN_DELETE"] = "Delete",
    
    -- ========================================================================
    -- Feedback Messages & Formats
    -- ========================================================================
    ["MSG_QUEST_EXISTS"] = "|cffff0000[Talon]|r Quest ID %s already exists.",
    ["MSG_ACHIEVEMENT_COMPLETED"] = "|cffff0000[Talon]|r Achievement already completed.",
    ["MSG_ACH_NO_QUESTS"] = "|cffff0000[Talon]|r No quests found for this achievement.",
    ["MSG_ADDED_QUEST_FROM_ACH"] = "|cff00ff00[Talon]|r Added quest from achievement: %s",
    ["MSG_ALL_ACH_QUESTS_COMPLETED"] = "|cffff0000[Talon]|r All quests for this achievement are completed.",
    ["LIST_PREFIX_FOUND"] = "|cff00ffff[Talon]|r Found: ",
    ["LIST_PREFIX_ACHIEVEMENT"] = "- Achievement: ",
    ["UNKNOWN"] = "Unknown",
    ["LOADING"] = "Loading...",
    ["UNKNOWN_ACHIEVEMENT"] = "Unknown Achievement",
    ["FOUND_TARGET_FORMAT"] = "|cff00ffff[Talon]|r Found: %s - Achievement: %s%s",
    
    -- ========================================================================
    -- Expansion Labels (Dynamically Generated)
    -- ========================================================================
    ["EXP_Legacy/Classic"] = "Legacy & Classic",
    ["EXP_The Burning Crusade"] = "The Burning Crusade",
    ["EXP_Wrath of the Lich King"] = "Wrath of the Lich King",
    ["EXP_Cataclysm"] = "Cataclysm",
    ["EXP_Mists of Pandaria"] = "Mists of Pandaria",
    ["EXP_Warlords of Draenor"] = "Warlords of Draenor",
    ["EXP_Legion"] = "Legion",
    ["EXP_Battle for Azeroth"] = "Battle for Azeroth",
    ["EXP_Shadowlands"] = "Shadowlands",
    ["EXP_Dragonflight"] = "Dragonflight",
    ["EXP_The War Within"] = "The War Within",
    ["EXP_TWW"] = "The War Within",
    ["EXP_DF"] = "Dragonflight",
    ["EXP_SL"] = "Shadowlands",
    ["EXP_BfA"] = "Battle for Azeroth",
    ["EXP_WoD"] = "Warlords of Draenor",
    ["EXP_MoP"] = "Mists of Pandaria",
    ["EXP_Cata"] = "Cataclysm",
    ["EXP_WotLK"] = "Wrath of the Lich King",
    ["EXP_TBC"] = "The Burning Crusade",
    ["EXP_Vanilla"] = "Classic / Vanilla",
    ["EXP_Midnight"] = "Midnight",
    
    -- ========================================================================
    -- Error Messages
    -- ========================================================================
    ["ERROR_NO_DATA"] = "Data file not loaded. Please reinstall the addon.",
    ["ERROR_INVALID_QUEST"] = "Invalid quest ID detected.",
    ["ERROR_API_FAIL"] = "Achievement API call failed.",
    ["ERROR_DB_CORRUPT"] = "Saved settings corrupted, resetting to defaults.",
    
    -- ========================================================================
    -- Slash Commands
    -- ========================================================================
    ["CMD_HELP"] = "Talon Commands:",
    ["CMD_CONFIG"] = "/talon config - Open settings",
    ["CMD_STATS"] = "/talon stats - Show statistics",
    ["CMD_RESET"] = "/talon reset - Reset session notifications",
    ["CMD_TOGGLE"] = "/talon toggle - Toggle tracking on/off",
    ["CMD_STATUS"] = "/talon status - Show current status",
    ["CMD_SCAN"] = "|cff00ff00/talon scan|r - Manually scan world quests",
    
    -- ========================================================================
    -- Status Messages
    -- ========================================================================
    ["STATUS_ENABLED"] = "|cff00ff00Enabled|r",
    ["STATUS_DISABLED"] = "|cffff0000Disabled|r",
    ["STATUS_TRACKING"] = "Tracking: %s",
    ["STATUS_EXPANSIONS"] = "Active Expansions: %s",
    ["STATUS_NOTIFIED"] = "Notified This Session: %d achievements",
    ["SCAN_START"] = "|cff00ffff[Talon]|r Scanning...",
    ["SESSION_RESET"] = "|cff00ffff[Talon]|r Session history reset.",
    ["FILTERS_RESET_MSG"] = "|cff00ffff[Talon]|r All expansion filters enabled.",
    ["SETTINGS_API_MISSING"] = "|cffff9900[Talon]|r Settings API not available. Using legacy interface.",
    ["CONFIG_REFRESHED"] = "|cff00ffff[Talon]|r Configuration refreshed",
    ["DB_LOAD_SUMMARY"] = "|cffff9900[Talon]|r Database loaded: %d valid, %d invalid entries removed",
    
})