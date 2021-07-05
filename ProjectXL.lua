
--// Settings 
local set = {
    enabled = false,
    clip = true,
    distance = 6,
    tool = false,
    quest = "",
    angle = "Below",
    alwaysStand = true,
    instaKill = true,
    abs = {E=false,R=false,C=false,X=false,Y=false}
}

--// Imports
local imgui = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/shiinanguyen12/Project-XL-remake.lua/master/UI.lua?token=ANXX2DOGG3TYEYPBUSIV2PDA4JX4Q'))()

--// Declarations 
local quests = {strings={},values={}}
local bosses = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/shiinanguyen12/Project-XL-remake.lua/master/Bosses.lua?token=ANXX2DLXZXGDGTYHWNYQ6YLA4JX3G'))()
local toolCache = {}
local player = game.Players.LocalPlayer
local live = workspace.Live  
local localQuests = player.Quests
local questRemote = game.ReplicatedStorage.RemoteEvents.ChangeQuestRemote -- :FireSever(questValue) 
local combatRemote = game.ReplicatedStorage.RemoteEvents.BladeCombatRemote -- :FireSever(bool,vec3,cf)

--// Old Data 
local lvl = player.PlayerValues.Level.Value
local gold = player.PlayerValues.Gold.Value

--// Storing Quests 
for i,v in pairs(game.ReplicatedStorage.Quests:GetChildren()) do 
    if v.Name:match('%d') then 
        --// Strings 
        table.insert(quests.strings,v.Name)

        --// Remote Value
        quests.values[v.Name] = v
    end
end 


--// Primary Loop 
coroutine.wrap(function()
    while wait(nil) do 

        if set.enabled then 
            --// Quest 
            local q = set.quest
            local boss = not localQuests:FindFirstChild(q)
            local allow = (#q>0 and (not boss and localQuests[q].Value or boss and #q>0))

            if not allow and not boss then 
                questRemote:FireServer(quests.values[q])
                allow = true 
            end 


            if allow then 
                --// Equip
                if not player.Character:FindFirstChildWhichIsA('Tool') then 
                    (not set.tool and player.Backpack:FindFirstChildWhichIsA('Tool') or set.tool and player.Backpack[set.tool]).Parent = player.Character
                end 
                --// Farm 
                for i,v in pairs(live:GetChildren()) do
                    if q:find(v.Name) then
                        --// Checks
                        local root = v:FindFirstChild('HumanoidRootPart')
                        local hum = v:FindFirstChild('Humanoid')
                        local origin = player.Character:FindFirstChild('HumanoidRootPart')
         
                        while (root and hum and origin and not v:FindFirstChild('ForceField')) and (hum.Health>0) and (game.RunService.Stepped:wait()) and (not boss and localQuests[q].Value or boss) do 
                            origin.CFrame = root.CFrame * CFrame.new(0,(set.angle == 'Above' and set.distance or set.angle == 'Below' and -set.distance or 0),(set.angle == 'Behind' and set.distance or 0)) * (((set.angle == 'Above' or set.angle == 'Below') and not set.alwaysStand) and CFrame.Angles(math.rad(set.angle == 'Above' and -90 or set.angle == 'Below' and 90),0,0) or (CFrame.new()))
                            if set.instaKill then 
                                combatRemote:FireServer(true,nil,nil)

                                if hum.Health < hum.MaxHealth then 
                                    hum.Health = 0 
                                end 
                            else 
                                combatRemote:FireServer(true,nil,nil)
                            end 
                        end

                    end 
                end 
                
            end 
        end 
    end 
end)()

--// Render Loops 
game.RunService.Stepped:Connect(function()
    local hum = player.Character:FindFirstChild('Humanoid')
    if hum and set.clip and set.enabled then 
        hum:ChangeState(11)
    end 
    setsimulationradius(math.huge,math.huge) -- insta kill
end)

--// Anti afk 
for i,v in pairs(getconnections(player.Idled)) do 
    v:Disable()
end

--// UI
local win = imgui.AddWindow(nil,'Project-XL-remake - Shiina Nguyen#0001',{main_color = Color3.fromRGB(255,69,0),min_size = Vector2.new(350,450),toggle_key = Enum.KeyCode.RightShift,can_resize = true})

--// Tabs
local primaryTab = win.AddTab(nil,'Farm') --[[]]

--//Folders
local setFolder = primaryTab.AddFolder(nil,'Settings')
local farmSetFolder = setFolder.AddFolder(nil,'Farm')
local abSetFolder = setFolder.AddFolder(nil,'Abilites')

--// Other Shit
farmSetFolder.AddSwitch(nil,'Insta-Kill',true,function(bool) set.instaKill = bool end)
farmSetFolder.AddSwitch(nil,'Clip',true,function(bool) set.clip = bool end)
farmSetFolder.AddSwitch(nil,'Always Stand',true,function(bool) set.alwaysStand = bool end)
local angleDropdown = farmSetFolder.AddDropdown(nil,'Angle',function(val) set.angle = val end)
for i,v in pairs({'Behind','Below','Above'}) do 
    angleDropdown:Add(v)
end 
local questDropdown = farmSetFolder.AddDropdown(nil,'Quest',function(val) set.quest = val end)
for _,v in pairs(quests.strings) do 
    questDropdown:Add(v)
end 
for _,v in pairs(bosses) do 
    questDropdown:Add(v)
end 
farmSetFolder.AddSlider(nil,'Distance',function(val) set.distance = val end,{min=0,max=10,def=set.distance,readonly=false})
primaryTab.AddSwitch(nil,'Start',false,function(bool) set.enabled = bool end)

local toolDropdown = abSetFolder.AddDropdown(nil,'Select Ability',function(val) set.tool = val end)
for i,item in pairs(player.Backpack:GetChildren()) do 
    if item:IsA('Tool') then 
        toolCache[item.Name] = toolDropdown:Add(item.Name)
    end 
end
player.Backpack.ChildAdded:Connect(function(item)
    if not toolCache[item.Name] then 
        toolCache[item.Name] = toolDropdown:Add(item.Name)
    end 
end)
for i,v in pairs({'E','R','C','X','Y'}) do 
    abSetFolder.AddSwitch(nil,'Use: '..v,false,function(bool) set.abs[v] = bool end)
    coroutine.wrap(function()
        while wait(nil) do 
            if set.abs[v] and set.enabled then 
                game:GetService('VirtualInputManager'):SendKeyEvent(true,v,false,uwu)
            end 
        end 
    end)()
end 

local expEarned = primaryTab.AddLabel(nil,'Levels Gained: 0')
local goldEarned = primaryTab.AddLabel(nil,'Gold Earned: 0')
coroutine.wrap(function()
    while wait(nil) do 
        goldEarned.Text = ('Gold Earned: %d'):format(player.PlayerValues.Gold.Value - gold)
        expEarned.Text = ('Levels Gained: %d'):format(player.PlayerValues.Level.Value - lvl)
    end 
end)()

--// Credits Tab 
local creditTab = win.AddTab(nil,'Credits')
creditTab.AddLabel(nil,'Scripter: {}#1000')
creditTab.AddLabel(nil,'Insta-Kill Method: Invell')
creditTab.AddLabel(nil,'UI: 0xSingularity')


--// imgui-Finalize 
imgui.FormatWindows()
primaryTab.Show()


