-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.5.10-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table tgmc.mission_log
CREATE TABLE IF NOT EXISTS `mission_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patrol_id` int(11) DEFAULT NULL,
  `round_id` int(11) NOT NULL,
  `mission_type` varchar(128) NOT NULL,
  `objective_results` longtext CHARACTER SET utf8mb4 NOT NULL COMMENT 'JSON {"objective datum type" : "rating factor"}',
  `map_path` varchar(128) DEFAULT NULL,
  `meta_json` longtext CHARACTER SET utf8mb4 DEFAULT NULL,
  `last_edit` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_patrol` (`patrol_id`),
  KEY `idx_mission` (`mission_type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

-- Dumping structure for table tgmc.patrol
CREATE TABLE IF NOT EXISTS `patrol` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_round_id` int(11) NOT NULL,
  `last_round_id` int(11) DEFAULT NULL,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `meta_json` longtext CHARACTER SET utf8mb4 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
