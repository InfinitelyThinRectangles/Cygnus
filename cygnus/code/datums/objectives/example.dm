// This file should be unchecked in DM i.e. excluded from the .dme file list
/datum/objective/example/
	theme_flags = ASSULT | DEFENSE | ESCORT | RESCUE | RETRIEVAL | REPAIR | RESEARCH

// Each objective below demonstrates methods of operations which can be mixed and matched
/datum/objective/example/processing
	name = "Example Processing Objective"
	description = "Witness this processing"

/datum/objective/example/processing/start()
	message_admins("Starting [name]")
	START_PROCESSING(SSveryslow, src)

/datum/objective/example/processing/end()
	STOP_PROCESSING(SSveryslow, src)

/datum/objective/example/processing/process()
	switch(TGS_CLIENT_COUNT)
		if(0)
			set_completion(MINOR_FAILURE)
		if(1)
			set_completion(MINOR_SUCCESS)
		if(2 to INFINITY)
			set_completion(MAJOR_SUCCESS)


/datum/objective/example/signaled
	name = "Example Signaled Objective"
	description = "Witness this listening for signals"

	var/logins = 0

/datum/objective/example/signaled/start()
	message_admins("Starting [name]")
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGIN, .proc/mob_login)

/datum/objective/example/signaled/end()
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGIN)

/datum/objective/example/signaled/proc/mob_login(mob/logged_in)
	message_admins("[name] - mob_login")
	SIGNAL_HANDLER
	logins++
	switch(logins)
		if(1 to 3)
			set_completion(MINOR_SUCCESS)
		if(4 to INFINITY)
			set_completion(MAJOR_SUCCESS)


/datum/objective/example/forced
	name = "Example Forced Objective"
	description = "Witness this appear from nowhere in current_objectives"
	forced = TRUE

/datum/objective/example/forced/start()
	message_admins("Starting [name]")
