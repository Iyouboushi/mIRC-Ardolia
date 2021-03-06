;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; characters.mrc
;;;; Last updated: 10/01/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a new character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !new char [race]
on 1:TEXT:!new char*:*: {  $checkscript($2-)
  if ($chr(124) isin $nick) { $display.private.message(4Cannot use a name that has illegal characters in it) | halt }
  if ($isfile($char($nick)) = $true) { $display.private.message($translate(PlayerExists)) | halt }
  if ($isfile($char($nick $+ _clone)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($char(evil_ $+ $nick)) = $true)  { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($char($nick $+ _summon)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($mon($nick)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($boss($nick)) = $true) { $display.private.message($translate(NameReserved)) | halt  }
  if ($isfile($npc($nick)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($summon($nick)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = $nick $+ _clone) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = evil_ $+ $nick) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = monster_warmachine) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = demon_wall) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = pirate_scallywag) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = pirate_firstmatey) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = bandit_leader) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = bandit_minion) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = crystal_shadow) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = alliedforces_president) { $display.private.message($translate(NameReserved)) | halt }
  if ((($nick = frost_monster) || ($nick = frost_monster1) || ($nick = frost_monster2))) { $display.private.message($translate(NameReserved)) | halt }

  ; If the player has not supplied a valid race then we need to give the beginning instructions
  if (($3 = $null) || ($readini($racefile($3), BasicInfo, Name) = $null)) { 
    $gamehelp(welcome, $nick)
    halt
  }

  ; Create the file
  .copy $char(new_chr) $char($nick)
  writeini $char($nick) Info Name $nick 
  writeini $char($nick) Info Created $fulldate
  writeini $char($nick) Info Race $3

  ; Copy the starting stats over
  writeini $char($nick) StartingStats Str $readini($racefile($3), StartingStats, Str)
  writeini $char($nick) StartingStats Dex $readini($racefile($3), StartingStats, Dex)
  writeini $char($nick) StartingStats Vit $readini($racefile($3), StartingStats, Vit)
  writeini $char($nick) StartingStats Int $readini($racefile($3), StartingStats, Int)
  writeini $char($nick) StartingStats Mnd $readini($racefile($3), StartingStats, Mnd)
  writeini $char($nick) StartingStats Pie $readini($racefile($3), StartingStats, Pie)
  writeini $char($nick) StartingStats Det $readini($racefile($3), StartingStats, Det)

  ; Give the starting money
  var %starting.money $readini(system.dat, system, StartingMoney)
  if (%starting.money = $null) { var %starting.money 20 }
  writeini $char($nick) Currencies Money %starting.money

  ; Generate a password
  set %password ardolia $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000)
  writeini $char($nick) info password $encode(%password)

  ; Send information about the password
  $display.private.message($translate(StartingCharPassword))

  ; Write current host
  if ($site != $null) { writeini $char($nick) info LastIP $site } 

  ; Give voice
  mode %battlechan +v $nick
  .auser 2 $nick

  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$nick,46) = $true) {
    var %bot.owner $gettok(%bot.owners, 1, 46)
    if ($nick = %bot.owner) { .auser 100 $nick }
    else { .auser 50 $nick }
  }

  ; Give 10 starting login points
  $currency.add($nick, LoginPoints, 10)
  writeini $char($nick) info lastloginpoint $ctime 

  ; Tell the world we've joined
  $display.message($translate(CharacterCreated))

  ; Tell the player what starting stuff he/she gets
  $display.private.message($translate(CharacterNewItems))
  $display.private.message($translate(StartingRecommendation, $nick))

  ; Copy the starting stats to the current stats
  $copyini($nick, StartingStats, BaseStats)
  $fulls($nick)

  unset %password
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Password and ID commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 2:TEXT:!newpass *:?:{ $checkscript($2-) | $password($nick) 
  var %encode.type $readini($char($nick), info, PasswordType)

  if (%encode.type = $null) { var %encode.type encode }
  if (%encode.type = encode) { 
    if ($encode($2) = %password) {  
      if ($version < 6.3) { writeini $char($nick)  info PasswordType encode | writeini $char($nick) info password $encode($3)  }
      else { writeini $char($nick) info PasswordType hash |  writeini $char($nick) info password $sha1($3) }
      $display.private.message($readini(translation.dat, translation, newpassword)) | unset %password | halt
    }
    if ($encode($2) != %password) {  $display.private.message($translate(wrongpassword)) | unset %password | halt }
  }
  if (%encode.type = hash) {
    if ($sha1($2) = %password) { writeini $char($nick) info password $sha1($3) | writeini $char($nick) info PasswordType hash | $display.private.message($readini(translation.dat, translation, newpassword)) | unset %password | halt }
    if ($sha1($2) != %password) { $display.private.message($translate(wrongpassword)) | unset %password | halt }
  }
}

ON 1:TEXT:!id*:*:{ 
  if ($readini(system.dat, system, botType) = TWITCH) {
    if ($isfile($char($nick)) = $true) {
      $set_chr_name($nick) | $display.message(10 $+ %real.name %custom.title  $+ $readini($char($nick), Descriptions, Char), global)
      var %bot.owners $readini(system.dat, botinfo, bot.owner)
      if ($istok(%bot.owners,$nick,46) = $true) {
        var %bot.owner $gettok(%bot.owners, 1, 46)
        if ($nick = %bot.owner) { .auser 100 $nick }
        else { .auser 50 $nick }
      }
      mode %battlechan +v $nick | unset %passhurt
      halt
    }
  }

  $idcheck($nick , $2) | mode %battlechan +v $nick |  unset %passhurt | $writehost($nick, $site) |  $system.intromessage($nick) | /close -m* 
  if ($readini($char($nick), info, CustomTitle) != $null) { var %custom.title " $+ $readini($char($nick), info, CustomTitle) $+ " }
  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { $display.message(10 $+ $get_chr_name($nick) %custom.title  $+  $readini($char($nick), Descriptions, Char), global) }
}
ON 1:TEXT:!quick id*:*:{ $idcheck($nick , $3, quickid) | mode %battlechan +v $nick |  $writehost($nick, $site) | $system.intromessage($nick)
  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { $set_chr_name($nick) }
  unset %passhurt 
  /close -m* 
}
on 2:TEXT:!logout*:*:{ .auser 1 $nick | close -c $nick | mode %battlechan -v $nick | .flush 1 }
on 2:TEXT:!log out*:*:{ .auser 1 $nick | close -c $nick | mode %battlechan -v $nick | .flush 1 }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate your free stat points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!stat *:?: {
  ; !stat [add] [stat] [amount]
  if (($2 = point) || ($2 = points)) { $display.private.message($translate(ViewMyStatPoints)) | halt }
  if (($2 != add) && ($2 != remove)) { $gamehelp(!stat, $nick) | halt }
  if (($3 = $null) || ($4 !isnum)) { $gamehelp(!stat, $nick) | halt }
  if ((. isin $4) || ($4 <= 0)) { $gamehelp(!stat, $nick) | halt }

  var %valid.stats str.dex.vit.int.mnd.pie
  if ($istok(%valid.stats, $3, 46) = $false) { $display.private.message($translate(InvalidStatSelection)) | halt }

  ; Are we in an adventure?  If so, we can't do this.
  if ($in.adventure($nick) = true) { $display.private.message($translate(Can'tAllocateRightNow)) | halt }

  if ($2 = add) {
    ; Do we have enough stat points?
    if ($4 > $current.freestatpoints($nick)) { $display.private.message($translate(NotEnoughStatPoints)) | halt }

    if ($3 = str) { var %current.stat $resting.str($nick) } 
    if ($3 = dex) { var %current.stat $resting.dex($nick) }
    if ($3 = vit) { var %current.stat $resting.vit($nick) }  
    if ($3 = int) { var %current.stat $resting.int($nick) } 
    if ($3 = mnd) { var %current.stat $resting.mnd($nick) } 
    if ($3 = pie) { var %current.stat $resting.pie($nick) }

    inc %current.stat $4

    writeini $char($nick) basestats $3 %current.stat 
    writeini $char($nick) info UnallocatedStatPoints $calc($current.freestatpoints($nick) - $4)
    $miscstats($nick, add, TotalStatPointsSpent, $4)

    $display.private.message($translate(AllocatedStatPoints, $4, $3, %current.stat)) 

    $fulls($nick, yes)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Changing/Checking Jobs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!job change *:*: {
  ; !job change [job]

  ; Can't change jobs if you're in an
  if ($in.adventure($nick) = true) { $display.private.message($translate(Can'tChangeJobsRightNow)) | halt }

  ; Is this the same job you already are?
  if ($3 = $current.job($nick)) { $display.private.message($translate(SameJob)) | halt }

  ; does the player still have unallocated stat points?
  if ($current.freestatpoints($nick) > 0) { $display.private.message($translate(Can'tChangeJobsWithStatPointsLeft)) | halt }

  ; Is this a valid job?
  if ($isfile($jobfile($3)) != $true) { $display.private.message($translate(JobDoesNotExist)) | halt }

  ; If the player's file doesn't have that job write that we're now level 1 to it
  var %job.level $readini($char($nick), jobs, $3)
  if ((%job.level = $null) || (%job.level = 0)) { writeini $char($nick) jobs $3 1 | writeini $char($nick) Exp $3 0 }

  ; Make a current copy of the stats of the old job and clear the equipment
  if ($current.job($nick) != none) {  
    $copyini($nick, BaseStats, Stats- $+ $current.job($nick)) 
    $gearset.set($nick, $current.job($nick))
    $equipment.reset($nick)
  }

  ; Do we need to restore a back up of the job's stats?
  if ($readini($char($nick), Stats- $+ $3, str) != $null) {  
    $copyini($nick, Stats- $+ $3, BaseStats) 
    $gearset.equip($nick, $3)
  }

  ; If a back up is not found then it means it's the first time we're switching to this job. Time to do some stuff.
  if ($readini($char($nick), Stats- $+ $3, str) = $null) {

    ; Get a copy from the starting stats
    $copyini($nick, StartingStats, BaseStats)
  }

  writeini $char($nick) Jobs CurrentJob $3

  ; Restore the player's HP/MP/battle stats
  $fulls($nick, yes)

  ; Tell the world we've changed jobs
  $display.message($translate(ChangedJob))
}

on 2:TEXT:!jobs*:#: {  
  unset %jobs.list

  if ($2 = $null) { .echo -q $findfile( $job_path , *.job, 0, 0, jobs.list $nick $1-) }
  else { $checkchar($2) | var %char.name $2 | .echo -q $findfile( $job_path , *.job, 0, 0, jobs.list %char.name $1-) }

  %jobs.list = $clean.list(%jobs.list)  

  if ($2 = $null) {  $display.message($translate(ViewMyJobs), private) }
  if ($2 != $null) { $display.message($translate(ViewOthersJobs, $2), private) }

  unset %jobs.list
}
on 2:TEXT:!jobs*:?: {  
  unset %jobs.list

  if ($2 = $null) { .echo -q $findfile( $job_path , *.job, 0, 0, jobs.list $nick $1-) }
  else { $checkchar($2) | var %char.name $2 | .echo -q $findfile( $job_path , *.job, 0, 0, jobs.list %char.name $1-) }

  %jobs.list = $clean.list(%jobs.list)  

  if ($2 = $null) {  $display.private.message($translate(ViewMyJobs))  }
  if ($2 != $null) { $display.private.message($translate(ViewOthersJobs, $2)) }

  unset %jobs.list
}
on 2:TEXT:!job:*: {  $display.message($translate(ViewMyCurrentJob),private) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set your gender
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !setgender male/female/neither/none
ON 2:TEXT:!setgender*:*: { $checkscript($2-)
  if ($2 = neither) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | $display.private.message($translate(SetGenderNeither)) | unset %check | halt }
  if ($2 = none) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | $display.private.message($translate(SetGenderNeither))  | unset %check | halt }
  if ($2 = male) { writeini $char($nick) Info Gender his | writeini $char($nick) Info Gender2 him | $display.private.message($translate(SetGenderMale))  | unset %check | halt }
  if ($2 = female) { writeini $char($nick) Info Gender her | writeini $char($nick) Info Gender2 her | $display.private.message($translate(SetGenderFemale)) | unset %check | halt }
  else { $display.private.message($translate(NeedValidGender)) | unset %check | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your HP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!hp:#: { $display.message($translate(ViewMyHP), private) }
on 2:TEXT:!hp:?: { $display.private.message($translate(ViewMyHP)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your MP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!mp:#: { $display.message($translate(ViewMyMP), private) }
on 2:TEXT:!mp:?: { $display.private.message($translate(ViewMyHP)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your TP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!tp:#: { $display.message($translate(ViewMyTP), private) }
on 2:TEXT:!tp:?: { $display.private.message($translate(ViewMyTP)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your level
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!level:#: { $display.message($translate(ViewMyLevel), private) }
on 2:TEXT:!level:?: { $display.private.message($translate(ViewMyLevel)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your iLevel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!ilevel:#: { $display.message($translate(ViewMyiLevel), private) }
on 2:TEXT:!ilevel:?: { $display.private.message($translate(ViewMyiLevel)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your xp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!xp:#: { $display.message($translate(ViewMyXP), private) }
on 2:TEXT:!xp:?: { $display.private.message($translate(ViewMyXP)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your main currency
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!gil:#: { $display.message($translate(ViewMyMoney), private) }
on 2:TEXT:!gil:?: { $display.private.message($translate(ViewMyMoney), private) }
on 2:TEXT:!money:#: { $display.message($translate(ViewMyMoney), private) }
on 2:TEXT:!money:?: { $display.private.message($translate(ViewMyMoney), private) }
on 2:TEXT:!gold:#: { $display.message($translate(ViewMyMoney), private) }
on 2:TEXT:!gold:?: { $display.private.message($translate(ViewMyMoney), private) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your craftingpoints
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!craftingpoints:#: { $display.message($translate(ViewMycraftingpoints), private) }
on 2:TEXT:!craftingpoints:?: { $display.private.message($translate(ViewMycraftingpoints)) }
on 2:TEXT:!crafting points:#: { $display.message($translate(ViewMycraftingpoints), private) }
on 2:TEXT:!crafting points:?: { $display.private.message($translate(ViewMycraftingpoints)) }
on 2:TEXT:!cp:#: { $display.message($translate(ViewMycraftingpoints), private) }
on 2:TEXT:!cp:?: { $display.private.message($translate(ViewMycraftingpoints)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your guildpoints
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!guildpoints:#: { $display.message($translate(ViewMyguildpoints), private) }
on 2:TEXT:!guildpoints:?: { $display.private.message($translate(ViewMyguildpoints)) }
on 2:TEXT:!guild points:#: { $display.message($translate(ViewMyguildpoints), private) }
on 2:TEXT:!guild points:?: { $display.private.message($translate(ViewMyguildpoints)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your fame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!fame:#: { $display.message($translate(ViewMyfame), private) }
on 2:TEXT:!fame:?: { $display.private.message($translate(ViewMyfame)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your loginpoints
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!loginpoints:#: { $display.message($translate(ViewMyloginpoints), private) }
on 2:TEXT:!loginpoints:?: { $display.private.message($translate(ViewMyloginpoints)) }
on 2:TEXT:!login points:#: { $display.message($translate(ViewMyloginpoints), private) }
on 2:TEXT:!login points:?: { $display.private.message($translate(ViewMyloginpoints)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View all currencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!currencies:#: { $display.message($translate(ViewMyCurrencies), private) }
on 2:TEXT:!currencies:?: { $display.private.message($translate(ViewMyCurrencies)) }


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View stats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!stats*:*: {

  ; Check your own stats
  if ($2 = $null) { 

    var %equipped.weapon $return.equipped($nick, weapon)
    var %equipped.shield $return.equipped($nick, shield)
    var %equipped.armor.head $return.equipped($nick, head)
    var %equipped.armor.body $return.equipped($nick, body)
    var %equipped.armor.legs $return.equipped($nick, legs)
    var %equipped.armor.feet $return.equipped($nick, feet)
    var %equipped.armor.hands $return.equipped($nick, hands)
    var %equipped.armor.ears $return.equipped($nick, ears)
    var %equipped.armor.neck $return.equipped($nick, neck)
    var %equipped.armor.wrists $return.equipped($nick, wrists)
    var %equipped.armor.ring $return.equipped($nick, ring)

    var %equipped.weapon $rarity.color.check(%equipped.weapon, weapon) $+ %equipped.weapon $+ 3
    if (%equipped.shield != nothing) { var %equipped.shield $rarity.color.check(%equipped.shield, armor) $+ %equipped.shield $+ 3 }
    var %equipped.armor.head $rarity.color.check(%equipped.armor.head, armor) $+ %equipped.armor.head $+ 3
    var %equipped.armor.body $rarity.color.check(%equipped.armor.body, armor) $+ %equipped.armor.body $+ 3
    var %equipped.armor.legs $rarity.color.check(%equipped.armor.legs, armor) $+ %equipped.armor.legs $+ 3
    var %equipped.armor.feet $rarity.color.check(%equipped.armor.feet,armor) $+ %equipped.armor.feet $+ 3 
    var %equipped.armor.hands $rarity.color.check(%equipped.armor.hands, armor) $+ %equipped.armor.hands $+ 3
    var %equipped.armor.ears $rarity.color.check(%equipped.armor.ears,armor) $+ %equipped.armor.ears $+ 3 
    var %equipped.armor.neck $rarity.color.check(%equipped.armor.neck,armor) $+ %equipped.armor.neck $+ 3 
    var %equipped.armor.wrists $rarity.color.check(%equipped.armor.wrists,armor) $+ %equipped.armor.wrists $+ 3 
    var %equipped.armor.ring $rarity.color.check(%equipped.armor.ring,armor) $+ %equipped.armor.ring $+ 3 

    if ($return.foodeffect($nick) != none) { var %food.eaten [4Food Eaten12 $return.foodeffect($nick) $+ ] }

    $display.private.message.delay.custom([4 $+ $get_chr_name($nick) 4the12 $race($nick) $+ ] [4Job12 $current.job($nick) $+ ]  [4Level12 $get.level($nick) $+ ] [4Exp12 $current.xp($nick) $chr(47) $xp.to.level($nick) $chr(40) $+ $round($calc(($current.xp($nick) / $xp.to.level($nick)) * 100),0) $+ $chr(37) $+ $chr(41) $+ ]    ,2,$nick)
    $display.private.message.delay.custom([4HP12 $current.hp($nick) $+ 1/ $+ 12 $+ $resting.hp($nick) $+ ] [4MP12 $current.mp($nick) $+ 1/ $+ 12 $+ $resting.mp($nick) $+ ] [4TP12 $current.tp($nick) $+ ] [4Defense12 $current.defense($nick) $+ ] [4Magic Defense12 $current.mdefense($nick) $+ ] %food.eaten, 2, $nick)
    $display.private.message.delay.custom([4Strength:12 $resting.str($nick) $+ ]  [4Dexterity:12 $resting.dex($nick) $+ ] [4Vitality:12 $resting.vit($nick) $+ ] [4Intelligence:12 $resting.int($nick) $+ ] [4Mind:12 $resting.mnd($nick) $+ ] [4Piety:12 $resting.pie($nick) $+ ], 2, $nick)
    $display.private.message.delay.custom([4Weapon12 %equipped.weapon $+ ] $iif(%equipped.shield != nothing, [4Shield12 %equipped.shield $+ ]) [4Head Armor12 %equipped.armor.head $+ ] [4Body Armor12 %equipped.armor.body $+ ] [4Leg Armor12 %equipped.armor.legs $+ ] [4Feet Armor12 %equipped.armor.feet $+ ] [4Hand Armor12 %equipped.armor.hands $+ ] [4Earrings12 %equipped.armor.ears $+ ] [4Neck Armor12 %equipped.armor.neck $+ ] [4Wrist Armor12 %equipped.armor.wrists $+ ] [4Ring12 %equipped.armor.ring $+ ],2,$nick)
  }

  ; Check someone else's stats
  else { $checkchar($2) 
    if ($flag($2) != $null) { $display.private.message($translate(CanOnlyViewPlayerStats)) | halt }

    var %equipped.weapon $return.equipped($2, weapon)
    var %equipped.shield $return.equipped($2, shield)
    var %equipped.armor.head $return.equipped($2, head)
    var %equipped.armor.body $return.equipped($2, body)
    var %equipped.armor.legs $return.equipped($2, legs)
    var %equipped.armor.feet $return.equipped($2, feet)
    var %equipped.armor.hands $return.equipped($2, hands)
    var %equipped.armor.ears $return.equipped($2, ears)
    var %equipped.armor.neck $return.equipped($2, neck)
    var %equipped.armor.wrists $return.equipped($2, wrists)
    var %equipped.armor.ring $return.equipped($2, ring)

    var %equipped.weapon $rarity.color.check(%equipped.weapon, weapon) $+ %equipped.weapon $+ 3
    if (%equipped.shield != nothing) { var %equipped.shield $rarity.color.check(%equipped.shield, armor) $+ %equipped.shield $+ 3 }
    var %equipped.armor.head $rarity.color.check(%equipped.armor.head, armor) $+ %equipped.armor.head $+ 3
    var %equipped.armor.body $rarity.color.check(%equipped.armor.body, armor) $+ %equipped.armor.body $+ 3
    var %equipped.armor.legs $rarity.color.check(%equipped.armor.legs, armor) $+ %equipped.armor.legs $+ 3
    var %equipped.armor.feet $rarity.color.check(%equipped.armor.feet,armor) $+ %equipped.armor.feet $+ 3 
    var %equipped.armor.hands $rarity.color.check(%equipped.armor.hands, armor) $+ %equipped.armor.hands $+ 3
    var %equipped.armor.ears $rarity.color.check(%equipped.armor.ears,armor) $+ %equipped.armor.ears $+ 3 
    var %equipped.armor.neck $rarity.color.check(%equipped.armor.neck,armor) $+ %equipped.armor.neck $+ 3 
    var %equipped.armor.wrists $rarity.color.check(%equipped.armor.wrists,armor) $+ %equipped.armor.wrists $+ 3 
    var %equipped.armor.ring $rarity.color.check(%equipped.armor.ring,armor) $+ %equipped.armor.ring $+ 3 

    if ($return.foodeffect($2) != none) { var %food.eaten [4Food Eaten12 $return.foodeffect($2) $+ ] }

    $display.private.message.delay.custom([4 $+ $get_chr_name($2) 4the12 $race($2) $+ ] [4Job12 $current.job($2) $+ ]  [4Level12 $get.level($2) $+ ] [4Exp12 $current.xp($2) $chr(47) $xp.to.level($2) $chr(40) $+ $round($calc(($current.xp($2) / $xp.to.level($2)) * 100),0) $+ $chr(37) $+ $chr(41) $+ ]    ,2,$nick)
    $display.private.message.delay.custom([4HP12 $current.hp($2) $+ 1/ $+ 12 $+ $resting.hp($2) $+ ] [4MP12 $current.mp($2) $+ 1/ $+ 12 $+ $resting.mp($2) $+ ] [4TP12 $current.tp($2) $+ ] [4Defense12 $current.defense($2) $+ ] [4Magic Defense12 $current.mdefense($2) $+ ] %food.eaten, 2, $nick)
    $display.private.message.delay.custom([4Strength:12 $resting.str($2) $+ ]  [4Dexterity:12 $resting.dex($2) $+ ] [4Vitality:12 $resting.vit($2) $+ ] [4Intelligence:12 $resting.int($2) $+ ] [4Mind:12 $resting.mnd($2) $+ ] [4Piety:12 $resting.pie($2) $+ ], 2, $nick)
    $display.private.message.delay.custom([4Weapon12 %equipped.weapon $+ ] $iif(%equipped.shield != nothing, [4Shield12 %equipped.shield $+ ]) [4Head Armor12 %equipped.armor.head $+ ] [4Body Armor12 %equipped.armor.body $+ ] [4Leg Armor12 %equipped.armor.legs $+ ] [4Feet Armor12 %equipped.armor.feet $+ ] [4Hand Armor12 %equipped.armor.hands $+ ] [4Earrings12 %equipped.armor.ears $+ ] [4Neck Armor12 %equipped.armor.neck $+ ] [4Wrist Armor12 %equipped.armor.wrists $+ ] [4Ring12 %equipped.armor.ring $+ ],2,$nick)

  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your abilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!abilities*:*: {
  unset %ability.list
  $abilities.list($nick, $2) | $readabilities($nick, channel)  
  unset %real.name
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!spells*:*: {

  if ($resting.mp($nick) = 0) { $display.message($translate(Can'tCastSpells, $nick)) | unset %real.name | halt }

  unset %spell.list
  $spells.list($nick, $2) | $readspells($nick, channel)  
  unset %real.name

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your weapons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!weapons*:*: {
  unset %weapon.list
  if ($2 = $null) { $display.message($translate(NeedToSayWhichWeaponType, $nick), global) | halt }
  $weapons.list($nick, $2) | $readweapons($nick, channel, $2)  
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!armor*:#:{ 
  if ($2 = $null) { $display.message($translate(NeedToSayWhichArmor, $nick), global) | halt }
  $armor.list($nick, $2) | $readarmor($nick, channel, $2)  
}
on 2:TEXT:!armor*:?:{ 
  if ($2 = $null) { $display.private.message($translate(NeedToSayWhichArmor, $nick) | halt }
  $armor.list($nick, $2) | $readarmor($nick, private, $2)  
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your inventory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!items*:#:{ 
  if ($2 != $null) { $checkchar($2) | $items.list($2) | $readitems($2, channel) }
  else {  $items.list($nick) | $readitems($nick, channel) }
}
on 2:TEXT:!inventory*:#:{ 
  if ($2 != $null) { $checkchar($2) | $items.list($2) | $readitems($2, channel) }
  else {  $items.list($nick) | $readitems($nick, channel) }
}
on 2:TEXT:!spoils*:#:{ 
  if ($3 != $null) { $checkchar($3) | $spoils.list($3) | $readspoils($3, channel) }
  else {  $spoils.list($nick) | $readspoils($nick, channel) }
}
on 2:TEXT:!spoils*:?:{ 
  if ($3 != $null) { $checkchar($3) | $spoils.list($3) | $readspoils($3, private) }
  else {  $spoils.list($nick) | $readspoils($nick, private) }
}
on 2:TEXT:!food*:#:{ 
  if ($2 != $null) { $checkchar($2) | $food.list($2) | $readfood($2, channel) }
  else {  $food.list($nick) | $readfood($nick, channel) }
}
on 2:TEXT:!food*:?:{ 
  if ($2 != $null) { $checkchar($2) | $food.list($2) | $readfood($2, private) }
  else {  $food.list($nick) | $readfood($nick, private) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your current status
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!status*:*: {
  unset %current.buffs
  unset %current.effects

  $character.showstatus($nick)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set your descriptions
; Also read descs of other players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !desc <person's name or [set character/whatever]> [description]

on 2:TEXT:!desc*:#: {  $checkscript($2-)
  if ($2 = $null) { $display.message(10 $+ $get_chr_name($nick)  $+ $readini($char($nick), Descriptions, Char),private) | halt }
  if ($2 = set) {

    if (($3 = character) || ($3 = char)) { writeini $char($nick) Descriptions Char $4- | $display.private.message($translate(DescSetOK, $3))  }
    if (($3 = abilitiy) || ($3 = skill)) { $display.message(Not implemented yet, private) }

    halt
  }

  ; Check someone else's desc
  $checkchar($2) |  $display.message(3 $+ $get_chr_name($2)  $+ $readini($char($2), Descriptions, Char), private) 
}

on 2:TEXT:!desc*:?: {  $checkscript($2-)
  if ($2 = $null) { $display.private.message(10 $+ $get_chr_name($nick)  $+ $readini($char($nick), Descriptions, Char)) | halt }
  if ($2 = set) {

    if (($3 = character) || ($3 = char)) { writeini $char($nick) Descriptions Char $4- | $display.private.message($translate(DescSetOK, $3))  }
    if (($3 = abilitiy) || ($3 = skill)) { $display.private.message(Not implemented yet) }

    halt
  }

  ; Check someone else's desc
  $checkchar($2) |  $display.private.message(3 $+ $get_chr_name($2)  $+ $readini($char($2), Descriptions, Char)) 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Equip command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !equip weaponname
; !equip armor armorname
; !equip shield shieldname

on 2:TEXT:!wear *:*: { $wear.armor($nick, $2) | halt }
on 2:TEXT:!wield *:*: { $wield.weapon($nick, $2) | halt }

on 2:TEXT:!equip *:*: { 
  if ($2 = armor) { $wear.armor($nick, $3) | halt }
  if ($2 = shield) { $wear.armor($nick, $3) | halt }

  $wield.weapon($nick, $2) 
}

alias wield.weapon {
  if ((%adventureis = on) && ($adventure.alreadyinparty.check($1) = true)) { $display.message($translate(CanOnlySwitchOutsideAdventure, $1), private) | halt }

  ; Is the weapon already equipped?
  if ($2 = $return.equipped($1, Weapon)) { $set_chr_name($1) | $display.message($translate(WeaponAlreadyEquipped, $1, $2), private) | unset %real.name | halt }

  ; Does the player own this weapon?
  if ($inventory.amount($1, $2) < 1) { $set_chr_name($1) | $display.message($translate(DoNotHaveWeapon, $1) , private) | unset %real.name | halt }

  ; Is the player the correct level and job to use this weapon?
  var %jobs.list $readini($dbfile(weapons.db), $2, jobs)
  if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { $display.message($translate(WrongJobToEquip, $1) , private) | halt }

  ; Is the player's level too low to equip this?
  if ($get.level($1) < $readini($dbfile(weapons.db), $2, PlayerLevel)) { $display.message($translate(LevelTooLowToEquip, $1) , private) | halt }

  $character.wieldweapon($1, $2)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unequip command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !unequip armor armorname
; !unequip shield shieldname
; !unequip weaponname

on 2:TEXT:!unequip *:*: { 

  if ($2 = armor) { $remove.armor($nick, $3) | halt }
  if ($2 = shield) { $remove.armor($nick, $3) | halt }

  ; Can only swap equipment outside of adventures
  if ((%adventureis = on) && ($adventure.alreadyinparty.check($nick) = true)) { $display.message($translate(CanOnlySwitchOutsideAdventure), private) | halt }

  ; We can hardly unequip our fists
  if ($2 = fists) { $set_chr_name($nick) | $display.message($translate(Can'tDetachHands),private) | halt }

  if ($return.equipped($nick, weapon) != $2) { $display.private.message($translate(WrongEquippedWeapon, $nick, $2)) | halt } 

  writeini $char($nick) equipment Weapon Fists 
  $display.message($translate(UnequipWeapon, $nick, $2),private) 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rolls the dice
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!roll *:#: { 
  if (d !isin $2) { $display.private.message(4!roll #d#(+#)  - example: !roll 1d10 or !roll 1d6+3) | halt }
  $display.message(7* 2Result for $2 $+ : $roll($2),global)
}

on 2:TEXT:!roll *:?: { 
  if (d !isin $2) { $display.private.message(4!roll #d#(+#)  - example: !roll 1d10 or !roll 1d6+3) | halt }
  $display.private.message(7* 2Result for $2 $+ : $roll($2))
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gearset code for when
; you change jobs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copies the current gear to a 'set' for easy swapping back later
alias gearset.set {
  ; $1 = the person we're setting a gearset for
  ; $2 = the gearset name

  ; copy the INI of the current [equipment] section to a gearset 
  $copyini($1, equipment, gearset $+ $2)
}

; Swaps back the gear and unequips anything the player no longer owns
alias gearset.equip {
  ; $1 = the person
  ; $2 = the gearset name

  ; Check to see if the gearset number exists
  if ($readini($char($1), Gearset $+ $2, body) = $null) { return }

  ; Check each armor piece to make sure the person still owns it. 
  ; If the armor is not found, set it to "nothing"
  var %armor.not.found false

  ; Set the variables for the armor we're swapping into
  var %head.armor $readini($char($1), Gearset $+ $2, head)
  var %body.armor $readini($char($1), Gearset $+ $2, body)
  var %legs.armor $readini($char($1), Gearset $+ $2, legs)
  var %feet.armor $readini($char($1), Gearset $+ $2, feet)
  var %hands.armor $readini($char($1), Gearset $+ $2, hands)
  var %ears.armor $readini($char($1), Gearset $+ $2, ears)
  var %wrists.armor $readini($char($1), Gearset $+ $2, wrists)
  var %neck.armor $readini($char($1), Gearset $+ $2, neck)
  var %ring.armor $readini($char($1), Gearset $+ $2, ring)
  var %shield.armor $readini($char($1), Gearset $+ $2, shield)
  var %gear.weapon $readini($char($1), Gearset $+ $2, weapon)


  if ((%head.armor != nothing) && (%head.armor != $null)) { 
    if ($inventory.amount($1, %head.armor) <= 0) { var %armor.not.found true | var %head.armor nothing }
  }
  if ((%body.armor != nothing) && (%body.armor != $null)) { 
    if ($inventory.amount($1, %body.armor) <= 0) { var %armor.not.found true | var %body.armor nothing }
  } 
  if ((%legs.armor != nothing) && (%legs.armor != $null)) { 
    if ($inventory.amount($1, %legs.armor) <= 0) { var %armor.not.found true | var %legs.armor nothing }
  }
  if ((%feet.armor != nothing) && (%feet.armor != $null)) { 
    if ($inventory.amount($1, %feet.armor) <= 0) { var %armor.not.found true | var %feet.armor nothing }
  }
  if ((%hands.armor != nothing) && (%hands.armor != $null)) { 
    if ($inventory.amount($1, %hands.armor) <= 0) { var %armor.not.found true | var %hands.armor nothing }
  }
  if ((%ears.armor != nothing) && (%ears.armor != $null)) { 
    if ($inventory.amount($1, %ears.armor) <= 0) { var %armor.not.found true | var %ears.armor nothing }
  }
  if ((%wrists.armor != nothing) && (%wrists.armor != $null)) { 
    if ($inventory.amount($1, %wrists.armor) <= 0) { var %armor.not.found true | var %wrists.armor nothing }
  }  
  if ((%neck.armor != nothing) && (%neck.armor != $null)) { 
    if ($inventory.amount($1, %neck.armor) <= 0) { var %armor.not.found true | var %neck.armor nothing }
  }  
  if ((%ring.armor != nothing) && (%ring.armor != $null)) { 
    if ($inventory.amount($1, %ring.armor) <= 0) { var %armor.not.found true | var %ring.armor nothing }
  }
  if ((%shield.armor != nothing) && (%shield.armor != $null)) { 
    if ($inventory.amount($1, %shield.armor) <= 0) { var %armor.not.found true | var %shield.armor nothing }
  }
  if ((%gear.weapon != nothing) && (%gear.weapon != $null)) { 
    if ($inventory.amount($1, %gear.weapon) <= 0) { var %armor.not.found true | var %gear.weapon fists }
  }

  ; Silently equip armor 
  writeini $char($1) equipment head %head.armor
  writeini $char($1) equipment body %body.armor
  writeini $char($1) equipment legs %legs.armor
  writeini $char($1) equipment feet %feet.armor
  writeini $char($1) equipment hands %hands.armor
  writeini $char($1) equipment ears %ears.armor
  writeini $char($1) equipment wrists %wrists.armor
  writeini $char($1) equipment neck %neck.armor
  writeini $char($1) equipment ring %ring.armor
  writeini $char($1) equipment shield %shield.armor
  writeini $char($1) equipment weapon %gear.weapon

  ; Display message.  If armor was changed display a different message
  if (%armor.not.found = true) { $display.private.message2($1, $translate(GearsetEquippedWithMissing)) }
  else {  $display.private.message2($1, $translate(GearsetEquipped, $2)) }
}
