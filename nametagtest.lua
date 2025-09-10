-- Load WindUI (ganti dengan raw URL WindUI kamu)
local WindUILoadURL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/WindUI.lua"
local WindUI = loadstring(game:HttpGet(WindUILoadURL))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Buat window dan tab Admin
local window = WindUI:Window({Title = "Admin Panel", Size = Vector2.new(400, 300)})
local adminTab = window:Tab("Admin")

-- WalkSpeed Control
local walkspeedValue = 16
adminTab:Slider({
    Text = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        walkspeedValue = value
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hrp then
            hrp.WalkSpeed = walkspeedValue
        end
    end
})

-- Fly Mode
local flyEnabled = false
local flySpeed = 50
local bodyVelocity

adminTab:Toggle({
    Text = "Fly Mode",
    Default = false,
    Callback = function(enabled)
        flyEnabled = enabled
        if flyEnabled then
            local character = LocalPlayer.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyVelocity.Velocity = Vector3.new(0,0,0)
            bodyVelocity.Parent = hrp
            
            RunService:BindToRenderStep("Fly", Enum.RenderPriority.Character.Value, function()
                local direction = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.new(0,1,0) end
                
                if direction.Magnitude > 0 then
                    bodyVelocity.Velocity = direction.Unit * flySpeed
                else
                    bodyVelocity.Velocity = Vector3.new(0,0,0)
                end
            end)
        else
            RunService:UnbindFromRenderStep("Fly")
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
        end
    end
})

-- Show Nicknames Except Self
adminTab:Button({
    Text = "Show Nicknames All",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head and not head:FindFirstChild("NicknameGui") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "NicknameGui"
                        billboard.Adornee = head
                        billboard.Size = UDim2.new(0,150,0,50)
                        billboard.StudsOffset = Vector3.new(0,2,0)
                        billboard.AlwaysOnTop = true
                        
                        local label = Instance.new("TextLabel")
                        label.Parent = billboard
                        label.Size = UDim2.new(1,0,1,0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.new(1,1,1)
                        label.TextStrokeColor3 = Color3.new(0,0,0)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.SourceSansBold
                        label.TextSize = 20
                        label.Text = player.DisplayName
                        
                        billboard.Parent = head
                    end
                end
            end
        end
    end
})

-- Infinite Jump Toggle
local infiniteJumpEnabled = false
adminTab:Toggle({
    Text = "Infinite Jump",
    Default = false,
    Callback = function(enabled)
        infiniteJumpEnabled = enabled
    end
})

UserInputService.Jumping:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
