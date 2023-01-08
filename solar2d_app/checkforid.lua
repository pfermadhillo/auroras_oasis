-- The following sample code contacts Google's encrypted search over SSL
-- and prints the response (in this case, the HTML source of the home page)
-- to the console.
 

  
-- Access Google over SSL:








local composer = require ("composer") 
local scene = composer.newScene() 

-- name all local variables here -- 
-- defined local (scene) functions here 


local mime = require( "mime" ) 

local saveFile = "AuroraOasisSave.id"

color = {
	blue={138/255, 201/255, 209/255},
	bkgdPurple={128/255, 25/255, 128/255},
	bkgd={230/255, 166/255, 245/255},
	scrollview={148/255, 45/255, 148/255,1},
	btnFill={168/255, 65/255, 168/255,1},
	btnFillOver={0.9,0.6,0.9,0.9},
	btnStroke={188/255, 85/255, 188/255,0.2},
	btnStrokeOver={1,1,1,1},
	btnLabel={138/255, 201/255, 209/255},
	btnLabelOver={0,0,1,1}
}
composer.setVariable( "color", color ) 

-- fillColor = { default={0.6,0.6,0.8,1}, over={0.9,0.9,1,0.9} }, 
-- strokeColor = { default={0.8,0.8,0.99,0.2}, over={1,1,1,1} },
-- labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }

local function isEmpty(s)
  return s == nil or s == ''
end


local function writeToFile(saveFile, data)
	-- body

	-- Path for the file to write
	local path = system.pathForFile( saveFile, system.DocumentsDirectory )
	 
	-- Open the file handle
	local file, errorString = io.open( path, "w" )
	 
	if not file then
	    -- Error occurred; output the cause
	    print( "File error: " .. errorString )
	else
	    -- Write data to file
	    file:write( data )
	    -- Close the file handle
	    io.close( file )

		file = nil
	    return data
	end
	
	file = nil
	return nil
end

local function readFromFile( saveFile )
	-- body
	-- Path for the file to read
	local path = system.pathForFile( saveFile, system.DocumentsDirectory )
	local outString = ""
	-- Open the file handle
	local file, errorString = io.open( path, "r" )
	 
	if not file then
	    -- Error occurred; output the cause
	    print( "File error: " .. errorString )
	else
	    -- Read data from file
	    local contents = file:read( "*a" )
	    -- Output the file contents
	    if not isEmpty(contents) then
	    	--
	    	print( "Contents of " .. path .. "\n" .. contents )
	    	outString = contents
	    end
	    -- Close the file handle
	    io.close( file )
	end
	 
	file = nil
	return outString
end



local function networkListener( event )
 
    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        print ( "RESPONSE: " .. event.response )
    end
end


local function networkListenerNewToken( event )
	-- native.showAlert( "in networkListenerNewToken ", "", { "<3" } ) 
 
    if ( event.isError ) then
        print( "Network error: ", event.response )
		native.showAlert( "Network error: ", event.response, { "<3" } ) 

    else

		-- native.showAlert( "networkListenerNewToken", event.response, { "<3" } ) 


        print ( "RESPONSE: " .. event.response )
        local dataFromFile = writeToFile(saveFile,event.response)
        print ("New Token! change game scene now! ", dataFromFile)
        -- native.showAlert( "New Token! change game scene now!", "" .. dataFromFile, { "<3" } ) 
		composer.setVariable( "token", dataFromFile ) 
		composer.gotoScene( "thegame" )

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
	  
	-- network.request( homeURL .. "/testpost", "POST", networkListener, params )

end







function scene:create( event ) 

	local sceneGroup = self.view 
	print ("JGDEBUG " .. "scene:create")

	--your code here; define display objects, sprites, physics bodies, etc - but don't play any sounds or animations yet. 


end 

function scene:show( event ) 

	local sceneGroup = self.view 
	local phase = event.phase 
	print ("JGDEBUG " .. "scene:show")

	if ( phase == "will" ) then 
		-- any code placed here will run when the scene is still "off-screen", but about to be displayed to the user. In many cases, this will be empty. 
	elseif ( phase == "did" ) then 
		-- any code placed here will run as soon as the scene is displayed on screen. This is where you would start any animations, start playing background audio, start timers, etc. 

		-- -- check for the file and code 
		-- local dataFromFile = nil
		local dataFromFile = readFromFile(saveFile)
		print("dataFromFile: ", dataFromFile)

		-- local myTextOut = "Failed to get dataFromFile"
		-- if not isEmpty(dataFromFile) then
		-- 	myTextOut = "Found: " .. dataFromFile
		-- end
		-- local myText = display.newText( myTextOut, 100, 200, native.systemFont, 16 )
		-- myText:setFillColor( 1, 0, 0 )

		if not isEmpty(dataFromFile) then
			-- we have our data!
        	print ("found token! change game scene now! ", dataFromFile)

			composer.setVariable( "token", dataFromFile ) 
			composer.gotoScene( "thegame" )
		else
			-- we must make data
        	-- native.showAlert( "making network request", "", { "<3" } ) 

			network.request( "https://auroras.fusionbombsderp.com/getToken", "GET", networkListenerNewToken )
		end

		-- -- if we dont find it, we make it
		-- 



		-- network.request( "http://auroras.fusionbombsderp.com/getToken", "GET", networkListenerNewToken )

		-- sendPOSTRequest(  )

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








