// Objective subtypes are used as DB refs so edit existing ones with care
/datum/objective
	/// The name of this objective
	var/name
	/// The description for this objective
	var/description
	/// This objective's theme flags - see __DEFINES\patrol.dm
	var/theme_flags = NONE
	/// If this objective is force added to every mission
	var/forced = FALSE
	/// If this objective is hidden from crew and public reports
	var/hidden = FALSE
	/// This objectives success or failure rating index
	var/completion_factor = NO_COMPLETION
	/// Possible completion states and rating values - see __DEFINES\patrol.dm
	var/list/completion_ratings = list(
		MAJOR_SUCCESS = 1200,
		MINOR_SUCCESS = 400,
		NO_COMPLETION = 0,
		MINOR_FAILURE = -400,
		MAJOR_FAILURE = -1200,
	)
	/// Mission that spawned this objective
	var/datum/mission/parent_mission

/datum/objective/New(mission)
	. = ..()
	SHOULD_CALL_PARENT(TRUE)
	parent_mission = mission

/// Entry point for objective logic. Called after map load. Override to register signals, start processing, setup mobs and objects etc..
/datum/objective/proc/start()
	return

/// Exit point for objective logic. Override to unregister signals, stop processing etc..
/datum/objective/proc/end()
	return

/// Checks if the define has a value and if so updates completion_factor
/datum/objective/proc/set_completion(factor)
	if(!(factor in completion_ratings))
		message_admins("Objective '[name]' tried to set completion to '[factor]' which is invalid.")
		CRASH("Objective '[name]' tried to set completion to '[factor]' which is invalid")
	if(completion_factor == factor)
		return

	completion_factor = factor
	if(parent_mission)
		INVOKE_ASYNC(parent_mission, /datum/mission/.proc/update_db_log)
