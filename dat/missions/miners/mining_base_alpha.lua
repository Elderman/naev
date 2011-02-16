--[[	
	+ Mining base
		- First off mining missions
		- Help miners to construct their new mining base in the Sirou system

		- Programmed: Anatolis (feb 2011)
		- Text:	Anatolis (feb 2011)
]]--

-- localization stuff, translators would work here
lang = naev.lang()
if lang == "es" then
else -- default English
   bar_desc = "A rough appearing miner walks from one pilot to another."
   mtitle = {}
   mtitle[1] = "Mining base"
   mreward = {}
   mreward[1] = "%d credits"
   mdesc = {}
   mdesc[1] = "Go to the %s system to launch the modules."
   mdesc[2] = "Drop off the technicians at %s in the %s system."
   
   title = {}
   title[1] = "Bar"
   title[2] = "Building a base"
   title[3] = "Mission Success"
   title[5] = "Successful launch"
   title[8] = "Better luck next time"
   	
	-- TODO: Spicing up texts and introduction to a minor miner storyline(?) -Anatolis
   	text = {}
   	text[1] = [["Hello, my name is Gallain. I am a representative of the miners guild. To extend our working area we are planning to construct a new mining station. We are looking for a capable pilot who can help us launch the space station modules. 
   	Would you help us?" ]]
   	text[2] = [["Thank you! The plan is for you to take us to the %s system so we can launch our station modules. Then we'll return back here on %s and %s so we can start the preparations for the next steps. You'll be paid %d credits when we arrive back."]]
   	text[3] = [["We will now start loading our modules in your ship. A group of technicians will also join you to ensure a smooth launch. When everything is loaded we would like to leave at-once!"]]
   
	text[4] = [[One of the miner technicians approaches you in your cockpit. "The launch was successful", he said. "We can now leave and return to %s. The modules are programmed to assemble themselves automatically. It will take some time before the station is assembled." 
	You nod and start travelling to the nearest hyperjump point.]]

	text[5] = [[The technicians thank you for your help. "In a few UST the station will be ready, but we could use your help in the future to help us to make the station operational."
Before the technicians run back into the market to buy new stuff for their station, one of them hands you a credit-chip with your reward.]]
   
   
   text[8] = [["That's too bad. Perhaps we could try again in the future." The miner walks away disappointed and starts talking to another pilot.]]
   text[9] = [["You do not have enough free cargo space to accept this mission!"]]
   
   launch = {}
   launch[1] = "Preparing to launch station modules..."
   launch[2] = "Getting into position..."
   launch[3] = "Launch in 5..."
   launch[4] = "Modules launched successfully!"
   
   trgtSystem = "Sirou" -- System where the new mining base will be build. If you change this, change also in unidiff.xml!!
end


function create ()
   -- Note: this mission does not make any mission claims.
   -- Set up mission variables
   misn_stage = 0
   
   homeworld = planet.cur()
   homeworld_sys = system.cur()
   satellite_sys = system.get(trgtSystem)
   credits = 50000

   -- Set stuff up for the spaceport bar
   misn.setNPC( "A miner", "none" ) -- TODO: portrait of a 'scary' miner
   misn.setDesc( bar_desc )
end


function accept ()
   -- See if rejects mission
   if not tk.yesno( title[1], text[1] ) then
		-- Mission not accepted: react disappointed
      	tk.msg( title[8], text[8] )
	  	misn.finish()
   end

   -- Check for cargo space because we'll be hauling 5 packages of 3
   if pilot.cargoFree(player.pilot()) <  15 then
		-- Not enough cargospace: Just give feedback about that
      	tk.msg( title[8], text[9] )
      	misn.finish()
   end

   -- Add cargo
   -- Loading multiple packages just for a nicer effect when jettison the cargo.
   cargo1 = misn.cargoAdd( "Starbase module", 3 )
   cargo2 = misn.cargoAdd( "Starbase module", 3 )
   cargo3 = misn.cargoAdd( "Starbase module", 3 )
   cargo4 = misn.cargoAdd( "Starbase module", 3 )
   cargo5 = misn.cargoAdd( "Starbase module", 3 )
   
   -- Set up mission information
   misn.setTitle( mtitle[1] )
   misn.setReward( string.format( mreward[1], credits ) )
   misn.setDesc( string.format( mdesc[1], satellite_sys:name() ) )
   misn_marker = misn.markerAdd( satellite_sys, "low" )

   -- Add mission
   misn.accept()

   	-- More flavour text
  	-- Tell about plans after accepting 
   	tk.msg( title[2], string.format(text[2], satellite_sys:name(), homeworld:name(), homeworld_sys:name(), credits ) )
   	tk.msg( title[2], string.format(text[3], satellite_sys:name()) )
	
	-- Creating objective    	
	misn.osdCreate(mtitle[1], {mdesc[1]:format(satellite_sys:name())} )
   
   -- Set up hooks
   hook.land("land")
   hook.enter("jump")
end

function land ()
   landed = planet.cur()
   -- Mission success
   if misn_stage == 1 and landed == homeworld then
		player.pay( credits )			-- Pay the player
		diff.apply("Mining_base_alpha") 	-- Apply diff to reveal our miningbase
	  
		var.push( "miner_status", 1 ) 		-- creating a mission variable for later lookup and tracing.

		-- Text for completion. Thanks and suggestion to more missions from new station
		tk.msg( title[3], text[5] )
		
		misn.finish(true) 				-- And finishing this mission.
   end
end

function jump ()
   sys = system.cur()
   -- Launch satellite
   if misn_stage == 0 and sys == satellite_sys then
      hook.timer( 3000, "beginLaunch" )	-- 3sec after entering the system, start launching
   end
end


--[[
   Launch process
--]]
function beginLaunch ()
	-- TODO: fixing some more specific  location to drop the station modules -Anatolis
	player.msg( launch[2] ) -- start position
	player.msg( launch[1] ) -- Starting countdown
	misn.osdDestroy()		-- Distroy the current mission objective (jetting cargo)
	hook.timer( 3000, "beginCountdown" )
end
function beginCountdown ()
   countdown = 5
   player.msg( launch[3] )
   hook.timer( 1000, "countLaunch" )
end
function countLaunch ()
   countdown = countdown - 1
   if countdown <= 0 then
      launchModules()
   else
      player.msg( string.format("%d...", countdown) )
      hook.timer( 1000, "countLaunch" )
   end
end
function launchModules ()
	misn_stage = 1
	player.msg( launch[4] )
	-- Jettison all packages. Just for the effect.
	misn.cargoJet(cargo1)
	misn.cargoJet(cargo2)
	misn.cargoJet(cargo3)
	misn.cargoJet(cargo4)
	misn.cargoJet(cargo5)
	
	hook.timer( 2000, "launchSucces" ) -- Wait for 2sec to display succes message
end
function launchSucces()
	-- Message upon good launch. 
	tk.msg( title[5], string.format( text[4], homeworld:name() ) ) -- Succesfull launch
		
	misn.setDesc( string.format( mdesc[2], homeworld:name(), homeworld_sys:name() ) ) -- Go back to home-planet
	misn.osdCreate(mtitle[1], {mdesc[2]:format(homeworld:name(), homeworld_sys:name())}) -- New target description
	misn.markerMove( misn_marker, homeworld_sys )
end


