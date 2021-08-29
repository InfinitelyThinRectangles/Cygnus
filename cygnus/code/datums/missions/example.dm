// This file should be unchecked in DM i.e. excluded from the .dme file list
/datum/mission/example
	name = "Example Mission"
	theme_flags = ASSULT | DEFENSE | ESCORT | RESCUE | RETRIEVAL | REPAIR | RESEARCH
	min_rating = -1000
	max_rating = -900
	objectives = 1
	possible_objectives = list(/datum/objective/example_processing)
	possible_maps = list("_maps/cygnus_map_files/example_mission_map.json")

/datum/mission/start()
	. = ..()
	message_admins("Starting [name]")
