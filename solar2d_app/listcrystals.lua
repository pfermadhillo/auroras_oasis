





local composer = require ("composer") 
local scene = composer.newScene() 
local widget = require ( "widget" )
local json = require ("json")

-- name all local variables here -- 
-- defined local (scene) functions here 
local scrollView 
local attempts = 0 
 markers = {}
-- local markers = {{lat:30.6389954,long:-97.6856937},
-- 	{lat:30.6389954,long:-97.6856937},
-- 	{lat:30.6389954,long:-97.6856937},
-- 	{lat:30.6389954,long:-97.6856937}}
-- local markers = {{30.6389954,-97.6856937},{30.6389954,-97.6856937}}
 imgFiles = {"blue_crystal1.png","orange_crystal2.png"}

 homeURL = "https://auroras.fusionbombsderp.com"
 saveFile = "AuroraOasisSave.id"

 token = composer.getVariable( "token" )
 color = composer.getVariable( "color" )

local function refreshScrollView(  )
	if(scrollView) then 
		for i=scrollView.numChildren,1 do
		    scrollView[i]:removeSelf()
		end
		scrollView = nil
	end
	
	myWidth = display.contentWidth - 10
	scrollView = widget.newScrollView(
	    {
	        top = 40,
	        left = 5,
	        width = myWidth,
	        height = display.contentHeight-40,
	        scrollWidth = myWidth,
	        scrollHeight = 800,
	        listener = scrollListener,
	        horizontalScrollDisabled = true,
	        backgroundColor = { unpack(color.scrollview) }
	    }
	)
end


local function networkListenerSendWholesale( event )
	if ( "ended" == event.phase ) then
        -- print( "Button was pressed and released" )
        composer.gotoScene( "listcrystals" )
    end
end
local function handleWholesaleButtonEvent( event , id )
	-- body
	print("handleWholesaleButtonEvent", id)
	network.request( homeURL .. "/sendWholesale?id=" .. id , 
		"GET", 
		networkListenerSendWholesale )
end

local function handleAuctionButtonEvent( event )
	-- body
end

local function networkListenerGetMyCrystals( event )
 	-- first, wipe scrollview, then fill it back up
	-- print ("scrollView.numChildren: ",scrollView.numChildren)
	refreshScrollView()
    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        print ( "RESPONSE: postMyCrystals: " .. event.response )
  --       -- local dataFromFile = writeToFile(saveFile,event.response)
  --       -- print ("change game scene now! ", dataFromFile)
		-- -- composer.setVariable( "token", dataFromFile ) 
		-- -- composer.gotoScene( "thegame" )

		local decode = json.decode( event.response )
		-- -- print("decide: #: " .. decode[1].lat )
		-- -- print("decide: #: " .. table.getn(decode) )
		-- markers = {}

		


		for i=1,table.getn(decode) do
		-- 	-- print(i)
			local line = decode[i]

			local xVal = display.contentCenterX
		 	print ("xVal: ", display.contentCenterX , display.contentWidth)
		 	local options = 
			{
			    text = "Hello World",     
			    x = 165, -- shifts entire block left when larger, must adjust if width changes
			    y = 0,
			    width = myWidth-20, -- smaller number reduces total textbox size from left and right
			    font = native.systemFont,   
			    fontSize = 16,
			    align = "left"  -- Alignment parameter
			}
		 	
	 		local yVal = 60*i -60-- 30 is slightly less than double 16 font 
	 		local listText = display.newText( options )
			-- listText:setFillColor( colorBlue.r,colorBlue.g,colorBlue.b )
			listText:setFillColor( unpack(color.blue) )
			listText.text = line.name..", Found on: "..os.date("%D",line.timeCreated/1000).." |"
			listText.y = yVal
			print(listText.text)


			local listText2 = display.newText( options )
			-- listText:setFillColor( colorBlue.r,colorBlue.g,colorBlue.b )
			listText2:setFillColor( unpack(color.blue) )
			listText2.text = "Value: "..line.value..", Grading: "..line.grading..", Condition: "..line.condition
			listText2.y = yVal+20
			print(listText2.text)

			local listImage = display.newImage( "img/"..line.filename )
			listImage.x = 10
			listImage.y = yVal
			listImage:scale( 0.5, 0.5 )

			local wholesaleButton = widget.newButton(
			    {
			        label = "button",
			        onRelease = function( event ) handleWholesaleButtonEvent( event, line._id ) end ,
			        emboss = false,
			        -- Properties for a rounded rectangle button
			        shape = "roundedRect",
			        width = 100,
			        height = 20,
			        cornerRadius = 2,
			        fillColor = { default=color.btnFill, over=color.btnFillOver },
			        strokeColor = { default=color.btnStroke, over=color.btnStrokeOver},
				    labelColor = { default=color.btnLabel, over=color.btnLabelOver },
			        strokeWidth = 4
			    }
			)
			wholesaleButton.x = display.contentCenterX-70
			wholesaleButton.y = yVal + 45
			wholesaleButton:setLabel( "Wholesale" )

			local auctionButton = widget.newButton(
			    {
			        label = "button",
			        onEvent = handleAuctionButtonEvent,
			        emboss = false,
			        -- Properties for a rounded rectangle button
			        shape = "roundedRect",
			        width = 100,
			        height = 20,
			        cornerRadius = 2,
			        fillColor = { default=color.btnFill, over=color.btnFillOver },
			        strokeColor = { default=color.btnStroke, over=color.btnStrokeOver},
				    labelColor = { default=color.btnLabel, over=color.btnLabelOver },
			        strokeWidth = 4
			    }
			)
			auctionButton.x = display.contentCenterX+70
			auctionButton.y = yVal + 45
			auctionButton:setLabel( "Auction" )
			-- sceneGroup:insert( gotoGameButton )

			local listGroup = display.newGroup()
			listGroup:insert( listText )
			listGroup:insert( listText2 )
			listGroup:insert( listImage )
			listGroup:insert( wholesaleButton )
			listGroup:insert( auctionButton )
			scrollView:insert( listGroup )

		end
		-- -- print("decide: #: " #decode .. "," .. decode)
    end
	print ("after scrollView.numChildren: ",scrollView.numChildren)

end

local function sendMyCrystalsPOSTRequest(  )
	-- body
	local headers = {}
	  
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Accept-Language"] = "en-US"

	local bodyConcat = "&token=".. token
	  
	local body = "time=" .. os.time() .. bodyConcat
	 
	local params = {}
	params.headers = headers
	params.body = body
	  
	network.request( homeURL .. "/postMyCrystals", "POST", networkListenerGetMyCrystals, params )
end


  
-- ScrollView listener
local function scrollListener( event )
 
    local phase = event.phase
    if ( phase == "began" ) then print( "Scroll view was touched" )
    elseif ( phase == "moved" ) then print( "Scroll view was moved" )
    elseif ( phase == "ended" ) then print( "Scroll view was released" )
    end
 
    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then print( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then print( "Reached top limit" )
        elseif ( event.direction == "left" ) then print( "Reached right limit" )
        elseif ( event.direction == "right" ) then print( "Reached left limit" )
        end
    end
 
    return true
end
 
local function handleGotoGameButtonEvent ( event )
 
    if ( "ended" == event.phase ) then
        -- print( "Button was pressed and released" )
        composer.gotoScene( "thegame" )
    end
end




-----------------------------------------------------------------------------------

function scene:create( event ) 

	local sceneGroup = self.view 
	print ("JGDEBUG " .. "scene:create")

	--your code here; define display objects, sprites, physics bodies, etc - but don't play any sounds or animations yet. 
	-- Create the widget
	-- refreshScrollView()
	-- myWidth = display.contentWidth - 10
	-- scrollView = widget.newScrollView(
	--     {
	--         top = 40,
	--         left = 5,
	--         width = myWidth,
	--         height = display.contentHeight-40,
	--         scrollWidth = myWidth,
	--         scrollHeight = 800,
	--         listener = scrollListener,
	--         horizontalScrollDisabled = true,
	--         backgroundColor = { unpack(color.scrollview) }
	--     }
	-- )
 -- 	local xVal = display.contentCenterX
 -- 	print ("xVal: ", display.contentCenterX , display.contentWidth)
 -- 	-- loval yVal = 0
 -- 	local options = 
	-- {
	--     text = "Hello World",     
	--     x = 150,
	--     y = 0,
	--     width = myWidth-20,
	--     font = native.systemFont,   
	--     fontSize = 16,
	--     align = "left"  -- Alignment parameter
	-- }
 -- 	for i=1,3 do
 -- 		-- print(i)
 -- 		local yVal = 20*i
 -- 		local listText = display.newText( options )
	-- 	listText:setFillColor( 0, 1, 0 )
	-- 	listText.text = "list text test: "..i
	-- 	listText.y = yVal
	-- 	print(listText.text)
	-- 	scrollView:insert( listText )

 -- 		local listText2 = display.newText( options )
	-- 	listText2:setFillColor( 1, 1, 0 )
	-- 	listText2.text = "much much longer version of list text test: "..i
	-- 	listText2.y = yVal
	-- 	print(listText2.text)
	-- 	scrollView:insert( listText2 )
	-- 	-- listText.anchorY = yVal
	-- 	-- listText.anchorX = 40
	-- 	-- listText2.anchorX = 40
 -- 	end
	-- Create a image and insert it into the scroll view

	-- Create the widget
	local gotoGameButton = widget.newButton(
	    {
	        label = "button",
	        onEvent = handleGotoGameButtonEvent,
	        emboss = false,
	        -- Properties for a rounded rectangle button
	        shape = "roundedRect",
	        width = 200,
	        height = 30,
	        cornerRadius = 2,
	        fillColor = { default=color.btnFill, over=color.btnFillOver },
	        strokeColor = { default=color.btnStroke, over=color.btnStrokeOver},
		    labelColor = { default=color.btnLabel, over=color.btnLabelOver },
	        strokeWidth = 4
	    }
	)
	 
	-- Center the button
	gotoGameButton.x = display.contentCenterX
	gotoGameButton.y = 20
	 
	-- Change the button's label text
	gotoGameButton:setLabel( "Goto Map Screen" )
	sceneGroup:insert( gotoGameButton )

end 

function scene:show( event ) 

	local sceneGroup = self.view 
	local phase = event.phase 
	print ("JGDEBUG " .. "scene:show")
	-- local myGroup = display.newGroup()

	if ( phase == "will" ) then 
		-- any code placed here will run when the scene is still "off-screen", but about to be displayed to the user. In many cases, this will be empty. 
	elseif ( phase == "did" ) then 
		
		-- any code placed here will run as soon as the scene is displayed on screen. This is where you would start any animations, start playing background audio, start timers, etc. 
		sendMyCrystalsPOSTRequest(  )
		
		if scrollView and not scrollView.isVisible then
			scrollView.isVisible = true
		end


	end 
end 

function scene:hide( event ) 
	local sceneGroup = self.view 
	local phase = event.phase 
	print ("JGDEBUG " .. "scene:hide")

	if ( phase == "will" ) then 
		-- any code placed here will run when the scene is still on screen, but is about to go off screen. This is where you would stop timers, audio, and animations that you created in the show event. 
	elseif ( phase == "did" ) then 
		-- any code placed here will run as soon as the scene is no longer visible. In many cases, this will be empty. 
		if scrollView  then 
			scrollView.isVisible = false 
		end 

	end 
end 

function scene:destroy( event ) 
	local sceneGroup = self.view 
	-- any code placed here will run as the scene is being removed. Remove display objects, set variables to nil, etc. 
	print ("JGDEBUG " .. "scene:destroy")

end 

scene:addEventListener( "create", scene ) 
scene:addEventListener( "show", scene ) 
scene:addEventListener( "hide", scene ) 
scene:addEventListener( "destroy", scene ) 
return scene





-- ... local listTextObject = display.newText( listText, 0 , 0 , display.contentWidth \* .8 , 0, "helvetica" , 14) 
-- listTextObject:setTextColor(0) 
-- listTextObject.x = display.contentCenterX 
-- scrollView:insert(listTextObject) 
-- listTextObject.anchorY = 0 ...&nbsp;




