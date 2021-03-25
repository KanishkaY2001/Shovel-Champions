----- Game Objects -----
local TweenService = game:GetService("TweenService")
local repS = game:GetService("ReplicatedStorage")
local sss = game:GetService("ServerScriptService")
local ss = game:GetService("ServerStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local petsFolder = game.Workspace.ActivePets
local tSpawns = game.Workspace.TreasureSpawns
local gItems = game.ServerStorage.GeneralItems
local updClient = repS.Remotes.Update_Client

----- LUCK CHANCES -----
local eggSpawnChange = 50 -- 50% chance

----- Pet Definitons -----
local plrDict = {}
local plrDebounces = {}
local digDebounce = {}
local tot = 6

----- Variables -----
local serverWL = {}
local treasureLookAt = {}
local spawnRate = 2 --> Mud Spawn Rate
local clickDist = 80
local treasureChance = {
	{"Coin1",0,0.15,80,0.05}, --> 15% Spawn Rate, 5% Max Reward
	{"Coin2",0.15,0.3,100,0.1}, --> 15% Spawn Rate, 10% Max Reward
	{"Ingot",0.3,0.4,120,0.125}, --> 10% Spawn Rate, 12.5% Max Reward
	{"SmallSack",0.4,0.6,150,0.15}, --> 20% Spawn Rate, 15% Max Reward
	{"BigSack",0.6,0.7,200,0.2}, --> 10% Spawn Rate, 20% Max Reward
	{"Barrel",0.7,0.8,250,0.3}, --> 10% Spawn Rate, 30% Max Reward
	{"MediumChest",0.8,0.925,350,0.45}, --> 12.5% Spawn Rate, 45% Max Reward
	{"BigChest",0.925,1,500,1} --> 7.5% Spawn Rate, 100% Max Reward
}

local zoneMudColors = {
	[1] = Color3.fromRGB(86, 66, 54),
	[2] = Color3.fromRGB(68, 45, 36),
	[3] = Color3.fromRGB(150, 81, 40),
	[4] = Color3.fromRGB(81, 104, 111),
	[5] = Color3.fromRGB(64, 135, 143),
	[6] = Color3.fromRGB(52, 39, 117)
}

function numAbb(num)
	num = math.floor(num)
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

local zoneLevel = {
	["Newbie"] = 1,
	["Farm"] = 2,
	["Waterfall"] = 3,
	["Castle"] = 4,
	["Iceland"] = 5,
	["Crystalline"] = 6
}

local zoneHealths = {
	["Coin1"] = {      6,    54,  	155,  	330,  	 650, 	  1050},
	["Coin2"] = {      12,   69, 	170,    360,     700,     1125},
	["Ingot"] = {      19,   85, 	190,    400,     750,     1200},
	["SmallSack"] = {  26,   96,    210,    445,     800,	  1275},
	["BigSack"] = {    32,   110,   230,    490,     850,	  1355},
	["Barrel"] = {     37,   128, 	250,    530,     900,     1420},
	["MediumChest"] = {42,   135, 	270,    565,     950,     1500},
	["BigChest"] = {   50,   150,   300,    600,     1000,    1600}
}

-- cost of zone door = bigchest of (zone/5)*100
-- ["door6"] = 40000
local serverDoorCosts = {
	["door1"] = 1000, 
	["door2"] = 5000,
	["door3"] = 15000,
	["door4"] = 45000,
	["door5"] = 100000
}

for _,v in pairs(game.Workspace.Doors:GetChildren()) do
	if serverDoorCosts[v.Name] ~= nil then
		v.Cost.Value = serverDoorCosts[v.Name]
		v.Txt.NextdoorCost.Text = "Door Cost: " .. numAbb(v.Cost.Value)
		local doorCost = v.Cost.Value
		for _,x in pairs(v.Txt:GetChildren()) do
			if x.Name == "GoldAmount1" then
				x.Text = "Gold: " .. numAbb(doorCost*0.1)
			elseif x.Name == "GoldAmount2" then
				x.Text = "Gold: " .. numAbb(doorCost*0.2334)
			elseif x.Name == "GoldAmount3" then
				x.Text = "Gold: " .. numAbb(doorCost*0.3667)
			elseif x.Name == "GoldAmount4" then
				x.Text = "Gold: " .. numAbb(doorCost*0.6667)
			elseif x.Name == "GoldAmount5" then
				x.Text = "Gold: " .. numAbb(doorCost*1.1)
			elseif x.Name == "GoldAmount6" then
				x.Text = "Gold: " .. numAbb(doorCost*2.3334)
			end
		end
	end
end

local petStats = {
	["Mini Santa"] = 145, -- damage, gold boost
	["Winter Bear"] = 100,
	["Santa's Helper"] = 60,
	["Snow White"] = 45,
	["Snowman"] = 170,
	
	["Happy"] = 5,
	["Lion"] = 4,
	["Rabbit"] = 3,
	["Deer"] = 1,
	["Cat"] = 2,
	
	["Chicken"] = 14,
	["Cow"] = 12,
	["Farmer"] = 16,
	["Horse"] = 10,
	["Pig"] = 8,
	
	["Green Slime"] = 27,
	["Frog"] = 32,
	["Orange"] = 24,
	["Wolf"] = 21,
	["Blue Slime"] = 19,
	
	["Boxer"] = 52,
	["Assassin"] = 46,
	["Archer"] = 42,
	["Goblin Slayer"] = 60,
	["Wizard"] = 38,
	
	["Goblin"] = 86,
	["Penguin"] = 80,
	["Polar Bear"] = 95,
	["Fox"] = 75,
	["Ghost"] = 70,
	
	["Crystal"] = 136,
	["Crystal Dominus"] = 125,
	["Miner"] = 113,
	["Dragon"] = 150,
	["Crystal Golem"] = 105
}

for _,v in pairs(game.ReplicatedStorage.GameStats.PetStats:GetChildren()) do
	if petStats[v.Name] ~= nil then
		v.Damage.Value = petStats[v.Name]
		local tempBoost = 1
		if math.floor(petStats[v.Name]/3) > 1 then
			tempBoost = math.floor(petStats[v.Name]/3)
		end
		v.Boost.Value = tempBoost
	end
end

--[[
print("local petStats = {")
for i,v in pairs(game.ServerStorage.Pets:GetChildren()) do
	for _,x in pairs(v:GetChildren()) do
		print('    ["' .. x.Name .. '"] = {0,0},')
	end
	print("")
end
print("}")]]

----- Remotes -----
local digR = repS.Remotes.Dig_Event
local pet_add_remove = repS.Remotes:FindFirstChild("Pet_Add_Remove")
local petStats = repS.Remotes.Pet_Stats
local rewStats = repS.Remotes.Rew_Data

game:GetService("Players").PlayerRemoving:Connect(function(player)
	local plrName = player.Name
	if serverWL[plrName] ~= nil then
		serverWL[plrName]:Destroy()
	end
	if treasureLookAt[plrName] ~= nil then
		treasureLookAt[plrName] = nil
	end
	if plrDict[plrName] ~= nil then
		for i,v in pairs(plrDict[plrName]) do
			if v[3] ~= "" then
				if(petsFolder:FindFirstChild(v[3])) then
					petsFolder:FindFirstChild(v[3]):Destroy()
				end
			end
		end
		plrDict[plrName] = nil
	end	
	if plrDebounces[plrName] ~= nil then
		plrDebounces[plrName] = nil
	end
end)

spawn(function()
	while true do
		for _,zone in pairs(tSpawns:GetChildren()) do
			for _,spawner in pairs(zone:GetChildren()) do
				if spawner:FindFirstChildWhichIsA("Model") == nil then
					spawnTreasure(spawner,tonumber(string.sub(zone.Name,5)),false)
					break
				end
			end
		end
		wait(spawnRate)
	end
end)

petStats.OnServerInvoke = function(player,cmd)
	if cmd == "petDamage" then
		local petConfig = getEquippedPetConfig(player.Name)
		local totalDmg = 0
		for i,v in pairs(petConfig[2]) do
			totalDmg += v
		end
		return totalDmg
	end
end

rewStats.OnServerInvoke = function(player,cmd,id)
	if cmd == "getRewardNormal" then
		local reward = rewardEquation("BigChest",_G.dataUpdMod.manipulateData(player,"Get","Level"),1)[1]/3*7.5
		reward = math.floor(reward*_G.dataUpdMod.manipulateData(player,"Get","CoinMultiple"))
		_G.dataUpdMod.manipulateData(player,"Increment","Gold_1",reward)
		return reward
	elseif cmd == "getRewardGroup" then
		local reward = rewardEquation("BigChest",_G.dataUpdMod.manipulateData(player,"Get","Level"),1)[1]/3*22.5
		reward = math.floor(reward*_G.dataUpdMod.manipulateData(player,"Get","CoinMultiple"))
		_G.dataUpdMod.manipulateData(player,"Increment","Gold_1",reward)
		return reward
	elseif cmd == "conId" then
		if ss.CollectRewards:FindFirstChild(player.UserId .. id) then
			local val = ss.CollectRewards:FindFirstChild(player.UserId .. id)
			local valValue = val.Value
			if string.find(id,"_Gems") then
				return {"Gems",valValue}
			elseif string.find(id,"_Gold") then
				return {"Gold_1",valValue}
			end
		end
		return nil
	end
end

function rewardEquation(rewType,lvl,zoneNum)
	local config = {}
	for _,v in pairs(treasureChance) do
		if v[1] == rewType then
			local goldReward = math.floor(zoneHealths[rewType][zoneNum])
			table.insert(config, goldReward)
			table.insert(config, zoneNum*zoneNum+1)
			return config
		end
	end
end

function getAnglesDict()
	local angles = {}
	for i = 1,100 do
		table.insert(angles,{60*i,false,""})
	end
	return angles
end

function spawnTreasure(spawner,zoneNum,eventItem)
	local hp = Instance.new("IntValue")
	local rew = Instance.new("StringValue")
	local rand = math.random()
	local t
	if eventItem == false then
		for i,v in pairs(treasureChance) do -- 1 weakest, 5 rarest, strongest
			if rand >= v[2] and rand < v[3] then
				rew.Value = v[1]
				hp.Value = zoneHealths[v[1]][zoneNum]
				t = ss.Treasures:FindFirstChild(v[1]):Clone()
				break
			end
		end
	end
	hp.Parent = t.Stats
	rew.Parent = t.Stats
	if t:FindFirstChild("MudModel") and eventItem == false then
		for _,v in pairs(t:FindFirstChild("MudModel"):GetChildren()) do
			v.Color = zoneMudColors[zoneNum]
		end
	elseif eventItem == false and t:FindFirstChild("MudModel") == nil then
		t.MudPart.Color = zoneMudColors[zoneNum]
	end

	local cd = Instance.new("ClickDetector")
	cd.Parent = t.ClickDetectPart
	cd.MaxActivationDistance = clickDist
	cd.MouseClick:Connect(function(player)
		if digDebounce[player.Name] == nil then
			digDebounce[player.Name] = false
		end
		if (eventItem ~= false or zoneLevel[_G.dataUpdMod.manipulateData(player,"Get","Zone")] >= tonumber(string.sub(cd.Parent.Parent.Parent.Parent.Name,5,5))) and digDebounce[player.Name] == false then
			if plrDebounces[player.Name] == nil then
				plrDebounces[player.Name] = true
			end
			if plrDebounces[player.Name] == true then
				plrDebounces[player.Name] = false
				spawn(function()
					wait() -------------------------------------------------- WAS ORIGINALLY 0.5
					plrDebounces[player.Name] = true
				end)
				if not t.Whitelist:FindFirstChild(player.Name) then
					local wl = t.Whitelist
					local st = Instance.new("StringValue")
					st.Parent = wl
					st.Value = player.Name
					st.Name = player.Name
					
					if serverWL[player.Name] ~= nil then
						serverWL[player.Name]:Destroy()
						digR:FireClient(player,"StopDigging")
						treasureLookAt[player.Name] = nil
						if player.Character ~= nil and player.Character.Humanoid.Health ~= 0 then
							shovelBackPos(player.Character:FindFirstChild("Shovel"),player.Character)
						end
					end
					
					serverWL[player.Name] = st
					local multp
					local multp2
					repeat
						wait()
						multp = math.random(-1,1)
					until multp ~= 0
					repeat
						wait()
						multp2 = math.random(-1,1)
					until multp2 ~= 0
					local posNum = 0
					local posNum2 = 0
					local cf = 0
					posNum = 3.3
					posNum2 = 3.3
					cf = CFrame.new(t.PrimaryPart.Position) * CFrame.new(posNum*multp,0,posNum2*multp2)
					digR:FireClient(player,"StartProcess",t.PrimaryPart,zoneNum)
					treasureLookAt[player.Name] = nil
					treasureLookAt[player.Name] = t.PrimaryPart
					if getEquippedPetConfig(player.Name)[1] > 0 then
						spawn(function()
							petsDamage(player.Name)
						end)
					end
					if player.Character ~= nil and player.Character.Humanoid.Health ~= 0 then
						moveTo(player.Character.Humanoid,cf.Position)
					end
				end
			end
		end
	end)
	local posList = {
		["Coin1"] = Vector3.new(0,0.6,0),
		["Coin2"] = Vector3.new(0,0.6,0),
		["Ingot"] = Vector3.new(0,0.6,0),
		["SmallSack"] = Vector3.new(0,0.8,0),
		["BigSack"] = Vector3.new(0,0.8,0),
		["Barrel"] = Vector3.new(0,1.6,0),
		["MediumChest"] = Vector3.new(0,1.4,0),
		["BigChest"] = Vector3.new(0,1.8,0),
	}
	t:SetPrimaryPartCFrame(spawner.CFrame * CFrame.new(posList[t.Name]))
	t.Parent = spawner
end

digR.OnServerEvent:Connect(function(plr,cmd,treasureModel,damageAmount)
	if serverWL[plr.Name] then
		if cmd == "Stop" then
			serverWL[plr.Name]:Destroy()
			if plr.Character ~= nil and plr.Character.Humanoid.Health ~= 0 then
				shovelBackPos(plr.Character:FindFirstChild("Shovel"),plr.Character)
			end
			treasureLookAt[plr.Name] = nil
		elseif cmd == "Damage" then
			if treasureModel ~= nil and treasureModel:FindFirstChild("Stats") and treasureModel:FindFirstChild("Stats"):FindFirstChild("Alive") then
				local tempHp = treasureModel.Stats:FindFirstChildWhichIsA("IntValue")
				if tempHp ~= nil then
					if tempHp.Value - damageAmount > 0 then
						tempHp.Value -= damageAmount
					else
						digR:FireClient(plr,"StopDigging")
						treasureLookAt[plr.Name] = nil
						if plr.Character ~= nil and plr.Character.Humanoid.Health ~= 0 then
							shovelBackPos(plr.Character:FindFirstChild("Shovel"),plr.Character)
						end
						spawn(function()
							wait() ---------------------------------- WAS ORIGINALLY 0.7
							digR:FireClient(plr,"DestroyGUI",treasureModel.PrimaryPart)
						end)
						if serverWL[plr.Name] and treasureModel.Stats:FindFirstChild("Alive") then
							treasureModel.Stats.Alive:Destroy()
							treasureModel.ClickDetectPart:Destroy()
							tempHp.Value = 0
							local currentRew = treasureModel.Stats:FindFirstChildWhichIsA("StringValue").Value
							local rewItem = game:GetService("ServerStorage").Treasures:FindFirstChild(currentRew)
							for _,st in pairs(treasureModel.Whitelist:GetChildren()) do
								for i,v in pairs(serverWL) do
									if v == st then
										serverWL[i]:Destroy()
										if game.Players:FindFirstChild(i) then
											local newPlr = game.Players:FindFirstChild(i)
											local rewEq
											local calcNum1 = 0
											local calcNum2 = 0
											rewEq = rewardEquation(currentRew,_G.dataUpdMod.manipulateData(newPlr,"Get","Level"),tonumber(string.sub(treasureModel.Parent.Parent.Name,5,5)))
											calcNum1 = rewEq[1]
											calcNum2 = rewEq[2]
											
											local goldBoost = getEquippedPetConfig(i)[3]
											local goldTotal = math.floor(((calcNum1/3.5)+goldBoost)*_G.dataUpdMod.manipulateData(newPlr,"Get","CoinMultiple"))
											local randChosen = randomGen()
											local ranGold = math.random(2,4)
											for i = 1,ranGold do
												local goldV = Instance.new("IntValue")
												goldV.Name = newPlr.UserId .. randChosen .. "_Gold"
												goldV.Value = goldTotal
												goldV.Parent = ss.CollectRewards
											end
											digR:FireClient(newPlr,"RewardPlayer",treasureModel.PrimaryPart,randChosen .. "_Gold",ranGold)
											local chance2 = math.random()
											if chance2 <= eggSpawnChange/100 then
												local randChosen = randomGen()
												local zoneNum = tonumber(string.sub(treasureModel.Parent.Parent.Name,5,5))
												local randomGemAmount = 0
												if zoneNum == 1 then
													randomGemAmount = math.random(1,5)
												elseif zoneNum == 2 then
													randomGemAmount = math.random(1,10)
												elseif zoneNum == 3 then
													randomGemAmount = math.random(1,15)
												elseif zoneNum == 4 then
													randomGemAmount = math.random(1,20)
												elseif zoneNum == 5 then
													randomGemAmount = math.random(1,38)
												elseif zoneNum == 6 then
													randomGemAmount = math.random(1,54)
												end
												local ranGems = math.random(1,4)
												for i = 1,ranGems do
													local gemsV = Instance.new("IntValue")
													gemsV.Value = randomGemAmount
													gemsV.Name = newPlr.UserId .. randChosen .. "_Gems"
													gemsV.Parent = ss.CollectRewards
												end
												digR:FireClient(newPlr,"RewardPlayer",treasureModel.PrimaryPart,randChosen .. "_Gems",ranGems)
											end

											local expTotal = math.floor(calcNum2*_G.dataUpdMod.manipulateData(newPlr,"Get","ExpMultiple"))
											_G.dataUpdMod.manipulateData(newPlr,"Increment","Experience",expTotal)
											_G.dataUpdMod.manipulateData(newPlr,"Increment","MatsCollected",1)
										end
									end
								end
							end

							local mudParts = {}
							if treasureModel:FindFirstChild("MudModel") then
								for _,v in pairs(treasureModel:FindFirstChild("MudModel"):GetChildren()) do
									table.insert(mudParts,v)
								end
							else
								table.insert(mudParts,treasureModel.MudPart)
							end
							for _,v in pairs(mudParts) do
								spawn(function()
									for i = 1,10 do
										wait(0.04)
										v.Transparency += 0.1
									end
								end)
							end
							local sparks = ss.GeneralItems.Sparks:Clone()
							sparks.Parent = treasureModel.PrimaryPart
							if treasureModel:FindFirstChild("TreasureModel") then
								for i = 1,30 do
									wait()
									if treasureModel.PrimaryPart ~= nil then
										treasureModel:SetPrimaryPartCFrame(treasureModel.PrimaryPart.CFrame*CFrame.new(0,0.08,0))
									end
								end
							else
								for i = 1,30 do
									wait()
									if treasureModel.PrimaryPart ~= nil then
										treasureModel.PrimaryPart.CFrame = treasureModel.PrimaryPart.CFrame*CFrame.new(0,0.08,0)
									end
								end
							end
							wait(0.5)
							treasureModel:Destroy()
						end
					end
				end
			else
				digR:FireClient(plr,"StopDigging")
				treasureLookAt[plr.Name] = nil
				if plr.Character ~= nil and plr.Character.Humanoid.Health ~= 0 then
					shovelBackPos(plr.Character:FindFirstChild("Shovel"),plr.Character)
				end
			end
		end
	end
end)

function randomGen()
	local ltrs = {"A","B","C","D","E","F","G","Z","X","Y","W","V","S","T"}
	local x = ""
	for i = 1,9 do
		if i%2 == 0 then
			x = x .. math.random(i,9)
		else
			x = x .. ltrs[math.random(i,14)]
		end
	end
	return x
end

function moveTo(humanoid,targetPoint)
	local targetReached = false
	if humanoid ~= nil and humanoid.Health ~= 0 then
		local noYVector = Vector3.new(1,0,1)
		local root = humanoid.Parent.HumanoidRootPart
		local timeout = false
		targetPoint = Vector3.new(targetPoint.X,root.Position.Y,targetPoint.Z)
		humanoid:MoveTo(targetPoint)
		spawn(function()
			wait(10)
			if ((root.Position - targetPoint)*noYVector).magnitude > 2.5 then
				timeout = true
			end
		end)
		repeat
			wait()
		until ((root.Position - targetPoint)*noYVector).magnitude <= 2.5 or timeout == true
		if timeout == false then
			targetReached = true
			local hrp
			local name
			if humanoid ~= nil and humanoid.Parent ~= nil then
				hrp = humanoid.Parent.HumanoidRootPart
				name = humanoid.Parent.Name
			end
			local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
			if treasureLookAt[name] and hrp ~= nil and digDebounce[name] == false then
				digDebounce[name] = true
				wait()
				if treasureLookAt[name] ~= nil and ((root.Position - treasureLookAt[name].Position)*noYVector).magnitude < 10 then
					if treasureLookAt[name] ~= nil and hrp ~= nil then
						hrp.CFrame = CFrame.new(hrp.Position,Vector3.new(treasureLookAt[name].Position.X,hrp.Position.Y,treasureLookAt[name].Position.Z))
						digTreasure(treasureLookAt[name],humanoid.Parent,name)
					end
				else
					digDebounce[name] = false
				end
			end
		end
	end
	spawn(function()
		while not targetReached and humanoid ~= nil and humanoid.Parent ~= nil and treasureLookAt[humanoid.Parent.Name] ~= nil do
			if not (humanoid and humanoid.Parent) then
				break
			end
			if humanoid.WalkToPoint ~= targetPoint then
				break
			end
			humanoid:MoveTo(targetPoint)
			for i = 1,5 do
				wait(0.1)
				if humanoid ~= nil then
					if treasureLookAt[humanoid.Parent.Name] == nil then
						local plr = game.Players:GetPlayerFromCharacter(humanoid.Parent)
						if plr.Character ~= nil then
							plr.Character:FindFirstChild("Humanoid"):MoveTo(plr.Character:FindFirstChild("HumanoidRootPart").Position)
							targetReached = true
							digR:FireClient(plr,"StopDigging")
						end
						break
					elseif treasureLookAt[humanoid.Parent.Name] and treasureLookAt[humanoid.Parent.Name].Parent then
						local alive
						if treasureLookAt[humanoid.Parent.Name].Parent.Name == "TreasureModel" then
							alive = treasureLookAt[humanoid.Parent.Name].Parent.Parent.Stats:FindFirstChild("Alive")
						else
							alive = treasureLookAt[humanoid.Parent.Name].Parent.Stats:FindFirstChild("Alive")
						end	
						if alive == nil then
							local plr = game.Players:GetPlayerFromCharacter(humanoid.Parent)
							plr.Character:FindFirstChild("Humanoid"):MoveTo(plr.Character:FindFirstChild("HumanoidRootPart").Position)
							targetReached = true
							digR:FireClient(plr,"StopDigging")
							break
						end
					end
				end
			end
		end
	end)
end

function digTreasure(t,char,name)
	if char ~= nil then
		shovelDigPos(char:FindFirstChild("Shovel"),char)
		digR:FireClient(game.Players:GetPlayerFromCharacter(char),"StartDigging")
		wait(0.25)
		digDebounce[name] = false
	end
end

function shovelDigPos(shovel,char)
	if shovel ~= nil and char.UpperTorso:FindFirstChild("ShovelWeld") then
		char.UpperTorso:FindFirstChild("ShovelWeld"):Destroy()
		shovel:SetPrimaryPartCFrame(char.RightHand.CFrame*CFrame.new(0,0,-0.5)*CFrame.Angles(math.rad(90),0,0))
		local wc = Instance.new("WeldConstraint")
		wc.Parent = char.RightHand
		wc.Part0 = char.RightHand
		wc.Part1 = shovel.PrimaryPart
		wc.Name = "ShovelWeld"
		shovel.Parent = char
	end
end

function shovelBackPos(shovel,char)
	if shovel ~= nil and char.RightHand:FindFirstChild("ShovelWeld") then
		char.RightHand:FindFirstChild("ShovelWeld"):Destroy()
		if shovel.PrimaryPart.Name == "Handle2" then
			shovel:SetPrimaryPartCFrame(char.UpperTorso.CFrame*CFrame.new(0.4,0.4,0.75)*CFrame.Angles(0,math.rad(180),math.rad(45)))
		else
			shovel:SetPrimaryPartCFrame(char.UpperTorso.CFrame*CFrame.new(0.7,0.7,0.65)*CFrame.Angles(0,math.rad(180),math.rad(45)))
		end
		local wc = Instance.new("WeldConstraint")
		wc.Parent = char.UpperTorso
		wc.Part0 = char.UpperTorso
		wc.Part1 = shovel.PrimaryPart
		wc.Name = "ShovelWeld"
		shovel.Parent = char
	end
end

spawn(function()
	while true do
		local x = TweenService:Create(ss.HoverPos, TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out), {Value = Vector3.new(0, 0.5, 0)})
		x:Play()
		wait(2)
		x = TweenService:Create(ss.HoverPos, TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out), {Value = Vector3.new(0, -0.5, 0)})
		x:Play()
		wait(2)
	end
end)

spawn(function()
	while true do
		local x = TweenService:Create(ss.DigPos, TweenInfo.new(0.2,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out), {Value = Vector3.new(0, 0.2, 0)})
		x:Play()
		wait(0.2)
		x = TweenService:Create(ss.DigPos, TweenInfo.new(0.2,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out), {Value = Vector3.new(0, -2, 0)})
		x:Play()
		wait(0.2)
	end
end)

function weldMdl(mdl)
	local pp = mdl.PrimaryPart
	for _,v in pairs(mdl:GetChildren()) do
		if v ~= pp and not v:IsA("StringValue") and not v:IsA("IntValue") then
			local wc = Instance.new("WeldConstraint")
			wc.Parent = pp
			wc.Part0 = pp
			wc.Part1 = v
		end
	end
end

function equipPet(char,petId,petName,tempDeg,petDmg,petBoost)
	local cl = game:GetService("ServerStorage").Pets:FindFirstChild(petName,true):Clone()
	local namVal = Instance.new("StringValue")
	namVal.Value = cl.Name
	namVal.Name = "PetName"
	namVal.Parent = cl
	local dmgVal = Instance.new("IntValue")
	dmgVal.Value = petDmg
	dmgVal.Name = "Dmg"
	dmgVal.Parent = cl
	local boostVal = Instance.new("IntValue")
	boostVal.Value = petBoost
	boostVal.Name = "Boost"
	boostVal.Parent = cl

	cl.Name = petId
	local bp = Instance.new("BodyPosition")
	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1000,1000,1000)
	bg.P = 1200
	bg.D = 400
	weldMdl(cl)
	cl:SetPrimaryPartCFrame(char:WaitForChild("HumanoidRootPart").CFrame)
	cl.Parent = petsFolder
	bp.Parent = cl.PrimaryPart
	bg.Parent = cl.PrimaryPart
	cl.PrimaryPart:SetNetworkOwner(nil)
	spawn(function()
		petMovement(cl,char.Name,tempDeg)
	end)
end

pet_add_remove.OnServerEvent:Connect(function(player,action,petId,petName,petDmg,petBoost,petLevel)
	if action == "AddShovel" then
		local shovelName = petId
		if ss.Shovels:FindFirstChild(shovelName,true) then
			_G.dataUpdMod.manipulateData(player,"Set","CurrentShovel",shovelName)
			_G.dataUpdMod.updateShovel(player)
		end
	elseif action == "AddHat" then
		local hatName = petId
		if ss.Hats:FindFirstChild(hatName) then
			local hatClone = ss.Hats:FindFirstChild(hatName):Clone()
			hatClone.Parent = player.Character
			local hatsOwned = _G.dataUpdMod.manipulateData(player,"Get","HatsOwned")
			hatsOwned[hatName] = true
		end
	elseif action == "AddHatToInventory" then
		wait(math.random()/8)
		local hatName = petId
		if ss.Hats:FindFirstChild(hatName) then
			local hatsOwned = _G.dataUpdMod.manipulateData(player,"Get","HatsOwned")
			if hatsOwned[hatName] == nil then
				hatsOwned[hatName] = false
			end
		end
	elseif action == "RemoveHat" then
		local hatName = petId
		if player.Character:FindFirstChild(hatName) then
			player.Character:FindFirstChild(hatName):Destroy()
			local hatsOwned = _G.dataUpdMod.manipulateData(player,"Get","HatsOwned")
			hatsOwned[hatName] = false
		end
	elseif action == "Add" then
		local tempDeg = 60
		if plrDict[player.Name] == nil then
			plrDict[player.Name] = getAnglesDict()
			plrDict[player.Name][1] = {60,true,petId}
		else
			for i,v in pairs(plrDict[player.Name]) do
				if v[2] == false then
					v[2] = true
					v[3] = petId
					tempDeg = v[1]
					break
				end
			end
		end
		if player.Character ~= nil and player.Character.Humanoid.Health ~= 0 then
			local petsOwned = _G.dataUpdMod.manipulateData(player,"Get","PetsOwned")
			if petsOwned[petName] ~= nil then
				for i,v in pairs(petsOwned[petName]) do
					if v[1] == petLevel then
						v[3] += 1
					end
				end
			end
			_G.dataUpdMod.manipulateData(player,"Set","PetsOwned",petsOwned)
			equipPet(player.Character,petId,petName,tempDeg,petDmg,petBoost)
		end
	elseif action == "Remove" then
		for i,v in pairs(plrDict[player.Name]) do
			if v[3] == petId then
				v[2] = false
				v[3] = ""
				break
			end
		end
		local petsOwned = _G.dataUpdMod.manipulateData(player,"Get","PetsOwned")
		if petsOwned[petName] ~= nil then
			for i,v in pairs(petsOwned[petName]) do
				if v[1] == petLevel then
					v[3] -= 1
				end
			end
		end
		_G.dataUpdMod.manipulateData(player,"Set","PetsOwned",petsOwned)
		if(petsFolder:FindFirstChild(petId)) then
			petsFolder:FindFirstChild(petId):Destroy()
		end
	end
end)

function petMovement(pet,plrName,tempDeg)
	if pet ~= nil and pet.PrimaryPart ~= nil then
		local bp = pet.PrimaryPart.BodyPosition
		local bg = pet.PrimaryPart.BodyGyro
		while pet.Parent ~= nil do
			wait()
			local hrp
			if game.Workspace:FindFirstChild(plrName) then
				hrp = game.Workspace:FindFirstChild(plrName):FindFirstChild("HumanoidRootPart")
			end
			if bg.Parent ~= nil and hrp ~= nil then
				if treasureLookAt[plrName] ~= nil then
					bp.P = 13000
					if hrp ~= nil then
						local changedPos = CFrame.new(treasureLookAt[plrName].Position.X,hrp.Position.Y,treasureLookAt[plrName].Position.Z)*CFrame.new(tot*0.75*math.sin(tempDeg),0,tot*0.75*math.cos(tempDeg))
						bg.CFrame = CFrame.new(bg.Parent.Position,Vector3.new(treasureLookAt[plrName].CFrame.Position.X,math.rad(60),treasureLookAt[plrName].CFrame.Position.Z))
						bp.Position = changedPos.Position + ss.DigPos.Value + Vector3.new(0,1,0)
					end
				else
					bp.P = 10000
					if hrp ~= nil then
						local changedPos = CFrame.new(hrp.CFrame.Position)*CFrame.new(tot*math.sin(tempDeg),0,tot*math.cos(tempDeg))
						bg.CFrame = CFrame.new(bg.Parent.Position,Vector3.new(hrp.CFrame.Position.X,bg.Parent.Position.Y,hrp.CFrame.Position.Z))
						bp.Position = changedPos.Position + ss.HoverPos.Value + Vector3.new(0,1,0)
					end
				end
			end
		end
	end
end

function petsDamage(plrName)
	if treasureLookAt[plrName] ~= nil then
		while treasureLookAt[plrName] ~= nil do
			local dmgConfig = specificallyForDamage(plrName)
			if #dmgConfig[2] == 0 then
				break
			else
				----- Static Damage -----
				local totalDmg = 0
				for i,v in pairs(dmgConfig[2]) do
					totalDmg += v
				end
				local wTimes = 50
				if MarketPlaceService:UserOwnsGamePassAsync(game:GetService("Players"):GetUserIdFromNameAsync(plrName),13099081) then
					wTimes = 17
				end
				for i = 1,wTimes do
					wait()
					if treasureLookAt[plrName] == nil then
						break
					end
				end

				if treasureLookAt[plrName] ~= nil then
					if game:GetService("Players"):FindFirstChild(plrName) then
						digR:FireClient(game:GetService("Players"):FindFirstChild(plrName),"PetDigging",totalDmg)
					else
						break
					end
				else
					break
				end
			end
		end
	end
end

function getEquippedPetConfig(plrName)
	local num = 0
	local totalBoost = 0
	local config = {}
	if plrDict[plrName] then
		for i,v in pairs(plrDict[plrName]) do
			if v[3] ~= "" then
				num+=1
				table.insert(config,petsFolder:FindFirstChild(v[3]).Dmg.Value)
				totalBoost+=petsFolder:FindFirstChild(v[3]).Boost.Value
			end
		end
	end
	return {num,config,totalBoost}
end

function specificallyForDamage(plrName)
	local num = 0
	local totalBoost = 0
	local config = {}
	if plrDict[plrName] then
		for i,v in pairs(plrDict[plrName]) do
			if v[3] ~= "" then
				num+=1
				table.insert(config,petsFolder:FindFirstChild(v[3]).Dmg.Value)
				totalBoost+=petsFolder:FindFirstChild(v[3]).Boost.Value
			end
		end
	end
	return {num,config,totalBoost}
end