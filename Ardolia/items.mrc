;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; items.mrc
;;;; Last updated: 05/09/17
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
; The !use command for using items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 3:TEXT:!use*:*: {  unset %real.name | unset %enemy | $set_chr_name($nick)
  $no.turn.check($nick, return)

  if ($person_in_mech($nick) = true) { $display.message($translate(Can'tDoThatInMech, $nick), private) | halt }

  if ($4 = $null) { 
    if ($readini($dbfile(items.db), $2, type) = tormentreward) { $uses_item($nick, $2, on, $nick, $3) }
    else { $uses_item($nick, $2, on, $nick) }
  }
  else {  
    $partial.name.match($nick, $4)
    $uses_item($nick, $2, $3, %attack.target)
  }
}

ON 50:TEXT:*uses item * on *:*:{  $set_chr_name($1)
  if ($1 = uses) { halt }
  if ($5 != on) { halt }

  if ($person_in_mech($1) = true) { $display.message($translate(Can'tDoThatInMech, $1), private) | halt }

  $partial.name.match($1, $6)
  $uses_item($1, $4, $5, %attack.target)
}

ON 3:TEXT:*uses item * on *:*:{  $set_chr_name($1)
  if ($1 = uses) { halt }
  if ($5 != on) { halt }

  if ($readini($char($1), info, flag) = monster) { halt }
  $controlcommand.check($nick, $1)
  if ($return.systemsetting(AllowPlayerAccessCmds) = false) { $display.message($translate(PlayerAccessCmdsOff), private) | halt }
  if ($char.seeninaweek($1) = false) { $display.message($translate(PlayerAccessOffDueToLogin), private) | halt }

  if ($person_in_mech($1) = true) { $display.message($translate(Can'tDoThatInMech, $1), private) | halt }

  if ($readini($char($1), info, clone) = yes) {  $display.message($translate(CloneCannotUseItem), private) | halt }

  $partial.name.match($1, $6)
  $uses_item($1, $4, $5, %attack.target)
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Alias for using items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias uses_item {
  ; $1 = the person using the item
  ; $2 = item name
  ; $4 = the person we're using the item on

  ; are we in an adventure?
  if (%adventureis != on) { $display.message($translate(NotCurrentlyInAdventure), global) | halt }

  var %item.type $readini($dbfile(items.db), $2, type)

  ; If this item is a food type then we need to try to eat it.
  if (%item.type = food) { $item.eatfood($1, $2) | halt }

  ; If this item is an adventure item then it cannot be used like this
  if (%item.type = adventure) { $display.message($translate(ItemUsedForAdventures), private) | halt }

  ; Does this item exist?
  if ($readini($dbfile(items.db), $2, type) = $null) { $display.message($translate(ThisItemDoesNotExist, $2), global) | halt  }

  ; Does the player even have this item?
  if ($inventory.amount($1, $2) = 0) { $display.message($translate(DoNotHaveThisItem, $1), global) | halt }

  ; Is a battle ongoing?  If not, we can't use items
  if (%battleis != on) { $display.message($translate(CanOnlyUseItemsInBattle, $1), global) | halt }

  ; If the item type is anything other than revive then we need a valid target 
  if (%item.type != revive)  {
    if (($3 != on) || ($3 = $null)) {  $display.message($translate(ItemUseCommandError), private) | halt }
    if ($4 = me) {  $display.message($translate(MustSpecifyName), private) | halt }
    if ($readini($char($4), battle, status) = dead) { $display.message($translate(CannotUseItemOnDead), private) | halt }
    $checkchar($4) 
    if (%battleis = on) { $person_in_battle($4) }
  }

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($4), info, flag)

  if ((((%item.type = misc) || (%item.type = crafting) || (%item.type = crystal) || (%item.type = gem)))) { $display.message($translate(ItemIsUsedForCrafting), private) | halt }

  if (%item.type = revive) { $item.revive($1, $2, $4) }
  if (%item.type = heal) { $item.heal($1, $2, $4) } 
  if (%item.type = restoreMP) { $item.restoreMP($1, $2, $4) } 

  ; The item has been used, let's decrease the amount the player has
  $inventory.decrease($1, $2, 1)

  ; Move onto the next turn.
  if (%battleis = on)  { $check_for_double_turn($1) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Alias for revive type items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias item.revive {
  ; $1 = the user
  ; $2 = the item name
  ; $3 = the target

  ; Is the target dead?
  if ($readini($char($4), battle, status) != dead) { $display.message($translate(CannotUseItemOnLiving), private) | halt }
  if ($flag($3) = monster) {  $display.message($translate(ItemCanOnlyBeUsedOnPlayers),private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackWhileUnconcious), private)  | unset %real.name | halt }

  var %clone.flag $readini($char($3), info, clone)
  var %doppel.flag $readini($char($3), info, Doppelganger)
  if ((%clone.flag = true) || (%doppel.flag = true)) { $display.message($translate(ItemCanOnlyBeUsedOnPlayers),private) | halt }

  ; Is the cooldown empty?
  var %revive.item.cooldown $readini($char($1), CoolDowns, ReviveItem)
  if (%healing.item.cooldown != $null) { $display.message($translate(CannotUseItemsAgainSoFast, $1, %revive.item.cooldown), private) | halt }

  ; Decrease the action points
  $action.points($1, remove, 2)

  $set_chr_name($3) | var %enemy %real.name | $set_chr_name($1) 
  $display.message(3 $+ $get_chr_name($1)  $+ $readini($dbfile(items.db), $2, UseDesc), battle)

  var %revive.amount $readini($dbfile(items.db), $2, ReviveAmount)
  $character.revive($4, %revive.amount)

  ; Write the item cooldown
  writeini $char($1) Cooldowns ReviveItem $readini($dbfile(items.db), $2, CoolDown)

  unset %enemy | unset %real.name

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Alias for healing type items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias item.heal {
  ; Is the target dead?
  if ($readini($char($4), battle, status) = dead) { $display.message($translate(CannotUseItemOnDead), private) | halt }
  if ($flag($3) = monster) {  $display.message($translate(ItemCanOnlyBeUsedOnPlayers),private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackWhileUnconcious), private)  | unset %real.name | halt }

  if ($current.hp($3) >= $resting.hp($3)) { $display.message($translate(TargetDoesNotNeedHealing, $3), battle) | halt }

  ; Is the cooldown empty?
  var %healing.item.cooldown $readini($char($1), CoolDowns, HealingItem)
  if (%healing.item.cooldown != $null) { $display.message($translate(CannotUseItemsAgainSoFast, $1, %healing.item.cooldown), private) | halt }

  ; Decrease the action points
  $action.points($1, remove, 2)

  $set_chr_name($3) | var %enemy %real.name | $set_chr_name($1) 
  $display.message(3 $+ $get_chr_name($1)  $+ $readini($dbfile(items.db), $2, UseDesc), battle)

  var %restore.amount $readini($dbfile(items.db), $2, HealAmount)
  if (%restore.amount = $null) { var %restore.amount 1 }

  ; restore the HP
  var %current.hp $current.hp($3)
  inc %current.hp %restore.amount
  if (%current.hp > $resting.hp($3)) { var %current.hp $resting.hp($3) } 
  writeini $char($3) Battle HP %current.hp

  ; Write the item cooldown
  writeini $char($1) Cooldowns HealingItem $readini($dbfile(items.db), $2, CoolDown)

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Alias for restoring MP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
item.restoreMP {
  ; Is the target dead?
  if ($readini($char($4), battle, status) = dead) { $display.message($translate(CannotUseItemOnDead), private) | halt }
  if ($flag($3) = monster) {  $display.message($translate(ItemCanOnlyBeUsedOnPlayers),private) | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackWhileUnconcious), private)  | unset %real.name | halt }

  if ($current.mp($3) >= $resting.mp($3)) { $display.message($translate(TargetDoesNotNeedMPHealing, $3), battle) | halt }

  ; Is the cooldown empty?
  var %healing.item.cooldown $readini($char($1), CoolDowns, MPrestoreItem)
  if (%healing.item.cooldown != $null) { $display.message($translate(CannotUseItemsAgainSoFast, $1, %healing.item.cooldown), private) | halt }

  ; Decrease the action points
  $action.points($1, remove, 2)

  $set_chr_name($3) | var %enemy %real.name | $set_chr_name($1) 
  $display.message(3 $+ $get_chr_name($1)  $+ $readini($dbfile(items.db), $2, UseDesc), battle)

  var %restore.amount $readini($dbfile(items.db), $2, HealAmount)
  if (%restore.amount = $null) { var %restore.amount 1 }

  ; restore the MP
  var %current.mp $current.mp($3)
  inc %current.mp %restore.amount
  if (%current.mp > $resting.mp($3)) { var %current.mp $resting.mp($3) } 
  writeini $char($3) Battle MP %current.mp

  ; Write the item cooldown
  writeini $char($1) Cooldowns MPrestoreitem $readini($dbfile(items.db), $2, CoolDown)

  return
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Decreases the item cooldowns
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias item.cooldowns.decrease {
  var %healing.item.cooldown $readini($char($1), CoolDowns, HealingItem)
  var %mphealing.item.cooldown $readini($char($1), CoolDowns, MPrestoreItem)
  var %revive.item.cooldown $readini($char($1), CoolDowns, ReviveItem)

  if (%healing.item.cooldown != $null) { 
    dec %healing.item.cooldown 1
    if (%healing.item.cooldown = 0) { remini $char($1) CoolDowns HealingItem }
    else { writeini $char($1) CoolDowns HealingItem %healing.item.cooldown }
  }

  if (%mphealing.item.cooldown != $null) { 
    dec %mphealing.item.cooldown 1
    if (%mphealing.item.cooldown = 0) { remini $char($1) CoolDowns MPrestoreitem }
    else { writeini $char($1) CoolDowns MPrestoreitem %mphealing.item.cooldown }
  }

  if (%revive.item.cooldown != $null) { 
    dec %revive.item.cooldown 1
    if (%revive.item.cooldown = 0) { remini $char($1) CoolDowns ReviveItem }
    else { writeini $char($1) CoolDowns ReviveItem %revive.item.cooldown }
  }
}
