-- Hooks.lua
-- Part of RS_ClassColors by Stupid (Crushridge-US, Horde)
--
-- Colorization methods for the various parts of the in-game UI.

local RS_ClassColors = LibStub("AceAddon-3.0"):GetAddon("RS_ClassColors");
local _G = getfenv(0);

-- Colors instances of a player's name in chat with that of their class, when
-- possible.
function RS_ClassColors:AddMessage(frame, text, red, green, blue, messageId, holdTime)
	if (not RS_ClassColors.db.profile.colorizeChat) then return; end
	if (text == nil) then return; end
	local formMsg = text;
	for internal, displayed in string.gmatch(text, "|Hplayer:(.-)|h%[(.-)%]|h") do
		local groupNum = RS_ClassColors:FindPlayerClasses(displayed);
		if (groupNum and RS_ClassColors.db.profile.showGroupNumbers) then
			formMsg = string.gsub(formMsg, "|Hplayer:" .. internal .. "|h%[" .. displayed .. "%]|h", "|Hplayer:" .. internal .. "|h%[" .. RS_ClassColors:GetClassColor(RS_ClassColors:GetPlayerClass(displayed)) .. displayed .. ":" .. groupNum .. "|r%]|h");
		else
			formMsg = string.gsub(formMsg, "|Hplayer:" .. internal .. "|h%[" .. displayed .. "%]|h", "|Hplayer:" .. internal .. "|h%[" .. RS_ClassColors:GetClassColor(RS_ClassColors:GetPlayerClass(displayed)) .. displayed .. "|r%]|h");
		end
	end
	self.hooks[frame].AddMessage(frame, formMsg, red, green, blue, messageId, holdTime);
end

-- Replaces the default Score Frame painter with one that colorizes player names
-- by class.
function RS_ClassColors:WorldStateScoreFrame_Update()
	if (self.db.profile.colorizeBGs == false) then return; end
	for i=1,MAX_WORLDSTATE_SCORE_BUTTONS do
		local index = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame) + i;
		if index > GetNumBattlefieldScores() then break; end
		local _,_,_,_,_,_,_,_, class = GetBattlefieldScore(index);
		local nameText = _G["WorldStateScoreButton" .. i .. "NameText"]:GetText();
		if (nameText == UnitName("player")) then
			_G["WorldStateScoreButton" .. i .. "NameText"]:SetText("|cff00ff00" .. nameText .. "|r");
		else
			_G["WorldStateScoreButton" .. i .. "NameText"]:SetText(self:GetClassColor(class) .. nameText .. "|r");
		end
	end
end

-- Replaces the default Friends Frame painter with one that colorizes player
-- names by class.
function RS_ClassColors:FriendsList_Update()
	if (self.db.profile.colorizeFriends == false) then return; end
	local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame);
	local friendIndex;
	for i=1,FRIENDS_TO_DISPLAY do
		friendIndex = friendOffset + i;
		local name, level, class, area, connected, status = GetFriendInfo(friendIndex);
		local nameText = _G["FriendsFrameFriendButton" .. i .. "ButtonTextName"];
		local nameLocationText = _G["FriendsFrameFriendButton" .. i .. "ButtonTextLocation"];
		local infoText = _G["FriendsFrameFriendButton"..i.."ButtonTextInfo"];
		if (name) then
			if (connected) then
				name = self:GetClassColor(class) .. name .. "|r";
				nameText:SetText(name)
				if (self.db.profile.colorizeZones and GetRealZoneText() == area) then
					nameLocationText:SetFormattedText("|cff00ff00- %s|r %s", area, status);
				else
					nameLocationText:SetFormattedText(FRIENDS_LIST_TEMPLATE, area, status);
				end
				if (self.db.profile.colorizePlayerLevels or self.db.profile.colorizeClassNames) then
					local newLevelTemplate = string.gsub(FRIENDS_LEVEL_TEMPLATE, "%%d", "%%s");
					if (self.db.profile.colorizePlayerLevels) then
						level = self:ColorizeLevel(level);
					end
					if (self.db.profile.colorizeClassNames) then
						class = self:GetClassColor(class) .. class .. "|r";
					end
					infoText:SetFormattedText(newLevelTemplate, level, class);
				end
			elseif (self.db.profile.colorizeOffline) then
				name = self:GetClassColor(self:GetPlayerClass(name)) .. name .. "|r";
				local offlineWord = string.match(FRIENDS_LIST_OFFLINE_TEMPLATE, "^|cff999999%%s %- (.+)|r$")
				nameLocationText:SetFormattedText("|cff999999 - %s|r", offlineWord);
				nameText:SetText(name)
			end
		end
	end
end

-- Replaces the default Who Frame painter with one that colorizes player names
-- by class.
function RS_ClassColors:WhoList_Update()
	if (self.db.profile.colorizeWho == false) then return; end
	local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame);
	local whoIndex;
	for i=1,WHOS_TO_DISPLAY do
		whoIndex = whoOffset + i;
		local name, _, level, _, class, zone = GetWhoInfo(whoIndex);
		if (name) then
			local r,g,b = self:GetClassColorComponents(class)
			_G["WhoFrameButton"..i.."Name"]:SetTextColor(r,g,b);
			if (self.db.profile.colorizePlayerLevels) then
				level = self:ColorizeLevel(level);
				_G["WhoFrameButton"..i.."Level"]:SetText(level);
			end
			if (self.db.profile.colorizeZones and UIDropDownMenu_GetSelectedID(WhoFrameDropDown) == 1 and GetRealZoneText() == zone) then
				local variableText = _G["WhoFrameButton"..i.."Variable"];
				variableText:SetText("|cff00ff00" .. zone .. "|r");
			end
		end
	end
end

-- Replaces the default Guild Frame painter with one that colorizes player names
-- by class.
function RS_ClassColors:GuildStatus_Update()
	if (self.db.profile.colorizeGuild == false) then return; end
	local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);
	local guildIndex;
	for i=1,GUILDMEMBERS_TO_DISPLAY do
		guildIndex = guildOffset + i;
		local name, _,_, level, class, zone, _,_, online = GetGuildRosterInfo(guildIndex);
		if (name and (online or self.db.profile.colorizeOffline)) then
			local r,g,b = self:GetClassColorComponents(class)
			_G["GuildFrameButton"..i.."Name"]:SetTextColor(r,g,b);
			_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(r,g,b);
			if (self.db.profile.colorizeZones and GetRealZoneText() == zone) then
				_G["GuildFrameButton"..i.."Zone"]:SetText("|cff00ff00" .. zone .. "|r");
			end
			if (self.db.profile.colorizePlayerLevels) then
				level = self:ColorizeLevel(level);
				_G["GuildFrameButton"..i.."Level"]:SetText(level);
			end
		end
	end
end
