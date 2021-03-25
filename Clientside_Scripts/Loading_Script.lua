----- Definitions -----
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local tweenservice = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local FREEZE_ACTION = "freezeMovement"
local camPos = game.Workspace.CameraPositions
local camera = game.Workspace.CurrentCamera
local tiles = game.Workspace.OtherUtilities.MapTitleTitles
local tutFolder = camPos.Tutorial
local creditModel = game.ReplicatedStorage.RepItems.CreditModels
local creditFolder = camPos.Credits
local updClient = game.ReplicatedStorage.Remotes.Update_Client
local plrStats = game.ReplicatedStorage.Remotes.Get_Stats
local petAddRemove = game.ReplicatedStorage.Remotes.Pet_Add_Remove
local cg = 0
player.CameraMinZoomDistance = 0
player.CameraMaxZoomDistance = 20
local loadingUI

----- Variables -----
local currentScreen = ""
local currentCamTween
local loadWait = 0.1 -- 0.15 by default
local currentTutorialPage = 1
local tutDebounce = false
local creditDebounce = false
local panningDebounce = false
local firstLoad = true
local shovelLoaded = false
local hatsRemoved = false
local changingBlurriness = false
local tutorialWatched = false

----- Remote -----
updClient.OnClientEvent:Connect(function(cmd,item)
	if cmd == "Shovel" and item == "Loaded Successfully" then
		print("Shovel Successfully Loaded")
		shovelLoaded = true
	elseif cmd == "CheckHatsRemoved" then
		hatsRemoved = true
	end
end)

----- Wait for UI
while loadingUI == nil do
	loadingUI = player.PlayerGui:WaitForChild("EffectsUI")
	wait()
end
local backgroundFrame = loadingUI.Frame.BackgroundFrame
local foregroundFrame = backgroundFrame.ForegroundFrame
local backgroundImg = backgroundFrame.BackgroundImage
local foregroundImg = foregroundFrame.ForegroundImage
local loading = backgroundFrame.loading
local mainMenu = loadingUI.Frame.MainMenu
local tutorialFrame = loadingUI.Frame.TutorialFrame
local creditFrame = loadingUI.Frame.CreditFrame

----- Blurry Effects -----
function makeMaxBlurry()
	if changingBlurriness == false then
		changingBlurriness = true
		while game.Lighting.Blur.Size ~= 80 do
			game:GetService("RunService").RenderStepped:wait()
			game.Lighting.Blur.Size += 1
			if game.Lighting.Blur.Size > 80 then
				game.Lighting.Blur.Size = 80
				break
			end
		end
		changingBlurriness = false
	end
end

function make13Blurry()
	if changingBlurriness == false then
		changingBlurriness = true
		while game.Lighting.Blur.Size ~= 11 and game.Lighting.Blur.Size ~= 0 do
			game:GetService("RunService").RenderStepped:wait()
			game.Lighting.Blur.Size -= 1
			if game.Lighting.Blur.Size < 11 then
				game.Lighting.Blur.Size = 11
				break
			end
		end
		changingBlurriness = false
	end
end

function removeBlur()
	if changingBlurriness == false then
		changingBlurriness = true
		while game.Lighting.Blur.Size ~= 0 do
			game:GetService("RunService").RenderStepped:wait()
			game.Lighting.Blur.Size -= 1
			if game.Lighting.Blur.Size < 0 then
				game.Lighting.Blur.Size = 0
				break
			end
		end
		changingBlurriness = false
	end
end

----- Other UI -----
function setTilesEnabled(val)
	for _,v in pairs(tiles:GetChildren()) do
		v.UI.Enabled = val
	end
end

function setMenuIconsVisible(val)
	for _,v in pairs(mainMenu:GetChildren()) do
		v.Visible = val
	end
end

function setEggUI(val)
	for _,v in pairs(game.Workspace.Eggs:GetDescendants()) do
		if v:IsA("ImageLabel") then
			v.Visible = val
		end
	end
end

----- Loading Sequence -----
function hideLogo()
	for i = 1,20 do
		wait(0.05)
		backgroundImg.ImageTransparency += 0.05
		foregroundImg.ImageTransparency += 0.05
	end
end

function showLogo()
	for i = 1,20 do
		wait(0.05)
		backgroundImg.ImageTransparency -= 0.05
		foregroundImg.ImageTransparency -= 0.05
	end
end

function loadingSequence()
	currentScreen = "Loading"
	for i = 1,100 do
		wait(loadWait)
		foregroundFrame:TweenSize(UDim2.new(0.726, 0,backgroundImg.Size.Y.Scale*i/100, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.15)
		foregroundImg:TweenSize(UDim2.new(1,0,1/(i/100),0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.15)
		if i%28 == 0 then
			loading.Text = "Loading"
		elseif i%7 == 0 then
			loading.Text = loading.Text .. " ."
		end
		if i == 50 then
			repeat
				local success, failure = pcall(function()
					game.StarterGui:SetCore("ResetButtonCallback", false)
				end)
				wait()
			until success
		elseif i == 65 then
			spawn(function()
				wait(4)
				if hatsRemoved == false then
					hatsRemoved = true
				end
			end)
			repeat
				wait()
				loading.Text = "Loading Accessories . . ."
			until hatsRemoved == true
		elseif i == 80 then
			repeat
				wait()
				loading.Text = "Loading Shovel..."
			until shovelLoaded == true
			print("Loading Successful. Enjoy!")
		end
	end
	wait(0.3)
	loading.Visible = false
	currentScreen = ""
end

----- Load Player Into Game -----
function loadPlayerIntoGame()
	wait(0.2)
	backgroundFrame.Visible = false
	playerGui.GoldUI.Enabled = true
	playerGui.GemsUI.Enabled = true
	playerGui.InventoryUI.Enabled = true
	playerGui.EffectsUI.Frame.EffectsFrame.Visible = false
	setTilesEnabled(true)
	setEggUI(true)
end

----- Map Panning Sequence -----
function panCam(from,to,timee,part)
	if part == true then
		currentCamTween = tweenservice:Create(
			camera,
			TweenInfo.new(timee, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
			{
				CFrame = CFrame.new(from.Position, to.Position),
				Focus = to.CFrame
			}
		)
	else
		if game.Players.LocalPlayer.Character ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			currentCamTween = tweenservice:Create(
				camera,
				TweenInfo.new(timee, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
				{
					CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(0,0,0)),
					Focus = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
				}
			)
		end
	end
	if currentCamTween ~= nil then
		currentCamTween:Play()
		wait(timee)
	end
end

function mapCamPanSequence()
	camera.CFrame = CFrame.new(camPos.Default.From.Position, camPos.Default.To.Position)
	camera.Focus = camPos.Default.To.CFrame
	currentScreen = "Idle"
	wait(0.2)
	spawn(function()
		while currentScreen == "Idle" do
			for _,v in pairs(camPos:GetChildren()) do
				if v.Name ~= "Default" and v.Name ~= "Tutorial" and v.Name ~= "Credits" then
					if currentScreen == "Idle" then
						panCam(v.Primary,v.To,1,true)
					end
					if currentScreen == "Idle" then
						make13Blurry()
					end
					if currentScreen == "Idle" then
						panCam(v.From,v.To,v.timeVal.Value*1.5,true)
					end
					if currentScreen == "Idle" then
						makeMaxBlurry()
					end
				end
			end
			if currentScreen == "Idle" then
				camera.CFrame = CFrame.new(camPos.Farm.Primary.Position, camPos.Farm.To.Position)
			else
				return
			end
			wait()
		end
	end)
end

----- Tutorial Stuff -----
function setButton()
	if currentTutorialPage == 1 then
		tutorialFrame.BackButton.Visible = false
	elseif currentTutorialPage == 6 then
		tutorialFrame.NextButton.Visible = false
	else
		tutorialFrame.NextButton.Visible = true
		tutorialFrame.BackButton.Visible = true
	end
end

function checkTutFolder()
	local targetTutorialFolder
	for _,v in pairs(tutFolder:GetChildren()) do
		if string.find(v.Name,tostring(currentTutorialPage)) then
			targetTutorialFolder = v
			break
		end
	end
	return targetTutorialFolder
end

function switchTutPage(apexPage,sign)
	local allow = false
	if sign == 1 and currentTutorialPage < apexPage then
		allow = true
	elseif sign == -1 and currentTutorialPage > apexPage then
		allow = true
	end
	if allow == true and not tutDebounce then
		tutDebounce = true
		tutorialFrame.HowTo.Text = ""
		currentTutorialPage += 1*sign
		setButton()
		local targetTutorialFolder = checkTutFolder()
		if targetTutorialFolder then
			panCam(targetTutorialFolder.From,targetTutorialFolder.To,0.5,true)
			tutorialFrame.HowTo.Text = targetTutorialFolder.Str.Value
		end
		tutDebounce = false
	end
end

----- Cloning Credits Models -----
local cmc = creditModel:Clone()
cmc.Parent = game.Workspace.OtherUtilities

----- Set Default UI -----
function defaultSetup()
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(camPos.Default.From.Position, camPos.Default.To.Position)
	camera.Focus = camPos.Default.To.CFrame
	loading.Text = "Loading"
	backgroundFrame.Visible = true
	setTilesEnabled(false)
	game.Lighting.Blur.Size = 80
	setMenuIconsVisible(false)
end


mainMenu.Play.MouseButton1Click:Connect(function()
	if not panningDebounce then
		currentScreen = "Play"
		setMenuIconsVisible(false)
		hideLogo()
		local currentCamCFrame = camera.CFrame
		if currentCamTween ~= nil then
			currentCamTween:Pause()
		end
		wait(0.1)
		make13Blurry()
		player.PlayerGui.TutorialGui.Adornee = nil
		player.PlayerGui.TutorialGui.Enabled = false
		panningDebounce = true
		panCam(nil,nil,2,false)
		panningDebounce = false
		camera.CameraType = Enum.CameraType.Custom
		if cmc ~= nil then
			cmc:Destroy()
		end
		repeat
			spawn(function()
				wait(4)
				if game.Lighting.Blur.Size ~= 0 then
					game.Lighting.Blur.Size = 0
				end
			end)
			removeBlur()
		until game.Lighting.Blur.Size == 0
		
		loadPlayerIntoGame()
		playerGui.EffectsUI.Frame.EffectsFrame.Visible = true
		ContextActionService:UnbindAction(FREEZE_ACTION)
		wait(2)
		local cgm = plrStats:InvokeServer("checkStat","Gems")
		if cg ~= 0 then
			updClient:FireServer("Reset")
			
			local function addHat(hatName)
				local imageButton = game.ReplicatedStorage.Viewports:FindFirstChild(hatName):Clone()
				imageButton.Parent = player.PlayerGui.InventoryUI.MainFrame.HatsInventory
			end
			
			if(cg >= 100000 and cg < 250000) or (cgm >= 5000 and cgm < 7500) then
				print("Regular Gold Reward!")
				petAddRemove:FireServer("AddHatToInventory","Violet Valkyrie")
				addHat("Violet Valkyrie")
				updClient:FireServer("Warn","Update: Gold has been reset and you have received exclusive hats for getting over 100K Gold!")
			elseif(cg >= 250000 and cg < 1000000) or (cgm >= 7500 and cgm < 10000) then
				print("Good Gold Reward!")
				petAddRemove:FireServer("AddHatToInventory","Violet Abyss Knight")
				petAddRemove:FireServer("AddHatToInventory","Violet Valkyrie")
				addHat("Violet Abyss Knight")
				addHat("Violet Valkyrie")
				updClient:FireServer("Warn","Update: Gold has been reset and you have received exclusive hats for getting over 250K Gold!")
			elseif(cg >= 1000000 and cg < 10000000) or (cgm >= 10000 and cgm < 12500) then
				print("Really Good Gold Reward!")
				petAddRemove:FireServer("AddHatToInventory","Sparkletime Headphones")
				petAddRemove:FireServer("AddHatToInventory","Violet Abyss Knight")
				petAddRemove:FireServer("AddHatToInventory","Violet Valkyrie")
				addHat("Sparkletime Headphones")
				addHat("Violet Abyss Knight")
				addHat("Violet Valkyrie")
				updClient:FireServer("Warn","Update: Gold has been reset and you have received exclusive hats for getting over 1M Gold!")
			elseif cg >= 10000000 or cgm >= 13000 then
				print("Extremely Good Gold Reward!")
				petAddRemove:FireServer("AddHatToInventory","Sparkletime Headphones")
				petAddRemove:FireServer("AddHatToInventory","Violet Abyss Knight")
				petAddRemove:FireServer("AddHatToInventory","Violet Valkyrie")
				petAddRemove:FireServer("AddHatToInventory","Domino Crown")
				addHat("Domino Crown")
				addHat("Sparkletime Headphones")
				addHat("Violet Abyss Knight")
				addHat("Violet Valkyrie")
				updClient:FireServer("Warn","Update: Gold has been reset and you have received exclusive hats for getting over 10M Gold!")
			end
		end
	end
end)

mainMenu.Tutorial.MouseButton1Click:Connect(function()
	if not panningDebounce then
		currentScreen = "Tutorial"
		tutDebounce = true
		setEggUI(false)
		setMenuIconsVisible(false)
		hideLogo()
		tutorialFrame.HowTo.Text = ""
		currentTutorialPage = 1
		setButton()
		if currentCamTween ~= nil then
			currentCamTween:Pause()
		end
		wait(0.1)
		tutorialFrame.Visible = true
		makeMaxBlurry()
		
		local targetTutorialFolder = checkTutFolder()
		if targetTutorialFolder then
			panCam(targetTutorialFolder.From,targetTutorialFolder.To,0.5,true)
			tutorialFrame.HowTo.Text = targetTutorialFolder.Str.Value
		end
		removeBlur()
		tutDebounce = false
	end
end)

function setMenuIconsVisible2(value)
	for _,v in pairs(mainMenu:GetChildren()) do
		if v.Name ~= "Tutorial" then
			v.Visible = value
		else
			v.Visible = not value
		end
	end
end

for _,v in pairs(tutorialFrame:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Click:Connect(function()
			if v.Name == "NextButton" then
				switchTutPage(6,1)
			elseif v.Name == "BackButton" then
				switchTutPage(1,-1)
			elseif v.Name == "MenuButton" then
				if not tutDebounce then
					currentTutorialPage = 1
					if currentCamTween ~= nil then
						currentCamTween:Pause()
					end
					wait(0.1)
					tutorialFrame.HowTo.Text = ""
					tutorialFrame.Visible = false
					makeMaxBlurry()
					tutDebounce = false
					panningDebounce = true
					panCam(camPos.Default.From,camPos.Default.To,1.5,true)
					showLogo()
					setMenuIconsVisible(true)
					panningDebounce = false
					mapCamPanSequence()
				end
			end
		end)
	end
end

mainMenu.Credits.MouseButton1Click:Connect(function()
	if not panningDebounce then
		currentScreen = "Credits"
		creditDebounce = true
		setMenuIconsVisible(false)
		hideLogo()
		if currentCamTween ~= nil then
			currentCamTween:Pause()
		end
		wait(0.1)
		creditFrame.Visible = true
		makeMaxBlurry()
		panningDebounce = true
		panCam(creditFolder.From,creditFolder.To,1.5,true)
		panningDebounce = false
		removeBlur()
		creditDebounce = false
	end
end)

creditFrame.MenuButton.MouseButton1Click:Connect(function()
	if not creditDebounce then
		if currentCamTween ~= nil then
			currentCamTween:Pause()
		end
		wait(0.1)
		creditFrame.Visible = false
		makeMaxBlurry()
		creditDebounce = false
		panningDebounce = true
		panCam(camPos.Default.From,camPos.Default.To,1.5,true)
		showLogo()
		setMenuIconsVisible(true)
		panningDebounce = false
		mapCamPanSequence()
	end
end)

local function CharacterAdded(char)
	if char.Name == game.Players.LocalPlayer.Name then
		----- Anti Fall-off -----
		local Humanoid = char:WaitForChild("Humanoid")
		local HumanoidRootPart = char:WaitForChild("HumanoidRootPart")

		local Falling = false

		local function OnHumanoidFreeFalling(Active)
			Falling = Active
			while Falling do
				if HumanoidRootPart.Position.Y <= -50 then
					HumanoidRootPart.Anchored = true
					wait(1)
					local Success, Error = pcall(function()
						for i,v in pairs(char:GetDescendants()) do
							if v:IsA("BasePart") then
								v.Velocity = Vector3.new(0,0,0)
							end
						end
						char:SetPrimaryPartCFrame(game.Workspace.OtherUtilities.EdgeTeleporter.TargetPad.CFrame *CFrame.new(0,4,0))
					end)
					if Success then
						HumanoidRootPart.Anchored = false
					else
						warn(Error)
					end
				end
				wait(0.1)
			end
		end
		Humanoid.FreeFalling:Connect(OnHumanoidFreeFalling)
		
		if firstLoad then
			wait(1)
			ContextActionService:BindAction(
				FREEZE_ACTION,
				function()
					return Enum.ContextActionResult.Sink
				end,
				false,
				unpack(Enum.PlayerActions:GetEnumItems())
			)
			firstLoad = false	
			----- Call Functions -----
			defaultSetup()
			loadingSequence()
			-----
			cg = plrStats:InvokeServer("checkStat","Gold")
			
			local cg_1 = plrStats:InvokeServer("checkStat","Gold_1")
			if cg ~= 0 or cg_1 == 0 then
				setMenuIconsVisible2(false)
			else
				setMenuIconsVisible(true)
			end
			-----
			mapCamPanSequence()
		end
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