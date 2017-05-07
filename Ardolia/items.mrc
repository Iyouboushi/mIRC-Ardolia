;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; items.mrc
;;;; Last updated: 05/05/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Counts how much of an item
; you have
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!count*:#: {  
  if ($3 = $null) { $item.countcmd($nick, $2, public) }
  if ($3 != $null) { $checkchar($2) | $item.countcmd($2, $3, public) }
}
on 2:TEXT:!count*:?: {  
  if ($3 = $null) { $item.countcmd($nick, $2, private) }
  if ($3 != $null) { $checkchar($2) | $item.countcmd($2, $3, private) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Alias for counting the # of an item
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias item.countcmd {
  if (($3 = public) || ($3 = $null)) { 
    if ($inventory.amount($1, $2) = 0) { $display.message($translate(DoNotHaveThisItem, $1), private) | halt }
    else { $display.message($translate(CountItem, $1, $2), private) }
  }
  if ($3 = private) {
    if ($inventory.amount($1, $2) = 0) { $display.private.message($translate(DoNotHaveThisItem, $1)) | halt }
    else { $display.private.message($translate(CountItem, $1, $2)) }

  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Alias for eating food
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias item.eatfood {
  ; are we in an adventure?
  if (%adventureis != on) { $display.message($translate(NotCurrentlyInAdventure), global) | halt }

  ; Is there a battle currently ongoing? If so we can't do this yet.
  if (%battleis = on) { $display.message($translate(AdventureActionCannotBeUsedInBattle), global) | halt } 

  ; Has a food item already been eaten?
  if ($return.foodeffect($1) != none) { $display.message($translate(AlreadyEaten, $1), global) | halt }

  ; Does this food exist?
  if ($readini($dbfile(items.db), $2, type) != food) { $display.message($translate(ThisFoodItemDoesNotExist, $2), global) | halt  }

  ; Does the player even have this item?
  if ($inventory.amount($1, $2) = 0) { $display.message($translate(DoNotHaveThisItem, $1), global) | halt }

  ; Eat the food
  writeini $char($1) Battle Food $2
  $inventory.decrease($1, $2, 1)

  ; Show desc
  var %user $get_chr_name($1)
  if ($readini($dbfile(items.db), $2, UseDesc) = $null) {  $display.message($translate(FoodEaten, $1, $2), global) } 
}
