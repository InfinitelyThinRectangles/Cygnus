# The modularization handbook - Cygnus style, v0.1

**Failure to follow this guide will result in your PR being laughed at.**

**Pretty much just refrence what's below and the skyrat-tg modularization handbook at this time: https://github.com/skyrat-SS13/skyrat-tg/blob/master/modular_skyrat/readme.md**

## Non-modular changes to the core code - IMPORTANT

Every once in a while, there comes a time, where editing the core files becomes inevitable.

In those cases, we've decided to apply the following convention, with examples:

- **Addition:**

  ```byond
  //CYGNUS ADDITION BEGIN - SHUTTLE_TOGGLE
  var/adminEmergencyNoRecall = FALS
  var/lastMode = SHUTTLE_IDLE
  var/lastCallTime = 6000
  //CYGNUS ADDITION END
  ```
  For just one line:
  ```byond
  var/lastMode = SHUTTLE_IDLE //CYGNUS ADDITION - SHUTTLE_TOGGLE
  ```

- **Removal:**

  ```byond
  /* CYGNUS REMOVAL BEGIN - SHUTTLE_TOGGLE
  for(var/obj/docking_port/stationary/S in stationary)
    if(S.id = id)
      return S
  */ //CYGNUS REMOVAL END
  WARNING("couldn't find dock with id: [id]")
  ```

- **Small Change:**

  ```byond
  //if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE) - TGMC ORIGINAL
  if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE, SHUTTLE_DISABLED) // CYGNUS EDIT - SHUTTLE_TOGGLE
      return 1
  ```

- **Override:**

  If a proc requires many changes it may be better to just make a new version if replacing the whole file is not desired:
  ```byond
  /* CYGNUS OVERRIDE BEGIN - SHUTTLE_TOGGLE (see modified version at bottom of file)
  /client/proc/admin_call_shuttle()
  set category = "Admin - Events"
  set name = "Call Shuttle"

  if(EMERGENCY_AT_LEAST_DOCKED)
    return

  if(!check_rights(R_ADMIN))
    return

  var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
  if(confirm != "Yes")
    return

  SSshuttle.emergency.request()
  SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
  log_admin("[key_name(usr)] admin-called the emergency shuttle.")
  message_admins("<span class='adminnotice'>[key_name_admin(usr)] admin-called the emergency shuttle.</span>")
  return
  */ //CYGNUS OVERRIDE END
  ```
  Then at the bottom of the file:
  ```byond
  //CYGNUS ADDITION BEGIN - SHUTTLE_TOGGLE
  /client/proc/admin_call_shuttle()
     ...
  ```
