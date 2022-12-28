



local composer = require ("composer") 
local scene = composer.newScene() 
local widget = require ( "widget" )
-- name all local variables here -- 
-- defined local (scene) functions here 
local titleBar, navBar, myMap, addressBar 
local attempts = 0 
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

local function convLatToM( lat )
	return lat * 111139
end
local function convMtoLat( m )
	return m / 111139
end

local function markerListener(event)
    print( "type: ", event.type )  -- event type
    print( "markerId: ", event.markerId )  -- ID of the marker that was touched
    print( "lat: ", event.latitude )  -- latitude of the marker
    print( "long: ", event.longitude )  -- longitude of the marker
	local outMsg = "you touched crystal at: " .. event.latitude .. ", " .. event.longitude

	native.showAlert( "MARKER1", outMsg, { "<3" } ) 

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
		myMap:setCenter( currentLocation.latitude, currentLocation.longitude ) 
		myMap:setRegion( currentLocation.latitude, currentLocation.longitude, 0.01, 0.01) 
		local options = { 
			title="You are here", 
			subtitle="testing this", 
			listener = markerListener, 
			imageFile =  "img/blue_crystal1.png",
		} 
		myMap:addMarker( currentLocation.latitude, currentLocation.longitude, options )

		myMap:addMarker( currentLocation.latitude, currentLocation.longitude + convMtoLat(1000) , options ) 
		myMap:addMarker( currentLocation.latitude + convMtoLat(500) , currentLocation.longitude, options ) 

		local outMsg = "I'm at: " .. currentLocation.latitude .. ", " .. currentLocation.longitude
		native.showAlert( "TEST2", outMsg, { "###" } ) 

		return currentLocation
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

	--your code here; define display objects, sprites, physics bodies, etc - but don't play any sounds or animations yet. 
	local labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
	local tabButtons = {
	    {
	        label = "Tab1",
	        id = "tab1",
	        selected = true,
	        onPress = handleTabBarEvent
	    },
	    {
	        label = "Tab2",
	        id = "tab2",
	        onPress = handleTabBarEvent
	    },
	    {
	        label = "Tab3",
	        id = "tab3",
	        onPress = handleTabBarEvent
	    }
	}
	-- navBar = widget.newNavigationBar({ title = "Set Appointment Location", backgroundColor = { 0,0,0}, titleColor = {1, 1, 1}, }) 
	navBar = widget.newTabBar({ 
		label = "Set Appointment Location", 
		labelColor = labelColor,
		-- labelXOffset = 2000, 
		-- labelYOffset = -100,
		buttons = tabButtons
	}) 
	sceneGroup:insert(navBar) 
end 

function scene:show( event ) 

	local sceneGroup = self.view 
	local phase = event.phase 
	print ("JGDEBUG " .. "scene:show")

	if ( phase == "will" ) then 
		-- any code placed here will run when the scene is still "off-screen", but about to be displayed to the user. In many cases, this will be empty. 
	elseif ( phase == "did" ) then 
		
		-- any code placed here will run as soon as the scene is displayed on screen. This is where you would start any animations, start playing background audio, start timers, etc. 
		-- addressBar = native.newTextField(display.contentCenterX, navBar.y + 90, display.contentCenterX * 1.8, 30) 
		-- addressBar:addEventListener("userInput", addressBarHandler) 
		-- sceneGroup:insert(addressBar) 
		myMap = native.newMapView(0, 0,display.contentWidth , display.contentHeight *(4/5) ) 
		if myMap then 
			myMap.mapType = "standard" 
			myMap.x = display.contentCenterX 
			myMap.y = navBar.y + 200
			local currentLocation = maplocationHandler() 
			local myText = display.newText( "Hello World!", 100, 20, native.systemFont, 16 )
			myText:setFillColor( 1, 0, 0 )

			myText.text =  "I'm here: " 
			if currentLocation then 
				if not isEmpty(currentLocation.latitude) then
				    myText.text = myText.text .. currentLocation.latitude .. ", "
				end
				if not isEmpty(currentLocation.longitude) then
				    myText.text = myText.text .. currentLocation.longitude .. ";"
				end
			end
			-- native.showAlert( "TEST", myText.text, { "###" } ) 

		else 
			native.showAlert( "Simulator", "Maps are only avaiable on device.", { "Okay" } ) 
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


