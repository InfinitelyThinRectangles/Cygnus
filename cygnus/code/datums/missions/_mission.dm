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
	/// Row id of this mission log in the database
	var/mission_id

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

/// Find and add all forced objectives to this mission
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

/// Push the latest objective results to the database
/datum/mission/proc/update_db_log()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!SSdbcore.Connect() || !mission_id)
		return

	var/datum/db_query/update_mission = SSdbcore.NewQuery({"
		UPDATE [format_table_name("mission_log")]
		SET objective_results = :objective_results
		WHERE id = :mission_id
	"}, list("mission_id" = mission_id, "objective_results" = json_encode(get_completion_list())))
	update_mission.Execute(async = TRUE)
	qdel(update_mission)

/// Returns an assoc list of "[type]" = "[completion_factor]" for current_objectives
/datum/mission/proc/get_completion_list()
	SHOULD_NOT_OVERRIDE(TRUE)
	var/list/completions = list()
	for(var/datum/objective/objective in current_objectives)
		completions[objective.type] = objective.completion_factor
	return completions

/// Start the mission proper and create database record
/datum/mission/proc/start(patrol_id)
	SHOULD_CALL_PARENT(TRUE)
	if(SSdbcore.Connect())
		var/datum/db_query/insert_mission = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("mission_log")] (patrol_id, round_id, mission_type, objective_results, map_path)
			VALUES (:patrol_id, :round_id, :mission_type, :objective_results, :map_path)
		"}, list("patrol_id" = patrol_id, "round_id" = GLOB.round_id, "mission_type" = type, "objective_results" = json_encode(get_completion_list()), "map_path" = current_map))
		insert_mission.Execute(async = FALSE)
		mission_id = insert_mission.last_insert_id
		qdel(insert_mission)
	for(var/datum/objective/objective in current_objectives)
		objective.start()

/// End the mission proper
/datum/mission/proc/end()
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/objective/objective in current_objectives)
		objective.end()
