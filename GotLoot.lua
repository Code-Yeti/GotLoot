

LootOptions = {};

local ClothTypes = {"linen cloth", "wool cloth", "silk cloth", "mageweave cloth", "runecloth", "neatherwave cloth", "embersilk cloth", "windwool cloth"};

--Event Frame
GotLootFrame = CreateFrame("Frame", "GotLootFrame", UIParent);

GotLootFrame:RegisterEvent("ADDON_LOADED");
GotLootFrame:RegisterEvent("VARIABLES_LOADED");
GotLootFrame:RegisterEvent("LOOT_OPENED");

--Process Slash Commands

SLASH_GOTLOOT1 = '/gl';

SlashCmdList["GOTLOOT"] = function(msg)
 if msg == 'enable' then
  LootOptions.Enabled = true;
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Firing Up!");
	local AutoLoot=GetCVar("AutoLootDefault"); 
	if(AutoLoot=="1") then 
		SetCVar("AutoLootDefault",0);
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Turning Autoloot Off");
	end
 end

 if msg == 'disable' then
  LootOptions.Enabled = false;
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Shutting Down!");
  if LootOptions.ALonStop == true then
	SetCVar("AutoLootDefault",1);
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Turning Autoloot On");
  end
 end
 
 if msg == 'toggle' then
  if LootOptions.Enabled == false then
	LootOptions.Enabled = true;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Firing Up!");
	local AutoLoot=GetCVar("AutoLootDefault"); 
	if(AutoLoot=="1") then 
		SetCVar("AutoLootDefault",0);
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Turning Autoloot Off");
	end
  else
	LootOptions.Enabled = false;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Shutting Down!");
	if LootOptions.ALonStop == true then
		SetCVar("AutoLootDefault",1);
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Turning Autoloot On");
	end
  end
 end

 if msg == 'lootcloth' then
  if LootOptions.LootCloth == false then
	LootOptions.LootCloth = true;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Looting Cloth!");
  else
	LootOptions.LootCloth = false;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Ignoring Cloth!");
  end
end
 
 if msg == 'lootshinies' then
  if LootOptions.LootShinies == false then
	LootOptions.LootShinies = true;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Looting Greens and above!");
  else
	LootOptions.LootShinies = false;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Ignoring Greens and above!");
  end
 end

if msg == 'alonstop' then
  if LootOptions.ALonStop == false then
	LootOptions.ALonStop = true;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Autoloot will be enabled on toggle off!");
  else
	LootOptions.ALonStop = false;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Autoloot will NOT be enabled on toggle off!");
  end
 end

 if msg == 'loottradegoods' then
  if LootOptions.TradeGoods == false then
	LootOptions.TradeGoods = true;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Looting Trade Goods!");
  else
	LootOptions.TradeGoods = false;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Ignoring Trade Goods!");
  end
 end

 if msg == 'lootnoms' then
  if LootOptions.Noms == false then
	LootOptions.Noms = true;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Looting Food Stuffs!");
  else
	LootOptions.Noms = false;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Ignoring Food Stuffs!!");
  end
 end

 
 if msg == 'lootjunk' then
  if LootOptions.LootJunk == false then
	LootOptions.LootJunk = true;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Looting Junk!");
  else
	LootOptions.LootJunk = false;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Ignoring Junk!");
  end
 end

 
 if msg == 'filterjunk' then
  if LootOptions.FilterJunk == false then
	LootOptions.FilterJunk = true;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Filtering Junk!");
  else
	LootOptions.FilterJunk = false;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r No Longer Filtering Junk!");
  end
 end

 if msg == 'debug' then
  if LootOptions.Debug == false then
	LootOptions.Debug = true;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Debug mode on!");
  else
	LootOptions.Debug = false;
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Debug mode off!");
  end
 end
 
 
 if msg == 'junkvalue' then
	DEFAULT_CHAT_FRAME:AddMessage(("|cffff0000 Got Loot?|r Junk value : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r"):format(LootOptions.MinJunkValue / 100 / 100, (LootOptions.MinJunkValue / 100) % 100, LootOptions.MinJunkValue % 100) );
 end

 local command, rest = msg:match("^(%S*)%s*(.-)$");
 if command == 'junkvalue' and rest ~= "" then
	LootOptions.MinJunkValue = rest;
	DEFAULT_CHAT_FRAME:AddMessage(("|cffff0000 Got Loot?|r Junk value set : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r"):format(rest / 100 / 100, (rest / 100) % 100, rest % 100) );
 end 
 
 if msg == 'options' then
 end

  if msg == '' then
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Usage:");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl options|r [Open options UI]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl toggle|r [Toggle on/off]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl enable|r [Turn on]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl disable|r [Turn off]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl lootcloth|r [Toggle looting cloth]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl lootjunk|r [Toggle looting gray/white items]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl junkvalue number|r [Set min value of junk in copper 10000=1G]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl filterjunk|r [Toggles filtering junk by minimum value]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl lootshinies|r [Toggles looting greens and above]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl loottradegoods|r [Toggles looting trade goods]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl lootnoms|r [Toggles looting food and drink]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl debug|r [Toggles debug mode]");
	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 /gl alonstop|r [Toggles autoloot enable/disable on stop]");
  end
 
 end
 


GotLootFrame:SetScript("OnEvent", function(self,event,arg1)

if event == "ADDON_LOADED" and arg1 == "GotLoot" then
--DEFAULT_CHAT_FRAME:AddMessage(LootOptions.MinJunkValue);
	if LootOptions.LootJunk == nil then 
		LootOptions.LootJunk = true;
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
	if LootOptions.Noms == nil then 
		LootOptions.Noms = false;
	end
	if LootOptions.TradeGoods == nil then 
		LootOptions.TradeGoods = true;
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

	DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Fired up!");
	local AutoLoot=GetCVar("AutoLootDefault"); 
	if(AutoLoot=="1") then 
		SetCVar("AutoLootDefault",0);
		LootOptions.ALonStop = true;
		DEFAULT_CHAT_FRAME:AddMessage("|cffff0000 Got Loot?|r Turning Autoloot Off");
	end

end

if event == "VARIABLES_LOADED" then
end

if event == "LOOT_OPENED" then

if LootOptions.Enabled == true then --Check GotLoot is enabled
local numItems = GetNumLootItems();
for CurrentLootItem=1, numItems, 1 do
	local looted=false;
	local loottype = GetLootSlotType(CurrentLootItem);
	
	--LOOT MONEY
	if loottype == 2 then
		LootSlot(CurrentLootItem);
	end 
	
	--LOOT ITEMS
	if loottype == 1 then
	local texture, item, quantity, currencyID, quality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(CurrentLootItem);
	local _, _, _, _, _, itemType, itemSubType, _, _, _, itemSellPrice = GetItemInfo(GetLootSlotLink(CurrentLootItem));
	--DEFAULT_CHAT_FRAME:AddMessage((item .. " : %dg %ds %dc"):format(itemSellPrice / 100 / 100, (itemSellPrice / 100) % 100, itemSellPrice % 100) );
	--local VendorValue = itemSellPrice * quantity
	--DEFAULT_CHAT_FRAME:AddMessage(item .. " : " .. VendorValue);
	if LootOptions.Debug == true then
		DEFAULT_CHAT_FRAME:AddMessage((item .. " (" .. itemType .. "|" .. itemSubType .. ") x" .. quantity .. " : %d|cffffd700G|r %d|cFFC0C0C0S|r %d|cFFFFA500C|r Per Item"):format(itemSellPrice / 100 / 100, (itemSellPrice / 100) % 100, itemSellPrice % 100));
	end

	--LOOT TRADE GOODS ITEMS
	if LootOptions.TradeGoods == true and itemType == "Tradeskill" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT NOMS ITEMS
	if LootOptions.Noms == true and itemType == "Consumable" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end
	
	--LOOT QUEST ITEMS
	if itemType == "Quest" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT RECIPE ITEMS
	if itemType == "Recipe" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT GEM ITEMS
	if itemType == "Gem" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT KEY ITEMS
	if itemType == "Key" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT ENCHANTING ITEMS
	if itemSubType == "Enchanting" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT CLOTH ITEMS
	if itemType == "Tradeskill" and itemSubType == "Cloth" and looted == false then
		if LootOptions.LootCloth == true then
				LootSlot(CurrentLootItem);
			looted=true;
		end
	end

	--LOOT SKINNING ITEMS
	if itemType == "Tradeskill" and itemSubType == "Leather" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT MINING ITEMS
	if itemSubType == "Metal & Stone" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT HERB ITEMS
	if itemSubType == "Herb" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT PET ITEMS
	if itemSubType == "Pet" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT MOUNT ITEMS
	if itemType == "Container" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	--LOOT BAG ITEMS
	if itemSubType == "Bag" and looted == false then
		LootSlot(CurrentLootItem);
		looted=true;
	end

	
	--LOOT GRAY/COMMON ITEMS
	if looted==false then
		if LootOptions.LootJunk == true then
			if LootOptions.FilterJunk == true then
				if itemSellPrice ~= nil then
					if tonumber(LootOptions.MinJunkValue) <= (tonumber(itemSellPrice) * tonumber(quantity)) then
						LootSlot(CurrentLootItem);
					end
				end
			else
				LootSlot(CurrentLootItem);
			end
			looted=true;
		end
	end
	--LOOT GREEN & ABOVE ITEMS
	if looted==false then
		if LootOptions.LootShinies == true then
            if quality ~= nil then
                if quality >= 2 then
                    LootSlot(CurrentLootItem);
                    looted=true;
                end
            end
		end
	end

	end
end
CloseLoot();
end
end
end)

