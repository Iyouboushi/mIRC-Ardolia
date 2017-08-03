;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; adventure.als
;;;; Last updated: 08/02/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lists all the dungeons/adventures
; that are available to the player
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.list {
  ; Check the filename and see if the dungeon is available (pre-req required or hoilday dungeon)

  var %zone.name $remove($2,.zone)
  var %zone.name $nopath(%zone.name)
  var %show.zone true

  ; If it's the current adventure or template, return
  if (%zone.name = adventure) { return }
  if (%zone.name = template) { return }

  ; Check for month. If not the right month, return
  var %zone.month $readini($zonefile(%zone.name), Info, Month)
  if (%zone.month = $null) { var %zone.month $left($adate,2) }
  if ($left($adate, 2) != %zone.month) { return }

  ;  check for a specific day
  var %zone.day $readini($zonefile(%zone.name), Info, Day)
  if (%zone.day = $null) { var %zone.day $right($left($adate,5),2) }
  if (($right($left($adate,5),2) != %zone.day) && ($left($fulldate, 3) != %zone.day)) { return }

  ; Check for pre-req.
  var %zone.prereq $readini($zonefile(%zone.name), Info, Prereq)
  if ((%zone.prereq != $null) && ($readini($char($1), AdventuresCleared, %zone.prereq) != true)) { return }

  ; Check for iLevel requirement
  var %zone.iLevel $readini($zonefile(%zone.name), Info, iLevel)
  if (%zone.iLevel = $null) { var %zone.iLevel 1 }
  if ($character.ilevel($1) < %zone.iLevel) { return }

  ; Write the line that will be shown
  if (%show.zone = true) {

    var %adventure.name $readini($zonefile(%zone.name), Info, Name)
    var %zone.minplayers $readini($zonefile(%zone.name), Info, MinimumPlayers)
    var %zone.levelrange $readini($zonefile(%zone.name), Info, LevelRange)

    write $txtfile(adventurelist_ $+ $1 $+ .txt) 3 $+ %adventure.name  $+ $chr(91) $+ Adventure Code2 %zone.name $+ 3 $+ $chr(93) $chr(91) $+ Min $chr(35) of Players:2 %zone.minplayers $+ 3 $+ $chr(93) $chr(91) $+ Recommended Level2 %zone.levelrange $+ 3 $+ $chr(93)  $chr(91) $+ Min iLevel Required:2 %zone.iLevel $+ 3 $+ $chr(93)
  }

  unset %zone.name

}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays the adventure list
; to the player
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.list.display {
  ; $1 = the person we're displaying to
  ; $2 = the text file we're reading from

  if (($lines($txtfile($2)) != $null) && ($lines($txtfile($2)) > 0)) { 

    write $txtfile($2) 3To start any of these adventures use !start adventure 2adventurecode

    if ($readini(system.dat, system, botType) = IRC) {  /.play $1 $txtfile($2) }
    if ($readini(system.dat, system, botType) = TWITCH) {  /.play %battlechan $txtfile($2) }
    if ($readini(system.dat, system, botType) = DCCchat) { /.play $1 $2 }

    /.remove $txtfile($2)
    /.timerReturnFromStatus $+ $rand(a,z) 1 2 /return 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tells the game that the player
; wants to start an adventure/party
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.start {
  ; $1 =  the person starting the adventure (i.e. party leader)
  ; $2 = the name of the dungeon/adventure being started 

  ; Is there currently an adventure already in progress?
  if ($readini($zonefile(adventure), info, Name) != $null) { $display.message($translate(Can'tStartAdventure), global) | halt }

  ; Can the party leader lead another party so soon?
  ; If more than 1 person is logged into the game there is a 5 minute wait for players to lead their own parties
  ; Note that they can still join other playeres' parties while waiting.
  var %voices $nick(%battlechan,0,v)

  if (%voices > 1) { 
    var %last.adventure.lead $readini($char($1), Info, LastAdventure)
    if (%last.adventure.lead != $null) { 
      var %party.lead.time 300 |  var %current.time $ctime
      var %time.difference $calc($ctime - $ctime(%last.adventure.lead))

      if (%time.difference < %party.lead.time) { 
        var %time.left $duration($calc(%party.lead.time - %time.difference))

        $display.message($translate(Can'tStartAnotherAdventure, $1, %time.left),global)
        halt
      }
    }
  }

  ; Does the adventure file exist?
  if ($isfile($zonefile($2)) = $false) { $display.message($translate(NoAdventureByThatName), global) | halt }

  ; Is this dungeon only available on a certain month (i.e. holiday dungeons)?   If so, is it the right month?
  var %zone.month $readini($zonefile($2), Info, Month)
  if (%zone.month = $null) { var %zone.month $left($adate,2) }
  if ($left($adate, 2) != %zone.month) { $display.message($translate(NotRightMonthToStart, $1), private) | halt }

  ; Is this dungeon only available on a certain day of a month?   If so, is it the right day?
  var %zone.day $readini($zonefile($2), Info, Day)
  if (%zone.day = $null) { var %zone.day $right($left($adate,5),2) }
  if (($right($left($adate,5),2) != %zone.day) && ($left($fulldate, 3) != %zone.day)) { $display.message($translate(NotRightDayToStart, $1), private) | halt }

  ; Is there a pre-req that needs to be done before this one may be started?
  var %zone.prereq $readini($zonefile($2), Info, Prereq)
  if ((%zone.prereq != $null) && ($readini($char($1), AdventuresCleared, %zone.prereq) != true)) { $display.message($translate(Haven'tDonePreReqToStart, $1, %zone.prereq), private) | halt }

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

  ; Is there a pre-req that needs to be done before this one may be started?
  var %zone.prereq $readini($zonefile(adventure), Info, Prereq)
  if ((%zone.prereq != $null) && ($readini($char($1), AdventuresCleared, %zone.prereq) != true)) { $display.message($translate(Haven'tDonePreReqToEnter, $1, %zone.prereq), private) | halt }


  $adventure.party.addmember($1)

  writeini $char($1) info SkippedTurns 0

  $display.message($translate(EnteredTheAdventure, $1), global)

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

  ; Start the anti-idle timer
  $adventure.idleTimer(start)

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

  ; Write the start time to the party leader. 
  writeini $char($adventure.party.leader) info LastAdventure $fulldate

  ; calculate total battle duration
  var %total.adventure.duration $adventure.calculateduration

  if ($1 = victory) {  
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
  unset %clear.flag
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
  $adventure.idleTimer(stop)
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
  unset %winners.xp
  unset %winners.spoils

  ; Cycle through the party
  var %adventure.party $readini($txtfile(adventure.txt), Info, partymembersList) | var %current.party.member 1 
  while (%current.party.member <= $adventure.party.count) { 
    var %party.member.name $gettok(%adventure.party, %current.party.member, 46)

    ; Increase that this party member has been in the adventure
    $miscstats(%party.member.name, add, TotalAdventures, 1)

    var %xp.to.reward $readini($txtfile(adventure.txt), Rewards, XP)
    if (%xp.to.reward = $null) { var %xp.to.reward 0 }

    var %money.to.reward $readini($txtfile(adventure.txt), Rewards, money)
    if (%money.to.reward = $null) { var %money.to.reward 0 }

    if ($1 = victory) { 

      ; Write that we've cleared this adventure
      writeini $char(%party.member.name) AdventuresCleared $readini($zonefile(adventure), Info, OriginalFile) true 

      ; Give some fame
      var %fame.to.reward $readini($zonefile(adventure), Info, FameRewarded)
      inc %fame.to.reward $current.fame(%party.member.name)
      writeini $char(%party.member.name) Info Fame %fame.to.reward

      ; Give a random clear reward
      var %original.adventure.name $readini($zonefile(adventure), Info, OriginalFile)
      if (%original.adventure.name != $null) { 
        var %reward.file $readini($zonefile(adventure), Info, ClearReward.list)
        if ($isfile($lstfile(%reward.file)) = $true) { 
          var %random.reward $read($lstfile(%reward.file), $rand(1,$lines($lstfile(%reward.file))))

          ; give it to the player
          $inventory.add(%party.member.name, %random.reward, $calc($inventory.amount(%party.member.name %random.reward) + 1))

          ; find out what kind of item it is so we can do a rarity color on it
          if ($readini($dbfile(items.db), %random.reward, Itemlevel) != $null) { var  %reward.color.check $rarity.color.check(%random.reward, item) }
          if ($readini($dbfile(equipment.db), %random.reward, Itemlevel) != $null) { var  %reward.color.check $rarity.color.check(%random.reward, armor) }
          if ($readini($dbfile(weapons.db), %random.reward, Itemlevel) != $null) { var  %reward.color.check $rarity.color.check(%random.reward, weapon) }

          ; add the spoil to the list of spoils
          var %display.reward.to.add  $+ %party.member.name -> %reward.color.check $+ %random.reward $+ 3

          %winners.clearrewards = $addtok(%winners.clearrewards, %display.reward.to.add, 46)
        }

      }

      ; Add some bonus xp for clearing the adventure
      inc %xp.to.reward $readini($zonefile(adventure), Info, ClearReward.XP)

    } 

    ; Reward XP if it's not 0

    if ((%xp.to.reward != $null) && (%xp.to.reward > 0)) { 
      var %current.xp $current.xp(%party.member.name) 

      var %level.cap $return.systemsetting(PlayerLevelCap)
      if (%level.cap = null) { var %level.cap 60 }
      if ($get.level >= %level.cap) { var %xp.to.reward 0 }

      inc %current.xp %xp.to.reward
      writeini $char(%party.member.name) exp $current.job(%party.member.name) %current.xp

      ; Increase the total amount of xp the player has earned
      $miscstats(%party.member.name, add, TotalXPGained, %xp.to.reward)

      ; Add the player and the xp amount to the list to be shown 
      %winners.xp = $addtok(%winners.xp, $+ %party.member.name $+  $+ $chr(91) $+ $chr(43) $+ $bytes(%xp.to.reward,b) $+ $chr(93),46)
    }

    ; We're done with this party member. Move onto the next (if there are any more)
    inc %current.party.member
  }

  ; Reward money if it's not 0
  if ((%money.to.reward != $null) && (%money.to.reward > 0)) { 
    var %current.money $currency.amount(%party.member.name, money)
    inc %current.money %money.to.reward
    writeini $char(%party.member.name) Currencies Money %current.money

    ; Increase the total amount of money the player has earned
    $miscstats(%party.member.name, add, TotalMoneyGained, %money.to.reward)
  }

  ; Reward spoils (if there are any) -- This is given out randomly while there's rewards left to give. Some players may end up with more than one.
  if ($isfile($txtfile(battlespoils.txt)) = $true) {
    var %spoils.to.reward $lines($txtfile(battlespoils.txt))
    var %current.spoil.number 1

    while (%current.spoil.number <= %spoils.to.reward) {
      var %spoil.name $read($txtfile(battlespoils.txt), %current.spoil.number)
      var %random.partymember $gettok(%adventure.party, $rand(1, $numtok(%adventure.party,46)), 46)
      var %spoil.reward %spoil.name ->  $+ %random.partymember $+ 
      if ($istok(%winners.spoils, %spoil.reward, 46) = $true) { %winners.spoils = %winners.spoils $+ . %spoil.reward }
      else { %winners.spoils = $addtok(%winners.spoils, %spoil.reward, 46) } 

      $inventory.add(%random.partymember, %spoil.name, $calc($inventory.amount(%random.partymember, %spoil.name) + 1))

      inc %current.spoil.number
    }
    %winners.spoils = $clean.list(%winners.spoils)
  }

  ; Show the rewards.
  if (%winners.xp != $null) { %winners.xp = $clean.list(%winners.xp) | $display.message($translate(ShowXPRewards), global) }
  if (%winners.spoils != $null) {  $display.message($translate(ShowSpoilRewards), global) }

  if ($1 = victory) { 
    if (%winners.clearrewards != $null) { 
      %winners.clearrewards = $clean.list(%winners.clearrewards) | $display.message($translate(ShowClearRewards), global) 
    }
  }

  ; Unset variables
  unset %winners.xp
  unset %winners.spoils
  unset %winners.clearrewards

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

  $adventure.idleTimer(start)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The !look command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.look {
  ; [Objects Here] [Chests here]
  ; [Trees]

  unset %object.list

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
; Returns the clear status of a room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
room.clear.status {
  ; $1 = the room #
  if ($readini($zonefile(adventure), $1, Clear) = $null) { return false }
  else { return $readini($zonefile(adventure), $1, Clear) }
}

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
  if (($1 != $adventure.party.leader) && ($adventure.party.leader != anyone)) { $display.message($translate(OnlyPartyLeaderCanDoAction), global) | halt }

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

  ; Stop the idle timer so it doesn't fire when we're in the middle of this action
  $adventure.idleTimer(stop)

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

  ; Stop the idle timer so it doesn't fire when we're in the middle of this action
  $adventure.idleTimer(stop)

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

  unset %log.list | unset %log.reward

  ; Increase the total number of times this player has chopped a tree down
  $miscstats($1, add, TreesChopped, 1)

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
  if ($2 = chest) { $adventure.chest($1, $2, $3) }
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

  if (%opening.chest = true) { halt }
  if ($readini($zonefile(adventure), %current.room, Chest) != true) { $display.message($translate(NoChestHere, $1), global) | halt }
  if ($3 != open) { $display.message($translate(ThisActionHasNoEffect), global) | halt }

  ; Get a list of items from the chest
  var %chest.file $readini($zonefile(adventure), %current.room, Chest.List)
  if ($isfile($lstfile(%chest.file)) = $false) { $display.message(4The chest's file is missing! Have a bot owner fix this., global) | halt }

  ; Set a variable so it can't be spammed
  set %opening.chest true

  ; Stop the idle timer so it doesn't fire when we're in the middle of this action
  $adventure.idleTimer(stop)

  ; Pick one at random
  var %chest.item $read($lstfile(%chest.file), $rand(1,$lines($lstfile(%chest.file))))

  ; Add item to item pool to be given at the end of the adventure
  write $txtfile(battlespoils.txt) %chest.item

  ; show what item was in the chest
  $display.message($translate(ChestItemAddedToItemPool, $1, %chest.item), global)  

  ; Erase the chest from the room
  remini $zonefile(adventure) %current.room Chest
  writeini $zonefile(adventure) %current.room Chest.Open true

  unset %object.list

  ; Increase the total number of times this player has opened a chest
  $miscstats($1, add, ChestsOpened, 1)

  ; remove 1 adventure action
  $adventure.actions.decrease(1)

  ; If adventure actions = 0, boot us out.
  $adventure.actions.checkforzero

  /.timerOpeningChest 1 2 unset %opening.chest
  halt
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

  ; Show how many tanks, dps and healers we have
  var %tanks $readini($txtfile(adventure.txt), BattleInfo, Tank)
  var %healers  $readini($txtfile(adventure.txt), BattleInfo, Healer)
  var %dps  $readini($txtfile(adventure.txt), BattleInfo, DPS)

  if (%tanks = $null) { var %tanks 0 }
  if (%healers = $null) { var %healers 0 }
  if (%dps = $null) { var %dps 0 }

  $display.message($translate(ShowPartyJobs, %tanks, %healers, %dps), global)

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

  ; If the party leader has lost control due to being idle, then anyone can do any command.

  if ($readini($txtfile(adventure.txt), Info, PartyLeaderOpen) = true) { return anyone }
  else { return %party.leader }
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

  writeini $char($1) Info NeedsFulls yes

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

  writeini $char($1) Info NeedsFulls yes

  ; Get the player's job role and increase a tally
  var %job.role $readini($jobfile($current.job($1)), BasicInfo, Role)

  var %current.role.count $readini($txtfile(adventure.txt), BattleInfo, %job.role)
  if (%current.role.count = $null) { var %current.role.count 0 }
  inc %current.role.count 1
  writeini $txtfile(adventure.txt) BattleInfo %job.role %current.role.count


}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; controls the idle timer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.idleTimer {
  ; $1 = start or stop

  if (%adventureis = off) { halt }
  if ($return.systemsetting(EnablePartyIdleTimer) = false) { return }

  if ($1 = stop) { /.timerPartyLeaderIdle off }
  if ($1 = start) { 
    ; Get the time party leaders can idle in adventures
    var %partyIdleTime $return.systemsetting(PartyIdleTime)
    if (%partyIdleTime = null) { var %partyIdleTime 180 }
    /.timerPartyLeaderIdle 1 %partyIdleTime /adventure.removepartyleader
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs the anti-idle command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adventure.removepartyleader {

  if (%adventureis = off) { halt }

  if ($adventure.party.count = 1) { 
    ; The adventure ends because the party leader was idle.
    $display.message($translate(AdventureEndDueToIdle), gloal)
    $adventure.end(failure)
    halt    
  }

  ; There's more than one player, so let's see if the party leader has already been removed
  var %partyleaderopen $readini($txtfile(adventure.txt), Info, PartyLeaderOpen)

  if (%partyleaderopen != true) { 
    $display.message($translate(PartyLeaderOpen), global)
    writeini $txtfile(adventure.txt) Info PartyLeaderOpen true
    $adventure.idleTimer(start)
  }

  if (%partyleaderopen = true) { 
    ; Cut the current stamina by half of max stamina
    var %stamina.to.decrease $readini($zonefile($readini($zonefile(adventure), Info, OriginalFile)), Info, AdventureActions)
    var %stamina.to.decrease $round($calc(%stamina.to.decrease / 2), 0)
    $adventure.actions.decrease(%stamina.to.decrease)

    ; Display a message that stamina has been cut.
    $display.message($translate(PartyStaminaCutDueToIdle, %stamina.to.decrease), global)

    ; If stamina has run out, end. 
    $adventure.actions.checkforzero
  }

}
