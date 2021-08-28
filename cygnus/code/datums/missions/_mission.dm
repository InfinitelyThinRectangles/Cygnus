// Mission subtypes are used as DB refs so edit existing ones with care
/datum/mission
	/// The name of this mission
	var/name
	/// The path to the map json for this missions z-levels
	var/map_path = "_maps/cygnus_map_files/sample_mission_map.json"
	/// This mission's theme flags from __DEFINES\patrol.dm
	var/theme_flags
	/// Minimum rating requirement for this mission, leave null for no min
	var/min_rating
	/// Maximum rating requirement for this mission, leave null for no max
	var/max_rating
	/// How many objectives this mission has, more or less dictates the length
	var/objectives = 3
	/// The list of possible objective types for this mission
	var/list/possible_objectives = list()
	/// The list of currently selected plus forced objectives in play
	var/list/current_objectives = list()
