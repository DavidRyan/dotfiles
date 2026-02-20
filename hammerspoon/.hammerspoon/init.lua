-- Hammerspoon config
-- SketchyBar calls: hs -c 'toggleMediaPopup()'

require("hs.ipc")

--------------------------------------------------------------------------------
-- Catppuccin Mocha Colors with Red Outline
--------------------------------------------------------------------------------
local colors = {
    background = { red = 0x1e/255, green = 0x1e/255, blue = 0x2e/255, alpha = 1 },
    foreground = { red = 0xcd/255, green = 0xd6/255, blue = 0xf4/255, alpha = 1 },
    red = { red = 0xf3/255, green = 0x8b/255, blue = 0xa8/255, alpha = 1 },
    green = { red = 0xa6/255, green = 0xe3/255, blue = 0xa1/255, alpha = 1 },
    surface0 = { red = 0x31/255, green = 0x32/255, blue = 0x44/255, alpha = 1 },
    surface1 = { red = 0x45/255, green = 0x47/255, blue = 0x5a/255, alpha = 1 },
    subtext = { red = 0xa6/255, green = 0xad/255, blue = 0xc8/255, alpha = 1 },
}

--------------------------------------------------------------------------------
-- Media Popup State
--------------------------------------------------------------------------------
local mediaPopup = {
    canvas = nil,
    visible = false,
    updateTimer = nil,
}

local POPUP_WIDTH = 320
local POPUP_HEIGHT = 140
local ARTWORK_SIZE = 110
local BORDER_WIDTH = 3
local CORNER_RADIUS = 12

--------------------------------------------------------------------------------
-- Helper: Run nowplaying-cli command
--------------------------------------------------------------------------------
local function nowplaying(cmd)
    local output, status = hs.execute("/opt/homebrew/bin/nowplaying-cli " .. cmd)
    if status and output then
        output = output:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
        if output == "null" or output == "" then
            return nil
        end
        return output
    end
    return nil
end

--------------------------------------------------------------------------------
-- Helper: Control media playback
--------------------------------------------------------------------------------
local function mediaControl(action)
    hs.execute("/opt/homebrew/bin/nowplaying-cli " .. action)
    -- Small delay then refresh display
    hs.timer.doAfter(0.2, function()
        if mediaPopup.visible then
            updateMediaPopup()
        end
    end)
end

--------------------------------------------------------------------------------
-- Get current media info
--------------------------------------------------------------------------------
local function getMediaInfo()
    return {
        title = nowplaying("get title") or "No Media Playing",
        artist = nowplaying("get artist") or "",
        album = nowplaying("get album") or "",
        state = nowplaying("get playbackRate"),
    }
end

--------------------------------------------------------------------------------
-- Update the popup content
--------------------------------------------------------------------------------
function updateMediaPopup()
    if not mediaPopup.canvas then return end

    local info = getMediaInfo()

    -- Update text elements
    -- Title is element 5, Artist is element 6
    mediaPopup.canvas[5].text = info.title
    mediaPopup.canvas[6].text = info.artist

    -- Update play/pause button (element 9)
    local isPlaying = info.state and tonumber(info.state) == 1
    mediaPopup.canvas[9].text = isPlaying and "⏸" or "▶"

    -- Update artwork (element 4)
    local artworkPath = "/tmp/sketchybar_media_artwork.jpg"
    if hs.fs.attributes(artworkPath) then
        mediaPopup.canvas[4].type = "image"
        mediaPopup.canvas[4].image = hs.image.imageFromPath(artworkPath)
        mediaPopup.canvas[4].imageScaling = "scaleToFit"
    end
end

--------------------------------------------------------------------------------
-- Create the popup canvas
--------------------------------------------------------------------------------
local function createMediaPopup()
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()

    -- Get media widget position from SketchyBar
    local output = hs.execute("/opt/homebrew/bin/sketchybar --query media")
    local mediaX = screenFrame.x + screenFrame.w - POPUP_WIDTH - 10 -- default fallback
    
    if output then
        -- Parse the bounding_rects origin x value from sketchybar output
        local originX = output:match('"origin":%s*%[%s*([%d%.]+)')
        if originX then
            mediaX = tonumber(originX)
        end
    end
    
    local x = mediaX
    local y = screenFrame.y + 5

    local canvas = hs.canvas.new({ x = x, y = y, w = POPUP_WIDTH, h = POPUP_HEIGHT })

    -- Element 1: Background with red border
    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = colors.background,
        roundedRectRadii = { xRadius = CORNER_RADIUS, yRadius = CORNER_RADIUS },
        frame = { x = 0, y = 0, w = POPUP_WIDTH, h = POPUP_HEIGHT },
    })

    -- Element 2: Red border outline
    canvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = colors.red,
        strokeWidth = BORDER_WIDTH,
        roundedRectRadii = { xRadius = CORNER_RADIUS, yRadius = CORNER_RADIUS },
        frame = { x = BORDER_WIDTH/2, y = BORDER_WIDTH/2, w = POPUP_WIDTH - BORDER_WIDTH, h = POPUP_HEIGHT - BORDER_WIDTH },
    })

    -- Element 3: Artwork background (placeholder)
    local artX = 15
    local artY = 15
    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = colors.surface0,
        roundedRectRadii = { xRadius = 8, yRadius = 8 },
        frame = { x = artX, y = artY, w = ARTWORK_SIZE, h = ARTWORK_SIZE },
    })

    -- Element 4: Album artwork image
    canvas:appendElements({
        type = "image",
        frame = { x = artX, y = artY, w = ARTWORK_SIZE, h = ARTWORK_SIZE },
        imageScaling = "scaleToFit",
        roundedRectRadii = { xRadius = 8, yRadius = 8 },
    })

    -- Element 5: Song title
    local textX = artX + ARTWORK_SIZE + 15
    local textWidth = POPUP_WIDTH - textX - 35
    canvas:appendElements({
        type = "text",
        text = "No Media Playing",
        textColor = colors.foreground,
        textSize = 14,
        textFont = "SF Pro Display Bold",
        frame = { x = textX, y = 20, w = textWidth, h = 22 },
    })

    -- Element 6: Artist name
    canvas:appendElements({
        type = "text",
        text = "",
        textColor = colors.subtext,
        textSize = 12,
        textFont = "SF Pro Display",
        frame = { x = textX, y = 44, w = textWidth, h = 20 },
    })

    -- Element 7: Controls background (positioned below artist)
    local controlsY = 72
    local controlsWidth = 160
    local controlsX = textX
    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = colors.surface0,
        roundedRectRadii = { xRadius = 20, yRadius = 20 },
        frame = { x = controlsX, y = controlsY, w = controlsWidth, h = 36 },
    })

    -- Control button positions
    local btnWidth = 40
    local btnY = controlsY
    local btnHeight = 36

    -- Element 8: Previous button
    canvas:appendElements({
        type = "text",
        text = "⏮",
        textColor = colors.foreground,
        textSize = 18,
        textAlignment = "center",
        frame = { x = controlsX, y = btnY + 6, w = btnWidth, h = btnHeight - 6 },
        trackMouseDown = true,
        id = "prev",
    })

    -- Element 9: Play/Pause button
    canvas:appendElements({
        type = "text",
        text = "▶",
        textColor = colors.green,
        textSize = 20,
        textAlignment = "center",
        frame = { x = controlsX + btnWidth, y = btnY + 5, w = btnWidth * 2, h = btnHeight - 5 },
        trackMouseDown = true,
        id = "playpause",
    })

    -- Element 10: Next button
    canvas:appendElements({
        type = "text",
        text = "⏭",
        textColor = colors.foreground,
        textSize = 18,
        textAlignment = "center",
        frame = { x = controlsX + btnWidth * 3, y = btnY + 6, w = btnWidth, h = btnHeight - 6 },
        trackMouseDown = true,
        id = "next",
    })

    -- Mouse click handler
    canvas:mouseCallback(function(_, _, id, x, y)
        if id == "prev" then
            mediaControl("previous")
        elseif id == "playpause" then
            mediaControl("togglePlayPause")
        elseif id == "next" then
            mediaControl("next")
        end
    end)

    canvas:level(hs.canvas.windowLevels.floating)
    canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)

    return canvas
end

--------------------------------------------------------------------------------
-- Toggle Media Popup (called from SketchyBar)
--------------------------------------------------------------------------------
function toggleMediaPopup()
    if mediaPopup.visible then
        -- Hide popup
        if mediaPopup.canvas then
            mediaPopup.canvas:hide()
        end
        if mediaPopup.updateTimer then
            mediaPopup.updateTimer:stop()
            mediaPopup.updateTimer = nil
        end
        mediaPopup.visible = false
    else
        -- Show popup
        if not mediaPopup.canvas then
            mediaPopup.canvas = createMediaPopup()
        end

        -- Reposition in case screen changed
        local screen = hs.screen.mainScreen()
        local screenFrame = screen:frame()
        
        -- Get media widget position from SketchyBar
        local output = hs.execute("/opt/homebrew/bin/sketchybar --query media")
        local mediaX = screenFrame.x + screenFrame.w - POPUP_WIDTH - 10 -- default fallback
        
        if output then
            -- Parse the bounding_rects origin x value from sketchybar output
            local originX = output:match('"origin":%s*%[%s*([%d%.]+)')
            if originX then
                mediaX = tonumber(originX)
            end
        end
        
        local x = mediaX
        local y = screenFrame.y + 5
        mediaPopup.canvas:topLeft({ x = x, y = y })

        updateMediaPopup()
        mediaPopup.canvas:show()
        mediaPopup.visible = true

        -- Start update timer (every 2 seconds)
        mediaPopup.updateTimer = hs.timer.doEvery(2, updateMediaPopup)
    end
end

--------------------------------------------------------------------------------
-- Click outside to close
--------------------------------------------------------------------------------
local clickWatcher = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function(event)
    if not mediaPopup.visible or not mediaPopup.canvas then
        return false
    end

    local pos = hs.mouse.absolutePosition()
    local frame = mediaPopup.canvas:frame()

    -- Check if click is outside the popup
    if pos.x < frame.x or pos.x > frame.x + frame.w or
       pos.y < frame.y or pos.y > frame.y + frame.h then
        toggleMediaPopup() -- Close it
    end

    return false
end)
clickWatcher:start()
