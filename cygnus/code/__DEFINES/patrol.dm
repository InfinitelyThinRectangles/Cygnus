#define PATROL_LENGTH "2 WEEK" // SQL INTERVAL - see https://mariadb.com/kb/en/date-and-time-units/
#define ON_DUTY_MAP_PATH "_maps/lucifer.json"
#define ZTRAIT_OFF_DUTY "Off Duty" // trait must be found on one shipmap's first z-level

// Mission and Objective theme flags
#define ASSULT (1<<0) // break or kill something
#define DEFENSE (1<<1) // stop something or someone from being broken, taken, or killed
#define ESCORT (1<<2) // get a person or thing from point A to B
#define RESCUE (1<<3) // get a person safely back to the ship
#define RETRIEVAL (1<<4) // get a thing safely back to the ship
#define REPAIR (1<<5) // fix something
#define RESEARCH (1<<6) // get some science done

// Objective completion_factors, some other perfect 5 letter prefixes if needed: hyper, ultra, turbo
#define SUPER_SUCCESS "3"
#define MAJOR_SUCCESS "2"
#define MINOR_SUCCESS "1"
#define NO_COMPLETION "0"
#define MINOR_FAILURE "-1"
#define MAJOR_FAILURE "-2"
#define SUPER_FAILURE "-3"
