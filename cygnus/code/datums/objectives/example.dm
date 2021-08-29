// This file should be unchecked in DM i.e. excluded from the .dme file list
/datum/objective/example_processing
	name = "Witness this processing"
	description = "Success in numbers"
	theme_flags = ASSULT | DEFENSE | ESCORT | RESCUE | RETRIEVAL | REPAIR | RESEARCH

/datum/objective/example_processing/start()
	START_PROCESSING(SSveryslow, src)

/datum/objective/example_processing/process()
	switch(TGS_CLIENT_COUNT)
		if(0)
			set_completion(MINOR_FAILURE)
		if(1)
			set_completion(MINOR_SUCCESS)
		if(2 to INFINITY)
			set_completion(MAJOR_SUCCESS)

/datum/objective/example_processing/end()
	STOP_PROCESSING(SSveryslow, src)
