// Objective subtypes are used as DB refs so edit existing ones with care
/datum/objective
	/// The name of this objective
	var/name
	/// This objective's theme flags see __DEFINES\patrol.dm
	var/theme_flags
	/// If this objective is force added to every mission
	var/forced = FALSE
	/// If this objective is hidden from crew and public reports
	var/hidden = FALSE
	/// This objectives success or failure rating index
	var/completion_factor = NO_COMPLETION
	/// This objectives possible completion states and rating values
	var/list/completion_ratings = list(
		MAJOR_SUCCESS = 1200,
		MINOR_SUCCESS = 400,
		NO_COMPLETION = 0,
		MINOR_FAILURE = -400,
		MAJOR_FAILURE = -1200,
	)
