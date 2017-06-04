;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; adventurecontrol.mrc
;;;; Last updated: 06/03/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this file contains the commands and code for the adventures (dungeons)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get a list of dungeons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!adventure list:#: { 
  var %adventurelist.file adventurelist_ $+ $nick $+ .txt

  ; Remove any previous list that may have been missed
  /.remove $txtfile(%adventurelist.file)

  ; Cycle through
  .echo -q $findfile( $zone_path , *.zone, 0 , 0, adventure.list $nick $1-)

  ; Display
  if (($lines($txtfile(%adventurelist.file)) != $null) && ($lines($txtfile(%adventurelist.file)) > 0)) { 
    /.timerThrottle $+ $rand(a,z) $+ $rand(1,1000) $+ $rand(a,z) 1 1 /adventure.list.display $nick %adventurelist.file
  } 
  if (($lines($txtfile(%adventurelist.file)) = $null) || ($lines($txtfile(%adventurelist.file)) = 0)) { $display.private.message($translate(NoAdventuresAvailable)) | halt }

}
on 2:TEXT:!adventure list:?: {
  var %adventurelist.file adventurelist_ $+ $nick $+ .txt

  ; Remove any previous list that may have been missed
  /.remove $txtfile(%adventurelist.file)

  ; Cycle through
  .echo -q $findfile( $zone_path , *.zone, 0 , 0, adventure.list $nick $1-)

  ; Display
  if (($lines($txtfile(%adventurelist.file)) != $null) && ($lines($txtfile(%adventurelist.file)) > 0)) { 
    /.timerThrottle $+ $rand(a,z) $+ $rand(1,1000) $+ $rand(a,z) 1 1 /adventure.list.display $nick %adventurelist.file 
  }

  if (($lines($txtfile(%adventurelist.file)) = $null) || ($lines($txtfile(%adventurelist.file)) = 0)) { $display.private.message($translate(NoAdventuresAvailable)) | halt }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start an adventure to a dungeon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!dungeon start *:#: { $adventure.start($nick, $3)) }
on 2:TEXT:!adventure start *:#: { $adventure.start($nick, $3)) }
on 2:TEXT:!start adventure *:#: { $adventure.start($nick, $3)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Join the party to go on an adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!enter:#: { $adventure.join($nick, $3)) }
on 2:TEXT:!party join:#: { $adventure.join($nick, $3)) }
ON 50:TEXT:*enters the adventure*:#:  { $adventure.join($1) }
ON 50:TEXT:*joins the party:#:  { $adventure.join($1) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shows who's in the party
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!party:#: { $adventure.party.show }
on 2:TEXT:!party list:#: { $adventure.party.show }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays the room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!look*:#: {
  if ($2 = $null) { 
    if ((%adventureis = on) && (%battleis != on)) { $adventure.look }
    if ((%adventureis = on) && (%battleis = on)) { $battle.list }
    if (%adventureis = off) { $lookat($nick, channel) }
  }
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
; Check party stamina
; aka adventure actions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!stamina:#: {
  if (%adventureis = on) { $display.message($translate(AdventureActionsMessage), global) }
  else { $display.message($translate(NotCurrentlyInAdventure), global) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Eats food
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!eat *:#: { $item.eatfood($nick, $2) }
