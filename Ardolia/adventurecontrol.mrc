;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; adventurecontrol.mrc
;;;; Last updated: 04/27/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this file contains the commands and code for the adventures (dungeons)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get a list of dungeons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!dungeon list:#: { $dungeon.list($nick) }
on 2:TEXT:!adventure list:?: { $dungeon.list($nick)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start an adventure to a dungeon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!dungeon start *:#: { $dungeon.start($nick, $3)) }
on 2:TEXT:!adventure start *:#: { $dungeon.start($nick, $3)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Join the party to go on an adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!enter:#: { $adventure.join($nick, $3)) }
on 2:TEXT:!party join:#: { $adventure.join($nick, $3)) }
ON 50:TEXT:*enters the adventure*:#:  { $adventure.join($1) }
ON 50:TEXT:*joins the party:#:  { $adventure.join($1) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!look*:#: {
  if ($2 = $null) { $adventure.look }
  else { $checkchar($2) | $lookat($2, channel) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves the party
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!go *:#: { $adventure.move($nick, $2) }
on 2:TEXT:!move  *:#: { $adventure.move($nick, $2) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lets the party rest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!rest:#: { $adventure.rest($nick) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Leaves the dungeon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!warp:#: { $adventure.warp($nick) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Commands to interact with objects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!push *:#: { $adventure.object($nick, $2-, push) }
on 2:TEXT:!pull *:#: { $adventure.object($nick, $2-, pull) }
on 2:TEXT:!open *:#: { $adventure.object($nick, $2-, open) }
on 2:TEXT:!close *:#: { $adventure.object($nick, $2-, close) }
on 2:TEXT:!read *:#: { $adventure.object($nick, $2-, read) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Chop down a tree
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!chop tree:#: { $adventure.choptree($nick) }






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The adventure begins!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias adventure.begin {
  set %adventureisopen off

  /.timerAdventureBegin off

  ; Write the time the battle begins
  writeini $txtfile(battle2.txt) BattleInfo TimeStarted $ctime

  ; First, see if there's any players in the adventure
  var %number.of.players $return_playersinbattle

  if ((%number.of.players = 0) || (%number.of.players = $null)) {  
    $display.message($readini(translation.dat, battle, NoPlayersOnField), global) 

    ; Increase the empty rounds counter and check to see if the empty rounds is > the max allowed before resetting the streak.
    var %max.emptyrounds $return.systemsetting(EmptyRoundsBeforeStreakReset)
    if (%max.emptyrounds = null) { var %max.emptyrounds 10 }

    var %current.emptyrounds $readini(adventure.dat, battle, emptyRounds) 
    inc %current.emptyrounds 1
    writeini adventure.dat battle emptyRounds %current.emptyrounds

    if (%current.emptyrounds >= %max.emptyrounds) { 
      if ($readini(adventure.dat, battle, adventurelevel) > 0) { $display.message($translate(AdventureResetTo1),global) }
      writeini adventure.dat battle emptyRounds 0
      writeini adventure.dat battle adventureLevel 1
      writeini adventure.dat battle LastReload 0
    }

    $clear_adventure
    halt 
  }

  ; Although I'm adding this code block here, PVP is not yet in the game.
  if (%mode.pvp = on) { 
    set %number.of.players $readini($txtfile(battle2.txt), BattleInfo, Players)
    if ((%number.of.players < 2) || (%number.of.players = $null)) {
      $display.message($readini(translation.dat, battle, NotEnoughPlayersOnField), global)
      $clear_adventure | halt 
    }
  }

  : Tell the bot we need to clean files after this adventure
  set %ignore.clearfiles no

  ; Get a random weather from the battlefield
  ;;;;; $random.weather.pick


  ; Check the moon phase.
  ;;;   $moonphase

  ; Check the Time of Day
  ;;;;   $timeofday

  ; Reset the empty rounds counter.
  writeini adventure.dat battle emptyRounds 0

  ; Set the room of the zone we're in
  set %adventure.zone.room 0

  ; Tell the world that the battle has begun
  $display.message(Battle Begins message, battle)

  ; Set the true turn
  set %true.turn 0 | set %current.battle.number 0

  ; Start the first battle of this adventure
  $battle.generate
}




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Give out the spoils of battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias adventure.giveitems {
  if ($isfile($txtfile(battlespoils.txt)) = $false) { return }
  if ($return.systemsetting(RPGMode) = true) { return }

  ;  Get the list of players 

  ; Cycles through the spoils and give the reward

  ; Display the rewards line.

}
