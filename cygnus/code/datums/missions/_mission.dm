// Mission subtypes are used as DB refs so edit existing ones with care
/datum/mission
	/// The name of this mission
	var/name
	/// This mission's theme flags from __DEFINES\patrol.dm
	var/theme_flags
	/// Minimum rating requirement for this mission, leave null for no min
	var/min_rating
	/// Maximum rating requirement for this mission, leave null for no max
	var/max_rating
	/// How many out of the possible objectives are selected, more or less dictates the mission length
	var/objectives = 3
	/// List of possible objective types for this mission
	var/list/possible_objectives = list()
	/// Paths to the possible map json(s) for this mission's z-level(s)
	var/list/possible_maps = list("_maps/cygnus_map_files/example_mission_map.json")
	/// Path to the selected map json from possible_maps
	var/current_map
	/// List of currently selected plus forced objectives in play
	var/list/datum/objective/current_objectives = list()
	/// Typecache of all objective sub types
	var/static/list/objectives_cache

/datum/mission/New()
	. = ..()
	SHOULD_CALL_PARENT(TRUE)
	if(!objectives_cache)
		objectives_cache = typecacheof(/datum/objective, TRUE)
	roll_map()
	roll_objectives()
	add_forced_objectives()

/// Select the map json for this mission
/datum/mission/proc/roll_map()
	current_map = pick(possible_maps)

/// Select the random objectives for this mission
/datum/mission/proc/roll_objectives()
	if(length(current_objectives))
		return
	// todo: make getting repeat objectives from the recent mission(s) less likely
	for(var/i in 1 to min(objectives, possible_objectives.len))
		var/selected = pick(possible_objectives)
		possible_objectives -= selected
		var/datum/objective/selected_objective = new selected(src)
		current_objectives += selected_objective

/// Find and adds all forced objectives to this mission
/datum/mission/proc/add_forced_objectives()
	for(var/_objective_path in objectives_cache)
		var/datum/objective/objective_path = _objective_path
		if(initial(objective_path.forced))
			current_objectives += new objective_path(src)

/// Clear and reselect random objectives
/datum/mission/proc/reroll_objectives()
	current_objectives = list()
	possible_objectives = initial(possible_objectives)
	roll_objectives()
	add_forced_objectives()

/// Start the mission proper
/datum/mission/proc/start()
	for(var/datum/objective/objective in current_objectives)
		objective.start()

/// End the mission proper
/datum/mission/proc/end()
	for(var/datum/objective/objective in current_objectives)
		objective.end()
