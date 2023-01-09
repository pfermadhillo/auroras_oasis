



local composer = require ("composer") 
local scene = composer.newScene() 
local widget = require ( "widget" )
local json = require ("json")

-- name all local variables here -- 
-- defined local (scene) functions here 
local titleBar, navBar, myMap, addressBar 
local attempts = 0 
 markers = {}
-- local markers = {{lat:30.6389954,long:-97.6856937},
-- 	{lat:30.6389954,long:-97.6856937},
-- 	{lat:30.6389954,long:-97.6856937},
-- 	{lat:30.6389954,long:-97.6856937}}
-- local markers = {{30.6389954,-97.6856937},{30.6389954,-97.6856937}}
 -- imgFiles = {"blue_crystal1.png","orange_crystal2.png"}

 homeURL = "https://auroras.fusionbombsderp.com"
 saveFile = "AuroraOasisSave.id"

 token = composer.getVariable( "token" )
 color = composer.getVariable( "color" )


print ("JGDEBUG " .. " running ")

local function checkLocation( location )
	-- body
	local retVal = true
	if ( currentLocation.errorCode or ( currentLocation.latitude == 0 and currentLocation.longitude == 0 ) ) then 
		-- error condition
		retVal = false
	end
	return retVal
end

local function isEmpty(s)
  return s == nil or s == ''
end
local function isTableEmpty( t )
	local next = next
	if next(t) == nil then
	   return true
	end
	return false
end

local function convLatToM( lat )
	return lat * 111139
end
local function convMtoLat( m )
	return m / 111139
end

local function sendGETRequest( url , queriesConcat )
	-- body
	if isEmpty(queriesConcat)then
		network.request( homeURL .. url, "GET", networkListenerGETRequest )
	else -- ?count=30
		network.request( homeURL .. url .. "?" .. queriesConcat, "GET", networkListenerGETRequest )
	end

end



local function networkListenerSendDelete( event )
	-- body
	local id = nil
	if ( event.isError ) then
        print( "Network error: ", event.response )
		native.showAlert( "Network Error: ", event.response, { "____" } ) 
    else
        print ( "RESPONSE: networkListenerSendDelete: " .. event.response )
        -- local dataFromFile = networkListenerSendDelete(saveFile,event.response)
        -- print ("change game scene now! ", dataFromFile)
		-- composer.setVariable( "token", dataFromFile ) 
		-- composer.gotoScene( "thegame" )

		-- local decode = json.decode( event.response )
		-- id = decode[i].id
		-- native.showAlert( event.response, "decode: " .. decode, { "____" } ) 
		-- native.showAlert( event.response, "id: "..id .. "," .. decode, { "____" } ) 
		local id = event.response
		for i=1,table.getn(markers) do
			local line = markers[i]
			if line 
					and not isEmpty(line[1]) 
					and not isEmpty(line[2]) 
					and not isEmpty(line[3]) 
					and not isEmpty(line[4]) 
					and not isEmpty(line[5]) 
					then
				if line[4] == id then
					-- we have a match for the deleted id, remove for markers
					-- id = line[4]
					table.remove(markers , i)
					myMap:removeMarker( line[5] )
				end
			else
			end
		end 
	end
end
local function sendDelete( id )
	-- body
	network.request( homeURL .. "/sendDelete?id=" .. id .. "&token=" .. token, 
		"GET", 
		networkListenerSendDelete )

end

local function markerListener(event)
    print( "type: ", event.type )  -- event type
    print( "markerId: ", event.markerId )  -- ID of the marker that was touched
    print( "lat: ", event.latitude )  -- latitude of the marker
    print( "long: ", event.longitude )  -- longitude of the marker
	local outMsg = "you touched crystal at: " .. event.latitude .. ", " .. event.longitude .. "|" .. event.markerId

	-- native.showAlert( "MARKER1", outMsg, { "<3" } ) 
	local id = nil
	for i=1,table.getn(markers) do
		local line = markers[i]
		if line 
				and not isEmpty(line[1]) 
				and not isEmpty(line[2]) 
				and not isEmpty(line[3]) 
				and not isEmpty(line[4]) 
				and not isEmpty(line[5]) 
				then
			if line[5] == event.markerId then
				-- we have a match for markerId, so grab _id and do db.delete()
				-- id = line[4]
				sendDelete( line[4] )
			end
		else
			-- native.showAlert( "Error: ", "Cant read markers[][] ", { " :'( " } ) 

		end
	end 
end

-- local function getCurrentLocation( )
-- 	-- body
-- 	local cL = {}
-- 	cL.lat = 30.6389954
-- 	cL.long = -97.6856937

-- 	return cL
-- end
local function getCurrentLocation( )
	local currentLocation = myMap:getUserLocation() 
	-- print ("JGDEBUG " .. currentLocation)
	if ( currentLocation.errorCode or ( currentLocation.latitude == 0 and currentLocation.longitude == 0 ) ) then 
		attempts = attempts + 1 
		if ( attempts >= 10 ) then 
			native.showAlert( "No GPS Signal", "Can't sync with GPS.", { "Okay" } ) 
		else 
			timer.performWithDelay( 1000, getCurrentLocation ) 
		end 
	else 
		return currentLocation
	end 
end

local function placeAllMarkers( currentLocation )
	-- body
	myMap:setCenter( currentLocation.latitude, currentLocation.longitude ) 
	myMap:setRegion( currentLocation.latitude, currentLocation.longitude, 0.01, 0.01) 
	local options = { 
		title="You are here", 
		subtitle="testing this", 
		listener = markerListener, 
		imageFile =  "img/blue_crystal1.png",
	} 
	if markers and not isTableEmpty(markers) and not isEmpty(markers[1][1]) then 
		for i=1,table.getn(markers) do
			local line = markers[i]
			if line 
					and not isEmpty(line[1]) 
					and not isEmpty(line[2]) 
					and not isEmpty(line[3]) 
					and not isEmpty(line[4]) 
					then
				options["subtitle"] = "This is crystal#: " .. i
				options["imageFile"] = "img/" .. line[3]
				-- options["_id"] = line[4]
				local result = myMap:addMarker( line[1],line[2], options )
				table.insert(markers[i], result)
				print("markers " .. i .. "line: " .. line[1] .. "," .. line[2] .. "," .. line[3])
			else
				-- native.showAlert( "Error: ", "Cant read markers[][] ", { " :'( " } ) 

			end
		end 
	end
	-- native.showAlert( "mLH", "markers " .. markers[1][1] .. "," .. markers[2][1], { "###" } ) 
end

local function maplocationHandler( event ) 
	local currentLocation = myMap:getUserLocation() 
	-- print ("JGDEBUG " .. currentLocation)
	if ( currentLocation.errorCode or ( currentLocation.latitude == 0 and currentLocation.longitude == 0 ) ) then 
		attempts = attempts + 1 
		if ( attempts >= 10 ) then 
			native.showAlert( "No GPS Signal", "Can't sync with GPS.", { "Okay" } ) 
		else 
			timer.performWithDelay( 1000, maplocationHandler ) 
		end 
	else 
		-- myMap:setCenter( currentLocation.latitude, currentLocation.longitude ) 
		-- myMap:setRegion( currentLocation.latitude, currentLocation.longitude, 0.01, 0.01) 
		-- local options = { 
		-- 	title="You are here", 
		-- 	subtitle="testing this", 
		-- 	listener = markerListener, 
		-- 	imageFile =  "img/blue_crystal1.png",
		-- } 
		-- if not isEmpty(markers[1][1]) then 
		-- 	for i=1,table.getn(markers) do
		-- 		local line = markers[i]
		-- 		if line and not isEmpty(line[1]) and not isEmpty(line[2]) and not isEmpty(line[3]) then
		-- 			options["subtitle"] = "This is crystal#: " .. i
		-- 			options["imageFile"] = "img/" .. imgFiles[line[3]]
		-- 			myMap:addMarker( line[1],line[2], options )
		-- 			print("markers " .. i .. "line: " .. line[1] .. "," .. line[2] .. "," .. line[3])
		-- 		end
		-- 	end 
		-- end
		-- native.showAlert( "mLH", "markers " .. markers[1][1] .. "," .. markers[2][1], { "###" } ) 
		placeAllMarkers(currentLocation)
		-- myMap:addMarker( currentLocation.latitude, currentLocation.longitude, options )

		-- myMap:addMarker( currentLocation.latitude, currentLocation.longitude + convMtoLat(1000) , options ) 
		-- myMap:addMarker( currentLocation.latitude + convMtoLat(500) , currentLocation.longitude, options ) 

		-- local outMsg = "I'm at: " .. currentLocation.latitude .. ", " .. currentLocation.longitude
		-- native.showAlert( "TEST2", outMsg, { "###" } ) 

		return currentLocation
	end 
end 

local function networkListenerGetCrystals( event )
 
    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        print ( "RESPONSE: getCrystals: " .. event.response )
        -- local dataFromFile = writeToFile(saveFile,event.response)
        -- print ("change game scene now! ", dataFromFile)
		-- composer.setVariable( "token", dataFromFile ) 
		-- composer.gotoScene( "thegame" )

		local decode = json.decode( event.response )
		-- print("decide: #: " .. decode[1].lat )
		-- print("decide: #: " .. table.getn(decode) )
		markers = {}
		for i=1,table.getn(decode) do
			-- print(i)
			local line = decode[i]
			table.insert(markers, {line.lat, line.long, line.filename, line._id})
		end
		placeAllMarkers(getCurrentLocation())
		-- print("decide: #: " #decode .. "," .. decode)
    end
end

local function sendPOSTRequest( bodyConcat )
	-- body
	local headers = {}
	  
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Accept-Language"] = "en-US"
	  
	local body = "time=" .. os.time() .. bodyConcat
	 
	local params = {}
	params.headers = headers
	params.body = body
	  
	network.request( homeURL .. "/getCrystals", "POST", networkListenerGetCrystals, params )
end

local function getCrystals(  )
	-- body
	myMap:removeAllMarkers()
	markers = {}
	local cL = getCurrentLocation() 
	local bodyConcat = "&mylat=" .. cL.latitude .. "&mylong=" .. cL.longitude
	sendPOSTRequest( bodyConcat )

end

		-- Function to handle button events
local function handleButtonEvent( event )
 
    if ( "ended" == event.phase ) then
        -- print( "Button was pressed and released" )
        getCrystals()
    end
end
		-- Function to handle button events
local function handleGotoListButtonEvent ( event )
 
    if ( "ended" == event.phase ) then
        -- print( "Button was pressed and released" )
        composer.gotoScene( "listcrystals" )
    end
end

-- local function mapSearchLocationHandler(event) 
-- 	if ( event.isError ) then 
-- 		print( "Map Error: " .. event.errorMessage ) 
-- 	else 
-- 		myMap:setCenter( event.latitude, event.longitude, false ) 
-- 		myMap:setRegion( event.latitude, event.longitude, 0.25, 0.25, false) 
-- 		local options = { title=event.text, } 

-- 	end 
-- end 

-- local function addressBarHandler( event ) 
-- 	if event.phase == "began" then 
-- 	elseif event.phase == "ended" or event.phase == "submitted" then 
-- 		myMap:requestLocation( event.target.text, mapSearchLocationHandlerLocationHandler ) 
-- 		native.setKeyboardFocus( nil )
-- 	elseif event.phase == "editing" then 
-- 		print( event.newCharacters ) 
-- 		print( event.oldText ) 
-- 		print( event.startPosition ) 
-- 		print( event.text ) 
-- 	end 
-- end 

-----------------------------------------------------------------------------------

function scene:create( event ) 

	local sceneGroup = self.view 
	print ("JGDEBUG " .. "scene:create")
	-- display.setDefault( "background", unpack(color.bkgdPurple) )
	display.setDefault( "background", unpack(color.bkgd) )
	--your code here; define display objects, sprites, physics bodies, etc - but don't play any sounds or animations yet. 
	-- local labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
	-- local tabButtons = {
	--     {
	--         label = "Tab1",
	--         id = "tab1",
	--         selected = true,
	--         onPress = handleTabBarEvent
	--     },
	--     {
	--         label = "Tab2",
	--         id = "tab2",
	--         onPress = handleTabBarEvent
	--     },
	--     {
	--         label = "Tab3",
	--         id = "tab3",
	--         onPress = handleTabBarEvent
	--     }
	-- }
	-- -- navBar = widget.newNavigationBar({ title = "Set Appointment Location", backgroundColor = { 0,0,0}, titleColor = {1, 1, 1}, }) 
	-- navBar = widget.newTabBar({ 
	-- 	label = "Set Appointment Location", 
	-- 	labelColor = labelColor,
	-- 	-- labelXOffset = 2000, 
	-- 	-- labelYOffset = -100,
	-- 	buttons = tabButtons
	-- }) 
	-- sceneGroup:insert(navBar) 
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
		-- addressBar = native.newTextField(display.contentCenterX, navBar.y + 90, display.contentCenterX * 1.8, 30) 
		-- addressBar:addEventListener("userInput", addressBarHandler) 
		-- sceneGroup:insert(addressBar) 
		-- native.showAlert( "test", "in create", { "<3" } ) 


		-- getCrystals()
		local testTable={}
		if isTableEmpty(testTable) then
			print ("works!!") 
		end
		print ("isTableEmpty: ",isTableEmpty(testTable),testTable) 

		-- print(token)
		-- print(string.sub(token,1,7))
		local userIDText = display.newText( "Your ID: " .. string.sub(token,1,7), 80, 0, native.systemFont, 16 )
		userIDText:setFillColor( 1, 0, 1 )

		local testX1 = display.newText( "-20", -20, 200, native.systemFont, 16 )
		local testX2 = display.newText( "0", 0, 200, native.systemFont, 16 )
		local testX3 = display.newText( "20", 20, 200, native.systemFont, 16 )
		local testX4 = display.newText( "100", 100, 200, native.systemFont, 16 )
		local testX5 = display.newText( "200", 200, 200, native.systemFont, 16 )
		local testX6 = display.newText( "300", 300, 200, native.systemFont, 16 )
		local testY1 = display.newText( "-20", 50, -20, native.systemFont, 16 )
		local testY2 = display.newText( "0", 50, 0, native.systemFont, 16 )
		local testY3 = display.newText( "20", 50, 20, native.systemFont, 16 )
		local testY4 = display.newText( "50", 50, 50, native.systemFont, 16 )
		local testY5 = display.newText( "100", 50, 100, native.systemFont, 16 )
		local testY6 = display.newText( "200", 50, 200, native.systemFont, 16 )
		local testY7 = display.newText( "300", 50, 300, native.systemFont, 16 )
		local testY7 = display.newText( "400", 50, 400, native.systemFont, 16 )
		local testY7 = display.newText( "500", 50, 500, native.systemFont, 16 )

		-- part of the map will go below the standard viewport
		myMap = native.newMapView(0, 0,display.contentWidth -10 , display.contentHeight -100) 
		if myMap then 
			myMap.mapType = "standard" 
			myMap.x = display.contentCenterX 
			-- navBar height is 52 per api doc // deleted!
			myMap.y = display.contentCenterY -10
			local currentLocation = maplocationHandler() 
			-- local myText = display.newText( "Hello World!", 100, 20, native.systemFont, 16 )
			-- myText:setFillColor( 1, 0, 0 )

			-- myText.text =  "I'm here: " 
			-- if currentLocation then 
			-- 	if not isEmpty(currentLocation.latitude) then
			-- 	    myText.text = myText.text .. currentLocation.latitude .. ", "
			-- 	end
			-- 	if not isEmpty(currentLocation.longitude) then
			-- 	    myText.text = myText.text .. currentLocation.longitude .. ";"
			-- 	end
			-- end
			sceneGroup:insert( myMap )
			
		else 
			-- native.showAlert( "Simulator", "Maps are only avaiable on device.", { "Okay" } ) 
		end 

		 
		-- Create the widget
		local button1 = widget.newButton(
		    {
		        label = "button",
		        onEvent = handleButtonEvent,
		        emboss = false,
		        -- Properties for a rounded rectangle button
		        shape = "roundedRect",
		        width = 200,
		        height = 30,
		        cornerRadius = 2,

				-- fillColor = { default={0.6,0.6,0.8,1}, over={0.9,0.9,1,0.9} }, 
				-- strokeColor = { default={0.8,0.8,0.99,0.2}, over={1,1,1,1} },
		        fillColor = { default=color.btnFill, over=color.btnFillOver },
		        strokeColor = { default=color.btnStroke, over=color.btnStrokeOver},
		        labelColor = { default=color.btnLabel, over=color.btnLabelOver },
		        strokeWidth = 4
		    }
		)
		 
		-- Center the button
		button1.x = display.contentCenterX
		button1.y = display.contentHeight - button1.height
		 
		-- Change the button's label text
		button1:setLabel( "Search For Crystals" )
		sceneGroup:insert( button1 )


		-- Create the widget
		local gotoListCrystalsButton = widget.newButton(
		    {
		        label = "button",
		        onEvent = handleGotoListButtonEvent,
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
		gotoListCrystalsButton.x = display.contentCenterX
		gotoListCrystalsButton.y = 20
		 
		-- Change the button's label text
		gotoListCrystalsButton:setLabel( "Goto Crystals" )
		sceneGroup:insert( gotoListCrystalsButton )

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
		-- addressBar:removeSelf() 
		-- addressBar = nil 
		if myMap and myMap.removeSelf then 
			myMap:removeSelf() myMap = nil 
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


