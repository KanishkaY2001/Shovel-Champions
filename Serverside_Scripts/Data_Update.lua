local dataUpdate = {}
----- Data Storage -----
local ss = game:GetService("ServerStorage")
local sss = game:GetService("ServerScriptService")
local repS = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local up_st = repS.Remotes.Update_Stats
local updClient = repS.Remotes.Update_Client
local DataStore2 = require(sss.DataStore2)

local currentLevelCap = 30
_G.defLevel = 1
_G.defExp = 0
_G.defTime = 0
_G.defShovel = "Weak Wood Shovel"
_G.defGold = 0
_G.defMats = 0
_G.defZone = "Newbie"
_G.defDailyRewards = {os.time(),os.time()+60,os.time()+60} -- lastPlayed,normalReward,groupReward
_G.defExpMultiple = 1
_G.defCoinMultiple = 1
_G.defPetsOwned = {}
_G.defHatsOwned = {
	["Cool Hair"] = false,
	["Pretty Hair"] = false
}
_G.defShovelsOwned = {
	"Weak Wood Shovel"
}
_G.defGems = 0
_G.defCodes = {}

local defKeys = {
	["PetsOwned"] = _G.defPetsOwned,
	["Level"] = _G.defLevel,
	["Experience"] = _G.defExp,
	["TimePlayed"] = _G.defTime,
	["CurrentShovel"] = _G.defShovel,
	["Gold"] = _G.defGold,
	["Gold_1"] = _G.defGold,
	["MatsCollected"] = _G.defMats,
	["Zone"] = _G.defZone,
	["ExpMultiple"] = _G.defExpMultiple,
	["CoinMultiple"] = _G.defCoinMultiple,
	["DailyRewards"] = _G.defDailyRewards,
	["Gems"] = _G.defGems,
	["HatsOwned"] = _G.defHatsOwned,
	["ShovelsOwned"] = _G.defShovelsOwned,
	["RedeemedCodes"] = _G.defCodes
}
local hatList = {
	[1] = "Pretty Hair",
	[1] = "Cool Hair",
	[3] = "Playful Sunglasses",
	[6] = "Black Iron Commando",
	[9] = "Sinister Branches",
	[12] = "Emperor of the Night",
	[15] = "Ice Valkyrie",
	[18] = "Workclock Headphones",
	[21] = "Workclock Shades",
	[24] = "Silverthorn Antlers",
	[27] = "Classic Fedora",
	[30] = "Disgraced Baroness"
}

----- Global Data Store -----
_G.statsInGame = DataStoreService:GetOrderedDataStore("ShovelChampions8000")


function updRem(player,tempVal,keyName)
	up_st:FireClient(player,keyName,tempVal)
end

function dataUpdate.updGlobalData(player,key2)
	local playerKey = tostring("nastaStudios-" .. player.UserId)
	if key2 == "UpdateData" then
		
		local gemNo = 0
		local worstGemAmount = 0
		local wgid
		local gid = ""
		
		local goldNo = 0
		local worstGoldAmount = 0
		local wgoid
		local goid = ""
		
		local levelNo = 0
		local worstLevelAmount = 0
		local wlid
		local loid = ""
		
		local function checkLeaderboard()
			local pageSize = 18
			local Table_Of_Pages = {}
			print("Getting Sorted Async")
			local pages = _G.statsInGame:GetSortedAsync(false,18)
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

				for item, pageNo in iterPageItems(pages) do
					if string.find(item.key,"_Level") and levelNo < 6 then
						levelNo +=1
						if item.key == playerKey .. "_Level" then
							loid = item.key
						end
						if levelNo == 6 then
							worstLevelAmount = item.value
							wlid = item.key
						end
					elseif string.find(item.key,"_Gold") and goldNo < 6 then
						goldNo +=1
						if item.key == playerKey .. "_Gold" then
							goid = item.key
						end
						if goldNo == 6 then
							worstGoldAmount = item.value
							wgoid = item.key
						end
					elseif string.find(item.key,"_Gems") and gemNo < 6 then
						gemNo +=1
						if item.key == playerKey .. "_Gems" then
							gid = item.key
						end
						if gemNo == 6 then
							worstGemAmount = item.value
							wgid = item.key
						end
					end
				end
			end
		end
		
		checkLeaderboard()
		if goldNo < 6 then
			print("Set Async 1")
			_G.statsInGame:SetAsync(playerKey .. "_Gold",math.floor(_G.dataUpdMod.manipulateData(player,"Get","Gold_1")))
		else
			if math.floor(_G.dataUpdMod.manipulateData(player,"Get","Gold_1")) > worstGoldAmount then
				if goid == "" then
					print("Remove Async and Set Async")
					_G.statsInGame:RemoveAsync(wgoid)
					_G.statsInGame:SetAsync(playerKey .. "_Gold",math.floor(_G.dataUpdMod.manipulateData(player,"Get","Gold_1")))
				else
					print("Only set Async")
					_G.statsInGame:SetAsync(playerKey .. "_Gold",math.floor(_G.dataUpdMod.manipulateData(player,"Get","Gold_1")))
				end
			end
		end
		
		if levelNo < 6 then
			print("Set Async 1")
			_G.statsInGame:SetAsync(playerKey .. "_Level",math.floor(_G.dataUpdMod.manipulateData(player,"Get","Level")))
		else
			if math.floor(_G.dataUpdMod.manipulateData(player,"Get","Level")) > worstLevelAmount then
				if loid == "" then
					print("Remove Async and Set Async")
					_G.statsInGame:RemoveAsync(wlid)
					_G.statsInGame:SetAsync(playerKey .. "_Level",math.floor(_G.dataUpdMod.manipulateData(player,"Get","Level")))
				else
					print("Only set Async")
					_G.statsInGame:SetAsync(playerKey .. "_Level",math.floor(_G.dataUpdMod.manipulateData(player,"Get","Level")))
				end
			end
		end
		
		if gemNo < 6 then
			print("Set Async 1")
			_G.statsInGame:SetAsync(playerKey .. "_Gems",math.floor(_G.dataUpdMod.manipulateData(player,"Get","Gems")))
		else
			if math.floor(_G.dataUpdMod.manipulateData(player,"Get","Gems")) > worstGemAmount then
				if gid == "" then
					print("Remove Async and Set Async")
					_G.statsInGame:RemoveAsync(wgid)
					_G.statsInGame:SetAsync(playerKey .. "_Gems",math.floor(_G.dataUpdMod.manipulateData(player,"Get","Gems")))
				else
					print("Only set Async")
					_G.statsInGame:SetAsync(playerKey .. "_Gems",math.floor(_G.dataUpdMod.manipulateData(player,"Get","Gems")))
				end
			end
		end
	end
	print("")
end

function dataUpdate.manipulateData(player, command, key2, value)
	local petsOwnedStore = DataStore2("PetsOwned", player)
	local levelStore = DataStore2("Level", player)
	local expStore = DataStore2("Experience", player)
	local timeStore = DataStore2("TimePlayed", player)
	local shovelStore = DataStore2("CurrentShovel", player)
	local goldStore = DataStore2("Gold", player)
	local goldStore_1 = DataStore2("Gold_1", player)
	local matsStore = DataStore2("MatsCollected", player)
	local zoneStore = DataStore2("Zone", player)
	local expMultipleStore = DataStore2("ExpMultiple", player)
	local coinMultipleStore = DataStore2("CoinMultiple", player)
	local gemsStore = DataStore2("Gems", player)
	local hatsStore = DataStore2("HatsOwned",player)
	local shovelsOwnedStore = DataStore2("ShovelsOwned",player)
	local codesStore = DataStore2("RedeemedCodes",player)
	
	local dataStores = {
		["PetsOwned"] = DataStore2("PetsOwned", player),
		["Level"] = DataStore2("Level", player),
		["Experience"] = DataStore2("Experience", player),
		["TimePlayed"] = DataStore2("TimePlayed", player),
		["CurrentShovel"] = DataStore2("CurrentShovel", player),
		["Gold"] = DataStore2("Gold", player),
		["Gold_1"] = DataStore2("Gold_1", player),
		["MatsCollected"] = DataStore2("MatsCollected", player),
		["Zone"] = DataStore2("Zone", player),
		["ExpMultiple"] = DataStore2("ExpMultiple", player),
		["CoinMultiple"] = DataStore2("CoinMultiple", player),
		["DailyRewards"] = DataStore2("DailyRewards",player),
		["Gems"] = DataStore2("Gems",player),
		["HatsOwned"] = DataStore2("HatsOwned",player),
		["ShovelsOwned"] = DataStore2("ShovelsOwned",player),
		["RedeemedCodes"] = DataStore2("RedeemedCodes",player)
	}

	if command == "Increment" then
		local lvl
		
		if key2 == "Level" or key2 == "Experience" then
			lvl = dataStores["Level"]:Get(defKeys["Level"])
			if lvl ~= nil and lvl < currentLevelCap then
				dataStores[key2]:Increment(value)
			end
		else
			dataStores[key2]:Increment(value)
		end
		if key2 == "Experience" and dataStores["Experience"]:Get(defKeys["Experience"]) >= math.floor(7*(lvl*lvl)-7*lvl+50) then
			while dataStores["Experience"]:Get(defKeys["Experience"]) >= math.floor(7*(lvl*lvl)-7*lvl+50) do
				wait()
				local leftOver = dataStores["Experience"]:Get(defKeys["Experience"]) - math.floor(7*(lvl*lvl)-7*lvl+50)
				if lvl == currentLevelCap then
					leftOver = 0
				end
				_G.dataUpdMod.manipulateData(player,"Increment","Level",1)
				_G.dataUpdMod.manipulateData(player,"Set","Experience",leftOver)
				if hatList[dataStores["Level"]:Get(defKeys["Level"])] ~= nil then
					local ownedHats = dataStores["HatsOwned"]:Get(defKeys["HatsOwned"])
					if ownedHats[hatList[dataStores["Level"]:Get(defKeys["Level"])]] == nil then
						ownedHats[hatList[dataStores["Level"]:Get(defKeys["Level"])]] = false
						dataStores["HatsOwned"]:Set(ownedHats)
						updClient:FireClient(player,"AddHat",hatList[dataStores["Level"]:Get(defKeys["Level"])])
					end
				end
			end
		end
	elseif command == "Get" then
 		return dataStores[key2]:Get(defKeys[key2])
	elseif command == "Set" then
		dataStores[key2]:Set(value)
	end
	
	local ls = player:FindFirstChild("leaderstats")
	if ls then
		if key2 == "Gold_1" then
			ls.Gold.Value = numAbb(dataStores["Gold_1"]:Get(defKeys["Gold_1"]))
		elseif key2 == "Gems" then
			ls.Gems.Value = numAbb(dataStores["Gems"]:Get(defKeys["Gems"]))
		elseif key2 == "Level" then
			ls.Level.Value = dataStores["Level"]:Get(defKeys["Level"])
		end
	end
	
	updRem(player,dataStores[key2]:Get(defKeys[key2]),key2)
end

function dataUpdate.updateShovel(player)
	if player.Character ~= nil and player.Character:WaitForChild("UpperTorso") then
		local char = player.Character
		if char:FindFirstChild("Shovel") then
			char.UpperTorso:FindFirstChild("ShovelWeld"):Destroy()
			char:FindFirstChild("Shovel"):Destroy()
		end
		local wc = Instance.new("WeldConstraint")
		local cl = ss.Shovels:FindFirstChild(_G.dataUpdMod.manipulateData(player,"Get","CurrentShovel"),true):Clone()
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
end

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

return dataUpdate
