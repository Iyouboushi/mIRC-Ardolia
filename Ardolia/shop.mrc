;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; shop.mrc
;;;; Last updated: 08/03/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file contains code for the shop

on 2:TEXT:!shop*:*: { $shop.start($nick, $2, $3, $4, $5) }
on 2:TEXT:!sell*:*: { $shop.start($nick, sell, $2, $3, $4, $5) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic Shop Starting Point
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias shop.start {
  if ($2 = $null) { $gamehelp(Shop, $nick)  | halt  }
  if ($5 = 0) {  $display.private.message($translate(Can'tBuy0OfThat)) | halt }

  if ((%adventureis = on) && ($adventure.alreadyinparty.check($nick) = true)) { $display.message($translate(Can'tUseShopinAdventure, $nick), private) | halt }

  var %categories items.item.armor.weapons.weapon

  if (($2 = buy) || ($2 = purchase)) { 

    if ($3 = $null) { $gamehelp(Shop, $1)  | halt  }
    if ($istok(%categories, $3, 46) = $false) { $gamehelp(Shop, $1)  | halt  }

    var %amount.to.purchase $abs($5)
    if ((%amount.to.purchase = $null) || (%amount.to.purchase !isnum 1-9999)) { var %amount.to.purchase 1 }

    $shop.buy($1, $3, $4, %amount.to.purchase)
  }

  if ($2 = sell) { 

    if ($3 = $null) { $gamehelp(Shop, $1)  | halt  }
    if ($istok(%categories, $3, 46) = $false) { $gamehelp(Shop, $1)  | halt  }

    var %amount.to.purchase $abs($5)
    if ((%amount.to.purchase = $null) || (%amount.to.purchase !isnum 1-9999)) { var %amount.to.purchase 1 }
    $shop.sell($1, $3, $4, %amount.to.purchase)
  }

  if ($2 = list) { 
    if ($3 = $null) { $gamehelp(Shop, $1)  | halt  }
    if ($istok(%categories, $3, 46) = $false) { $gamehelp(Shop, $1)  | halt  }

    $shop.list($1, $3)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shop List Command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !shop list [item/weapon/armor]
alias shop.list {
  unset %shop.items*
  unset %token.count.shop

  var %fame.level $character.fame($1) |  var %shop.fame.level 1 |  var %token.count.shop 1

  if (($2 = item) || ($2 = items)) {  var %category.db items.db } 
  if ($2 = food) { var %category.db items.db }
  if (($2 = weapons) || ($2 = weapon)) {  var %category.db weapons.db } 
  if ($2 = armor) { var %category.db equipment.db }

  ; Cycle through the fame lists
  while (%shop.fame.level <= %fame.level) {

    var %shop.fame.file shop_fame $+ %shop.fame.level $+ .lst
    var %shop.line 1

    ; Shop through the list files for the individual items
    while (%shop.line <= $lines($lstfile(%shop.fame.file))) {

      var %line.item.name $read($lstfile(%shop.fame.file), %shop.line)
      var %line.item.cost $readini($dbfile(%category.db), %line.item.name, Cost)

      if ((%line.item.cost > 0) && (%line.item.cost != $null)) {
        ; Add to the list

        if ($2 = armor) { var %item.color $rarity.color.check(%line.item.name, armor) }
        if (($2 = weapon) || ($2 = weapons)) { var %item.color $rarity.color.check(%line.item.name, armor) }

        ; Determine the item's color for the shop (red meaning can't use it)
        var %shop.item.level $readini($dbfile(%category.db), %line.item.name, ItemLevel)
        if (%shop.item.level = $null) { var %shop.item.level 1 }

        var %shop.item.job $readini($dbfile(%category.db), %line.item.name, jobs)
        if ((%shop.item.job = $null) || (%shop.item.job = all)) { var %shop.item.job $current.job($1) } 

        echo -a shop item level for %line.item.name :: %shop.item.level


        if ($istok(%shop.item.job, $current.job($1), 46) = $false) { var %item.color 4 }
        if ($get.level($1) < %shop.item.level) { var %item.color 4 }

        inc %token.count.shop 1
        var %item.to.add %item.color $+ %line.item.name $+ 2 $+ $chr(40) $+ %line.item.cost $+ $chr(41)

        if (%token.count.shop <= 20) { %shop.items.list = $addtok(%shop.items.list, %item.to.add,46) }
        if ((%token.count.shop > 20) && ( %token.count.shop <= 40)) { %shop.items.list2 = $addtok(%shop.items.list2, %item.to.add,46) }
        if ((%token.count.shop > 40) && ( %token.count.shop <= 60)) {  %shop.items.list3 = $addtok(%shop.items.list3, %item.to.add,46) }
        if ((%token.count.shop > 60) && ( %token.count.shop <= 80)) { %shop.items.list4 = $addtok(%shop.items.list4, %item.to.add,46)  }
        if (%token.count.shop > 80) { %shop.items.list5 = $addtok(%shop.items.list5, %item.to.add,46) }
      }

      inc %shop.line
    }

    inc %shop.fame.level 1
  }

  ; Display the items for the category
  $display.private.message(3 $+ $2 available for purchase)

  %shop.items.list = $clean.list(%shop.items.list)
  $display.private.message(2 $+ %shop.items.list)
  if (%shop.items.list2 != $null) { %shop.items.list2 = $clean.list(%shop.items.list2)  | $display.private.message(2 $+ %shop.items.list2) }
  if (%shop.items.list3 != $null) {  %shop.items.list3 = $clean.list(%shop.items.list3) | $display.private.message(2 $+ %shop.items.list3) }
  if (%shop.items.list4 != $null) { %shop.items.list4 = $clean.list(%shop.items.list4) | $display.private.message(2 $+ %shop.items.list4) }
  if (%shop.items.list5 != $null) { %shop.items.list5 = $clean.list(%shop.items.list5)   | $display.private.message(2 $+ %shop.items.list5) } 

  unset %shop.items*
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shop Purchase Command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !shop buy [item/armor/weapon] itemname
alias shop.buy {

  if (($2 = item) || ($2 = items)) {  var %category.db items.db } 
  if ($2 = food) { var %category.db items.db }
  if (($2 = weapons) || ($2 = weapon)) {  var %category.db weapons.db } 
  if ($2 = armor) { var %category.db equipment.db }

  ; Can this item even be bought in the store?
  if (($readini($dbfile(%category.db), $3, Cost) = 0) || ($readini($dbfile(%category.db), $3, Cost) = $null)) { $display.private.message($translate(Can'tBuyThis, $2)) | halt }

  ; Does the player have enough fame?
  var %fame.level $character.fame($1) | var %item.fame $readini($dbfile(%category.db), $3, famelevel)
  if (%fame.level < %item.fame) { echo -a fame too low | $display.private.message($translate(FameTooLowToBuy)) | halt }

  ; Does the player have enough money?
  var %item.cost $readini($dbfile(%category.db), $3, cost)
  var %item.cost $calc(%item.cost * $4)
  var %player.money $currency.amount($1, Money)
  if (%player.money < %item.cost) { $display.private.message($translate(NotEnoughMoneyToBuy, $4)) | halt }

  ; Remove the money
  $currency.remove($1, money, %item.cost)

  ; Give item
  var %item.count $readini($char($1), Inventory, $3)
  if (%item.count = $null) { var %item.count 0 }
  inc %item.count $4
  writeini $char($1) Inventory $3 %item.count

  ; Display the message
  $display.private.message($translate(ShopPurchaseMessage, %item.cost, $4, $3))
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Shop Sell Command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !shop sell [item/armor/weapon] itemname amount
alias shop.sell {
  ; $1 = the person
  ; $2 = the category
  ; $3 = the item name
  ; $4 = the amount

  if (($2 = item) || ($2 = items)) {  var %category.db items.db } 
  if ($2 = food) { var %category.db items.db }
  if (($2 = weapons) || ($2 = weapon)) {  var %category.db weapons.db } 
  if ($2 = armor) { var %category.db equipment.db }

  ; Can this item be sold?
  var %sell.price $readini($dbfile(%category.db), $3, SellPrice)
  if ((%sell.price = $null) || (%sell.price <= 0)) { $display.private.message($translate(CannotSellThisItem)) | halt }

  ; set the amount of this that the player owns
  var %current.inventory $readini($char($1), inventory, $3)

  if ((%current.inventory = 0) || (%current.inventory = $null)) { $display.private.message($translate(YouDoNotHaveThisItemToSell)) | halt }

  ; Is this a weapon or armor that is equipped?
  if ($2 = weapon) { 
    var %weapon.equipped $readini($char($1), equipment, weapon)

    if (%weapon.equipped = $3) {
      if (%current.inventory = 1) { $display.private.message($translate(StillUsingWeapon)) | halt }
    }
  }

  if ($2 = armor) { 
    var %armor.equip.slot $readini($dbfile(equipment.db), $3, EquipLocation)
    var %armor.equipped $readini($char($1), equipment, %armor.equip.slot)

    if (%armor.equipped = $3) {
      if (%current.inventory = 1) { $display.private.message($translate(StillWearingArmor)) | halt }
    }
  }

  ; Does the player have the amount of items to sell?
  dec %current.inventory $4 
  if (%current.inventory < 0) { $display.private.message($translate(SellingMoreThanYouOwn)) | halt } 

  ; Sell the item and give currency to the player
  if (%current.inventory = 0) { remini $char($1) inventory $3 }
  else { writeini $char($1) inventory $3 %current.inventory }

  var %money.earned $calc($4 * %sell.price)
  $currency.add($1, money, %money.earned)

  ; Display the sell message
  $display.private.message($translate(SellMessage, $4, $3, %money.earned))
}
