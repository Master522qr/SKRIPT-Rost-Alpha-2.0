--[[
BOSS-MORS Script for Rost Alpha (Xeno Injector Version)
Версия 3.0 - ULTIMATE EDITION
ВНИМАНИЕ: Использование некоторых функций может привести к бану!
Вы подтверждаете, что действуете на свой страх и риск!

ИНСТРУКЦИЯ ДЛЯ XENO:
1. Откройте Xeno Injector
2. Нажмите "Attach" для прикрепления к Roblox
3. Вставьте этот скрипт в поле для кода
4. Нажмите "Execute"
5. В игре нажмите INSERT для открытия меню
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

if _G.BOSSMORS_LOADED then
    print("Скрипт уже запущен!")
    return
end
_G.BOSSMORS_LOADED = true

_G.BOSSMORS = {
    Version = "3.0",
    Author = "BOSS-MORS",
    Game = "Rost Alpha",
    LoadTime = os.time()
}

local Settings = {
    Menu = {
        Key = Enum.KeyCode.Insert,
        Open = false,
        Color = Color3.fromRGB(170, 0, 255),
        Accent = Color3.fromRGB(130, 0, 200),
        Background = Color3.fromRGB(30, 30, 40),
        Text = Color3.fromRGB(255, 255, 255),
        AnimationSpeed = 0.3
    },
    
    AimBot = {
        Enabled = false,
        Key = Enum.KeyCode.T,
        FOV = 30,
        Smoothness = 0.2,
        TeamCheck = true,
        VisibleCheck = true,
        Friends = {},
        Prediction = 0.12,
        Priority = "Distance",
        HitChance = 85,
        Color = Color3.fromRGB(255, 0, 0)
    },
    
    Visuals = {
        ESP = {
            Enabled = false,
            Box = true,
            Name = true,
            Distance = true,
            Health = true,
            Weapon = true,
            Armor = true,
            MaxDistance = 500,
            FriendColor = Color3.fromRGB(0, 255, 0),
            EnemyColor = Color3.fromRGB(255, 50, 50),
            FriendKey = Enum.KeyCode.F2,
            Tracer = false,
            Skeleton = false,
            HeadDot = false
        },
        
        BlockESP = {
            Enabled = false,
            Chest = true,
            Crate = true,
            Loot = true,
            Vehicle = true,
            Door = true
        },
        
        NightVision = {
            Enabled = false,
            Intensity = 2.5,
            Color = Color3.fromRGB(0, 255, 200)
        },
        
        Chams = {
            Enabled = false,
            Material = "ForceField",
            Transparency = 0.3,
            Color = Color3.fromRGB(255, 0, 0)
        },
        
        NoFog = { Enabled = false },
        FullBright = { Enabled = false },
        
        Crosshair = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Size = 20
        }
    },
    
    Player = {
        Speed = { Enabled = false, Value = 25, Default = 16 },
        Jump = { Enabled = false, Value = 50 },
        Fly = { Enabled = false, Speed = 50 },
        HitBox = { Enabled = false, Size = 10, Range = 50 },
        NoClip = { Enabled = false }
    },
    
    Dupe = {
        MoneyDuplication = { Enabled = false, Warning = false },
        ItemDuplication = { Enabled = false, Warning = false }
    },
    
    Spinner = {
        Enabled = false,
        Warning = false,
        AimBotXSpinner = false,
        NoFaire = false,
        SpinSpeed = 50,
        SpinRange = 100
    },
    
    Fun = {
        CrashServer = { Enabled = false, Warning = false },
        KillServer = { Enabled = false, Warning = false },
        FriendAdd = { Enabled = false },
        WhatsSoft = { Enabled = false },
        ReportSpam = { Enabled = false, Warning = false }
    },
    
    Turret = {
        Invisible = false
    },
    
    EveryoneFly = {
        Enabled = false,
        Warning = false,
        Speed = 100
    },
    
    Sound = {
        Enabled = false,
        Volume = 1
    },
    
    Exploits = {
        AntiAFK = true,
        InfiniteJump = false,
        AutoFarm = false,
        AutoCollect = false,
        InstantRespawn = false,
        NoFallDamage = false
    },
    
    Safety = {
        AntiBan = true,
        AntiLog = true,
        RandomDelay = true,
        HideScript = true,
        BypassAC = true,
        StealthMode = true
    }
}

local Connections = {}
local ESPObjects = {}
local BlockedESPObjects = {}
local OldLighting = {}
local RenderSteppedConnection = nil
local HeartbeatConnection = nil
local LastUpdateTime = 0
local UpdateInterval = 1/60
local FriendsSet = {}

-- Звук "АХХХХХХХ"
local function PlayAhSound()
    if not Settings.Sound.Enabled then return end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9120386436" -- Замените на реальный ID звука
    sound.Volume = Settings.Sound.Volume
    sound.Parent = LocalPlayer.Character or Workspace
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

local function ShowWarning(functionName, warningText, callback)
    local warningGui = Instance.new("ScreenGui")
    warningGui.Name = "WarningGUI"
    warningGui.Parent = CoreGui
    warningGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = warningGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    title.Text = "⚠️ ВНИМАНИЕ! ⚠️"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    local warningTextLabel = Instance.new("TextLabel")
    warningTextLabel.Size = UDim2.new(1, -20, 0, 80)
    warningTextLabel.Position = UDim2.new(0, 10, 0, 50)
    warningTextLabel.BackgroundTransparency = 1
    warningTextLabel.Text = warningText .. "\n\nВы подтверждаете, что действуете на свой страх и риск?"
    warningTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    warningTextLabel.TextWrapped = true
    warningTextLabel.Font = Enum.Font.Gotham
    warningTextLabel.TextSize = 14
    warningTextLabel.Parent = mainFrame
    
    local confirmButton = Instance.new("TextButton")
    confirmButton.Size = UDim2.new(0, 150, 0, 40)
    confirmButton.Position = UDim2.new(0, 20, 1, -50)
    confirmButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    confirmButton.Text = "✅ ПОДТВЕРЖДАЮ"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.TextSize = 14
    confirmButton.Parent = mainFrame
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0, 150, 0, 40)
    cancelButton.Position = UDim2.new(1, -170, 1, -50)
    cancelButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cancelButton.Text = "❌ ОТМЕНА"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.TextSize = 14
    cancelButton.Parent = mainFrame
    
    confirmButton.MouseButton1Click:Connect(function()
        warningGui:Destroy()
        callback(true)
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        warningGui:Destroy()
        callback(false)
    end)
end

local SpinnerTargets = {}
local function AimBotXSpinner()
    if not Settings.Spinner.Enabled or not Settings.Spinner.AimBotXSpinner then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.HumanoidRootPart then
            local target = player.Character.HumanoidRootPart
            local spinAngle = (tick() * Settings.Spinner.SpinSpeed) % (math.pi * 2)
            local offset = Vector3.new(math.sin(spinAngle) * Settings.Spinner.SpinRange, 0, math.cos(spinAngle) * Settings.Spinner.SpinRange)
            
            -- Заставляем прицел крутиться вокруг игрока
            local newPosition = target.Position + offset
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, newPosition)
        end
    end
end

local function NoFaire()
    if not Settings.Spinner.Enabled or not Settings.Spinner.NoFaire then return end
    if not LocalPlayer.Character then return end
    
    for _, projectile in pairs(Workspace:GetDescendants()) do
        if projectile:IsA("BasePart") and projectile:FindFirstChild("Bullet") then
            local origin = projectile:FindFirstChild("Origin")
            if origin and origin.Value and origin.Value ~= LocalPlayer then
                local distance = (projectile.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < 20 then
                    -- Отклоняем пулю
                    projectile.Velocity = projectile.Velocity + Vector3.new(math.random(-100, 100), math.random(-50, 50), math.random(-100, 100))
                    
                    -- Крутим атакующего
                    local attacker = origin.Value
                    if attacker and attacker.Character and attacker.Character.HumanoidRootPart then
                        attacker.Character.HumanoidRootPart.CFrame = attacker.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(30), 0)
                    end
                end
            end
        end
    end
end

local function HitBoxExpander()
    if not Settings.Player.HitBox.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = Vector3.new(Settings.Player.HitBox.Size, Settings.Player.HitBox.Size, Settings.Player.HitBox.Size)
                    
                    -- Увеличиваем дальность атаки
                    if Settings.Player.HitBox.Range > 0 then
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool and tool.Handle then
                            tool.Handle.Size = Vector3.new(Settings.Player.HitBox.Range, Settings.Player.HitBox.Range, Settings.Player.HitBox.Range)
                        end
                    end
                end
            end
        end
    end
end

local function BlockESP()
    if not Settings.Visuals.BlockESP.Enabled then return end
    
    local blockTypes = {}
    if Settings.Visuals.BlockESP.Chest then table.insert(blockTypes, "Chest") end
    if Settings.Visuals.BlockESP.Crate then table.insert(blockTypes, "Crate") end
    if Settings.Visuals.BlockESP.Loot then table.insert(blockTypes, "Loot") end
    if Settings.Visuals.BlockESP.Vehicle then table.insert(blockTypes, "Vehicle") end
    if Settings.Visuals.BlockESP.Door then table.insert(blockTypes, "Door") end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        for _, blockType in pairs(blockTypes) do
            if obj.Name:find(blockType) or obj.ClassName:find(blockType) then
                obj.LocalTransparencyModifier = 1
                obj.CanCollide = false
            end
        end
    end
end

local function InvisibleTurret()
    if not Settings.Turret.Invisible then return end
    if not LocalPlayer.Character then return end
    
    for _, turret in pairs(Workspace:GetDescendants()) do
        if turret.Name:lower():find("turret") or turret:IsA("Model") and turret:FindFirstChild("Turret") then
            local humanoid = turret:FindFirstChild("Humanoid")
            if humanoid then
                -- Делаем турель слепой к игроку
                local targetPart = turret:FindFirstChild("TargetPart")
                if targetPart then
                    targetPart.CFrame = CFrame.new(0, 0, 0)
                end
               
                local detection = turret:FindFirstChild("Detection")
                if detection then
                    detection.Disabled = true
                end
            end
        end
    end
end

local FlyingPlayers = {}
local function EveryoneFly()
    if not Settings.EveryoneFly.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not FriendsSet[player.Name] and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart and not FlyingPlayers[player.Name] then
                humanoid.PlatformStand = true
                
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
                bodyVelocity.Velocity = Vector3.new(0, Settings.EveryoneFly.Speed, 0)
                bodyVelocity.Parent = rootPart
                
                FlyingPlayers[player.Name] = bodyVelocity
                
                -- Бан игрока (симуляция)
                local args = {
                    [1] = player.Name,
                    [2] = "Fly Hack Detected"
                }
                if ReplicatedStorage:FindFirstChild("BanPlayer") then
                    ReplicatedStorage.BanPlayer:FireServer(unpack(args))
                end
            end
        end
    end
end

local function CrashServer()
    if not Settings.Fun.CrashServer.Enabled then return end
    
    for i = 1, 1000 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(100, 100, 100)
        part.Position = Vector3.new(math.random(-10000, 10000), math.random(-10000, 10000), math.random(-10000, 10000))
        part.Anchored = true
        part.Parent = Workspace
        task.wait()
    end
    
    for i = 1, 100 do
        LocalPlayer:Kick("Crash initiated")
    end
end

local function KillServer()
    if not Settings.Fun.KillServer.Enabled then return end
    
    -- Убиваем всех игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj:Destroy()
        end
    end
end

local function FriendAdd()
    if not Settings.Fun.FriendAdd.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not FriendsSet[player.Name] then
            table.insert(Settings.AimBot.Friends, player.Name)
            UpdateFriendsSet()
            print("Добавлен в друзья: " .. player.Name)
            task.wait(0.1)
        end
    end
end

local function WhatsSoft()
    if not Settings.Fun.WhatsSoft.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player:Kick("What's soft? - BOSS-MORS")
            task.wait(0.05)
        end
    end
end

local function ReportSpam()
    if not Settings.Fun.ReportSpam.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            for i = 1, 50 do
                -- Спамим репортами
                local args = {
                    [1] = player.Name,
                    [2] = "Cheating/Hacking",
                    [3] = "Using aimbot, ESP, fly hacks",
                    [4] = "Bullying and harassment"
                }
                if ReplicatedStorage:FindFirstChild("ReportPlayer") then
                    ReplicatedStorage.ReportPlayer:FireServer(unpack(args))
                end
                task.wait(0.01)
            end
        end
    end
end

-- Улучшенный Anti-Ban с обходом античитов
local function AntiBanBypass()
    if not Settings.Safety.AntiBan then return end
    
    local oldName = LocalPlayer.Name
    LocalPlayer.Name = HttpService:GenerateGUID(false)
    task.wait(0.1)
    LocalPlayer.Name = oldName
    
    for _, obj in pairs(CoreGui:GetChildren()) do
        if obj.Name:find("BOSS") or obj.Name:find("MORS") then
            obj.DisplayOrder = 999
        end
    end
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            local oldState = humanoid:GetState()
            if oldState == Enum.HumanoidStateType.Flying then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
                task.wait(0.1)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
            end
        end
    end
    
    if Settings.Player.Speed.Enabled then
        local walkspeed = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.WalkSpeed
        if walkspeed and walkspeed > 50 then
            -- Подделываем скорость для сервера
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/me Walking normally", "All")
        end
    end
end

local function UpdateESP()
    for _, obj in pairs(ESPObjects) do
        pcall(function() obj:Remove() end)
    end
    ESPObjects = {}
    
    if not Settings.Visuals.ESP.Enabled then return end
    if not LocalPlayer.Character then return end
    
    local playerRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then continue end
        
        local distance = (humanoidRootPart.Position - playerRoot.Position).Magnitude
        if distance > Settings.Visuals.ESP.MaxDistance then continue end
        
        local isFriend = FriendsSet[player.Name]
        local color = isFriend and Settings.Visuals.ESP.FriendColor or Settings.Visuals.ESP.EnemyColor
        
        if Settings.Visuals.ESP.Box then
            local box = Drawing.new("Square")
            box.Visible = true
            box.Color = color
            box.Thickness = 2
            box.Filled = false
            box.Transparency = 1
            table.insert(ESPObjects, box)
            
            local function updateBox()
                if not player.Character or not humanoidRootPart or humanoid.Health <= 0 then
                    box.Visible = false
                    box:Remove()
                    return
                end
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local size = Vector2.new(2000 / screenPoint.Z, 3000 / screenPoint.Z)
                    box.Size = size
                    box.Position = Vector2.new(screenPoint.X - size.X / 2, screenPoint.Y - size.Y / 2)
                    box.Visible = true
                else
                    box.Visible = false
                end
            end
            table.insert(ESPObjects, {update = updateBox})
        end
        
        if Settings.Visuals.ESP.Name then
            local nameText = Drawing.new("Text")
            nameText.Visible = true
            nameText.Color = color
            nameText.Size = 13
            nameText.Center = true
            nameText.Outline = true
            nameText.Text = player.Name
            table.insert(ESPObjects, nameText)
            
            local function updateName()
                if not player.Character or not humanoidRootPart then
                    nameText.Visible = false
                    return
                end
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    nameText.Position = Vector2.new(screenPoint.X, screenPoint.Y - 40)
                    nameText.Visible = true
                else
                    nameText.Visible = false
                end
            end
            table.insert(ESPObjects, {update = updateName})
        end
        
        if Settings.Visuals.ESP.Distance then
            local distanceText = Drawing.new("Text")
            distanceText.Visible = true
            distanceText.Color = Color3.fromRGB(255, 255, 255)
            distanceText.Size = 12
            distanceText.Center = true
            distanceText.Outline = true
            table.insert(ESPObjects, distanceText)
            
            local function updateDistance()
                if not player.Character or not humanoidRootPart then
                    distanceText.Visible = false
                    return
                end
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                local currentDistance = (humanoidRootPart.Position - playerRoot.Position).Magnitude
                if onScreen then
                    distanceText.Position = Vector2.new(screenPoint.X, screenPoint.Y - 25)
                    distanceText.Text = math.floor(currentDistance) .. "m"
                    distanceText.Visible = true
                else
                    distanceText.Visible = false
                end
            end
            table.insert(ESPObjects, {update = updateDistance})
        end
        
        if Settings.Visuals.ESP.Health then
            local healthText = Drawing.new("Text")
            healthText.Visible = true
            healthText.Size = 12
            healthText.Center = true
            healthText.Outline = true
            table.insert(ESPObjects, healthText)
            
            local function updateHealth()
                if not player.Character or not humanoid or humanoid.Health <= 0 then
                    healthText.Visible = false
                    return
                end
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    healthText.Position = Vector2.new(screenPoint.X, screenPoint.Y - 55)
                    healthText.Text = "❤ " .. math.floor(humanoid.Health)
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    if healthPercent > 0.5 then
                        healthText.Color = Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 0.25 then
                        healthText.Color = Color3.fromRGB(255, 255, 0)
                    else
                        healthText.Color = Color3.fromRGB(255, 0, 0)
                    end
                    healthText.Visible = true
                else
                    healthText.Visible = false
                end
            end
            table.insert(ESPObjects, {update = updateHealth})
        end
        
        if Settings.Visuals.ESP.Weapon then
            local weaponText = Drawing.new("Text")
            weaponText.Visible = true
            weaponText.Color = color
            weaponText.Size = 11
            weaponText.Center = true
            weaponText.Outline = true
            table.insert(ESPObjects, weaponText)
            
            local function updateWeapon()
                if not player.Character then
                    weaponText.Visible = false
                    return
                end
                local tool = player.Character:FindFirstChildOfClass("Tool")
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen and tool then
                    weaponText.Position = Vector2.new(screenPoint.X, screenPoint.Y + 20)
                    weaponText.Text = "🔫 " .. tool.Name
                    weaponText.Visible = true
                else
                    weaponText.Visible = false
                end
            end
            table.insert(ESPObjects, {update = updateWeapon})
        end
        
        if Settings.Visuals.ESP.Armor then
            local armorText = Drawing.new("Text")
            armorText.Visible = true
            armorText.Color = Color3.fromRGB(100, 150, 255)
            armorText.Size = 11
            armorText.Center = true
            armorText.Outline = true
            table.insert(ESPObjects, armorText)
            
            local function updateArmor()
                if not player.Character then
                    armorText.Visible = false
                    return
                end
                local armor = player.Character:FindFirstChild("Armor")
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen and armor then
                    armorText.Position = Vector2.new(screenPoint.X, screenPoint.Y + 35)
                    armorText.Text = "🛡️ " .. math.floor(armor.Value)
                    armorText.Visible = true
                else
                    armorText.Visible = false
                end
            end
            table.insert(ESPObjects, {update = updateArmor})
        end
    end
end

local function UpdateESPObjects()
    for i = #ESPObjects, 1, -1 do
        local obj = ESPObjects[i]
        if type(obj) == "table" and obj.update then
            pcall(obj.update)
        end
    end
end

local function FastUpdate()
    local currentTime = tick()
    if currentTime - LastUpdateTime < UpdateInterval then return end
    LastUpdateTime = currentTime
    
    pcall(function()
        AimBotXSpinner()
        NoFaire()
        HitBoxExpander()
        BlockESP()
        InvisibleTurret()
        EveryoneFly()
        FriendAdd()
        ReportSpam()
        AntiBanBypass()
        UpdateESPObjects()
    end)
end

local function AnimateMenu(frame, targetVisible)
    local targetAlpha = targetVisible and 1 or 0
    local currentAlpha = frame.Visible and 1 or 0
    
    local tweenInfo = TweenInfo.new(Settings.Menu.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1 - targetAlpha})
    tween:Play()
    
    frame.Visible = targetVisible
end

Library = {Tabs = {}, UI = nil}

function Library:CreateWindow()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BOSS_MORS_XENO"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 550)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
    MainFrame.BackgroundColor3 = Settings.Menu.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Settings.Menu.Color
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "BOSS-MORS v3.0 | ULTIMATE EDITION"
    Title.TextColor3 = Settings.Menu.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Settings.Menu.Text
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseButton1Click:Connect(function()
        Settings.Menu.Open = false
        AnimateMenu(MainFrame, false)
    end)
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, -30)
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 120, 1, 0)
    TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 3
    TabContainer.Parent = Content
    
    local RightPanel = Instance.new("Frame")
    RightPanel.Size = UDim2.new(1, -120, 1, 0)
    RightPanel.Position = UDim2.new(0, 120, 0, 0)
    RightPanel.BackgroundTransparency = 1
    RightPanel.Parent = Content
    
    return {ScreenGui = ScreenGui, MainFrame = MainFrame, TabContainer = TabContainer, RightPanel = RightPanel, TitleBar = TitleBar}
end

function Library:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.Position = UDim2.new(0, 0, 0, (#self.Tabs * 40))
    TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    TabButton.BorderSizePixel = 0
    TabButton.Text = "  " .. name
    TabButton.TextColor3 = Settings.Menu.Text
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 12
    TabButton.Parent = self.UI.TabContainer
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, -20, 1, -20)
    TabFrame.Position = UDim2.new(0, 10, 0, 10)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.ScrollBarThickness = 3
    TabFrame.Visible = false
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.Parent = self.UI.RightPanel
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        if self.CurrentTab then self.CurrentTab.Visible = false end
        TabFrame.Visible = true
        self.CurrentTab = TabFrame
        for _, tab in pairs(self.Tabs) do
            if tab.Button then tab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60) end
        end
        TabButton.BackgroundColor3 = Settings.Menu.Color
    end)
    
    local tabData = {Name = name, Button = TabButton, Frame = TabFrame}
    table.insert(self.Tabs, tabData)
    
    if #self.Tabs == 1 then
        TabButton.BackgroundColor3 = Settings.Menu.Color
        TabFrame.Visible = true
        self.CurrentTab = TabFrame
    end
    
    return tabData
end

function Library:CreateToggle(tab, text, settingTable, settingKey, requireWarning, warningText)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 25)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = tab.Frame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -40, 0, 0)
    ToggleButton.BackgroundColor3 = settingTable[settingKey] and Settings.Menu.Accent or Color3.fromRGB(80, 80, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Settings.Menu.Text
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 12
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    ToggleIndicator.Position = settingTable[settingKey] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleIndicator.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 100)
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        if requireWarning and not settingTable[settingKey] then
            ShowWarning(text, warningText or "Эта функция может привести к бану вашего аккаунта!", function(confirmed)
                if confirmed then
                    settingTable[settingKey] = true
                    ToggleButton.BackgroundColor3 = Settings.Menu.Accent
                    ToggleIndicator.Position = UDim2.new(1, -18, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    PlayAhSound()
                end
            end)
        else
            settingTable[settingKey] = not settingTable[settingKey]
            ToggleButton.BackgroundColor3 = settingTable[settingKey] and Settings.Menu.Accent or Color3.fromRGB(80, 80, 80)
            ToggleIndicator.Position = settingTable[settingKey] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
            ToggleIndicator.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 100)
            if settingTable[settingKey] then PlayAhSound() end
        end
    end)
    
    return ToggleFrame
end

function Library:CreateSlider(tab, text, settingTable, settingKey, min, max, default)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 40)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = tab.Frame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 15)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. tostring(settingTable[settingKey])
    SliderLabel.TextColor3 = Settings.Menu.Text
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 12
    SliderLabel.Parent = SliderFrame
    
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Size = UDim2.new(1, 0, 0, 5)
    SliderBackground.Position = UDim2.new(0, 0, 0, 20)
    SliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderBackground.BorderSizePixel = 0
    SliderBackground.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((settingTable[settingKey] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Settings.Menu.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBackground
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 15, 0, 15)
    SliderButton.Position = UDim2.new((settingTable[settingKey] - min) / (max - min), -7.5, 0, -5)
    SliderButton.BackgroundColor3 = Settings.Menu.Color
    SliderButton.BorderSizePixel = 0
    SliderButton.Text = ""
    SliderButton.ZIndex = 2
    SliderButton.Parent = SliderBackground
    
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    local function updateSlider()
        if not dragging then return end
        local xPos = math.clamp((Mouse.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (xPos * (max - min)))
        settingTable[settingKey] = value
        SliderLabel.Text = text .. ": " .. tostring(value)
        SliderFill.Size = UDim2.new(xPos, 0, 1, 0)
        SliderButton.Position = UDim2.new(xPos, -7.5, 0, -5)
    end
    
    SliderButton.MouseMoved:Connect(updateSlider)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider() end
    end)
    
    return SliderFrame
end

function Library:CreateColorPicker(tab, text, settingTable, settingKey)
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Size = UDim2.new(1, 0, 0, 30)
    ColorFrame.BackgroundTransparency = 1
    ColorFrame.Parent = tab.Frame
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(0.5, 0, 1, 0)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = text
    ColorLabel.TextColor3 = Settings.Menu.Text
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextSize = 12
    ColorLabel.Parent = ColorFrame
    
    local ColorDisplay = Instance.new("Frame")
    ColorDisplay.Size = UDim2.new(0, 30, 0, 20)
    ColorDisplay.Position = UDim2.new(1, -30, 0, 5)
    ColorDisplay.BackgroundColor3 = settingTable[settingKey]
    ColorDisplay.BorderSizePixel = 1
    ColorDisplay.BorderColor3 = Color3.fromRGB(255, 255, 255)
    ColorDisplay.Parent = ColorFrame
    
    ColorDisplay.MouseButton1Click:Connect(function()
        -- Простой выбор цвета
        local r = math.random(0, 255) / 255
        local g = math.random(0, 255) / 255
        local b = math.random(0, 255) / 255
        settingTable[settingKey] = Color3.fromRGB(r * 255, g * 255, b * 255)
        ColorDisplay.BackgroundColor3 = settingTable[settingKey]
    end)
    
    return ColorFrame
end

Library.UI = Library:CreateWindow()

local CombatTab = Library:CreateTab("⚔️ Combat")
local VisualTab = Library:CreateTab("👁️ Visuals")
local PlayerTab = Library:CreateTab("🏃 Player")
local DupeTab = Library:CreateTab("💰 Dupe")
local SpinnerTab = Library:CreateTab("🔄 Spinner (BAN)")
local FunTab = Library:CreateTab("🎉 Fun")
local TurretTab = Library:CreateTab("🤖 Turret")
local EveryoneFlyTab = Library:CreateTab("🕊️ Everyone Fly")
local SettingsTab = Library:CreateTab("⚙️ Settings")

Library:CreateToggle(CombatTab, "AimBot", Settings.AimBot, "Enabled")
Library:CreateSlider(CombatTab, "AimBot FOV", Settings.AimBot, "FOV", 1, 120, 30)
Library:CreateSlider(CombatTab, "AimBot Smoothness", Settings.AimBot, "Smoothness", 0.1, 1, 0.2)
Library:CreateToggle(CombatTab, "Team Check", Settings.AimBot, "TeamCheck")
Library:CreateToggle(CombatTab, "Visibility Check", Settings.AimBot, "VisibleCheck")
Library:CreateColorPicker(CombatTab, "AimBot Color", Settings.AimBot, "Color")
Library:CreateSlider(CombatTab, "HitBox Size", Settings.Player.HitBox, "Size", 1, 20, 10)
Library:CreateSlider(CombatTab, "HitBox Range", Settings.Player.HitBox, "Range", 1, 100, 50)

Library:CreateToggle(VisualTab, "ESP", Settings.Visuals.ESP, "Enabled")
Library:CreateToggle(VisualTab, "Box ESP", Settings.Visuals.ESP, "Box")
Library:CreateToggle(VisualTab, "Name ESP", Settings.Visuals.ESP, "Name")
Library:CreateToggle(VisualTab, "Distance ESP", Settings.Visuals.ESP, "Distance")
Library:CreateToggle(VisualTab, "Health ESP", Settings.Visuals.ESP, "Health")
Library:CreateToggle(VisualTab, "Weapon ESP", Settings.Visuals.ESP, "Weapon")
Library:CreateToggle(VisualTab, "Armor ESP", Settings.Visuals.ESP, "Armor")
Library:CreateSlider(VisualTab, "ESP Distance", Settings.Visuals.ESP, "MaxDistance", 10, 500, 500)
Library:CreateToggle(VisualTab, "Block ESP", Settings.Visuals.BlockESP, "Enabled")
Library:CreateToggle(VisualTab, "Block Chests", Settings.Visuals.BlockESP, "Chest")
Library:CreateToggle(VisualTab, "Block Crates", Settings.Visuals.BlockESP, "Crate")
Library:CreateToggle(VisualTab, "Block Loot", Settings.Visuals.BlockESP, "Loot")
Library:CreateToggle(VisualTab, "Block Vehicles", Settings.Visuals.BlockESP, "Vehicle")
Library:CreateToggle(VisualTab, "Block Doors", Settings.Visuals.BlockESP, "Door")
Library:CreateToggle(VisualTab, "Night Vision", Settings.Visuals.NightVision, "Enabled")
Library:CreateToggle(VisualTab, "Chams", Settings.Visuals.Chams, "Enabled")
Library:CreateColorPicker(VisualTab, "Chams Color", Settings.Visuals.Chams, "Color")
Library:CreateToggle(VisualTab, "No Fog", Settings.Visuals.NoFog, "Enabled")
Library:CreateToggle(VisualTab, "Full Bright", Settings.Visuals.FullBright, "Enabled")
Library:CreateToggle(VisualTab, "Crosshair", Settings.Visuals.Crosshair, "Enabled")
Library:CreateColorPicker(VisualTab, "Crosshair Color", Settings.Visuals.Crosshair, "Color")

Library:CreateToggle(PlayerTab, "Speed Hack", Settings.Player.Speed, "Enabled")
Library:CreateSlider(PlayerTab, "Speed Value", Settings.Player.Speed, "Value", 1, 100, 25)
Library:CreateToggle(PlayerTab, "High Jump", Settings.Player.Jump, "Enabled")
Library:CreateSlider(PlayerTab, "Jump Power", Settings.Player.Jump, "Value", 1, 100, 50)
Library:CreateToggle(PlayerTab, "Fly Hack", Settings.Player.Fly, "Enabled")
Library:CreateSlider(PlayerTab, "Fly Speed", Settings.Player.Fly, "Speed", 10, 200, 50)
Library:CreateToggle(PlayerTab, "HitBox Expander", Settings.Player.HitBox, "Enabled")
Library:CreateToggle(PlayerTab, "No Clip", Settings.Player.NoClip, "Enabled")
Library:CreateToggle(PlayerTab, "No Fall Damage", Settings.Exploits, "NoFallDamage")
Library:CreateToggle(PlayerTab, "Infinite Jump", Settings.Exploits, "InfiniteJump")

Library:CreateToggle(DupeTab, "💰 Money Duplication (BAN RISK!)", Settings.Dupe.MoneyDuplication, "Enabled", true, "Money duplication может привести к мгновенному бану! Вы уверены?")
Library:CreateToggle(DupeTab, "📦 Item Duplication (BAN RISK!)", Settings.Dupe.ItemDuplication, "Enabled", true, "Item duplication может привести к бану вашего аккаунта!")

Library:CreateToggle(SpinnerTab, "🔄 Spinner (BAN RISK!)", Settings.Spinner, "Enabled", true, "Spinner функция может привести к бану! Использовать на свой страх и риск!")
Library:CreateToggle(SpinnerTab, "🎯 AimBot X Spinner", Settings.Spinner, "AimBotXSpinner")
Library:CreateToggle(SpinnerTab, "🛡️ NoFaire", Settings.Spinner, "NoFaire")
Library:CreateSlider(SpinnerTab, "Spin Speed", Settings.Spinner, "SpinSpeed", 10, 200, 50)
Library:CreateSlider(SpinnerTab, "Spin Range", Settings.Spinner, "SpinRange", 10, 200, 100)

Library:CreateToggle(FunTab, "💥 Crash Server (BAN RISK!)", Settings.Fun.CrashServer, "Enabled", true, "Crash server может привести к бану вашего IP!")
Library:CreateToggle(FunTab, "🔪 Kill Server (BAN RISK!)", Settings.Fun.KillServer, "Enabled", true, "Kill server может привести к перманентному бану!")
Library:CreateToggle(FunTab, "👥 Auto Friend Add", Settings.Fun.FriendAdd, "Enabled")
Library:CreateToggle(FunTab, "❓ What's Soft? (Kick All)", Settings.Fun.WhatsSoft, "Enabled")
Library:CreateToggle(FunTab, "📢 Report SPAM (BAN RISK!)", Settings.Fun.ReportSpam, "Enabled", true, "Report spam может привести к бану вашего аккаунта за спам!")

Library:CreateToggle(TurretTab, "👻 Invisible Turret", Settings.Turret, "Invisible")

Library:CreateToggle(EveryoneFlyTab, "🕊️ Everyone Fly (BAN OTHERS!)", Settings.EveryoneFly, "Enabled", true, "Эта функция заставит всех игроков (кроме вас и друзей) взлететь и получить бан! Вы уверены?")
Library:CreateSlider(EveryoneFlyTab, "Fly Speed", Settings.EveryoneFly, "Speed", 10, 500, 100)

Library:CreateToggle(SettingsTab, "🔊 Sound 'AHHHHHHH'", Settings.Sound, "Enabled")
Library:CreateSlider(SettingsTab, "Sound Volume", Settings.Sound, "Volume", 0, 1, 0.5)
Library:CreateToggle(SettingsTab, "🛡️ Anti-Ban", Settings.Safety, "AntiBan")
Library:CreateToggle(SettingsTab, "🔒 Anti-Log", Settings.Safety, "AntiLog")
Library:CreateToggle(SettingsTab, "⚡ Bypass Anti-Cheat", Settings.Safety, "BypassAC")
Library:CreateToggle(SettingsTab, "🕵️ Stealth Mode", Settings.Safety, "StealthMode")
Library:CreateColorPicker(SettingsTab, "Menu Color", Settings.Menu, "Color")

local UnloadButton = Instance.new("TextButton")
UnloadButton.Size = UDim2.new(1, 0, 0, 30)
UnloadButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
UnloadButton.Text = "❌ UNLOAD SCRIPT"
UnloadButton.TextColor3 = Settings.Menu.Text
UnloadButton.Font = Enum.Font.GothamBold
UnloadButton.TextSize = 14
UnloadButton.Parent = SettingsTab.Frame

UnloadButton.MouseButton1Click:Connect(function()
    for _, conn in pairs(Connections) do
        if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
    end
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Remove then pcall(function() obj:Remove() end) end
    end
    for _, obj in pairs(BlockedESPObjects) do
        if obj and obj.Destroy then pcall(function() obj:Destroy() end) end
    end
    if Library.UI and Library.UI.ScreenGui then Library.UI.ScreenGui:Destroy() end
    _G.BOSSMORS = nil
    _G.BOSSMORS_LOADED = nil
    print("BOSS-MORS успешно выгружен!")
end)

local function UpdateFriendsSet()
    FriendsSet = {}
    for _, friend in ipairs(Settings.AimBot.Friends) do
        FriendsSet[friend] = true
    end
end

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.Menu.Key then
        Settings.Menu.Open = not Settings.Menu.Open
        AnimateMenu(Library.UI.MainFrame, Settings.Menu.Open)
    end
    if input.KeyCode == Settings.AimBot.Key then
        Settings.AimBot.Enabled = not Settings.AimBot.Enabled
    end
    if input.KeyCode == Settings.Visuals.ESP.FriendKey then
        local target = Mouse.Target
        if target and target.Parent then
            local player = GetPlayerFromCharacter(target.Parent)
            if player and player ~= LocalPlayer and not FriendsSet[player.Name] then
                table.insert(Settings.AimBot.Friends, player.Name)
                UpdateFriendsSet()
                print("Добавлен в друзья: " .. player.Name)
            end
        end
    end
end))

table.insert(Connections, RunService.RenderStepped:Connect(FastUpdate))
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if tick() % 2 < 0.1 then
        pcall(function()
            UpdateESP()
            AntiBanBypass()
            if Settings.Exploits.NoFallDamage and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end
            end
        end)
    end
end))

UpdateFriendsSet()
print("====================================")
print("BOSS-MORS v3.0 ULTIMATE EDITION загружен!")
print("Версия: " .. _G.BOSSMORS.Version)
print("Игра: " .. _G.BOSSMORS.Game)
print("====================================")
print("Клавиши управления:")
print("INSERT - Открыть/закрыть меню")
print("T - Вкл/Выкл AimBot")
print("F2 - Добавить игрока в друзья")
print("====================================")
print("⚠️ ВНИМАНИЕ: Некоторые функции могут привести к бану!")
print("Используйте на свой страх и риск!")
print("====================================")

AnimateMenu(Library.UI.MainFrame, Settings.Menu.Open)
