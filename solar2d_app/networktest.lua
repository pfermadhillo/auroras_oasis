-- The following sample code contacts Google's encrypted search over SSL
-- and prints the response (in this case, the HTML source of the home page)
-- to the console.
 

  
-- Access Google over SSL:








local composer = require ("composer") 
local scene = composer.newScene() 
local widget = require ( "widget" )

-- name all local variables here -- 
-- defined local (scene) functions here 

local homeURL = "http://auroras.fusionbombsderp.com"

local function isEmpty(s)
  return s == nil or s == ''
end

local function networkListener( event )
 
    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        print ( "RESPONSE: " .. event.response )
    end
end

local function sendPOSTRequest(  )
	-- body

	local headers = {}
	  
	headers["Content-Type"] = "application/x-www-form-urlencoded"
	headers["Accept-Language"] = "en-US"
	  
	local body = "color=red&size=small&username=brosef&time=" .. os.time()
	 
	local params = {}
	params.headers = headers
	params.body = body
	  
	network.request( homeURL .. "/testpost", "POST", networkListener, params )

end

local function 	acctURLEvent( event )
	-- body
	system.openURL( homeURL .. "/createuser" )
end

local function addressBarHandler( event ) 
	if event.phase == "began" then 
	elseif event.phase == "ended" or event.phase == "submitted" then 
		myMap:requestLocation( event.target.text, mapSearchLocationHandlerLocationHandler ) 
		local theInput = event.target.text
		if not isEmpty(theInput	)then	
			-- send the input to the server and receive the big code
		end	
		native.setKeyboardFocus( nil )
	elseif event.phase == "editing" then 
		print( event.newCharacters ) 
		print( event.oldText ) 
		print( event.startPosition ) 
		print( event.text ) 
	end 
end 

function scene:create( event ) 

	local sceneGroup = self.view 
	print ("JGDEBUG " .. "scene:create")

	--your code here; define display objects, sprites, physics bodies, etc - but don't play any sounds or animations yet. 
	local labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }
	local tabButtons = {
	    {
	        label = "Create an Account",
	        id = "acctURL",
	        selected = true,
	        onPress = acctURLEvent
	    }
	}
	-- navBar = widget.newNavigationBar({ title = "Set Appointment Location", backgroundColor = { 0,0,0}, titleColor = {1, 1, 1}, }) 
	navBar = widget.newTabBar({ 
		label = "Input Your Code:", 
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
		network.request( "http://auroras.fusionbombsderp.com/testget", "GET", networkListener )

		sendPOSTRequest(  )

		addressBar = native.newTextField(display.contentCenterX, navBar.y + 90, display.contentCenterX * 1.8, 30) 
		addressBar:addEventListener("userInput", addressBarHandler) 
		sceneGroup:insert(addressBar) 
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

	end 
end 

function scene:destroy( event ) 
	local sceneGroup = self.view 
	-- any code placed here will run as the scene is being removed. Remove display objects, set variables to nil, etc. 


end 

scene:addEventListener( "create", scene ) 
scene:addEventListener( "show", scene ) 
scene:addEventListener( "hide", scene ) 
scene:addEventListener( "destroy", scene ) 
return scene








