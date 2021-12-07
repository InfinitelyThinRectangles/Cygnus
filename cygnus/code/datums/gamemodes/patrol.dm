/datum/game_mode/patrol
	name = "Patrol"
	config_tag = "Patrol"
	flags_xeno_abilities = ABILITY_DISTRESS
	deploy_time_lock = 30 SECONDS
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 1,
		/datum/job/terragov/requisitions/officer = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 6,
		/datum/job/terragov/medical/researcher = 2,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1
	)
	/// Typecache of all mission sub types
	var/static/list/missions_cache
	/// Initialized instance of the current mission datum
	var/datum/mission/current_mission
	/// Row id of the current active patrol in the database
	var/patrol_id

/datum/game_mode/patrol/New()
	. = ..()
	if(!missions_cache)
		missions_cache = typecacheof(/datum/mission, TRUE)

/datum/game_mode/patrol/can_start(bypass_checks)
	. = ..()
	if(!. || bypass_checks)
		return
	if(current_mission)
		return TRUE
	if(!SSdbcore.Connect())
		to_chat(world, "<b>Unable to start.</b> No database connection and no pre-selected mission.")
		return FALSE
	var/datum/db_query/verify_query = SSdbcore.NewQuery({"
		SELECT TABLE_NAME
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_SCHEMA = :db_name
		AND (TABLE_NAME = '[format_table_name("patrol")]'
			OR TABLE_NAME = '[format_table_name("mission_log")]')"}, list("db_name" = CONFIG_GET(string/feedback_database)))
	if(!verify_query.Execute(async = FALSE))
		qdel(verify_query)
		to_chat(world, "<b>Unable to start.</b> Database check query failed.")
		return FALSE
	if(verify_query.rows.len < 2)
		qdel(verify_query)
		to_chat(world, "<b>Unable to start.</b> Database tables missing.")
		return FALSE
	qdel(verify_query)

/datum/game_mode/patrol/pre_setup()
	if(LAZYACCESSASSOC(SSmapping.configs[SHIP_MAP].traits, 1, ZTRAIT_OFF_DUTY))
		return TRUE // Bypass mission and objective logic when Off Duty - patrol_id stays null

	if(!patrol_id && SSdbcore.Connect())
		// store patrol_id of ongoing patrol if there is one
		var/datum/db_query/patrol_select = SSdbcore.NewQuery({"
			SELECT id
			FROM [format_table_name("patrol")]
			WHERE last_round_id IS NULL
			ORDER BY id DESC
			LIMIT 1
		"})
		if(patrol_select.Execute(async = FALSE))
			if(LAZYACCESS(patrol_select.rows, 1))
				patrol_id = patrol_select.rows[1][1]
		qdel(patrol_select)
	if(!patrol_id && SSdbcore.Connect())
		// start a new patrol and store its patrol_id
		var/datum/db_query/insert_patrol = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("patrol")] (first_round_id, start_datetime)
			VALUES (:first_round_id, now())
		"}, list("first_round_id" = GLOB.round_id))
		insert_patrol.Execute(async = FALSE)
		patrol_id = insert_patrol.last_insert_id
		qdel(insert_patrol)

	if(current_mission)
		// a mission is already selected somehow, thanks admemes?
		if(!config_mission_map())
			to_chat(world, "<b>Failed to load the mission map config, defaulted.</b>")
			return FALSE
		return ..()

	var/datum/db_query/rating_query = SSdbcore.NewQuery({"
		SELECT rating
		FROM [format_table_name("patrol")]
		WHERE last_round_id IS NOT NULL
		ORDER BY id DESC
		LIMIT 1
	"})
	if(!rating_query.Execute(async = FALSE))
		qdel(rating_query)
		message_admins("Patrol pre_setup failed. Something is wrong check runtime errors for more info.")
		stack_trace("rating_query failed - check logs") // most likely from bypass_checks with can_start()
		return FALSE

	var/tot_rating = 0
	while(rating_query.NextRow())
		tot_rating += rating_query.item[1]
	qdel(rating_query)

	// todo: mission selection logic using tot_rating
	// for(var/_mission_path in missions_cache)
	// 	var/datum/mission/mission_path = _mission_path

	current_mission = new /datum/mission/example()

	if(!config_mission_map())
		// todo: try blacklisting this mission current_map and loading alternates?
		to_chat(world, "<b>Failed to load the mission map config, defaulted.</b>")
		return FALSE

	return ..() // lazy loads the current_mission "ground map"

/datum/game_mode/patrol/post_setup()
	. = ..()
	current_mission?.start(patrol_id)

/datum/game_mode/patrol/announce()
	to_chat(world, "<b>The current game mode is - Patrol!</b>")
	to_chat(world, "<b>Good luck and godspeed!</b>")

/datum/game_mode/patrol/check_finished()
	if(!round_finished)
		return FALSE
	return TRUE

/datum/game_mode/patrol/declare_completion()
	wrap_up()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [SSmapping.configs[SHIP_MAP].map_name].</span>")
	var/sound/S = sound(pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\\nTotal spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()

// Round end intercept
/datum/game_mode/patrol/proc/wrap_up()
	current_mission?.end()
	var/datum/map_config/next_config

	if(LAZYACCESSASSOC(SSmapping.configs[SHIP_MAP].traits, 1, ZTRAIT_OFF_DUTY))
		// currently Off Duty so load the On Duty ship map for next round
		next_config = new
		if(!next_config.LoadConfig(ON_DUTY_MAP_PATH, TRUE))
			message_admins("Patrol failed to load a ship map config [ON_DUTY_MAP_PATH].")
			CRASH("Patrol failed to load a ship map")
		if(SSmapping.changemap(next_config, SHIP_MAP))
			message_admins("Patrol changed the ship map to [next_config.map_name].")
		else
			message_admins("Patrol failed to change the ship map [ON_DUTY_MAP_PATH].")
			CRASH("Patrol failed to change the ship map")
		return

	var/patrol_time_ending
	if(patrol_id && SSdbcore.Connect())
		var/datum/db_query/patrol_check = SSdbcore.NewQuery({"
			SELECT id
			FROM [format_table_name("patrol")]
			WHERE id = :patrol_id
			AND NOW() < DATE_ADD(start_datetime, INTERVAL [PATROL_LENGTH]) -- was the current patrol started less than PATROL_LENGTH ago
		"}, list("patrol_id" = patrol_id))
		if(patrol_check.Execute(async = FALSE))
			if(!LAZYLEN(patrol_check.rows))
				patrol_time_ending = TRUE
		qdel(patrol_check)

	if(patrol_time_ending || SSevacuation.dest_status > NUKE_EXPLOSION_IN_PROGRESS) // EVACUATION_STATUS_COMPLETE also?
		var/datum/db_query/patrol_query
		var/list/rating_values = list()
		var/rating_avg = 0
		// populate rating_values
		patrol_query = SSdbcore.NewQuery({"
			SELECT objective_results
			FROM [format_table_name("mission_log")]
			WHERE patrol_id = :patrol_id
		"}, list("patrol_id" = patrol_id))
		if(patrol_query.Execute(async = TRUE))
			var/list/completions
			var/datum/objective/temp_objective
			while(patrol_query.NextRow())
				completions = json_decode(patrol_query.item[1])
				for(var/objective_type in completions)
					// todo: refactor this to be more reusable and not trash, prepare yourself it's bad
					temp_objective = new objective_type()
					if(LAZYACCESS(temp_objective.completion_ratings, completions[objective_type]))
						rating_values += temp_objective.completion_ratings[completions[objective_type]]
					qdel(temp_objective)
		else
			stack_trace("SELECT close out patrol query failed")
		qdel(patrol_query)

		// calculate rating_avg
		if(rating_values.len > 0)
			for(var/val in rating_values)
				rating_avg += val
			rating_avg = rating_avg / rating_values.len

		// finally update and close out the patrol
		patrol_query = SSdbcore.NewQuery({"
			UPDATE [format_table_name("patrol")]
			SET rating = :rating,
				last_round_id = :round_id,
				end_datetime = NOW()
			WHERE id = :patrol_id
		"}, list("patrol_id" = patrol_id, "round_id" = GLOB.round_id, "rating" = rating_avg))
		if(!patrol_query.Execute(async = FALSE))
			message_admins("Oppsie just tried but could not close out the current Patrol in the DB. Advise checking logs.")
			stack_trace("UPDATE close out patrol query failed")
		qdel(patrol_query)

		for(var/map in config.maplist[SHIP_MAP])
			var/datum/map_config/temp_config = config.maplist[SHIP_MAP][map]
			if(LAZYACCESSASSOC(temp_config.traits, 1, ZTRAIT_OFF_DUTY))
				next_config = temp_config
				break
		if(!next_config)
			message_admins("Patrol failed to find an Off Duty ship map config.")
			CRASH("Patrol failed to find an Off Duty ship map config")
		if(SSmapping.changemap(next_config, SHIP_MAP))
			message_admins("Patrol changed the ship map to [next_config.map_name].")
		else
			message_admins("Patrol failed to change the ship map [next_config.map_name].")
			CRASH("Patrol failed to change the ship map")

/// Attempt to parse and load the current_mission.current_map file
/datum/game_mode/patrol/proc/config_mission_map()
	var/datum/map_config/config = new
	. = config.LoadConfig(current_mission.current_map, TRUE, GROUND_MAP, TRUE)
	SSmapping.configs[GROUND_MAP] = config
