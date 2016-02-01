local addonName, ns = ...

local db
local watchedQuests
local watchedAchievements
local defaults = {
	toggleQuests = true,
	toggleAchievements = true,
	watchedQuests = {},
	watchedAchievements = {},
}

local hideEvents = {
	ENCOUNTER_START = true,
	PLAYER_REGEN_DISABLED = true,
}

local addon = CreateFrame("Frame")
addon:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)
addon:RegisterEvent("ADDON_LOADED")

local function UntrackAchievements()
	watchedAchievements = { GetTrackedAchievements() }
	for i = 1, #watchedAchievements do
		RemoveTrackedAchievement(watchedAchievements[i])
	end
end

local function TrackAchievements()
	for i = 1, #watchedAchievements do
		AddTrackedAchievement(watchedAchievements[i])
	end
	wipe(watchedAchievements)
end

local function UntrackQuests()
	for i = 1, GetNumQuestWatches() do
		local questID, questTitle, questLogIndex = GetQuestWatchInfo(1)
		watchedQuests[questID] = true
		RemoveQuestWatch(questLogIndex)
	end
end

local function TrackQuests()
	for questID in pairs(watchedQuests) do
		AddQuestWatch(GetQuestLogIndexByID(questID)) -- if the quest log changed, so did the log indicies
	end
	wipe(watchedQuests)
	SortQuestWatches()
end

local function ToggleTracking(event)
	if (hideEvents[event]) then
		if (db.toggleQuests) then UntrackQuests() end
		if (db.toggleAchievements) then UntrackAchievements() end
	else
		if (db.toggleQuests) then TrackQuests() end
		if (db.toggleAchievements) then TrackAchievements() end
	end
end

local function ParseCommand(cmd)
	if (cmd == "track") then
		ToggleTracking("ENCOUNTER_END")
	elseif (cmd == "untrack") then
		ToggleTracking("ENCOUNTER_START")
	else
		print(string.format("|cff0099CC%s:|r Unknown command - %s.", addonName, cmd))
	end
end

function addon:ADDON_LOADED(_, name)
	if (name ~= addonName) then return end

	ToggleTrackingDB = setmetatable(ToggleTrackingDB or {}, {__index = function(t, k)
		local v = defaults[k]
		rawset(t, k, v)
		return v
	end})
	db = ToggleTrackingDB
	watchedQuests = db.watchedQuests
	watchedAchievements = db.watchedAchievements

	_G["SLASH_"..addonName.."1"] = "/ttrack"
	_G["SLASH_"..addonName.."2"] = "/toggletracking"
	SlashCmdList[addonName] = ParseCommand

	self:UnregisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ENCOUNTER_START")
	self:RegisterEvent("ENCOUNTER_END")
end

function addon:PLAYER_ENTERING_WORLD()
	-- ENCOUNTER_START|END fire only for raid bosses
	local isInInstance, instanceType = IsInInstance()
	if (isInInstance and instanceType == "party") then
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	end
	-- recover if the player disconnected mid-fight
	if (IsEncounterInProgress()) then
		ToggleTracking("ENCOUNTER_START")
	else
		ToggleTracking("ENCOUNTER_END")
		if (isInInstance and instanceType == "party") then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end
end

function addon:ENCOUNTER_START(event)
	ToggleTracking(event)
end

function addon:ENCOUNTER_END(event)
	ToggleTracking(event)
end

function addon:PLAYER_REGEN_DISABLED(event)
	if (IsEncounterInProgress()) then
		ToggleTracking(event)
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

function addon:PLAYER_REGEN_ENABLED(event)
	ToggleTracking(event)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end
