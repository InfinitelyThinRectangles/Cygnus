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

/datum/game_mode/patrol/New()
	. = ..()
	if(!missions_cache)
		missions_cache = typecacheof(/datum/mission, TRUE)

/datum/game_mode/patrol/can_start(bypass_checks)
	. = ..()
	if(!. || bypass_checks)
		return
	if(!SSdbcore.Connect())
		to_chat(world, "<b>Unable to start.</b> No database connection.")
		return FALSE
	var/datum/db_query/verify_query = SSdbcore.NewQuery({"
		SELECT TABLE_NAME
		FROM INFORMATION_SCHEMA.TABLES
		WHERE TABLE_SCHEMA = :db_name
		AND (TABLE_NAME = '[format_table_name("patrol")]'
			OR TABLE_NAME = '[format_table_name("mission_log")]')"}, list("db_name" = CONFIG_GET(string/feedback_database)))
	if(!verify_query.Execute(async = TRUE))
		qdel(verify_query)
		to_chat(world, "<b>Unable to start.</b> Database query failed.")
		return FALSE
	if(verify_query.rows.len < 2)
		qdel(verify_query)
		to_chat(world, "<b>Unable to start.</b> Database tables missing.")
		return FALSE
	qdel(verify_query)

/datum/game_mode/patrol/pre_setup()
	var/datum/db_query/rating_query = SSdbcore.NewQuery({"
		SELECT rating
		FROM [format_table_name("patrol")]
		WHERE last_round_id IS NOT NULL
		ORDER BY id DESC
		LIMIT 4
	"})
	if(!rating_query.Execute(async = TRUE))
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

	var/datum/map_config/config = new
	if(!config.LoadConfig(current_mission.current_map, TRUE, GROUND_MAP, TRUE))
		// todo: try blacklisting this mission current_map and loading alternates?
		to_chat(world, "<b>Failed to load the mission map.</b>")
		return FALSE
	SSmapping.configs[GROUND_MAP] = config

	return ..() // lazy loads the current_mission "ground map"

/datum/game_mode/patrol/post_setup()
	. = ..()
	current_mission.start()

/datum/game_mode/patrol/announce()
	to_chat(world, "<b>The current game mode is - Patrol!</b>")
	to_chat(world, "<b>Good luck and godspeed!</b>")

/datum/game_mode/patrol/check_finished()
	if(!round_finished)
		return FALSE
	return TRUE

/datum/game_mode/patrol/declare_completion()
	current_mission.end()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [SSmapping.configs[SHIP_MAP].map_name].</span>")
	var/sound/S = sound(pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\\nTotal spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()
