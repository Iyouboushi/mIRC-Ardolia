;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ACHIEVEMENTS 
;;;; Last updated: 04/26/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file is not updated from
; BattleArena. It is being left
; as a placeholder for the
; new achievements;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

alias achievement.list {
  ; CHECKING ACHIEVEMENTS
  unset %achievement.list | unset %achievement.list.2 | unset %achievement.list.3
  set %totalachievements $lines($lstfile(achievements.lst)) | set %totalachievements.unlocked 0

  var %value 1 | var %achievements.lines $lines($lstfile(achievements.lst))
  if ((%achievements.lines = $null) || (%achievements.lines = 0)) { return }

  while (%value <= %achievements.lines) {

    var %achievement.name $read -l $+ %value $lstfile(achievements.lst)
    $achievement_already_unlocked($1, %achievement.name) 

    if (%achievement.unlocked = true) {   
      inc %totalachievements.unlocked 1
      if (%achievement.name = 1.21Gigawatts) { %achievement.name = 1point21Gigawatts }

      if ($numtok(%achievement.list,46) <= 12) { %achievement.list = $addtok(%achievement.list, %achievement.name, 46) }
      else { 
        if ($numtok(%achievement.list.2,46) >= 12) { %achievement.list.3 = $addtok(%achievement.list.3, %achievement.name, 46) }
        else { %achievement.list.2 = $addtok(%achievement.list.2, %achievement.name, 46) }
      }
    }
    unset %achievement.unlocked
    inc %value 1 
  }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %achievement.list = $replace(%achievement.list, $chr(046), %replacechar)
  if (%achievement.list2 != $null) {  %achievement.list.2 = $replace(%achievement.list.2, $chr(046), %replacechar) }
  if (%achievement.list3 != $null) {  %achievement.list.3 = $replace(%achievement.list.3, $chr(046), %replacechar) }

  writeini $char($1) stuff TotalAchievements %totalachievements.unlocked
}


alias achievement_check {
  if ($readini($char($1), info, flag) != $null) { return } 
  if (%achievement.system = off) { return }

  $achievement_already_unlocked($1, $2) 

  if (%achievement.unlocked = true) {  unset %achievement.unlocked | return  }

  $set_chr_name($1)

  if ($2 = Can'tKeepAGoodManDown) {
    var %number.of.revives $readini($char($1), stuff, RevivedTimes)
    if (%number.of.revives >= 10) { writeini $char($1) achievements $2 true 
      $announce_achievement($1, $2, 200)
      $currency.add($1, gil, 200)
    }
  }



}

alias achievement_already_unlocked {
  if ($readini($char($1), achievements, $2) = true) { set %achievement.unlocked true }
}

alias announce_achievement { $set_chr_name($1) 
  $display.message($translate($2),global) 
}
