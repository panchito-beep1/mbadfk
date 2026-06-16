-- Gul Library v2
-- Rebuilt with dual-panel layout (Tabs + Content)
local Gul = {}
Gul.__index = Gul

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local function New(class, props)
	local obj = Instance.new(class)
	for k,v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

function Gul:CreateWindow(cfg)
	cfg = cfg or {}

	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local ScreenGui = New("ScreenGui", {
		Name = "GulLibrary",
		ResetOnSpawn = false,
		Parent = PlayerGui
	})

	local Main = New("Frame", {
		Parent = ScreenGui,
		Size = UDim2.fromOffset(820,420),
		Position = UDim2.fromScale(.5,.5),
		AnchorPoint = Vector2.new(.5,.5),
		BackgroundColor3 = Color3.fromRGB(24,24,24)
	})

	New("UICorner",{CornerRadius=UDim.new(0,16),Parent=Main})

	local Tabs = New("Frame",{
		Parent=Main,
		Size=UDim2.fromOffset(240,420),
		BackgroundColor3=Color3.fromRGB(20,20,20)
	})
	New("UICorner",{CornerRadius=UDim.new(0,16),Parent=Tabs})

	local Content = New("Frame",{
		Parent=Main,
		Position=UDim2.fromOffset(250,0),
		Size=UDim2.new(1,-250,1,0),
		BackgroundColor3=Color3.fromRGB(28,28,28)
	})
	New("UICorner",{CornerRadius=UDim.new(0,16),Parent=Content})

	local TabList = New("ScrollingFrame",{
		Parent=Tabs,
		BackgroundTransparency=1,
		Size=UDim2.new(1,0,1,-50),
		CanvasSize=UDim2.new()
	})
	local TL = New("UIListLayout",{Parent=TabList,Padding=UDim.new(0,6)})

	local Window = {}
	Window.Tabs = {}

	function Window:AddTab(Name)
		local Btn = New("TextButton",{
			Parent=TabList,
			Size=UDim2.new(1,-10,0,36),
			Text=Name,
			BackgroundColor3=Color3.fromRGB(35,35,35),
			TextColor3=Color3.new(1,1,1)
		})

		local Page = New("ScrollingFrame",{
			Parent=Content,
			Visible=false,
			Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1,
			CanvasSize=UDim2.new()
		})

		local Layout = New("UIListLayout",{Parent=Page,Padding=UDim.new(0,8)})

		local Tab = {}

		local function addContainer(text)
			local F = New("Frame",{
				Parent=Page,
				Size=UDim2.new(1,-12,0,40),
				BackgroundColor3=Color3.fromRGB(35,35,35)
			})
			New("UICorner",{Parent=F})
			local L = New("TextLabel",{
				Parent=F,
				Text=text,
				BackgroundTransparency=1,
				TextColor3=Color3.new(1,1,1),
				Size=UDim2.new(.7,0,1,0)
			})
			return F,L
		end

		function Tab:AddButton(text,cb)
			local F = addContainer(text)
			F.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 and cb then
					cb()
				end
			end)
		end

		function Tab:AddToggle(text,default,cb)
			local State = default or false
			local F = addContainer(text)
			local B = New("TextButton",{
				Parent=F, Text=State and "ON" or "OFF",
				Size=UDim2.fromOffset(60,24),
				Position=UDim2.new(1,-70,.5,-12)
			})
			B.MouseButton1Click:Connect(function()
				State = not State
				B.Text = State and "ON" or "OFF"
				if cb then cb(State) end
			end)
		end

		function Tab:AddSlider(text,min,max,default,cb)
			local F = addContainer(text)
			local Box = New("TextBox",{
				Parent=F,
				Text=tostring(default or min),
				Size=UDim2.fromOffset(60,24),
				Position=UDim2.new(1,-70,.5,-12)
			})
			Box.FocusLost:Connect(function()
				local v = tonumber(Box.Text) or min
				v = math.clamp(v,min,max)
				Box.Text=tostring(v)
				if cb then cb(v) end
			end)
		end

		function Tab:AddTextbox(text,cb)
			local F = addContainer(text)
			local Box = New("TextBox",{Parent=F,Size=UDim2.fromOffset(120,24),Position=UDim2.new(1,-130,.5,-12)})
			Box.FocusLost:Connect(function()
				if cb then cb(Box.Text) end
			end)
		end

		function Tab:AddDropdown(text,list,cb)
		end

		function Tab:AddColorPicker(text,cb)
		end

		Btn.MouseButton1Click:Connect(function()
			for _,t in pairs(Window.Tabs) do
				t.Page.Visible = false
			end
			Page.Visible = true
		end)

		table.insert(Window.Tabs,{Page=Page})
		if #Window.Tabs == 1 then Page.Visible = true end
		return Tab
	end

	return Window
end

return Gul
