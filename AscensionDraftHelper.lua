
local addonName = 'ascensiondrafthelper';
SPELL_LIST = {};
AscensionDraftHelper = {
    macroName = 'AscensionDraftHelper - Macro',
    spellList = { 965202, 1130, 1978, 13165 },
    windowHidden = false
};

local ROUND = 1;
local foundSpells = {};
NUMBER_OF_MATCHES = 3;

function AscensionDraftHelper:log(msg)
    ChatFrame1:AddMessage("|cFFFFC107[DraftMan]: |r" .. msg)
end

function AscensionDraftHelper:CreateMacro()
    AscensionDraftHelper:DeleteMacro()
    DRAFT_MAN_MACRO_ID = CreateMacro(AscensionDraftHelper.macroName, 10, "#show\n/script AscensionDraftHelper:StartRoll()", nil)
    AscensionDraftHelper:log("Macro created! Please put it on action bar 1.")
    PickupMacro(AscensionDraftHelper.macroName)
end

function AscensionDraftHelper:DeleteMacro()
    DeleteMacro(AscensionDraftHelper.macroName);
end

-- Gets spell card info
local function getCardSpellInfo(index)
    local spells = {
        [1] = Card1.sID,
        [2] = Card2.sID,
        [3] = Card3.sID
    }
    local name = GetSpellInfo(spells[index])
	return spells[index], name
end

-- Learn spell card at position
local function learnSpellCardAt(index)
    _G["Card" .. tostring(index)].button:Click()
end

local round = 1;
local enabled = false;

function AscensionDraftHelper:Roll()
    CardExtraBar.button1:Click();
    -- ActionButton1:Click();
end

function AscensionDraftHelper:StartAutoRoll()
    enabled = not enabled;

    if enabled then
        AscensionDraftHelperFrame_AutoRollButton:SetText('Stop Auto roll');
        foundSpells = {};
        AscensionDraftHelper:AutoRoll();
    else
        AscensionDraftHelperFrame_AutoRollButton:SetText('Start Auto roll')
    end
end

function AscensionDraftHelper:AutoRoll()
    if enabled then
        AscensionDraftHelper:Wait(1.2, function ()
            AscensionDraftHelper:SelectOrRoll();
            AscensionDraftHelper:AutoRoll()
        end)
    end
end

function AscensionDraftHelper:StartRoll()
    foundSpells = {};
    AscensionDraftHelper:SelectOrRoll();
end

function AscensionDraftHelper:SelectOrRoll()
    if not (table.getn(foundSpells) == table.getn(SPELL_LIST) or table.getn(foundSpells) == NUMBER_OF_MATCHES) then
        print('>>> Round ' .. round);
        local found = AscensionDraftHelper:SelectCard();
        
        if not found then
            print('not found')
            AscensionDraftHelper:Roll();
            foundSpells = {};
            round = 1;
        else
            print('found')
            found = false;
            round = round + 1;
        end
    else
        print('All spells found')
    end
    
end



function AscensionDraftHelper:SelectCard()
    local found = false;
    for i = 1, 3 do
        local id, name = getCardSpellInfo(i)
        print(id .. " | " ..name)
        
        for j = 1, 4 do
            if SPELL_LIST[j] == id then
                print('learning')
                learnSpellCardAt(i)
                print('Learned' .. ' | ' .. name)
                foundSpells[round] = name;
                found = true;
                break
            end
        end
    end

    return found;
    -- AscensionDraftHelper:Wait(1.2, function ()
        -- if not found then
        --     print('not found')
        --     CardExtraBar.button1:Click();
        --     foundSpells = {}
        --     round = 1;
        -- else
        --     print('found')
        --     found = false;
        --     round = round + 1;
        -- end
        -- AscensionDraftHelper:SelectCardOrRoll();
    -- end)
end

function AscensionDraftHelper:OnLoad()
    this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    AscensionDraftHelper:log("Loaded v1")
end

function AscensionDraftHelper:OnEvent(event)
    if event == "VARIABLES_LOADED" then
        AscensionDraftHelper:OnInit()
    end
end

function AscensionDraftHelper:OnInit()
    -- Reroll bar state
    AscensionDraftHelperFrame_UnlockFrames:Hide();
    AscensionDraftHelper:SetFrameVisibility(AscensionDraftHelper.windowHidden);
    _G["AscensionDraftHelperFrame_Input1"]:SetText(table.concat(SPELL_LIST,", "));
    _G["AscensionDraftHelperFrame_NumberOfSpells"]:SetText(NUMBER_OF_MATCHES);
    AscensionDraftHelper:SetFrameVisibility(true)
end

function AscensionDraftHelper:SetFrameVisibility(status)
    if status then 
        AscensionDraftHelperFrame:Show();
        -- AscensionDraftHelperFrame_RerollBar:Show();
    else 
        AscensionDraftHelperFrame:Hide();
        -- AscensionDraftHelperFrame_RerollBar:Hide();
    end
    AscensionDraftHelper.windowHidden = not status
end

function AscensionDraftHelper:OnInputEdit(input, editbox)
    local text = editbox:GetText();
    SPELL_LIST = AscensionDraftHelper:ParseSpells(text);
end

function AscensionDraftHelper:OnNumberOfSpellsEdit(editbox)
    local text = editbox:GetText();
    NUMBER_OF_MATCHES = tonumber(text);
end

function AscensionDraftHelper:ParseSpells(input)
    local spells = {}
    for spell in string.gmatch(input, '([^,]+)') do
        -- Trim string
        spell = spell:gsub("^%s*(.-)%s*$", "%1")
        -- Remove non numerics
        spell = spell:gsub("[^0-9]", "")
        -- To number
        spell = tonumber(spell)
        table.insert(spells, spell)
    end
    return spells
end

local waitTable = {};
local waitFrame = nil;

function AscensionDraftHelper:Wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

--===[ Slash command ]===--- 

function AscensionDraftHelper_HandleSlashCommand(msg)
    if msg == "show" then
        AscensionDraftHelper:SetFrameVisibility(true)
    elseif msg == "hide" then
        AscensionDraftHelper:SetFrameVisibility(false)
    end
end
SlashCmdList["ASCENSIONDRAFTHELPER"] = AscensionDraftHelper_HandleSlashCommand;
SLASH_ASCENSIONDRAFTHELPER1 = "/" .. addonName
SLASH_ASCENSIONDRAFTHELPER2 = "/adh"