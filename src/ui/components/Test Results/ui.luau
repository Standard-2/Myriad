local cascade = require("@packages/cascade")

local FONT_BOLD = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold)
local FONT_MEDIUM = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium)
local FONT_REG = Font.new("rbxassetid://12187365364")

local TONE = {
	pass = {
		icon = cascade.Symbols.checkmark,
		color = function(theme)
			return theme.Controls.Zoom
		end,
	},
	fail = {
		icon = cascade.Symbols.xmark,
		color = function(theme)
			return theme.Accents.Red
		end,
	},
	warn = {
		icon = cascade.Symbols.questionmark,
		color = function(theme)
			return theme.Controls.Minimize
		end,
	},
}

local function host(object)
	if typeof(object) == "Instance" then
		return object
	end
	return object.__instance
end

return function(self, properties: any, actions)
	local creator = cascade.Creator
	local binder = cascade.Binder
	local create = creator.Create
	local theme = self.Theme

	local parent = self.__container or self.__instance or self
	local structures = {}

	structures.Body = binder.Apply({}, create("Frame")({
		Name = "TestResults",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,

		create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),
		create("UIPadding")({
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 8),
		}),
	}))

	local body = host(structures.Body)

	local header = create("Frame")({
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = body,

		create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 12),
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		}),
	})
	local headerHost = host(header)

	local titleCluster = create("Frame")({
		Name = "TitleCluster",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 1,
		Parent = headerHost,

		create("UIFlexItem")({
			FlexMode = Enum.UIFlexMode.None,
		}),

		create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local titleHost = host(titleCluster)

	create("TextLabel")({
		Name = "Title",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		FontFace = FONT_BOLD,
		TextSize = 16,
		Text = "Results",
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		Parent = titleHost,
		__dynamicKeys = {
			TextColor3 = theme.Text.Primary[1],
			TextTransparency = theme.Text.Primary[2],
		},
	})

	structures.CountPill = create("Frame")({
		Name = "CountPill",
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		BorderSizePixel = 0,
		Visible = false,
		LayoutOrder = 2,
		Parent = titleHost,
		__dynamicKeys = {
			BackgroundColor3 = theme.Controls.MenuButton.IndicatorBackground[1],
			BackgroundTransparency = theme.Controls.MenuButton.IndicatorBackground[2],
		},

		create("UICorner")({ CornerRadius = UDim.new(0, 8) }),
		create("UIPadding")({
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
		}),
	})

	structures.CountLabel = create("TextLabel")({
		Name = "Count",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		FontFace = FONT_MEDIUM,
		TextSize = 11,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = host(structures.CountPill),
		__dynamicKeys = {
			TextColor3 = theme.Text.Secondary[1],
			TextTransparency = theme.Text.Secondary[2],
		},
	})

	local trailing = create("Frame")({
		Name = "Trailing",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
		LayoutOrder = 2,
		Parent = headerHost,

		create("UIFlexItem")({
			FlexMode = Enum.UIFlexMode.Fill,
		}),
		create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
	})
	local trailingHost = host(trailing)

	local controls = self:HStack({
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		LayoutOrder = 1,
	})
	local controlsHost = host(controls)
	controlsHost.AutomaticSize = Enum.AutomaticSize.XY
	controlsHost.BackgroundTransparency = 1
	controlsHost.Parent = trailingHost

	local tweenService = game:GetService("TweenService")
	local focusIn = TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local focusOut = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	local search = create("Frame")({
		Name = "Filter",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(168, 28),
		LayoutOrder = 1,
		Parent = controlsHost,

		create("UICorner")({
			Name = "Corner",
			CornerRadius = UDim.new(0, 6),
		}),
		create("UIStroke")({
			Name = "Stroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1,
			__dynamicKeys = {
				Color = theme.Controls.ViewBorder[1],
				Transparency = theme.Controls.ViewBorder[2],
			},
		}),
		create("UIPadding")({
			PaddingLeft = UDim.new(0, 7),
			PaddingRight = UDim.new(0, 7),
		}),
		create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
		create("ImageLabel")({
			Name = "Icon",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			Image = cascade.Symbols.magnifyingglass,
			ScaleType = Enum.ScaleType.Fit,
			LayoutOrder = 1,
			__dynamicKeys = {
				ImageColor3 = theme.Text.PrimaryAccent[1],
				ImageTransparency = theme.Text.PrimaryAccent[2],
			},
		}),
	})
	local searchHost = host(search)
	local searchStroke = searchHost:FindFirstChild("Stroke")
	local searchField = create("TextBox")({
		Name = "Field",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(120, 20),
		FontFace = FONT_REG,
		TextSize = 14,
		Text = "",
		PlaceholderText = "Filter checks...",
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = 2,
		Parent = searchHost,
		__dynamicKeys = {
			PlaceholderColor3 = theme.Text.Tertiary[1],
		},
	})
	local searchBox = host(searchField)
	local focusTween = nil
	local function paintSearchText()
		if searchBox.Text == "" then
			searchBox.PlaceholderColor3 = theme.Text.Tertiary[1].Value
			searchBox.TextColor3 = theme.Text.Tertiary[1].Value
			searchBox.TextTransparency = theme.Text.Tertiary[2].Value
		else
			searchBox.TextColor3 = theme.Text.Primary[1].Value
			searchBox.TextTransparency = theme.Text.Primary[2].Value
		end
	end
	paintSearchText()
	theme.Text.Tertiary[1]:Connect(paintSearchText)
	theme.Text.Primary[1]:Connect(paintSearchText)
	theme.Text.Tertiary[2]:Connect(paintSearchText)
	theme.Text.Primary[2]:Connect(paintSearchText)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		paintSearchText()
		actions.onQuery(searchBox.Text)
	end)
	searchBox.Focused:Connect(function()
		if focusTween then
			focusTween:Cancel()
		end
		focusTween = tweenService:Create(searchStroke, focusIn, {
			Color = theme.Controls.SelectionStroke[1].Value,
			Transparency = theme.Controls.SelectionStroke[2].Value,
			Thickness = 3,
		})
		focusTween:Play()
	end)
	searchBox.FocusLost:Connect(function()
		if focusTween then
			focusTween:Cancel()
		end
		focusTween = tweenService:Create(searchStroke, focusOut, {
			Color = theme.Controls.ViewBorder[1].Value,
			Transparency = theme.Controls.ViewBorder[2].Value,
			Thickness = 1,
		})
		focusTween:Play()
	end)
	structures.Filter = search

	structures.Status = controls:PopUpButton({
		Options = actions.statusOptions,
		Value = 1,
		LayoutOrder = 2,
		ValueChanged = function(_button, value)
			actions.onStatus(value)
		end,
	})

	create("TextLabel")({
		Name = "TimesLabel",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		FontFace = FONT_REG,
		TextSize = 13,
		Text = "Times",
		LayoutOrder = 4,
		Parent = controlsHost,
		__dynamicKeys = {
			TextColor3 = theme.Text.Secondary[1],
			TextTransparency = theme.Text.Secondary[2],
		},
	})

	controls:Toggle({
		Value = true,
		LayoutOrder = 5,
		ValueChanged = function(_toggle, value)
			actions.onTimes(value)
		end,
	})

	controls:Button({
		Label = "Copy",
		State = "Secondary",
		LayoutOrder = 6,
		Pushed = function()
			actions.onCopy()
		end,
	})

	structures.SummaryLabel = create("TextLabel")({
		Name = "Summary",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		FontFace = FONT_REG,
		TextSize = 13,
		Text = "",
		RichText = true,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		Parent = body,
		__dynamicKeys = {
			TextColor3 = theme.Text.Secondary[1],
			TextTransparency = theme.Text.Secondary[2],
		},
	})

	create("Frame")({
		Name = "Separator",
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		LayoutOrder = 3,
		Parent = body,
		__dynamicKeys = {
			BackgroundColor3 = theme.Controls.ViewBorder[1],
			BackgroundTransparency = theme.Controls.ViewBorder[2],
		},
	})

	structures.List = create("Frame")({
		Name = "List",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 4,
		Parent = body,

		create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
	})

	local listHost = host(structures.List)
	local groupHosts = {}

	local function clearList()
		table.clear(groupHosts)
		for _, child in listHost:GetChildren() do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
	end

	local function toneColor(toneName)
		return TONE[toneName].color(theme)
	end

	local function buildRow(entry, order, parentInstance, elapsedOut)
		local tone = TONE[entry.tone]
		local color = toneColor(entry.tone)

		local row = create("Frame")({
			Name = `Row_{entry.name}`,
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundTransparency = 1,
			LayoutOrder = order,
			Parent = parentInstance,

			create("UIPadding")({
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
			}),
			create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			}),
		})
		local rowHost = host(row)

		local icon = create("ImageLabel")({
			Name = "Icon",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			Image = tone.icon,
			ScaleType = Enum.ScaleType.Fit,
			LayoutOrder = 1,
			Parent = rowHost,
			__dynamicKeys = {
				ImageColor3 = color[1],
				ImageTransparency = color[2],
			},
		})
		create("UIFlexItem")({
			FlexMode = Enum.UIFlexMode.None,
			Parent = host(icon),
		})

		local name = create("TextLabel")({
			Name = "Name",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			FontFace = FONT_REG,
			TextSize = 14,
			Text = entry.name,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			LayoutOrder = 3,
			Parent = rowHost,
			__dynamicKeys = {
				TextColor3 = theme.Text.Primary[1],
				TextTransparency = theme.Text.Primary[2],
			},
		})
		create("UIFlexItem")({
			FlexMode = Enum.UIFlexMode.Fill,
			Parent = host(name),
		})

		if entry.docsUrl then
			local docsButton = create("ImageButton")({
				Name = "Docs",
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Size = UDim2.fromOffset(16, 16),
				Image = cascade.Symbols.link,
				ScaleType = Enum.ScaleType.Fit,
				LayoutOrder = 2,
				Parent = rowHost,
				__dynamicKeys = {
					ImageColor3 = theme.Text.Secondary[1],
					ImageTransparency = theme.Text.Secondary[2],
				},
			})
			create("UIFlexItem")({
				FlexMode = Enum.UIFlexMode.None,
				Parent = host(docsButton),
			})
			host(docsButton).MouseButton1Click:Connect(function()
				actions.onDocs(entry.docsUrl)
			end)
		end

		local trailing = create("Frame")({
			Name = "Trailing",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 22),
			LayoutOrder = 4,
			Parent = rowHost,

			create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
			}),
		})
		local trailingHost = host(trailing)
		create("UIFlexItem")({
			FlexMode = Enum.UIFlexMode.None,
			Parent = trailingHost,
		})

		if entry.showMessage then
			create("Frame")({
				Name = "Message",
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 0.86,
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Parent = trailingHost,
				__dynamicKeys = {
					BackgroundColor3 = color[1],
				},

				create("UICorner")({ CornerRadius = UDim.new(0, 9) }),
				create("UIPadding")({
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 3),
					PaddingBottom = UDim.new(0, 3),
				}),
				create("TextLabel")({
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.XY,
					Size = UDim2.fromOffset(0, 0),
					FontFace = FONT_MEDIUM,
					TextSize = 12,
					Text = entry.message,
					TextWrapped = false,
					__dynamicKeys = {
						TextColor3 = color[1],
						TextTransparency = color[2],
					},
				}),
			})
		end

		local elapsedFolder = create("Folder")({
			Name = "LayoutIgnore",
			Parent = trailingHost,
		})
		local elapsed = create("TextLabel")({
			Name = "Elapsed",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 18),
			FontFace = FONT_REG,
			TextSize = 12,
			Text = entry.elapsedText or "",
			LayoutOrder = 2,
			Parent = if entry.showTimes then trailingHost else host(elapsedFolder),
			__dynamicKeys = {
				TextColor3 = theme.Text.Tertiary[1],
				TextTransparency = theme.Text.Tertiary[2],
			},
		})
		table.insert(elapsedOut, {
			label = host(elapsed),
			parent = trailingHost,
			folder = host(elapsedFolder),
		})

		create("TextLabel")({
			Name = "Status",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 18),
			FontFace = FONT_MEDIUM,
			TextSize = 12,
			Text = tostring(entry.status),
			LayoutOrder = 3,
			Parent = trailingHost,
			__dynamicKeys = {
				TextColor3 = color[1],
				TextTransparency = color[2],
			},
		})
	end

	local dropInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	local function buildGroup(group, order)
		local color = toneColor(group.tone)
		local open = group.expanded
		local card = create("Frame")({
			Name = `Group_{group.name}`,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			LayoutOrder = order,
			Parent = listHost,
			__dynamicKeys = {
				BackgroundColor3 = theme.Controls.View[1],
				BackgroundTransparency = theme.Controls.View[2],
			},

			create("UICorner")({ CornerRadius = UDim.new(0, 6) }),
			create("UIStroke")({
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				__dynamicKeys = {
					Color = theme.Controls.ViewBorder[1],
					Transparency = theme.Controls.ViewBorder[2],
				},
			}),
			create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),
		})
		local cardHost = host(card)

		local headerButton = create("TextButton")({
			Name = "Header",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = 1,
			Parent = cardHost,
		})
		local headerButtonHost = host(headerButton)
		headerButtonHost.MouseButton1Click:Connect(function()
			actions.onToggle(group.name)
		end)

		create("Frame")({
			Name = "Dot",
			Size = UDim2.fromOffset(8, 8),
			Position = UDim2.new(0, 12, 0.5, -4),
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = headerButtonHost,
			__dynamicKeys = {
				BackgroundColor3 = color[1],
				BackgroundTransparency = color[2],
			},
			create("UICorner")({ CornerRadius = UDim.new(1, 0) }),
		})

		create("TextLabel")({
			Name = "Name",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -160, 1, 0),
			Position = UDim2.fromOffset(28, 0),
			FontFace = FONT_MEDIUM,
			TextSize = 14,
			Text = group.name,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = headerButtonHost,
			__dynamicKeys = {
				TextColor3 = theme.Text.Primary[1],
				TextTransparency = theme.Text.Primary[2],
			},
		})

		create("Frame")({
			Name = "Badge",
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.fromOffset(0, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -36, 0.5, 0),
			BorderSizePixel = 0,
			Parent = headerButtonHost,
			__dynamicKeys = {
				BackgroundColor3 = theme.Controls.MenuButton.IndicatorBackground[1],
				BackgroundTransparency = theme.Controls.MenuButton.IndicatorBackground[2],
			},

			create("UICorner")({ CornerRadius = UDim.new(0, 6) }),
			create("UIPadding")({
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			}),
			create("TextLabel")({
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromOffset(0, 0),
				FontFace = FONT_MEDIUM,
				TextSize = 12,
				Text = `{group.passed}/{group.total}`,
				__dynamicKeys = {
					TextColor3 = theme.Text.Secondary[1],
					TextTransparency = theme.Text.Secondary[2],
				},
			}),
		})

		local chevron = create("ImageLabel")({
			Name = "Chevron",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Image = cascade.Symbols.chevronDown,
			Rotation = if open then 180 else 0,
			ScaleType = Enum.ScaleType.Fit,
			Parent = headerButtonHost,
			__dynamicKeys = {
				ImageColor3 = theme.Text.Secondary[1],
				ImageTransparency = theme.Text.Secondary[2],
			},
		})
		local chevronHost = host(chevron)
		local bodyHeight = 1 + (#group.entries * 34)
		local elapsedLabels = {}
		local clip = create("Frame")({
			Name = "Clip",
			ClipsDescendants = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = if open then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
			LayoutOrder = 2,
			Parent = cardHost,
		})
		local clipHost = host(clip)
		local content = create("Frame")({
			Name = "Content",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = clipHost,

			create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),
			create("Frame")({
				Name = "Rule",
				Size = UDim2.new(1, 0, 0, 1),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				__dynamicKeys = {
					BackgroundColor3 = theme.Controls.ViewBorder[1],
					BackgroundTransparency = theme.Controls.ViewBorder[2],
				},
			}),
		})
		local contentHost = host(content)

		for index, entry in group.entries do
			buildRow(entry, index + 1, contentHost, elapsedLabels)
		end

		groupHosts[group.name] = {
			clip = clipHost,
			chevron = chevronHost,
			elapsed = elapsedLabels,
			expandedHeight = bodyHeight,
		}
	end

	function structures.toggleGroup(name, open)
		local record = groupHosts[name]
		if not record then
			return
		end

		local clip = record.clip
		if record.tween then
			record.tween:Cancel()
		end

		local current = clip.AbsoluteSize.Y
		if not open and clip.AutomaticSize == Enum.AutomaticSize.Y and current > 0 then
			record.expandedHeight = current
		end

		clip.AutomaticSize = Enum.AutomaticSize.None
		clip.Size = UDim2.new(1, 0, 0, current)
		local tween = tweenService:Create(clip, dropInfo, {
			Size = UDim2.new(1, 0, 0, if open then record.expandedHeight else 0),
		})
		record.tween = tween
		tween:Play()
		if open then
			tween.Completed:Once(function(playback)
				if playback == Enum.PlaybackState.Completed and clip.Parent then
					clip.AutomaticSize = Enum.AutomaticSize.Y
				end
			end)
		end

		if record.chevronTween then
			record.chevronTween:Cancel()
		end
		record.chevronTween = tweenService:Create(record.chevron, dropInfo, {
			Rotation = if open then 180 else 0,
		})
		record.chevronTween:Play()
	end

	function structures.setTimes(show)
		for _, record in groupHosts do
			for _, item in record.elapsed do
				item.label.Parent = if show then item.parent else item.folder
			end
		end
	end

	local function escapeRich(text: string): string
		text = string.gsub(text, "&", "&amp;")
		text = string.gsub(text, "<", "&lt;")
		text = string.gsub(text, ">", "&gt;")
		return text
	end

	local function colorRgb(color: Color3): string
		return string.format(
			"%d,%d,%d",
			math.round(color.R * 255),
			math.round(color.G * 255),
			math.round(color.B * 255)
		)
	end

	local lastView = nil

	local function applySummary(view)
		local label = host(structures.SummaryLabel)
		if not view or view.executor == nil then
			label.Text = ""
			return
		end

		local pass = theme.Controls.Zoom[1].Value
		local fail = theme.Accents.Red[1].Value
		local mixed = fail:Lerp(pass, math.clamp((view.rate or 0) / 100, 0, 1))
		local score = `<font color="rgb({colorRgb(mixed)})">{view.passed}/{view.tested} ({view.rate}%)</font>`
		local text = `{escapeRich(view.executor)} - {score} • {escapeRich(view.timeText or "")}`
		if view.extra and view.extra ~= "" then
			text ..= ` • {escapeRich(view.extra)}`
		end
		label.Text = text
	end

	theme.Controls.Zoom[1]:Connect(function()
		applySummary(lastView)
	end)
	theme.Accents.Red[1]:Connect(function()
		applySummary(lastView)
	end)

	function structures.render(view)
		lastView = view
		host(structures.CountLabel).Text = view.countText
		host(structures.CountPill).Visible = view.countText ~= ""
		applySummary(view)
		clearList()

		if view.empty then
			create("TextLabel")({
				Name = "Empty",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 28),
				FontFace = FONT_REG,
				TextSize = 13,
				Text = "No checks match this filter.",
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 1,
				Parent = listHost,
				__dynamicKeys = {
					TextColor3 = theme.Text.Secondary[1],
					TextTransparency = theme.Text.Secondary[2],
				},
			})
			return
		end

		for index, group in view.groups do
			buildGroup(group, index)
		end
	end

	return structures
end
