-- GulLibrary.lua
-- A clean Roblox UI library rebuilt from the broken pasted script.
-- Drop this into a ModuleScript and require it from a LocalScript.
--
-- Example:
-- local GuiLib = require(path.To.GulLibrary)
-- local Window = GuiLib:CreateWindow({Title = "My Script"})
-- local Tab = Window:AddTab("Main")
-- Tab:AddButton("Hello", function() print("clicked") end)
-- Tab:AddToggle("Fly", false, function(state) print(state) end)
-- Tab:AddSlider("Speed", 0, 100, 25, function(v) print(v) end)
-- Tab:AddDropdown("Mode", {"A", "B", "C"}, "A", function(v) print(v) end)
-- Tab:AddColorPicker("Accent", Color3.fromRGB(255, 80, 120), function(c) print(c) end)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

Library.Theme = {
	Window = Color3.fromRGB(22, 22, 24),
	Panel = Color3.fromRGB(28, 28, 31),
	Panel2 = Color3.fromRGB(34, 34, 38),
	Stroke = Color3.fromRGB(60, 60, 68),
	Text = Color3.fromRGB(240, 240, 245),
	Muted = Color3.fromRGB(170, 170, 180),
	Accent = Color3.fromRGB(110, 170, 255),
	Accent2 = Color3.fromRGB(80, 120, 200),
	Danger = Color3.fromRGB(255, 95, 95),
	Success = Color3.fromRGB(90, 220, 140),
}

local function create(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local function round(inst, radius)
	return create("UICorner", {
		CornerRadius = radius or UDim.new(0, 8),
		Parent = inst,
	})
end

local function stroke(inst, color, thickness, transparency)
	return create("UIStroke", {
		Color = color or Library.Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0.2,
		Parent = inst,
	})
end

local function padding(inst, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		Parent = inst,
	})
end

local function list(inst, paddingPx, fillDirection, sortOrder)
	return create("UIListLayout", {
		Padding = UDim.new(0, paddingPx or 6),
		FillDirection = fillDirection or Enum.FillDirection.Vertical,
		SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Parent = inst,
	})
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging = false
	local dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end)
end

local function clamp01(n)
	return math.clamp(n, 0, 1)
end

function Library:SetTheme(theme)
	for k, v in pairs(theme or {}) do
		if self.Theme[k] ~= nil and typeof(v) == "Color3" then
			self.Theme[k] = v
		end
	end
	if self._window then
		self:_applyTheme()
	end
end

function Library:_applyTheme()
	local theme = self.Theme
	local window = self._window
	if not window then
		return
	end

	window.Main.BackgroundColor3 = theme.Window
	window.Sidebar.BackgroundColor3 = theme.Panel
	window.Content.BackgroundColor3 = theme.Panel
	window.Title.TextColor3 = theme.Text
	window.SideTitle.TextColor3 = theme.Text
	window.Separator.BackgroundColor3 = theme.Stroke
	window.SideSeparator.BackgroundColor3 = theme.Stroke
	window.ScrollBarColor3 = theme.Accent
end

function Library:CreateWindow(opts)
	opts = opts or {}

	local existing = CoreGui:FindFirstChild("GulLibraryGui")
	if existing then
		existing:Destroy()
	end

	local gui = create("ScreenGui", {
		Name = "GulLibraryGui",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
	})

	local main = create("Frame", {
		Name = "Main",
		Size = UDim2.fromOffset(opts.Width or 760, opts.Height or 480),
		Position = opts.Position or UDim2.new(0.5, -380, 0.5, -240),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = self.Theme.Window,
		BorderSizePixel = 0,
		Parent = gui,
	})
	round(main, UDim.new(0, 18))
	stroke(main, self.Theme.Stroke, 1, 0.35)

	local top = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = main,
	})

	local title = create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 10),
		Size = UDim2.new(1, -36, 0, 28),
		Font = Enum.Font.GothamSemibold,
		Text = opts.Title or "Gul Library",
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.Theme.Text,
		Parent = top,
	})

	local subtitle = create("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 28),
		Size = UDim2.new(1, -36, 0, 16),
		Font = Enum.Font.Gotham,
		Text = opts.Subtitle or "Clean controls, no spaghetti vines.",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.Theme.Muted,
		Parent = top,
	})

	local separator = create("Frame", {
		Name = "Separator",
		Size = UDim2.new(1, -24, 0, 1),
		Position = UDim2.new(0, 12, 0, 50),
		BackgroundColor3 = self.Theme.Stroke,
		BorderSizePixel = 0,
		Parent = main,
	})

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 190, 1, -62),
		Position = UDim2.fromOffset(12, 56),
		BackgroundColor3 = self.Theme.Panel,
		BorderSizePixel = 0,
		Parent = main,
	})
	round(sidebar, UDim.new(0, 14))
	stroke(sidebar, self.Theme.Stroke, 1, 0.45)
	padding(sidebar, 10, 10, 10, 10)

	local sideTitle = create("TextLabel", {
		Name = "SideTitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.GothamSemibold,
		Text = "Tabs",
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.Theme.Text,
		Parent = sidebar,
	})

	local sideSeparator = create("Frame", {
		Name = "SideSeparator",
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = self.Theme.Stroke,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	local tabsHolder = create("ScrollingFrame", {
		Name = "TabsHolder",
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 1, -28),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = self.Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	})
	list(tabsHolder, 8)

	local content = create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -226, 1, -62),
		Position = UDim2.fromOffset(214, 56),
		BackgroundColor3 = self.Theme.Panel,
		BorderSizePixel = 0,
		Parent = main,
	})
	round(content, UDim.new(0, 14))
	stroke(content, self.Theme.Stroke, 1, 0.45)
	padding(content, 12, 12, 12, 12)

	local pages = create("Folder", {
		Name = "Pages",
		Parent = content,
	})

	local pageTop = create("TextLabel", {
		Name = "PageTitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Font = Enum.Font.GothamSemibold,
		Text = "Select a tab",
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.Theme.Text,
		Parent = content,
	})

	local pageSub = create("TextLabel", {
		Name = "PageSubtitle",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, 0, 0, 16),
		Font = Enum.Font.Gotham,
		Text = "Pick a tab on the left.",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.Theme.Muted,
		Parent = content,
	})

	local pageSeparator = create("Frame", {
		Name = "Separator",
		Position = UDim2.fromOffset(0, 42),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = self.Theme.Stroke,
		BorderSizePixel = 0,
		Parent = content,
	})

	local pageHost = create("ScrollingFrame", {
		Name = "PageHost",
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(1, 0, 1, -52),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = self.Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = content,
	})
	list(pageHost, 10)

	makeDraggable(main, top)

	local window = {
		Gui = gui,
		Main = main,
		Sidebar = sidebar,
		Content = content,
		Title = title,
		Subtitle = subtitle,
		Separator = separator,
		SideTitle = sideTitle,
		SideSeparator = sideSeparator,
		ScrollBarColor3 = self.Theme.Accent,
		Tabs = {},
		CurrentTab = nil,
		Theme = self.Theme,
	}

	self._window = window
	self:_applyTheme()

	local function setActiveTab(tab)
		for _, t in ipairs(window.Tabs) do
			local active = (t == tab)
			t.Button.BackgroundColor3 = active and self.Theme.Accent or self.Theme.Panel2
			t.Button.TextColor3 = active and Color3.new(1, 1, 1) or self.Theme.Text
			t.Page.Visible = active
		end
		window.CurrentTab = tab
		pageTop.Text = tab.Name
		pageSub.Text = tab.Description or "Ready."
	end

	local windowMethods = {}

	function windowMethods:AddTab(name, description)
		local tabName = tostring(name or "Tab")

		local tabButton = create("TextButton", {
			Name = tabName .. "Button",
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = self.Theme.Panel2,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.GothamSemibold,
			Text = tabName,
			TextSize = 14,
			TextColor3 = self.Theme.Text,
			Parent = tabsHolder,
		})
		round(tabButton, UDim.new(0, 10))
		stroke(tabButton, self.Theme.Stroke, 1, 0.6)

		local page = create("ScrollingFrame", {
			Name = tabName .. "Page",
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = self.Theme.Accent,
			Visible = false,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = pages,
		})
		list(page, 10)

		local pageLayout = list(page, 10)
		local sectionCount = 0

		local tab = {
			Name = tabName,
			Description = description,
			Button = tabButton,
			Page = page,
		}

		local function wrapElement(root)
			local holder = create("Frame", {
				Name = "Element",
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundColor3 = Library.Theme.Panel2,
				BorderSizePixel = 0,
				Parent = page,
			})
			round(holder, UDim.new(0, 12))
			stroke(holder, Library.Theme.Stroke, 1, 0.65)
			padding(holder, 10, 10, 8, 8)
			return holder
		end

		local function makeRow(height)
			local row = create("Frame", {
				Size = UDim2.new(1, 0, 0, height or 42),
				BackgroundColor3 = Library.Theme.Panel2,
				BorderSizePixel = 0,
				Parent = page,
			})
			round(row, UDim.new(0, 12))
			stroke(row, Library.Theme.Stroke, 1, 0.65)
			padding(row, 10, 10, 8, 8)
			return row
		end

		function tab:AddSection(text)
			sectionCount += 1
			local section = create("Frame", {
				Name = "Section" .. sectionCount,
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1,
				Parent = page,
			})
			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.GothamSemibold,
				Text = tostring(text or "Section"),
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Library.Theme.Text,
				Parent = section,
			})
			return section
		end

		function tab:AddLabel(text)
			local row = makeRow(38)
			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.Gotham,
				Text = tostring(text or "Label"),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Library.Theme.Text,
				Parent = row,
			})
			return {
				Instance = label,
				Set = function(_, newText)
					label.Text = tostring(newText)
				end,
			}
		end

		function tab:AddButton(text, callback)
			local row = makeRow(42)
			local btn = create("TextButton", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				AutoButtonColor = false,
				Font = Enum.Font.GothamSemibold,
				Text = tostring(text or "Button"),
				TextSize = 14,
				TextColor3 = Library.Theme.Text,
				Parent = row,
			})
			btn.MouseEnter:Connect(function()
				tween(row, TweenInfo.new(0.15), {BackgroundColor3 = Library.Theme.Accent})
				tween(btn, TweenInfo.new(0.15), {TextColor3 = Color3.new(1, 1, 1)})
			end)
			btn.MouseLeave:Connect(function()
				tween(row, TweenInfo.new(0.15), {BackgroundColor3 = Library.Theme.Panel2})
				tween(btn, TweenInfo.new(0.15), {TextColor3 = Library.Theme.Text})
			end)
			btn.MouseButton1Click:Connect(function()
				if callback then
					task.spawn(callback)
				end
			end)
			return btn
		end

		function tab:AddToggle(text, default, callback)
			local state = default and true or false
			local row = makeRow(44)

			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -60, 1, 0),
				Font = Enum.Font.Gotham,
				Text = tostring(text or "Toggle"),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Library.Theme.Text,
				Parent = row,
			})

			local toggleBtn = create("TextButton", {
				Size = UDim2.fromOffset(42, 24),
				Position = UDim2.new(1, -42, 0.5, -12),
				BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Stroke,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				Parent = row,
			})
			round(toggleBtn, UDim.new(1, 0))
			stroke(toggleBtn, nil, 0, 1)

			local knob = create("Frame", {
				Size = UDim2.fromOffset(18, 18),
				Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Parent = toggleBtn,
			})
			round(knob, UDim.new(1, 0))

			local function set(newState)
				state = newState and true or false
				tween(toggleBtn, TweenInfo.new(0.15), {
					BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Stroke,
				})
				tween(knob, TweenInfo.new(0.15), {
					Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
				})
				if callback then
					task.spawn(callback, state)
				end
			end

			toggleBtn.MouseButton1Click:Connect(function()
				set(not state)
			end)

			if callback then
				task.defer(callback, state)
			end

			return {
				Set = set,
				Get = function()
					return state
				end,
			}
		end

		function tab:AddTextbox(text, placeholder, callback)
			local row = makeRow(56)
			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Font = Enum.Font.Gotham,
				Text = tostring(text or "Textbox"),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Library.Theme.Text,
				Parent = row,
			})

			local box = create("TextBox", {
				Position = UDim2.fromOffset(0, 22),
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundColor3 = Library.Theme.Panel,
				TextColor3 = Library.Theme.Text,
				PlaceholderColor3 = Library.Theme.Muted,
				PlaceholderText = tostring(placeholder or "Type here"),
				Text = "",
				ClearTextOnFocus = false,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				BorderSizePixel = 0,
				Parent = row,
			})
			round(box, UDim.new(0, 8))
			stroke(box, Library.Theme.Stroke, 1, 0.75)

			box.FocusLost:Connect(function(enterPressed)
				if callback then
					task.spawn(callback, box.Text, enterPressed)
				end
			end)

			return {
				Instance = box,
				Set = function(_, value)
					box.Text = tostring(value or "")
				end,
				Get = function()
					return box.Text
				end,
			}
		end

		function tab:AddSlider(text, min, max, default, callback)
			min = tonumber(min) or 0
			max = tonumber(max) or 100
			if max < min then
				min, max = max, min
			end

			local value = math.clamp(tonumber(default) or min, min, max)
			local row = makeRow(58)

			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Font = Enum.Font.Gotham,
				Text = string.format("%s: %s", tostring(text or "Slider"), tostring(value)),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Library.Theme.Text,
				Parent = row,
			})

			local bar = create("Frame", {
				Position = UDim2.fromOffset(0, 30),
				Size = UDim2.new(1, 0, 0, 12),
				BackgroundColor3 = Library.Theme.Stroke,
				BorderSizePixel = 0,
				Parent = row,
			})
			round(bar, UDim.new(1, 0))

			local fill = create("Frame", {
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = Library.Theme.Accent,
				BorderSizePixel = 0,
				Parent = bar,
			})
			round(fill, UDim.new(1, 0))

			local knob = create("TextButton", {
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Text = "",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = bar,
			})
			round(knob, UDim.new(1, 0))

			local dragging = false

			local function set(newValue)
				value = math.clamp(math.floor(newValue + 0.5), min, max)
				local pct = (value - min) / (max - min)
				fill.Size = UDim2.new(pct, 0, 1, 0)
				knob.Position = UDim2.new(pct, -8, 0.5, -8)
				label.Text = string.format("%s: %s", tostring(text or "Slider"), tostring(value))
				if callback then
					task.spawn(callback, value)
				end
			end

			local function updateFromX(x)
				local pct = clamp01((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X)
				set(min + ((max - min) * pct))
			end

			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateFromX(input.Position.X)
				end
			end)
			knob.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateFromX(input.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			task.defer(function()
				if callback then
					callback(value)
				end
			end)

			return {
				Set = set,
				Get = function()
					return value
				end,
			}
		end

		function tab:AddDropdown(text, options, default, callback)
			options = options or {}
			local selected = default
			if selected == nil and #options > 0 then
				selected = options[1]
			end

			local open = false
			local row = makeRow(44)
			row.ClipsDescendants = true
			local label = create("TextButton", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Font = Enum.Font.Gotham,
				Text = string.format("%s: %s", tostring(text or "Dropdown"), tostring(selected or "None")),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Library.Theme.Text,
				AutoButtonColor = false,
				Parent = row,
			})
			local arrow = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -20, 0, 0),
				Size = UDim2.fromOffset(20, 18),
				Font = Enum.Font.GothamSemibold,
				Text = "⌄",
				TextSize = 18,
				TextColor3 = Library.Theme.Muted,
				Parent = row,
			})

			local listHolder = create("Frame", {
				Position = UDim2.fromOffset(0, 24),
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				Parent = row,
			})
			local optionsFrame = create("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				Parent = listHolder,
			})
			list(optionsFrame, 6)

			for _, opt in ipairs(options) do
				local optBtn = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = Library.Theme.Panel,
					Text = tostring(opt),
					TextColor3 = Library.Theme.Text,
					Font = Enum.Font.Gotham,
					TextSize = 13,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Parent = optionsFrame,
				})
				round(optBtn, UDim.new(0, 8))
				stroke(optBtn, Library.Theme.Stroke, 1, 0.75)
				optBtn.MouseButton1Click:Connect(function()
					selected = opt
					label.Text = string.format("%s: %s", tostring(text or "Dropdown"), tostring(selected))
					open = false
					listHolder.Size = UDim2.new(1, 0, 0, 0)
					row.Size = UDim2.new(1, 0, 0, 44)
					if callback then
						task.spawn(callback, selected)
					end
				end)
			end

			local function toggleOpen()
				open = not open
				local height = open and (24 + math.min(#options, 6) * 36) or 0
				listHolder.Size = UDim2.new(1, 0, 0, height)
				row.Size = UDim2.new(1, 0, 0, open and (44 + height) or 44)
				arrow.Text = open and "⌃" or "⌄"
			end

			label.MouseButton1Click:Connect(toggleOpen)

			task.defer(function()
				if callback and selected ~= nil then
					callback(selected)
				end
			end)

			return {
				Set = function(_, value)
					selected = value
					label.Text = string.format("%s: %s", tostring(text or "Dropdown"), tostring(selected))
				end,
				Get = function()
					return selected
				end,
			}
		end

		function tab:AddColorPicker(text, defaultColor, callback)
			local current = typeof(defaultColor) == "Color3" and defaultColor or Color3.fromRGB(255, 255, 255)
			local row = makeRow(52)
			row.ClipsDescendants = true

			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -52, 0, 18),
				Font = Enum.Font.Gotham,
				Text = tostring(text or "Color Picker"),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Library.Theme.Text,
				Parent = row,
			})

			local preview = create("TextButton", {
				Position = UDim2.new(1, -40, 0, 4),
				Size = UDim2.fromOffset(32, 32),
				BackgroundColor3 = current,
				Text = "",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = row,
			})
			round(preview, UDim.new(0, 8))
			stroke(preview, Library.Theme.Stroke, 1, 0.75)

			local popup = create("Frame", {
				Position = UDim2.fromOffset(0, 38),
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = Library.Theme.Panel,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Visible = false,
				Parent = row,
			})
			round(popup, UDim.new(0, 10))
			stroke(popup, Library.Theme.Stroke, 1, 0.7)
			padding(popup, 10, 10, 10, 10)
			local popupList = list(popup, 8)

			local function channelSlider(channelName, initial)
				local wrapper = create("Frame", {
					Size = UDim2.new(1, 0, 0, 42),
					BackgroundTransparency = 1,
					Parent = popup,
				})
				local txt = create("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 16),
					Font = Enum.Font.Gotham,
					Text = string.format("%s: %d", channelName, initial),
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = Library.Theme.Text,
					Parent = wrapper,
				})
				local bar = create("Frame", {
					Position = UDim2.fromOffset(0, 20),
					Size = UDim2.new(1, 0, 0, 10),
					BackgroundColor3 = Library.Theme.Stroke,
					BorderSizePixel = 0,
					Parent = wrapper,
				})
				round(bar, UDim.new(1, 0))
				local fill = create("Frame", {
					Size = UDim2.new(initial / 255, 0, 1, 0),
					BackgroundColor3 = Library.Theme.Accent,
					BorderSizePixel = 0,
					Parent = bar,
				})
				round(fill, UDim.new(1, 0))
				local knob = create("TextButton", {
					Size = UDim2.fromOffset(14, 14),
					Position = UDim2.new(initial / 255, -7, 0.5, -7),
					Text = "",
					AutoButtonColor = false,
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Parent = bar,
				})
				round(knob, UDim.new(1, 0))
				stroke(knob, nil, 0, 1)

				local dragging = false
				local setChannel

				local function refreshDisplay(v)
					txt.Text = string.format("%s: %d", channelName, v)
					if channelName == "R" then
						current = Color3.fromRGB(v, math.floor(current.G * 255), math.floor(current.B * 255))
					elseif channelName == "G" then
						current = Color3.fromRGB(math.floor(current.R * 255), v, math.floor(current.B * 255))
					elseif channelName == "B" then
						current = Color3.fromRGB(math.floor(current.R * 255), math.floor(current.G * 255), v)
					end
					preview.BackgroundColor3 = current
					if callback then
						task.spawn(callback, current)
					end
				end

				local function set(v)
					v = math.clamp(math.floor(v + 0.5), 0, 255)
					fill.Size = UDim2.new(v / 255, 0, 1, 0)
					knob.Position = UDim2.new(v / 255, -7, 0.5, -7)
					refreshDisplay(v)
				end
				setChannel = set

				local function updateFromX(x)
					local pct = clamp01((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X)
					setChannel(pct * 255)
				end

				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						updateFromX(input.Position.X)
					end
				end)
				knob.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						updateFromX(input.Position.X)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				return set
			end

			local rSet = channelSlider("R", math.floor(current.R * 255))
			local gSet = channelSlider("G", math.floor(current.G * 255))
			local bSet = channelSlider("B", math.floor(current.B * 255))

			local function sync(color)
				current = color
				preview.BackgroundColor3 = current
				if callback then
					task.spawn(callback, current)
				end
			end

			local openState = false
			local function togglePopup()
				openState = not openState
				popup.Visible = true
				local target = openState and UDim2.new(1, 0, 0, 160) or UDim2.new(1, 0, 0, 0)
				tween(popup, TweenInfo.new(0.2), {Size = target})
				if not openState then
					task.delay(0.2, function()
						if not openState then
							popup.Visible = false
						end
					end)
				end
			end

			preview.MouseButton1Click:Connect(togglePopup)
			label.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					togglePopup()
				end
			end)

			local function set(color)
				if typeof(color) ~= "Color3" then
					return
				end
				current = color
				preview.BackgroundColor3 = color
				local r = math.floor(color.R * 255)
				local g = math.floor(color.G * 255)
				local b = math.floor(color.B * 255)
				rSet(r)
				gSet(g)
				bSet(b)
				sync(Color3.fromRGB(r, g, b))
			end

			task.defer(function()
				if callback then
					callback(current)
				end
			end)

			return {
				Set = set,
				Get = function()
					return current
				end,
			}
		end

		table.insert(window.Tabs, tab)

		tabButton.MouseButton1Click:Connect(function()
			setActiveTab(tab)
		end)

		if not window.CurrentTab then
			setActiveTab(tab)
		else
			page.Visible = false
		end

		return tab
	end

	function windowMethods:Destroy()
		if gui then
			gui:Destroy()
		end
		if self == window then
			Library._window = nil
		end
	end

	function windowMethods:SetTitle(newTitle)
		title.Text = tostring(newTitle or title.Text)
	end

	function windowMethods:SetSubtitle(newSubtitle)
		subtitle.Text = tostring(newSubtitle or subtitle.Text)
	end

	function windowMethods:SetAccent(color)
		if typeof(color) == "Color3" then
			Library.Theme.Accent = color
			Library:_applyTheme()
		end
	end

	windowMethods.__index = windowMethods

	setmetatable(window, windowMethods)
	return window
end

return setmetatable(Library, Library)
