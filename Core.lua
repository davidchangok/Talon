--[[
================================================================================
Talon - Core Monitoring Engine (12.0 Retail Fixed)
================================================================================
]]--

local ADDON_NAME, addon = ...
local L = addon.L
addon.sessionMessages = {}

-- 安全获取本地化字符串 (防止返回键名)
local function GetText(key, default)
    local val = L and L[key]
    if not val or val == key then
        return default
    end
    return val
end

-- ============================================================================
-- 数据库初始化 (SavedVariables)
-- ============================================================================
TalonDB = TalonDB or {}
local DB_VERSION = "2.0.0"

local function InitializeDatabase()
    if not TalonDB.version or TalonDB.version ~= DB_VERSION then
        TalonDB = {
            version = DB_VERSION,
            expFilters = {},
            showCompleted = false,
            enableSound = true,
            debounceTime = 3,
            enabled = true,
            sessionNotified = {},
            customQuests = {},
            trackCharacterOnly = false
        }
    end
end

-- ============================================================================
-- 核心扫描类 (适配 12.0 C_AchievementInfo)
-- ============================================================================
local TalonScanner = {
    questLookup = {},
    expansionMaps = {},
    sessionStats = { notifiedCount = 0 }
}

-- 建立任务索引
function TalonScanner:BuildQuestIndex()
    -- 运行时获取全局数据表，避免加载顺序导致的 nil 问题
    ---@diagnostic disable-next-line: undefined-global
    local DailyAchTable = DailyAchTable
    
    if not DailyAchTable then return false end
    
    for _, entry in ipairs(DailyAchTable) do
        local qID = entry.quest
        if qID then
            self.questLookup[qID] = self.questLookup[qID] or {}
            table.insert(self.questLookup[qID], entry)
            
            if entry.map and entry.map > 0 then
                self.expansionMaps[entry.exp] = self.expansionMaps[entry.exp] or {}
                self.expansionMaps[entry.exp][entry.map] = true
            end
        end
    end
    return true
end

-- 判定逻辑：账号完成 vs 角色完成 (修正为 12.0 标准 API)
function TalonScanner:IsAchievementNeeded(achID)
    local isCompleted, wasEarnedByMe
    
    -- 使用 12.0 标准 API
    if C_AchievementInfo and C_AchievementInfo.GetAchievementInfo then
        local achInfo = C_AchievementInfo.GetAchievementInfo(achID)
        if achInfo then
            isCompleted = achInfo.completed
            wasEarnedByMe = achInfo.wasEarnedByMe
        end
    end
    
    if isCompleted == nil and GetAchievementInfo then
        local _, _, _, completed, _, _, _, _, _, _, _, _, earnedByMe = GetAchievementInfo(achID)
        isCompleted = completed
        wasEarnedByMe = earnedByMe
    end
    
    if isCompleted == nil then return false end -- 无法获取成就信息

    if TalonDB.trackCharacterOnly then
        if wasEarnedByMe then return false end -- 当前角色已完成
    else
        if isCompleted then return false end -- 账号已完成
    end

    if not TalonDB.showCompleted and isCompleted then return false end

    return true
end

-- 扫描世界任务
function TalonScanner:ScanWorldQuests()
    if not TalonDB or not TalonDB.enabled then return end

    -- 每次扫描都重置列表，确保列表只显示当前存在的任务 (解决任务过期问题)
    addon.sessionMessages = {}

    local foundQuests = {}
    for expLabel, maps in pairs(self.expansionMaps) do
        if TalonDB.expFilters[expLabel] then
            for mapID, _ in pairs(maps) do
                local taskQuests = C_TaskQuest.GetQuestsOnMap(mapID)
                if taskQuests then
                    for _, info in ipairs(taskQuests) do
                        if info.questID then foundQuests[info.questID] = mapID end
                    end
                end
            end
        end
    end

    -- 辅助函数：添加任务到列表
    local function AddToSessionList(qID, achID, mapID)
        local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(qID)
        if not timeLeft then
            local seconds = C_TaskQuest.GetQuestTimeLeftSeconds(qID)
            if seconds then timeLeft = math.floor(seconds / 60) end
        end
        table.insert(addon.sessionMessages, { qID = qID, achID = achID, mapID = mapID, timeLeft = timeLeft })
    end

    -- 1. 优先处理自定义任务 (Custom Quests)
    if TalonDB.customQuests then
        for _, qID in ipairs(TalonDB.customQuests) do
            if foundQuests[qID] then
                AddToSessionList(qID, nil, foundQuests[qID])
                if not TalonDB.sessionNotified[qID] or self.manualScanActive then
                    self:Notify(qID, nil, foundQuests[qID]) -- 自定义任务通常没有关联成就ID
                end
            end
        end
    end

    for qID, mapID in pairs(foundQuests) do
        local entries = self.questLookup[qID]
        if entries then
            for _, data in ipairs(entries) do
                if self:IsAchievementNeeded(data.ach) then
                    AddToSessionList(qID, data.ach, mapID)
                    if not TalonDB.sessionNotified[qID] or self.manualScanActive then
                        self:Notify(qID, data.ach, mapID)
                    end
                end
            end
        end
    end
    
    if addon.UpdateConfigSessionList then addon.UpdateConfigSessionList() end
    self.manualScanActive = false
end

-- 通知输出
function TalonScanner:Notify(qID, achID, mapID)
    local qName = C_QuestLog.GetTitleForQuestID(qID) or GetText("LOADING", "Loading...")
    
    local achName = GetText("CUSTOM_WATCH", "Custom Watch")
    local aLink = string.format("|cff00ff00[%s]|r", achName)

    if achID then
        if C_AchievementInfo and C_AchievementInfo.GetAchievementInfo then
            local achInfo = C_AchievementInfo.GetAchievementInfo(achID)
            if achInfo then achName = achInfo.title or achInfo.name end
        end
        if (not achName or achName == GetText("UNKNOWN_ACHIEVEMENT", "Unknown Achievement")) and GetAchievementInfo then
            local _, name = GetAchievementInfo(achID)
            if name then achName = name end
        end
        achName = achName or GetText("UNKNOWN_ACHIEVEMENT", "Unknown Achievement")
        aLink = GetAchievementLink(achID) or ("[" .. achName .. "]")
    end

    -- 优化聊天链接显示
    local qLink = GetQuestLink(qID) or ("[" .. qName .. "]")

    local mapName = ""
    if mapID then
        local mapInfo = C_Map.GetMapInfo(mapID)
        if mapInfo and mapInfo.name then
            mapName = " - " .. mapInfo.name
        end
    end

    local msg = string.format(GetText("FOUND_TARGET_FORMAT", "|cff00ffff[Talon]|r Found: %s - Achievement: %s%s"), qLink, aLink, mapName)
    print(msg)

    UIErrorsFrame:AddMessage("Talon: " .. qName, 0, 1, 1, 1, 5)

    if TalonDB.enableSound then PlaySound(12867, "Master") end

    TalonDB.sessionNotified[qID] = true
    self.sessionStats.notifiedCount = self.sessionStats.notifiedCount + 1
end

-- 初始化
function TalonScanner:Init()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    f:RegisterEvent("QUEST_LOG_UPDATE")
    
    f:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_LOGIN" then
            InitializeDatabase()
            TalonDB.sessionNotified = {} -- 每次加载插件时重置提醒状态，防止错过提示
            self:BuildQuestIndex()
            C_Timer.After(3, function() self:ScanWorldQuests() end)
        else
            self:ScanWorldQuests()
        end
    end)
end

TalonScanner:Init()
addon.Scanner = TalonScanner

-- 斜杠命令
SLASH_TALON1 = "/talon"
SlashCmdList["TALON"] = function(msg)
    if msg == "scan" then
        TalonScanner.manualScanActive = true
        TalonScanner:ScanWorldQuests()
    elseif msg == "config" then
        if addon.category then
            Settings.OpenToCategory(addon.category:GetID())
        end
    end
end