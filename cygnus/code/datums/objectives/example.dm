// This file should be unchecked in DM i.e. excluded from the .dme file list
/datum/objective/example/
	theme_flags = ASSULT | DEFENSE | ESCORT | RESCUE | RETRIEVAL | REPAIR | RESEARCH
	completion_ratings = list(
		MAJOR_SUCCESS = 1000,
		MINOR_SUCCESS = 400,
		NO_COMPLETION = 0,
		MINOR_FAILURE = -100,
		MAJOR_FAILURE = -1337,
	)

/datum/objective/example/start()
	message_admins("Starting [name] [ADMIN_VV(src)]")

// Each objective below demonstrates methods of operations which can be mixed and matched
/datum/objective/example/processing
	name = "Example Processing Objective"
	description = "Witness this processing"

/datum/objective/example/processing/start()
	START_PROCESSING(SSveryslow, src)
	return ..()

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
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGIN, .proc/mob_login)
	return ..()

/datum/objective/example/signaled/end()
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGIN)

/datum/objective/example/signaled/proc/mob_login(mob/logged_in)
	SIGNAL_HANDLER
	message_admins("[name] - mob_login")
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
