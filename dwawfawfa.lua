-- Library source with slider text inside and color picker on toggles
local library = {}
local notifications = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Directory setup
library.directory = "seraph_development"
library.flags = {}
library.flags_initialized = false
library.tabs = {}
library.current_tab = nil
library.connections = {}
library.gui = nil
library.accent_color = Color3.fromRGB(0, 153, 255)
library.watermark_instance = nil

-- Ensure directory exists
if not isfolder(library.directory) then
    makefolder(library.directory)
end

-- Load configs folder
local configs_folder = library.directory .. "/configs"
if not isfolder(configs_folder) then
    makefolder(configs_folder)
end

-- Notifications system
do
    local notification_gui = Instance.new("ScreenGui")
    notification_gui.Name = "SeraphNotifications"
    notification_gui.Parent = CoreGui
    
    local notification_list = Instance.new("Frame")
    notification_list.Name = "NotificationList"
    notification_list.Size = UDim2.new(0, 300, 0, 500)
    notification_list.Position = UDim2.new(1, -320, 0, 20)
    notification_list.BackgroundTransparency = 1
    notification_list.Parent = notification_gui
    
    local list_layout = Instance.new("UIListLayout")
    list_layout.Padding = UDim.new(0, 8)
    list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    list_layout.VerticalAlignment = Enum.VerticalAlignment.Top
    list_layout.SortOrder = Enum.SortOrder.LayoutOrder
    list_layout.Parent = notification_list
    
    function notifications:create_notification(options)
        options = options or {}
        local name = options.name or "Notification"
        local duration = options.duration or 3
        
        local notification = Instance.new("Frame")
        notification.Name = "Notification"
        notification.Size = UDim2.new(0, 280, 0, 40)
        notification.Position = UDim2.new(1, 0, 0, 0)
        notification.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        notification.BackgroundTransparency = 0.1
        notification.BorderSizePixel = 0
        notification.ClipsDescendants = true
        notification.Parent = notification_list
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = notification
        
        local accent = Instance.new("Frame")
        accent.Name = "Accent"
        accent.Size = UDim2.new(0, 4, 1, 0)
        accent.BackgroundColor3 = library.accent_color
        accent.BorderSizePixel = 0
        accent.Parent = notification
        
        local text = Instance.new("TextLabel")
        text.Name = "Text"
        text.Size = UDim2.new(1, -16, 1, 0)
        text.Position = UDim2.new(0, 12, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = name
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Font = Enum.Font.Gotham
        text.TextSize = 14
        text.Parent = notification
        
        notification:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.3, true)
        
        task.delay(duration, function()
            notification:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.3, true)
            task.delay(0.3, function()
                notification:Destroy()
            end)
        end)
    end
end

-- Utility functions
function library:round(number, increment)
    return math.floor(number / increment + 0.5) * increment
end

function library:create_drag(gui_object, drag_object)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                gui_object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragInput = nil
        end
    end
    
    drag_object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui_object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                end
            end)
        end
    end)
    
    drag_object.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            onInput(input)
        end
    end)
end

function library:update_theme(key, value)
    if key == "accent" then
        self.accent_color = value
    end
end

-- Main window
function library:window(options)
    options = options or {}
    local name = options.name or "Library"
    local size = options.size or UDim2.new(0, 600, 0, 400)
    
    -- Create main gui
    local gui = Instance.new("ScreenGui")
    gui.Name = "SeraphUI"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    self.gui = gui
    
    -- Main outline
    local main_outline = Instance.new("Frame")
    main_outline.Name = "MainOutline"
    main_outline.Size = size
    main_outline.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    main_outline.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main_outline.BorderSizePixel = 0
    main_outline.Parent = gui
    
    local main_corner = Instance.new("UICorner")
    main_corner.CornerRadius = UDim.new(0, 6)
    main_corner.Parent = main_outline
    
    local main_stroke = Instance.new("UIStroke")
    main_stroke.Color = Color3.fromRGB(35, 35, 35)
    main_stroke.Thickness = 1
    main_stroke.Parent = main_outline
    
    -- Title bar
    local title_bar = Instance.new("Frame")
    title_bar.Name = "TitleBar"
    title_bar.Size = UDim2.new(1, 0, 0, 40)
    title_bar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title_bar.BorderSizePixel = 0
    title_bar.Parent = main_outline
    
    local title_corner = Instance.new("UICorner")
    title_corner.CornerRadius = UDim.new(0, 6)
    title_corner.Parent = title_bar
    
    local title_fill = Instance.new("Frame")
    title_fill.Name = "TitleFill"
    title_fill.Size = UDim2.new(1, 0, 1, 0)
    title_fill.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title_fill.BorderSizePixel = 0
    title_fill.Parent = title_bar
    
    local title_fill_corner = Instance.new("UICorner")
    title_fill_corner.CornerRadius = UDim.new(0, 6)
    title_fill_corner.Parent = title_fill
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.RichText = true
    title.Parent = title_bar
    
    -- Tab bar
    local tab_bar = Instance.new("Frame")
    tab_bar.Name = "TabBar"
    tab_bar.Size = UDim2.new(1, 0, 0, 36)
    tab_bar.Position = UDim2.new(0, 0, 0, 40)
    tab_bar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tab_bar.BorderSizePixel = 0
    tab_bar.Parent = main_outline
    
    local tab_list = Instance.new("Frame")
    tab_list.Name = "TabList"
    tab_list.Size = UDim2.new(1, -24, 1, 0)
    tab_list.Position = UDim2.new(0, 12, 0, 0)
    tab_list.BackgroundTransparency = 1
    tab_list.Parent = tab_bar
    
    local tab_layout = Instance.new("UIListLayout")
    tab_layout.FillDirection = Enum.FillDirection.Horizontal
    tab_layout.Padding = UDim.new(0, 8)
    tab_layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tab_layout.VerticalAlignment = Enum.VerticalAlignment.Center
    tab_layout.SortOrder = Enum.SortOrder.LayoutOrder
    tab_layout.Parent = tab_list
    
    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -76)
    content.Position = UDim2.new(0, 0, 0, 76)
    content.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    content.BorderSizePixel = 0
    content.Parent = main_outline
    
    local content_corner = Instance.new("UICorner")
    content_corner.CornerRadius = UDim.new(0, 6)
    content_corner.Parent = content
    
    -- Dragging
    self:create_drag(main_outline, title_bar)
    
    local window_obj = {
        gui = gui,
        main_outline = main_outline,
        title = title,
        content = content,
        tab_bar = tab_bar,
        tab_list = tab_list,
        tabs = {},
        current_tab = nil
    }
    
    function window_obj:tab(options)
        options = options or {}
        local tab_name = options.name or "Tab"
        
        -- Create tab button
        local tab_button = Instance.new("TextButton")
        tab_button.Name = tab_name .. "Tab"
        tab_button.Size = UDim2.new(0, 80, 0, 28)
        tab_button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        tab_button.BackgroundTransparency = 0.5
        tab_button.Text = ""
        tab_button.AutoButtonColor = false
        tab_button.Parent = self.tab_list
        
        local tab_corner = Instance.new("UICorner")
        tab_corner.CornerRadius = UDim.new(0, 4)
        tab_corner.Parent = tab_button
        
        local tab_text = Instance.new("TextLabel")
        tab_text.Name = "Text"
        tab_text.Size = UDim2.new(1, 0, 1, 0)
        tab_text.BackgroundTransparency = 1
        tab_text.Text = tab_name
        tab_text.TextColor3 = Color3.fromRGB(200, 200, 200)
        tab_text.Font = Enum.Font.Gotham
        tab_text.TextSize = 14
        tab_text.Parent = tab_button
        
        -- Create tab content
        local tab_content = Instance.new("Frame")
        tab_content.Name = tab_name .. "Content"
        tab_content.Size = UDim2.new(1, -24, 1, -24)
        tab_content.Position = UDim2.new(0, 12, 0, 12)
        tab_content.BackgroundTransparency = 1
        tab_content.Visible = false
        tab_content.Parent = self.content
        
        local tab_layout = Instance.new("UIListLayout")
        tab_layout.FillDirection = Enum.FillDirection.Horizontal
        tab_layout.Padding = UDim.new(0, 12)
        tab_layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        tab_layout.VerticalAlignment = Enum.VerticalAlignment.Top
        tab_layout.SortOrder = Enum.SortOrder.LayoutOrder
        tab_layout.Parent = tab_content
        
        local tab_obj = {
            name = tab_name,
            button = tab_button,
            content = tab_content,
            columns = {}
        }
        
        function tab_obj:column(options)
            options = options or {}
            
            local column = Instance.new("Frame")
            column.Name = "Column"
            column.Size = UDim2.new(0, 280, 1, 0)
            column.BackgroundTransparency = 1
            column.Parent = self.content
            
            local column_layout = Instance.new("UIListLayout")
            column_layout.Padding = UDim.new(0, 12)
            column_layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            column_layout.VerticalAlignment = Enum.VerticalAlignment.Top
            column_layout.SortOrder = Enum.SortOrder.LayoutOrder
            column_layout.Parent = column
            
            local column_obj = {
                frame = column,
                sections = {}
            }
            
            function column_obj:section(options)
                options = options or {}
                local section_name = options.name or "Section"
                local size = options.size or 1
                local auto_fill = options.auto_fill or false
                
                local section = Instance.new("ScrollingFrame")
                section.Name = section_name .. "Section"
                section.Size = UDim2.new(1, 0, 0, 0)
                section.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                section.BorderSizePixel = 0
                section.AutomaticCanvasSize = Enum.AutomaticSize.Y
                section.ScrollBarThickness = 4
                section.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 45)
                section.CanvasSize = UDim2.new(0, 0, 0, 0)
                section.Parent = column
                
                local section_corner = Instance.new("UICorner")
                section_corner.CornerRadius = UDim.new(0, 4)
                section_corner.Parent = section
                
                local section_padding = Instance.new("UIPadding")
                section_padding.PaddingTop = UDim.new(0, 12)
                section_padding.PaddingBottom = UDim.new(0, 12)
                section_padding.PaddingLeft = UDim.new(0, 12)
                section_padding.PaddingRight = UDim.new(0, 12)
                section_padding.Parent = section
                
                local section_layout = Instance.new("UIListLayout")
                section_layout.Padding = UDim.new(0, 8)
                section_layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                section_layout.VerticalAlignment = Enum.VerticalAlignment.Top
                section_layout.SortOrder = Enum.SortOrder.LayoutOrder
                section_layout.Parent = section
                
                local section_title = Instance.new("TextLabel")
                section_title.Name = "Title"
                section_title.Size = UDim2.new(1, 0, 0, 20)
                section_title.BackgroundTransparency = 1
                section_title.Text = section_name
                section_title.TextColor3 = Color3.fromRGB(180, 180, 180)
                section_title.TextXAlignment = Enum.TextXAlignment.Left
                section_title.Font = Enum.Font.GothamBold
                section_title.TextSize = 14
                section_title.Parent = section
                
                -- Adjust size based on content
                local function update_size()
                    local total_height = 0
                    for _, child in ipairs(section:GetChildren()) do
                        if child:IsA("GuiObject") and child.Visible then
                            total_height = total_height + child.AbsoluteSize.Y + 8
                        end
                    end
                    section.Size = UDim2.new(1, 0, 0, total_height + 24)
                end
                
                section_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_size)
                task.spawn(update_size)
                
                local section_obj = {
                    frame = section,
                    layout = section_layout,
                    title = section_title
                }
                
                -- Toggle with optional color picker on the right
                function section_obj:toggle(options)
                    options = options or {}
                    local name = options.name or "Toggle"
                    local default = options.default or false
                    local flag = options.flag
                    local callback = options.callback
                    local color_picker = options.color_picker -- Color picker options
                    
                    local toggle_frame = Instance.new("Frame")
                    toggle_frame.Name = "ToggleFrame"
                    toggle_frame.Size = UDim2.new(1, 0, 0, 24)
                    toggle_frame.BackgroundTransparency = 1
                    toggle_frame.Parent = section
                    
                    local toggle_button = Instance.new("TextButton")
                    toggle_button.Name = "ToggleButton"
                    toggle_button.Size = UDim2.new(0, 44, 0, 20)
                    toggle_button.Position = UDim2.new(1, -44, 0, 2)
                    toggle_button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    toggle_button.Text = ""
                    toggle_button.AutoButtonColor = false
                    toggle_button.Parent = toggle_frame
                    
                    local toggle_corner = Instance.new("UICorner")
                    toggle_corner.CornerRadius = UDim.new(1, 0)
                    toggle_corner.Parent = toggle_button
                    
                    local toggle_circle = Instance.new("Frame")
                    toggle_circle.Name = "Circle"
                    toggle_circle.Size = UDim2.new(0, 16, 0, 16)
                    toggle_circle.Position = UDim2.new(0, 2, 0.5, -8)
                    toggle_circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    toggle_circle.BorderSizePixel = 0
                    toggle_circle.Parent = toggle_button
                    
                    local toggle_circle_corner = Instance.new("UICorner")
                    toggle_circle_corner.CornerRadius = UDim.new(1, 0)
                    toggle_circle_corner.Parent = toggle_circle
                    
                    local toggle_fill = Instance.new("Frame")
                    toggle_fill.Name = "Fill"
                    toggle_fill.Size = UDim2.new(0, 0, 1, 0)
                    toggle_fill.BackgroundColor3 = library.accent_color
                    toggle_fill.BorderSizePixel = 0
                    toggle_fill.Parent = toggle_button
                    
                    local toggle_fill_corner = Instance.new("UICorner")
                    toggle_fill_corner.CornerRadius = UDim.new(1, 0)
                    toggle_fill_corner.Parent = toggle_fill
                    
                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.new(1, -80, 1, 0)
                    label.Position = UDim2.new(0, 0, 0, 0)
                    label.BackgroundTransparency = 1
                    label.Text = name
                    label.TextColor3 = Color3.fromRGB(220, 220, 220)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 14
                    label.Parent = toggle_frame
                    
                    local value = default
                    
                    -- Color picker on toggle if specified
                    local color_picker_button = nil
                    local color_preview = nil
                    
                    if color_picker then
                        color_picker_button = Instance.new("TextButton")
                        color_picker_button.Name = "ColorPicker"
                        color_picker_button.Size = UDim2.new(0, 20, 0, 20)
                        color_picker_button.Position = UDim2.new(1, -68, 0, 2)
                        color_picker_button.BackgroundColor3 = color_picker.color or Color3.fromRGB(255, 255, 255)
                        color_picker_button.Text = ""
                        color_picker_button.AutoButtonColor = false
                        color_picker_button.Parent = toggle_frame
                        
                        local color_corner = Instance.new("UICorner")
                        color_corner.CornerRadius = UDim.new(0, 4)
                        color_corner.Parent = color_picker_button
                        
                        -- Color picker dropdown
                        local color_dropdown = Instance.new("Frame")
                        color_dropdown.Name = "ColorDropdown"
                        color_dropdown.Size = UDim2.new(0, 180, 0, 160)
                        color_dropdown.Position = UDim2.new(0, 0, 1, 5)
                        color_dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        color_dropdown.BackgroundTransparency = 0.1
                        color_dropdown.BorderSizePixel = 0
                        color_dropdown.Visible = false
                        color_dropdown.ZIndex = 10
                        color_dropdown.Parent = color_picker_button
                        
                        local dropdown_corner = Instance.new("UICorner")
                        dropdown_corner.CornerRadius = UDim.new(0, 4)
                        dropdown_corner.Parent = color_dropdown
                        
                        local dropdown_stroke = Instance.new("UIStroke")
                        dropdown_stroke.Color = Color3.fromRGB(45, 45, 45)
                        dropdown_stroke.Thickness = 1
                        dropdown_stroke.Parent = color_dropdown
                        
                        local hue_sat = Instance.new("ImageLabel")
                        hue_sat.Name = "HueSat"
                        hue_sat.Size = UDim2.new(1, -40, 1, -40)
                        hue_sat.Position = UDim2.new(0, 10, 0, 10)
                        hue_sat.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        hue_sat.BackgroundTransparency = 0
                        hue_sat.Image = "rbxasset://textures/ui/GuiImagePalette.png"
                        hue_sat.ScaleType = Enum.ScaleType.Stretch
                        hue_sat.SliceCenter = Rect.new(0, 0, 0, 0)
                        hue_sat.Parent = color_dropdown
                        
                        local hue_sat_corner = Instance.new("UICorner")
                        hue_sat_corner.CornerRadius = UDim.new(0, 4)
                        hue_sat_corner.Parent = hue_sat
                        
                        local hue = Instance.new("Frame")
                        hue.Name = "Hue"
                        hue.Size = UDim2.new(0, 20, 1, -40)
                        hue.Position = UDim2.new(1, -30, 0, 10)
                        hue.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        hue.BorderSizePixel = 0
                        hue.Parent = color_dropdown
                        
                        local hue_corner = Instance.new("UICorner")
                        hue_corner.CornerRadius = UDim.new(0, 4)
                        hue_corner.Parent = hue
                        
                        local hue_gradient = Instance.new("UIGradient")
                        hue_gradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        })
                        hue_gradient.Rotation = 90
                        hue_gradient.Parent = hue
                        
                        local color_preview = Instance.new("Frame")
                        color_preview.Name = "ColorPreview"
                        color_preview.Size = UDim2.new(0, 30, 0, 30)
                        color_preview.Position = UDim2.new(0, 10, 1, -40)
                        color_preview.BackgroundColor3 = color_picker.color or Color3.fromRGB(255, 255, 255)
                        color_preview.BorderSizePixel = 0
                        color_preview.Parent = color_dropdown
                        
                        local preview_corner = Instance.new("UICorner")
                        preview_corner.CornerRadius = UDim.new(0, 4)
                        preview_corner.Parent = color_preview
                        
                        local hex_input = Instance.new("TextBox")
                        hex_input.Name = "HexInput"
                        hex_input.Size = UDim2.new(1, -50, 0, 30)
                        hex_input.Position = UDim2.new(0, 50, 1, -40)
                        hex_input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                        hex_input.BackgroundTransparency = 0.3
                        hex_input.Text = "#" .. color_picker.color:ToHex()
                        hex_input.TextColor3 = Color3.fromRGB(255, 255, 255)
                        hex_input.PlaceholderText = "#FFFFFF"
                        hex_input.Font = Enum.Font.Gotham
                        hex_input.TextSize = 14
                        hex_input.Parent = color_dropdown
                        
                        local hex_corner = Instance.new("UICorner")
                        hex_corner.CornerRadius = UDim.new(0, 4)
                        hex_corner.Parent = hex_input
                        
                        local current_color = color_picker.color or Color3.fromRGB(255, 255, 255)
                        local flag_name = color_picker.flag
                        local color_callback = color_picker.callback
                        
                        -- Color picker functionality
                        local function update_color_from_hue_sat(x, y)
                            local size = hue_sat.AbsoluteSize
                            local hue_val = (hue_sat.BackgroundColor3:ToHSV())
                            local sat = math.clamp(x / size.X, 0, 1)
                            local val = 1 - math.clamp(y / size.Y, 0, 1)
                            
                            local h = hue_val
                            local s = sat
                            local v = val
                            
                            current_color = Color3.fromHSV(h, s, v)
                            color_preview.BackgroundColor3 = current_color
                            color_picker_button.BackgroundColor3 = current_color
                            hex_input.Text = "#" .. current_color:ToHex()
                            
                            if flag_name then
                                library.flags[flag_name] = current_color
                            end
                            if color_callback then
                                color_callback(current_color)
                            end
                        end
                        
                        local function update_hue(y)
                            local size = hue.AbsoluteSize
                            local hue_val = math.clamp(y / size.Y, 0, 0.99)
                            local color = Color3.fromHSV(hue_val, 1, 1)
                            hue_sat.BackgroundColor3 = color
                            
                            local current_h, current_s, current_v = current_color:ToHSV()
                            current_color = Color3.fromHSV(hue_val, current_s, current_v)
                            color_preview.BackgroundColor3 = current_color
                            color_picker_button.BackgroundColor3 = current_color
                            hex_input.Text = "#" .. current_color:ToHex()
                            
                            if flag_name then
                                library.flags[flag_name] = current_color
                            end
                            if color_callback then
                                color_callback(current_color)
                            end
                        end
                        
                        hue_sat.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                local pos = hue_sat.AbsolutePosition
                                local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                                local relative = mouse_pos - pos
                                update_color_from_hue_sat(relative.X, relative.Y)
                            end
                        end)
                        
                        hue_sat.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement then
                                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                    local pos = hue_sat.AbsolutePosition
                                    local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                                    local relative = mouse_pos - pos
                                    update_color_from_hue_sat(relative.X, relative.Y)
                                end
                            end
                        end)
                        
                        hue.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                local pos = hue.AbsolutePosition
                                local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                                local relative = mouse_pos - pos
                                update_hue(relative.Y)
                            end
                        end)
                        
                        hue.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement then
                                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                    local pos = hue.AbsolutePosition
                                    local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                                    local relative = mouse_pos - pos
                                    update_hue(relative.Y)
                                end
                            end
                        end)
                        
                        hex_input.FocusLost:Connect(function()
                            local hex = hex_input.Text:gsub("#", "")
                            local success, color = pcall(function()
                                return Color3.fromHex(hex)
                            end)
                            if success then
                                current_color = color
                                color_preview.BackgroundColor3 = color
                                color_picker_button.BackgroundColor3 = color
                                hex_input.Text = "#" .. color:ToHex()
                                
                                local h, s, v = color:ToHSV()
                                hue_sat.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                                
                                if flag_name then
                                    library.flags[flag_name] = color
                                end
                                if color_callback then
                                    color_callback(color)
                                end
                            end
                        end)
                        
                        color_picker_button.MouseButton1Click:Connect(function()
                            color_dropdown.Visible = not color_dropdown.Visible
                        end)
                        
                        -- Store color in flags
                        if flag_name then
                            library.flags[flag_name] = current_color
                        end
                    end
                    
                    local function set_state(state)
                        value = state
                        if state then
                            toggle_button.BackgroundColor3 = library.accent_color
                            toggle_circle:TweenPosition(UDim2.new(1, -18, 0.5, -8), "Out", "Quad", 0.1, true)
                            toggle_fill:TweenSize(UDim2.new(1, -2, 1, 0), "Out", "Quad", 0.1, true)
                        else
                            toggle_button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                            toggle_circle:TweenPosition(UDim2.new(0, 2, 0.5, -8), "Out", "Quad", 0.1, true)
                            toggle_fill:TweenSize(UDim2.new(0, 0, 1, 0), "Out", "Quad", 0.1, true)
                        end
                        
                        if flag then
                            library.flags[flag] = state
                        end
                        if callback then
                            callback(state)
                        end
                    end
                    
                    toggle_button.MouseButton1Click:Connect(function()
                        set_state(not value)
                    end)
                    
                    set_state(default)
                    
                    return {
                        set = set_state,
                        get = function() return value end,
                        frame = toggle_frame,
                        color_picker = color_picker_button
                    }
                end
                
                -- Keybind
                function section_obj:keybind(options)
                    options = options or {}
                    local name = options.name or "Keybind"
                    local default_key = options.key or Enum.KeyCode.LeftControl
                    local default_mode = options.mode or "Toggle"
                    local flag = options.flag
                    local callback = options.callback
                    
                    local keybind_frame = Instance.new("Frame")
                    keybind_frame.Name = "KeybindFrame"
                    keybind_frame.Size = UDim2.new(1, 0, 0, 24)
                    keybind_frame.BackgroundTransparency = 1
                    keybind_frame.Parent = section
                    
                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.new(1, -120, 1, 0)
                    label.Position = UDim2.new(0, 0, 0, 0)
                    label.BackgroundTransparency = 1
                    label.Text = name
                    label.TextColor3 = Color3.fromRGB(220, 220, 220)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 14
                    label.Parent = keybind_frame
                    
                    local mode_dropdown = Instance.new("TextButton")
                    mode_dropdown.Name = "ModeDropdown"
                    mode_dropdown.Size = UDim2.new(0, 60, 0, 20)
                    mode_dropdown.Position = UDim2.new(1, -100, 0, 2)
                    mode_dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    mode_dropdown.Text = default_mode
                    mode_dropdown.TextColor3 = Color3.fromRGB(220, 220, 220)
                    mode_dropdown.Font = Enum.Font.Gotham
                    mode_dropdown.TextSize = 12
                    mode_dropdown.AutoButtonColor = false
                    mode_dropdown.Parent = keybind_frame
                    
                    local mode_corner = Instance.new("UICorner")
                    mode_corner.CornerRadius = UDim.new(0, 4)
                    mode_corner.Parent = mode_dropdown
                    
                    local key_button = Instance.new("TextButton")
                    key_button.Name = "KeyButton"
                    key_button.Size = UDim2.new(0, 40, 0, 20)
                    key_button.Position = UDim2.new(1, -40, 0, 2)
                    key_button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    key_button.Text = default_key.Name
                    key_button.TextColor3 = Color3.fromRGB(220, 220, 220)
                    key_button.Font = Enum.Font.Gotham
                    key_button.TextSize = 12
                    key_button.AutoButtonColor = false
                    key_button.Parent = keybind_frame
                    
                    local key_corner = Instance.new("UICorner")
                    key_corner.CornerRadius = UDim.new(0, 4)
                    key_corner.Parent = key_button
                    
                    local listening = false
                    local current_key = default_key
                    local current_mode = default_mode
                    local active = false
                    
                    local function update_key_text()
                        if listening then
                            key_button.Text = "..."
                        else
                            key_button.Text = current_key.Name
                        end
                    end
                    
                    key_button.MouseButton1Click:Connect(function()
                        listening = true
                        update_key_text()
                    end)
                    
                    mode_dropdown.MouseButton1Click:Connect(function()
                        if current_mode == "Toggle" then
                            current_mode = "Hold"
                        else
                            current_mode = "Toggle"
                        end
                        mode_dropdown.Text = current_mode
                        
                        if flag then
                            library.flags[flag .. "_mode"] = current_mode
                        end
                    end)
                    
                    UserInputService.InputBegan:Connect(function(input)
                        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                            current_key = input.KeyCode
                            listening = false
                            update_key_text()
                            
                            if flag then
                                library.flags[flag] = current_key
                            end
                        end
                        
                        if not listening and current_key and input.KeyCode == current_key and input.UserInputType == Enum.UserInputType.Keyboard then
                            if current_mode == "Toggle" then
                                active = not active
                            elseif current_mode == "Hold" then
                                active = true
                            end
                            
                            if callback then
                                callback(active)
                            end
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if current_key and input.KeyCode == current_key and current_mode == "Hold" then
                            active = false
                            if callback then
                                callback(active)
                            end
                        end
                    end)
                    
                    if flag then
                        library.flags[flag] = current_key
                        library.flags[flag .. "_mode"] = current_mode
                    end
                    
                    return {
                        frame = keybind_frame
                    }
                end
                
                -- Slider with text inside
                function section_obj:slider(options)
                    options = options or {}
                    local name = options.name or "Slider"
                    local min = options.min or 0
                    local max = options.max or 100
                    local default = options.default or 0
                    local suffix = options.suffix or ""
                    local flag = options.flag
                    local callback = options.callback
                    local interval = options.interval or 1
                    
                    local slider_frame = Instance.new("Frame")
                    slider_frame.Name = "SliderFrame"
                    slider_frame.Size = UDim2.new(1, 0, 0, 36)
                    slider_frame.BackgroundTransparency = 1
                    slider_frame.Parent = section
                    
                    local slider_container = Instance.new("Frame")
                    slider_container.Name = "SliderContainer"
                    slider_container.Size = UDim2.new(1, 0, 0, 20)
                    slider_container.Position = UDim2.new(0, 0, 0, 16)
                    slider_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    slider_container.BorderSizePixel = 0
                    slider_container.Parent = slider_frame
                    
                    local container_corner = Instance.new("UICorner")
                    container_corner.CornerRadius = UDim.new(0, 4)
                    container_corner.Parent = slider_container
                    
                    local fill = Instance.new("Frame")
                    fill.Name = "Fill"
                    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    fill.BackgroundColor3 = library.accent_color
                    fill.BorderSizePixel = 0
                    fill.Parent = slider_container
                    
                    local fill_corner = Instance.new("UICorner")
                    fill_corner.CornerRadius = UDim.new(0, 4)
                    fill_corner.Parent = fill
                    
                    -- Text inside slider
                    local value_label = Instance.new("TextLabel")
                    value_label.Name = "ValueLabel"
                    value_label.Size = UDim2.new(1, -10, 1, 0)
                    value_label.Position = UDim2.new(0, 5, 0, 0)
                    value_label.BackgroundTransparency = 1
                    value_label.Text = name .. ": " .. library:round(default, interval) .. suffix
                    value_label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    value_label.TextXAlignment = Enum.TextXAlignment.Left
                    value_label.Font = Enum.Font.Gotham
                    value_label.TextSize = 13
                    value_label.Parent = slider_container
                    
                    local value = default
                    
                    local function set(val)
                        val = math.clamp(val, min, max)
                        val = library:round(val, interval)
                        value = val
                        
                        local percent = (val - min) / (max - min)
                        fill.Size = UDim2.new(percent, 0, 1, 0)
                        value_label.Text = name .. ": " .. val .. suffix
                        
                        if flag then
                            library.flags[flag] = val
                        end
                        if callback then
                            callback(val)
                        end
                    end
                    
                    slider_container.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local pos = slider_container.AbsolutePosition
                            local size = slider_container.AbsoluteSize
                            local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                            local relative = (mouse_pos.X - pos.X) / size.X
                            local val = min + (relative * (max - min))
                            set(val)
                        end
                    end)
                    
                    slider_container.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                local pos = slider_container.AbsolutePosition
                                local size = slider_container.AbsoluteSize
                                local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                                local relative = math.clamp((mouse_pos.X - pos.X) / size.X, 0, 1)
                                local val = min + (relative * (max - min))
                                set(val)
                            end
                        end
                    end)
                    
                    set(default)
                    
                    return {
                        set = set,
                        get = function() return value end,
                        frame = slider_frame
                    }
                end
                
                -- Multi slider with text inside and no title
                function section_obj:multi_slider(options)
                    options = options or {}
                    local left_name = options.left_name or "Left"
                    local left_min = options.left_min or 0
                    local left_max = options.left_max or 100
                    local left_default = options.left_default or 0
                    local left_suffix = options.left_suffix or ""
                    local left_flag = options.left_flag
                    local left_interval = options.left_interval or 1
                    
                    local right_name = options.right_name or "Right"
                    local right_min = options.right_min or 0
                    local right_max = options.right_max or 100
                    local right_default = options.right_default or 0
                    local right_suffix = options.right_suffix or ""
                    local right_flag = options.right_flag
                    local right_interval = options.right_interval or 1
                    
                    local callback = options.callback
                    
                    local container = Instance.new("Frame")
                    container.Name = "MultiSlider"
                    container.Size = UDim2.new(1, 0, 0, 46)
                    container.BackgroundTransparency = 1
                    container.Parent = section
                    
                    -- Left slider
                    local left_container = Instance.new("Frame")
                    left_container.Name = "LeftSlider"
                    left_container.Size = UDim2.new(0.47, 0, 0, 20)
                    left_container.Position = UDim2.new(0, 0, 0, 16)
                    left_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    left_container.BorderSizePixel = 0
                    left_container.Parent = container
                    
                    local left_corner = Instance.new("UICorner")
                    left_corner.CornerRadius = UDim.new(0, 4)
                    left_corner.Parent = left_container
                    
                    local left_fill = Instance.new("Frame")
                    left_fill.Name = "Fill"
                    left_fill.Size = UDim2.new((left_default - left_min) / (left_max - left_min), 0, 1, 0)
                    left_fill.BackgroundColor3 = library.accent_color
                    left_fill.BorderSizePixel = 0
                    left_fill.Parent = left_container
                    
                    local left_fill_corner = Instance.new("UICorner")
                    left_fill_corner.CornerRadius = UDim.new(0, 4)
                    left_fill_corner.Parent = left_fill
                    
                    -- Text inside left slider
                    local left_value = Instance.new("TextLabel")
                    left_value.Name = "ValueLabel"
                    left_value.Size = UDim2.new(1, -5, 1, 0)
                    left_value.Position = UDim2.new(0, 3, 0, 0)
                    left_value.BackgroundTransparency = 1
                    left_value.Text = left_name .. ": " .. library:round(left_default, left_interval) .. left_suffix
                    left_value.TextColor3 = Color3.fromRGB(255, 255, 255)
                    left_value.TextXAlignment = Enum.TextXAlignment.Left
                    left_value.Font = Enum.Font.Gotham
                    left_value.TextSize = 12
                    left_value.Parent = left_container
                    
                    -- Right slider
                    local right_container = Instance.new("Frame")
                    right_container.Name = "RightSlider"
                    right_container.Size = UDim2.new(0.47, 0, 0, 20)
                    right_container.Position = UDim2.new(0.53, 0, 0, 16)
                    right_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    right_container.BorderSizePixel = 0
                    right_container.Parent = container
                    
                    local right_corner = Instance.new("UICorner")
                    right_corner.CornerRadius = UDim.new(0, 4)
                    right_corner.Parent = right_container
                    
                    local right_fill = Instance.new("Frame")
                    right_fill.Name = "Fill"
                    right_fill.Size = UDim2.new((right_default - right_min) / (right_max - right_min), 0, 1, 0)
                    right_fill.BackgroundColor3 = library.accent_color
                    right_fill.BorderSizePixel = 0
                    right_fill.Parent = right_container
                    
                    local right_fill_corner = Instance.new("UICorner")
                    right_fill_corner.CornerRadius = UDim.new(0, 4)
                    right_fill_corner.Parent = right_fill
                    
                    -- Text inside right slider
                    local right_value = Instance.new("TextLabel")
                    right_value.Name = "ValueLabel"
                    right_value.Size = UDim2.new(1, -5, 1, 0)
                    right_value.Position = UDim2.new(0, 3, 0, 0)
                    right_value.BackgroundTransparency = 1
                    right_value.Text = right_name .. ": " .. library:round(right_default, right_interval) .. right_suffix
                    right_value.TextColor3 = Color3.fromRGB(255, 255, 255)
                    right_value.TextXAlignment = Enum.TextXAlignment.Left
                    right_value.Font = Enum.Font.Gotham
                    right_value.TextSize = 12
                    right_value.Parent = right_container
                    
                    local left_val = left_default
                    local right_val = right_default
                    
                    local function set_left(val)
                        val = math.clamp(val, left_min, left_max)
                        val = library:round(val, left_interval)
                        left_val = val
                        
                        local percent = (val - left_min) / (left_max - left_min)
                        left_fill.Size = UDim2.new(percent, 0, 1, 0)
                        left_value.Text = left_name .. ": " .. val .. left_suffix
                        
                        if left_flag then
                            library.flags[left_flag] = val
                        end
                        if callback then
                            callback(left_val, right_val)
                        end
                    end
                    
                    local function set_right(val)
                        val = math.clamp(val, right_min, right_max)
                        val = library:round(val, right_interval)
                        right_val = val
                        
                        local percent = (val - right_min) / (right_max - right_min)
                        right_fill.Size = UDim2.new(percent, 0, 1, 0)
                        right_value.Text = right_name .. ": " .. val .. right_suffix
                        
                        if right_flag then
                            library.flags[right_flag] = val
                        end
                        if callback then
                            callback(left_val, right_val)
                        end
                    end
                    
                    left_container.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local pos = left_container.AbsolutePosition
                            local size = left_container.AbsoluteSize
                            local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                            local relative = (mouse_pos.X - pos.X) / size.X
                            local val = left_min + (relative * (left_max - left_min))
                            set_left(val)
                        end
                    end)
                    
                    left_container.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                local pos = left_container.AbsolutePosition
                                local size = left_container.AbsoluteSize
                                local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                                local relative = math.clamp((mouse_pos.X - pos.X) / size.X, 0, 1)
                                local val = left_min + (relative * (left_max - left_min))
                                set_left(val)
                            end
                        end
                    end)
                    
                    right_container.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local pos = right_container.AbsolutePosition
                            local size = right_container.AbsoluteSize
                            local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                            local relative = (mouse_pos.X - pos.X) / size.X
                            local val = right_min + (relative * (right_max - right_min))
                            set_right(val)
                        end
                    end)
                    
                    right_container.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                local pos = right_container.AbsolutePosition
                                local size = right_container.AbsoluteSize
                                local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                                local relative = math.clamp((mouse_pos.X - pos.X) / size.X, 0, 1)
                                local val = right_min + (relative * (right_max - right_min))
                                set_right(val)
                            end
                        end
                    end)
                    
                    set_left(left_default)
                    set_right(right_default)
                    
                    return {
                        set_left = set_left,
                        set_right = set_right,
                        get_left = function() return left_val end,
                        get_right = function() return right_val end,
                        frame = container
                    }
                end
                
                -- Dropdown
                function section_obj:dropdown(options)
                    options = options or {}
                    local name = options.name or "Dropdown"
                    local items = options.items or {}
                    local default = options.default or (items[1] or "")
                    local multi = options.multi or false
                    local flag = options.flag
                    local callback = options.callback
                    
                    local dropdown_frame = Instance.new("Frame")
                    dropdown_frame.Name = "DropdownFrame"
                    dropdown_frame.Size = UDim2.new(1, 0, 0, 60)
                    dropdown_frame.BackgroundTransparency = 1
                    dropdown_frame.Parent = section
                    
                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.new(1, 0, 0, 20)
                    label.BackgroundTransparency = 1
                    label.Text = name
                    label.TextColor3 = Color3.fromRGB(220, 220, 220)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 14
                    label.Parent = dropdown_frame
                    
                    local dropdown_button = Instance.new("TextButton")
                    dropdown_button.Name = "DropdownButton"
                    dropdown_button.Size = UDim2.new(1, 0, 0, 30)
                    dropdown_button.Position = UDim2.new(0, 0, 0, 25)
                    dropdown_button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    dropdown_button.Text = ""
                    dropdown_button.AutoButtonColor = false
                    dropdown_button.Parent = dropdown_frame
                    
                    local button_corner = Instance.new("UICorner")
                    button_corner.CornerRadius = UDim.new(0, 4)
                    button_corner.Parent = dropdown_button
                    
                    local button_text = Instance.new("TextLabel")
                    button_text.Name = "Text"
                    button_text.Size = UDim2.new(1, -30, 1, 0)
                    button_text.Position = UDim2.new(0, 10, 0, 0)
                    button_text.BackgroundTransparency = 1
                    button_text.Text = multi and "Select..." or (default or items[1] or "None")
                    button_text.TextColor3 = Color3.fromRGB(220, 220, 220)
                    button_text.TextXAlignment = Enum.TextXAlignment.Left
                    button_text.Font = Enum.Font.Gotham
                    button_text.TextSize = 13
                    button_text.Parent = dropdown_button
                    
                    local arrow = Instance.new("TextLabel")
                    arrow.Name = "Arrow"
                    arrow.Size = UDim2.new(0, 20, 1, 0)
                    arrow.Position = UDim2.new(1, -25, 0, 0)
                    arrow.BackgroundTransparency = 1
                    arrow.Text = "▼"
                    arrow.TextColor3 = Color3.fromRGB(140, 140, 140)
                    arrow.Font = Enum.Font.Gotham
                    arrow.TextSize = 14
                    arrow.Parent = dropdown_button
                    
                    local dropdown_list = Instance.new("Frame")
                    dropdown_list.Name = "DropdownList"
                    dropdown_list.Size = UDim2.new(1, 0, 0, 0)
                    dropdown_list.Position = UDim2.new(0, 0, 0, 35)
                    dropdown_list.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    dropdown_list.BackgroundTransparency = 0.1
                    dropdown_list.BorderSizePixel = 0
                    dropdown_list.Visible = false
                    dropdown_list.ZIndex = 10
                    dropdown_list.Parent = dropdown_button
                    
                    local list_corner = Instance.new("UICorner")
                    list_corner.CornerRadius = UDim.new(0, 4)
                    list_corner.Parent = dropdown_list
                    
                    local list_layout = Instance.new("UIListLayout")
                    list_layout.Padding = UDim.new(0, 2)
                    list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                    list_layout.VerticalAlignment = Enum.VerticalAlignment.Top
                    list_layout.SortOrder = Enum.SortOrder.LayoutOrder
                    list_layout.Parent = dropdown_list
                    
                    local selected_items = multi and {} or default
                    if multi and type(default) == "table" then
                        selected_items = default
                    end
                    
                    local function update_height()
                        local count = #items
                        local height = math.min(count, 6) * 28
                        dropdown_list.Size = UDim2.new(1, 0, 0, height)
                    end
                    
                    local function refresh_items()
                        for _, child in ipairs(dropdown_list:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        
                        for _, item in ipairs(items) do
                            local item_button = Instance.new("TextButton")
                            item_button.Name = "Item"
                            item_button.Size = UDim2.new(1, 0, 0, 26)
                            item_button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                            item_button.BackgroundTransparency = 0.5
                            item_button.Text = ""
                            item_button.AutoButtonColor = false
                            item_button.ZIndex = 11
                            item_button.Parent = dropdown_list
                            
                            local item_text = Instance.new("TextLabel")
                            item_text.Name = "Text"
                            item_text.Size = UDim2.new(1, -20, 1, 0)
                            item_text.Position = UDim2.new(0, 10, 0, 0)
                            item_text.BackgroundTransparency = 1
                            item_text.Text = item
                            item_text.TextColor3 = Color3.fromRGB(200, 200, 200)
                            item_text.TextXAlignment = Enum.TextXAlignment.Left
                            item_text.Font = Enum.Font.Gotham
                            item_text.TextSize = 13
                            item_text.ZIndex = 11
                            item_text.Parent = item_button
                            
                            if multi then
                                local check = Instance.new("TextLabel")
                                check.Name = "Check"
                                check.Size = UDim2.new(0, 20, 1, 0)
                                check.Position = UDim2.new(1, -25, 0, 0)
                                check.BackgroundTransparency = 1
                                check.Text = table.find(selected_items, item) and "✓" or ""
                                check.TextColor3 = library.accent_color
                                check.Font = Enum.Font.Gotham
                                check.TextSize = 16
                                check.ZIndex = 11
                                check.Parent = item_button
                                
                                item_button.MouseButton1Click:Connect(function()
                                    local index = table.find(selected_items, item)
                                    if index then
                                        table.remove(selected_items, index)
                                        check.Text = ""
                                    else
                                        table.insert(selected_items, item)
                                        check.Text = "✓"
                                    end
                                    
                                    local display_text = #selected_items > 0 and table.concat(selected_items, ", ") or "Select..."
                                    button_text.Text = display_text
                                    
                                    if flag then
                                        library.flags[flag] = selected_items
                                    end
                                    if callback then
                                        callback(selected_items)
                                    end
                                end)
                            else
                                item_button.MouseButton1Click:Connect(function()
                                    selected_items = item
                                    button_text.Text = item
                                    dropdown_list.Visible = false
                                    
                                    if flag then
                                        library.flags[flag] = item
                                    end
                                    if callback then
                                        callback(item)
                                    end
                                end)
                                
                                if item == selected_items then
                                    item_button.BackgroundColor3 = library.accent_color
                                    item_button.BackgroundTransparency = 0.3
                                    item_text.TextColor3 = Color3.fromRGB(255, 255, 255)
                                end
                            end
                        end
                        update_height()
                    end
                    
                    dropdown_button.MouseButton1Click:Connect(function()
                        dropdown_list.Visible = not dropdown_list.Visible
                    end)
                    
                    refresh_items()
                    
                    if flag then
                        library.flags[flag] = selected_items
                    end
                    
                    return {
                        refresh_options = function(new_items)
                            items = new_items
                            refresh_items()
                        end,
                        set = function(value)
                            if multi then
                                selected_items = value
                                button_text.Text = #selected_items > 0 and table.concat(selected_items, ", ") or "Select..."
                            else
                                selected_items = value
                                button_text.Text = value
                            end
                            if flag then
                                library.flags[flag] = value
                            end
                        end,
                        frame = dropdown_frame
                    }
                end
                
                -- Button
                function section_obj:button(options)
                    options = options or {}
                    local name = options.name or "Button"
                    local callback = options.callback or function() end
                    
                    local button = Instance.new("TextButton")
                    button.Name = "Button"
                    button.Size = UDim2.new(1, 0, 0, 32)
                    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    button.Text = ""
                    button.AutoButtonColor = false
                    button.Parent = section
                    
                    local button_corner = Instance.new("UICorner")
                    button_corner.CornerRadius = UDim.new(0, 4)
                    button_corner.Parent = button
                    
                    local button_text = Instance.new("TextLabel")
                    button_text.Name = "Text"
                    button_text.Size = UDim2.new(1, 0, 1, 0)
                    button_text.BackgroundTransparency = 1
                    button_text.Text = name
                    button_text.TextColor3 = Color3.fromRGB(220, 220, 220)
                    button_text.Font = Enum.Font.Gotham
                    button_text.TextSize = 14
                    button_text.Parent = button
                    
                    button.MouseButton1Click:Connect(callback)
                    
                    return {
                        frame = button
                    }
                end
                
                -- Textbox
                function section_obj:textbox(options)
                    options = options or {}
                    local name = options.name or "Textbox"
                    local placeholder = options.placeholder or ""
                    local flag = options.flag
                    local callback = options.callback
                    
                    local textbox_frame = Instance.new("Frame")
                    textbox_frame.Name = "TextboxFrame"
                    textbox_frame.Size = UDim2.new(1, 0, 0, 50)
                    textbox_frame.BackgroundTransparency = 1
                    textbox_frame.Parent = section
                    
                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.new(1, 0, 0, 20)
                    label.BackgroundTransparency = 1
                    label.Text = name
                    label.TextColor3 = Color3.fromRGB(220, 220, 220)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 14
                    label.Parent = textbox_frame
                    
                    local box = Instance.new("TextBox")
                    box.Name = "Box"
                    box.Size = UDim2.new(1, 0, 0, 30)
                    box.Position = UDim2.new(0, 0, 0, 20)
                    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    box.PlaceholderText = placeholder
                    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                    box.Text = ""
                    box.TextColor3 = Color3.fromRGB(220, 220, 220)
                    box.Font = Enum.Font.Gotham
                    box.TextSize = 14
                    box.Parent = textbox_frame
                    
                    local box_corner = Instance.new("UICorner")
                    box_corner.CornerRadius = UDim.new(0, 4)
                    box_corner.Parent = box
                    
                    box.FocusLost:Connect(function()
                        if flag then
                            library.flags[flag] = box.Text
                        end
                        if callback then
                            callback(box.Text)
                        end
                    end)
                    
                    return {
                        set = function(text)
                            box.Text = text
                        end,
                        get = function() return box.Text end,
                        frame = textbox_frame
                    }
                end
                
                -- List
                function section_obj:list(options)
                    options = options or {}
                    local name = options.name or "List"
                    local items = options.items or {}
                    local size = options.size or 150
                    local flag = options.flag
                    
                    local list_frame = Instance.new("Frame")
                    list_frame.Name = "ListFrame"
                    list_frame.Size = UDim2.new(1, 0, 0, size + 25)
                    list_frame.BackgroundTransparency = 1
                    list_frame.Parent = section
                    
                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.new(1, 0, 0, 20)
                    label.BackgroundTransparency = 1
                    label.Text = name
                    label.TextColor3 = Color3.fromRGB(220, 220, 220)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 14
                    label.Parent = list_frame
                    
                    local list_container = Instance.new("ScrollingFrame")
                    list_container.Name = "ListContainer"
                    list_container.Size = UDim2.new(1, 0, 0, size)
                    list_container.Position = UDim2.new(0, 0, 0, 25)
                    list_container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    list_container.BorderSizePixel = 0
                    list_container.ScrollBarThickness = 4
                    list_container.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 45)
                    list_container.CanvasSize = UDim2.new(0, 0, 0, 0)
                    list_container.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    list_container.Parent = list_frame
                    
                    local container_corner = Instance.new("UICorner")
                    container_corner.CornerRadius = UDim.new(0, 4)
                    container_corner.Parent = list_container
                    
                    local container_padding = Instance.new("UIPadding")
                    container_padding.PaddingTop = UDim.new(0, 4)
                    container_padding.PaddingBottom = UDim.new(0, 4)
                    container_padding.Parent = list_container
                    
                    local list_layout = Instance.new("UIListLayout")
                    list_layout.Padding = UDim.new(0, 2)
                    list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                    list_layout.VerticalAlignment = Enum.VerticalAlignment.Top
                    list_layout.SortOrder = Enum.SortOrder.LayoutOrder
                    list_layout.Parent = list_container
                    
                    local selected_item = items[1] or ""
                    
                    local function refresh_options(new_items)
                        items = new_items
                        for _, child in ipairs(list_container:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        
                        for _, item in ipairs(items) do
                            local item_button = Instance.new("TextButton")
                            item_button.Name = "Item"
                            item_button.Size = UDim2.new(1, -8, 0, 28)
                            item_button.Position = UDim2.new(0, 4, 0, 0)
                            item_button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                            item_button.BackgroundTransparency = 0.5
                            item_button.Text = ""
                            item_button.AutoButtonColor = false
                            item_button.Parent = list_container
                            
                            local item_corner = Instance.new("UICorner")
                            item_corner.CornerRadius = UDim.new(0, 4)
                            item_corner.Parent = item_button
                            
                            local item_text = Instance.new("TextLabel")
                            item_text.Name = "Text"
                            item_text.Size = UDim2.new(1, -10, 1, 0)
                            item_text.Position = UDim2.new(0, 5, 0, 0)
                            item_text.BackgroundTransparency = 1
                            item_text.Text = item
                            item_text.TextColor3 = Color3.fromRGB(200, 200, 200)
                            item_text.TextXAlignment = Enum.TextXAlignment.Left
                            item_text.Font = Enum.Font.Gotham
                            item_text.TextSize = 13
                            item_text.Parent = item_button
                            
                            if item == selected_item then
                                item_button.BackgroundColor3 = library.accent_color
                                item_button.BackgroundTransparency = 0.3
                                item_text.TextColor3 = Color3.fromRGB(255, 255, 255)
                            end
                            
                            item_button.MouseButton1Click:Connect(function()
                                selected_item = item
                                for _, btn in ipairs(list_container:GetChildren()) do
                                    if btn:IsA("TextButton") then
                                        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                                        btn.BackgroundTransparency = 0.5
                                        btn.Text.TextColor3 = Color3.fromRGB(200, 200, 200)
                                    end
                                end
                                item_button.BackgroundColor3 = library.accent_color
                                item_button.BackgroundTransparency = 0.3
                                item_text.TextColor3 = Color3.fromRGB(255, 255, 255)
                                
                                if flag then
                                    library.flags[flag] = item
                                end
                            end)
                        end
                    end
                    
                    refresh_options(items)
                    
                    return {
                        refresh_options = refresh_options,
                        set = function(value)
                            selected_item = value
                            for _, btn in ipairs(list_container:GetChildren()) do
                                if btn:IsA("TextButton") and btn.Text.Text == value then
                                    btn.BackgroundColor3 = library.accent_color
                                    btn.BackgroundTransparency = 0.3
                                    btn.Text.TextColor3 = Color3.fromRGB(255, 255, 255)
                                else
                                    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                                    btn.BackgroundTransparency = 0.5
                                    btn.Text.TextColor3 = Color3.fromRGB(200, 200, 200)
                                end
                            end
                        end,
                        get = function() return selected_item end,
                        frame = list_frame
                    }
                end
                
                -- Colorpicker
                function section_obj:colorpicker(options)
                    options = options or {}
                    local name = options.name or "Colorpicker"
                    local default_color = options.color or Color3.fromRGB(255, 255, 255)
                    local flag = options.flag
                    local callback = options.callback
                    
                    local color_frame = Instance.new("Frame")
                    color_frame.Name = "ColorFrame"
                    color_frame.Size = UDim2.new(1, 0, 0, 24)
                    color_frame.BackgroundTransparency = 1
                    color_frame.Parent = section
                    
                    local label = Instance.new("TextLabel")
                    label.Name = "Label"
                    label.Size = UDim2.new(1, -40, 1, 0)
                    label.Position = UDim2.new(0, 0, 0, 0)
                    label.BackgroundTransparency = 1
                    label.Text = name
                    label.TextColor3 = Color3.fromRGB(220, 220, 220)
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 14
                    label.Parent = color_frame
                    
                    local color_preview = Instance.new("TextButton")
                    color_preview.Name = "ColorPreview"
                    color_preview.Size = UDim2.new(0, 30, 0, 20)
                    color_preview.Position = UDim2.new(1, -30, 0, 2)
                    color_preview.BackgroundColor3 = default_color
                    color_preview.Text = ""
                    color_preview.AutoButtonColor = false
                    color_preview.Parent = color_frame
                    
                    local preview_corner = Instance.new("UICorner")
                    preview_corner.CornerRadius = UDim.new(0, 4)
                    preview_corner.Parent = color_preview
                    
                    -- Color picker dropdown
                    local color_dropdown = Instance.new("Frame")
                    color_dropdown.Name = "ColorDropdown"
                    color_dropdown.Size = UDim2.new(0, 200, 0, 180)
                    color_dropdown.Position = UDim2.new(0, 0, 1, 5)
                    color_dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    color_dropdown.BackgroundTransparency = 0.1
                    color_dropdown.BorderSizePixel = 0
                    color_dropdown.Visible = false
                    color_dropdown.ZIndex = 10
                    color_dropdown.Parent = color_preview
                    
                    local dropdown_corner = Instance.new("UICorner")
                    dropdown_corner.CornerRadius = UDim.new(0, 4)
                    dropdown_corner.Parent = color_dropdown
                    
                    local dropdown_stroke = Instance.new("UIStroke")
                    dropdown_stroke.Color = Color3.fromRGB(45, 45, 45)
                    dropdown_stroke.Thickness = 1
                    dropdown_stroke.Parent = color_dropdown
                    
                    local hue_sat = Instance.new("ImageLabel")
                    hue_sat.Name = "HueSat"
                    hue_sat.Size = UDim2.new(1, -40, 1, -40)
                    hue_sat.Position = UDim2.new(0, 10, 0, 10)
                    hue_sat.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    hue_sat.BackgroundTransparency = 0
                    hue_sat.Image = "rbxasset://textures/ui/GuiImagePalette.png"
                    hue_sat.ScaleType = Enum.ScaleType.Stretch
                    hue_sat.SliceCenter = Rect.new(0, 0, 0, 0)
                    hue_sat.Parent = color_dropdown
                    
                    local hue_sat_corner = Instance.new("UICorner")
                    hue_sat_corner.CornerRadius = UDim.new(0, 4)
                    hue_sat_corner.Parent = hue_sat
                    
                    local hue = Instance.new("Frame")
                    hue.Name = "Hue"
                    hue.Size = UDim2.new(0, 20, 1, -40)
                    hue.Position = UDim2.new(1, -30, 0, 10)
                    hue.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    hue.BorderSizePixel = 0
                    hue.Parent = color_dropdown
                    
                    local hue_corner = Instance.new("UICorner")
                    hue_corner.CornerRadius = UDim.new(0, 4)
                    hue_corner.Parent = hue
                    
                    local hue_gradient = Instance.new("UIGradient")
                    hue_gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    })
                    hue_gradient.Rotation = 90
                    hue_gradient.Parent = hue
                    
                    local preview = Instance.new("Frame")
                    preview.Name = "Preview"
                    preview.Size = UDim2.new(0, 30, 0, 30)
                    preview.Position = UDim2.new(0, 10, 1, -40)
                    preview.BackgroundColor3 = default_color
                    preview.BorderSizePixel = 0
                    preview.Parent = color_dropdown
                    
                    local preview_corner2 = Instance.new("UICorner")
                    preview_corner2.CornerRadius = UDim.new(0, 4)
                    preview_corner2.Parent = preview
                    
                    local hex_input = Instance.new("TextBox")
                    hex_input.Name = "HexInput"
                    hex_input.Size = UDim2.new(1, -50, 0, 30)
                    hex_input.Position = UDim2.new(0, 50, 1, -40)
                    hex_input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    hex_input.BackgroundTransparency = 0.3
                    hex_input.Text = "#" .. default_color:ToHex()
                    hex_input.TextColor3 = Color3.fromRGB(255, 255, 255)
                    hex_input.PlaceholderText = "#FFFFFF"
                    hex_input.Font = Enum.Font.Gotham
                    hex_input.TextSize = 14
                    hex_input.Parent = color_dropdown
                    
                    local hex_corner = Instance.new("UICorner")
                    hex_corner.CornerRadius = UDim.new(0, 4)
                    hex_corner.Parent = hex_input
                    
                    local current_color = default_color
                    
                    local function update_color_from_hue_sat(x, y)
                        local size = hue_sat.AbsoluteSize
                        local hue_val = (hue_sat.BackgroundColor3:ToHSV())
                        local sat = math.clamp(x / size.X, 0, 1)
                        local val = 1 - math.clamp(y / size.Y, 0, 1)
                        
                        local h = hue_val
                        local s = sat
                        local v = val
                        
                        current_color = Color3.fromHSV(h, s, v)
                        preview.BackgroundColor3 = current_color
                        color_preview.BackgroundColor3 = current_color
                        hex_input.Text = "#" .. current_color:ToHex()
                        
                        if flag then
                            library.flags[flag] = current_color
                        end
                        if callback then
                            callback(current_color)
                        end
                    end
                    
                    local function update_hue(y)
                        local size = hue.AbsoluteSize
                        local hue_val = math.clamp(y / size.Y, 0, 0.99)
                        local color = Color3.fromHSV(hue_val, 1, 1)
                        hue_sat.BackgroundColor3 = color
                        
                        local current_h, current_s, current_v = current_color:ToHSV()
                        current_color = Color3.fromHSV(hue_val, current_s, current_v)
                        preview.BackgroundColor3 = current_color
                        color_preview.BackgroundColor3 = current_color
                        hex_input.Text = "#" .. current_color:ToHex()
                        
                        if flag then
                            library.flags[flag] = current_color
                        end
                        if callback then
                            callback(current_color)
                        end
                    end
                    
                    hue_sat.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local pos = hue_sat.AbsolutePosition
                            local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                            local relative = mouse_pos - pos
                            update_color_from_hue_sat(relative.X, relative.Y)
                        end
                    end)
                    
                    hue_sat.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                local pos = hue_sat.AbsolutePosition
                                local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                                local relative = mouse_pos - pos
                                update_color_from_hue_sat(relative.X, relative.Y)
                            end
                        end
                    end)
                    
                    hue.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local pos = hue.AbsolutePosition
                            local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                            local relative = mouse_pos - pos
                            update_hue(relative.Y)
                        end
                    end)
                    
                    hue.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                local pos = hue.AbsolutePosition
                                local mouse_pos = Vector2.new(Mouse.X, Mouse.Y)
                                local relative = mouse_pos - pos
                                update_hue(relative.Y)
                            end
                        end
                    end)
                    
                    hex_input.FocusLost:Connect(function()
                        local hex = hex_input.Text:gsub("#", "")
                        local success, color = pcall(function()
                            return Color3.fromHex(hex)
                        end)
                        if success then
                            current_color = color
                            preview.BackgroundColor3 = color
                            color_preview.BackgroundColor3 = color
                            hex_input.Text = "#" .. color:ToHex()
                            
                            local h, s, v = color:ToHSV()
                            hue_sat.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                            
                            if flag then
                                library.flags[flag] = color
                            end
                            if callback then
                                callback(color)
                            end
                        end
                    end)
                    
                    color_preview.MouseButton1Click:Connect(function()
                        color_dropdown.Visible = not color_dropdown.Visible
                    end)
                    
                    if flag then
                        library.flags[flag] = default_color
                    end
                    
                    return {
                        set = function(color)
                            current_color = color
                            preview.BackgroundColor3 = color
                            color_preview.BackgroundColor3 = color
                            hex_input.Text = "#" .. color:ToHex()
                            
                            local h, s, v = color:ToHSV()
                            hue_sat.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        end,
                        get = function() return current_color end,
                        frame = color_frame
                    }
                end
                
                return section_obj
            end
            
            table.insert(self.columns, column_obj)
            return column_obj
        end
        
        -- Tab switching
        tab_button.MouseButton1Click:Connect(function()
            if self.current_tab then
                self.current_tab.content.Visible = false
                self.current_tab.button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                self.current_tab.button.BackgroundTransparency = 0.5
                self.current_tab.button.Text.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            self.current_tab = tab_obj
            tab_obj.content.Visible = true
            tab_button.BackgroundColor3 = library.accent_color
            tab_button.BackgroundTransparency = 0.2
            tab_text.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        
        -- If this is the first tab, show it
        if #self.tabs == 0 then
            self.current_tab = tab_obj
            tab_obj.content.Visible = true
            tab_button.BackgroundColor3 = library.accent_color
            tab_button.BackgroundTransparency = 0.2
            tab_text.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        table.insert(self.tabs, tab_obj)
        return tab_obj
    end
    
    function window_obj:unload()
        self.gui:Destroy()
        for _, conn in ipairs(library.connections) do
            conn:Disconnect()
        end
        library.gui = nil
    end
    
    return window_obj
end

-- Config system
function library:get_config()
    local config_data = {}
    for flag, value in pairs(self.flags) do
        if type(value) == "EnumItem" then
            config_data[flag] = value.Name
        elseif type(value) == "Color3" then
            config_data[flag] = {value.R, value.G, value.B}
        elseif type(value) == "table" then
            local serializable = true
            for _, v in ipairs(value) do
                if type(v) ~= "string" and type(v) ~= "number" and type(v) ~= "boolean" then
                    serializable = false
                    break
                end
            end
            if serializable then
                config_data[flag] = value
            end
        else
            config_data[flag] = value
        end
    end
    return game:GetService("HttpService"):JSONEncode(config_data)
end

function library:load_config(json_data)
    local success, config = pcall(function()
        return game:GetService("HttpService"):JSONDecode(json_data)
    end)
    
    if success and type(config) == "table" then
        for flag, value in pairs(config) do
            if self.flags[flag] ~= nil then
                if type(value) == "table" and #value == 3 and type(value[1]) == "number" then
                    self.flags[flag] = Color3.new(value[1], value[2], value[3])
                elseif type(value) == "string" and Enum.KeyCode[value] then
                    self.flags[flag] = Enum.KeyCode[value]
                else
                    self.flags[flag] = value
                end
            end
        end
        return true
    end
    return false
end

function library:unload_menu()
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
end

return library, notifications
