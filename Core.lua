-- Core.lua
-- Part of RS_ClassColors by Stupid (Crushridge-US, Horde)
--
-- General purpose functions and constants of relevance to the entire addon.

local _G = getfenv(0);
local RS_ClassColors = LibStub("AceAddon-3.0"):NewAddon("RS_ClassColors",
	"AceConsole-3.0", "AceConsole-3.0", "AceHook-3.0"
);
local L = LibStub("AceLocale-3.0"):GetLocale("RS_ClassColors");
local BC = LibStub("LibBabble-Class-3.0"):GetLookupTable();

-- FUNCTIONS

-- Called when the mod is loaded at game UI launch.
function RS_ClassColors:OnInitialize()
	local options = {
		type = 'group',
		args = {
			remember = {
				type = 'toggle',
				name = L["Remember classes"],
				desc = L["Remember player classes between logouts (may take up a lot of memory after a few months)"],
				get = function(info) return self.db.profile.saveClassData end,
				set = function(info, v) self.db.profile.saveClassData = v end
			},
			colorize = {
				type = 'group',
				name = L["Windows"],
				desc = L["What windows to colorize player names in"],
				args = {
					chat = {
						type = 'toggle',
						name = L["Chat windows"],
						desc = L["Colorize player names in chat windows"],
						get = function(info) return self.db.profile.colorizeChat end,
						set = function(info, v) self.db.profile.colorizeChat = v end
					},
					friends = {
						type = 'toggle',
						name = L["Friends pane"],
						desc = L["Colorize player names in the friends list"],
						get = function(info) return self.db.profile.colorizeFriends end,
						set = function(info, v) self.db.profile.colorizeFriends = v end
					},
					guild = {
						type = 'toggle',
						name = L["Guild pane"],
						desc = L["Colorize player names in the guild roster"],
						get = function(info) return self.db.profile.colorizeGuild end,
						set = function(info, v) self.db.profile.colorizeGuild = v end
					},
					who = {
						type = 'toggle',
						name = L["/who results list"],
						desc = L["Colorize player names in the /who results list"],
						get = function(info) return self.db.profile.colorizeWho end,
						set = function(info, v) self.db.profile.colorizeWho = v end
					},
					battlegrounds = {
						type = 'toggle',
						name = L["Battleground standings pane"],
						desc = L["Colorize player names in the battlegrounds scoreboard"],
						get = function(info) return self.db.profile.colorizeBGs end,
						set = function(info, v) self.db.profile.colorizeBGs = v end
					}
				}
			},
			include = {
				type = 'group',
				name = L["What to Colorize"],
				desc = L["What specific elements of a window to colorize"],
				args = {
					classes = {
						type = 'toggle',
						name = L["Player classes"],
						desc = L["Colorize player classes in the friends pane"],
						get = function(info) return self.db.profile.colorizeClassNames end,
						set = function(info, v) self.db.profile.colorizeClassNames = v end
					},
					levels = {
						type = 'toggle',
						name = L["Player levels"],
						desc = L["Colorize player levels in the guild, /who results, and friends panes"],
						get = function(info) return self.db.profile.colorizePlayerLevels end,
						set = function(info, v) self.db.profile.colorizePlayerLevels = v end
					},
					zones = {
						type = 'toggle',
						name = L["Zones you are in"],
						desc = L["Colorize player zones in the guild, /who results, and friends panes, if they are in the same zone as you"],
						get = function(info) return self.db.profile.colorizeZones end,
						set = function(info, v) self.db.profile.colorizeZones = v end
					}
				}
			},
			show = {
				type = 'group',
				name = L["Miscellaneous"],
				desc = L["Additional information that can be toggled on or off"],
				args = {
					subgroups = {
						type = 'toggle',
						name = L["Show subgroups"],
						desc = L["Shows players' subgroup numbers in the chat window if they are in your raid (good for buffers/dispellers)"],
						get = function(info) return self.db.profile.showGroupNumbers end,
						set = function(info, v) self.db.profile.showGroupNumbers = v end
					},
					offline = {
						type = 'toggle',
						name = L["Include offline players"],
						desc = L["Colorize names of offline players in the guild roster and friends list"],
						get = function(info) return self.db.profile.colorizeOffline end,
						set = function(info, v) self.db.profile.colorizeOffline = v end
					}
				}
			}
		}
	};
	
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("RS_ClassColors", options);
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RS_ClassColors", "RS_ClassColors");
	
	local defaults ={
		realm = {
			playerClasses = {}
		},
		profile = {
			saveClassData = false,
			colorizeFriends = true,
			colorizeGuild = true,
			colorizeWho = true,
			colorizeBGs = true,
			colorizeChat = true,
			colorizeOffline = false,
			showGroupNumbers = false,
			colorizePlayerLevels = false,
			colorizeClassNames = false,
			colorizeZones = false
		}
	};
	self.db = LibStub("AceDB-3.0"):New("rsccDB", defaults, "Default");
	
	self:SecureHook("WorldStateScoreFrame_Update", "WorldStateScoreFrame_Update");
	self:SecureHook("FriendsList_Update", "FriendsList_Update");
	self:SecureHook("WhoList_Update", "WhoList_Update");
	self:SecureHook("GuildStatus_Update", "GuildStatus_Update");
	
	for i=1,7 do
		self:RawHook(_G["ChatFrame" .. i], "AddMessage", "AddMessage", true);
	end
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.AddMessage);
	-- ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.AddMessage);

	
	if (self.db.profile.saveClassData == false) then self.db.realm.playerClasses = {}; end
end

-- Called when the mod is enabled through the ACE command line.
function RS_ClassColors:OnEnable()
	self:AddPlayer(UnitName("player"), UnitClass("player"));
	
	local prevRosterSetting = GetGuildRosterShowOffline();
	SetGuildRosterShowOffline(true);
	for i=1,GetNumGuildMembers() do
		local name, _,_,_, class = GetGuildRosterInfo(i);
		self:AddPlayer(name, class);
	end
	SetGuildRosterShowOffline(prevRosterSetting);
	
	for i=1,GetNumFriends() do
		local name,_,class = GetFriendInfo(i);
		self:AddPlayer(name, class);
	end
end

-- Called when a chat message is received. Attempts to determine the sender's
-- class.
-- PARAMETERS
-- player: the player's name
-- RETURNS
-- The player's subgroup number, if he is in a raid group
function RS_ClassColors:FindPlayerClasses(player)
	-- first check to see if the player is in our raid
	if (UnitInRaid("player")) then
		for i=1,MAX_RAID_MEMBERS do
			local name, _, subgroup, _,_, class = GetRaidRosterInfo(i);
			if (name and subgroup and class) then
				self:AddPlayer(name, class);
				if (name == player) then
					return subgroup;
				end
			end
		end
	end
	
	-- or in our party
	if (UnitInParty("player")) then
		for i=1,5 do
			if (UnitName("party" .. i)) then
				self:AddPlayer(UnitName("party" .. i), UnitClass("party" .. i));
			end
		end
	end
	if (self:GetPlayerClass(player)) then return; end
	
	-- or our friends' list
	for i=1,GetNumFriends() do
		local name,_,class = GetFriendInfo(i);
		self:AddPlayer(name, class);
	end
	if (self:GetPlayerClass(player)) then return; end
	
	-- or our guild
	if (IsInGuild()) then
		local prevRosterSetting = GetGuildRosterShowOffline();
		SetGuildRosterShowOffline(true);
		if (GetNumGuildMembers() == 0) then GuildRoster(); end
		for i=1,GetNumGuildMembers() do
			local name, _,_,_, class = GetGuildRosterInfo(i);
			self:AddPlayer(name, class);
		end
		SetGuildRosterShowOffline(prevRosterSetting);
		if (self:GetPlayerClass(player)) then return; end
	end
	
	-- or our most recent /who
	local _, numWhos = GetNumWhoResults();
	for i=1,numWhos do
		local name, _,_,_, class = GetWhoInfo(i);
		self:AddPlayer(name, class);
	end
	if (self:GetPlayerClass(player)) then return; end
	
	-- or give up
end

-- Adds a player's class to the database, for future colorization.
-- PARAMETERS
-- name: the player's name
-- class: the player's class (any capitalization is OK)
function RS_ClassColors:AddPlayer(name, class)
	if (self.db == nil) then return; end
    if (name == nil or class == nil) then return; end --TODO do we need this?
	
    self.db.realm.playerClasses[name] = RS_ClassColors:NormalizeClassName(class);
end

-- Converts a class name into one stored in the RAID_CLASS_COLORS hash.
function RS_ClassColors:NormalizeClassName(class)
	return string.gsub(string.upper(class), " ", "");
	-- TODO reverse-translate with babble
end

-- Retrieves a player's class from the database.
-- PARAMETERS
-- name: the player's name
-- RETURNS
-- The player's class.
function RS_ClassColors:GetPlayerClass(name)
	if (self.db.realm.playerClasses[name] == "UNKNOWN") then return nil; end
	return self.db.realm.playerClasses[name];
end

-- Returns a formatted color string for the given class.
-- PARAMETERS
-- class: the name of the class
-- RETURNS
-- An escape sequence beginning the colorization for the class. This must later
-- be ended by appending "|r" to the end of the string.
function RS_ClassColors:GetClassColor(class)
	if class == nil then return "|cff808080"; end
	return "|cff" .. self:GetHexColor(RAID_CLASS_COLORS[self:NormalizeClassName(class)]);
end

-- Returns the six-digit hex color string for an RGB color.
-- PARAMETERS
-- color: the RGB color object
-- RETURNS
-- A hex string of the color, e.g., "ff8000" for orange.
function RS_ClassColors:GetHexColor(color)
	local r,g,b = color.r*256, color.g*256, color.b*256;
	if r > 255 then r = 255; end
	if g > 255 then g = 255; end
	if b > 255 then b = 255; end
	return DecToHex(r) .. DecToHex(g) .. DecToHex(b);
end

-- shamelessly stolen from http://lua-users.org/lists/lua-l/2004-09/msg00054.html
function DecToHex(IN)
    local B,K,OUT,I,D=16,"0123456789abcdef","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.fmod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
	if string.len(OUT) == 1 then OUT = "0" .. OUT; end
    return OUT
end

-- Returns the color components for a given class.
-- PARAMETERS
-- class: the name of the class
-- RETURNS
-- 1. The red component, as a fraction
-- 2. The green component, as a fraction
-- 3. The blue component, as a fraction
function RS_ClassColors:GetClassColorComponents(class)
	if class == nil then return 0.5, 0.5, 0.5; end
	local color = RAID_CLASS_COLORS[self:NormalizeClassName(class)];
	if color == nil then return 0.5, 0.5, 0.5; end
	return color.r, color.g, color.b;
end

-- Applies a color to a level based on how close it is to the player's level.
-- Red levels are ±69 away, and green levels are equal to the player's level.
-- Intermediate colors are used for intermediate differences.
-- PARAMETERS
-- level: the level to colorize
-- RETURNS
-- A colorized string containing the level number
function RS_ClassColors:ColorizeLevel(level)
	local levelDiff = level - UnitLevel("player");
	local red = 0.0;
	local green = 0.0;
	local blue = 0.0;
	if (levelDiff > 5 or level == -1) then
		red = 1.0;
	elseif (levelDiff >= 3) then
		red = 1.0;
		green = 0.5;
	elseif (levelDiff >= -2) then
		red = 1.0;
		green = 1.0;
	elseif (-levelDiff <= GetQuestGreenRange()) then
		green = 1.0;
	else
		red = 0.5;
		green = 0.5;
		blue = 0.5;
	end
	--local levelDiffFactor = (math.abs(UnitLevel("player") - level))/69.0
	--local red = levelDiffFactor;
	--local green = 1 - levelDiffFactor;
	return string.format("|cff%02x%02x%02x%d|r", red*255, green*255, blue*255, level);
end
