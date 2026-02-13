-- Variables 
local uis = game:GetService("UserInputService") 
local players = game:GetService("Players") 
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = game:GetService("CoreGui")
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local sound_service = game:GetService("SoundService")

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new 
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local point_object_space = empty_cfr.PointToObjectSpace
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer 
local mouse = lp:GetMouse() 
local gui_offset = gui_service:GetGuiInset().Y

local max = math.max 
local floor = math.floor 
local min = math.min 
local abs = math.abs 
local noise = math.noise
local rad = math.rad 
local random = math.random 
local pow = math.pow 
local sin = math.sin 
local pi = math.pi 
local tan = math.tan 
local atan2 = math.atan2 
local clamp = math.clamp 

local insert = table.insert 
local find = table.find 
local remove = table.remove
local concat = table.concat
-- 

-- Library init
getgenv().library = {
    directory = "priv9",
    folders = {
        "/fonts",
        "/configs",
    },
    flags = {},
    config_flags = {},

    connections = {},   
    notifications = {},
    playerlist_data = {
        players = {},
        player = {}, 
    },
    colorpicker_open = false; 
    gui; 
    sgui;
    watermark_instance = nil; -- Store watermark reference
    current_open_element = nil; -- Track currently open dropdown/keybind
}

local themes = {
    preset = {
        outline = rgb(10, 10, 10),
        inline = rgb(35, 35, 35),
        text = rgb(255, 255, 255),
        text_outline = rgb(0, 0, 0),
        background = rgb(20, 20, 20),
        accent = hex("#0099FF"),
    },

    utility = {
        inline = {
            BackgroundColor3 = {} 	
        },
        text = {
            TextColor3 = {}	
        },
        text_outline = {
            Color = {} 	
        },
        accent = {
            BackgroundColor3 = {}, 	
            TextColor3 = {}, 
            ImageColor3 = {}, 
            ScrollBarImageColor3 = {} 
        },
    }
}

local keys = {
    [Enum.KeyCode.LeftShift] = "LS",
    [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC",
    [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS",
    [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent",
    [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA",
    [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2",
    [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4",
    [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8",
    [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.KeypadOne] = "Num1",
    [Enum.KeyCode.KeypadTwo] = "Num2",
    [Enum.KeyCode.KeypadThree] = "Num3",
    [Enum.KeyCode.KeypadFour] = "Num4",
    [Enum.KeyCode.KeypadFive] = "Num5",
    [Enum.KeyCode.KeypadSix] = "Num6",
    [Enum.KeyCode.KeypadSeven] = "Num7",
    [Enum.KeyCode.KeypadEight] = "Num8",
    [Enum.KeyCode.KeypadNine] = "Num9",
    [Enum.KeyCode.KeypadZero] = "Num0",
    [Enum.KeyCode.Minus] = "-",
    [Enum.KeyCode.Equals] = "=",
    [Enum.KeyCode.Tilde] = "~",
    [Enum.KeyCode.LeftBracket] = "[",
    [Enum.KeyCode.RightBracket] = "]",
    [Enum.KeyCode.RightParenthesis] = ")",
    [Enum.KeyCode.LeftParenthesis] = "(",
    [Enum.KeyCode.Semicolon] = ",",
    [Enum.KeyCode.Quote] = "'",
    [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Comma] = ",",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/",
    [Enum.KeyCode.Asterisk] = "*",
    [Enum.KeyCode.Plus] = "+",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Backquote] = "`",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
    [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC",
}
    
library.__index = library

for _, path in next, library.folders do 
    makefolder(library.directory .. path)
end

local flags = library.flags 
local config_flags = library.config_flags

-- Font importing system 
local fonts = {}; do
    function Register_Font(Name, Weight, Style, Asset)
        if not isfile(Asset.Id) then
            writefile(Asset.Id, Asset.Font)
        end
        
        if isfile(Name .. ".font") then
            delfile(Name .. ".font")
        end
        
        local Data = {
            name = Name,
            faces = {
                {
                    name = "Regular",
                    weight = Weight,
                    style = Style,
                    assetId = getcustomasset(Asset.Id),
                },
            },
        }
        
        writefile(Name .. ".font", game:GetService("HttpService"):JSONEncode(Data))
        
        return getcustomasset(Name .. ".font");
    end
    
    local ProggyTiny = Register_Font("Tahoma", 200, "Normal", {
        Id = "Tahoma.ttf",
        Font = game:HttpGet("https://raw.githubusercontent.com/0x340/Priv9-UI-Libary/main/fonts/tahoma_bold.ttf"),
    })

    local ProggyClean = Register_Font("ProggyClean", 200, "normal", {
        Id = "ProggyClean.ttf",
        Font = game:HttpGet("https://raw.githubusercontent.com/0x340/Priv9-UI-Libary/main/fonts/ProggyClean.ttf")
    })
    
    fonts = {
        ["TahomaBold"] = Font.new(ProggyTiny, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
        ["ProggyClean"] = Font.new(ProggyClean, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    }
end
-- 

-- Library functions 
-- Misc functions
function library:tween(obj, properties) 
    local tween = tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), properties):Play()
        
    return tween
end 

function library:close_current_element() 
    if library.current_open_element and library.current_open_element.set_visible then
        library.current_open_element:set_visible(false)
        if library.current_open_element.toggle_open then
            library.current_open_element:toggle_open(false)
        end
        library.current_open_element = nil
    end
end 

function library:resizify(frame) 
    local Frame = Instance.new("TextButton")
    Frame.Position = dim2(1, -10, 1, -10)
    Frame.BorderColor3 = rgb(0, 0, 0)
    Frame.Size = dim2(0, 10, 0, 10)
    Frame.BorderSizePixel = 0
    Frame.BackgroundColor3 = rgb(255, 255, 255)
    Frame.Parent = frame
    Frame.BackgroundTransparency = 1 
    Frame.Text = ""
    Frame.FontFace = fonts["ProggyClean"]

    local resizing = false 
    local start_size 
    local start 
    local og_size = frame.Size  

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            start = input.Position
            start_size = frame.Size
        end
    end)

    Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    library:connection(uis.InputChanged, function(input, game_event) 
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local viewport_x = camera.ViewportSize.X
            local viewport_y = camera.ViewportSize.Y

            local current_size = dim2(
                start_size.X.Scale,
                math.max(300, start_size.X.Offset + (input.Position.X - start.X)),
                start_size.Y.Scale,
                math.max(200, start_size.Y.Offset + (input.Position.Y - start.Y))
            )
            frame.Size = current_size
        end
    end)
end

function library:mouse_in_frame(uiobject)
    if not uiobject or not uiobject.AbsolutePosition or not uiobject.AbsoluteSize then
        return false
    end
    
    local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
    local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X

    return (y_cond and x_cond)
end

library.lerp = function(start, finish, t)
    t = t or 1 / 8

    return start * (1 - t) + finish * t
end

function library:draggify(frame)
    local dragging = false 
    local start_size = frame.Position
    local start 

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = input.Position
            start_size = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    library:connection(uis.InputChanged, function(input, game_event) 
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local current_position = dim2(
                0,
                start_size.X.Offset + (input.Position.X - start.X),
                0,
                start_size.Y.Offset + (input.Position.Y - start.Y)
            )

            frame.Position = current_position
        end
    end)
end 

function library:convert(str)
    local values = {}

    for value in string.gmatch(str, "[^,]+") do
        insert(values, tonumber(value))
    end
    
    if #values == 4 then              
        return unpack(values)
    else 
        return
    end
end

function library:convert_enum(enum)
    local enum_parts = {}

    for part in string.gmatch(enum, "[%w_]+") do
        insert(enum_parts, part)
    end
    
    local enum_table = Enum
    for i = 2, #enum_parts do
        local enum_item = enum_table[enum_parts[i]]

        enum_table = enum_item
    end

    return enum_table
end

local config_holder;
function library:update_config_list() 
    if not config_holder then 
        return 
    end
    
    local list = {}
    
    for idx, file in listfiles(library.directory .. "/configs") do
        local name = file:gsub(library.directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(library.directory .. "\\configs\\", "")
        list[#list + 1] = name
    end
    

    config_holder.refresh_options(list)
end 

function library:get_config()
    local Config = {}

    for _, v in flags do
        if type(v) == "table" and v.key then
            Config[_] = {active = v.active, mode = v.mode, key = tostring(v.key)}
        elseif type(v) == "table" and v["Transparency"] and v["Color"] then
            Config[_] = {Transparency = v["Transparency"], Color = v["Color"]:ToHex()}
        else
            Config[_] = v
        end
    end 
    
    return http_service:JSONEncode(Config)
end

function library:load_config(config_json) 
    local config = http_service:JSONDecode(config_json)
    
    for _, v in next, config do 
        local function_set = library.config_flags[_]
        
        if _ == "config_name_list" then 
            continue
        end

        if function_set then 
            if type(v) == "table" and v["Transparency"] and v["Color"] then
                function_set(hex(v["Color"]), v["Transparency"])
            elseif type(v) == "table" and v["active"] then 
                function_set(v)
            else
                function_set(v)
            end
        end 
    end 
end 

function library:round(number, float) 
    local multiplier = 1 / (float or 1)

    return floor(number * multiplier + 0.5) / multiplier
end 

function library:apply_theme(instance, theme, property) 
    insert(themes.utility[theme][property], instance)
end

function library:update_theme(theme, color)
    if not themes.utility[theme] then return end
    
    for property, instances in pairs(themes.utility[theme]) do 
        for _, object in ipairs(instances) do 
            if object and object.Parent then
                pcall(function()
                    object[property] = color
                end)
            end
        end 
    end 

    themes.preset[theme] = color 
end 

function library:update_accent_color(color)
    library:update_theme("accent", color)
    
    local function find_and_update_toggles(instance)
        if not instance then return end
        
        if instance.Name == "Fill" and instance.Parent and instance.Parent.Parent and instance.Parent.Parent:IsA("TextButton") then
            if instance:FindFirstAncestorWhichIsA("ScreenGui") then
                instance.BackgroundColor3 = color
            end
        end
        
        for _, child in ipairs(instance:GetChildren()) do
            find_and_update_toggles(child)
        end
    end
    
    if library.gui then
        find_and_update_toggles(library.gui)
    end
    
    for _, notification in ipairs(library.notifications.notifs or {}) do
        if notification and notification.Parent then
            notification.BackgroundColor3 = color
        end
    end
    
    if library.watermark_instance and library.watermark_instance.Parent then
        library.watermark_instance.BackgroundColor3 = color
    end
end

function library:connection(signal, callback)
    local connection = signal:Connect(callback)
    
    insert(library.connections, connection)

    return connection 
end

function library:apply_stroke(parent) 
    local STROKE = library:create("UIStroke", {
        Parent = parent,
        Color = themes.preset.text_outline, 
        LineJoinMode = Enum.LineJoinMode.Miter
    }) 

    library:apply_theme(STROKE, "text_outline", "Color")
end

function library:create(instance, options)
    local ins = Instance.new(instance) 
    
    for prop, value in next, options do 
        ins[prop] = value
    end
    
    if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then 	
        ins.FontFace = fonts["ProggyClean"]
        ins.TextSize = 12
        library:apply_theme(ins, "text", "TextColor3")
        library:apply_stroke(ins)
    end
    
    return ins 
end

function library:unload_menu() 
    if library.gui then 
        library.gui:Destroy()
    end
    
    for index, connection in next, library.connections do 
        connection:Disconnect() 
        connection = nil 
    end     

    if library.sgui then 
        library.sgui:Destroy()
    end 
    
    library = nil 
end 
--

-- Library element functions
function library:window(properties)
    local cfg = {
        name = properties.name or properties.Name or "priv9",
        size = properties.size or properties.Size or dim2(0, 600, 0, 400), 
        selected_tab 
    }

    library.gui = library:create("ScreenGui", {
        Parent = coregui,
        Name = "\0",
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    -- Window
    local window_outline = library:create("Frame", {
        Parent = library.gui;
        Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2);
        BorderColor3 = rgb(0, 0, 0);
        Size = cfg.size;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(20, 20, 20)
    });

    library:create("UICorner", {
        CornerRadius = UDim.new(0, 3);
        Parent = window_outline
    })

    window_outline.Position = dim2(0, window_outline.AbsolutePosition.Y, 0, window_outline.AbsolutePosition.Y)
    cfg.main_outline = window_outline

    library:resizify(window_outline)
    library:draggify(window_outline)
    
    local title_holder = library:create("Frame", {
        Parent = window_outline;
        BackgroundTransparency = 0.800000011920929;
        Position = dim2(0, 2, 0, 2);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 0, 20);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    });
    
    local ui_title = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = title_holder;
        BackgroundTransparency = 1;
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        TextSize = 12;
        RichText = true;
        BackgroundColor3 = rgb(255, 255, 255)
    }); cfg.title = ui_title
    
    local tab_button_holder = library:create("Frame", {
        AnchorPoint = vec2(0, 1);
        Parent = window_outline;
        BackgroundTransparency = 0.800000011920929;
        Position = dim2(0, 2, 1, -2);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 0, 20);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    }); cfg.tab_button_holder = tab_button_holder
    
    library:create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Center;
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        Parent = tab_button_holder;
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalFlex = Enum.UIFlexAlignment.Fill
    });

    function cfg.toggle_menu(bool) 
        window_outline.Visible = bool 
    end

    return setmetatable(cfg, library)
end 

function library:tab(properties)
    local cfg = {
        name = properties.name or "visuals", 
        count = 0
    }

    -- Instances 
    -- Tab Button
    local tab_button = library:create("TextButton", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(170, 170, 170);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = self.tab_button_holder;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    -- Page
    local Page = library:create("Frame", {
        Parent = self.main_outline;
        BackgroundTransparency = 0.6;
        Position = dim2(0, 2, 0, 24);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 1, -48);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0),
        Visible = false,
    }); cfg.page = Page
    
    library:create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        Parent = Page;
        Padding = dim(0, 2);
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalFlex = Enum.UIFlexAlignment.Fill
    });
    
    library:create("UIPadding", {
        PaddingTop = dim(0, 2);
        PaddingBottom = dim(0, 2);
        Parent = Page;
        PaddingRight = dim(0, 2);
        PaddingLeft = dim(0, 2)
    });
    
    function cfg.open_tab() 
        local selected_tab = self.selected_tab
        
        if selected_tab then 
            selected_tab[1].Visible = false 
            selected_tab[2].TextColor3 = rgb(170, 170, 170)
            selected_tab = nil 
        end

        Page.Visible = true
        tab_button.TextColor3 = rgb(255, 255, 255)
        self.selected_tab = {Page, tab_button}
        
        library:close_current_element()
    end

    tab_button.MouseButton1Down:Connect(function()
        cfg.open_tab()
    end)

    if not self.selected_tab then 
        cfg.open_tab(true) 
    end

    return setmetatable(cfg, library)    
end 

local notifications = {notifs = {}} 
library.notifications = notifications

library.sgui = library:create("ScreenGui", {
    Name = "NotificationGui",
    Parent = gethui(),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})

function notifications:refresh_notifs() 
    for i, v in ipairs(notifications.notifs) do 
        if v and v.Parent then
            local Position = vec2(50, 50)
            tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = dim_offset(Position.X, Position.Y + ((i-1) * 30))}):Play()
        end
    end
end

function notifications:fade(path, is_fading)
    local fading = is_fading and 1 or 0 
    
    tween_service:Create(path, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = fading}):Play()

    for _, instance in path:GetDescendants() do 
        if not instance:IsA("GuiObject") then 
            if instance:IsA("UIStroke") then
                tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Transparency = fading}):Play()
            end
            continue
        end 

        if instance:IsA("TextLabel") then
            tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = fading}):Play()
        elseif instance:IsA("Frame") then
            local transparency = instance.BackgroundTransparency
            if instance.Name == "Accent" then
                tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = fading}):Play()
            else
                tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = is_fading and 1 or 0.6}):Play()
            end
        end
    end
end 

function notifications:create_notification(options)
    local cfg = {
        name = options.name or "Notification",
    }

    -- Instances
    local outline = library:create("Frame", {
        Parent = library.sgui;
        Position = dim_offset(-50, 50 + (#notifications.notifs * 30));
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 0, 0, 24);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        BackgroundColor3 = themes.preset.accent,
        Name = "Accent",
        ZIndex = 10
    });
    
    local dark = library:create("Frame", {
        Parent = outline;
        BackgroundTransparency = 0.6;
        Position = dim2(0, 2, 0, 2);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 1, -4);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0),
        ZIndex = 11
    });

    library:create("UIPadding", {
        PaddingTop = dim(0, 7);
        PaddingBottom = dim(0, 6);
        Parent = dark;
        PaddingRight = dim(0, 7);
        PaddingLeft = dim(0, 4)
    });

    library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = dark;
        Size = dim2(0, 0, 1, 0);
        Position = dim2(0, 1, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 12
    }); 
    
    local index = #notifications.notifs + 1
    notifications.notifs[index] = outline
    
    notifications:refresh_notifs()
    tween_service:Create(outline, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = dim2(0, 50, 0, 50 + ((index-1) * 30))}):Play()
    
    notifications:fade(outline, false)

    task.spawn(function()
        task.wait(3)
        
        notifications.notifs[index] = nil
        notifications:fade(outline, true)
        task.wait(1)
        outline:Destroy() 
        notifications:refresh_notifs()
    end)
    
    return outline
end

function library:watermark(options)
    local cfg = {
        name = options.name or "nebulahax";
    }
    
    -- Instances
    local outline = library:create("Frame", {
        Parent = library.sgui;
        Position = dim2(0, 50, 0, 50); 
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 0, 0, 24);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        BackgroundColor3 = themes.preset.accent,
        Name = "Watermark",
        ZIndex = 10
    }); 
    
    library.watermark_instance = outline
    library.watermark_outline = outline
    
    library:draggify(outline);
    
    local dark = library:create("Frame", {
        Parent = outline;
        BackgroundTransparency = 0.6;
        Position = dim2(0, 2, 0, 2);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 1, -4);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0),
        ZIndex = 11
    });

    library:create("UIPadding", {
        PaddingTop = dim(0, 7);
        PaddingBottom = dim(0, 6);
        Parent = dark;
        PaddingRight = dim(0, 7);
        PaddingLeft = dim(0, 4)
    });

    local text_title = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = dark;
        Size = dim2(0, 0, 1, 0);
        Position = dim2(0, 1, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 12
    }); 

    function cfg.update_text(text)
        text_title.Text = text
    end

    cfg.update_text(cfg.name)

    return setmetatable(cfg, library)
end 

local watermark = library:watermark({name = "priv9 - 0 fps - 0 ping"})
local fps = 0
local watermark_delay = tick() 

run.RenderStepped:Connect(function()
    fps = fps + 1

    if tick() - watermark_delay > 1 then 
        watermark_delay = tick()
        local ping = math.floor(stats.PerformanceStats.Ping:GetValue() or 0) .. "ms"                
        watermark.update_text(string.format("priv9 - fps: %s - ping: %s", fps, ping))
        fps = 0
    end
end)

function library:column(properties)
    self.count = (self.count or 0) + 1

    local cfg = {count = self.count} 

    local scrolling_frame = library:create("ScrollingFrame", {
        ScrollBarImageColor3 = rgb(0, 0, 0);
        Active = true;
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 0;
        Parent = self.page;
        LayoutOrder = -1;
        BackgroundTransparency = 1;
        ScrollBarImageTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        CanvasSize = dim2(0, 0, 0, 0)
    }); cfg.column = scrolling_frame

    library:create("UIListLayout", {
        Parent = scrolling_frame;
        Padding = dim(0, 5);
        SortOrder = Enum.SortOrder.LayoutOrder
    });

    return setmetatable(cfg, library)            
end 

function library:section(properties)            
    local cfg = {
        name = properties.name or properties.Name or "section",
        size = properties.size or 1, 
        autofill = properties.auto_fill or false,
        count = self.count;
        color = self.color;
        elements = nil; -- Will hold the elements container
    }

    -- Instances
    local accent = library:create("Frame", {
        Parent = self.column;
        ClipsDescendants = true;
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(accent, "inline", "BackgroundColor3");

    local dark = library:create("Frame", {
        Parent = accent;
        BackgroundTransparency = 0.6;
        Position = dim2(0, 2, 0, 16);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 1, -18);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    });
    
    local elements = library:create("Frame", {
        Parent = dark;
        Position = dim2(0, 4, 0, 5);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -8, 0, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); cfg.elements = elements

    if cfg.autofill == false then 
        elements.AutomaticSize = Enum.AutomaticSize.Y;
        accent.AutomaticSize = Enum.AutomaticSize.Y;
        accent.Size = dim2(1, 0, 0, 0);
        
        local UIPadding = library:create("UIPadding", {
            Parent = elements,
            Name = "",
            PaddingBottom = dim(0, 7)
        })
    else 
        accent.Size = dim2(1, 0, 0, cfg.size * 100); -- Fixed sizing
    end
    
    library:create("UIListLayout", {
        Parent = elements;
        Padding = dim(0, 6);
        SortOrder = Enum.SortOrder.LayoutOrder
    });
    
    local title = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = accent;
        Size = dim2(1, 0, 0, 14);
        Position = dim2(0, 4, 0, 1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    return setmetatable(cfg, library)
end 

-- Elements  
-- FIXED TOGGLE FUNCTION - PROPERLY HANDLES DEFAULT PARAMETER
function library:toggle(options) 
    local cfg = {
        enabled = options.default or false,
        name = options.name or "Toggle",
        flag = options.flag or options.name or "Flag",
        
        default = options.default or false,
        folding = options.folding or false, 
        callback = options.callback or function() end,

        color = self.color;
        count = self.count;
    }

    -- Instances
    local toggle = library:create("TextButton", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        Text = "";
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = toggle;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 1, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    }); 
    
    local accent = library:create("Frame", {
        AnchorPoint = vec2(1, 0);
        Parent = toggle;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 12, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(accent, "inline", "BackgroundColor3");    
    
    local fill = library:create("Frame", {
        Parent = accent;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        Name = "Fill"
    });                
    
    -- Sub sections
    local elements;

    if cfg.folding then
        elements = library:create("Frame", {
            Parent = self.elements;
            BackgroundTransparency = 1;
            Position = dim2(0, 4, 0, 21);
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            Visible = cfg.default;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.elements = elements
        
        library:create("UIListLayout", {
            Parent = elements;
            Padding = dim(0, 6);
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder
        });                            
    end 
    
    -- Functions
    function cfg.set(bool)
        bool = bool ~= nil and bool or false
        cfg.enabled = bool
        fill.BackgroundColor3 = bool and themes.preset.accent or themes.preset.inline
        flags[cfg.flag] = bool
        cfg.callback(bool)

        if cfg.folding and elements then 
            elements.Visible = bool
        end
    end 

    -- Set initial state
    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set

    -- Connections
    toggle.MouseButton1Click:Connect(function()
        cfg.set(not cfg.enabled)
    end)

    return setmetatable(cfg, library)
end 

function library:list(options)
    local cfg = {
        callback = options and options.callback or function() end, 
        name = options.name or nil, 

        scale = options.size or 90, 
        items = options.items or {"1", "2", "3"}, 
        visible = options.visible or true,

        option_instances = {}, 
        current_instance = nil, 
        flag = options.flag or "SET A FLAG", 
    }

    -- Elements
    local accent = library:create("Frame", {
        BorderColor3 = rgb(0, 0, 0);
        AnchorPoint = vec2(1, 0);
        Parent = self.elements;
        Position = dim2(1, 0, 0, 0);
        Size = dim2(1, 0, 0, cfg.scale);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(accent, "inline", "BackgroundColor3")
    
    local inline = library:create("Frame", {
        Parent = accent;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(35, 35, 35)
    }); library:apply_theme(inline, "inline", "BackgroundColor3")
    
    local scrollingframe = library:create("ScrollingFrame", {
        ScrollBarImageColor3 = rgb(0, 0, 0);
        Active = true;
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 0;
        Parent = inline;
        Size = dim2(1, 0, 1, 0);
        LayoutOrder = -1;
        BackgroundTransparency = 1;
        ScrollBarImageTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        BackgroundColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        CanvasSize = dim2(0, 0, 0, 0)
    });
    
    library:create("UIListLayout", {
        Parent = scrollingframe;
        Padding = dim(0, 6);
        SortOrder = Enum.SortOrder.LayoutOrder
    });
    
    library:create("UIPadding", {
        PaddingTop = dim(0, 2);
        PaddingBottom = dim(0, 4);
        Parent = scrollingframe;
        PaddingRight = dim(0, 5);
        PaddingLeft = dim(0, 5)
    });

    -- Functions
    function cfg.render_option(text) 
        local text = library:create("TextButton", {
            FontFace = fonts["ProggyClean"];
            TextColor3 = rgb(170, 170, 170);
            BorderColor3 = rgb(0, 0, 0);
            Text = text;
            AutoButtonColor = false;
            BackgroundTransparency = 1;
            Parent = scrollingframe;
            BorderSizePixel = 0;
            Size = dim2(1, 0, 0, 0);
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 12;
            TextXAlignment = Enum.TextXAlignment.Left;
            BackgroundColor3 = rgb(255, 255, 255)
        }); 
        
        return text 
    end 

    function cfg.refresh_options(options)
        for _, v in ipairs(cfg.option_instances) do 
            pcall(function() v:Destroy() end)
        end 

        cfg.option_instances = {}

        for _, option in next, options do 
            local button = cfg.render_option(option) 
            insert(cfg.option_instances, button)
            
            button.MouseButton1Click:Connect(function()
                if cfg.current_instance and cfg.current_instance ~= button then 
                    cfg.current_instance.TextColor3 = rgb(170, 170, 170)
                end 

                cfg.current_instance = button
                button.TextColor3 = rgb(255, 255, 255) 
                flags[cfg.flag] = button.Text
                cfg.callback(button.Text)
            end)
        end 
    end
    
    function cfg.filter_options(text)
        for _, v in next, cfg.option_instances do 
            if string.find(v.Text, text) then 
                v.Visible = true 
            else 
                v.Visible = false
            end
        end
    end

    function cfg.set(value)
        for _, buttons in next, cfg.option_instances do 
            if buttons.Text == value then 
                buttons.TextColor3 = rgb(255, 255, 255) 
            else 
                buttons.TextColor3 = rgb(170, 170, 170)
            end 
        end 

        flags[cfg.flag] = value
        cfg.callback(value)
    end 

    cfg.refresh_options(cfg.items) 

    return setmetatable(cfg, library)
end     

function library:slider(options) 
    local cfg = {
        name = options.name or nil,
        suffix = options.suffix or "",
        flag = options.flag or options.name or "Flag",
        callback = options.callback or function() end, 

        min = options.min or options.minimum or 0,
        max = options.max or options.maximum or 100,
        intervals = options.interval or options.decimal or 1,
        default = options.default or 10,
        value = options.default or 10, 
        display_text = options.display_text or options.name or "",

        ignore = options.ignore or false, 
        dragging = false,
    } 

    -- Instances
    local slider = library:create("Frame", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local outline = library:create("TextButton", {
        Parent = slider;
        Text = "";
        AutoButtonColor = false;
        Position = dim2(0, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        FontFace = fonts["ProggyClean"]
    }); library:apply_theme(outline, "inline", "BackgroundColor3")
    
    local inline = library:create("Frame", {
        Parent = outline;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(inline, "inline", "BackgroundColor3")
    
    local accent = library:create("Frame", {
        Parent = inline;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0.5, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.accent
    }); library:apply_theme(accent, "accent", "BackgroundColor3")
    
    local slider_text = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        RichText = true;
        BorderColor3 = rgb(0, 0, 0);
        Text = "";
        Parent = inline;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 0, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Center;
        BorderSizePixel = 0;
        TextSize = 10;
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 2
    });
    
    -- Functions 
    function cfg.set(value)
        local valuee = tonumber(value)

        if valuee == nil then 
            return 
        end 

        cfg.value = clamp(library:round(valuee, cfg.intervals), cfg.min, cfg.max)
        accent.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
        
        if cfg.display_text and cfg.display_text ~= "" then
            slider_text.Text = cfg.display_text .. ": " .. tostring(cfg.value) .. cfg.suffix
        else
            slider_text.Text = tostring(cfg.value) .. cfg.suffix
        end
        
        flags[cfg.flag] = cfg.value
        cfg.callback(flags[cfg.flag])
    end 

    cfg.set(cfg.default)

    -- Connections
    outline.MouseButton1Down:Connect(function()
        cfg.dragging = true 
    end)

    library:connection(uis.InputChanged, function(input)
        if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
            local size_x = (input.Position.X - inline.AbsolutePosition.X) / inline.AbsoluteSize.X
            local value = ((cfg.max - cfg.min) * size_x) + cfg.min
            cfg.set(value)
        end
    end)

    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            cfg.dragging = false 
        end 
    end)

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, library)
end 

function library:multi_slider(options)
    local cfg = {
        name = options.name or nil,
        
        -- Left slider options
        left_name = options.left_name or "Left",
        left_min = options.left_min or 0,
        left_max = options.left_max or 100,
        left_default = options.left_default or 50,
        left_suffix = options.left_suffix or "",
        left_flag = options.left_flag or (options.flag_prefix and options.flag_prefix .. "_left") or "multi_left",
        left_intervals = options.left_interval or 1,
        left_display_text = options.left_display_text or options.left_name or "",
        
        -- Right slider options
        right_name = options.right_name or "Right",
        right_min = options.right_min or 0,
        right_max = options.right_max or 100,
        right_default = options.right_default or 50,
        right_suffix = options.right_suffix or "",
        right_flag = options.right_flag or (options.flag_prefix and options.flag_prefix .. "_right") or "multi_right",
        right_intervals = options.right_interval or 1,
        right_display_text = options.right_display_text or options.right_name or "",
        
        callback = options.callback or function(left_val, right_val) end,
    }

    -- Main container
    local container = library:create("Frame", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    -- Create horizontal layout for two sliders
    local slider_row = library:create("Frame", {
        Parent = container;
        BackgroundTransparency = 1;
        Position = dim2(0, 0, 0, 0);
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    -- Left slider container (50% width)
    local left_container = library:create("Frame", {
        Parent = slider_row;
        BackgroundTransparency = 1;
        Position = dim2(0, 0, 0, 0);
        Size = dim2(0.5, -2, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    local left_outline = library:create("TextButton", {
        Parent = left_container;
        Text = "";
        AutoButtonColor = false;
        Position = dim2(0, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        FontFace = fonts["ProggyClean"]
    }); library:apply_theme(left_outline, "inline", "BackgroundColor3")

    local left_inline = library:create("Frame", {
        Parent = left_outline;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(left_inline, "inline", "BackgroundColor3")

    local left_accent = library:create("Frame", {
        Parent = left_inline;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0.5, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.accent
    }); library:apply_theme(left_accent, "accent", "BackgroundColor3")
    
    local left_text = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        RichText = true;
        BorderColor3 = rgb(0, 0, 0);
        Text = "";
        Parent = left_inline;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 0, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Center;
        BorderSizePixel = 0;
        TextSize = 10;
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 2
    });

    -- Right slider container (50% width)
    local right_container = library:create("Frame", {
        Parent = slider_row;
        BackgroundTransparency = 1;
        Position = dim2(0.5, 2, 0, 0);
        Size = dim2(0.5, -2, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    local right_outline = library:create("TextButton", {
        Parent = right_container;
        Text = "";
        AutoButtonColor = false;
        Position = dim2(0, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        FontFace = fonts["ProggyClean"]
    }); library:apply_theme(right_outline, "inline", "BackgroundColor3")

    local right_inline = library:create("Frame", {
        Parent = right_outline;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(right_inline, "inline", "BackgroundColor3")

    local right_accent = library:create("Frame", {
        Parent = right_inline;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0.5, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.accent
    }); library:apply_theme(right_accent, "accent", "BackgroundColor3")
    
    local right_text = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        RichText = true;
        BorderColor3 = rgb(0, 0, 0);
        Text = "";
        Parent = right_inline;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 0, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Center;
        BorderSizePixel = 0;
        TextSize = 10;
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 2
    });

    -- Slider state
    cfg.left_value = cfg.left_default
    cfg.right_value = cfg.right_default
    cfg.left_dragging = false
    cfg.right_dragging = false

    -- Left slider functions
    function cfg.set_left(value)
        local valuee = tonumber(value)
        if valuee == nil then return end

        cfg.left_value = clamp(library:round(valuee, cfg.left_intervals), cfg.left_min, cfg.left_max)
        left_accent.Size = dim2((cfg.left_value - cfg.left_min) / (cfg.left_max - cfg.left_min), 0, 1, 0)
        
        if cfg.left_display_text and cfg.left_display_text ~= "" then
            left_text.Text = cfg.left_display_text .. ": " .. tostring(cfg.left_value) .. cfg.left_suffix
        else
            left_text.Text = tostring(cfg.left_value) .. cfg.left_suffix
        end
        
        flags[cfg.left_flag] = cfg.left_value
        cfg.callback(cfg.left_value, cfg.right_value)
    end

    -- Right slider functions
    function cfg.set_right(value)
        local valuee = tonumber(value)
        if valuee == nil then return end

        cfg.right_value = clamp(library:round(valuee, cfg.right_intervals), cfg.right_min, cfg.right_max)
        right_accent.Size = dim2((cfg.right_value - cfg.right_min) / (cfg.right_max - cfg.right_min), 0, 1, 0)
        
        if cfg.right_display_text and cfg.right_display_text ~= "" then
            right_text.Text = cfg.right_display_text .. ": " .. tostring(cfg.right_value) .. cfg.right_suffix
        else
            right_text.Text = tostring(cfg.right_value) .. cfg.right_suffix
        end
        
        flags[cfg.right_flag] = cfg.right_value
        cfg.callback(cfg.left_value, cfg.right_value)
    end

    -- Set default values
    cfg.set_left(cfg.left_default)
    cfg.set_right(cfg.right_default)

    -- Config flags
    config_flags[cfg.left_flag] = cfg.set_left
    config_flags[cfg.right_flag] = cfg.set_right

    -- Connections for left slider
    left_outline.MouseButton1Down:Connect(function()
        cfg.left_dragging = true
    end)

    -- Connections for right slider
    right_outline.MouseButton1Down:Connect(function()
        cfg.right_dragging = true
    end)

    -- Mouse movement for both sliders
    library:connection(uis.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if cfg.left_dragging then
                local size_x = (input.Position.X - left_inline.AbsolutePosition.X) / left_inline.AbsoluteSize.X
                local value = ((cfg.left_max - cfg.left_min) * size_x) + cfg.left_min
                cfg.set_left(value)
            end
            if cfg.right_dragging then
                local size_x = (input.Position.X - right_inline.AbsolutePosition.X) / right_inline.AbsoluteSize.X
                local value = ((cfg.right_max - cfg.right_min) * size_x) + cfg.right_min
                cfg.set_right(value)
            end
        end
    end)

    -- Mouse release for both sliders
    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            cfg.left_dragging = false
            cfg.right_dragging = false
        end
    end)

    return setmetatable(cfg, library)
end

function library:dropdown(options) 
    local cfg = {
        name = options.name or nil,
        flag = options.flag or options.name or "Flag",
        items = options.items or {""},
        callback = options.callback or function() end,
        multi = options.multi or false, 
        scrolling = options.scrolling or false, 

        open = false, 
        option_instances = {}, 
        multi_items = {}, 
        ignore = options.ignore or false, 
    }   

    cfg.default = options.default or (cfg.multi and {cfg.items[1]}) or cfg.items[1] or "None"

    flags[cfg.flag] = {} 

    -- Instances
    -- Element 
    local dropdown = library:create("Frame", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local dropdown_holder = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        AutoButtonColor = false; 
        Text = "";
        Parent = dropdown;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0.5, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        FontFace = fonts["ProggyClean"]
    }); library:apply_theme(dropdown_holder, "inline", "BackgroundColor3")
    
    local inline = library:create("Frame", {
        Parent = dropdown_holder;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(35, 35, 35)
    });
    
    local text = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = inline;
        Size = dim2(1, 0, 1, 0);
        BackgroundTransparency = 1;
        Position = dim2(0, 0, 0, 1);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local title = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = dropdown;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 1, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    -- Holder
    local accent = library:create("Frame", {
        Parent = library.gui;
        Size = dim2(0, 100, 0, 20);
        Position = dim2(0, 500, 0, 100);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        Visible = false;
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 100
    }); library:apply_theme(accent, "inline", "BackgroundColor3")

    local inline_holder = library:create("Frame", {
        Parent = accent;
        Size = dim2(1, -2, 1, -2);
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 101
    }); library:apply_theme(inline_holder, "inline", "BackgroundColor3")

    library:create("UIListLayout", {
        Parent = inline_holder;
        Padding = dim(0, 6);
        SortOrder = Enum.SortOrder.LayoutOrder
    });

    library:create("UIPadding", {
        PaddingTop = dim(0, 5);
        PaddingBottom = dim(0, 2);
        Parent = inline_holder;
        PaddingRight = dim(0, 6);
        PaddingLeft = dim(0, 6)
    });

    -- Functions
    function cfg.render_option(text) 
        local title = library:create("TextButton", {
            FontFace = fonts["ProggyClean"];
            AutoButtonColor = false;
            TextColor3 = rgb(170, 170, 170);
            BorderColor3 = rgb(0, 0, 0);
            Text = text;
            Parent = inline_holder;
            Size = dim2(1, 0, 0, 0);
            Position = dim2(0, 0, 0, 1);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            TextSize = 12;
            BackgroundColor3 = rgb(255, 255, 255),
            ZIndex = 102
        });

        return title
    end 
    
    function cfg.set_visible(bool) 
        accent.Visible = bool
        if bool then
            accent.Position = dim2(0, dropdown_holder.AbsolutePosition.X, 0, dropdown_holder.AbsolutePosition.Y + 20)
            accent.ZIndex = 1000
            library.current_open_element = cfg
        else
            if library.current_open_element == cfg then
                library.current_open_element = nil
            end
        end
    end
    
    function cfg:toggle_open(bool)
        cfg.open = bool
    end
    
    function cfg.set(value)
        local selected = {}
        local isTable = type(value) == "table"

        if value == nil then 
            return 
        end

        for _, option in next, cfg.option_instances do 
            if option.Text == value or (isTable and find(value, option.Text)) then 
                insert(selected, option.Text)
                cfg.multi_items = selected
                option.TextColor3 = rgb(255, 255, 255)
            else
                option.TextColor3 = rgb(170, 170, 170)
            end
        end

        text.Text = isTable and concat(selected, ", ") or selected[1] or "None"
        flags[cfg.flag] = isTable and selected or selected[1]
        cfg.callback(flags[cfg.flag]) 
    end
    
    function cfg.refresh_options(list) 
        for _, option in next, cfg.option_instances do 
            pcall(function() option:Destroy() end)
        end
        
        cfg.option_instances = {} 

        for _, option in next, list do 
            local button = cfg.render_option(option)
            insert(cfg.option_instances, button)
            
            button.MouseButton1Down:Connect(function()
                if cfg.multi then 
                    local selected_index = find(cfg.multi_items, button.Text)

                    if selected_index then 
                        remove(cfg.multi_items, selected_index)
                    else
                        insert(cfg.multi_items, button.Text)
                    end
                    
                    cfg.set(cfg.multi_items) 				
                else 
                    cfg.set_visible(false)
                    cfg.open = false 
                    cfg.set(button.Text)
                end
            end)
        end
    end

    cfg.refresh_options(cfg.items)
    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set

    -- Connections 
    dropdown_holder.MouseButton1Click:Connect(function()
        library:close_current_element()
        cfg.open = not cfg.open 
        cfg.set_visible(cfg.open)
    end)

    return setmetatable(cfg, library)
end 

-- FIXED: Colorpicker with proper vertical hue bar
function library:colorpicker(options) 
    local cfg = {
        name = options.name or "Color", 
        flag = options.flag or options.name or "Flag",

        color = options.color or color(1, 1, 1),
        alpha = options.alpha and 1 - options.alpha or 0,
        
        open = false, 
        callback = options.callback or function() end,
    }

    -- Instances
    -- Element 
    local colorpicker_element = library:create("TextButton", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        Text = "";
        AutoButtonColor = false;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255),
        FontFace = fonts["ProggyClean"]
    });
    
    local accent = library:create("Frame", {
        AnchorPoint = vec2(1, 0);
        Parent = colorpicker_element;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 30, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(accent, "inline", "BackgroundColor3")
    
    local colorpicker_element_color = library:create("Frame", {
        Parent = accent;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = colorpicker_element;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 1, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    -- Elements
    local colorpicker = library:create("Frame", {
        Parent = library.gui;
        Position = dim2(0.6888179183006287, 0, 0.24751244485378265, 0);
        BorderColor3 = rgb(0, 0, 0);
        Visible = false;
        Size = dim2(0, 150, 0, 150);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 1000
    }); library:apply_theme(colorpicker, "inline", "BackgroundColor3")

    local a = library:create("Frame", {
        Parent = colorpicker;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 1001
    }); library:apply_theme(a, "inline", "BackgroundColor3")
    
    local e = library:create("Frame", {
        Parent = a;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0);
        BackgroundTransparency = 0.6;
        ZIndex = 1002
    }); 

    local _ = library:create("UIPadding", {
        PaddingTop = dim(0, 7);
        PaddingBottom = dim(0, -13);
        Parent = e;
        PaddingRight = dim(0, 6);
        PaddingLeft = dim(0, 7)
    });
    
    local textbox_holder = library:create("Frame", {
        Parent = e;
        Position = dim2(0, 0, 1, -36);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -1, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 1003
    }); library:apply_theme(textbox_holder, "inline", "BackgroundColor3")
    
    local textbox = library:create("TextBox", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = "";
        Parent = textbox_holder;
        BackgroundTransparency = 0;
        ClearTextOnFocus = false;
        PlaceholderColor3 = rgb(255, 255, 255);
        Size = dim2(1, -2, 1, -2);
        Position = dim2(0, 1, 0, 1);
        BorderSizePixel = 0;
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Center;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 1004
    }); library:apply_theme(textbox, "inline", "BackgroundColor3")
    
    local hue_button = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        Text = "";
        AutoButtonColor = false;
        Parent = e;
        Position = dim2(1, -1, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 14, 1, -60);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 1003,
        FontFace = fonts["ProggyClean"]
    }); library:apply_theme(hue_button, "inline", "BackgroundColor3")
    
    local hue_drag = library:create("Frame", {
        Parent = hue_button;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 1004
    });
    
    library:create("UIGradient", {
        Rotation = 90;
        Parent = hue_drag;
        Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))}
    });
    
    local hue_picker = library:create("Frame", {
        Parent = hue_drag;
        BorderMode = Enum.BorderMode.Inset;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 2, 0, 3);
        Position = dim2(0, -1, 0, 0);
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 1005
    });
    
    local alpha_button = library:create("TextButton", {
        AnchorPoint = vec2(0, 0.5);
        Text = "";
        AutoButtonColor = false;
        Parent = e;
        Position = dim2(0, 0, 1, -48);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -1, 0, 14);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 1003,
        FontFace = fonts["ProggyClean"]
    }); library:apply_theme(alpha_button, "inline", "BackgroundColor3")
    
    local alpha_color = library:create("Frame", {
        Parent = alpha_button;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 221, 255),
        ZIndex = 1004
    });
    
    local alphaind = library:create("ImageLabel", {
        ScaleType = Enum.ScaleType.Tile;
        BorderColor3 = rgb(0, 0, 0);
        Parent = alpha_color;
        Image = "rbxassetid://18274452449";
        BackgroundTransparency = 1;
        Size = dim2(1, 0, 1, 0);
        TileSize = dim2(0, 4, 0, 4);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 1005
    });
    
    library:create("UIGradient", {
        Parent = alphaind;
        Transparency = numseq{numkey(0, 0), numkey(1, 1)}
    });
    
    local alpha_picker = library:create("Frame", {
        Parent = alpha_color;
        BorderMode = Enum.BorderMode.Inset;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 3, 1, 2);
        Position = dim2(0, -1, 0, -1);
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 1006
    });
    
    local saturation_value_button = library:create("TextButton", {
        Parent = e;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -20, 1, -60);
        Text = "";
        AutoButtonColor = false;
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 1003,
        FontFace = fonts["ProggyClean"]
    }); library:apply_theme(saturation_value_button, "inline", "BackgroundColor3")
    
    local colorpicker_color = library:create("Frame", {
        Parent = saturation_value_button;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 221, 255),
        ZIndex = 1004
    });
    
    local val = library:create("TextButton", {
        Parent = colorpicker_color;
        Text = "";
        AutoButtonColor = false;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 1005,
        FontFace = fonts["ProggyClean"]
    });
    
    library:create("UIGradient", {
        Parent = val;
        Transparency = numseq{numkey(0, 0), numkey(1, 1)}
    });
    
    local saturation_value_picker = library:create("Frame", {
        Parent = colorpicker_color;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 3, 0, 3);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0),
        ZIndex = 1006
    });
    
    local inline = library:create("Frame", {
        Parent = saturation_value_picker;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255),
        ZIndex = 1007
    });
    
    local saturation_button = library:create("TextButton", {
        Parent = colorpicker_color;
        Text = "";
        AutoButtonColor = false;
        Size = dim2(1, 0, 1, 0);
        BorderColor3 = rgb(0, 0, 0);
        ZIndex = 1005;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255),
        FontFace = fonts["ProggyClean"]
    });
    
    library:create("UIGradient", {
        Rotation = 270;
        Transparency = numseq{numkey(0, 0), numkey(1, 1)};
        Parent = saturation_button;
        Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
    });
    
    -- Functions 
    local dragging_sat = false 
    local dragging_hue = false 
    local dragging_alpha = false 

    local h, s, v = cfg.color:ToHSV() 
    local a = cfg.alpha 

    flags[cfg.flag] = {} 

    function cfg.set_visible(bool) 
        colorpicker.Visible = bool
        colorpicker.Position = dim_offset(colorpicker_element_color.AbsolutePosition.X - 1, colorpicker_element_color.AbsolutePosition.Y + colorpicker_element_color.AbsoluteSize.Y + 65)
        colorpicker.ZIndex = 1000
        
        if bool then
            library.current_open_element = cfg
        else
            if library.current_open_element == cfg then
                library.current_open_element = nil
            end
        end
    end
    
    function cfg:toggle_open(bool)
        cfg.open = bool
    end

    function cfg.set(color, alpha)
        if color then
            h, s, v = color:ToHSV()
        end
        
        if alpha then 
            a = alpha 
        end 
        
        local Color = Color3.fromHSV(h, s, v)
        
        hue_picker.Position = dim2(0, -1, h, -1)
        alpha_picker.Position = dim2(1 - a, -1, 0, -1)
        saturation_value_picker.Position = dim2(s, -1, 1 - v, -1)

        alpha_color.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        colorpicker_element_color.BackgroundColor3 = Color
        colorpicker_color.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        
        flags[cfg.flag] = {
            Color = Color;
            Transparency = a 
        }
        
        local color = colorpicker_element_color.BackgroundColor3
        textbox.Text = string.format("%s, %s, %s, ", library:round(color.R * 255), library:round(color.G * 255), library:round(color.B * 255))
        textbox.Text = textbox.Text .. library:round(1 - a, 0.01)
        
        cfg.callback(Color, a)
    end

    function cfg.update_color() 
        local mouse = uis:GetMouseLocation() 
        local offset = vec2(mouse.X, mouse.Y - gui_offset) 

        if dragging_sat then	
            s = math.clamp((offset - saturation_value_button.AbsolutePosition).X / saturation_value_button.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((offset - saturation_value_button.AbsolutePosition).Y / saturation_value_button.AbsoluteSize.Y, 0, 1)
        elseif dragging_hue then
            h = math.clamp((offset - hue_button.AbsolutePosition).Y / hue_button.AbsoluteSize.Y, 0, 1)
        elseif dragging_alpha then
            a = 1 - math.clamp((offset - alpha_button.AbsolutePosition).X / alpha_button.AbsoluteSize.X, 0, 1)
        end

        cfg.set(nil, nil)
    end

    cfg.set(cfg.color, cfg.alpha)
    config_flags[cfg.flag] = cfg.set

    -- Connections 
    colorpicker_element.MouseButton1Click:Connect(function()
        library:close_current_element()
        cfg.open = not cfg.open 
        cfg.set_visible(cfg.open)            
    end)

    uis.InputChanged:Connect(function(input)
        if (dragging_sat or dragging_hue or dragging_alpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
            cfg.update_color() 
        end
    end)

    library:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging_sat = false
            dragging_hue = false
            dragging_alpha = false  

            if not (library:mouse_in_frame(colorpicker_element) or library:mouse_in_frame(colorpicker)) then 
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)

    alpha_button.MouseButton1Down:Connect(function()
        dragging_alpha = true 
    end)
    
    hue_button.MouseButton1Down:Connect(function()
        dragging_hue = true 
    end)
    
    saturation_button.MouseButton1Down:Connect(function()
        dragging_sat = true  
    end)
    
    textbox.FocusLost:Connect(function()
        local r, g, b, a = library:convert(textbox.Text)
        
        if r and g and b and a then 
            cfg.set(rgb(r, g, b), 1 - a)
        end 
    end)

    return setmetatable(cfg, library)
end

function library:textbox(options) 
    local cfg = {
        name = options.name or "...",
        placeholder = options.placeholder or options.placeholdertext or options.holder or options.holdertext or "type here...",
        default = options.default,
        flag = options.flag or options.name or "Flag",
        callback = options.callback or function() end,
        visible = options.visible or true,
    }
    
    -- Instances 
    local frame = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        Text = "";
        AutoButtonColor = false;
        Parent = self.elements;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        FontFace = fonts["ProggyClean"]
    }); library:apply_theme(frame, "inline", "BackgroundColor3")
    
    local frame_inline = library:create("Frame", {
        Parent = frame;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(frame_inline, "inline", "BackgroundColor3")
    
    local input = library:create("TextBox", {
        Parent = frame,
        Name = "",
        FontFace = fonts["ProggyClean"],
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextSize = 12,
        Text = "",
        Size = dim2(1, -6, 1, 0),
        RichText = true,
        TextColor3 = rgb(255, 255, 255),
        BorderColor3 = rgb(0, 0, 0),
        CursorPosition = -1,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = dim2(0, 6, 0, 0),
        BorderSizePixel = 0,
        PlaceholderColor3 = rgb(170, 170, 170),
        PlaceholderText = cfg.placeholder
    })
    
    -- Functions
    function cfg.set(text) 
        flags[cfg.flag] = text
        input.Text = text
        cfg.callback(text)
    end 
    
    config_flags[cfg.flag] = cfg.set

    if cfg.default then 
        cfg.set(cfg.default) 
    end

    -- Connections 
    input:GetPropertyChangedSignal("Text"):Connect(function()
        cfg.set(input.Text) 
    end)
    
    return setmetatable(cfg, library)
end 

function library:keybind(options) 
    local cfg = {
        flag = options.flag or options.name or "Flag",
        callback = options.callback or function() end,
        open = false,
        binding = nil, 
        name = options.name or nil, 
        ignore_key = options.ignore or false, 

        key = options.key or nil, 
        mode = options.mode or "toggle",
        active = options.default or false, 

        hold_instances = {},
    }

    flags[cfg.flag] = {} 

    -- Instances
    -- Element 
    local keybind = library:create("Frame", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local keybind_holder = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        AutoButtonColor = false; 
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(170, 170, 170);
        Text = "[...]";
        Parent = keybind;
        Position = dim2(1, 0, 0, 0);
        BorderSizePixel = 0;
        Size = dim2(0, 0, 1, 0);
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundTransparency = 1;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local text = keybind_holder;
    
    local title = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = keybind;
        Size = dim2(1, 0, 1, 0);
        Position = dim2(0, 1, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    -- Holder - Fixed sizing
    local accent = library:create("Frame", {
        Parent = library.gui;
        Visible = false;
        Size = dim2(0, 0, 0, 0);
        Position = dim2(0, 500, 0, 100);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 1000
    }); library:apply_theme(accent, "inline", "BackgroundColor3")

    local inline = library:create("Frame", {
        Parent = accent;
        Size = dim2(1, -2, 1, -2);
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = themes.preset.inline,
        ZIndex = 1001
    }); library:apply_theme(inline, "inline", "BackgroundColor3")

    local list_layout = library:create("UIListLayout", {
        Parent = inline;
        Padding = dim(0, 4);
        SortOrder = Enum.SortOrder.LayoutOrder;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
    });

    library:create("UIPadding", {
        PaddingTop = dim(0, 4);
        PaddingBottom = dim(0, 4);
        Parent = inline;
        PaddingRight = dim(0, 8);
        PaddingLeft = dim(0, 8)
    });

    local options = {"Hold", "Toggle", "Always"}
    
    for _, v in options do
        local option = library:create("TextButton", {
            FontFace = fonts["ProggyClean"];
            TextColor3 = rgb(170, 170, 170);
            BorderColor3 = rgb(0, 0, 0);
            Text = v;
            Parent = inline;
            Position = dim2(0, 0, 0, 0);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Center;
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.XY;
            TextSize = 12;
            BackgroundColor3 = rgb(255, 255, 255),
            ZIndex = 1002,
            Size = dim2(0, 0, 0, 0)
        }); cfg.hold_instances[v] = option

        option.MouseButton1Click:Connect(function()
            cfg.set(v)
            cfg.set_visible(false)
            cfg.open = false
        end)
    end

    -- Functions 
    function cfg.modify_mode_color(path)
        for _, v in pairs(cfg.hold_instances) do 
            v.TextColor3 = rgb(170, 170, 170)
        end

        if cfg.hold_instances[path] then 
            cfg.hold_instances[path].TextColor3 = rgb(255, 255, 255)
        end
    end 

    function cfg.set_mode(mode) 
        cfg.mode = mode 

        if mode == "Always" then
            cfg.set(true)
        elseif mode == "Hold" then
            cfg.set(false)
        end

        flags[cfg.flag]["mode"] = mode
        cfg.modify_mode_color(mode)
    end 

    function cfg.set(input)
        if type(input) == "boolean" then 
            local __cached = input 

            if cfg.mode == "Always" then 
                __cached = true 
            end 

            cfg.active = __cached 
            cfg.callback(__cached)
        elseif tostring(input):find("Enum") then 
            input = input.Name == "Escape" and "..." or input
            cfg.key = input or "..."	
            cfg.callback(cfg.active or false)
        elseif find({"Toggle", "Hold", "Always"}, input) then 
            cfg.set_mode(input)

            if input == "Always" then 
                cfg.active = true 
            end 

            cfg.callback(cfg.active or false)
        elseif type(input) == "table" then 
            input.key = type(input.key) == "string" and input.key ~= "..." and library:convert_enum(input.key) or input.key
            input.key = input.key == Enum.KeyCode.Escape and "..." or input.key
            cfg.key = input.key or "..."
            
            cfg.mode = input.mode or "Toggle"
            cfg.set_mode(cfg.mode)

            if input.active ~= nil then
                cfg.active = input.active
            end
        end 

        flags[cfg.flag] = {
            mode = cfg.mode,
            key = cfg.key, 
            active = cfg.active
        }

        local _text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
        local __text = _text and (tostring(_text):gsub("KeyCode.", ""):gsub("UserInputType.", "")) or "..."
        
        text.Text = "[" .. __text .. "]"
    end

    function cfg.set_visible(bool)
        accent.Visible = bool
        
        if bool then
            accent.Position = dim2(0, keybind_holder.AbsolutePosition.X, 0, keybind_holder.AbsolutePosition.Y + 20)
            accent.ZIndex = 1000
            library.current_open_element = cfg
        else
            if library.current_open_element == cfg then
                library.current_open_element = nil
            end
        end
    end
    
    function cfg:toggle_open(bool)
        cfg.open = bool
    end

    -- Connections
    keybind_holder.MouseButton1Down:Connect(function()
        library:close_current_element()
        task.wait()
        text.Text = "[...]"	

        cfg.binding = library:connection(uis.InputBegan, function(keycode, game_event)  
            if not game_event and keycode.KeyCode ~= Enum.KeyCode.Unknown then
                cfg.set(keycode.KeyCode)
                cfg.binding:Disconnect() 
                cfg.binding = nil
            end
        end)
    end)

    keybind_holder.MouseButton2Down:Connect(function()
        library:close_current_element()
        cfg.open = not cfg.open 
        cfg.set_visible(cfg.open) 
    end)

    library:connection(uis.InputBegan, function(input, game_event) 
        if not game_event then 
            if input.KeyCode == cfg.key then 
                if cfg.mode == "Toggle" then 
                    cfg.active = not cfg.active
                    cfg.set(cfg.active)
                elseif cfg.mode == "Hold" then 
                    cfg.set(true)
                end
            end
        end
    end)

    library:connection(uis.InputEnded, function(input, game_event) 
        if game_event then 
            return 
        end 

        local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType

        if selected_key == cfg.key then
            if cfg.mode == "Hold" then 
                cfg.set(false)
            end
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.wait()
            if not (library:mouse_in_frame(keybind_holder) or library:mouse_in_frame(accent)) then 
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)
    
    library:connection(run.RenderStepped, function()
        if cfg.open and accent.Visible then
            if not (library:mouse_in_frame(keybind_holder) or library:mouse_in_frame(accent)) then
                cfg.open = false
                cfg.set_visible(false)
            end
        end
    end)

    config_flags[cfg.flag] = cfg.set
    cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})

    return setmetatable(cfg, library)
end

function library:button(options) 
    local cfg = {
        name = options.name or "button",
        callback = options.callback or function() end,
    }
    
    -- Instances 
    local frame = library:create("TextButton", {
        AnchorPoint = vec2(1, 0);
        Text = "";
        AutoButtonColor = false;
        Parent = self.elements;
        Position = dim2(1, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 16);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline,
        FontFace = fonts["ProggyClean"]
    }); library:apply_theme(frame, "inline", "BackgroundColor3")
    
    local frame_inline = library:create("Frame", {
        Parent = frame;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); library:apply_theme(frame_inline, "inline", "BackgroundColor3")
    
    local text = library:create("TextLabel", {
        FontFace = fonts["ProggyClean"];
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = frame;
        Size = dim2(1, 0, 1, 0);
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    -- Connections 
    frame.MouseButton1Click:Connect(function()
        cfg.callback()
    end)
    
    return setmetatable(cfg, library)
end 

-- Global click handler to close open elements
library:connection(uis.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        task.wait()
        if library.current_open_element and not (
            library:mouse_in_frame(library.current_open_element.keybind_holder) or 
            library:mouse_in_frame(library.current_open_element.accent) or
            library:mouse_in_frame(library.current_open_element.colorpicker_element) or
            library:mouse_in_frame(library.current_open_element.colorpicker)
        ) then
            library:close_current_element()
        end
    end
end)

return library, notifications
