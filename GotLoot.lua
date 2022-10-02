-- VARS
LootOptions = {};

local ClothTypes = {"linen cloth", "wool cloth", "silk cloth", "mageweave cloth", "runecloth", "neatherwave cloth", "embersilk cloth", "windwool cloth"};

local CurrentMoney 	= 0
local LootedMoney 	= 0

local Colors = {}
	Colors.Red 		= "cffff0000"
	Colors.Green 	= "cff00ff00"
	Colors.Blue		= "cff0000ff"

local types = {}
	types.Trade		= "Tradeskill" --Retail
	--types.Trade 		= "Trade Goods" --Classic
	types.Herbs			= "Herb"
	types.Cooking		= "Cooking"	-- Cooking items meat etc
	types.Ore			= "Metal & Stone"
	types.Leather		= "Leather"
	types.Food			= "Consumable"
	types.Cloth			= "Cloth"
	types.Elemental		= "Elemental" -- Motes of fire, water etc TBC
	types.Food			= "Food & Drink"
	types.Potions		= "Potion"
	types.Scroll		= "Other"
	types.Junk			= "Junk"

-- Used for picking up potions and food (Player Level - levelOffset)
local levelOffset		= 15

-- Tally of value of looted items this session
local lootedValue		= 0

--Functions
function CheckList (list, item)
	for _,v in pairs(list) do
		if v == item then
			return true;
			
		end
	end
	return false;
end

function Validate (item)
	if(item ~= nil) then
		return item;
	else
		return false;
	end
end

function HideOptionFrames ()
	keepOptions:Hide()
	mainOptions:Hide()
	blOptions:Hide()
end

function RemoveItem (list, item)
	for i,v in pairs(list) do
		if v == item then
			table.remove(list, i);
			return true;
			
		end
	end
	return false;
end

function debugHandler(value)
	if value then
		LootOptions.Debug = true;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Debug mode on!");
	else
		LootOptions.Debug = false;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Debug mode off!");
	end
end

function CreateToggleButton (name, text, parent, x, y)
	local f = CreateFrame("CheckButton",name,parent,"OptionsCheckButtonTemplate")
	f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	f.title = f:CreateFontString(f, "ARTWORK", "GameFontNormalSmall");
	f.title:SetText(text)
	f.title:SetPoint("LEFT", f,"RIGHT", 10, 2);
	return f
end

function CreateSlider (name, text, parent, x, y, minVal, maxVal)
	local f = CreateFrame("Slider",name,parent,"OptionsSliderTemplate")
	f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	f:SetOrientation('HORIZONTAL')
	f:SetWidth(500)
	f:SetMinMaxValues(minVal, maxVal)
	f.textLow = _G[name.."Low"]
    f.textHigh = _G[name.."High"]
	f.textLow:SetText(floor(minVal))
    f.textHigh:SetText(floor(maxVal))
	f.title = f:CreateFontString(f, "ARTWORK", "GameFontNormalSmall");
	f.title:SetText(text)
	f.title:SetPoint("CENTER", f,"CENTER", 0, 15);
	return f
end

function UpdateUI()
	if LootOptions.Debug then
		mainOptions.debug:SetChecked(true)
	end
	if LootOptions.Info then
		mainOptions.info:SetChecked(true)
	end
	-- Update Junk Value Slider
	mainOptions.value:SetValue(LootOptions.MinJunkValue/100)

	mainOptions.junk:SetChecked(LootOptions.AlwaysLootJunk)
	mainOptions.bypass:SetChecked(LootOptions.Bypass)

	mainOptions.ore:SetChecked(LootOptions.LootOre)
	mainOptions.meat:SetChecked(LootOptions.LootMeat)
	mainOptions.cloth:SetChecked(LootOptions.LootCloth)
	mainOptions.leather:SetChecked(LootOptions.LootLeather)
	mainOptions.herbs:SetChecked(LootOptions.LootHerbs)
	mainOptions.food:SetChecked(LootOptions.LootFood)
	mainOptions.healthp:SetChecked(LootOptions.HealthPotions)
	mainOptions.manap:SetChecked(LootOptions.ManaPotions)

	mainOptions.s_agi:SetChecked(LootOptions.LootAgiScroll)
	mainOptions.s_int:SetChecked(LootOptions.LootIntScroll)
	mainOptions.s_str:SetChecked(LootOptions.LootStrScroll)
	mainOptions.s_sta:SetChecked(LootOptions.LootStaScroll)
	mainOptions.s_ver:SetChecked(LootOptions.LootVerScroll)

	mainOptions.s_lvl:SetValue(LootOptions.LootScrollLVL)

	mainOptions.foodos:SetValue(LootOptions.FoodLevelOffset)
	-- Update Session Loot Value
	mainOptions.sessionvalue:SetText(("Session Loot Value : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r "):format(lootedValue / 100 / 100, (lootedValue / 100) % 100, lootedValue % 100))

	mainOptions.lootedvalue:SetText(("Session Coin Looted : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r "):format(LootedMoney / 100 / 100, (LootedMoney / 100) % 100, LootedMoney % 100))

	UpdateWhiteList()
	UpdateBlackList()
end

function UpdateWhiteList()
	output = ""
	local i = 0
	for _,v in pairs(LootOptions.Keep) do
		local itemName, itemLink, _, _, _, itemType, itemSubType, _, _, _, itemSellPrice = GetItemInfo(v)
		if itemLink ~= nil then
			output = output .. itemLink .. '\n'
		else
			output = output .. v .. '\n'
		end
		i = i + 1
	end
	keepOptions.title:SetText(i .. " Items in the white list");
	keepOptions.moduleoptions.list:SetText(output);
	keepOptions.moduleoptions.list:SetHeight(keepOptions.moduleoptions.list:GetStringHeight())
	keepOptions.scrollchild:SetSize(keepOptions.scrollframe:GetWidth(), ( keepOptions.moduleoptions.list:GetStringHeight()))
end

function UpdateBlackList()
	output = ""
	local i = 0
	for _,v in pairs(LootOptions.Blacklist) do
		local itemName, itemLink, _, _, _, itemType, itemSubType, _, _, _, itemSellPrice = GetItemInfo(v)
		if itemLink ~= nil then
			output = output .. itemLink .. '\n'
		else
			output = output .. v .. '\n'
		end
		i = i + 1
	end
	blOptions.title:SetText(i .. " Items in the black list");
	blOptions.moduleoptions.list:SetText(output);
	blOptions.moduleoptions.list:SetHeight(blOptions.moduleoptions.list:GetStringHeight())
	blOptions.scrollchild:SetSize(blOptions.scrollframe:GetWidth(), ( blOptions.moduleoptions.list:GetStringHeight()))
end

function BlackList(args)
	local itemName, itemLink, _, _, _, itemType, itemSubType, _, _, _, itemSellPrice = GetItemInfo(args);
	if itemName ~= nil then
		if not CheckList(LootOptions.Blacklist, itemName) then
			-- Check the item isnt white listed, if so remove it
			if CheckList(LootOptions.Keep, itemName) then
				RemoveItem(LootOptions.Keep, itemName);
				UpdateWhiteList()
			end
			table.insert(LootOptions.Blacklist,itemName);
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Ignoring " .. itemLink);
		else
			RemoveItem(LootOptions.Blacklist, itemName);
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Stopped ignoring " .. itemLink);
		end
		UpdateBlackList()
	end		
end

function WhiteList(args)
	local itemName, itemLink, _, _, _, itemType, itemSubType, _, _, _, itemSellPrice = GetItemInfo(args);
	if itemName ~= nil then
		if not CheckList(LootOptions.Keep, itemName) then
			-- Check the item isnt black listed, if so remove it
			if CheckList(LootOptions.Blacklist, itemName) then
				RemoveItem(LootOptions.Blacklist, itemName);
				UpdateBlackList()
			end
			table.insert(LootOptions.Keep,itemName);
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Keeping " .. itemLink);
		else
			RemoveItem(LootOptions.Keep, itemName);
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Stopped looting " .. itemLink);
		end
		UpdateWhiteList()
	end		
end

function RemoveWhiteList(args)
	if CheckList(LootOptions.Keep, args) then
		RemoveItem(LootOptions.Keep, args)
		UpdateWhiteList()
		keepOptions.input:SetText("")
	end
end

function RemoveBlackList(args)
	if CheckList(LootOptions.Blacklist, args) then
		RemoveItem(LootOptions.Blacklist, args)
		UpdateWhiteList()
		blOptions.input:SetText("")
	end
end

function WhiteListDrop()
	local type, _, itemLink = GetCursorInfo();
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink)
	keepOptions.itemBut:SetNormalTexture(itemTexture)
	WhiteList(itemLink)
	ClearCursor()
end

function BlackListDrop()
	local type, _, itemLink = GetCursorInfo();
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink)
	keepOptions.itemBut:SetNormalTexture(itemTexture)
	BlackList(itemLink)
	ClearCursor()
end

function LootItem(slot)
	LootSlot(slot)
	ConfirmLootSlot(slot)
end


-- *************
-- CREATE FRAMES
-- *************

--Event Frame
local GotLootFrame = CreateFrame("Frame", "GotLootFrame", UIParent);

-- GUI Frame

local GotLootOptions = CreateFrame("Frame","GotLootOptions",UIParent, "InsetFrameTemplate"); --, "MacroFrame");
GotLootOptions:SetFrameStrata("DIALOG");
GotLootOptions:SetWidth(700);
GotLootOptions:SetHeight(600);
GotLootOptions:SetPoint("CENTER",0,0);
tinsert(UISpecialFrames, GotLootOptions:GetName())

local GotLootOptions_titleBG = GotLootOptions:CreateTexture(nil,"ARTWORK");
GotLootOptions_titleBG:SetTexture("Interface/DialogFrame/UI-DialogBox-Header");
GotLootOptions_titleBG:SetWidth(280);
GotLootOptions_titleBG:SetHeight(64);
GotLootOptions_titleBG:SetPoint("TOP", GotLootOptions, 0, 20);
GotLootOptions.texture = GotLootOptions_titleBG;

local GotLootOptions_titleText = GotLootOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
GotLootOptions_titleText:SetText("Got Loot");
GotLootOptions_titleText:SetPoint("TOP", GotLootOptions, 0, 5);

local CloseButton = CreateFrame("Button","CloseButton", GotLootOptions, "UIPanelCloseButton")
CloseButton:SetPoint("TOPRIGHT", GotLootOptions, "TOPRIGHT", 0, 0);
CloseButton:SetScript("OnMouseUp", function()
	GotLootOptions:Hide()
end)

-- TABS
Tab_1 = CreateFrame('Button', "parentTab1", GotLootOptions, "OptionsButtonTemplate");
Tab_1:SetPoint("TOPLEFT", GotLootOptions, "TOPLEFT", 30, -20);
Tab_1:SetText('Main Options');
--Tab_1:ClearAllPoints()
--Tab_1:SetID(1);
Tab_1:SetWidth(100)


local Tab_2 = CreateFrame('Button', "parentTab2", GotLootOptions, "OptionsButtonTemplate");
Tab_2:SetID(2);
Tab_2:SetWidth(100)
Tab_2:SetText('Keep List');
Tab_2:SetPoint("LEFT", Tab_1, "RIGHT", 20, 0);


local Tab_3 = CreateFrame('Button', "parentTab3", GotLootOptions, "OptionsButtonTemplate");
Tab_3:SetID(3);
Tab_3:SetWidth(100)
Tab_3:SetText('Black List');
Tab_3:SetPoint("LEFT", Tab_2, "RIGHT", 20, 0);

-- OPTIONS FRAMES

-- MAIN OPTIONS
local mainOptions = CreateFrame("Frame", "mainOptions", GotLootOptions, "InsetFrameTemplate")
mainOptions:SetWidth(660)
mainOptions:SetHeight(505)
mainOptions:SetPoint("CENTER", GotLootOptions, "CENTER", 0, -30);

mainOptions.title = mainOptions:CreateFontString(mainOptions, "ARTWORK", "GameFontNormal");
mainOptions.title:SetText('Main Options');
mainOptions.title:SetPoint("TOP", mainOptions, 10, -10);

mainOptions.sessionvalue = mainOptions:CreateFontString(mainOptions, "ARTWORK", "GameFontNormal");
mainOptions.sessionvalue:SetText('Main Options Goes Here');
mainOptions.sessionvalue:SetPoint("BOTTOM", mainOptions, 10, 10);

mainOptions.lootedvalue = mainOptions:CreateFontString(mainOptions, "ARTWORK", "GameFontNormal");
mainOptions.lootedvalue:SetText('');
mainOptions.lootedvalue:SetPoint("BOTTOM", mainOptions.sessionvalue, "TOP", 0, 10);


mainOptions.tradetitle = mainOptions:CreateFontString(mainOptions, "ARTWORK", "GameFontNormal");
mainOptions.tradetitle:SetText('Trade Goods');
mainOptions.tradetitle:SetPoint("TOP", mainOptions, 10, -120);

mainOptions.scrollstitle = mainOptions:CreateFontString(mainOptions, "ARTWORK", "GameFontNormal");
mainOptions.scrollstitle:SetText('Scrolls');
mainOptions.scrollstitle:SetPoint("TOP", mainOptions, 10, -360);


-- ITEMS
mainOptions.debug 	= CreateToggleButton("debug", "Debug mode", mainOptions, 10, -20)
mainOptions.junk 	= CreateToggleButton("junk", "Always Loot Junk (useful for fishing)", mainOptions, 400, -20)
mainOptions.bypass 	= CreateToggleButton("bypass", "Bypass filter and loot everthing", mainOptions, 400, -40)
mainOptions.info 	= CreateToggleButton("info", "Show info on items not looted", mainOptions, 10, -40)
mainOptions.value 	= CreateSlider("value", "Junk Value (Silver) : ", mainOptions, 80, -80, 1, 100)

mainOptions.ore 	= CreateToggleButton("ore", "Ore & Stone", mainOptions, 10, -140)
mainOptions.meat 	= CreateToggleButton("meat", "Meat", mainOptions, 200, -140)
mainOptions.cloth 	= CreateToggleButton("cloth", "Cloth", mainOptions, 10, -160)
mainOptions.leather	= CreateToggleButton("leather", "Leather", mainOptions, 10, -180)
mainOptions.herbs 	= CreateToggleButton("herbs", "Herbs", mainOptions, 10, -200)

mainOptions.food 	= CreateToggleButton("food", "Food & Drink", mainOptions, 10, -240)
mainOptions.healthp	= CreateToggleButton("hp", "Health Potions", mainOptions, 200, -240)
mainOptions.manap 	= CreateToggleButton("mp", "Mana Potions", mainOptions, 400, -240)
mainOptions.foodos 	= CreateSlider("foodos", "Food/Drink/Potion Level Offset (Number of levels below character to loot)", mainOptions, 80, -280, 0, 60)

mainOptions.s_agi 	= CreateToggleButton("s_agi", "Agility", mainOptions, 20, -380)
mainOptions.s_int 	= CreateToggleButton("s_int", "Intellect", mainOptions, 120, -380)
mainOptions.s_sta 	= CreateToggleButton("s_sta", "Stamina", mainOptions, 220, -380)
mainOptions.s_str 	= CreateToggleButton("s_str", "Strength", mainOptions, 320, -380)
mainOptions.s_ver 	= CreateToggleButton("s_ver", "Versatility", mainOptions, 420, -380)
mainOptions.s_lvl	= CreateSlider("s_lvl", "Minimum Scroll Rank", mainOptions, 80, -420, 1, 6)


-- ITEM SCRIPTS
mainOptions.debug:SetScript("OnClick", function()
	if mainOptions.debug:GetChecked() then
		LootOptions.Debug = true;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Debug mode on!");
	else
		LootOptions.Debug = false;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Debug mode off!");
	end
end)

mainOptions.info:SetScript("OnClick", function()
	if mainOptions.info:GetChecked() then
		LootOptions.Info = true;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Info mode on!");
	else
		LootOptions.Info = false;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Info mode off!");
	end
end)

mainOptions.junk:SetScript("OnClick", function(self,value)
	if mainOptions.junk:GetChecked() then
		LootOptions.AlwaysLootJunk = true;
	else
		LootOptions.AlwaysLootJunk = false;
	end
end)

mainOptions.bypass:SetScript("OnClick", function(self,value)
	if mainOptions.bypass:GetChecked() then
		LootOptions.Bypass = true;
	else
		LootOptions.Bypass = false;
	end
end)


mainOptions.value:SetScript("OnValueChanged", function(self,value)
	mainOptions.value.title:SetText("Junk Value: " .. math.floor(value) .. " Silver")
	rest = math.floor(value) * 100;
	LootOptions.MinJunkValue = rest;
end)

mainOptions.s_agi:SetScript("OnClick", function()
	if mainOptions.s_agi:GetChecked() then
		LootOptions.LootAgiScroll = true;
	else
		LootOptions.LootAgiScroll = false;
	end
end)

mainOptions.s_int:SetScript("OnClick", function()
	if mainOptions.s_int:GetChecked() then
		LootOptions.LootIntScroll = true;
	else
		LootOptions.LootIntScroll = false;
	end
end)

mainOptions.s_sta:SetScript("OnClick", function()
	if mainOptions.s_sta:GetChecked() then
		LootOptions.LootStaScroll = true;
	else
		LootOptions.LootStaScroll = false;
	end
end)

mainOptions.s_str:SetScript("OnClick", function()
	if mainOptions.s_str:GetChecked() then
		LootOptions.LootStrScroll = true;
	else
		LootOptions.LootStrScroll = false;
	end
end)

mainOptions.s_ver:SetScript("OnClick", function()
	if mainOptions.s_ver:GetChecked() then
		LootOptions.LootVerScroll = true;
	else
		LootOptions.LootVerScroll = false;
	end
end)

mainOptions.s_lvl:SetScript("OnValueChanged", function(self,value)
	mainOptions.s_lvl.title:SetText("Minimum Scroll Rank: " .. math.floor(value))
	LootOptions.LootScrollLVL = value
end)


mainOptions.ore:SetScript("OnClick", function()
	if mainOptions.ore:GetChecked() then
		LootOptions.LootOre = true;
	else
		LootOptions.LootOre = false;
	end
end)

mainOptions.meat:SetScript("OnClick", function()
	if mainOptions.meat:GetChecked() then
		LootOptions.LootMeat = true;
	else
		LootOptions.LootMeat = false;
	end
end)


mainOptions.cloth:SetScript("OnClick", function()
	if mainOptions.cloth:GetChecked() then
		LootOptions.LootCloth = true;
	else
		LootOptions.LootCloth = false;
	end
end)

mainOptions.leather:SetScript("OnClick", function()
	if mainOptions.leather:GetChecked() then
		LootOptions.LootLeather = true;
	else
		LootOptions.LootLeather = false;
	end
end)

mainOptions.herbs:SetScript("OnClick", function()
	if mainOptions.herbs:GetChecked() then
		LootOptions.LootHerbs = true;
	else
		LootOptions.LootHerbs = false;
	end
end)

mainOptions.food:SetScript("OnClick", function()
	if mainOptions.food:GetChecked() then
		LootOptions.LootFood = true;
	else
		LootOptions.LootFood = false;
	end
end)

mainOptions.healthp:SetScript("OnClick", function()
	if mainOptions.healthp:GetChecked() then
		LootOptions.HealthPotions = true;
	else
		LootOptions.HealthPotions = false;
	end
end)

mainOptions.manap:SetScript("OnClick", function()
	if mainOptions.manap:GetChecked() then
		LootOptions.ManaPotions = true;
	else
		LootOptions.ManaPotions = false;
	end
end)


mainOptions.foodos:SetScript("OnValueChanged", function(self,value)
	mainOptions.foodos.title:SetText("Food/Drink/Potion Level Offset (Number of levels below character to loot) [" .. math.floor(value) .. "]")
	LootOptions.FoodLevelOffset = math.floor(value)
end)

-- KEEP LIST
local keepOptions = CreateFrame("Frame", "keepOptions", GotLootOptions, "InsetFrameTemplate")
keepOptions:SetWidth(660)
keepOptions:SetHeight(505)
keepOptions:SetPoint("CENTER", GotLootOptions, "CENTER", 0, -30);
keepOptions:Hide()
keepOptions.input = CreateFrame("EditBox", "keepinput",keepOptions,"InputBoxTemplate")
keepOptions.input:SetWidth(150)
keepOptions.input:SetHeight(20)
keepOptions.input:SetAutoFocus(false)
keepOptions.input:SetPoint("TOPLEFT", keepOptions, "TOPLEFT", 20, -10);

keepOptions.keep = CreateFrame('Button', "keepbut", keepOptions.input, "UIPanelButtonTemplate");
keepOptions.keep:SetWidth(100)
keepOptions.keep:SetText('Remove');
keepOptions.keep:SetPoint("LEFT", keepOptions.input, "RIGHT", 10, 0);
keepOptions.keep:SetScript("OnClick", function()
	RemoveWhiteList(keepOptions.input:GetText())
end)

-- *********************************************************
-- DROP BOX
keepOptions.itemBut = CreateFrame("Button", "keepbutton", keepOptions);
keepOptions.itemBut.ctrl = keepOptions;
keepOptions.itemBut:SetWidth(37);
keepOptions.itemBut:SetHeight(37);
keepOptions.itemBut:SetPoint("TOPLEFT", 70, -80);

keepOptions.itemBut:RegisterForDrag("LeftButton");
keepOptions.itemBut:SetScript("OnClick", function() 
	WhiteListDrop()
end);
keepOptions.itemBut:SetScript("OnDragStart", function() 
	WhiteListDrop()
end);
keepOptions.itemBut:SetScript("OnReceiveDrag", function() 
	WhiteListDrop()
end);
keepOptions.itemBut:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
keepOptions.itemBut:SetNormalTexture("Interface\\Buttons\\ButtonHilight-Square");

keepOptions.droptitle = keepOptions:CreateFontString(keepOptions, "ARTWORK", "GameFontNormal");
keepOptions.droptitle:SetText('Drop item here to add\nto white list');
keepOptions.droptitle:SetPoint("TOPLEFT", keepOptions, 20, -120);


-- *********************************************************


keepOptions.title = keepOptions:CreateFontString(keepOptions, "ARTWORK", "GameFontNormal");
keepOptions.title:SetText('White List Goes Here');
keepOptions.title:SetPoint("TOPLEFT", keepOptions, 20, -40);

keepOptions.scrollchild = keepOptions.scrollchild or CreateFrame("Frame"); 

keepOptions.scrollframe = CreateFrame("ScrollFrame", "keeplist", keepOptions, "UIPanelScrollFrameTemplate")
local scrollbarName = keepOptions.scrollframe:GetName()
keepOptions.scrollbar = _G[scrollbarName.."ScrollBar"];
keepOptions.scrollupbutton = _G[scrollbarName.."ScrollBarScrollUpButton"];
keepOptions.scrolldownbutton = _G[scrollbarName.."ScrollBarScrollDownButton"];

keepOptions.scrollupbutton:ClearAllPoints();
keepOptions.scrollupbutton:SetPoint("TOPRIGHT", keepOptions.scrollframe, "TOPRIGHT", -2, -2);
 
keepOptions.scrolldownbutton:ClearAllPoints();
keepOptions.scrolldownbutton:SetPoint("BOTTOMRIGHT", keepOptions.scrollframe, "BOTTOMRIGHT", -2, 2);
 
keepOptions.scrollbar:ClearAllPoints();
keepOptions.scrollbar:SetPoint("TOP", keepOptions.scrollupbutton, "BOTTOM", 0, -2);
keepOptions.scrollbar:SetPoint("BOTTOM", keepOptions.scrolldownbutton, "TOP", 0, 2);

keepOptions.scrollframe:SetScrollChild(keepOptions.scrollchild);
keepOptions.scrollframe:SetAllPoints(keepOptions);
keepOptions.scrollchild:SetSize(keepOptions.scrollframe:GetWidth(), ( keepOptions.scrollframe:GetHeight() * 2 ));

keepOptions.moduleoptions = keepOptions.moduleoptions or CreateFrame("Frame", nil, keepOptions.scrollchild);
keepOptions.moduleoptions:SetAllPoints(keepOptions.scrollchild);
keepOptions.moduleoptions.list = keepOptions.moduleoptions:CreateFontString(keepOptions.moduleoptions, "ARTWORK", "GameFontNormal");
keepOptions.moduleoptions.list:SetPoint("TOP", keepOptions.moduleoptions, "TOP", 0, -80);
--keepOptions.moduleoptions.fontstring:SetText("This is a test.");
--keepOptions.moduleoptions.fontstring:SetPoint("BOTTOMLEFT", keepOptions.moduleoptions, "BOTTOMLEFT", 20, 60);

-- BLACK LIST
local blOptions = CreateFrame("Frame", "blOptions", GotLootOptions, "InsetFrameTemplate")
blOptions:SetWidth(660)
blOptions:SetHeight(505)
blOptions:SetPoint("CENTER", GotLootOptions, "CENTER", 0, -30);
blOptions:Hide()

-- *********************************************************
-- DROP BOX
blOptions.itemBut = CreateFrame("Button", "blbutton", blOptions);
blOptions.itemBut.ctrl = blOptions;
blOptions.itemBut:SetWidth(37);
blOptions.itemBut:SetHeight(37);
blOptions.itemBut:SetPoint("TOPLEFT", 70, -80);

blOptions.itemBut:RegisterForDrag("LeftButton");
blOptions.itemBut:SetScript("OnClick", function() 
	BlackListDrop()
end);
blOptions.itemBut:SetScript("OnDragStart", function() 
	BlackListDrop()
end);
blOptions.itemBut:SetScript("OnReceiveDrag", function() 
	BlackListDrop()
end);
blOptions.itemBut:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
blOptions.itemBut:SetNormalTexture("Interface\\Buttons\\ButtonHilight-Square");

blOptions.droptitle = blOptions:CreateFontString(blOptions, "ARTWORK", "GameFontNormal");
blOptions.droptitle:SetText('Drop item here to remove\nfrom the black list');
blOptions.droptitle:SetPoint("TOPLEFT", blOptions, 20, -120);


-- *********************************************************


blOptions.input = CreateFrame("EditBox", "keepinput",blOptions,"InputBoxTemplate")
blOptions.input:SetWidth(150)
blOptions.input:SetHeight(20)
blOptions.input:SetAutoFocus(false)
blOptions.input:SetPoint("TOPLEFT", blOptions, "TOPLEFT", 20, -10);

blOptions.keep = CreateFrame('Button', "blbut", blOptions.input, "UIPanelButtonTemplate");
blOptions.keep:SetWidth(100)
blOptions.keep:SetText('Remove');
blOptions.keep:SetPoint("LEFT", blOptions.input, "RIGHT", 10, 0);
blOptions.keep:SetScript("OnClick", function()
	RemoveBlackList(blOptions.input:GetText())
end)


blOptions.title = blOptions:CreateFontString(blOptions, "ARTWORK", "GameFontNormal");
blOptions.title:SetText('White List Goes Here');
blOptions.title:SetPoint("TOPLEFT", blOptions, 20, -40);

blOptions.scrollchild = blOptions.scrollchild or CreateFrame("Frame"); 

blOptions.scrollframe = CreateFrame("ScrollFrame", "blacklist", blOptions, "UIPanelScrollFrameTemplate")
local scrollbarName = blOptions.scrollframe:GetName()
blOptions.scrollbar = _G[scrollbarName.."ScrollBar"];
blOptions.scrollupbutton = _G[scrollbarName.."ScrollBarScrollUpButton"];
blOptions.scrolldownbutton = _G[scrollbarName.."ScrollBarScrollDownButton"];

blOptions.scrollupbutton:ClearAllPoints();
blOptions.scrollupbutton:SetPoint("TOPRIGHT", blOptions.scrollframe, "TOPRIGHT", -2, -2);
 
blOptions.scrolldownbutton:ClearAllPoints();
blOptions.scrolldownbutton:SetPoint("BOTTOMRIGHT", blOptions.scrollframe, "BOTTOMRIGHT", -2, 2);
 
blOptions.scrollbar:ClearAllPoints();
blOptions.scrollbar:SetPoint("TOP", blOptions.scrollupbutton, "BOTTOM", 0, -2);
blOptions.scrollbar:SetPoint("BOTTOM", blOptions.scrolldownbutton, "TOP", 0, 2);

blOptions.scrollframe:SetScrollChild(blOptions.scrollchild);
blOptions.scrollframe:SetAllPoints(blOptions);
blOptions.scrollchild:SetSize(blOptions.scrollframe:GetWidth(), ( blOptions.scrollframe:GetHeight() * 2 ));

blOptions.moduleoptions = blOptions.moduleoptions or CreateFrame("Frame", nil, blOptions.scrollchild);
blOptions.moduleoptions:SetAllPoints(blOptions.scrollchild);
blOptions.moduleoptions.list = blOptions.moduleoptions:CreateFontString(blOptions.moduleoptions, "ARTWORK", "GameFontNormal");
blOptions.moduleoptions.list:SetPoint("TOP", blOptions.moduleoptions, "TOP", 0, -80);


-- SET TAB BUTTONS AFTER FRAME CREATION
Tab_1:SetScript("OnClick", function()
	HideOptionFrames()
	mainOptions:Show();
end)
Tab_2:SetScript("OnClick", function()
	HideOptionFrames()
	keepOptions:Show()
end)
Tab_3:SetScript("OnClick", function()
	HideOptionFrames()
	blOptions:Show()
end)

-- HIDE OPTIONS WINDOW
GotLootOptions:Hide()


-- HELPER FRAME

GLFB = CreateFrame("Frame", "GLFB",UIParent)
GLFB:SetPoint("CENTER",0,0);
GLFB:SetSize(64,64)
GLFB.texture = GLFB:CreateTexture(nil, "BACKGROUND")
GLFB.texture:SetTexture("Interface\\AddOns\\GotLoot\\LootIcon.tga")
GLFB.texture:SetAllPoints(true)

GLFB:SetMovable(true)
GLFB:EnableMouse(true)

GLFB:SetScript("OnMouseDown", function(self, button)
	if button == "RightButton" and not self.isMoving then
	 self:StartMoving();
	 self.isMoving = true;
	end
  end)
GLFB:SetScript("OnMouseUp", function(self, button)
	if button == "RightButton" and self.isMoving then
		self:StopMovingOrSizing();
		self.isMoving = false;
		point, relativeTo, relativePoint, xOfs, yOfs = GLFB:GetPoint();
		LootOptions.location.x = xOfs;
		LootOptions.location.y = yOfs;
	end
	if button == "LeftButton" then
		if GotLootOptions:IsShown() then
			GotLootOptions:Hide();
		else
			GotLootOptions:Show();
		end
	end
end)

-- *********************
-- ** END OF GUI CODE **
-- *********************

--Register Events
GotLootFrame:RegisterEvent("ADDON_LOADED");
GotLootFrame:RegisterEvent("VARIABLES_LOADED");
GotLootFrame:RegisterEvent("LOOT_OPENED");
GotLootFrame:RegisterEvent("CHAT_MSG_MONEY");




--Process Slash Commands
SLASH_GOTLOOT1 = '/gl';

SlashCmdList["GOTLOOT"] = function(msg)
	if msg == 'enable' then
		LootOptions.Enabled = true;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Firing Up!");
		local AutoLoot=GetCVar("AutoLootDefault"); 
		if(AutoLoot=="1") then 
			SetCVar("AutoLootDefault",0);
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Turning Autoloot Off");
		end
	end

	if msg == 'disable' then
		LootOptions.Enabled = false;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Shutting Down!");
		if LootOptions.ALonStop == true then
		SetCVar("AutoLootDefault",1);
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Turning Autoloot On");
		end
	end

	if msg == 'toggle' then
		if LootOptions.Enabled == false then
		LootOptions.Enabled = true;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Firing Up!");
		local AutoLoot=GetCVar("AutoLootDefault"); 
		if(AutoLoot=="1") then 
			SetCVar("AutoLootDefault",0);
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Turning Autoloot Off");
		end
	else
		LootOptions.Enabled = false;
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Shutting Down!");
		if LootOptions.ALonStop == true then
			SetCVar("AutoLootDefault",1);
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Turning Autoloot On");
		end
		end
	end

	if msg == 'cloth' then
		if LootOptions.LootCloth == false then
			LootOptions.LootCloth = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Looting Cloth!");
		else
			LootOptions.LootCloth = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Ignoring Cloth!");
		end
	end

	if msg == 'ore' then
		if LootOptions.LootOre == false then
			LootOptions.LootOre = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Looting Ore!");
		else
			LootOptions.LootOre = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Ignoring Ore!");
		end
	end

	if msg == 'leather' then
		if LootOptions.LootLeather == false then
			LootOptions.LootLeather = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Looting Leather!");
		else
			LootOptions.LootLeather = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Ignoring Leather!");
		end
	end

	if msg == 'herbs' then
		if LootOptions.LootHerbs == false then
			LootOptions.LootHerbs = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Looting Herbs!");
		else
			LootOptions.LootHerbs = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Ignoring Herbs!");
		end
	end

	if msg == 'info' then
		if LootOptions.Info == false then
			LootOptions.Info = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Info mode on! Showing passed on loot");
		else
			LootOptions.Info = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Info mode off!");
		end
	end

	-- ALWAYS ON MIGHT REMOVE
	if msg == 'lootshinies' then
		if LootOptions.LootShinies == false then
			LootOptions.LootShinies = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Looting Greens and above!");
		else
			LootOptions.LootShinies = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Ignoring Greens and above!");
		end
	end

	-- NOT REALLY NEEDED
	if msg == 'alonstop' then
		if LootOptions.ALonStop == false then
			LootOptions.ALonStop = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Autoloot will be enabled on toggle off!");
		else
			LootOptions.ALonStop = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Autoloot will NOT be enabled on toggle off!");
		end
	end

	if msg == 'loottradegoods' then
		if LootOptions.TradeGoods == false then
			LootOptions.TradeGoods = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Looting Trade Goods!");
		else
			LootOptions.TradeGoods = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Ignoring Trade Goods!");
		end
	end

	if msg == 'food' then
		if LootOptions.LootFood == false then
			LootOptions.LootFood = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Looting Food Stuffs!");
		else
			LootOptions.LootFood = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Ignoring Food Stuffs!!");
		end
	end


	if msg == 'lootjunk' then
		if LootOptions.LootJunk == false then
			LootOptions.LootJunk = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Looting Junk!");
		else
			LootOptions.LootJunk = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Ignoring Junk!");
		end
	end

	-- JUNK
	if msg == 'filterjunk' then
		if LootOptions.FilterJunk == false then
			LootOptions.FilterJunk = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Filtering Junk!");
		else
			LootOptions.FilterJunk = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r No Longer Filtering Junk!");
		end
	end

	-- DEBUG TOGGLE
	if msg == 'debug' then
		if LootOptions.Debug == false then
			LootOptions.Debug = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Debug mode on!");
		else
			LootOptions.Debug = false;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Debug mode off!");
		end
	end

	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	-- WHITE LIST
	if cmd == 'keep' then
		WhiteList(args)
	end
	-- BLACK LIST
	if cmd == 'bl' then
		BlackList(args)
	end

	-- defunct, you now call the same to add and remove keep/bl
	if cmd == 'remove' then
		local itemName, itemLink, _, _, _, itemType, itemSubType, _, _, _, itemSellPrice = GetItemInfo(args);
		if itemName ~= nil then
			if CheckList(LootOptions.Keep, itemName) then
				RemoveItem(LootOptions.Keep, itemName);
				DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Removed from loot list: " .. itemLink);
			else
				DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Not looting " .. itemLink);
			end
		end
	end

	if msg == 'value' then
		DEFAULT_CHAT_FRAME:AddMessage(("|" .. Colors.Red .. "Got Loot?|r Junk value : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r"):format(LootOptions.MinJunkValue / 100 / 100, (LootOptions.MinJunkValue / 100) % 100, LootOptions.MinJunkValue % 100) );
	end

	local command, rest = msg:match("^(%S*)%s*(.-)$");
	if command == 'value' and rest ~= "" then
		rest = rest * 100;
		LootOptions.MinJunkValue = rest;
		DEFAULT_CHAT_FRAME:AddMessage(("|" .. Colors.Red .. "Got Loot?|r Junk value set : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r"):format(rest / 100 / 100, (rest / 100) % 100, rest % 100) );
	end 

	if msg == 'options' then
		-- UI TO GO HERE
		
		if GotLootOptions:IsShown() then
			GotLootOptions:Hide();
		else
			GotLootOptions:Show();
		end
	end

	if msg == '' then
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Usage:");
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl toggle|r [Toggle on/off]");
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl enable|r [Turn on]");
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl disable|r [Turn off]");
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl keep [Item Link]|r [Add / Remove from keep list]");
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl bl [Item Link]|r [Add / Remove from black list list]");
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl value number|r [Set min value of junk in silver]");

		if LootOptions.LootFood == true then out = "|" .. Colors.Green .. "[ON]|r" else out = "|" .. Colors.Red .. "[OFF]|r" end
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl food|r [Toggles looting food and drink]".. out);

		if LootOptions.LootPotions == true then out = "|" .. Colors.Green .. "[ON]|r" else out = "|" .. Colors.Red .. "[OFF]|r" end
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl potions|r [Toggles looting potions]".. out);
		
		if LootOptions.LootCloth == true then out = "|" .. Colors.Green .. "[ON]|r" else out = "|" .. Colors.Red .. "[OFF]|r" end
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl cloth|r [Toggles looting cloth]" .. out);
		
		if LootOptions.LootOre == true then out = "|" .. Colors.Green .. "[ON]|r" else out = "|" .. Colors.Red .. "[OFF]|r" end
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl ore|r [Toggles looting ore]".. out);
		
		if LootOptions.LootLeather == true then out = "|" .. Colors.Green .. "[ON]|r" else out = "|" .. Colors.Red .. "[OFF]|r" end
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl leather|r [Toggles looting leather]".. out);
		
		if LootOptions.LootHerbs == true then out = "|" .. Colors.Green .. "[ON]|r" else out = "|" .. Colors.Red .. "[OFF]|r" end
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl herbs|r [Toggles looting herbs]".. out);
		
		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "/gl debug|r [Toggles debug mode]");
	end

	end
 


 GotLootFrame:SetScript("OnEvent", function(self,event,arg1)

	if event == "ADDON_LOADED" and arg1 == "GotLoot" then
	--DEFAULT_CHAT_FRAME:AddMessage(LootOptions.MinJunkValue);
		if LootOptions.LootJunk == nil then 
			LootOptions.LootJunk = true;
		end
		if LootOptions.AlwaysLootJunk == nil then 
			LootOptions.AlwaysLootJunk = false;
		end
		if LootOptions.Bypass == nil then 
			LootOptions.Bypass = false;
		end
		if LootOptions.FilterJunk == nil then 
			LootOptions.FilterJunk = true;
		end
		if LootOptions.MinJunkValue == nil then 
			LootOptions.MinJunkValue = 10000;
		end
		if LootOptions.LootShinies == nil then 
			LootOptions.LootShinies = true;
		end
		if LootOptions.LootCloth == nil then 
			LootOptions.LootCloth = true;
		end
		if LootOptions.LootFood == nil then 
			LootOptions.LootFood = false;
		end
		if LootOptions.FoodLevelOffset == nil then 
			LootOptions.FoodLevelOffset = 5;
		end
		if LootOptions.TradeGoods == nil then 
			LootOptions.TradeGoods = true;
		end
		if LootOptions.LootPotions == nil then 
			LootOptions.LootPotions = true;
		end
		if LootOptions.LootLeather == nil then 
			LootOptions.LootLeather = true;
		end
		if LootOptions.LootOre == nil then 
			LootOptions.LootOre = true;
		end
		if LootOptions.LootHerbs == nil then 
			LootOptions.LootHerbs = true;
		end
		if LootOptions.Enabled == nil then 
			LootOptions.Enabled = true;
		end
		if LootOptions.ALonStop == nil then 
			LootOptions.ALonStop = false;
		end
		if LootOptions.Debug == nil then 
			LootOptions.Debug = false;
		end
		if LootOptions.Info == nil then 
			LootOptions.Info = false;
		end
		if LootOptions.Keep == nil then
			LootOptions.Keep = {};
		end
		if LootOptions.Blacklist == nil then
			LootOptions.Blacklist = {};
		end
		if LootOptions.ManaPotions == nil then 
			LootOptions.ManaPotions = true;
		end
		if LootOptions.HealthPotions == nil then 
			LootOptions.HealthPotions = true;
		end
		if LootOptions.LootMeat == nil then 
			LootOptions.LootMeat = true;
		end
		if LootOptions.LootAgiScroll == nil then
			LootOptions.LootAgiScroll = true
		end
		if LootOptions.LootStaScroll == nil then
			LootOptions.LootStaScroll = true
		end
		if LootOptions.LootStrScroll == nil then
			LootOptions.LootStrScroll = true
		end
		if LootOptions.LootIntScroll == nil then
			LootOptions.LootIntScroll = true
		end
		if LootOptions.LootVerScroll == nil then
			LootOptions.LootVerScroll = true
		end
		if LootOptions.LootScrollLVL == nil then
			LootOptions.LootScrollLVL = 1
		end
		if LootOptions.LootBOP == nil then
			LootOptions.LootBOP = true
		end

		if LootOptions.location ~= nil then
			if LootOptions.location.x ~= nil and LootOptions.location.y ~= nil then
				GLFB:SetPoint("CENTER",LootOptions.location.x,LootOptions.location.y);
			end
		else
			LootOptions.location = {}
			LootOptions.location.x = 0
			LootOptions.location.y = 0
		end

		DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Fired up!");
		local AutoLoot=GetCVar("AutoLootDefault"); 
		if(AutoLoot=="1") then 
			SetCVar("AutoLootDefault",0);
			LootOptions.ALonStop = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Turning Autoloot Off");
			CurrentMoney = GetMoney()
		end
		UpdateUI()
	end
	
	if event == "VARIABLES_LOADED" then
		local AutoLoot=GetCVar("AutoLootDefault"); 
		if(AutoLoot=="1") then 
			SetCVar("AutoLootDefault",0);
			LootOptions.ALonStop = true;
			DEFAULT_CHAT_FRAME:AddMessage("|" .. Colors.Red .. "Got Loot?|r Turning Autoloot Off");
			CurrentMoney = GetMoney()
		end
		UpdateUI()
	end

	if event == "CHAT_MSG_MONEY" then
		local newMoney = GetMoney()
		if CurrentMoney == 0 then
			CurrentMoney = newMoney
		end
		if newMoney > CurrentMoney and CurrentMoney > 0 then
			LootedMoney = LootedMoney + (newMoney - CurrentMoney)
			CurrentMoney = newMoney
			UpdateUI()
		end
	end

	if event == "LOOT_OPENED" then
	if LootOptions.Enabled == true then --Check GotLoot is enabled
	local numItems = GetNumLootItems();
	--DEFAULT_CHAT_FRAME:AddMessage(numItems);
	
	local lootIssue = false;

	for CurrentLootItem=1, numItems, 1 do
		local looted=false;
		local ignored=false;
		local loottype = GetLootSlotType(CurrentLootItem);
		
		--LOOT MONEY
		if (LootSlotHasItem(CurrentLootItem)) then

			local texture, item, quantity, currencyID, quality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(CurrentLootItem);
			
			if (loottype == 2 or loottype == 3) then
				LootSlot(CurrentLootItem);
				CurrentMoney = GetMoney();
				looted = true;
			else
			--LOOT ITEMS
			local texture, item, quantity, currencyID, quality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(CurrentLootItem);

			local itemLink = GetLootSlotLink(CurrentLootItem)
			local itemID = GetItemInfoFromHyperlink(itemLink)
			--DEFAULT_CHAT_FRAME:AddMessage(itemLink .. " : " .. itemID);
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemID) 
			--DEFAULT_CHAT_FRAME:AddMessage(itemName);
				
			local querytime = 0;
			local now = 0;
			while now - querytime < 0.50 do
				now = GetTime();
			end

			local itemName, itemLink, _, itemLevel, itemMinLevel, itemType, itemSubType, _, _, _, itemSellPrice = GetItemInfo(itemID);
			
			
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemID) 
			--DEFAULT_CHAT_FRAME:AddMessage((item .. " : %dg %ds %dc"):format(itemSellPrice / 100 / 100, (itemSellPrice / 100) % 100, itemSellPrice % 100) );
			
			--DEFAULT_CHAT_FRAME:AddMessage(Validate(item));
			--DEFAULT_CHAT_FRAME:AddMessage(Validate(itemLink));
			--local VendorValue = itemSellPrice * quantity
			if itemName ~= nil then
				--DEFAULT_CHAT_FRAME:AddMessage(itemName);
			else
				--DEFAULT_CHAT_FRAME:AddMessage("Could not query: " .. item);
			end

			if (not itemType) then
				itemType = "";
			end

			if (not itemSubType) then
				itemSubType = "";
			end

			if (not itemLink) then
				itemLink = GetLootSlotLink(CurrentLootItem);
			end

			if (not itemName) then
				-- lootIssue = true;
				itemName = item;
			end

			-- BLACK LIST
			if looted==false then
				if CheckList(LootOptions.Blacklist, itemName) then
					looted = true;
					ignored = true;
				end
			end

			-- BYPASS
			if LootOptions.Bypass == true and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end


			-- ALWAYS LOOT JUNK
			if LootOptions.AlwaysLootJunk == true and itemSubType == types.Junk and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
		
			--LOOT FOOD ITEMS
			if LootOptions.LootFood == true and itemSubType == types.Food and looted == false then
				minFoodLevel = UnitLevel("Player") - LootOptions.FoodLevelOffset;
				if itemMinLevel >= minFoodLevel then
					LootItem(CurrentLootItem);
					looted=true;
				end
			end
			
			--LOOT POTIONS
			if itemName then
				--LOOT HEALTH POTIONS
				if LootOptions.HealthPotions == true and itemSubType == types.Potions and looted == false and string.find(itemName, "Heal") then
				--if LootOptions.HealthPotions == true and string.find(itemName, "Health") and looted == false then
					minFoodLevel = UnitLevel("Player") - LootOptions.FoodLevelOffset;
					if itemMinLevel >= minFoodLevel then
						LootItem(CurrentLootItem);
						looted=true;
					end
				end

				--LOOT MANA POTIONS
				if LootOptions.ManaPotions == true and itemSubType == types.Potions and string.find(itemName, "Mana") and looted == false then
					minFoodLevel = UnitLevel("Player") - LootOptions.FoodLevelOffset;
					if itemMinLevel >= minFoodLevel then
						LootItem(CurrentLootItem);
						looted=true;
					end
				end

			end
			
			--LOOT QUEST ITEMS
			if itemType == "Quest" and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT RECIPE ITEMS
			if itemType == "Recipe" and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT GEM ITEMS
			if itemType == "Gem" and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT KEY ITEMS
			if itemType == "Key" and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT ENCHANTING ITEMS
			if itemSubType == "Enchanting" and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end

			--LOOT MEAT/COOKING ITEMS
			if LootOptions.LootMeat == true and itemSubType == types.Cooking and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end


			--LOOT ELEMEMTAL ITEMS (MOTES OF FIRE ETC)
			if itemSubType == types.Elemental and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT CLOTH ITEMS
			if itemType == types.Trade and itemSubType == types.Cloth and LootOptions.LootCloth == true and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT SKINNING ITEMS
			if itemSubType == types.Leather and LootOptions.LootLeather == true and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT MINING ITEMS
			if itemSubType == types.Ore and LootOptions.LootOre == true and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT HERB ITEMS
			if itemSubType == types.Herbs and LootOptions.LootHerbs == true and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT PET ITEMS
			if itemSubType == "Pet" and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT MOUNT ITEMS
			if itemType == "Container" and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
		
			--LOOT BAG ITEMS
			if itemSubType == "Bag" and looted == false then
				LootItem(CurrentLootItem);
				looted=true;
			end
			
			--LOOT SCROLLS
			scrollRank = {}
			if LootOptions.LootScrollLVL == 2 then
				table.insert(scrollRank, "II")
			elseif LootOptions.LootScrollLVL <= 3 then
				table.insert(scrollRank, "III")
			elseif LootOptions.LootScrollLVL <= 4 then
				table.insert(scrollRank, "IV")
			elseif LootOptions.LootScrollLVL <= 5 then
				table.insert(scrollRank, "V")
			elseif LootOptions.LootScrollLVL <= 6 then
				table.insert(scrollRank, "VI")
			end

			if LootOptions.LootAgiScroll == true and itemType == types.Food and itemSubType == types.Scroll and string.find(itemName, "Agility") then
				if LootOptions.LootScrollLVL == 1 then
					LootItem(CurrentLootItem);
					looted=true;
				else
					for i,v in pairs(scrollRank) do
						if string.find(itemName, v) then
							LootItem(CurrentLootItem);
							looted=true;
							break
						end
					end
				end
			end

			if LootOptions.LootStaScroll == true and itemType == types.Food and itemSubType == types.Scroll and string.find(itemName, "Stamina") then
				if LootOptions.LootScrollLVL == 1 then
					LootItem(CurrentLootItem);
					looted=true;
				else
					for i,v in pairs(scrollRank) do
						if string.find(itemName, v) then
							LootItem(CurrentLootItem);
							looted=true;
							break
						end
					end
				end
			end

			if LootOptions.LootStrScroll == true and itemType == types.Food and itemSubType == types.Scroll and string.find(itemName, "Strength") then
				if LootOptions.LootScrollLVL == 1 then
					LootItem(CurrentLootItem);
					looted=true;
				else
					for i,v in pairs(scrollRank) do
						if string.find(itemName, v) then
							LootItem(CurrentLootItem);
							looted=true;
							break
						end
					end
				end
			end

			if LootOptions.LootVerScroll == true and itemType == types.Food and itemSubType == types.Scroll and string.find(itemName, "Spirit") then
				if LootOptions.LootScrollLVL == 1 then
					LootItem(CurrentLootItem);
					looted=true;
				else
					for i,v in pairs(scrollRank) do
						if string.find(itemName, v) then
							LootItem(CurrentLootItem);
							looted=true;
							break
						end
					end
				end
			end

			if LootOptions.LootIntScroll == true and itemType == types.Food and itemSubType == types.Scroll and string.find(itemName, "Versatility") then
				if LootOptions.LootScrollLVL == 1 then
					LootItem(CurrentLootItem);
					looted=true;
				else
					for i,v in pairs(scrollRank) do
						if string.find(itemName, v) then
							LootItem(CurrentLootItem);
							looted=true;
							break
						end
					end
				end
			end


			--LOOT JUNK ITEMS OF WORTH
			if looted==false then
				if LootOptions.LootJunk == true then
					if itemSellPrice ~= nil then
						if tonumber(LootOptions.MinJunkValue) <= (tonumber(itemSellPrice) * tonumber(quantity)) then
							LootItem(CurrentLootItem);
							looted=true;
						end
					end
				end
			end

			--LOOT GREEN & ABOVE ITEMS
			if looted==false then
				if LootOptions.LootShinies == true then
					if quality ~= nil then
						if quality >= 2 then
							LootItem(CurrentLootItem);
							looted=true;
						end
					end
				end
			end
		
			--ALWAYS LOOT LIST
			if looted==false then
				--DEFAULT_CHAT_FRAME:AddMessage(CheckList(LootOptions.Keep, itemName));


				if CheckList(LootOptions.Keep, itemName) then
					LootItem(CurrentLootItem);
					looted = true;
				end
			end

			--DEBUG MESSAGES
			if LootOptions.Debug == true then
				if (not itemSellPrice) then
					itemSellPrice = 0;
				end
				if looted == true and ignored == false then
					DEFAULT_CHAT_FRAME:AddMessage(("|" .. Colors.Green .. "GL:|r " .. Validate(itemLink) .. " [%d/%d] (" .. itemType .. "|" .. itemSubType .. ") x" .. quantity .. " : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r Per Item"):format(itemLevel, itemMinLevel, itemSellPrice / 100 / 100, (itemSellPrice / 100) % 100, itemSellPrice % 100));
				else
					ignoremsg = "";
					if ignored==true then
						ignoremsg = "|"  .. Colors.Red .. "[BL]|r";
					end
					DEFAULT_CHAT_FRAME:AddMessage(("|" .. Colors.Red .. "GL:|r " .. itemLink .. " [%d/%d] (" .. itemType .. "|" .. itemSubType .. ") x" .. quantity .. " : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r Per Item " .. ignoremsg):format(itemLevel, itemMinLevel, itemSellPrice / 100 / 100, (itemSellPrice / 100) % 100, itemSellPrice % 100));
				end
			end

			if LootOptions.Info == true and LootOptions.Debug == false and looted == false then
				ignoremsg = "[Ignored]";
				if (not itemSellPrice) then
					itemSellPrice = 0;
				end
				if looted == false and ignored == false then
					DEFAULT_CHAT_FRAME:AddMessage(("|" .. Colors.Red .. "GL " .. ignoremsg .. ": |r " .. itemLink .. " (" .. itemType .. "|" .. itemSubType .. ") x" .. quantity .. " : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r "):format((itemSellPrice * quantity) / 100 / 100, ((itemSellPrice * quantity) / 100) % 100, (itemSellPrice * quantity) % 100));
				else
					if ignored==true then
						ignoremsg =  "[Blacklist]";
					end
					DEFAULT_CHAT_FRAME:AddMessage(("|" .. Colors.Red .. "GL " .. ignoremsg .. ": |r " .. itemLink .. " (" .. itemType .. "|" .. itemSubType .. ") x" .. quantity .. " : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r "):format((itemSellPrice * quantity) / 100 / 100, ((itemSellPrice * quantity) / 100) % 100, (itemSellPrice * quantity) % 100));
				end
			end

			if looted == true and itemSellPrice ~= nil then
				lootedValue = lootedValue + (itemSellPrice * quantity)
				UpdateUI()
			end

			
		end -- Loop End
		end
	end
		if (not lootIssue) then
			CloseLoot();
		end
	end
	end
	end)

