;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; adventure.als
;;;; Last updated: 05/02/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lists all the dungeons/adventures
; that are available to the player
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dungeon.list {
  ; [dungeonfilename] Dungeon Full Name - # of players - Level Range
  ; Should the dungeons be listed in a .lst file to read?

  ; Check the filename and see if the dungeon is available (pre-req required or hoilday dungeon)

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tells the game that the player
; wants to start an adventure/party
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dungeon.start {
  ; $1 =  the person starting the adventure (i.e. party leader)
  ; $2 = the name of the dungeon/adventure being started 

  ; Is there currently an adventure already in progress?
  if ($readini($zonefile(adventure), info, Name) != $null) { $display.message($translate(Can'tStartAdventure), global) | halt }

  ; Can the party leader lead another party so soon?
  ; to be added

  ; Does the adventure file exist?
  if ($isfile($zonefile($2)) = $false) { $display.message($translate(NoAdventureByThatName), global) | halt }

  ; Is there a pre-req that needs to be done before this one may be started?
  ; to be added

  ; Is this dungeon only available on a certain month (i.e. holiday dungeons)?   If so, is it the right month?
  ; to be added

  ; Is there a minimum item level to start this adventure?
  if ($readini($zonefile($2), info, iLevel) > $character.iLevel($1)) { $display.message($translate(NotHighEnoughiLevelToStart, $1), private) | halt }

  ; Let's add the party leader to the adventure
  $adventure.party.addmember($1)

  ; Copy the dungeon file to adventure.zone so that it can be freely modified
  .copy -o $zonefile($2) $zonefile(adventure)

  ; Is the adventure a solo adventure?
  if ($readini($zonefile(adventure), Info, MaximumPlayers) = 1) { 
    $display.message($translate(ThisAdventureIsSolo, $1), global)   
    /.timerAdventureBegin 1 3 /adventure.begin 
    halt
  }


  ; Open the party so that others may join
  $adventure.open($1, $2)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Opens the adventure to others
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.open {
  ; $1 = the person starting the adventure
  ; $2 = the name of the adventure being started

  ; Set the variable
  set %adventure.open true

  ; Get the time we have before this adventure starts
  set %time.to.enter $readini(system.dat, system, TimeToEnter)
  if (%time.to.enter = $null) { var %time.to.enter 120 }
  var %time.to.enter.minutes $round($calc(%time.to.enter / 60),1)

  ; Start the timer for players to enter
  /.timerAdventureBegin 1 %time.to.enter /adventure.begin

  ; Display the message that the adventure is open
  $display.message($translate(AdventureOpen, $1), global) 

  unset %time.to.enter
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lets a player join the party
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.join {
  ; Enter the person into the party

  $checkchar($1)

  ; Is the party accepting members?
  if ($isfile($txtfile(adventure.txt)) = $false) { $display.message($translate(AdventureClosed, $1), global)  | unset %real.name | halt }
  if ((%adventure.open != true) && ($return.systemsetting(AllowLateEntries) != true)) { $display.message($translate(AdventureClosed, $1), global)  | halt  }

  ; Is this player already in the party?
  if ($adventure.alreadyinparty.check($1) = true) { $display.message($translate(AlreadyInAdventure, $1), private) | halt  } 

  ; Is there a minimum item level to enter this adventure?
  if ($adventure.minimumiLevel > $character.iLevel($1)) { $display.message($translate(NotHighEnoughiLevelToEnter, $1), private) | halt }

  ; Is there a maximum amount of players allowed?  If so, are we at the limit?
  if ($readini($zonefile(adventure), Info, MaximumPlayers) != $null) { 
    if ($adventure.party.count = $readini($zonefile(adventure), info, MaximumPlayers) { $display.message($translate(PartyIsFull), global) | halt }
  }

  $adventure.party.addmember($1)

  writeini $char($1) info SkippedTurns 0

  $display.message($translate(EnteredTheAdventure), global)

  remini $char($1) info levelsync 
  writeini $char($1) info NeedsFulls yes
  $miscstats($1, add, TotalAdventures, 1)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actually starts the adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.begin {

  ; Are there enough players in the party for this dungeon?
  if ($adventure.party.count < $adventure.minimumplayers) { $display.message($translate(NotEnoughPlayersInAdventure), global) | $adventure.clearfiles | halt }

  ; Write the start time to the party leader. 
  writeini $char($adventure.party.leader) info LastAdventure $fulldate

  ; Write when the adventure started
  writeini $txtfile(adventure.txt) info AdventureStarted $fulldate

  ; Is this the first adventure ever done? If so, let's write it to adventure.dat
  if ($readini(adventure.dat, AdventureStats, FirstAdventure) = $null) { writeini adventure.dat AdventureStats FirstAdventure $fulldate }

  ; Set variables
  set %current.room 0
  set %adventure.open false
  set %adventureis on 
  set %true.turn 0

  ; Display the first room's info
  $display.message(7*2 $readini($zonefile(adventure), 0, EnterDesc), global)

  ; Display the number of adventure actions the party has to complete this
  $display.message($translate(AdventureActionsMessage), global)

  ; Display the first room's look info.
  set %show.room true
  /.timerShowFirstRoom 1 1 /adventure.look
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The adventure is over
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.end {
  ; $1 = victory, defeat

  $display.message($translate(AdventureIsOver), global)

  ; calculate total battle duration
  var %total.adventure.duration $adventure.calculateduration

  if ($1 = victory) {  
    echo -a we win!

    var %victory.message $readini($zonefile(adventure), Info, AdventureClearMessage)
    if (%victory.message = $null) { var %victory.message The party returns to town victorious! }
    $display.message(3 $+ %victory.message, global)

    ; Increase the # of adventures we've cleared
    var %total.adventures $readini(adventure.dat, AdventureStats, TotalAdventuresCleared)
    inc %total.adventures 1
    writeini adventure.dat AdventureStats TotalAdventuresCleared %total.adventures
  }
  if (($1 = defeat) || ($1 = failure)) { 
    $display.message($translate(AdventureFailMessage),global) 

    ; Increase the # of adventures we've failed
    var %total.adventures $readini(adventure.dat, AdventureStats, TotalAdventuresFailed)
    inc %total.adventures 1
    writeini adventure.dat AdventureStats TotalAdventuresFailed %total.adventures

  }

  ; Kill any related timers..
  $clear_timers

  ; Award the spoils and xp of battle
  $adventure.rewards($1)

  set %ignore.clearfiles no

  if (%ignore.clearfiles != yes) {
    ; Search through the characters folder and find stray monsters/npcs.  Also full players.
    .echo -q $findfile( $char_path , *.char, 0, 0, adventure.clearfiles $1-) 
    set %ignore.clearfiles yes
  }

  ; Kill the files and variables
  set %adventureis off | set %adventure.open false 
  unset %clear.flag | unset %chest.time
  if ($lines($txtfile(temp_status.txt)) != $null) { .remove $txtfile(temp_status.txt) }

  ; Clear variables
  $clear_variables

  $adventure.cleardatafiles
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears timers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_timers {
  /.timerAdventureBegin off
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears data files used for the adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.cleardatafiles {
  ; Remove the battle text files
  .remove $txtfile(battle.txt) | .remove $txtfile(battle2.txt) | .remove MonsterTable.file
  .remove $txtfile(battlespoils.txt) | .remove $txtfile(adventure.txt) | .remove $txtfile(battlespoils.txt)
  .remove $zonefile(adventure)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates how long the
; adventure took
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.calculateduration {
  var %total.time $readini($txtfile(adventure.txt), Info, AdventureStarted)
  if (%total.time != $null) {
    var %total.adventure.time $ctime(%total.time)
    var %total.adventure.duration $duration($calc($ctime - %total.adventure.time))
  }
  if (%total.time = $null) { var %total.adventure.duration unknown time }

  return %total.adventure.duration
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cleans the \characters\ folder
; and gets everyone ready
; for the next adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Goes through and 'fulls' everyone and cleans up their files to be ready
adventure.clearfiles {

  set %name $remove($1-,.char)
  set %name $nopath(%name)

  if ($lines($txtfile(status $+ %name $+ .txt)) != $null) { .remove $txtfile(status $+ %name $+ .txt) }
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 
    var %clear.flag $flag(%name)

    if ((%clear.flag = $null) && ($resting.hp(%name) = $null)) {
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: NULL HP }
      .remove $char(%name) 
    }
    if ((%clear.flag = monster) || (%clear.flag = npc)) {
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: Monster or NPC at End of Battle }
      .remove $char(%name) 
    } 
    if (%name = !use) {
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: Invalid User Name (!use) }
      .remove $char(%name)
    }
    if ($file($char(%name)).size = 0) { 
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: Invalid File Size (the file's size is 0) }
      $zap_char(%name) 
    }

    ; Check to see if this personc an level up
    $levelup.check(%name)

    ; Let's refill their hp/mp/stats to max.
    $fulls(%name)
    if ((%clear.flag = $null) && ($resting.str(%name) != $null)) { $oldchar.check(%name) }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rewards items, xp, fame
; after the adventure is over
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.rewards {
  ; This code block is not finished but it's close

  unset %winners.xp
  unset %winners.spoils

  ; Cycle through the party
  var %adventure.party $readini($txtfile(adventure.txt), Info, partymembersList) | var %current.party.member 1 
  while (%current.party.member <= $adventure.party.count) { 
    var %party.member.name $gettok(%adventure.party, %current.party.member, 46)

    var %xp.to.reward $readini($txtfile(adventure.txt), Rewards, XP)
    if (%xp.to.reward = $null) { var %xp.to.reward 0 }

    if ($1 = victory) { 

      ; Write that we've cleared this adventure
      writeini $char(%party.member.name) AdventuresCleared $readini($zonefile(adventure), Info, OriginalFile) true 

      ; Give some fame
      var %fame.to.reward $readini($zonefile(adventure), Info, FameRewarded)
      inc %fame.to.reward $current.fame(%party.member.name)
      writeini $char(%party.member.name) Info Fame %fame.to.reward

      ; Give a random clear reward
      ; if (isfile($lstfile($readini($zonefile(adventure), Info, OriginalFile)  $+ _clear)) = true) { 

      ; pull a random item from that list 

      ; give it to the player

      ; find out what kind of item it is so we can do a rarity color on it

      ; add the spoil to the list of spoils
      ;  %winners.spoils = $addtok(%winners.xp, $+ %party.member.name $+  $+ $chr(91) $+ $chr(43) $+ %spoil.reward $+ $chr(93),46)
      ;  }

      ; Add some bonus xp for clearing the adventure
      inc %xp.to.reward $readini($zonefile(adventure), Info, ClearReward.XP)

    } 

    ; Reward XP
    var %current.xp $current.xp(%party.member.name) 

    var %level.cap $return.systemsetting(PlayerLevelCap)
    if (%level.cap = null) { var %level.cap 60 }
    if ($get.level >= %level.cap) { var %xp.to.reward 0 }

    inc %current.xp %xp.to.reward
    writeini $char(%party.member.name) exp $current.job(%party.member.name) %current.xp

    ; Add the player and the xp amount to the list to be shown 
    %winners.xp = $addtok(%winners.xp, $+ %party.member.name $+  $+ $chr(91) $+ $chr(43) $+ $bytes(%xp.to.reward,b) $+ $chr(93),46)

    ; We're done with this party member. Move onto the next (if there are any more)
    inc %current.party.member
  }


  ; Reward spoils (if there are any) -- This is given out randomly while there's rewards left to give. Some players may end up with more than one.
  ; if isfile adventure_spoils.txt = true

  ; Show the rewards.
  $display.message($translate(ShowXPRewards), global)

  ; Unset variables
  unset %winners.xp
  unset %winners.spoils

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the # of adventure actions
; still available
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.actions { return $readini($zonefile(adventure), Info, AdventureActions) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Decrease the # of adventure actions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.actions.decrease {
  ; $1 = the amount we want to decrease
  var %adventure.actions $adventure.actions
  dec %adventure.actions $1
  writeini $zonefile(adventure) Info AdventureActions %adventure.actions
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if the party has run
; out of adventure actions and ends
; the adventure if so
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.actions.checkforzero {
  if ($adventure.actions <= 0) { 
    $display.message(The party has run out of adventure actions and is booted out, global)
    $adventure.end(failure) 
    halt
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The !look command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.look {
  ; [Objects Here] [Chests here]
  ; [Trees]

  ; are we in an adventure?
  if (%adventureis != on) { $display.message($translate(NotCurrentlyInAdventure), global) | halt }

  ; Is there a battle currently ongoing? If so we can't do this yet.
  if (%battleis = on) { $display.message($translate(AdventureActionCannotBeUsedInBattle), global) | halt }

  set %show.room true

  if ($readini($zonefile(adventure), %current.room, objectlist) != $null) { var %object.list $readini($zonefile(adventure), %current.room, ObjectList) }
  if ($readini($zonefile(adventure), %current.room, chest) != $null) { %object.list = $addtok(%object.list, chest, 46) }

  ; [Name of Room]
  $display.message(12[ $+ $readini($zonefile(adventure), %current.room, name) $+  ] , global)

  ; Look Desc
  $display.message(3 $+ $readini($zonefile(adventure), %current.room, LookDesc) , global)

  ; Objects
  if (%object.list != $null) { var %object.list $clean.list(%object.list) | $display.message(10Objects:12 %object.list) }

  ; Check for trees
  var %room.tree.count $readini($zonefile(adventure), %current.room, trees)
  if (%room.tree.count > 0) { 
    $display.message(3You see5 %room.tree.count $iif(%room.tree.count > 1, trees, tree) 3here, global) 
  }

  ; Exit LIst
  var %look.exits $readini($zonefile(adventure), %current.room, ExitList)
  if (%look.exits != $null) {  %look.exits = $clean.list(%look.exits) }
  if (%look.exits = $null) { var %look.exits none that you can see }
  $display.message(10Exits:12 %look.exits)

  ; Tell the game we're done showing this room's info
  /.timerEndShowRoom 1 1 /unset %show.room
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reads a room desc if there is one
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.room.desc { return $readini($zonefile(adventure), %current.room, LookDesc) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the # of trees in the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.tree.count { 
  var %trees.in.room $readini($zonefile(adventure), %current.room, trees)
  if (%trees.in.room = $null) { return 0 }
  else { return %trees.in.room } 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The !lgo command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.move {
  ; $1 = the person trying to use the command
  ; $2 = the exit name

  ; are we in an adventure?
  if (%adventureis != on) { $display.message($translate(NotCurrentlyInAdventure), global) | halt }

  ; Is there a battle currently ongoing? If so we can't do this yet.
  if (%battleis = on) { $display.message($translate(AdventureActionCannotBeUsedInBattle), global) | halt }  

  ; Is $1 the party leader?
  if ($1 != $adventure.party.leader) { $display.message($translate(OnlyPartyLeaderCanDoAction), global) | halt }


  ; Are we still showing a room? If so, we can't go anywhere (this is to throttle it to keep people from spamming go actions)
  if (%show.room = true) { halt }

  ; Does the exit exist?
  if ($readini($zonefile(adventure), %current.room, $2) = $null) { $display.message($translate(CannotGoInThisDirection), global) | halt }

  ; Take an adventure action from their total.  If 0, boot them out with the adventure ending in failure
  $adventure.actions.decrease(1)
  $adventure.actions.checkforzero

  ; Get the room # and go to that room
  var %adventure.newroom $readini($zonefile(adventure), %current.room, $2)
  $adventure.go(%adventure.newroom)
}

adventure.go {
  ; $1 = the room number that we're moving into

  set %current.room $1

  ; Show the entering room desc 
  $display.message(7*2 $readini($zonefile(adventure), %current.room, EnterDesc), global)

  ; If the room is clear, show the !look desc automatically. 
  if ($readini($zonefile(adventure), %current.room, clear) = true) { $adventure.look | halt }

  ; If the room is not clear, check for combat.  If the combat is true, start a battle and show the battle begin message.
  if ($readini($zonefile(adventure), %current.room, combat) = true) { 
    $display.message(4* $readini($zonefile(adventure), %current.room, CombatDesc), global)

    var %battle.type $readini($zonefile(adventure), %current.room, BattleType)
    if (%battle.type = $null) { var %battle.type normal }
    $battle.generate(Normal)
    halt
  }
  else { $adventure.look | halt }

}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The !rest command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.rest {
  ; $1 = the person trying to use the command

  ; are we in an adventure?
  if (%adventureis != on) { $display.message($translate(NotCurrentlyInAdventure), global) | halt }

  ; Is there a battle currently ongoing? If so we can't do this yet.
  if (%battleis = on) { $display.message($translate(AdventureActionCannotBeUsedInBattle), global) | halt }  

  ; Is $1 the party leader?
  if ($1 != $adventure.party.leader) { $display.message($translate(OnlyPartyLeaderCanDoAction), global) | halt }

  ; Take an adventure action from their total.  If 0, boot them out with the adventure ending in failure
  $adventure.actions.decrease(1)
  $adventure.actions.checkforzero

  ; Cycle through all the party members and restore half their HP and MP. Also refill 30% of the max TP
  var %adventure.party $readini($txtfile(adventure.txt), Info, partymembersList) | var %current.party.member 1 
  while (%current.party.member <= $adventure.party.count) { 
    var %party.member.name $gettok(%adventure.party, %current.party.member, 46)

    ; HP
    var %current.hp $current.hp(%party.member.name)
    var %hp.to.refill $return_percentofvalue($resting.hp(%party.member.name), 50)
    inc %current.hp %hp.to.refill
    if (%current.hp > $resting.hp(%party.member.name)) { var %current.hp $resting.hp(%party.member.name) }
    writeini $char(%party.member.name) Battle HP %current.hp

    ; MP
    var %current.mp $current.mp(%party.member.name)
    var %mp.to.refill $return_percentofvalue($resting.mp(%party.member.name), 50)
    inc %current.mp %mp.to.refill
    if (%current.mp > $resting.mp(%party.member.name)) { var %current.mp $resting.mp(%party.member.name) }
    writeini $char(%party.member.name) Battle MP %current.mp

    ; TP
    var %current.tp $current.tp(%party.member.name)
    var %tp.to.refill $return_percentofvalue($max.tp, 30)
    inc %current.tp %tp.to.refill
    if (%current.tp > $max.tp) { var %current.tp $max.tp }
    writeini $char(%party.member.name) Battle TP %current.tp

    inc %current.party.member
  }

  ; Display the message
  $display.message($translate(PartyRests), global) 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The !warp command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.warp {
  ; $1 = the person trying to use the command

  ; are we in an adventure?
  if (%adventureis != on) { $display.message($translate(NotCurrentlyInAdventure), global) | halt }

  ; Is there a battle currently ongoing? If so we can't do this yet.
  if (%battleis = on) { $display.message($translate(AdventureActionCannotBeUsedInBattle), global) | halt }  

  ; Is $1 the party leader?
  if ($1 != $adventure.party.leader) { $display.message($translate(OnlyPartyLeaderCanDoAction), global) | halt }

  ; Display a message showing that the dungeon is ending and then end the adventure.
  $display.message($translate(AdventureWarpOut), global)

  set %adventureis off

  /.timerWarpOut 1 2 /adventure.end defeat
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The !chop tree command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.choptree {
  ; $1 = the person trying to use the command

  if (%chopping.trees = true) { halt }

  ; are we in an adventure?
  if (%adventureis != on) { $display.message($translate(NotCurrentlyInAdventure), global) | halt }

  ; Is there a battle currently ongoing? If so we can't do this yet.
  if (%battleis = on) { $display.message($translate(AdventureActionCannotBeUsedInBattle), global) | halt }  

  ; Is $1 the party leader?
  if ($1 != $adventure.party.leader) { $display.message($translate(OnlyPartyLeaderCanDoAction), global) | halt }

  ; Are there any trees in this room?
  var %tree.count $adventure.tree.count
  if (%tree.count <= 0) { $display.message($translate(NoTreesInHere), global) | halt }

  ; Does $1 have a hatchet to use?
  if ($inventory.amount($1, hatchet) = 0) { $display.message($translate(NoHatchetToUse, $1), global) | halt }

  ; Set a variable so people can't just spam the command
  var %chopping.trees true

  ; Take an adventure action from their total. 
  $adventure.actions.decrease(1)

  ; Add a log to the item pool and show the message to the channel
  var %log.list $readini($zonefile(adventure), %current.room, LogList)
  if (%log.list = $null) { var %log.list AshLog) }
  var %log.reward $gettok(%log.list, $rand(1, $numtok(%log.list, 46)), 46)
  write $txtfile(battlespoils.txt) %log.reward
  $display.message($translate(ItemAddedToItemPool, %log.reward), global)  

  ; Does the hatchet break?
  var %hatchet.breakchance $readini($dbfile(items.db), Hatchet, BreakChance)
  if (%hatchet.breakchance = $null) { var %hatchet.breakchance 65 }
  var %break.roll $roll(1d100)
  if (%break.roll <= %hatchet.breakchance) { 
    ; hatchet broke
    $inventory.decrease($1, hatchet, 1)
    $display.message($translate(HatchetBroke, $1), global)
  }

  ; decrease the # of trees
  dec %tree.count 1
  writeini $zonefile(adventure) %current.room Trees %tree.count

  ; Check to see if the party has run out of actions to use.  
  $adventure.actions.checkforzero

  /.timerUnsetTreeSlowdown 1 2 unset %chopping.trees
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interacting with objects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.object {
  ; $1 = the person
  ; $2 = the object
  ; $3 = the command

  ; are we in an adventure?
  if (%adventureis != on) { $display.message($translate(NotCurrentlyInAdventure), global) | halt }

  ; Is there a battle currently ongoing? If so we can't do this yet.
  if (%battleis = on) { $display.message($translate(AdventureActionCannotBeUsedInBattle), global) | halt }  

  ; Is $1 the party leader?
  if ($1 != $adventure.party.leader) { $display.message($translate(OnlyPartyLeaderCanDoAction), global) | halt }

  ; Does the object exist?
  if ($2 = chest) { $adventure.chest($1, $3) }
  else { 
    var %room.objects $readini($zonefile(adventure), %current.room, ObjectList)
    if ($istok(%room.objects,$2,46) = $false) {  $display.message($translate(DoNotSeeThatObject, $1), global) | halt }
  }

  ; Can that command be used with the object?
  var %object.command $2 $+ . $+ $3

  if ($readini($zonefile(adventure), n, %current.room, %object.command) = $null) { $display.message($translate(ThisActionHasNoEffect), global) | halt }

  ; remove 1 adventure action
  $adventure.actions.decrease(1)

  ; If adventure actions = 0, boot us out.
  $adventure.actions.checkforzero

  ; Perform the action
  $readini($zonefile(adventure), p, %current.room, %object.command)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interacting with chests
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.chest {
  ; $1 = the party leader
  ; $3 = action

  if ($3 != open) { error | halt }

  ; Get a list of items from the chest

  ; Pick one at random

  ; Add item to item pool to be given at the end of the adventure

  ; Erase the chest from the room
  remini $zonefile(adventure) %current.room Chest

  ; remove 1 adventure action
  $adventure.actions.decrease(1)

  ; If adventure actions = 0, boot us out.
  $adventure.actions.checkforzero
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; counts party members
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.party.count { return $numtok($readini($txtfile(adventure.txt), info, partymembersList), 46) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; shows the current adventure party
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.party.show { 

  var %curparty $readini($txtfile(adventure.txt), Info, partymembersList)
  if (%curparty = $null) {  $display.message($translate(NoAdventureCurrently), private) | halt }

  var %curparty $clean.list(%curparty) 

  $display.message($translate(ShowParty, %curparty), global)
  $display.message($translate(CurrentPartyLeader, $adventure.party.leader), global)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; returns minimum # of players
; for this adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.minimumplayers { return $readini($zonefile(adventure), Info, MinimumPlayers) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; returns minimum iLevel 
; for this adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.minimumiLevel { 
  var %iLevel $readini($zonefile(adventure), info, iLevel) 
  if (%iLevel = $null) { return 0 }
  else { return $readini($zonefile(adventure), Info, iLevel) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; returns the party leader
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.party.leader {
  var %party.list $readini($txtfile(adventure.txt), Info, PartyMembersList)
  var %party.leader $gettok(%party.list, 1, 46)

  ; to do: make it so if the party leader is idle long enough then everyone is considered a party leader (thus anyone can use commands)
  ; if the party leader is idle for too long and he/she is the only one in battle then just end the adventure in failure.

  return %party.leader
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; returns the party leader
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.alreadyinparty.check {
  var %curbat $readini($txtfile(adventure.txt), Info, partymembersList)
  if ($istok(%curbat,$1,46) = $true) { return true } 
  else { return false } 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; adds a player into the party
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.party.addmember {

  ; Add the person into the adventure.
  var %curbat $readini($txtfile(adventure.txt), Info, PartyMembersList)
  %curbat = $addtok(%curbat,$1,46)
  writeini $txtfile(adventure.txt) Info PartyMembersList %curbat

  var %battleplayers $readini($txtfile(adventure.txt), BattleInfo, Players)
  if (%battleplayers = $null) { var %battleplayers 0 }
  inc %battleplayers 1 
  writeini $txtfile(adventure.txt) BattleInfo Players %battleplayers

  var %current.player.levels $readini($txtfile(adventure.txt), BattleInfo, PlayerLevels)
  if (%current.player.levels = $null) { var %current.player.levels 0 }
  var %player.level $get.level($1)
  inc %current.player.levels %player.level
  writeini $txtfile(adventure.txt) BattleInfo PlayerLevels %current.player.levels

  var %average.levels $round($calc(%current.player.levels / $readini($txtfile(adventure.txt), BattleInfo, Players)),0)
  writeini $txtfile(adventure.txt) BattleInfo AverageLevel %average.levels

  var %highest.level $readini($txtfile(adventure.txt), BattleInfo, HighestLevel)
  if (%highest.level = $null) { var %highest.level 0 }
  if (%player.level > %highest.level) { writeini $txtfile(adventure.txt) BattleInfo HighestLevel %player.level } 

  ; Restore player's HP, MP and TP
  $fulls($1, yes)
}
