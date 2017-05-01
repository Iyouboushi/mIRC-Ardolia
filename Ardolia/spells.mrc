;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; spells.mrc
;;;; Last updated: 04/30/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file is seriously unfinished
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spell Commands and code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 3:ACTION:casts * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $5)
  $spell_cmd($nick , $3 , %attack.target, $7) | halt 
} 
ON 3:TEXT:!cast * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $4)
  $spell_cmd($nick , $2 , %attack.target, $5) | halt 
} 
ON 3:TEXT:!magic * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $4)
  $spell_cmd($nick , $2 , %attack.target, $5) | halt 
} 
ON 50:TEXT:*casts * on *:*:{ 
  if ($1 = uses) { halt }
  if ($3 = item) { halt }
  if ($5 != on) { halt }

  $partial.name.match($1, $6)
  $spell_cmd($1 , $4,  %attack.target) 
  halt 
}


alias spell_cmd {
  ; $1 = user
  ; $2 = Spell cast
  ; $3 = target

  ; Can this spell be cast outside of battle?
  if ($readini($dbfile(spells.db), $2, CanUseOutsideBattle) != true) {  
    $no.turn.check($1,admin)
  }

  ; Are we in an adventure?
  if (%adventureis = off) { halt }


  ; do more stuff here


  ; Write to the file that we just used this ability
  writeini $char($1) cooldowns $2 %true.turn



}
