----- Object Definitions -----
local repS = game:GetService("ReplicatedStorage")
local cas = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketPlaceService = game:GetService("MarketplaceService")
local healthUI = repS.RepItems.HealthUI
local gameStats = repS.GameStats

----- Gamepass Variables ----
local maxPetCount = 2
local adminMaxPetCount = 100
local maxHatCount = 3
local dmgMultiple = 1
local damageSpeedMultiple = 1
local walkspeedMultiple = 1

----- Player -----
local player = game.Players.LocalPlayer
local currentLevelCap = 30
local baseWS = 18
local walkingToTarget = false
local diggingInProcess = false
local purchaseDebounce = true
local equipDebounce = true
local redeemingAtm = false
local guiDebounce = true
local char = nil
local head = nil
local hum = nil
local warningUI = nil
local shopUI = nil
local goldUI = nil
local gemsUI = nil
local statsUI = nil
local effectsUI = nil
local eggsUI = nil
local gamepassUI = nil
local inventoryUI = nil
local currentDigUI = nil
local settingsUI = nil
local teleportUI = nil
local selectedInvenItem = nil
local musicOn = true
local firstLoad = true
local goldInHand = 0
local gemsInHand = 0
local loadedStats = false
local charLoaded = false
local playerImg = ""
local petList = {}
local equippedPetCount = 0
local equippedHatsCount = 0
local buyingEggDebounce = false
local curZone = ''

local guiList = {
	"EffectsUI",
	"EggsUI",
	"GamepassUI",
	"GoldUI",
	"InventoryUI",
	"SettingsUI",
	"TeleportUI",
	"ShopUI",
	"WarningUI",
	"StatsUI",
	"GemsUI"
}
local playerStats = {
	["Level"] = 1,
	["Experience"] = 0,
	["TimePlayed"] = 0,
	["CoinMultiple"] = 1,
	["ExpMultiple"] = 1,
	["CurrentShovel"] = "Weak Wood Shovel",
	["ShovelsOwned"] = {"Weak Wood Shovel"},
	["Gold"] = 0,
	["Gold_1"] = 0,
	["MatsCollected"] = 0,
	["Zone"] = "Newbie",
	["PetsOwned"] = {},
	["DailyRewards"] = {},
	["HatsOwned"] = {},
	["Gems"] = 0,
	["RedeemedCodes"] = {}
}

local checkStatsLoaded = {
	["Level"] = false,
	["Experience"] = false,
	["TimePlayed"] = false,
	["CoinMultiple"] = false,
	["ExpMultiple"] = false,
	["CurrentShovel"] = false,
	["ShovelsOwned"] = false,
	["Gold"] = false,
	["Gold_1"] = false,
	["MatsCollected"] = false,
	["Zone"] = false,
	["PetsOwned"] = false,
	["DailyRewards"] = false,
	["HatsOwned"] = false,
	["Gems"] = false,
	["RedeemedCodes"] = false
}

local prevStats = {
	["Gems"] = 0,
	["Gold_1"] = 0,
	["Gold"] = 0
}

----- Zone/GUI Variables -----
local inventoryType = "Pets"
local curAtmos = ''
local openedGUI = nil
local shopConnections = {}
local invenConnections = {}
local eggConnections = {}
local eggConfirmConnections = {}
local codeConnections = {}
local evolveList = {}
local currentlyEvolving = false
local currentlyHatching = false
local warningDebounce = false
local currentDiggingUI = nil
local showingText = false
local digAnim = Instance.new("Animation")
digAnim.AnimationId = "rbxassetid://6052272325"
local redButtonImg = "rbxassetid://5957031845"
local greenButtonImg = "rbxassetid://5957006513"
local digTrack = nil
local eggCost = {
	["Egg0"] = 30,
	["Egg1"] = 100,
	["Egg2"] = 250,
	["Egg3"] = 450,
	["Egg4"] = 900,
	["Egg5"] = 1500
}
local devProcIds = {
	["Coin0"] = 1122867139,
	["Coin1"] = 1122867136,
	["Coin2"] = 1122867135,
	["Coin3"] = 1122867132,
	["Coin4"] = 1122867131,
	["Coin5"] = 1122867141,
	["Gem0"] = 1122868275,
	["Gem1"] = 1122868273,
	["Gem2"] = 1122868272,
	["Gem3"] = 1122868271,
	["Gem4"] = 1122868270,
	["Gem5"] = 1122868269
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

----- Time Display -----
local min = 60
local hour = min * 60 -- 3600
local day = hour * 24 -- 86400
local month = day * 30 -- 2592000

----- Remotes -----
local getStats = repS.Remotes.Get_Stats
local petStats = repS.Remotes.Pet_Stats
local updClient = repS.Remotes.Update_Client
local buySell = repS.Remotes.Buy_Sell
local devProducts = repS.Remotes.Dev_Products
local digR = repS.Remotes.Dig_Event
local up_st = repS.Remotes.Update_Stats
local petAddRemove = repS.Remotes.Pet_Add_Remove
local rewStats = repS.Remotes.Rew_Data
local eggHatch = repS.Remotes.Egg_Hatch
local twitterRem = repS.Remotes.Twitter_Code

function addHat(hatName)
	if repS.Viewports:FindFirstChild(hatName) then
		local imageButton = repS.Viewports:FindFirstChild(hatName):Clone()
		imageButton.Parent = inventoryUI.MainFrame.HatsInventory
		petAddRemove:FireServer("AddHatToInventory",hatName)
		spawn(function()
			effectsUI.Frame.HatUnlockText.Text = "Unlocked Shovel: " .. hatName .. "!"
			tweenGuiObj(effectsUI.Frame.HatUnlockText,false,UDim2.new(0.5, 0,0.045, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
			wait(2.8)
			tweenGuiObj(effectsUI.Frame.HatUnlockText,false,UDim2.new(0.5, 0,-0.2, 0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
			wait(0.3)
			effectsUI.Frame.HatUnlockText.Text = ""
		end)
	end
end

function addShovel(shovelName)
	if repS.Viewports:FindFirstChild(shovelName) then
		local imageButton = repS.Viewports:FindFirstChild(shovelName):Clone()
		imageButton.Parent = inventoryUI.MainFrame.ShovelsInventory
		spawn(function()
			effectsUI.Frame.HatUnlockText.Text = "Unlocked Accessory: " .. shovelName .. "!"
			tweenGuiObj(effectsUI.Frame.HatUnlockText,false,UDim2.new(0.5, 0,0.045, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
			wait(2.8)
			tweenGuiObj(effectsUI.Frame.HatUnlockText,false,UDim2.new(0.5, 0,-0.2, 0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
			wait(0.3)
			effectsUI.Frame.HatUnlockText.Text = ""
		end)
	end
end

function variableReset(refreshType)
	maxPetCount = 2
	dmgMultiple = 1
	damageSpeedMultiple = 1
	walkspeedMultiple = 1
	walkingToTarget = false
	diggingInProcess = false
	purchaseDebounce = true
	equipDebounce = true
	guiDebounce = true
	firstLoad = true
	playerImg = ""
	petList = {}
	curZone = ''
	openedGUI = nil
	for _,v in pairs(shopConnections) do
		v:Disconnect()
	end
	for _,v in pairs(invenConnections) do
		v:Disconnect()
	end
	for _,v in pairs(eggConnections) do
		v:Disconnect()
	end
	for _,v in pairs(eggConfirmConnections) do
		v:Disconnect()
	end
	for _,v in pairs(codeConnections) do
		v:Disconnect()
	end
	for _,v in pairs(evolveList) do
		v:Destroy()
	end
	currentlyEvolving = false
	currentlyHatching = false
	warningDebounce = false
	if currentDiggingUI ~= nil then
		currentDiggingUI:Destroy()
	end
end

function populateHatsInventory()
	local hatsList = playerStats["HatsOwned"]
	for hatName,value in pairs(hatsList) do
		if repS.Viewports:FindFirstChild(hatName) then
			local imageButton = repS.Viewports:FindFirstChild(hatName):Clone()
			imageButton.Parent = inventoryUI.MainFrame.HatsInventory
			if value == true then
				equippedHatsCount += 1
				local eq = repS.RepItems.Equipped:Clone()
				eq.Parent = imageButton
				petAddRemove:FireServer("AddHat",hatName)
			end
		end
	end
end

function populateShovelsInventory()
	local alreadyInInventory = false
	local shovelsList = playerStats["ShovelsOwned"]
	for _,shovelName in pairs(shovelsList) do
		if repS.Viewports:FindFirstChild(shovelName) then
			local imageButton = repS.Viewports:FindFirstChild(shovelName):Clone()
			imageButton.Parent = inventoryUI.MainFrame.ShovelsInventory
			if shovelName == playerStats["CurrentShovel"] then
				alreadyInInventory = true
				local eq = repS.RepItems.Equipped:Clone()
				eq.Parent = imageButton
			end
		end
	end
	if alreadyInInventory == false then
		local imageButton = repS.Viewports:FindFirstChild(playerStats["CurrentShovel"]):Clone()
		imageButton.Parent = inventoryUI.MainFrame.ShovelsInventory
	end
end

function doorListCheck()
	local doorsFold = game.Workspace.Doors
	local doorCosts = {}
	for _,v in pairs(doorsFold:GetChildren()) do
		doorCosts[v.Name] = v.Cost.Value
	end
	if doorCosts == nil then
		return {1000,5000,15000,45000,100000}
	end
	return doorCosts
end

function addPet(petName)
	local imageButton = repS.Viewports:FindFirstChild(petName):Clone()
	local lvl = Instance.new("IntValue")
	lvl.Name = "Level"
	lvl.Parent = imageButton
	lvl.Value = 1
	imageButton.Parent = inventoryUI.MainFrame.Inventory
	spawn(function()
		effectsUI.Frame.HatUnlockText.Text = "Unlocked Pet: " .. petName .. "!"
		tweenGuiObj(effectsUI.Frame.HatUnlockText,false,UDim2.new(0.5, 0,0.045, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
		wait(2.8)
		tweenGuiObj(effectsUI.Frame.HatUnlockText,false,UDim2.new(0.5, 0,-0.2, 0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
		wait(0.3)
		effectsUI.Frame.HatUnlockText.Text = ""
	end)
end

function populateInventory()
	local petsList = playerStats["PetsOwned"]
	for petName,mainArray in pairs(petsList) do -- [PetName] = {{Level,Quantity,equippedCount},{Level,Quantity,equippedCount},{3,10,2}}
		if repS.Viewports:FindFirstChild(petName) then
			for _,petArray in pairs(mainArray) do -- {Level,Quantity,equippedCount}
				if petArray[2] > 0 then
					local allocatedPets = 0
					for i = 1,petArray[2] do -- #Quantity
						local imageButton = repS.Viewports:FindFirstChild(petName):Clone()
						local lvl = Instance.new("IntValue")
						lvl.Name = "Level"
						lvl.Parent = imageButton
						lvl.Value = petArray[1]
						imageButton.Parent = inventoryUI.MainFrame.Inventory
						if petArray[3] > 0 and allocatedPets ~= petArray[3] and equippedPetCount < maxPetCount then
							allocatedPets += 1
							equippedPetCount += 1
							local eq = repS.RepItems.Equipped:Clone()
							eq.Parent = imageButton
							local dmgAmount = gameStats:FindFirstChild(imageButton.Name,true).Damage.Value
							local boostAmount = gameStats:FindFirstChild(imageButton.Name,true).Boost.Value
							local petDmg = math.floor(dmgAmount + dmgAmount*(imageButton.Level.Value/10))
							local petBoost = math.floor(math.floor(boostAmount + boostAmount*((imageButton.Level.Value-1)/10)))
							local petId = player.UserId
							local ltrs = {"A","B","C","D","E","F","G","Z","X","Y","W","V","S","T"}
							for i = 1,9 do
								if i%2 == 0 then
									petId = petId .. math.random(i,9)
								else
									petId = petId .. ltrs[math.random(i,14)]
								end
							end
							petList[petId] = imageButton
							petAddRemove:FireServer("Add",petId,petName,petDmg,petBoost)
						end
					end
				end
			end
		end
	end
	updateTotalPetCount()
end

function castRay(origin,direct,filter,filtType)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = filter
	params.FilterType = filtType
	return workspace:Raycast(origin, direct, params)
end

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
	local rawResult = tempNum .. abb
	return rawResult
end

local function onInputBegan(input, gameProcessed)
	local KeyCode = input.KeyCode -- Get all keyboard inputs
	if KeyCode == Enum.KeyCode.E and eggsUI ~= nil and eggsUI.MainFrame.Visible and not currentlyHatching and eggsUI.MainFrame.CurrentShop.Value ~= "" then
		if not currentlyHatching and not warningDebounce then
			local hatchNum = 1
			currentlyHatching = true
			displayEggHatch("Would you like to buy " .. hatchNum .. "x Eggs for " .. numAbb(eggCost[eggsUI.MainFrame.CurrentShop.Value]*hatchNum) .. " Gems?", hatchNum)
		end
	elseif KeyCode == Enum.KeyCode.Q and eggsUI ~= nil and eggsUI.MainFrame.Visible and not currentlyHatching and eggsUI.MainFrame.CurrentShop.Value ~= "" then
		if not currentlyHatching and not warningDebounce then
			local hatchNum = 3
			currentlyHatching = true
			displayEggHatch("Would you like to buy " .. hatchNum .. "x Eggs for " .. numAbb(eggCost[eggsUI.MainFrame.CurrentShop.Value]*hatchNum) .. " Gems?", hatchNum)
		end
	end
end
UserInputService.InputBegan:Connect(onInputBegan)
--[[
function generateTween(obj,effect,dur)
	local info = TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
	return TweenService:Create(obj,info,effect)
end

local bloom = game.Lighting.Bloom
local blur = game.Lighting.Blur
local clrcrt = game.Lighting.ColorCorrection
local sunray = game.Lighting.SunRays
local atmo = game.Lighting.Atmosphere

function zoneEffects()
	if curAtmos == 'NewbieZone' then
		generateTween(atmo,{Density = 0.25,Color = Color3.fromRGB(247, 243, 255),Haze = 0},2):Play()
		generateTween(clrcrt,{TintColor = Color3.fromRGB(214, 214, 214), Saturation = 0.3, Contrast = 0.3},2):Play()
	elseif curAtmos == 'FarmZone' then
		generateTween(atmo,{Density = 0.362,Color = Color3.fromRGB(234, 168, 93),Haze = 0},2):Play()
		generateTween(clrcrt,{TintColor = Color3.fromRGB(255, 188, 156), Saturation = 0, Contrast = 0.2},2):Play()
	elseif curAtmos == 'WaterfallZone' then
		generateTween(atmo,{Density = 0.25,Color = Color3.fromRGB(123, 154, 227),Haze = 0},2):Play()
		generateTween(clrcrt,{TintColor = Color3.fromRGB(214, 214, 214), Saturation = 0.3, Contrast = 0.3},2):Play()
	elseif curAtmos == 'CastleZone' then
		generateTween(atmo,{Density = 0.453,Color = Color3.fromRGB(200, 200, 200),Haze = 0},2):Play()
		generateTween(clrcrt,{TintColor = Color3.fromRGB(191, 191, 191), Saturation = -0.4, Contrast = 0.3},2):Play()
	elseif curAtmos == 'IcelandZone' then
		generateTween(atmo,{Density = 0.599,Color = Color3.fromRGB(119, 173, 188),Haze = 0},2):Play()
		generateTween(clrcrt,{TintColor = Color3.fromRGB(160, 193, 207), Saturation = -0.2, Contrast = 0.8},2):Play()
	elseif curAtmos == 'CrystallineZone' then
		generateTween(atmo,{Density = 0.321,Color = Color3.fromRGB(189, 132, 222),Haze = 0},2):Play()
		generateTween(clrcrt,{TintColor = Color3.fromRGB(189, 155, 255), Saturation = 0, Contrast = 0.2},2):Play()
	else
		generateTween(atmo,{Density = 0.25,Color = Color3.fromRGB(123, 154, 227),Haze = 0},2):Play()
		generateTween(clrcrt,{TintColor = Color3.fromRGB(214, 214, 214), Saturation = 0.3, Contrast = 0.3},2):Play()
	end
end

function atmosCheck()
	spawn(function()
		while head ~= nil do
			if head then
				local ray = castRay(head.CFrame.p,Vector3.new(0,100,0),{game.Workspace.AtmosZones},Enum.RaycastFilterType.Whitelist)
				if ray then
					if curAtmos ~= ray.Instance.Parent.Name then
						curAtmos = ray.Instance.Parent.Name
						zoneEffects()
					end
				else
					if curAtmos ~= '' then
						curAtmos = ''
						zoneEffects()
					end
				end
			end
			wait(1)
		end
	end)
end
--]]
function zoneCheck()
	spawn(function()
		while head ~= nil do
			local ray = castRay(head.CFrame.p,Vector3.new(0,35,0),{game.Workspace.RayPrompts},Enum.RaycastFilterType.Whitelist)
			if ray then
				if curZone ~= ray.Instance.Parent.Name then
					curZone = ray.Instance.Parent.Name
					if string.find(ray.Instance.Name,'Shop') and getStats:InvokeServer("requirement","Zone",tonumber(string.sub(ray.Instance.Name,6,6))) then
						if guiDebounce then
							guiDebounce = false
							spawn(function()
								wait(0.25)
								guiDebounce = true
							end)
							openedGUI = shopUI
							guiDisplay(shopUI,"Open","Shop",ray.Instance.Name)
						end
					elseif ray.Instance.Name == "NormalDaily" then
						local check = getStats:InvokeServer("normalDailyReward")
						if check == true then
							local rewardAmount = rewStats:InvokeServer("getRewardNormal")
							displayWarning("Congratulations! You collected " .. numAbb(rewardAmount) .. " as Daily Reward")
						else
							local tl = playerStats["DailyRewards"][2]-os.time()
							if math.floor((tl/60/60)%60) <= 0 and math.floor((tl/60)%60) <= 0 then
								displayWarning("Must wait less than 1 Minute until next reward.")
							else
								displayWarning("Must wait:\n" .. math.floor((tl/60/60)%60) .. " Hours & " .. math.floor((tl/60)%60) .. " Minutes until next reward.")
							end
						end
					elseif ray.Instance.Name == "GroupDaily" then
						if game.Players.LocalPlayer ~= nil and game.Players.LocalPlayer:IsInGroup(8263287) then
							local check = getStats:InvokeServer("groupDailyReward")
							if check == true then
								local rewardAmount = rewStats:InvokeServer("getRewardGroup")
								displayWarning("Congratulations! You collected " .. numAbb(rewardAmount) .. " as Daily Group Reward")
							else
								local tl = playerStats["DailyRewards"][3]-os.time()
								if math.floor((tl/60/60)%60) <= 0 and math.floor((tl/60)%60) <= 0 then
									displayWarning("Must wait less than 1 Minute until next reward.")
								else
									displayWarning("Must wait:\n" .. math.floor((tl/60/60)%60) .. " Hours & " .. math.floor((tl/60)%60) .. " Minutes until next reward.")
								end
							end
						else
							displayWarning("Get 3 Times More Daily Rewards by joining Nasta Studios Roblox Group!")
						end
					elseif string.find(ray.Instance.Name,'Egg') then
						if guiDebounce then
							guiDebounce = false
							spawn(function()
								wait(0.25)
								guiDebounce = true
							end)
							local populateInfo = getStats:InvokeServer("eggShop",ray.Instance.Name)
							if populateInfo ~= nil then
								eggsUI.MainFrame.CurrentShop.Value = ray.Instance.Name
								openedGUI = eggsUI
								for i,petInfo in pairs(populateInfo) do
									local frame = eggsUI.MainFrame:FindFirstChild("Pet" .. i-1)
									local vpCl = repS.Viewports:FindFirstChild(petInfo[1]):FindFirstChildWhichIsA("ViewportFrame"):Clone()
									vpCl.Parent = frame.ImageLabel
									rotateViewport(vpCl)
									frame.TextLabel.Text = (petInfo[3]-petInfo[2])*100 .. "%"
								end
								local function clickedBuy()
									if not currentlyHatching and not warningDebounce then
										local hatchNum = 1
										currentlyHatching = true
										displayEggHatch("Would you like to buy " .. hatchNum .. "x Eggs for " .. numAbb(eggCost[eggsUI.MainFrame.CurrentShop.Value]*hatchNum) .. " Gems?",hatchNum)
									end
								end
								local tempCon = eggsUI.MainFrame.E.MouseButton1Click:Connect(clickedBuy)
								table.insert(eggConnections,tempCon)

								local function clickedBuy()
									if not currentlyHatching and not warningDebounce then
										local hatchNum = 3
										currentlyHatching = true
										displayEggHatch("Would you like to buy " .. hatchNum .. "x Eggs for " .. numAbb(eggCost[eggsUI.MainFrame.CurrentShop.Value]*hatchNum) .. " Gems?",hatchNum)
									end
								end
								local tempCon = eggsUI.MainFrame.Q.MouseButton1Click:Connect(clickedBuy)
								table.insert(eggConnections,tempCon)

								eggsUI.MainFrame.Visible = true
								tweenGuiObj(eggsUI.MainFrame,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
							end
						end
					end
				end
			else
				if curZone ~= '' then
					curZone = ''
					if openedGUI ~= nil and openedGUI.Name == "ShopUI" then
						guiDisplay(openedGUI,"Close")
					elseif openedGUI ~= nil and openedGUI.Name == "EggsUI" then
						for _,v in pairs(eggConnections) do
							if v ~= nil then
								v:Disconnect()
							end
						end
						if warningUI.Frame.Question.Visible ~= true then
							eggsUI.MainFrame.CurrentShop.Value = ""
						end
						spawn(function()
							tweenGuiObj(eggsUI.MainFrame,false,UDim2.new(.5,0,-0.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
							wait(0.4)
							eggsUI.MainFrame.Visible = false
						end)
						for _,v in pairs(eggsUI.MainFrame:GetChildren()) do
							if string.find(v.Name,"Pet") and v.Name ~= "Pet5" then ----------------- Will need to change last part when updating 6 items
								if v.ImageLabel:FindFirstChildWhichIsA("ViewportFrame") then
									v.ImageLabel:FindFirstChildWhichIsA("ViewportFrame"):Destroy()
								end
								v.TextLabel.Text = ""
							end
						end
					end
				end
			end
			wait(0.25)
		end
	end)
end

function guiDisplay(guiObj,action,guiType,partName)
	local mf = guiObj.MainFrame
	if action == "Close" then
		for _,con in pairs(shopConnections) do
			con:Disconnect()
		end
		tweenGuiObj(mf,false,UDim2.new(-0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
		guiObj.Enabled = false
		if mf:FindFirstChildWhichIsA("ViewportFrame") then
			mf:FindFirstChildWhichIsA("ViewportFrame"):Destroy()
		end
		mf.Power.Text = ""
		mf.Cost.Text = ""
		if guiType == "Shop" then
			displayItems(mf,partName)
		end
	else
		closeOtherUI()
		local function clickedBuy()
			if purchaseDebounce then
				purchaseDebounce = false
				local bought = buySell:InvokeServer("Buy",mf:FindFirstChildWhichIsA("IntValue").Name)
				if bought == true then
					local itemName = mf:FindFirstChildWhichIsA("IntValue").Name
					if gameStats.PetStats:FindFirstChild(itemName) then
						local viewport = repS.Viewports:FindFirstChild(itemName):Clone()
						local lvl = Instance.new("IntValue")
						lvl.Name = "Level"
						lvl.Parent = viewport
						lvl.Value = 1
						viewport.Parent = inventoryUI.MainFrame.Inventory
					elseif gameStats.ShovelStats:FindFirstChild(itemName) then
						addShovel(itemName)
					end
					displayWarning("Successfully Bought Item: " .. itemName)
				elseif bought == false then
					print("returned false")
					spawn(function()
						wait(1)
						local doorDict =  doorListCheck()
						devProducts:FireServer(getDevProdId("Gold_1",mf:FindFirstChildWhichIsA("IntValue").Value-playerStats["Gold_1"]),doorDict)
					end)
					displayWarning("Oh No! You are missing " .. numAbb(mf:FindFirstChildWhichIsA("IntValue").Value-playerStats["Gold_1"]) .. " Gold") -- \nYou can Claim Treasures or Purchase more Gold.
				end
				wait(4)
				purchaseDebounce = true
			end
		end
		local tempCon = mf.BuyButton.MouseButton1Click:Connect(clickedBuy)
		table.insert(shopConnections, tempCon)
		displayItems(mf,partName)
		guiObj.Enabled = true
		tweenGuiObj(mf,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
		wait(0.5)
	end
end

function displayWarning(text,cmd)
	if not warningDebounce then
		warningDebounce = true
		warningUI.Frame.Description.Text = text
		tweenGuiObj(warningUI.Frame,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
		if cmd == "Evolution" then
			wait(8)
		elseif string.find(text,"Update:") then
			wait(11)
		else
			wait(3)
		end
		tweenGuiObj(warningUI.Frame,false,UDim2.new(0.5,0,1.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
		wait(0.5)
		warningUI.Frame.Description.Text = ""
		warningDebounce = false
	end
end

function displayCodesWarning(text)
	if not warningDebounce then
		warningDebounce = true
		for _,v in pairs(codeConnections) do
			v:Disconnect()
		end
		warningUI.Frame.CodeDesc.Text = text
		warningUI.Frame.Title.Text = "Codes"
		warningUI.Frame.CodeBox.Visible = true
		warningUI.Frame.TryCodeButton.Visible = true
		warningUI.Frame.CodeDesc.Visible = true
		tweenGuiObj(warningUI.Frame,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
		
		local function clickedCode()
			if redeemingAtm == false then
				redeemingAtm = true
				local attempt = twitterRem:InvokeServer(warningUI.Frame.CodeBox.TextBox.Text)
				if attempt[1] ~= "incorrect" then
					if attempt[1] == "redeemed" then
						effectsUI.Frame.HatUnlockText.Text = "Congratulations! You received " .. attempt[2] .. " Gems and " .. attempt[3] .. " Coins!"
					elseif attempt[1] == "already redeemed" then
						effectsUI.Frame.HatUnlockText.Text = "Redeemed already. Follow @NastaStudiosRB for more awesome codes!"
					end
					tweenGuiObj(effectsUI.Frame.HatUnlockText,false,UDim2.new(0.5, 0,0.045, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
					wait(2.8)
					tweenGuiObj(effectsUI.Frame.HatUnlockText,false,UDim2.new(0.5, 0,-0.2, 0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
					wait(0.3)
					effectsUI.Frame.HatUnlockText.Text = ""
				end
				wait(0.1)
				redeemingAtm = false
			end
		end
		local tempCon = warningUI.Frame.TryCodeButton.MouseButton1Click:Connect(clickedCode)
		table.insert(codeConnections,tempCon)
	end
end

function displayEggHatch(text,hatchNum)
	if not warningDebounce then
		warningDebounce = true
		for _,con in pairs(eggConfirmConnections) do
			con:Disconnect()
		end
		warningUI.Frame.NoButton.Visible = true
		warningUI.Frame.YesButton.Visible = true
		warningUI.Frame.Question.Text = text
		warningUI.Frame.Title.Text = "CONFIRMATION"
		tweenGuiObj(warningUI.Frame,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
		local function clickedBuy()
			tweenGuiObj(warningUI.Frame,false,UDim2.new(0.5,0,1.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
			if eggsUI.MainFrame.Position ~= UDim2.new(0.5,0,0.5,0) then
				for _,v in pairs(eggConnections) do
					if v ~= nil then
						v:Disconnect()
					end
				end
			end
			wait(0.5)
			warningUI.Frame.Question.Text = ""
			warningUI.Frame.NoButton.Visible = false
			warningUI.Frame.YesButton.Visible = false
			warningDebounce = false
			wait(1)
			currentlyHatching = false
		end
		local tempCon = warningUI.Frame.NoButton.MouseButton1Click:Connect(clickedBuy)
		table.insert(eggConfirmConnections,tempCon)

		local function clickedBuy()
			if buyingEggDebounce == false then
				buyingEggDebounce = true
				spawn(function()
					wait(2)
					buyingEggDebounce = false
				end)
				local tryingTobuy = buySell:InvokeServer("BuyEggs",eggCost[eggsUI.MainFrame.CurrentShop.Value]*hatchNum)
				if tryingTobuy == true then
					local attempt = eggHatch:InvokeServer(hatchNum,eggsUI.MainFrame.CurrentShop.Value)
					if attempt ~= nil then
						warningUI.Frame.Question.Text = ""
						warningUI.Frame.NoButton.Visible = false
						warningUI.Frame.YesButton.Visible = false
						eggHatching(attempt)
					end
				else
					warningUI.Frame.Question.Text = ""
					warningUI.Frame.NoButton.Visible = false
					warningUI.Frame.YesButton.Visible = false
					warningUI.Frame.Description.Text = "You need " .. numAbb(eggCost[eggsUI.MainFrame.CurrentShop.Value]*hatchNum-playerStats["Gems"]) .. " more Gems to purchase these Eggs."
					spawn(function()
						wait(1)
						devProducts:FireServer(getDevProdId("Gems",eggCost[eggsUI.MainFrame.CurrentShop.Value]*hatchNum-playerStats["Gems"]))
					end)
					wait(3)
					tweenGuiObj(warningUI.Frame,false,UDim2.new(0.5,0,1.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
					wait(0.5)
					warningUI.Frame.Description.Text = ""
					warningDebounce = false
					currentlyHatching = false
				end
			end
		end
		local tempCon = warningUI.Frame.YesButton.MouseButton1Click:Connect(clickedBuy)
		table.insert(eggConfirmConnections,tempCon)
	end
end

function eggHatching(petList)
	local hatchNum = #petList
	local viewports = {}
	warningUI.Frame.Title.Text = "EGG HATCH"
	for _,v in pairs(petList) do
		if repS.Viewports:FindFirstChild(v) then
			local vp = repS.Viewports:FindFirstChild(v):FindFirstChildWhichIsA("ViewportFrame"):Clone()
			vp.Size = UDim2.new(1.7,0,1.7,0)
			vp.Position = UDim2.new(-0.35,0,-0.35,0)
			table.insert(viewports,vp)
			local itemName = v
			if gameStats.PetStats:FindFirstChild(itemName) then
				local viewport = repS.Viewports:FindFirstChild(itemName):Clone()
				local lvl = Instance.new("IntValue")
				lvl.Name = "Level"
				lvl.Parent = viewport
				lvl.Value = 1
				viewport.Parent = inventoryUI.MainFrame.Inventory
			end
		end
	end

	local eggImg = warningUI.Frame.EggImg
	local x = repS.Viewports:FindFirstChild(eggsUI.MainFrame.CurrentShop.Value):FindFirstChildWhichIsA("ViewportFrame"):Clone()
	x.Size = UDim2.new(1.7,0,1.7,0)
	x.Position = UDim2.new(-0.35,0,-0.35,0)
	if eggsUI.MainFrame.Visible == false then
		eggsUI.MainFrame.CurrentShop.Value = ""
	end
	x.Parent = eggImg

	for _,viewport in pairs(viewports) do
		for _,evolveImg in pairs(warningUI.Frame:GetChildren()) do
			if hatchNum == 1 then
				if evolveImg.Name == "EvolveImageMid" and not evolveImg:FindFirstChildWhichIsA("ViewportFrame") then
					viewport.Parent = evolveImg
					evolveImg.Position = UDim2.new(0.372, 0,0.415, 0)
					evolveImg.Size = UDim2.new(0,0,0,0)
				end
			else
				if string.find(evolveImg.Name,"EvolveImage") and not evolveImg:FindFirstChildWhichIsA("ViewportFrame") then
					viewport.Parent = evolveImg
					evolveImg.Position = UDim2.new(0.372, 0,0.415, 0)
					evolveImg.Size = UDim2.new(0,0,0,0)
				end
			end
		end
	end

	spawn(function()
		for i = 1,12 do
			eggImg.Rotation = 20
			wait(0.1)
			eggImg.Rotation = -20
			wait(0.1)
		end
		eggImg.Rotation = 0
		for i = 1,10 do
			wait(0.1)
			if eggImg:FindFirstChildWhichIsA("ViewportFrame") then
				eggImg:FindFirstChildWhichIsA("ViewportFrame").ImageTransparency += 0.1
			end
		end
		wait(0.3)
		eggImg:FindFirstChildWhichIsA("ViewportFrame"):Destroy()
		tweenGuiObj(warningUI.Frame.EvolveImage,UDim2.new(0.259, 0,0.255, 0),UDim2.new(0.681, 0,0.415, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.5)
		tweenGuiObj(warningUI.Frame.EvolveImageMid,UDim2.new(0.259, 0,0.255, 0),UDim2.new(0.372, 0,0.415, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.5)
		tweenGuiObj(warningUI.Frame.EvolveImageLeft,UDim2.new(0.259, 0,0.255, 0),UDim2.new(0.057, 0,0.418, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.5)
		wait(1)
		for _,v in pairs(viewports) do
			spawn(function()
				local model = v:FindFirstChildWhichIsA("Model")
				for i = 1,120 do
					wait()
					if model ~= nil then
						model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame * CFrame.Angles(0,math.rad(2),0))
					end
				end
				model.Parent:Destroy()
			end)
		end
		local lvlText = "Unlocked " .. hatchNum .. " New Pets!"
		if hatchNum == 1 then
			lvlText = "Unlocked " .. hatchNum .. " New Pet!"
		end
		spawn(function()
			wait(math.random())
			if not showingText then
				showingText = true
				for i = 1,string.len(lvlText) do
					wait(0.06)
					warningUI.Frame.Unlock.Text = warningUI.Frame.Unlock.Text .. string.sub(lvlText,i,i)
				end
				wait(2.5)
				warningUI.Frame.Title.Text = "WARNING"
				eggImg.ImageTransparency = 0
				warningUI.Frame.Unlock.Text = ""
				tweenGuiObj(warningUI.Frame,false,UDim2.new(0.5,0,1.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
				wait(1.5)
				warningDebounce = false
				currentlyHatching = false
				showingText = false
			end
		end)
	end)
end

function displayItems(mf,shopLevel)
	for _,v in pairs(mf.ShopUI:GetChildren()) do
		if v.Name == shopLevel then
			v.Visible = true
			for _,item in pairs(v:GetChildren()) do
				if item:IsA("ImageButton") then
					local function clickedItem()
						local default = "Shovel"
						if gameStats:FindFirstChild(item.Name,true).Parent.Name == "PetStats" then
							default = "Pet"
						end
						if mf:FindFirstChild("DisplayImage") then
							mf:FindFirstChild("DisplayImage"):Destroy()
						end
						local vpcl = item.ViewportFrame:Clone()
						vpcl.Name = "DisplayImage"
						vpcl.Parent = mf
						vpcl.Position = UDim2.new(0.76, 0,0.27, 0)
						vpcl.Size = UDim2.new(0.158,0,0.217,0)
						rotateViewport(vpcl)
						mf.Power.Text = "Power of this " .. default .. ": " .. numAbb(gameStats:FindFirstChild(item.Name,true).Damage.Value*dmgMultiple)
						mf.Cost.Text = "Cost: " .. numAbb(gameStats:FindFirstChild(item.Name,true).Cost.Value)
						mf:FindFirstChildWhichIsA("IntValue").Value = gameStats:FindFirstChild(item.Name,true).Cost.Value
						mf:FindFirstChildWhichIsA("IntValue").Name = item.Name
					end
					local tempCon = item.MouseButton1Click:Connect(clickedItem)
					table.insert(shopConnections, tempCon)
				end
			end
		else
			v.Visible = false
		end
	end
end

function expReq(lvl)
	return 7*(lvl*lvl)-7*lvl+50
end

function updateUI(uiToShow)
	if uiToShow ~= nil and (uiToShow == "Gold_1") then
		if playerStats[uiToShow]-prevStats[uiToShow] > 0 then
			local ui = repS.RepItems:FindFirstChild(uiToShow):Clone()
			local tempVal = numAbb(math.floor(playerStats[uiToShow]-prevStats[uiToShow]))
			ui.Parent = effectsUI.Frame.EffectsFrame
			ui.Txt.Text = "+"
			ui.UiVal.Text = tempVal
			spawn(function()
				if uiToShow == "Gold_1" then
					tweenGuiObj(ui,UDim2.new(0.471,0,0.142,0),false,Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
					wait(1)
					tweenGuiObj(ui,UDim2.new(0,0,0,0),UDim2.new(0.204,-30,0.486,-20),Enum.EasingDirection.In,Enum.EasingStyle.Linear,1)
					wait(1)
					goldUI.ExteriorUI.Coins.Count.Text = numAbb(playerStats["Gold_1"])
					ui:Destroy()
				end
			end)
			prevStats["Gold_1"] = playerStats["Gold_1"]
		else
			goldUI.ExteriorUI.Coins.Count.Text = numAbb(playerStats["Gold_1"])
			prevStats["Gold_1"] = playerStats["Gold_1"]
		end
	elseif uiToShow ~= nil and ((uiToShow == "Level") or (uiToShow == "Experience") or (uiToShow == "Gems")) then
		if uiToShow == "Level" then
			if playerStats["Level"] ~= 1 then
				local ui = repS.RepItems:FindFirstChild(uiToShow):Clone()
				ui.Parent = effectsUI.Frame.EffectsFrame
				ui.UiVal.Text = "Lvl Up: " .. playerStats[uiToShow]
				spawn(function()
					tweenGuiObj(ui,UDim2.new(0.471,0,0.142,0),false,Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.5)
					wait(1)
					tweenGuiObj(ui,UDim2.new(0,0,0,0),false,Enum.EasingDirection.In,Enum.EasingStyle.Linear,1)
					wait(1)
					ui:Destroy()
				end)
			end
		end
		if uiToShow == "Gems" then
			if playerStats[uiToShow]-prevStats[uiToShow] > 0 then
				local ui = repS.RepItems:FindFirstChild(uiToShow):Clone()
				local tempVal = numAbb(math.floor(playerStats[uiToShow]-prevStats[uiToShow]))
				ui.Parent = effectsUI.Frame.EffectsFrame
				ui.UiVal.Text = tempVal
				spawn(function()
					tweenGuiObj(ui,UDim2.new(0.471,0,0.142,0),false,Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
					wait(1)
					tweenGuiObj(ui,UDim2.new(0,0,0,0),UDim2.new(0.087, 0,0.525, 0),Enum.EasingDirection.In,Enum.EasingStyle.Linear,1)
					wait(1)
					gemsUI.ExteriorUI.Gems.Count.Text = numAbb(playerStats["Gems"])
					ui:Destroy()
				end)
				prevStats["Gems"] = playerStats["Gems"]
			else
				gemsUI.ExteriorUI.Gems.Count.Text = numAbb(playerStats["Gems"])
				prevStats["Gems"] = playerStats["Gems"]
			end
			prevStats["Gems"] = playerStats["Gems"]
		end
	end
	if firstLoad == true then
		prevStats["Experience"] = playerStats["Experience"]
		goldUI.ExteriorUI.Coins.Count.Text = numAbb(playerStats["Gold_1"])
		gemsUI.ExteriorUI.Gems.Count.Text = numAbb(playerStats["Gems"])
		prevStats["Gold_1"] = playerStats["Gold_1"]
		prevStats["Gems"] = playerStats["Gems"]
	end
	statsUI.MainFrame.MainUI.lvl.Text = "Current Level: " .. numAbb(playerStats["Level"])
	if playerStats["Level"] == currentLevelCap then
		local capMinusOne = currentLevelCap-1
		local maxExp = 4*(capMinusOne*capMinusOne)-4*capMinusOne+50
		statsUI.MainFrame.MainUI.exp.Text = "Experience: " .. maxExp .. "/" .. maxExp .. " [MAX]"
	else
		statsUI.MainFrame.MainUI.exp.Text = "Experience: " .. playerStats["Experience"] .. "/" .. expReq(playerStats["Level"])
	end
	statsUI.MainFrame.MainUI.treasure.Text = "Treasure Found: " .. numAbb(playerStats["MatsCollected"])
end

function loadUI()
	----- Player Stats -----
	updateUI()
	goldUI.ExteriorUI.BuyCoins.MouseButton1Click:Connect(function()
		if guiDebounce and (not warningDebounce or warningUI.Frame.CodeBox.Visible) then
			if warningUI.Frame.CodeBox.Visible then
				warningDebounce = false
			end
			guiDebounce = false
			spawn(function()
				wait(0.25)
				guiDebounce = true
			end)
			if not goldUI.MainFrame.Visible then
				devProdUI(goldUI, "Gold_1")
			else
				closeOtherUI()
			end
		end
	end)
	
	gemsUI.ExteriorUI.BuyGems.MouseButton1Click:Connect(function()
		if guiDebounce and (not warningDebounce or warningUI.Frame.CodeBox.Visible) then
			if warningUI.Frame.CodeBox.Visible then
				warningDebounce = false
			end
			guiDebounce = false
			spawn(function()
				wait(0.25)
				guiDebounce = true
			end)
			if not gemsUI.MainFrame.Visible then
				devProdUI(gemsUI, "Gems")
			else
				closeOtherUI()
			end
			
		end
	end)
	
	inventoryUI.Options.Stats.StatsButton.MouseButton1Click:Connect(function()
		if guiDebounce and (not warningDebounce or warningUI.Frame.CodeBox.Visible) then
			if warningUI.Frame.CodeBox.Visible then
				warningDebounce = false
			end
			guiDebounce = false
			spawn(function()
				wait(0.25)
				guiDebounce = true
			end)
			if not statsUI.MainFrame.Visible then
				closeOtherUI()
				local dmg = getStats:InvokeServer("getDamage")
				local pDmg = petStats:InvokeServer("petDamage")
				statsUI.MainFrame.MainUI.dmg.Text = "Damage per Second: " .. numAbb((math.floor(dmg)+math.floor(pDmg/1.5))*dmgMultiple)
				local tempDate = playerStats["TimePlayed"]
				local tempMonth = getDate(tempDate,month,"Months")
				tempDate -= tempMonth[2]
				local tempDay = getDate(tempDate,day,"Days")
				tempDate -= tempDay[2]
				local tempHour = getDate(tempDate,hour,"Hours")
				tempDate -= tempHour[2]
				updateTotalPetCount()
				statsUI.MainFrame.MainUI.time.Text = "Time Played:  " .. tempMonth[1] .. " | " .. tempDay[1] .. " | " .. tempHour[1]
				tweenGuiObj(statsUI.MainFrame,false,UDim2.new(0.02,-10,1,-10),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
				statsUI.MainFrame.MainUI.PlayerDisplay.Image = playerImg
				statsUI.MainFrame.Visible = true
			else
				closeOtherUI()
			end
		end
	end)
	
	inventoryUI.Options.Twitter.TwitterButton.MouseButton1Click:Connect(function()
		if guiDebounce and (not warningDebounce or warningUI.Frame.CodeBox.Visible) then
			if warningUI.Frame.CodeBox.Visible then
				warningDebounce = false
			end
			if not warningUI.Frame.CodeBox.Visible then
				closeOtherUI()
				displayCodesWarning("Follow @NastaStudiosRB on Twitter for Epic Rewards!")
			else
				closeOtherUI()
			end
		end
	end)
	
	inventoryUI.Options.Gamepass.RobuxButton.MouseButton1Click:Connect(function()
		if guiDebounce and (not warningDebounce or warningUI.Frame.CodeBox.Visible) then
			if warningUI.Frame.CodeBox.Visible then
				warningDebounce = false
			end
			guiDebounce = false
			spawn(function()
				wait(0.25)
				guiDebounce = true
			end)
			if not gamepassUI.MainFrame.Visible then
				closeOtherUI()
				gamepassUI.MainFrame.Cost.Text = ""
				gamepassUI.MainFrame.Description.Text = ""
				gamepassUI.MainFrame.DisplayImage.Image = ""
				local shopFrame = gamepassUI.MainFrame.GamepassShop
				for _,btn in pairs(shopFrame:GetChildren()) do
					if btn:IsA("ImageButton") then
						local function clickedItem()
							gamepassUI.MainFrame.Cost.Text = "Robux: " .. btn.RobuxCost.Value
							gamepassUI.MainFrame.Description.Text = btn.Description.Value
							gamepassUI.MainFrame.CurrentItem.Value = btn.ProductID.Value
							gamepassUI.MainFrame.DisplayImage.Image = btn.ImageLabel.Image
						end
						local tempCon = btn.MouseButton1Click:Connect(clickedItem)
						table.insert(shopConnections, tempCon)
					end
				end

				local function clickedItem()
					local success, message = pcall(function()
						hasPass = MarketPlaceService:UserOwnsGamePassAsync(game.Players.LocalPlayer.UserId, gamepassUI.MainFrame.CurrentItem.Value)
					end)
					if not success then
						return
					end
					if hasPass then
						displayWarning("You already own this Gamepass")
					else
						MarketPlaceService:PromptGamePassPurchase(game.Players.LocalPlayer, gamepassUI.MainFrame.CurrentItem.Value)
					end
				end
				local tempCon = gamepassUI.MainFrame.BuyButton.MouseButton1Click:Connect(clickedItem)
				table.insert(shopConnections, tempCon)

				tweenGuiObj(gamepassUI.MainFrame,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
				gamepassUI.MainFrame.Visible = true
			else
				closeOtherUI()
			end
		end
	end)
	
	inventoryUI.MainFrame.HatsButton.MouseButton1Click:Connect(function()
		if inventoryType == "Pets" or inventoryType == "Shovels" then
			inventoryType = "Hats"
			hatsInventoryDisplay()
		end
	end)
	
	inventoryUI.MainFrame.ShovelsButton.MouseButton1Click:Connect(function()
		if inventoryType == "Hats" or inventoryType == "Pets" then
			inventoryType = "Shovels"
			shovelsInventoryDisplay()
			
		end
	end)
	
	inventoryUI.MainFrame.PetsButton.MouseButton1Click:Connect(function()
		if inventoryType == "Hats" or inventoryType == "Shovels" then
			inventoryType = "Pets"
			petsInventoryDisplay()
		end
	end)
	
	inventoryUI.Options.Bottom.InventoryButton.MouseButton1Click:Connect(function()
		if guiDebounce and (not warningDebounce or warningUI.Frame.CodeBox.Visible) then
			if warningUI.Frame.CodeBox.Visible then
				warningDebounce = false
			end
			guiDebounce = false
			spawn(function()
				wait(0.25)
				guiDebounce = true
			end)
			if not inventoryUI.MainFrame.Visible then
				closeOtherUI()
				tweenGuiObj(inventoryUI.MainFrame,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
				inventoryUI.MainFrame.Visible = true
				local mf = inventoryUI.MainFrame
				if inventoryType == "Pets" then
					petsInventoryDisplay()
				elseif inventoryType == "Hats" then
					hatsInventoryDisplay()
				elseif inventoryType == "Shovels" then
					shovelsInventoryDisplay()
				end
			else
				closeOtherUI()
			end
		end
	end)
	inventoryUI.Options.Top.SettingsButton.MouseButton1Click:Connect(function()
		if guiDebounce and (not warningDebounce or warningUI.Frame.CodeBox.Visible) then
			if warningUI.Frame.CodeBox.Visible then
				warningDebounce = false
			end
			guiDebounce = false
			spawn(function()
				wait(0.25)
				guiDebounce = true
			end)
			if not settingsUI.MainFrame.Visible then
				closeOtherUI()
				local function clickedItem()
					musicOn = false
					player.PlayerGui.MainSound.Volume = 0
				end
				local tempCon = settingsUI.MainFrame.OffButton.MouseButton1Click:Connect(clickedItem)
				table.insert(shopConnections,tempCon)

				local function clickedItem()
					musicOn = true
					player.PlayerGui.MainSound.Volume = 0.3
				end
				local tempCon = settingsUI.MainFrame.OnButton.MouseButton1Click:Connect(clickedItem)
				table.insert(shopConnections,tempCon)
				tweenGuiObj(settingsUI.MainFrame,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
				settingsUI.MainFrame.Visible = true
			else
				closeOtherUI()
			end
		end
	end)
end

function teleportUiActivate()
	closeOtherUI()
	local tpList = {
		["Spawn"] = game.Workspace.OtherUtilities.EdgeTeleporter.TargetPad.CFrame * CFrame.new(0,2,0)
	}
	local function BindButtonToFunction(btn, func)
		btn.MouseButton1Click:Connect(func)
	end

	for _, v in pairs(teleportUI.MainFrame:GetDescendants()) do
		if v:IsA("TextButton") or v:IsA("ImageButton") then
			BindButtonToFunction(v, function()
				if tpList[v.Parent.Parent.Name] then
					if walkingToTarget then
						walkingToTarget = false
						if currentDigUI then
							currentDigUI:Destroy()
						end
						digR:FireServer("Stop")
					end
					if diggingInProcess then
						diggingInProcess = false
						digTrack:Stop()
					end
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = tpList[v.Parent.Parent.Name]
					closeOtherUI()
				end
			end)
		end
	end
	tweenGuiObj(teleportUI.MainFrame,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
	teleportUI.MainFrame.Visible = true
end

function shovelsInventoryDisplay()
	selectedInvenItem = nil
	for _,con in pairs(invenConnections) do
		con:Disconnect()
	end
	local mf = inventoryUI.MainFrame
	if mf:FindFirstChild("DisplayImage") then
		mf:FindFirstChild("DisplayImage"):Destroy()
	end
	mf.Shovelsunequip.Image = greenButtonImg
	mf.Shovelsunequip.TextLabel.TextColor3 = Color3.fromRGB(32, 104, 37)
	mf.Shovelsunequip.TextLabel.Text = "EQUIP"
	mf.Evolve.ImageTransparency = 1
	mf.Evolve.TextLabel.TextTransparency = 1
	
	mf.ShovelsInventory.Visible = true
	mf.Inventory.Visible = false
	mf.HatsInventory.Visible = false
	
	mf.shovelsTitle.TextTransparency = 0
	mf.petsTitle.TextTransparency = 0.65
	mf.hatsTitle.TextTransparency = 0.65
	
	mf.unEquip.Visible = false
	mf.HatsunEquip.Visible = false
	mf.Shovelsunequip.Visible = true
	
	mf.Level.Text = ""
	mf.Damage.Text = ""
	mf.Boost.Text = ""
	for _,btn in pairs(mf.ShovelsInventory:GetChildren()) do
		if btn:IsA("ImageButton") then
			local function clickedItem()
				if mf:FindFirstChild("DisplayImage") then
					mf:FindFirstChild("DisplayImage"):Destroy()
				end
				if btn:FindFirstChild("Equipped") then
					mf.Shovelsunequip.Image = redButtonImg
					mf.Shovelsunequip.TextLabel.TextColor3 = Color3.fromRGB(86, 13, 13)
					mf.Shovelsunequip.TextLabel.Text = "EQUIPPED"
				else
					mf.Shovelsunequip.Image = greenButtonImg
					mf.Shovelsunequip.TextLabel.TextColor3 = Color3.fromRGB(32, 104, 37)
					mf.Shovelsunequip.TextLabel.Text = "EQUIP"
				end
				selectedInvenItem = btn
				local vpcl = btn.ViewportFrame:Clone()
				vpcl.Name = "DisplayImage"
				vpcl.Parent = mf
				vpcl.Position = UDim2.new(0.76, 0,0.29, 0)
				vpcl.Size = UDim2.new(0.158,0,0.217,0)
				rotateViewport(vpcl)
				mf.Level.Text = btn.Name
				if repS.GameStats.ShovelStats:FindFirstChild(btn.Name).Damage:IsA("StringValue") then
					mf.Damage.Text = repS.GameStats.ShovelStats:FindFirstChild(btn.Name).Damage.Value
				else
					mf.Damage.Text = "Damage: " .. numAbb(repS.GameStats.ShovelStats:FindFirstChild(btn.Name).Damage.Value)
				end
			end
			local tempCon = btn.MouseButton1Click:Connect(clickedItem)
			table.insert(invenConnections, tempCon)
			local function clickedUnEquip()
				if mf:FindFirstChild("DisplayImage") and selectedInvenItem ~= nil and equipDebounce then
					equipDebounce = false
					if not selectedInvenItem:FindFirstChild("Equipped") and not diggingInProcess then
						for _,v in pairs(mf.ShovelsInventory:GetDescendants()) do
							if v.Name == "Equipped" then
								v:Destroy()
							end
						end
						local eq = repS.RepItems.Equipped:Clone()
						eq.Parent = selectedInvenItem
						petAddRemove:FireServer("AddShovel",selectedInvenItem.Name)
						
					end
					if selectedInvenItem ~= nil then
						if selectedInvenItem:FindFirstChild("Equipped") then
							mf.Shovelsunequip.Image = redButtonImg
							mf.Shovelsunequip.TextLabel.TextColor3 = Color3.fromRGB(86, 13, 13)
							mf.Shovelsunequip.TextLabel.Text = "EQUIPPED"
						else
							mf.Shovelsunequip.Image = greenButtonImg
							mf.Shovelsunequip.TextLabel.TextColor3 = Color3.fromRGB(32, 104, 37)
							mf.Shovelsunequip.TextLabel.Text = "EQUIP"
						end
					end
					spawn(function()
						wait(1)
						equipDebounce = true
					end)
				end
			end
			local tmpCon = mf.Shovelsunequip.MouseButton1Click:Connect(clickedUnEquip)
			table.insert(invenConnections, tempCon)
		end
	end

end

function hatsInventoryDisplay()
	selectedInvenItem = nil
	for _,con in pairs(invenConnections) do
		con:Disconnect()
	end
	local mf = inventoryUI.MainFrame
	if mf:FindFirstChild("DisplayImage") then
		mf:FindFirstChild("DisplayImage"):Destroy()
	end
	mf.HatsunEquip.Image = greenButtonImg
	mf.HatsunEquip.TextLabel.TextColor3 = Color3.fromRGB(32, 104, 37)
	mf.HatsunEquip.TextLabel.Text = "EQUIP"
	mf.HatsInventory.Visible = true
	mf.Inventory.Visible = false
	mf.ShovelsInventory.Visible = false
	mf.Evolve.ImageTransparency = 1
	mf.Evolve.TextLabel.TextTransparency = 1
	mf.hatsTitle.TextTransparency = 0
	mf.petsTitle.TextTransparency = 0.65
	mf.shovelsTitle.TextTransparency = 0.65
	mf.unEquip.Visible = false
	mf.Shovelsunequip.Visible = false
	mf.HatsunEquip.Visible = true
	mf.Level.Text = ""
	mf.Damage.Text = ""
	mf.Boost.Text = ""
	for _,btn in pairs(mf.HatsInventory:GetChildren()) do
		if btn:IsA("ImageButton") then
			local function clickedItem()
				if mf:FindFirstChild("DisplayImage") then
					mf:FindFirstChild("DisplayImage"):Destroy()
				end
				if btn:FindFirstChild("Equipped") then
					mf.HatsunEquip.Image = redButtonImg
					mf.HatsunEquip.TextLabel.TextColor3 = Color3.fromRGB(86, 13, 13)
					mf.HatsunEquip.TextLabel.Text = "UNEQUIP"
				else
					mf.HatsunEquip.Image = greenButtonImg
					mf.HatsunEquip.TextLabel.TextColor3 = Color3.fromRGB(32, 104, 37)
					mf.HatsunEquip.TextLabel.Text = "EQUIP"
				end
				selectedInvenItem = btn
				local vpcl = btn.ViewportFrame:Clone()
				vpcl.Name = "DisplayImage"
				vpcl.Parent = mf
				vpcl.Position = UDim2.new(0.76, 0,0.27, 0)
				vpcl.Size = UDim2.new(0.158,0,0.217,0)
				rotateViewport(vpcl)
				mf.Level.Text = btn.Name
			end
			local tempCon = btn.MouseButton1Click:Connect(clickedItem)
			table.insert(invenConnections, tempCon)
			local function clickedUnEquip()
				if mf:FindFirstChild("DisplayImage") and selectedInvenItem ~= nil and equipDebounce then
					equipDebounce = false
					if selectedInvenItem:FindFirstChild("Equipped") then
						local hatId = ""
						selectedInvenItem:FindFirstChild("Equipped"):Destroy()
						petAddRemove:FireServer("RemoveHat",selectedInvenItem.Name)
						equippedHatsCount -= 1
					elseif not selectedInvenItem:FindFirstChild("Equipped") then
						if equippedHatsCount < maxHatCount then
							equippedHatsCount += 1
							local eq = repS.RepItems.Equipped:Clone()
							eq.Parent = selectedInvenItem
							petAddRemove:FireServer("AddHat",selectedInvenItem.Name)
						else
							displayWarning("Maximum Hats reached!")
						end
					end
					if selectedInvenItem ~= nil then
						if selectedInvenItem:FindFirstChild("Equipped") then
							mf.HatsunEquip.Image = redButtonImg
							mf.HatsunEquip.TextLabel.TextColor3 = Color3.fromRGB(86, 13, 13)
							mf.HatsunEquip.TextLabel.Text = "UNEQUIP"
						else
							mf.HatsunEquip.Image = greenButtonImg
							mf.HatsunEquip.TextLabel.TextColor3 = Color3.fromRGB(32, 104, 37)
							mf.HatsunEquip.TextLabel.Text = "EQUIP"
						end
					end
					spawn(function()
						wait(1)
						equipDebounce = true
					end)
				end
			end
			local tmpCon = mf.HatsunEquip.MouseButton1Click:Connect(clickedUnEquip)
			table.insert(invenConnections, tempCon)
		end
	end
end

function petsInventoryDisplay()
	selectedInvenItem = nil
	for _,con in pairs(invenConnections) do
		con:Disconnect()
	end
	local mf = inventoryUI.MainFrame
	if mf:FindFirstChild("DisplayImage") then
		mf:FindFirstChild("DisplayImage"):Destroy()
	end
	mf.HatsunEquip.Image = greenButtonImg
	mf.unEquip.TextLabel.TextColor3 = Color3.fromRGB(32, 104, 37)
	mf.unEquip.TextLabel.Text = "EQUIP"
	mf.HatsInventory.Visible = false
	mf.Inventory.Visible = true
	mf.ShovelsInventory.Visible = false
	mf.Evolve.ImageTransparency = 0.65
	mf.Evolve.TextLabel.TextTransparency = 0.65
	mf.hatsTitle.TextTransparency = 0.65
	mf.shovelsTitle.TextTransparency = 0.65
	mf.petsTitle.TextTransparency = 0
	mf.unEquip.Visible = true
	mf.HatsunEquip.Visible = false
	mf.Shovelsunequip.Visible = false
	mf.Level.Text = ""
	for _,btn in pairs(mf.Inventory:GetChildren()) do
		if btn:IsA("ImageButton") then
			local function clickedItem()
				evolveList = {}
				if mf:FindFirstChild("DisplayImage") then
					mf:FindFirstChild("DisplayImage"):Destroy()
				end

				for _,pet in pairs(mf.Inventory:GetChildren()) do
					if pet:IsA("ImageButton") and pet.Name == btn.Name and pet.Level.Value == btn.Level.Value and btn.Level.Value < 5 then
						table.insert(evolveList,pet:FindFirstChildWhichIsA("ViewportFrame"))
						if #evolveList == 3 then
							mf.Evolve.ImageTransparency = 0
							mf.Evolve.TextLabel.TextTransparency = 0
							break
						end
					end
				end
				if #evolveList < 3 then
					mf.Evolve.ImageTransparency = 0.65
					mf.Evolve.TextLabel.TextTransparency = 0.65
				end
				if btn:FindFirstChild("Equipped") then
					mf.unEquip.Image = redButtonImg
					mf.unEquip.TextLabel.TextColor3 = Color3.fromRGB(86, 13, 13)
					mf.unEquip.TextLabel.Text = "UNEQUIP"
				else
					mf.unEquip.Image = greenButtonImg
					mf.unEquip.TextLabel.TextColor3 = Color3.fromRGB(32, 104, 37)
					mf.unEquip.TextLabel.Text = "EQUIP"
				end
				selectedInvenItem = btn
				local vpcl = btn.ViewportFrame:Clone()
				vpcl.Name = "DisplayImage"
				vpcl.Parent = mf
				vpcl.Position = UDim2.new(0.76, 0,0.27, 0)
				vpcl.Size = UDim2.new(0.158,0,0.217,0)
				rotateViewport(vpcl)
				local dmgAmount = gameStats:FindFirstChild(btn.Name,true).Damage.Value
				local boostAmount = gameStats:FindFirstChild(btn.Name,true).Boost.Value

				mf.Damage.Text = "Damage: " .. numAbb(math.floor(dmgAmount + dmgAmount*(btn.Level.Value/10))*dmgMultiple)
				mf.Boost.Text = "Boost: " .. numAbb(math.floor(boostAmount + boostAmount*((btn.Level.Value-1)/10)))
				mf.Level.Text = "Level: " .. btn.Level.Value
				mf:FindFirstChildWhichIsA("IntValue").Value = btn.Level.Value
				mf:FindFirstChildWhichIsA("IntValue").Name = btn.Name
			end
			local tempCon = btn.MouseButton1Click:Connect(clickedItem)
			table.insert(invenConnections, tempCon)
			local function clickEvolve()
				if mf:FindFirstChild("DisplayImage") and selectedInvenItem ~= nil and #evolveList == 3 and not currentlyEvolving then
					currentlyEvolving = true
					local petName = selectedInvenItem.Name
					local currentLvl = selectedInvenItem.Level.Value + 1
					local bought = buySell:InvokeServer("EvolvePet",petName,currentLvl)
					if bought then
						local vpList = {}
						local dmgAmount = gameStats:FindFirstChild(selectedInvenItem.Name,true).Damage.Value
						local boostAmount = gameStats:FindFirstChild(selectedInvenItem.Name,true).Boost.Value
						local currentBoost = numAbb(math.floor(boostAmount + boostAmount*((btn.Level.Value-1)/10)))
						local currentDmg = numAbb(math.floor(dmgAmount + dmgAmount*(currentLvl/10))*dmgMultiple)
						for petId,petBtn in pairs(petList) do
							for _,v in pairs(evolveList) do
								if petBtn == v.Parent then
									petAddRemove:FireServer("Remove",petId,petName,nil,nil,petList[petId].Level.Value)
									equippedPetCount -=1
									petList[petId] = nil
									local vpCl = v:Clone()
									table.insert(vpList,vpCl)
									table.remove(evolveList,table.find(evolveList,v))
									v.Parent:Destroy()
								end
							end
						end
						for _,v in pairs(evolveList) do
							local vpCl = v:Clone()
							table.insert(vpList,vpCl)
							v.Parent:Destroy()
						end
						
						local itemName = petName
						if gameStats.PetStats:FindFirstChild(itemName) then
							local viewport = repS.Viewports:FindFirstChild(itemName):Clone()
							local lvl = Instance.new("IntValue")
							lvl.Name = "Level"
							lvl.Parent = viewport
							lvl.Value = currentLvl
							viewport.Parent = inventoryUI.MainFrame.Inventory
						end
						warningUI.Frame.Title.Text = "EVOLUTION"
						for _,vp in pairs(vpList) do
							for _,ei in pairs(warningUI.Frame:GetChildren()) do
								if string.find(ei.Name,"EvolveImage") and not ei:FindFirstChildWhichIsA("ViewportFrame") then
									vp.Parent = ei
									vp.Size = UDim2.new(1.7,0,1.7,0)
									vp.Position = UDim2.new(-0.35,0,-0.35,0)
									spawn(function()
										for i = 1,15 do
											ei.Rotation = 20
											wait(0.1)
											ei.Rotation = -20
											wait(0.1)
										end
										ei.Rotation = 0
										if ei.Name ~= "EvolveImageMid" then
											tweenGuiObj(ei,false,warningUI.Frame.EvolveImageMid.Position,Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.5)
											wait(0.6)
											ei:FindFirstChildWhichIsA("ViewportFrame"):Destroy()
											if ei.Name == "EvolveImageLeft" then
												ei.Position = UDim2.new(0.057, 0,0.418, 0)
											elseif ei.Name == "EvolveImage" then
												ei.Position = UDim2.new(0.681, 0,0.415, 0)
											end
										else
											wait(1.2)
											tweenGuiObj(ei,false,warningUI.Frame.EvolveImageLeft.Position,Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.5)
											spawn(function()
												local model = ei:FindFirstChildWhichIsA("ViewportFrame"):FindFirstChildWhichIsA("Model")
												for i = 1,145 do
													wait()
													if model ~= nil then
														model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame * CFrame.Angles(0,math.rad(2),0))
													end
												end
												model.Parent:Destroy()
												warningUI.Frame.Lvl.Text = ""
												warningUI.Frame.Boost.Text = ""
												warningUI.Frame.Damage.Text = ""
												warningUI.Frame.Title.Text = "WARNING"
												ei.Position = UDim2.new(0.372, 0,0.415, 0)
											end)
											wait(0.6)
											local lvlText = "Level: " .. currentLvl
											local boostText = "Boost: " .. currentBoost
											local dmgText = "Damage: " .. currentDmg
											currentlyEvolving = false
											spawn(function()
												for i = 1,string.len(lvlText) do
													wait(0.06)
													warningUI.Frame.Lvl.Text = warningUI.Frame.Lvl.Text .. string.sub(lvlText,i,i)
												end
											end)
											spawn(function()
												for i = 1,string.len(boostText) do
													wait(0.06)
													warningUI.Frame.Boost.Text = warningUI.Frame.Boost.Text .. string.sub(boostText,i,i)
												end
											end)
											spawn(function()
												for i = 1,string.len(dmgText) do
													wait(0.06)
													warningUI.Frame.Damage.Text = warningUI.Frame.Damage.Text .. string.sub(dmgText,i,i)
												end
											end)
										end
									end)
									break
								end
							end
						end
						closeOtherUI()
						displayWarning("","Evolution")
					else
						displayWarning("Pet Evolution Failed. Rejoin if your inventory has changed & report bug.")
					end
				end
			end
			local tmpCon = mf.Evolve.MouseButton1Click:Connect(clickEvolve)
			table.insert(invenConnections, tempCon)

			local function clickedUnEquip()
				if mf:FindFirstChild("DisplayImage") and selectedInvenItem ~= nil and equipDebounce then
					equipDebounce = false
					if selectedInvenItem:FindFirstChild("Equipped") then
						local petId = ""
						for i,v in pairs(petList) do
							if v == selectedInvenItem then
								petId = i
								petList[i] = nil
								break
							end
						end
						local petName = selectedInvenItem.Name
						selectedInvenItem:FindFirstChild("Equipped"):Destroy()
						petAddRemove:FireServer("Remove",petId,petName,nil,nil,selectedInvenItem.Level.Value)


						equippedPetCount -= 1
					elseif not selectedInvenItem:FindFirstChild("Equipped") then
						if equippedPetCount < maxPetCount then
							equippedPetCount += 1
							local eq = repS.RepItems.Equipped:Clone()
							eq.Parent = selectedInvenItem
							local dmgAmount = gameStats:FindFirstChild(selectedInvenItem.Name,true).Damage.Value
							local boostAmount = gameStats:FindFirstChild(selectedInvenItem.Name,true).Boost.Value
							local petDmg = math.floor(dmgAmount + dmgAmount*(selectedInvenItem.Level.Value/10))
							local petBoost = math.floor(boostAmount + boostAmount*((selectedInvenItem.Level.Value-1)/10))
							local petId = player.UserId
							local ltrs = {"A","B","C","D","E","F","G","Z","X","Y","W","V","S","T"}
							for i = 1,9 do
								if i%2 == 0 then
									petId = petId .. math.random(i,9)
								else
									petId = petId .. ltrs[math.random(i,14)]
								end
							end
							petList[petId] = selectedInvenItem
							petAddRemove:FireServer("Add",petId,mf:FindFirstChild("DisplayImage"):FindFirstChildWhichIsA("Model").Name,petDmg,petBoost,selectedInvenItem.Level.Value)
						else
							displayWarning("Maximum pets reached! Buy Gamepasses to unlock more Pets")
						end
					end

					if selectedInvenItem ~= nil then
						if selectedInvenItem:FindFirstChild("Equipped") then
							mf.unEquip.Image = redButtonImg
							mf.unEquip.TextLabel.TextColor3 = Color3.fromRGB(86, 13, 13)
							mf.unEquip.TextLabel.Text = "UNEQUIP"
						else
							mf.unEquip.Image = greenButtonImg
							mf.unEquip.TextLabel.TextColor3 = Color3.fromRGB(32, 104, 37)
							mf.unEquip.TextLabel.Text = "EQUIP"
						end
					end
					spawn(function()
						wait(1)
						equipDebounce = true
					end)
				end
			end
			local tmpCon = mf.unEquip.MouseButton1Click:Connect(clickedUnEquip)
			table.insert(invenConnections, tempCon)
		end
	end
end

function updateTotalPetCount()
	local totalPetCount = 0
	for _,v in pairs(inventoryUI.MainFrame.Inventory:GetChildren()) do
		if v:IsA("ImageButton") then
			totalPetCount += 1
		end
	end
	statsUI.MainFrame.MainUI.pets.Text = "Pets Owned: " .. totalPetCount
end

----- Client Update -----
updClient.OnClientEvent:Connect(function(cmd,item)
	if cmd == "Door" then
		item.Color = Color3.fromRGB(255,255,255)
		item.Material = Enum.Material.ForceField
		item.CanCollide = false
		for _,v in pairs(item:GetChildren()) do
			if v:IsA("SurfaceGui") then
				v:Destroy()
			end
		end
	elseif cmd == "AddPet" then
		addPet(item)
	elseif cmd == "AddShovel" then
		addShovel(item)
	elseif cmd == "Shovel" and item ~= nil and item == "S_Loading..." then
		print(item)
	elseif cmd == "TimePassed" then
		print("+30 Seconds")
	elseif cmd == "AddHat" and item ~= nil then
		addHat(item)
	elseif cmd == "Warn" then
		displayWarning(item)
	elseif cmd == "Gold_1" then
		updClient:FireServer("Gold_1",math.floor(goldInHand))
	elseif cmd == "Gems" then
		updClient:FireServer("Gems",math.floor(gemsInHand))
	elseif cmd == "+4 Pets" and getStats:InvokeServer("GamepassCheck",game.Players.LocalPlayer.UserId .. cmd .. item) then
		print("Successful Purchase!")
		maxPetCount += 4
	elseif cmd == "+8 Pets" and getStats:InvokeServer("GamepassCheck",game.Players.LocalPlayer.UserId .. cmd .. item) then
		print("Successful Purchase!")
		maxPetCount += 8
	elseif cmd == "Infinite Pets" and getStats:InvokeServer("GamepassCheck",game.Players.LocalPlayer.UserId .. cmd .. item) then
		print("Successful Purchase!")
		maxPetCount = 20
	elseif cmd == "x2 Damage" and getStats:InvokeServer("GamepassCheck",game.Players.LocalPlayer.UserId .. cmd .. item) then
		print("Successful Purchase!")
		dmgMultiple = 2
	elseif cmd == "x2 Damage Speed" and getStats:InvokeServer("GamepassCheck",game.Players.LocalPlayer.UserId .. cmd .. item) then
		print("Successful Purchase!")
		damageSpeedMultiple = 2
	elseif cmd == "x2 Walk Speed" and getStats:InvokeServer("GamepassCheck",game.Players.LocalPlayer.UserId .. cmd .. item) then
		print("Successful Purchase!")
		walkspeedMultiple = 2
		if player.Character then
			player.Character.Humanoid.WalkSpeed = baseWS * walkspeedMultiple
		end
	end
end)

for _,door in pairs(game.Workspace.Doors:GetChildren()) do
	if door:FindFirstChild("SurfaceGuiMain") ~= nil then
		local mf = door:FindFirstChild("SurfaceGuiMain"):FindFirstChild("MainFrame")
		local bf = door:FindFirstChild("SurfaceGuiMain"):FindFirstChild("BuyFrame")
		for _,btn in pairs(mf:GetChildren()) do
			if string.len(btn.Name) == 1 then
				btn.MouseButton1Click:Connect(function()
					local totalAmount = 0
					local doorCost = door.Cost.Value
					if tonumber(btn.Name)-1 == 0 then
						totalAmount = doorCost*0.1
					elseif tonumber(btn.Name)-1 == 1 then
						totalAmount = doorCost*0.2334
					elseif tonumber(btn.Name)-1 == 2 then
						totalAmount = doorCost*0.3667
					elseif tonumber(btn.Name)-1 == 3 then
						totalAmount = doorCost*0.6667
					elseif tonumber(btn.Name)-1 == 4 then
						totalAmount = doorCost*1.1
					elseif tonumber(btn.Name)-1 == 5 then
						totalAmount = doorCost*2.3334
					end
					goldInHand = totalAmount
					local doorDict =  doorListCheck()
					devProducts:FireServer(btn.ProductId.Value,doorDict)
				end)
			end
		end
		bf.BuyButton.MouseButton1Click:Connect(function()
			local bought = buySell:InvokeServer("BuyZone",door)
			if bought == false then
				local cg = getStats:InvokeServer("checkStat","Gold_1")
				spawn(function()
					wait(1)
					local doorDict =  doorListCheck()
					devProducts:FireServer(getDevProdId("GoldDoor",door.Cost.Value-cg),doorDict)
				end)
				displayWarning("Oh No! You are missing " .. numAbb(door.Cost.Value-cg) .. " Gold") -- \nYou can Claim Treasures or Purchase more Gold.
			else
				displayWarning("Congratulations! You have purchased " .. getStats:InvokeServer("checkStat","Zone"))
			end
		end)
	end
end

function devProdUI(guiObj, itemType)
	if not guiObj.MainFrame.Visible then
		closeOtherUI()
		local config
		if itemType == "Gold_1" then
			config = getDevProdId("GetGoldConfig")
		elseif itemType == "Gems" then
			config = getDevProdId("GetGemsConfig")
		end
		if config ~= {} then
			tweenGuiObj(guiObj.MainFrame,false,UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
			guiObj.MainFrame.Visible = true
			local mf = guiObj.MainFrame.InteriorUI
			local function clickedBuy()
				if mf.SelectedItem.Value ~= nil and mf.SelectedItem.Value ~= 0 then
					if mf.Parent.Parent.Name == "GoldUI" then
						goldInHand = mf.CAmnt.Value
					elseif mf.Parent.Parent.Name == "GemsUI" then
						gemsInHand = mf.CAmnt.Value
					end
					local doorDict =  doorListCheck()
					devProducts:FireServer(mf.SelectedItem.Value,doorDict)
				end
			end
			local tempCon1 = mf.BuyButton.MouseButton1Click:Connect(clickedBuy)
			table.insert(shopConnections, tempCon1)
			for _,item in pairs(guiObj.MainFrame.OptionsFrame:GetChildren()) do
				if item:IsA("ImageButton") then
					local function clickedItem()
						mf.DisplayImage.Image = item:FindFirstChildWhichIsA("ImageLabel").Image
						for _,v in pairs(config) do
							if tostring(v[1]) == item.Name then
								mf.CAmnt.Value = v[2]
								mf.Amount.Text = itemType .. ": " .. numAbb(v[2])
								mf:FindFirstChildWhichIsA("IntValue").Value = v[3]
								break
							end
						end
						mf.Cost.Text = "Robux: " .. numAbb(item.RobuxCost.Value)
					end
					local tempCon = item.MouseButton1Click:Connect(clickedItem)
					table.insert(shopConnections, tempCon)
				end
			end
		end
	end
end

function closeOtherUI()
	for _,con in pairs(shopConnections) do
		con:Disconnect()
	end
	selectedInvenItem = nil
	for _,con in pairs(invenConnections) do
		con:Disconnect()
	end
	if inventoryUI.MainFrame:FindFirstChild("DisplayImage") then
		inventoryUI.MainFrame:FindFirstChild("DisplayImage"):Destroy()
	end
	shopUI.MainFrame:FindFirstChildWhichIsA("IntValue").Value = 0
	shopUI.MainFrame:FindFirstChildWhichIsA("IntValue").Name = "CurrentItem"
	goldUI.MainFrame.InteriorUI.CAmnt.Value = 0
	goldUI.MainFrame.InteriorUI.SelectedItem.Value = 0
	gemsUI.MainFrame.InteriorUI.CAmnt.Value = 0
	gemsUI.MainFrame.InteriorUI.SelectedItem.Value = 0
	local function slideOutUI(guiObj,pos)
		tweenGuiObj(guiObj.MainFrame,false,pos,Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25)
		wait(0.25)
		guiObj.MainFrame.Visible = false
	end
	if warningUI.Frame.TryCodeButton.Visible then
		tweenGuiObj(warningUI.Frame,false,UDim2.new(0.5,0,1.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25)
		wait(0.5)
		warningUI.Frame.Title.Text = "Warning"
		warningUI.Frame.CodeBox.Visible = false
		warningUI.Frame.TryCodeButton.Visible = false
		warningUI.Frame.CodeDesc.Visible = false
		warningUI.Frame.CodeDesc.Text = ""
		warningDebounce = false
	end
	if goldUI.MainFrame.Visible then
		slideOutUI(goldUI,UDim2.new(-0.5,0,0.5,0))
	end
	if gemsUI.MainFrame.Visible then
		slideOutUI(gemsUI,UDim2.new(-0.5,0,0.5,0))
	end
	if statsUI.MainFrame.Visible then
		slideOutUI(statsUI,UDim2.new(-0.26,-10,1,-10))
	end
	if settingsUI.MainFrame.Visible then
		slideOutUI(settingsUI,UDim2.new(1.5,0,0.5,0))
	end
	if teleportUI.MainFrame.Visible then
		slideOutUI(teleportUI,UDim2.new(0.5,0,-0.4,0))
	end
	if gamepassUI.MainFrame.Visible then
		slideOutUI(gamepassUI,UDim2.new(0.5,0,-0.5,0))
	end
	if inventoryUI.MainFrame.Visible then
		slideOutUI(inventoryUI,UDim2.new(0.5,0,-0.5,0))
	end
	if shopUI.MainFrame.Visible then
		guiDisplay(shopUI,"Close")
	end
end

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

digR.OnClientEvent:Connect(function(cmd,treasurePart,zoneNum,partitions)
	if cmd == "StartProcess" and treasurePart then
		if currentDiggingUI ~= nil then
			currentDiggingUI:Destroy()
		end
		walkingToTarget = true
		--previousDiggingUI = currentDiggingUI
		local hui = healthUI:Clone()
		currentDigUI = hui
		currentDiggingUI = hui
		
		hui.Parent = treasurePart
		local hp
		local name
		local specialItem = false
		if treasurePart.Parent.Name == "TreasureModel" then
			hp = treasurePart.Parent.Parent.Stats:FindFirstChildWhichIsA("IntValue")
			name = treasurePart.Parent.Parent.Stats:FindFirstChildWhichIsA("StringValue").Value
		else
			hp = treasurePart.Parent.Stats:FindFirstChildWhichIsA("IntValue")
			name = treasurePart.Parent.Stats:FindFirstChildWhichIsA("StringValue").Value
		end
		if specialItem == false then
			hui.ImageLabel.Amount.Text = numAbb(hp.Value) .. " | " .. numAbb(zoneHealths[name][zoneNum])
			hp.Changed:Connect(function()
				if hui:FindFirstChild("ImageLabel") then
					hui.ImageLabel.Amount.Text = numAbb(hp.Value) .. " | " .. numAbb(zoneHealths[name][zoneNum])
				end
			end)
		end
	elseif cmd == "StartDigging" and not diggingInProcess then
		
		local splat = player.Character.LeftHand:FindFirstChild("MudSplatter")
		diggingInProcess = true
		digTrack:Play()
		spawn(function()
			while digTrack.IsPlaying do
				if digTrack.IsPlaying then
					if diggingInProcess then
						digSound()
					end
					wait((2*digTrack.Length)/5)
					if diggingInProcess then
						if splat ~= nil then
							splat.Enabled = true
						end
						wait(digTrack.Length/5)
						if splat ~= nil then
							splat.Enabled = false
						end
						wait((2*digTrack.Length)/5)
					else
						break
					end
				else
					break
				end
			end
		end)
		while diggingInProcess do
			for i = 1,20/damageSpeedMultiple do
				wait(0.05)
				if not diggingInProcess then
					return
				end
			end
			local dmg = math.floor(getStats:InvokeServer("getDamage")*dmgMultiple)
			local txt = repS.RepItems.DmgNum:Clone()
			txt.Position = UDim2.new(math.random(199,701)/1000,0,math.random(200,700)/1000,0)
			txt.Text = "-" .. numAbb(dmg)
			txt.Parent = effectsUI.Frame
			tweenGuiObj(txt,UDim2.new(0.079, 0,0.173, 0),UDim2.new(txt.Position.X.Scale+(math.random(-100,100)/1000),0,txt.Position.Y.Scale+0.1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,0.8)
			spawn(function()
				wait(1)
				for i = 1,10 do
					wait()
					txt.TextTransparency += 0.1
				end
				txt:Destroy()
			end)
			if currentDiggingUI ~= nil and currentDiggingUI.parent ~= nil and currentDiggingUI.Parent.Parent ~= nil then
				if currentDiggingUI.Parent.Parent.Name == "TreasureModel" then
					digR:FireServer("Damage",currentDiggingUI.Parent.Parent.Parent,dmg)
				else
					digR:FireServer("Damage",currentDiggingUI.Parent.Parent,dmg)
				end
			end
		end
	elseif cmd == "PetDigging" and treasurePart then
		local dmg = treasurePart*dmgMultiple
		local txt = repS.RepItems.DmgNum:Clone()
		txt.Position = UDim2.new(math.random(199,701)/1000,0,math.random(200,700)/1000,0)
		txt.Text = "-" .. numAbb(dmg)
		txt.Parent = effectsUI.Frame
		tweenGuiObj(txt,UDim2.new(0.0632, 0,0.1384, 0),UDim2.new(txt.Position.X.Scale+(math.random(-100,100)/1000),0,txt.Position.Y.Scale+0.1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,0.8)
		spawn(function()
			wait(0.65)
			for i = 1,10 do
				wait()
				txt.TextTransparency += 0.1
			end
			txt:Destroy()
		end)
		if currentDiggingUI and currentDiggingUI.Parent and currentDiggingUI.Parent.Parent and currentDiggingUI.Parent.Parent.Name == "TreasureModel" then
			digR:FireServer("Damage",currentDiggingUI.Parent.Parent.Parent,dmg)
		elseif currentDiggingUI and currentDiggingUI.Parent and currentDiggingUI.Parent.Parent and currentDiggingUI.Parent.Parent.Name ~= "TreasureModel" then
			digR:FireServer("Damage",currentDiggingUI.Parent.Parent,dmg)
		end
	elseif cmd == "StopDigging" and diggingInProcess then
		diggingInProcess = false
		digTrack:Stop()
	elseif cmd == "DestroyGUI" and treasurePart and treasurePart:FindFirstChildWhichIsA("BillboardGui") then
		treasurePart:FindFirstChildWhichIsA("BillboardGui"):Destroy()
	elseif cmd == "RewardPlayer" and treasurePart then
		local rewardAmount = rewStats:InvokeServer("conId",zoneNum)
		if rewardAmount ~= nil then
			local cf = treasurePart.CFrame
			local reward = rewardAmount[2]
			local rewardType = rewardAmount[1]
			for i = 1,partitions do
				spawn(function()
					if rewardType ~= "" then
						rewardBlastOut(cf,i,rewardType,math.floor(reward/partitions),zoneNum)
					end
				end)
			end
		else
			player:Kick("ID: T1; Please take a screenshot and post this in bug reports.")
		end
	end
end)

function rewardBlastOut(cf,inc,rewardType,rewSegAmount,valId)
	local item = repS.RepItems:FindFirstChild(rewardType .. "_RewardAsset"):Clone()
	local rewCollected = false
	item:SetPrimaryPartCFrame(cf*CFrame.new(0,1,0))
	item.Parent = game.Workspace
	local bv = Instance.new("BodyVelocity")
	bv.Parent = item.PrimaryPart
	local add = 0
	if rewardType == "Gems" then
		add = 25
	end
	if inc == 1 then
		setFalling(bv,Vector3.new(25,20,add),0.1)
		setFalling(bv,Vector3.new(0,-20,0),0.15)
	elseif inc == 2 then
		setFalling(bv,Vector3.new(-25,20,-add),0.1)
		setFalling(bv,Vector3.new(0,-20,0),0.15)
	elseif inc == 3 then
		setFalling(bv,Vector3.new(-add,20,25),0.1)
		setFalling(bv,Vector3.new(0,-20,0),0.15)
	elseif inc == 4 then
		setFalling(bv,Vector3.new(add,20,-25),0.1)
		setFalling(bv,Vector3.new(0,-20,0),0.15)
	end
	item.Part.CanCollide = true
	wait(0.1)
	item.PrimaryPart.Anchored = true
	bv:Destroy()
	spawn(function()
		rotateRewardPart(item)
	end)
	item.PrimaryPart.Touched:Connect(function(part)
		if part.Parent ~= nil and part.Parent:FindFirstChild("Humanoid") and rewCollected == false then
			rewCollected = true
			item:Destroy()
			if rewSegAmount == 0 then
				rewSegAmount = 1
			end
			spawn(function()
				if rewardType == "Gems" then
					gemSound()
				else
					coinSound()
				end
			end)
			updClient:FireServer("Reward" .. rewardType,rewSegAmount,player.UserId .. valId)
		end
	end)
	spawn(function()
		wait(3)
		if item ~= nil and item.PrimaryPart ~= nil and game.Players.LocalPlayer ~= nil then
			item:Destroy()
			if rewSegAmount == 0 then
				rewSegAmount = 1
			end
			spawn(function()
				if rewardType == "Gems" then
					gemSound()
				else
					coinSound()
				end
			end)
			updClient:FireServer("Reward" .. rewardType,rewSegAmount,player.UserId .. valId)
		end
	end)
end

function coinSound()
	local sound = Instance.new("Sound", game.Players.LocalPlayer)
	sound.SoundId = "rbxassetid://131323304"
	if not sound.IsLoaded then
		sound.Loaded:wait()
	end
	sound:Play()
	wait(1.5)
	sound:Destroy()
end

function gemSound()
	local sound = Instance.new("Sound", game.Players.LocalPlayer)
	sound.SoundId = "rbxassetid://3199238931"
	sound.Volume = 0.75
	if not sound.IsLoaded then
		sound.Loaded:wait()
	end
	sound:Play()
	wait(1.5)
	sound:Destroy()
end

function digSound()
	local sound = Instance.new("Sound", game.Players.LocalPlayer)
	sound.SoundId = "rbxassetid://185603034"
	sound.Volume = 0.75
	if not sound.IsLoaded then
		sound.Loaded:wait()
	end
	sound:Play()
	wait(2)
	sound:Destroy()
end

function setFalling(vel,vector,timer)
	vel.Velocity = vector
	wait(timer)
end

function rotateRewardPart(model)
	while model ~= nil do
		wait()
		if model and model.PrimaryPart then
			model.PrimaryPart.CFrame = model.PrimaryPart.CFrame * CFrame.Angles(0,math.rad(2),0)
		else
			return
		end
	end
end

function rotateViewport(vpcl)
	spawn(function()
		while vpcl ~= nil do
			wait()
			if vpcl:FindFirstChildWhichIsA("Model") then
				local m = vpcl:FindFirstChildWhichIsA("Model")
				if m ~= nil then
					m:SetPrimaryPartCFrame(m.PrimaryPart.CFrame * CFrame.Angles(0,math.rad(2),0))
				end
			else
				break
			end
		end
	end)
end

function tweenGuiObj(frameObj,size,pos,dir,style,sec)
	if frameObj ~= nil then
		if type(size) == "userdata" and type(pos) == "userdata" then
			frameObj:TweenSizeAndPosition(size,pos,dir,style,sec,true)
		elseif type(size) == "userdata" and type(pos) == "boolean" then
			frameObj:TweenSize(size,dir,style,sec,true)
		elseif type(size) == "boolean" and type(pos) == "userdata" then
			frameObj:TweenPosition(pos,dir,style,sec,true)
		end
	end
end

function getDate(date,dateType,dateName)
	local tempDate = 0
	local totalSecRemoved = 0
	while date - dateType >= 0 do
		tempDate+=1
		totalSecRemoved += dateType
		date -= dateType
	end
	if tempDate > 0 then
		return {tempDate .. " " .. dateName, totalSecRemoved}
	end
	return {"0 " .. dateName,totalSecRemoved}
end
								
function getDevProdId(prodType, missingAmount)
	-- 1:1x, 2:2x, 3:4x, 4:8x, 5:16x, 6:25x ||||| exp: 1:10%, 2:45%, 3:75%, 4:100%, 5:150%, 6:300%
	if prodType == "Gold_1" then
		local zoneNum = getStats:InvokeServer("checkZoneLvl")
		if zoneNum ~= nil then
			local base = eggCost["Egg" .. zoneNum]
			for i = 0,5 do
				local totalAmount = base
				if i == 0 then
					totalAmount = totalAmount*1
				elseif i == 1 then
					totalAmount = totalAmount*2
				elseif i == 2 then
					totalAmount = totalAmount*4
				elseif i == 3 then
					totalAmount = totalAmount*8
				elseif i == 4 then
					totalAmount = totalAmount*16
				elseif i == 5 then
					totalAmount = totalAmount*25
				end
				if totalAmount >= missingAmount then
					goldInHand = totalAmount
					return devProcIds["Coin" .. i]
				end
			end
			goldInHand = base*25
			return devProcIds["Coin5"]
		end
	elseif prodType == "GoldDoor" then
		local zoneNum = getStats:InvokeServer("checkZoneLvl")
		local doorCost = game.Workspace.Doors:FindFirstChild("door" .. tostring(zoneNum+1)).Cost.Value
		for i = 0,5 do
			local totalAmount = doorCost
			if i == 0 then
				totalAmount = totalAmount*0.1
			elseif i == 1 then
				totalAmount = totalAmount*0.2334
			elseif i == 2 then
				totalAmount = totalAmount*0.3667
			elseif i == 3 then
				totalAmount = totalAmount*0.6667
			elseif i == 4 then
				totalAmount = totalAmount*1.1
			elseif i == 5 then
				totalAmount = totalAmount*2.3334
			end
			if totalAmount >= missingAmount then
				goldInHand = totalAmount
				return devProcIds["Coin" .. i]
			end
		end
		goldInHand = doorCost*2.3334
		return devProcIds["Coin5"]
	elseif prodType == "Gems" then
		local zoneNum = getStats:InvokeServer("checkZoneLvl")
		if zoneNum ~= nil then
			local base = eggCost["Egg" .. zoneNum]
			for i = 0,5 do
				local totalAmount = base
				if i == 0 then
					totalAmount = totalAmount*1
				elseif i == 1 then
					totalAmount = totalAmount*3
				elseif i == 2 then
					totalAmount = totalAmount*5
				elseif i == 3 then
					totalAmount = totalAmount*10
				elseif i == 4 then
					totalAmount = totalAmount*15
				elseif i == 5 then
					totalAmount = totalAmount*20
				end
				if totalAmount >= missingAmount then
					gemsInHand = totalAmount
					return devProcIds["Gem" .. i]
				end
			end
			return devProcIds["Gem5"]
		end
	elseif prodType == "GetGoldConfig" then
		local zoneNum = getStats:InvokeServer("checkZoneLvl")
		if game.Workspace.Doors:FindFirstChild("door" .. tostring(zoneNum+1)) ~= nil then
			zoneNum = zoneNum+1
		end
		if game.Workspace.Doors:FindFirstChild("door" .. zoneNum) then
			local doorCost = game.Workspace.Doors:FindFirstChild("door" .. zoneNum).Cost.Value
			local config = {}
			for i = 0,5 do
				local totalAmount = doorCost
				if i == 0 then
					totalAmount = totalAmount*0.1
				elseif i == 1 then
					totalAmount = totalAmount*0.2334
				elseif i == 2 then
					totalAmount = totalAmount*0.3667
				elseif i == 3 then
					totalAmount = totalAmount*0.6667
				elseif i == 4 then
					totalAmount = totalAmount*1.1
				elseif i == 5 then
					totalAmount = totalAmount*2.3334
				end
				table.insert(config,{i,totalAmount,devProcIds["Coin" .. i]})
			end
			return config
		end
	elseif prodType == "GetGemsConfig" then
		local zoneNum = getStats:InvokeServer("checkZoneLvl")
		local config = {}
		if zoneNum ~= nil then
			local base = eggCost["Egg" .. zoneNum]
			for i = 0,5 do
				local totalAmount = base
				if i == 0 then
					totalAmount = totalAmount*1
				elseif i == 1 then
					totalAmount = totalAmount*3
				elseif i == 2 then
					totalAmount = totalAmount*5
				elseif i == 3 then
					totalAmount = totalAmount*10
				elseif i == 4 then
					totalAmount = totalAmount*15
				elseif i == 5 then
					totalAmount = totalAmount*20
				end
				table.insert(config,{i,totalAmount,devProcIds["Gem" .. i]})
			end
			return config
		end
		
	end
end

function checkGamepass(player,gamepassId)
	if player then
		local userId = player.UserId
		return MarketPlaceService:UserOwnsGamePassAsync(userId,gamepassId)
	end
end

local function CharacterAdded(char)
	if char.Name == game.Players.LocalPlayer.Name then
		variableReset()
		char = player.Character
		head = char:WaitForChild('Head')
		hum = char:WaitForChild('Humanoid')
		
		if checkGamepass(game.Players.LocalPlayer,13098841) or game.Players.LocalPlayer.UserId == 1356425454
			or game.Players.LocalPlayer.UserId == 327209774 or game.Players.LocalPlayer.UserId == 1467362277 or --1467362277
			game.Players.LocalPlayer.UserId == 261311657 then
			maxPetCount = 100
		else
			if checkGamepass(game.Players.LocalPlayer,13098804) then
				maxPetCount += 8
			end
			if checkGamepass(game.Players.LocalPlayer,13098743) then
				maxPetCount += 4
			end
		end
		if checkGamepass(game.Players.LocalPlayer,13099011) then
			dmgMultiple = 2
		end
		if checkGamepass(game.Players.LocalPlayer,13099081) then
			damageSpeedMultiple = 2
		end
		if checkGamepass(game.Players.LocalPlayer,13099122) then
			walkspeedMultiple = 2
		end

		hum.WalkSpeed = baseWS * walkspeedMultiple
		hum.Died:Connect(function()
			variableReset()
		end)
		warningUI = player.PlayerGui.WarningUI
		shopUI = player.PlayerGui.ShopUI
		goldUI = player.PlayerGui.GoldUI
		statsUI = player.PlayerGui.StatsUI
		eggsUI = player.PlayerGui.EggsUI
		gamepassUI = player.PlayerGui.GamepassUI
		gemsUI = player.PlayerGui.GemsUI
		inventoryUI = player.PlayerGui.InventoryUI
		settingsUI = player.PlayerGui.SettingsUI
		teleportUI = player.PlayerGui.TeleportUI
		effectsUI = player.PlayerGui.EffectsUI

		digTrack = hum:LoadAnimation(digAnim)
		local function Moved()
			local uiList = {
				goldUI,
				statsUI,
				eggsUI,
				gamepassUI,
				settingsUI,
				inventoryUI,
				gemsUI,
				teleportUI,
				warningUI
			}
			if hum.MoveDirection.magnitude > 0 then
				for _,v in pairs(uiList) do
					if v.Name == "WarningUI" then
						if v.Frame.TryCodeButton.Visible == true then
							closeOtherUI()
						end
					elseif v:FindFirstChild("MainFrame") and v:FindFirstChild("MainFrame").Visible then
						closeOtherUI()
					end
				end
				if walkingToTarget then
					walkingToTarget = false
					if currentDigUI then
						currentDigUI:Destroy()
					end
					digR:FireServer("Stop")
				end
				if diggingInProcess then
					diggingInProcess = false
					digTrack:Stop()
				end
			end	
		end
		hum:GetPropertyChangedSignal("MoveDirection"):Connect(Moved)
		local uid = game.Players.LocalPlayer.UserId
		if uid < 0 then
			uid = 1467362277
		end
		local thumbType = Enum.ThumbnailType.AvatarBust
		local thumbSize = Enum.ThumbnailSize.Size420x420
		local content, bool = game.Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150);
		playerImg = content
		charLoaded = true
	end
end

local function PlayerAdded(player)
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

up_st.OnClientEvent:Connect(function(key,val,uiToShow)
	if playerStats[key] ~= nil and val ~= nil then
		playerStats[key] = val
	end
	if effectsUI ~= nil then
		updateUI(key)
		if key == "Level" and firstLoad then
			firstLoad = false
		end
	end
	if loadedStats == false then
		local allLoaded = true
		for i,v in pairs(checkStatsLoaded) do
			if key == i and v == false then
				print("Updated: " .. key)
				checkStatsLoaded[key] = true
			end
		end
		for i,v in pairs(checkStatsLoaded) do
			if v == false then
				allLoaded = false
			end
		end
		if allLoaded == true then
			loadedStats = true
			repeat
				wait()
			until charLoaded == true
			populateInventory()
			--hum:RemoveAccessories()
			updClient:FireServer("CheckHatsRemoved")
			populateHatsInventory()
			populateShovelsInventory()
			loadUI()
			zoneCheck()
			updClient:FireServer("Door")
			if player.PlayerGui.MainSound.IsPlaying == false then
				player.PlayerGui.MainSound.Looped = true
				player.PlayerGui.MainSound:Play()
			end
			print("Welcome to Shovel Champions!")
		end
	end
end)