--[[
================================================================================
Talon - 简体中文本地化
================================================================================
Description: 简体中文语言包，包含所有UI和系统消息
Author: David W Zhang
Version: 12.0.0
Locale: zhCN (简体中文 - 中国大陆)
================================================================================
]]--

local _, addon = ...

-- ============================================================================
-- 简体中文本地化注册
-- ============================================================================

addon:RegisterLocale("zhCN", {
    
    -- ========================================================================
    -- 系统消息
    -- ========================================================================
    ["ADDON_LOADED"] = "|cff00ffff[Talon]|r v%s 已加载。追踪 %d 个成就，覆盖 %d 个资料片。",
    ["INDEXING_START"] = "|cff00ffff[Talon]|r 正在建立任务索引...",
    ["INDEXING_COMPLETE"] = "|cff00ffff[Talon]|r 索引建立完成：%d 个任务已就绪。",
    ["INDEXING_ERROR"] = "|cffff0000[Talon 错误]|r 任务索引建立失败。",
    
    -- ========================================================================
    -- 成就通知 (UIErrorsFrame)
    -- ========================================================================
    ["RELATED_ACHIEVEMENT"] = "关联成就：%s",
    ["ACHIEVEMENT_PROGRESS"] = "%s (%d/%d)",
    ["CUSTOM_WATCH"] = "自定义监控",
    ["QUEST_ID_PREFIX"] = "任务 ",
    
    -- ========================================================================
    -- 配置界面
    -- ========================================================================
    ["CFG_TITLE"] = "Talon - 日常任务成就追踪器",
    ["CFG_DESC"] = "配置要追踪的资料片。取消勾选可禁用该资料片的通知。",
    ["CFG_PANEL_TITLE"] = "Talon 日常与成就追踪",
    ["CFG_HEADER_FILTERS"] = "资料片过滤器",
    ["CFG_HEADER_OPTIONS"] = "显示选项",
    ["CFG_ENABLE_TRACKING"] = "启用追踪",
    ["CFG_ENABLE_TRACKING_DESC"] = "扫描地图上的世界任务",
    ["CFG_SHOW_COMPLETED"] = "显示已完成成就",
    ["CFG_SHOW_COMPLETED_DESC"] = "即使成就已完成也显示通知。",
    ["CFG_TRACK_CHAR_ONLY"] = "仅追踪本角色成就",
    ["CFG_TRACK_CHAR_ONLY_DESC"] = "开启后，仅当本角色未完成成就时才进行追踪，忽略战团/账号共享的完成状态。",
    ["CFG_ENABLE_SOUND"] = "启用声音提醒",
    ["CFG_ENABLE_SOUND_DESC"] = "检测到成就相关任务时播放音效。",
    ["CFG_DEBUG_MODE"] = "调试模式",
    ["CFG_DEBUG_MODE_DESC"] = "在聊天窗口显示详细的调试信息。",
    ["CFG_DEBOUNCE_TIME"] = "防刷屏时长",
    ["CFG_DEBOUNCE_TIME_DESC"] = "在此时间内阻止同一成就的重复通知（秒）。",
    ["CFG_RESET_FILTERS"] = "重置所有过滤器",
    ["CFG_RESET_FILTERS_DESC"] = "启用所有资料片过滤器。",
    ["CFG_STATS"] = "统计信息",
    ["CFG_STATS_DESC"] = "追踪 %d 个成就，共 %d 个任务，覆盖 %d 个资料片。",
    ["CFG_HEADER_CUSTOM_QUESTS"] = "自定义任务追踪",
    ["CFG_CUSTOM_QUESTS_DESC"] = "在此处添加您想优先追踪的特定日常任务ID。插件会在扫描时优先处理这些任务。",
    ["CFG_ADD_QUEST"] = "添加任务 ID",
    ["CFG_ADD_QUEST_HINT"] = "(输入任务 ID)",
    ["CFG_MANUAL_SCAN"] = "手动扫描",
    ["CFG_ADD_ACHIEVEMENT_ID"] = "添加成就ID",
    ["CFG_HEADER_SESSION_RESULTS"] = "本次扫描结果",
    ["CFG_EXPORT"] = "导出列表",
    ["CFG_EXPORT_TITLE"] = "Talon 自定义任务 (Ctrl+C 复制):",
    ["CFG_BTN_DELETE"] = "删除",
    
    -- ========================================================================
    -- 反馈消息与格式
    -- ========================================================================
    ["MSG_QUEST_EXISTS"] = "|cffff0000[Talon]|r 任务 ID %s 已存在。",
    ["MSG_ACHIEVEMENT_COMPLETED"] = "|cffff0000[Talon]|r 此成就已完成。",
    ["MSG_ACH_NO_QUESTS"] = "|cffff0000[Talon]|r 未找到此成就的相关任务。",
    ["MSG_ADDED_QUEST_FROM_ACH"] = "|cff00ff00[Talon]|r 已添加成就关联任务: %s",
    ["MSG_ALL_ACH_QUESTS_COMPLETED"] = "|cffff0000[Talon]|r 此成就的所有关联任务均已完成。",
    ["LIST_PREFIX_FOUND"] = "|cff00ffff[Talon]|r 发现: ",
    ["LIST_PREFIX_ACHIEVEMENT"] = "- 成就: ",
    ["UNKNOWN"] = "未知",
    ["LOADING"] = "加载中...",
    ["UNKNOWN_ACHIEVEMENT"] = "未知成就",
    ["FOUND_TARGET_FORMAT"] = "|cff00ffff[Talon]|r 发现目标: %s - 关联成就: %s%s",
    
    -- ========================================================================
    -- 资料片标签（动态生成）
    -- ========================================================================
    ["EXP_Legacy/Classic"] = "经典旧世与怀旧服",
    ["EXP_The Burning Crusade"] = "燃烧的远征",
    ["EXP_Wrath of the Lich King"] = "巫妖王之怒",
    ["EXP_Cataclysm"] = "大地的裂变",
    ["EXP_Mists of Pandaria"] = "熊猫人之谜",
    ["EXP_Warlords of Draenor"] = "德拉诺之王",
    ["EXP_Legion"] = "军团再临",
    ["EXP_Battle for Azeroth"] = "争霸艾泽拉斯",
    ["EXP_Shadowlands"] = "暗影国度",
    ["EXP_Dragonflight"] = "巨龙时代",
    ["EXP_The War Within"] = "地心之战",
    ["EXP_TWW"] = "地心之战",
    ["EXP_DF"] = "巨龙时代",
    ["EXP_SL"] = "暗影国度",
    ["EXP_BfA"] = "争霸艾泽拉斯",
    ["EXP_WoD"] = "德拉诺之王",
    ["EXP_MoP"] = "熊猫人之谜",
    ["EXP_Cata"] = "大地的裂变",
    ["EXP_WotLK"] = "巫妖王之怒",
    ["EXP_TBC"] = "燃烧的远征",
    ["EXP_Vanilla"] = "经典旧世",
    ["EXP_Midnight"] = "至暗之夜",
    
    -- ========================================================================
    -- 错误消息
    -- ========================================================================
    ["ERROR_NO_DATA"] = "数据文件未加载。请重新安装插件。",
    ["ERROR_INVALID_QUEST"] = "检测到无效的任务ID。",
    ["ERROR_API_FAIL"] = "成就API调用失败。",
    ["ERROR_DB_CORRUPT"] = "保存的设置已损坏，正在重置为默认值。",
    
    -- ========================================================================
    -- 斜杠命令
    -- ========================================================================
    ["CMD_HELP"] = "Talon 命令列表：",
    ["CMD_CONFIG"] = "/talon config - 打开设置",
    ["CMD_STATS"] = "/talon stats - 显示统计信息",
    ["CMD_RESET"] = "/talon reset - 重置本次会话通知",
    ["CMD_TOGGLE"] = "/talon toggle - 开启/关闭追踪",
    ["CMD_STATUS"] = "/talon status - 显示当前状态",
    ["CMD_SCAN"] = "|cff00ff00/talon scan|r - 手动扫描世界任务",
    
    -- ========================================================================
    -- 状态消息
    -- ========================================================================
    ["STATUS_ENABLED"] = "|cff00ff00已启用|r",
    ["STATUS_DISABLED"] = "|cffff0000已禁用|r",
    ["STATUS_TRACKING"] = "追踪状态：%s",
    ["STATUS_EXPANSIONS"] = "已激活资料片：%s",
    ["STATUS_NOTIFIED"] = "本次会话已通知：%d 个成就",
    ["SCAN_START"] = "|cff00ffff[Talon]|r 正在扫描...",
    ["SESSION_RESET"] = "|cff00ffff[Talon]|r 会话历史已重置。",
    ["FILTERS_RESET_MSG"] = "|cff00ffff[Talon]|r 所有资料片过滤器已启用。",
    ["SETTINGS_API_MISSING"] = "|cffff9900[Talon]|r 设置 API 不可用。正在使用旧版界面。",
    ["CONFIG_REFRESHED"] = "|cff00ffff[Talon]|r 配置已刷新",
    ["DB_LOAD_SUMMARY"] = "|cffff9900[Talon]|r 数据库已加载：%d 个有效，移除 %d 个无效条目",
    
})