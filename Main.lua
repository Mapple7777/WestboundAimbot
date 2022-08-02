-- // Services
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local UserInputService = game:GetService('UserInputService')
local GuiService = game:GetService('GuiService')

-- // Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character.Humanoid
local Mouse = LocalPlayer:GetMouse()
local Head = Character.Head
local Team = LocalPlayer.Team
local UserId = LocalPlayer.UserId

-- // Camera
local Camera = Workspace.CurrentCamera

-- // Variables
local KeyHeld = false
local Player;

-- // Functions
local function GetNearestPlayer()
    local NearestPlayer;
    local Mag;
    for _, Player in next, Players:GetChildren() do
        local PlayerTeam = Player.Team
        local PlayerUserId = Player.UserId
        local PlayerCharacter = Player.Character
        local PlayerHumanoidRootPart = Character.HumanoidRootPart
        local PlayerHumanoid = Character.Humanoid
        local PlayerHealth = PlayerHumanoid.Health
        if Player ~= LocalPlayer and PlayerCharacter and PlayerHumanoidRootPart and PlayerHumanoid and PlayerHealth > 0 then
            if getgenv().Settings.AimbotTeamCheck then
                if PlayerTeam ~= Team then
                    local Vector, OnScreen = Camera:WorldToScreenPoint(Player.Character[getgenv().Settings.AimbotHitPart].Position)
                    local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).magnitude
                    if math.huge > Magnitude and OnScreen and Magnitude < getgenv().Settings.AimbotFOVRadius then 
                        Mag = Magnitude
                        NearestPlayer = Player
                    end
                end
            elseif getgenv().Settings.AimbotFriendCheck then
                if not Player:IsFriendsWith(UserId) then
                    local Vector, OnScreen = Camera:WorldToScreenPoint(Player.Character[getgenv().Settings.AimbotHitPart].Position)
                    local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).magnitude
                    if math.huge > Magnitude and OnScreen and Magnitude < getgenv().Settings.AimbotFOVRadius then 
                        Mag = Magnitude
                        NearestPlayer = Player
                    end
                end
            elseif getgenv().Settings.AimbotWhitelistCheck then
                if not table.find(Settings.AimbotWhitelist, PlayerUserId) then
                    local Vector, OnScreen = Camera:WorldToScreenPoint(Player.Character[getgenv().Settings.AimbotHitPart].Position)
                    local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).magnitude
                    if math.huge > Magnitude and OnScreen and Magnitude < getgenv().Settings.AimbotFOVRadius then 
                        Mag = Magnitude
                        NearestPlayer = Player
                    end
                end 
            else
                local Vector, OnScreen = Camera:WorldToScreenPoint(Player.Character[getgenv().Settings.AimbotHitPart].Position)
                local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).magnitude
                if math.huge > Magnitude and OnScreen and Magnitude < getgenv().Settings.AimbotFOVRadius then 
                    Mag = Magnitude
                    NearestPlayer = Player
                end
            end
        end
    end
    return NearestPlayer
end

local function Wallcheck(Player)
    local Ray = Ray.new(Head.Position, (Player.Position - Head.Position).Unit * 300)
    local Part, Position = Workspace:FindPartOnRayWithIgnoreList(Ray, {Character}, false, true)
    if Part then
        local Humanoid = Part.Parent:FindFirstChildOfClass('Humanoid')
        if not Humanoid then
            Humanoid = Part.Parent.Parent:FindFirstChildOfClass('Humanoid')
        end
        if Humanoid and Player and Humanoid.Parent == Player.Parent then
            local Vector, OnScreen = Camera:WorldToScreenPoint(Player.Position)
            if OnScreen then 
                return true
            end
        end
    end
end

-- // Main
local FOVCircle = Drawing.new('Circle')
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 1

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if not GameProcessedEvent then
        if Input.KeyCode.Name == Settings.AimbotKey then
            KeyHeld = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input, GameProcessedEvent)
    if not GameProcessedEvent then
        if Input.KeyCode.Name == Settings.AimbotKey then
            KeyHeld = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = getgenv().Settings.AimbotShowFOV
    FOVCircle.Radius = getgenv().Settings.AimbotFOVRadius
    FOVCircle.Color = getgenv().Settings.AimbotFOVColor
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + GuiService:GetGuiInset().Y)
    
    if Character then
        if getgenv().Settings.AimbotEnabled and KeyHeld and LocalPlayer:DistanceFromCharacter(GetNearestPlayer().Character[getgenv().Settings.AimbotHitPart].Position) <= getgenv().Settings.AimbotRange then
            if getgenv().Settings.AimbotWallCheck then
                if Wallcheck(GetNearestPlayer().Character.HumanoidRootPart) then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, GetNearestPlayer().Character[getgenv().Settings.AimbotHitPart].Position)
                end
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, GetNearestPlayer().Character[getgenv().Settings.AimbotHitPart].Position)
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Mapple7777/WestboundAimbot/main/Main.lua'))()
end)
