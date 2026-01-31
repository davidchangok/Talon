--[[
================================================================================
Talon - Configuration Interface (12.0 Retail Fixed)
================================================================================
]]--

local ADDON_NAME, addon = ...
local L = addon.L

-- 安全获取本地化字符串 (防止返回键名)
local function GetText(key, default)
    local val = L and L[key]
    if not val or val == key then
        return default
    end
    return val
end

local TalonConfigPanel = {
    panel = nil,
    content = nil,
    customListContainer = nil
}

-- ============================================================================
-- 辅助函数 (适配 12.0 模板与 API)
-- ============================================================================

-- 创建标准的勾选框
local function CreateCheckbox(parent, label, tooltip, dbKey)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetChecked(TalonDB[dbKey])
    
    -- 适配 12.0：直接使用模板提供的 Text 引用，移除不安全的 _G 查找
    local text = cb.Text
    if text then
        text:SetText(label)
    end
    
    cb:SetScript("OnClick", function(self)
        TalonDB[dbKey] = self:GetChecked()
        -- 勾选变动时，如果有需要可以触发刷新
        if addon.RefreshConfigPanel then
            addon:RefreshConfigPanel()
        end
    end)
    
    if tooltip then
        cb:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", GameTooltip_Hide)
    end
    return cb
end

-- 更新内容总高度
function TalonConfigPanel:UpdateContentHeight()
    if not self.content then return end
    local top = self.topHeight or 300
    local customH = self.customListContainer and self.customListContainer:GetHeight() or 0
    local bottomBase = self.bottomBaseHeight or 250
    local sessionH = self.sessionListContainer and self.sessionListContainer:GetHeight() or 0
    
    self.content:SetHeight(top + customH + bottomBase + sessionH + 100) -- 增加 Padding 确保底部可见
end

-- 绘制自定义任务列表
function TalonConfigPanel:DrawCustomList()
    if not self.customListContainer then return 0 end
    
    -- 确保任务索引已建立 (修复 PLAYER_LOGIN 竞态条件导致无法显示成就名的问题)
    if addon.Scanner and (not addon.Scanner.questLookup or not next(addon.Scanner.questLookup)) then
        addon.Scanner:BuildQuestIndex()
    end

    -- 清空旧列表
    local kids = {self.customListContainer:GetChildren()}
    for _, child in ipairs(kids) do child:Hide() child:SetParent(nil) end
    
    local ly = 0
    if TalonDB.customQuests then
        for i, qID in ipairs(TalonDB.customQuests) do
            local row = CreateFrame("Frame", nil, self.customListContainer, "BackdropTemplate")
            row:SetSize(480, 30)
            row:SetPoint("TOPLEFT", 0, ly)
            
            row:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            row:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
            row:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            
            local delBtn = CreateFrame("Button", nil, row, "UIPanelCloseButton")
            delBtn:SetSize(20, 20)
            delBtn:SetPoint("LEFT", 5, 0)
            delBtn:SetScript("OnClick", function()
                table.remove(TalonDB.customQuests, i)
                addon:RefreshConfigPanel()
            end)
            
            local name = C_QuestLog.GetTitleForQuestID(qID)
            if not name or name == "" then
                C_QuestLog.RequestLoadQuestByID(qID)
                name = GetText("QUEST_ID_PREFIX", "Quest #") .. qID
            end
            
            -- 任务信息按钮
            local questBtn = CreateFrame("Button", nil, row)
            questBtn:SetHeight(20)
            questBtn:SetPoint("LEFT", delBtn, "RIGHT", 10, 0)
            
            local qText = questBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            qText:SetPoint("LEFT", 0, 0)
            qText:SetText(string.format("|cff00ffff%s|r: %s", qID, name))
            questBtn:SetWidth(qText:GetStringWidth() + 10)
            
            questBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink("quest:" .. qID)
                GameTooltip:Show()
            end)
            questBtn:SetScript("OnLeave", GameTooltip_Hide)

            -- 尝试查找关联成就
            local achID
            if addon.Scanner and addon.Scanner.questLookup and addon.Scanner.questLookup[qID] then
                local entry = addon.Scanner.questLookup[qID][1]
                if entry then achID = entry.ach end
            end

            if achID then
                local achName
                -- 尝试使用现代 API
                if C_AchievementInfo and C_AchievementInfo.GetAchievementInfo then
                    local info = C_AchievementInfo.GetAchievementInfo(achID)
                    if info then achName = info.title or info.name end
                end
                -- 回退到全局 API (如果存在)
                if not achName and GetAchievementInfo then achName = select(2, GetAchievementInfo(achID)) end

                if achName then
                    local achBtn = CreateFrame("Button", nil, row)
                    achBtn:SetHeight(20)
                    achBtn:SetPoint("LEFT", questBtn, "RIGHT", 10, 0)
                    
                    local aText = achBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    aText:SetPoint("LEFT", 0, 0)
                    aText:SetText(string.format("|cffffd700[%s]|r", achName))
                    achBtn:SetWidth(aText:GetStringWidth() + 10)
                    
                    achBtn:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetAchievementByID(achID)
                        GameTooltip:Show()
                    end)
                    achBtn:SetScript("OnLeave", GameTooltip_Hide)
                end
            end
            
            ly = ly - 35
        end
    end
    local finalHeight = math.abs(ly)
    if finalHeight < 1 then finalHeight = 1 end -- 防止高度为0导致布局塌陷
    self.customListContainer:SetHeight(finalHeight)
    self:UpdateContentHeight()
    return ly
end

-- 更新本次扫描结果列表
function TalonConfigPanel:UpdateSessionList()
    if not self.sessionListContainer then return end
    
    local kids = {self.sessionListContainer:GetChildren()}
    for _, child in ipairs(kids) do child:Hide() child:SetParent(nil) end
    
    local ly = 0
    if addon.sessionMessages then
        for _, data in ipairs(addon.sessionMessages) do
            local row = CreateFrame("Frame", nil, self.sessionListContainer)
            row:SetSize(580, 20)
            row:SetPoint("TOPLEFT", 10, ly)
            
            -- 发现目标
            local prefix = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            prefix:SetPoint("LEFT", 0, 0)
            prefix:SetText(GetText("LIST_PREFIX_FOUND", "|cff00ffff[Talon]|r Found: "))
            
            -- 任务链接按钮
            local qName = C_QuestLog.GetTitleForQuestID(data.qID)
            if not qName or qName == "" then
                C_QuestLog.RequestLoadQuestByID(data.qID)
                qName = "Quest #" .. data.qID
            end
            
            local qBtn = CreateFrame("Button", nil, row)
            qBtn:SetHeight(20)
            qBtn:SetPoint("LEFT", prefix, "RIGHT", 2, 0)
            
            local qText = qBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            qText:SetPoint("LEFT", 0, 0)
            qText:SetText("[" .. qName .. "]")
            qBtn:SetWidth(qText:GetStringWidth() + 5)
            
            qBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink("quest:" .. data.qID)
                GameTooltip:Show()
            end)
            qBtn:SetScript("OnLeave", GameTooltip_Hide)
            
            -- 关联成就
            local anchor = qBtn
            if data.achID then
                local mid = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                mid:SetPoint("LEFT", qBtn, "RIGHT", 5, 0)
                mid:SetText(GetText("LIST_PREFIX_ACHIEVEMENT", "- Achievement: "))
                
                local achName
                if C_AchievementInfo and C_AchievementInfo.GetAchievementInfo then
                    local info = C_AchievementInfo.GetAchievementInfo(data.achID)
                    if info then achName = info.title or info.name end
                end
                if not achName and GetAchievementInfo then
                    local _, name = GetAchievementInfo(data.achID)
                    if name then achName = name end
                end
                achName = achName or GetText("UNKNOWN", "Unknown")
                
                local aBtn = CreateFrame("Button", nil, row)
                aBtn:SetHeight(20)
                aBtn:SetPoint("LEFT", mid, "RIGHT", 2, 0)
                
                local aText = aBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                aText:SetPoint("LEFT", 0, 0)
                aText:SetText("[" .. achName .. "]")
                aBtn:SetWidth(aText:GetStringWidth() + 5)
                
                aBtn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetAchievementByID(data.achID)
                    GameTooltip:Show()
                end)
                aBtn:SetScript("OnLeave", GameTooltip_Hide)
                anchor = aBtn
            end
            
            -- 地图名称
            local lastElement = anchor
            if data.mapID then
                local mapInfo = C_Map.GetMapInfo(data.mapID)
                if mapInfo and mapInfo.name then
                    local mapText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    mapText:SetPoint("LEFT", lastElement, "RIGHT", 5, 0)
                    mapText:SetText("- " .. mapInfo.name)
                    lastElement = mapText
                end
            end

            -- 剩余时间
            if data.timeLeft and data.timeLeft > 0 then
                local timeText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                timeText:SetPoint("LEFT", lastElement, "RIGHT", 5, 0)
                
                local h = math.floor(data.timeLeft / 60)
                local m = data.timeLeft % 60
                local timeStr = (h > 0 and (h .. "h ") or "") .. m .. "m"
                timeText:SetText("|cffaaaaaa(" .. timeStr .. ")|r")
            end
            
            ly = ly - 20
        end
    end
    
    local listHeight = math.abs(ly)
    if listHeight < 1 then listHeight = 1 end -- 防止高度为0
    self.sessionListContainer:SetHeight(listHeight)
    
    self:UpdateContentHeight()
end

-- ============================================================================
-- 主面板构建与注册 (适配 12.0 Settings API)
-- ============================================================================

function TalonConfigPanel:CreatePanel()
    local panel = CreateFrame("Frame", "TalonSettingsPanel", UIParent)
    panel:Hide() -- 确保面板初始隐藏，避免在登录或重载时闪烁，等待 Settings API 接管
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(GetText("CFG_PANEL_TITLE", "Talon Daily & Achievement Tracker"))

    -- 创建滚动容器以承载长列表
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame")
    scrollFrame:SetScrollChild(content)
    content:SetWidth(600)
    self.content = content

    -- 绘制设置项
    -- 辅助函数：查找任务关联的成就
    local function GetAchForQuest(questID)
        if DailyAchTable then
            for _, entry in ipairs(DailyAchTable) do
                if entry.quest == questID then return entry.ach end
            end
        end
        return nil
    end

    -- 辅助函数：查找成就关联的任务列表
    local function GetQuestsForAch(achID)
        local quests = {}
        local seen = {}
        if DailyAchTable then
            for _, entry in ipairs(DailyAchTable) do
                if entry.ach == achID and not seen[entry.quest] then
                    table.insert(quests, entry.quest)
                    seen[entry.quest] = true
                end
            end
        end
        return quests
    end

    local y = -10
    local cbEnabled = CreateCheckbox(content, GetText("CFG_ENABLE_TRACKING", "Enable Tracking"), GetText("CFG_ENABLE_TRACKING_DESC", "Scan map for world quests"), "enabled")
    cbEnabled:SetPoint("TOPLEFT", 10, y)
    
    local scanBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    scanBtn:SetSize(100, 22)
    scanBtn:SetPoint("LEFT", cbEnabled, "RIGHT", 250, 0)
    scanBtn:SetText(GetText("CFG_MANUAL_SCAN", "Manual Scan"))
    scanBtn:SetScript("OnClick", function()
        if addon.Scanner then
            addon.Scanner.manualScanActive = true
            addon.Scanner:ScanWorldQuests()
        end
    end)

    local cbCompleted = CreateCheckbox(content, GetText("CFG_SHOW_COMPLETED", "Show Completed Achievements"), GetText("CFG_SHOW_COMPLETED_DESC", "Show quests even if achievement is earned"), "showCompleted")
    cbCompleted:SetPoint("TOPLEFT", 10, y - 30)

    local cbCharOnly = CreateCheckbox(content, GetText("CFG_TRACK_CHAR_ONLY", "Track Character Only"), GetText("CFG_TRACK_CHAR_ONLY_DESC", "Ignore account-wide progress"), "trackCharacterOnly")
    cbCharOnly:SetPoint("TOPLEFT", 10, y - 60)

    y = y - 110

    -- 自定义任务追踪区域
    local customHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customHeader:SetPoint("TOPLEFT", 15, y)
    customHeader:SetText(GetText("CFG_HEADER_CUSTOM_QUESTS", "Custom Quest Tracking"))
    y = y - 25

    -- 创建统一的添加区域 Groupbox
    local addGroup = CreateFrame("Frame", nil, content, "BackdropTemplate")
    addGroup:SetSize(500, 50)
    addGroup:SetPoint("TOPLEFT", 20, y)
    addGroup:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    addGroup:SetBackdropColor(0, 0, 0, 0.3)
    addGroup:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    -- === 任务 ID 输入部分 (左侧) ===
    local inputBox = CreateFrame("EditBox", "TalonAddQuestInput", addGroup, "InputBoxTemplate")
    inputBox:SetSize(100, 20)
    inputBox:SetPoint("TOPLEFT", 15, -15)
    inputBox:SetAutoFocus(false)
    inputBox:SetNumeric(true)
    inputBox:SetTextInsets(5, 5, 0, 0)
    
    inputBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:SetText(GetText("CFG_ADD_QUEST_HINT", "Enter Quest ID"), 1, 1, 1)
        GameTooltip:Show()
    end)
    inputBox:SetScript("OnLeave", GameTooltip_Hide)
    
    local addBtn = CreateFrame("Button", nil, addGroup, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 22)
    addBtn:SetPoint("LEFT", inputBox, "RIGHT", 10, 0)
    addBtn:SetText(GetText("CFG_ADD_QUEST", "Add"))
    
    addBtn:SetScript("OnClick", function()
        local id = tonumber(inputBox:GetText())
        if id and id > 0 then
            if not TalonDB.customQuests then TalonDB.customQuests = {} end
            
            -- 检查重复 ID
            local exists = false
            for _, v in ipairs(TalonDB.customQuests) do
                if v == id then exists = true break end
            end
            
            if not exists then
                table.insert(TalonDB.customQuests, id)
                inputBox:SetText("")
                addon:RefreshConfigPanel()
            else
                print(string.format(GetText("MSG_QUEST_EXISTS", "|cffff0000[Talon]|r Quest ID %s already exists."), id))
            end
        end
    end)

    -- === 成就 ID 输入部分 (右侧) ===
    -- 在同一行显示
    local achInputBox = CreateFrame("EditBox", "TalonAddAchInput", addGroup, "InputBoxTemplate")
    achInputBox:SetSize(100, 20)
    achInputBox:SetPoint("LEFT", addBtn, "RIGHT", 30, 0)
    achInputBox:SetAutoFocus(false)
    achInputBox:SetNumeric(true)
    achInputBox:SetTextInsets(5, 5, 0, 0)

    local achAddBtn = CreateFrame("Button", nil, addGroup, "UIPanelButtonTemplate")
    achAddBtn:SetSize(120, 22) -- Increased width for English text
    achAddBtn:SetPoint("LEFT", achInputBox, "RIGHT", 10, 0)
    achAddBtn:SetText(GetText("CFG_ADD_ACHIEVEMENT_ID", "Add Achievement ID"))

    achAddBtn:SetScript("OnClick", function()
        local id = tonumber(achInputBox:GetText())
        if not id or id <= 0 then return end

        -- 1. 检查成就是否完成
        local isCompleted = false
        if C_AchievementInfo and C_AchievementInfo.GetAchievementInfo then
            local info = C_AchievementInfo.GetAchievementInfo(id)
            if info then isCompleted = info.completed end
        end

        if isCompleted then
            print(GetText("MSG_ACHIEVEMENT_COMPLETED", "|cffff0000[Talon]|r Achievement already completed."))
            return
        end

        -- 2. 查找关联任务并寻找第一个未完成的
        local quests = GetQuestsForAch(id)
        if #quests == 0 then
            print(GetText("MSG_ACH_NO_QUESTS", "|cffff0000[Talon]|r No quests found for this achievement."))
            return
        end

        local targetQuestID
        for _, qID in ipairs(quests) do
            if not C_QuestLog.IsQuestFlaggedCompleted(qID) then
                targetQuestID = qID
                break
            end
        end

        if targetQuestID then
            if not TalonDB.customQuests then TalonDB.customQuests = {} end
            table.insert(TalonDB.customQuests, targetQuestID)
            achInputBox:SetText("")
            addon:RefreshConfigPanel()
            print(string.format(GetText("MSG_ADDED_QUEST_FROM_ACH", "|cff00ff00[Talon]|r Added quest from achievement: %s"), targetQuestID))
        else
            print(GetText("MSG_ALL_ACH_QUESTS_COMPLETED", "|cffff0000[Talon]|r All quests for this achievement are completed."))
        end
    end)

    y = y - 60
    self.topHeight = math.abs(y) -- 记录顶部固定高度

    self.customListContainer = CreateFrame("Frame", nil, content)
    self.customListContainer:SetSize(500, 1)
    self.customListContainer:SetPoint("TOPLEFT", 25, y)
    
    -- 创建底部容器，锚定在自定义列表下方，实现自动下移
    self.bottomFrame = CreateFrame("Frame", nil, content)
    self.bottomFrame:SetSize(560, 1)
    self.bottomFrame:SetPoint("TOPLEFT", self.customListContainer, "BOTTOMLEFT", -5, -20)

    local by = 0
    -- 绘制资料片过滤
    local filterHeader = self.bottomFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") -- 优化字体
    filterHeader:SetPoint("TOPLEFT", 0, by)
    filterHeader:SetText(GetText("CFG_HEADER_FILTERS", "Expansion Filters"))
    by = by - 30

    -- 修正：键值必须与 DailyAchData.lua 中的 "exp" 字段完全一致
    -- 修正：移除数据库中不存在的键值 (如 Cata, WotLK, TBC 被归类为 Legacy/Classic)
    local expansions = {
        "The War Within", -- 修正 TWW
        "Dragonflight",   -- 修正 DF
        "Shadowlands",    -- 修正 SL
        "BfA",
        "Legion",
        "WoD",
        "MoP",
        "Legacy/Classic"
    }

    local i = 0
    for _, exp in ipairs(expansions) do
        i = i + 1
        -- 使用匿名框架以避免全局冲突，并手动确保 Text 对象存在
        local expCb = CreateFrame("CheckButton", nil, self.bottomFrame, "InterfaceOptionsCheckButtonTemplate")
        expCb:SetPoint("TOPLEFT", 5, by)
        
        if not expCb.Text then
            local text = expCb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", expCb, "RIGHT", 0, 1)
            expCb.Text = text
        end
        
        local txt = expCb.Text
        -- 修正：应用本地化
        if txt then txt:SetText(GetText("EXP_" .. exp, exp)) end
        
        -- 初始化勾选状态
        if not TalonDB.expFilters then TalonDB.expFilters = {} end
        if TalonDB.expFilters then
            expCb:SetChecked(TalonDB.expFilters[exp] == true)
        end

        expCb:SetScript("OnClick", function(self)
            if not TalonDB.expFilters then TalonDB.expFilters = {} end
            TalonDB.expFilters[exp] = self:GetChecked()
            addon:RefreshConfigPanel()
        end)
        by = by - 25
    end

    -- 本次扫描结果区域
    by = by - 20
    local sessionHeader = self.bottomFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") -- 优化字体
    sessionHeader:SetPoint("TOP", self.bottomFrame, "TOP", 0, by)
    sessionHeader:SetText(GetText("CFG_HEADER_SESSION_RESULTS", "Session Scan Results"))
    by = by - 25

    self.bottomBaseHeight = math.abs(by) -- 记录底部基础高度

    self.sessionListContainer = CreateFrame("Frame", nil, self.bottomFrame)
    self.sessionListContainer:SetSize(580, 1)
    self.sessionListContainer:SetPoint("TOP", self.bottomFrame, "TOP", 0, by)

    self:DrawCustomList()
    self:UpdateSessionList()

    self.panel = panel
    return panel
end

function TalonConfigPanel:Register()
    local panel = self:CreatePanel()
    -- 使用 12.0 现代 Settings API
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Talon")
    Settings.RegisterAddOnCategory(category)
    addon.category = category
end

-- ============================================================================
-- 初始化与刷新
-- ============================================================================

function addon:RefreshConfigPanel()
    if TalonConfigPanel.panel and TalonConfigPanel.content then
        -- 刷新自定义列表
        TalonConfigPanel:DrawCustomList()
    end
end

function addon:UpdateConfigSessionList()
    if TalonConfigPanel.UpdateSessionList then
        TalonConfigPanel:UpdateSessionList()
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    TalonConfigPanel:Register()
end)