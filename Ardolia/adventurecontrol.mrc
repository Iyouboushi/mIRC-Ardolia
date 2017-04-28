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
on 2:TEXT:!start adventure *:#: { $dungeon.start($nick, $3)) }

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
