----- Object Definitions -----
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local repS = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local DataStoreService = game:GetService("DataStoreService")
local ss = game:GetService("ServerStorage")
local sss = game:GetService("ServerScriptService")
local mSplat = repS.RepItems.MudSplatter
local productFunctions = {}
local playerList = {}

----- Data Storage -----
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")
local DataStore2 = require(sss.DataStore2)
DataStore2.Combine("ShovelChampions2079","Level","Experience","TimePlayed","CurrentShovel","Gold","Gold_1","MatsCollected","Zone","PetsOwned","DailyRewards","CoinMultiple","ExpMultiple","Gems","HatsOwned","ShovelsOwned","RedeemedCodes")
_G.dataUpdMod = require(sss.DataControl.DataUpdate)

----- Special Shovels -----
local skinShovels = {
	"Santa's Shovel"
}

----- Collision -----
local defaultGroup = PhysicsService:GetCollisionGroupName(0)
local playerGrp = "PlayerGroup"
local doorList = {
	door1 = "Door1",
	door2 = "Door2",
	door3 = "Door3",
	door4 = "Door4",
	door5 = "Door5"
}

----- Other Stats -----
local zoneLevel = {
	["Newbie"] = 0,
	["Farm"] = 1,
	["Waterfall"] = 2,
	["Castle"] = 3,
	["Iceland"] = 4,
	["Crystalline"] = 5
}
local ranks = {
	[-3] = "Angelic Retribution",
	[-2] = "Demonic Hellfire",
	[-1] = "Voidless Bermuda",
	[0.5] = "Wood",
	[1] = "Bronze",
	[2] = "Steel",
	[3] = "Gold"
}
local zoneRanks = {
	[1] = "Weak",
	[2] = "Solid",
	[3] = "Durable",
	[4] = "Powerful",
	[5] = "Icelandic",
	[6] = "Crystalline",
}

local adminList = {
	["Voidless Bermuda"] = 1356425454,
	["Angelic Retribution"] = 327209774, -- 327209774
	["Demonic Hellfire"] = 1467362277, -- 1467362277  110027475
	["Holy Death"] = 22689352
}
local petEggInfo = {
	["Egg0"] = {
		{"Lion",0.70,0.86}, -- Boost: 9, Dmg: 43, Cost: 1837 ---------------- 16% chance
		{"Rabbit",0.50,0.70}, -- Boost: 7, Dmg: 36, Cost: 1276 ---------------- 20% chance
		{"Cat",0.28,0.50}, -- Boost: 6, Dmg: 29, Cost: 816 ---------------- 22% chance
		{"Deer",0,0.28}, -- Boost: 4, Dmg: 21, Cost: 459 ---------------- 28% chance
		{"Happy",0.86,1}}, -- Boost: 10, Dmg: 50, Cost: 2500 ---------------- 14% chance
	["Egg1"] = {
		{"Chicken",0.74,0.88}, -- Boost: 34, Dmg: 171, Cost: 29388 ---------------- 14% chance
		{"Cow",0.56,0.74}, -- Boost: 29, Dmg: 143, Cost: 20408 ---------------- 18% chance
		{"Horse",0.30,0.56}, -- Boost: 23, Dmg: 114, Cost: 13061 ---------------- 26% chance
		{"Pig",0,0.30}, -- Boost: 17, Dmg: 86, Cost: 7347 ---------------- 30% chance
		{"Farmer",0.88,1}}, -- Boost: 40, Dmg: 200, Cost: 40000 ---------------- 12% chance
	["Egg2"] = {	
		{"Green Slime",0.78,0.90}, -- Boost: 99, Dmg: 493, Cost: 242908 ---------------- 12% chance
		{"Orange",0.62,0.78}, -- Boost: 82, Dmg: 411, Cost: 168686 ---------------- 16% chance
		{"Wolf",0.38,0.62}, -- Boost: 66, Dmg: 329, Cost: 107959 ---------------- 24% chance
		{"Blue Slime",0,0.38}, -- Boost: 49, Dmg: 246, Cost: 60727 ---------------- 38% chance
		{"Frog",0.90,1}}, -- Boost: 115, Dmg: 575, Cost: 330625 ---------------- 10% chance
	["Egg3"] = {
		{"Boxer",0.82,0.92}, -- Boost: 231, Dmg: 1157, Cost: 1338980 ---------------- 10% chance
		{"Assassin",0.68,0.82}, -- Boost: 193, Dmg: 964, Cost: 929847 ---------------- 14% chance
		{"Archer",0.40,0.68}, -- Boost: 154, Dmg: 771, Cost: 595102 ---------------- 28% chance
		{"Wizard",0,0.40}, -- Boost: 116, Dmg: 579, Cost: 334745 ---------------- 40% chance
		{"Goblin Slayer",0.92,1}}, -- Boost: 270, Dmg: 1350, Cost: 1822500 ---------------- 8% chance
	["Egg4"] = {
		{"Goblin",0.86,0.94}, -- Boost: 943, Dmg: 4714, Cost: 22224490 ---------------- 8% chance
		{"Penguin",0.74,0.86}, -- Boost: 786, Dmg: 3929, Cost: 15433673 ---------------- 12% chance
		{"Fox",0.50,0.74}, -- Boost: 629, Dmg: 3143, Cost: 9877551 ---------------- 24% chance
		{"Ghost",0,0.50}, -- Boost: 471, Dmg: 2357, Cost: 5556122 ---------------- 50% chance
		{"Polar Bear",0.94,1}}, -- Boost: 1100, Dmg: 5500, Cost: 30250000 ---------------- 6% chance
	["Egg5"] = {
		{"Crystal",0.93,0.99}, -- Boost: 5143, Dmg: 25714, Cost: 661224490 ---------------- 6% chance
		{"Crystal Dominus",0.83,0.93}, -- Boost: 4286, Dmg: 21429, Cost: 459183673 ---------------- 10% chance
		{"Miner",0.63,0.83}, -- Boost: 3429, Dmg: 17143, Cost: 293877551 ---------------- 20% chance
		{"Crystal Golem",0,0.63}, -- Boost: 2571, Dmg: 12857, Cost: 165306122 ---------------- 60% chance
		{"Dragon",0.99,1} -- Boost: 6000, Dmg: 30000, Cost: 900000000 ---------------- 1% chance
	}
}

-- damage, cost
-- cost of golden shovel = 0.6x next zone door cost
local shovelStats = {
	["Weak Bronze Shovel"] = {6,125},
	["Weak Steel Shovel"] = {8,250},
	["Weak Gold Shovel"] = {12,500}, 
	["Solid Bronze Shovel"] = {16,900}, 
	["Solid Steel Shovel"] = {22,1750}, 
	["Solid Gold Shovel"] = {30,3500}, 
	["Durable Bronze Shovel"] = {40,5000}, 
	["Durable Steel Shovel"] = {50,7000}, 
	["Durable Gold Shovel"] = {60,9000}, 
	["Powerful Bronze Shovel"] = {70,10000}, 
	["Powerful Steel Shovel"] = {85,12500}, 
	["Powerful Gold Shovel"] = {100,15000},
	["Icelandic Bronze Shovel"] = {115,25000},
	["Icelandic Steel Shovel"] = {135,30000}, 
	["Icelandic Gold Shovel"] = {175,35000}, 
	["Crystalline Bronze Shovel"] = {190,65000}, 
	["Crystalline Steel Shovel"] = {230,95000}, 
	["Crystalline Gold Shovel"] = {275,150000} -- damage, cost
}

for _,v in pairs(game.ReplicatedStorage.GameStats.ShovelStats:GetChildren()) do
	if shovelStats[v.Name] ~= nil then
		v.Damage.Value = shovelStats[v.Name][1]
		v.Cost.Value = shovelStats[v.Name][2]
	end
end

-- Create two collision groups
PhysicsService:CreateCollisionGroup(playerGrp)

----- Remotes -----
local plrStats = repS.Remotes.Get_Stats
local updClient = repS.Remotes.Update_Client
local buySell = repS.Remotes.Buy_Sell
local devProducts = repS.Remotes.Dev_Products
local eggHatch = repS.Remotes.Egg_Hatch
local twitterRem = repS.Remotes.Twitter_Code

eggHatch.OnServerInvoke = function(player,num,shopName)
	if petEggInfo[shopName] then
		local randomPets = {}
		for i = 1,num do
			local chance = math.random()
			for _,v in pairs(petEggInfo[shopName]) do
				if chance >= v[2] and chance < v[3] then
					table.insert(randomPets,v[1])
					local dict = _G.dataUpdMod.manipulateData(player,"Get","PetsOwned")
					if dict[v[1]] == nil then
						dict[v[1]] = {{1,1,0},{2,0,0},{3,0,0},{4,0,0},{5,0,0}}
					else
						dict[v[1]][1][2] = dict[v[1]][1][2]+1
					end
					_G.dataUpdMod.manipulateData(player,"Set","PetsOwned",dict)
					break
				end
			end
		end
		return randomPets
	end
	return nil
end

function giveShovel(player)
	local char = player.Character
	if char:FindFirstChild("Shovel") then
		char.UpperTorso:FindFirstChild("ShovelWeld"):Destroy()
		char:FindFirstChild("Shovel"):Destroy()
	end
	local wc = Instance.new("WeldConstraint")
	local cl = ss.Shovels:FindFirstChild(_G.dataUpdMod.manipulateData(player,"Get","CurrentShovel"),true):Clone()
	repeat
		wait()
	until char:FindFirstChild("UpperTorso") ~= nil
	if cl.PrimaryPart.Name == "Handle2" then
		cl:SetPrimaryPartCFrame(char.UpperTorso.CFrame*CFrame.new(0.4,0.4,0.75)*CFrame.Angles(0,math.rad(180),math.rad(45)))
	else
		print(cl.Name)
		cl:SetPrimaryPartCFrame(char.UpperTorso.CFrame*CFrame.new(0.7,0.7,0.65)*CFrame.Angles(0,math.rad(180),math.rad(45)))
	end
	wc.Parent = char.UpperTorso
	wc.Part0 = char.UpperTorso
	wc.Part1 = cl.PrimaryPart
	cl.Name = "Shovel"
	wc.Name = "ShovelWeld"
	cl.Parent = char
	for _,v in pairs(cl:GetChildren()) do
		v.Anchored = false
	end
end

local function CharacterAdded(char)
	--Character added:
	local player = game.Players:GetPlayerFromCharacter(char)
	
	----- Attaching Shovel -----
	spawn(function()
		giveShovel(player)
		wait(3)
		while not char:FindFirstChild("Shovel") do
			updClient:FireClient(player,"Shovel","S_Loading...")
			giveShovel(player)
			wait(3)
			if char:FindFirstChild("Shovel") then
				break	
			end
		end
		updClient:FireClient(player,"Shovel","Loaded Successfully")
	end)
	
	player.CharacterAppearanceLoaded:Connect(function(char)
		----- Creating Collision Groups -----
		for _,v in pairs(char:GetDescendants()) do
			if (v:IsA("BasePart")) then
				PhysicsService:SetPartCollisionGroup(v, playerGrp)
			end
		end
		PhysicsService:CollisionGroupSetCollidable(playerGrp, playerGrp, false)
		whitelistDoors(player)
	end)
	
	local tagUI = repS.RepItems.TagGui:Clone()
	tagUI.Parent = char:WaitForChild("Head")
	local hum = char:WaitForChild("Humanoid")
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	if player.UserId ~= 1356425454 and player.UserId ~= 327209774 and player.UserId ~= 1467362277 then
		tagUI.NameTag.Text = player.Name .. "\n" .. _G.dataUpdMod.manipulateData(player,"Get","Zone")
	else
		tagUI.NameTag.TextColor3 = Color3.fromRGB(134, 111, 204)
		tagUI.NameTag.Text = player.Name .. "\nDEVELOPER"
	end
	
	hum.Died:Connect(function()
		player:Kick("You have been kicked.")
	end)
	
	local splatClone = mSplat:Clone()
	splatClone.Parent = char:WaitForChild("LeftHand")
	playerList[player] = player.Name
	
	spawn(function()
		wait(1)
		updatePlrData(player)
		while true do
			for i = 1,5 do
				wait(30)
				updClient:FireClient(player,"TimePassed")
				_G.dataUpdMod.manipulateData(player,"Increment","TimePlayed",30)
			end
			updatePlrData(player)
		end
	end)
end


function updatePlrData(player)
	if Players:FindFirstChild(player.Name) == nil then
		return
	end
	if player.UserId ~= 1356425454 and player.UserId ~= 327209774 and player.UserId ~= 1467362277 then
		print("Updating Player Data for ..." .. player.Name)
		_G.dataUpdMod.updGlobalData(player,"UpdateData")
	end
	local timeTable = _G.dataUpdMod.manipulateData(player,"Get","DailyRewards")
	_G.dataUpdMod.manipulateData(player,"Set","DailyRewards",{os.time(),timeTable[2],timeTable[3]})
end

spawn(function()	
	while true do
		spawn(function()
			updateGlobalLB("UpdateStats")
		end)
		wait(150)
	end
end)

function updateGlobalLB(lbType)
	local frames = {}
	for _,v in pairs(game.Workspace.Leaderboards:GetChildren()) do
		table.insert(frames,v)
	end

	local pageSize = 18
	local pages
	local Table_Of_Pages = {}
	
	if lbType == "UpdateStats" then
		print("Getting Sorted Async")
		pages = _G.statsInGame:GetSortedAsync(false,pageSize)
	end
	if pages ~= nil then
		local function iterPageItems(pages)
			return coroutine.wrap(function()
				local pagenum = 1
				while true do
					for rank, item in ipairs(pages:GetCurrentPage()) do
						coroutine.yield(item, pagenum)
					end
					if pages.IsFinished then
						break
					end
					pages:AdvanceToNextPageAsync()
					pagenum = pagenum + 1
				end
			end)
		end
		
		for _,v in pairs(frames) do
			local frame = v.PrimaryPart.SurfaceGui.Players
			for _,x in pairs(frame:GetChildren()) do
				if x:IsA("TextLabel") then
					x.Text = ""
				end
			end
		end
		local gemNo = 1
		local goldNo = 1
		local levelNo = 1
		local debrisDict = {}
		for item, pageNo in iterPageItems(pages) do
			if string.find(item.key,"_Level") and levelNo < 7 then
				local cfr = game.Workspace.Leaderboards.GameLevel.PrimaryPart.SurfaceGui.Players
				local newstr, rep = string.gsub(string.sub(item.key,14), "_Level", "")
				if tonumber(newstr) <= 0 then
					cfr:FindFirstChild(levelNo).Text = "Character" .. tonumber(newstr) .. " : " .. numAbb(item.value)
				else
					cfr:FindFirstChild(levelNo).Text = Players:GetNameFromUserIdAsync(tonumber(newstr)) .. " : " .. numAbb(item.value)
				end
				levelNo +=1
			elseif string.find(item.key,"_Gold") and goldNo < 7 then
				local cfr = game.Workspace.Leaderboards.GameRichest.PrimaryPart.SurfaceGui.Players
				local newstr, rep = string.gsub(string.sub(item.key,14), "_Gold", "")
				if tonumber(newstr) <= 0 then
					cfr:FindFirstChild(goldNo).Text = "Character" .. tonumber(newstr) .. " : " .. numAbb(item.value)
				else
					cfr:FindFirstChild(goldNo).Text = Players:GetNameFromUserIdAsync(tonumber(newstr)) .. " : " .. numAbb(item.value)
				end
				goldNo +=1
			elseif string.find(item.key,"_Gems") and gemNo < 7 then
				local cfr = game.Workspace.Leaderboards.GameGems.PrimaryPart.SurfaceGui.Players
				local newstr, rep = string.gsub(string.sub(item.key,14), "_Gems", "")
				if tonumber(newstr) <= 0 then
					cfr:FindFirstChild(gemNo).Text = "Character" .. tonumber(newstr) .. " : " .. numAbb(item.value)
				else
					cfr:FindFirstChild(gemNo).Text = Players:GetNameFromUserIdAsync(tonumber(newstr)) .. " : " .. numAbb(item.value)
				end
				gemNo +=1
			else
				table.insert(debrisDict,item.key)
			end
		end
		spawn(function()
			for _,v in pairs(debrisDict) do
				print(v)
				_G.statsInGame:RemoveAsync(v)
			end
			if #debrisDict ~= 0 then
				debrisDict = {}
				print("Updating Leaderboard Again -------------------------------")
				wait(60)
				updateGlobalLB("UpdateStats")
			end
		end)
	end
end

local function PlayerAdded(player)
	local ls = Instance.new("Model")
	ls.Name = "leaderstats"
	ls.Parent = player

	local m = Instance.new("StringValue")
	m.Name = "Gold"
	m.Value = "0"
	m.Parent = ls
	
	local d = Instance.new("StringValue")
	d.Name = "Gems"
	d.Value = "0"
	d.Parent = ls
	
	local l = Instance.new("StringValue")
	l.Name = "Level"
	l.Value = "1"
	l.Parent = ls
	
	_G.dataUpdMod.manipulateData(player,nil,"PetsOwned")
	_G.dataUpdMod.manipulateData(player,nil,"Level")
	_G.dataUpdMod.manipulateData(player,nil,"Experience")
	_G.dataUpdMod.manipulateData(player,nil,"TimePlayed")
	_G.dataUpdMod.manipulateData(player,nil,"CurrentShovel")
	_G.dataUpdMod.manipulateData(player,nil,"Gold")
	_G.dataUpdMod.manipulateData(player,nil,"Gold_1")
	_G.dataUpdMod.manipulateData(player,nil,"MatsCollected")
	_G.dataUpdMod.manipulateData(player,nil,"Zone")
	_G.dataUpdMod.manipulateData(player,nil,"DailyRewards")
	_G.dataUpdMod.manipulateData(player,nil,"CoinMultiple")
	_G.dataUpdMod.manipulateData(player,nil,"ExpMultiple")
	_G.dataUpdMod.manipulateData(player,nil,"Gems")
	_G.dataUpdMod.manipulateData(player,nil,"HatsOwned")
	_G.dataUpdMod.manipulateData(player,nil,"ShovelsOwned")
	_G.dataUpdMod.manipulateData(player,nil,"RedeemedCodes")
	
	local function adminsStats(shovel)
		local adminDict = {}
		adminDict["Dragon"] = {{1,0,0},{2,0,0},{3,0,0},{4,3,0},{5,3,0}}
		
		--adminDict["Snowman"] = {{1,1,0},{2,0,0},{3,0,0},{4,0,0},{5,0,0}}
		--adminDict["Snow White"] = {{1,1,0},{2,0,0},{3,0,0},{4,0,0},{5,0,0}}
		--adminDict["Winter Bear"] = {{1,1,0},{2,0,0},{3,0,0},{4,0,0},{5,0,0}}
		--adminDict["Mini Santa"] = {{1,1,0},{2,0,0},{3,0,0},{4,0,0},{5,0,0}}
		--adminDict["Santa's Helper"] = {{1,1,0},{2,0,0},{3,0,0},{4,0,0},{5,0,0}}
		local hatList = {
			["Cool Hair"] = false,
			["Pretty Hair"] = false,
			["Playful Sunglasses"] = false,
			["Black Iron Commando"] = false,
			["Sinister Branches"] = false,
			["Emperor of the Night"] = false,
			["Ice Valkyrie"] = false,
			["Workclock Headphones"] = false,
			["Workclock Shades"] = false,
			["Silverthorn Antlers"] = false,
			["Classic Fedora"] = false,
			["Disgraced Baroness"] = false
		}
		local shovelList = {
			"Weak Wood Shovel",
			"Crystalline Gold Shovel"
			--"Santa's Shovel"
		}
		_G.dataUpdMod.manipulateData(player,"Set","PetsOwned",adminDict)
		--_G.dataUpdMod.manipulateData(player,"Set","Zone","Crystalline")
		_G.dataUpdMod.manipulateData(player,"Set","Gold_1",5)
		_G.dataUpdMod.manipulateData(player,"Set","Experience",0)
		_G.dataUpdMod.manipulateData(player,"Set","CurrentShovel",shovel)
		_G.dataUpdMod.manipulateData(player,"Set","HatsOwned",hatList)
		_G.dataUpdMod.manipulateData(player,"Set","ShovelsOwned",shovelList)
	end
	
	for i,v in pairs(adminList) do
		if player.UserId == v then
			adminsStats(i)
		end
	end
	if player.UserId == 261311657 then  -- 261311657  1467362277
		adminsStats("Holy Death")
	end
	
	player.CharacterAdded:Connect(CharacterAdded)
	local char = player.Character
	if char then
		CharacterAdded(char)
	end
end
game.Players.PlayerAdded:Connect(PlayerAdded)
for i,v in next,game.Players:GetPlayers() do
	PlayerAdded(v)
end

game.Workspace.OtherUtilities.EdgeTeleporter.TeleporterPad.Touched:Connect(function(limb)
	if limb.Parent ~= nil and limb.Parent:FindFirstChild("HumanoidRootPart") then
		limb.Parent:FindFirstChild("HumanoidRootPart").CFrame = game.Workspace.OtherUtilities.EdgeTeleporter.TargetPad.CFrame *CFrame.new(0,4,0)
	end
end)

updClient.OnServerEvent:Connect(function(player,cmd,amount,valId)
	if cmd == "UpdateShovel" then
		_G.dataUpdMod.updateShovel(player)
	elseif cmd == "CheckHatsRemoved" then
		updClient:FireClient(player,"CheckHatsRemoved")
	elseif cmd == "Reset" then
		_G.dataUpdMod.manipulateData(player,"Set","Gold",0)
		if _G.dataUpdMod.manipulateData(player,"Get","Gems") > 2500 then
			_G.dataUpdMod.manipulateData(player,"Set","Gems",2500)
		end
	elseif cmd == "Warn" then
		updClient:FireClient(player,cmd,amount)
	elseif cmd == "Gold_1" and ss.InHandEvents:FindFirstChild(player.UserId .. "_GOLD") then
		ss.InHandEvents:FindFirstChild(player.UserId .. "_GOLD"):Destroy()
		_G.dataUpdMod.manipulateData(player,"Increment","Gold_1",amount)
	elseif cmd == "Gems" and ss.InHandEvents:FindFirstChild(player.UserId .. "_GEMS") then
		ss.InHandEvents:FindFirstChild(player.UserId .. "_GEMS"):Destroy()
		_G.dataUpdMod.manipulateData(player,"Increment","Gems",amount)
	elseif cmd == "Door" then
		for _,v in pairs(game.Workspace.Doors:GetChildren()) do
			if getZoneLevel(player,"Zone") >= tonumber(string.sub(v.Name,5)) then
				updClient:FireClient(player,"Door",v)
			end
		end
	elseif cmd == "RewardGold_1" and ss.CollectRewards:FindFirstChild(valId) then
		ss.CollectRewards:FindFirstChild(valId):Destroy()
		wait(math.random()/5)
		_G.dataUpdMod.manipulateData(player,"Increment","Gold_1",amount)
	elseif cmd == "RewardGems" and ss.CollectRewards:FindFirstChild(valId) then
		ss.CollectRewards:FindFirstChild(valId):Destroy()
		wait(math.random()/5)
		_G.dataUpdMod.manipulateData(player,"Increment","Gems",amount)
	end
end)

function strongestShovelOwned(shovelList)
	local highestDmg = 4
	for _,s in pairs(shovelList) do
		if shovelStats[s] ~= nil then
			if highestDmg < shovelStats[s][1] then
				highestDmg = shovelStats[s][1]
			end
		end
	end
	return highestDmg
end

plrStats.OnServerInvoke = function(player,checkType,stat,reqmt)
	if checkType == "requirement" then
		if stat == "Level" and _G.dataUpdMod.manipulateData(player,"Get","Level") >= reqmt then
			return true
		elseif stat == "Zone" and zoneLevel[_G.dataUpdMod.manipulateData(player,"Get","Zone")] >= reqmt then
			return true
		end
	elseif checkType == "GamepassCheck" then
		if ss.GamepassValidation:FindFirstChild(stat) then
			ss.GamepassValidation:FindFirstChild(stat):Destroy()
			return true
		else
			return false
		end
	elseif checkType == "checkStat" then
		local returnStat = _G.dataUpdMod.manipulateData(player,"Get",stat)
		if returnStat == nil then
			local setStat = _G.dataUpdMod.manipulateData(player,nil,stat)
			return setStat
		else
			return returnStat
		end
	elseif checkType == "checkZoneLvl" and _G.dataUpdMod.manipulateData(player,"Get","Zone") ~= nil then
		return zoneLevel[_G.dataUpdMod.manipulateData(player,"Get","Zone")]
	elseif checkType == "getDamage" then
		local currentShov = _G.dataUpdMod.manipulateData(player,"Get","CurrentShovel")
		local allShovs = _G.dataUpdMod.manipulateData(player,"Get","ShovelsOwned")
		for _,v in pairs(skinShovels) do
			if currentShov == v then
				local base = strongestShovelOwned(allShovs)
				return base
			end
		end
		local Base = repS.GameStats:FindFirstChild(currentShov,true).Damage.Value
		return Base
	elseif checkType == "normalDailyReward" then
		local timeTable = _G.dataUpdMod.manipulateData(player,"Get","DailyRewards")
		if timeTable[1] >= timeTable[2] then
			_G.dataUpdMod.manipulateData(player,"Set","DailyRewards",{os.time(),os.time()+86400,timeTable[3]})
			return true
		else
			return false
		end
	elseif checkType == "groupDailyReward" then
		local timeTable = _G.dataUpdMod.manipulateData(player,"Get","DailyRewards")
		if timeTable[1] >= timeTable[3] then
			_G.dataUpdMod.manipulateData(player,"Set","DailyRewards",{os.time(),timeTable[2],os.time()+86400})
			return true
		else
			return false
		end
	elseif checkType == "eggShop" then
		if petEggInfo[stat] then
			return petEggInfo[stat]
		end
		return nil
	end
end

twitterRem.OnServerInvoke = function(player,enteredCode)
	if string.lower(enteredCode) == "release" then	
		local attempt = redeemCode(player,string.lower(enteredCode))
		if attempt == true then
			_G.dataUpdMod.manipulateData(player,"Increment","Gold_1",300)
			_G.dataUpdMod.manipulateData(player,"Increment","Gems",80)
			return {"redeemed",80,300}
		end
		return {"already redeemed",0,0}
	else
		print("'" .. enteredCode .. "' is an incorrect code")
	end
	return {"incorrect",0,0}
end

function redeemCode(player,code)
	local preRedeemed = _G.dataUpdMod.manipulateData(player,"Get","RedeemedCodes")
	if preRedeemed[code] == nil then
		preRedeemed[code] = true
		_G.dataUpdMod.manipulateData(player,"Set","RedeemedCodes",preRedeemed)
		print("Code successfully redeemed!")
		return true
	else
		print("Code redeemed already")
		return false
	end
end

--[[
function checkShovelRank(currentShovel, newShovel)
	if ss.Shovels:FindFirstChild(currentShovel,true) and ss.Shovels:FindFirstChild(newShovel,true) then
		local currentShovelRank = 0
		local newShovelRank = 0
		local newZoneRank = 0
		local currentZoneRank = 0
		for i,v in pairs(ranks) do
			if string.find(currentShovel,v) ~= nil then
				currentShovelRank = i
			end
			if string.find(newShovel,v) ~= nil then
				newShovelRank = i
			end
		end
		
		for i,v in pairs(zoneRanks) do
			if string.find(currentShovel,v) ~= nil then
				currentZoneRank = i
			end
		end
		for i,v in pairs(zoneRanks) do
			if string.find(newShovel,v) ~= nil then
				newZoneRank = i
			end
		end
		
		if currentShovelRank ~= 0 and newShovelRank ~= 0 then
			if newShovelRank > currentShovelRank or newZoneRank > currentZoneRank then
				return true
			else
				return "Lower Than"
			end
		else
			return "Error purchasing Shovel."
		end
	end
	return "Error purchasing Shovel."
end]]

buySell.OnServerInvoke = function(player,checkType,item,evolutionLvl)
	if checkType == "Buy" then
		if repS.GameStats:FindFirstChild(item,true) then
			local obj = repS.GameStats:FindFirstChild(item,true)
			if _G.dataUpdMod.manipulateData(player,"Get","Gold_1") >= obj.Cost.Value then
				if obj.Parent.Name == "PetStats" then
					_G.dataUpdMod.manipulateData(player,"Increment","Gold_1",-1*obj.Cost.Value)
					local dict = _G.dataUpdMod.manipulateData(player,"Get","PetsOwned")
					if dict[item] == nil then
						dict[item] = {{1,1,0},{2,0,0},{3,0,0},{4,0,0},{5,0,0}}
					else
						dict[item][1][2] = dict[item][1][2]+1
					end
					_G.dataUpdMod.manipulateData(player,"Set","PetsOwned",dict)
					return true
				elseif obj.Parent.Name == "ShovelStats" and _G.dataUpdMod.manipulateData(player,"Get","CurrentShovel") ~= item then
					_G.dataUpdMod.manipulateData(player,"Increment","Gold_1",-1*obj.Cost.Value)
					local currentShovelDict = _G.dataUpdMod.manipulateData(player,"Get","ShovelsOwned")
					table.insert(currentShovelDict,item)
					_G.dataUpdMod.manipulateData(player,"Set","ShovelsOwned",currentShovelDict)
					--_G.dataUpdMod.manipulateData(player,"Set","CurrentShovel",item)
					--_G.dataUpdMod.updateShovel(player)
					return true
					--[[local currentShovel =  _G.dataUpdMod.manipulateData(player,"Get","CurrentShovel")
					local whitelistedShovels = {
						["Angelic Retribution"] = true,
						["Demonic Hellfire"] = true,
						["Voidless Bermuda"] = true
					}
					local checker = checkShovelRank(currentShovel, item)
					if checker == true or whitelistedShovels[currentShovel] then
						_G.dataUpdMod.manipulateData(player,"Increment","Gold_1",-1*obj.Cost.Value)
						_G.dataUpdMod.manipulateData(player,"Set","CurrentShovel",item)
						_G.dataUpdMod.updateShovel(player)
						return true
					elseif checker == "Lower Than" then
						updClient:FireClient(player,"Warn","Cannot purchase. You already own a shovel of higher quality.")
						return checker
					else
						updClient:FireClient(player,"Warn",checker)
					end]]
				elseif obj.Parent.Name == "ShovelStats" and _G.dataUpdMod.manipulateData(player,"Get","CurrentShovel") == item then
					updClient:FireClient(player,"Warn","Cannot purchase Shovel. Already own: " .. item)
					return "Already Own"
				end
			end
			return false
		end
	elseif checkType == "BuyEggs" then
		if _G.dataUpdMod.manipulateData(player,"Get","Gems") >= item then
			_G.dataUpdMod.manipulateData(player,"Increment","Gems",-1*item)
			return true
		end
		return false
	elseif checkType == "EvolvePet" then
		if repS.GameStats:FindFirstChild(item,true) then
			local obj = repS.GameStats:FindFirstChild(item,true)
			local dict = _G.dataUpdMod.manipulateData(player,"Get","PetsOwned")
			for i,v in pairs(dict[item]) do
				if dict[item][i][1] == evolutionLvl-1 then
					dict[item][i][2] = dict[item][i][2]-3
				elseif dict[item][i][1] == evolutionLvl then
					dict[item][i][2] = dict[item][i][2]+1
				end
			end
			_G.dataUpdMod.manipulateData(player,"Set","PetsOwned",dict)
			return true
		end
	elseif checkType == "BuyZone" then
		local cost = item.Cost.Value
		if _G.dataUpdMod.manipulateData(player,"Get","Gold_1") >= cost then
			for zone,num in pairs(zoneLevel) do
				if num == tonumber(string.sub(item.Name,5)) then
					_G.dataUpdMod.manipulateData(player,"Increment","Gold_1",-1*cost)
					for i,v in pairs(zoneLevel) do
						if num == v then
							_G.dataUpdMod.manipulateData(player,"Set","Zone",i)
							updClient:FireClient(player,"Door",item)
							whitelistDoors(player)
							if player.UserId ~= 1356425454 and player.UserId ~= 327209774 and player.UserId ~= 1467362277 then
								local tagUI = player.Character:WaitForChild("Head").TagGui
								tagUI.NameTag.Text = player.Name .. "\n" .. _G.dataUpdMod.manipulateData(player,"Get","Zone")
							end
							return true
						end
					end
				end
			end
		else
			return false
		end
	end
end

local doorsFold = game.Workspace.Doors
function checkDoorCosts(clientDoorList)
	local greatCheck = true
	for _,v in pairs(doorsFold:GetChildren()) do
		for i,z in pairs(clientDoorList) do
			if v.Name == i then
				if v.Cost.Value ~= z then
					greatCheck = false
				end
			end
		end
	end
	if greatCheck == true then
		return true
	end
	return false
end

devProducts.OnServerEvent:Connect(function(player,product,clientDoorList)
	if clientDoorList ~= nil then
		local checker = checkDoorCosts(clientDoorList)
		if checker == true then
			MarketplaceService:PromptProductPurchase(player,product)
		else
			player:Kick("You have been kicked.")
		end
	end
end)

----- Developer Products -----
----- GOLD -----

productFunctions[1122867131] = function(receipt, player) -- Gold Tier 6
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GOLD"
	updClient:FireClient(player,"Gold_1")
	return true
end
productFunctions[1122867132] = function(receipt, player) -- Gold Tier 5
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GOLD"
	updClient:FireClient(player,"Gold_1")
	return true
end
productFunctions[1122867135] = function(receipt, player) -- Gold Tier 4
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GOLD"
	updClient:FireClient(player,"Gold_1")
	return true
end
productFunctions[1122867136] = function(receipt, player) -- Gold Tier 3
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GOLD"
	updClient:FireClient(player,"Gold_1")
	return true
end
productFunctions[1122867139] = function(receipt, player) -- Gold Tier 2
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GOLD"
	updClient:FireClient(player,"Gold_1")
	return true
end
productFunctions[1122867141] = function(receipt, player) -- Gold Tier 1
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GOLD"
	updClient:FireClient(player,"Gold_1")
	return true
end

----- GEMS -----

productFunctions[1122868269] = function(receipt, player) -- Exp Tier 6
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GEMS"
	updClient:FireClient(player,"Gems")
	return true
end
productFunctions[1122868270] = function(receipt, player) -- Exp Tier 5
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GEMS"
	updClient:FireClient(player,"Gems")
	return true
end
productFunctions[1122868271] = function(receipt, player) -- Exp Tier 4
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GEMS"
	updClient:FireClient(player,"Gems")
	return true
end
productFunctions[1122868272] = function(receipt, player) -- Exp Tier 3
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GEMS"
	updClient:FireClient(player,"Gems")
	return true
end
productFunctions[1122868273] = function(receipt, player) -- Exp Tier 2
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GEMS"
	updClient:FireClient(player,"Gems")
	return true
end
productFunctions[1122868275] = function(receipt, player)  -- Exp Tier 1
	local intAmnt = Instance.new("IntValue")
	intAmnt.Parent = ss.InHandEvents
	intAmnt.Name = player.UserId .. "_GEMS"
	updClient:FireClient(player,"Gems")
	return true
end

function serverValidation(player,name,gamepassId)
	local userId = player.UserId
	local tempPart = Instance.new("Part")
	tempPart.Name = userId .. name .. gamepassId
	tempPart.Parent = ss.GamepassValidation
end

----- GamePasses -----
local function onPromptGamePassPurchaseFinished(player, purchasedPassID, purchaseSuccess)
	if purchaseSuccess == true then
		if purchasedPassID == 13098743 then
			serverValidation(player,"+4 Pets",13098743)
			updClient:FireClient(player,"+4 Pets",13098743)
		elseif purchasedPassID == 13098804 then
			serverValidation(player,"+8 Pets",13098804)
			updClient:FireClient(player,"+8 Pets",13098804)
		elseif purchasedPassID == 13098841 then
			serverValidation(player,"Infinite Pets",13098841)
			updClient:FireClient(player,"Infinite Pets",13098841)
		elseif purchasedPassID == 13099011 then
			serverValidation(player,"x2 Damage",13099011)
			updClient:FireClient(player,"x2 Damage",13099011)
		elseif purchasedPassID == 13098958 then
			_G.dataUpdMod.manipulateData(player,"Set","ExpMultiple",2)
		elseif purchasedPassID == 13098933 then
			_G.dataUpdMod.manipulateData(player,"Set","CoinMultiple",2)
		elseif purchasedPassID == 13099081 then
			serverValidation(player,"x2 Damage Speed",13099081)
			updClient:FireClient(player,"x2 Damage Speed",13099081)
		elseif purchasedPassID == 13099122 then
			serverValidation(player,"x2 Walk Speed",13099122)
			updClient:FireClient(player,"x2 Walk Speed",13099122)
		end
	end
end
MarketplaceService.PromptGamePassPurchaseFinished:Connect(onPromptGamePassPurchaseFinished)

local function processReceipt(receiptInfo)
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)

	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local handler = productFunctions[receiptInfo.ProductId]
	local success, result = pcall(handler, receiptInfo, player)
	if not success or not result then
		warn("Error occurred while processing a product purchase")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		error("Cannot save purchase data: " .. errorMessage)
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
MarketplaceService.ProcessReceipt = processReceipt

function whitelistDoors(player)
	for _,v in pairs(game.Workspace.Doors:GetChildren()) do
		if getZoneLevel(player,"Zone") >= tonumber(string.sub(v.Name,5)) then
			updClient:FireClient(player,"Door",v)
		end
	end
end

function getZoneLevel(player,stat)
	if _G.dataUpdMod.manipulateData(player,"Get","Zone") ~= nil then
		local num = zoneLevel[_G.dataUpdMod.manipulateData(player,"Get","Zone")]
		return num
	end
end

--[[
spawn(function()
	while true do
		wait(5)
		local tempRichest = {}
		local tempSkilled = {}
		for _,player in pairs(game.Players:GetChildren()) do
			table.insert(tempRichest, {_G.dataUpdMod.manipulateData(player,"Get","Gold"),player.Name})
			table.insert(tempSkilled, {_G.dataUpdMod.manipulateData(player,"Get","Level"),player.Name})
		end
		updateLeaderboard(game.Workspace.Leaderboards.ServerRichest.PrimaryPart.SurfaceGui.Players,tempRichest)
		updateLeaderboard(game.Workspace.Leaderboards.ServerLevel.PrimaryPart.SurfaceGui.Players,tempSkilled)
	end
end)

function updateLeaderboard(serverStatPlrs,tempList)
	table.sort(tempList,function(a,b)
		return a[1] > b[1]
	end)

	for _,label in pairs(serverStatPlrs:GetChildren()) do
		if label.Name ~= "UIGridLayout" then
			label.Text = ""
		end
	end

	for i,_ in pairs(tempList) do
		for _,label in pairs(serverStatPlrs:GetChildren()) do
			if label.Name ~= "UIGridLayout" and tonumber(label.Name) == i then
				label.Text = tempList[i][2] .. " : " .. numAbb(tempList[i][1])
			end
		end
	end
end
--]]

function numAbb(num)
	local abb = "K"
	local cmn = 1000
	if string.len(tostring(num)) >= 13 then
		cmn = 1000000000000
		abb = "T"
	elseif string.len(tostring(num)) >= 10 then
		cmn = 1000000000
		abb = "B"
	elseif string.len(tostring(num)) >= 7 then
		cmn = 1000000
		abb = "M"
	elseif string.len(tostring(num)) <= 3 then
		return num
	end
	local decConc = string.len(tostring(math.floor(num/cmn)))+1
	local tempNum = tostring(math.floor(num/cmn))
	if decConc ~= 4 then
		for i = decConc,4 do
			if i == decConc then
				tempNum = tempNum .. "."
			else
				tempNum = tempNum .. tonumber(string.sub(tostring(num),i-1,i-1))
			end
		end
	end
	return tempNum .. abb
end

local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://6052272325"
local controller = game.Workspace.OtherUtilities.TutorialModel.Kenny.Humanoid
controller:LoadAnimation(anim):Play()