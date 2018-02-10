-- --------------------------------------------------------
-- Host:                         192.168.1.200
-- Server version:               10.2.9-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.4.0.5125
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table wellrestd.commandLog
CREATE TABLE IF NOT EXISTS `commandLog` (
  `id` varchar(50) NOT NULL,
  `commandType` varchar(255) NOT NULL,
  `createdDtm` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `usrId` int(10) unsigned DEFAULT NULL,
  `processingTIme` double unsigned NOT NULL,
  `lifecycle` text NOT NULL,
  `metadata` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Stores a full log of all commands that have been executed on the sytem';

-- Dumping data for table wellrestd.commandLog: ~1 rows (approximately)
/*!40000 ALTER TABLE `commandLog` DISABLE KEYS */;
INSERT INTO `commandLog` (`id`, `commandType`, `createdDtm`, `usrId`, `processingTIme`, `lifecycle`, `metadata`) VALUES
	('5a7ef4ecf8c25668589e9c3a', 'commands.registeruser.RegisterUserCommand', '2018-02-10 13:34:33', 0, 30002010, '{"eventCreated":636538664734110904,"eventReceived":636538664734110904,"eventDispatched":636538664764112914,"eventProcessingTime":30002010}', '{"email":"admin@example.com","userFirstName":"Administrator","password":"******","username":"admin","userLastName":"Administrator"}'),
	('5a7ef503f8c25668589e9c3b', 'commands.createprefix.CreatePrefixCommand', '2018-02-10 13:34:59', 0, 69879, '{"eventCreated":636538664990882426,"eventReceived":636538664990892149,"eventDispatched":636538664990952305,"eventProcessingTime":69879}', '{"timestamp":636538664990882426,"ipAddress":"127.0.0.1","userAgent":"PostmanRuntime/7.1.1"}'),
	('5a7ef51af8c25668589e9c3c', 'commands.assignprefix.AssignPrefixCommand', '2018-02-10 13:35:22', 1, 76633, '{"eventCreated":636538665228320893,"eventReceived":636538665228320893,"eventDispatched":636538665228397526,"eventProcessingTime":76633}', '{"usrId":1,"prefix":"BFE3C4EF"}'),
	('5a7ef51af8c25668589e9c3d', 'commands.login.LoginCommand', '2018-02-10 13:35:22', 1, 150016, '{"eventCreated":636538665228320893,"eventReceived":636538665228440830,"eventDispatched":636538665228470909,"eventProcessingTime":150016}', '{"prefix":"BFE3C4EF","ipAddress":"127.0.0.1","usrType":0,"usrId":1,"userAgent":"PostmanRuntime/7.1.1"}');
/*!40000 ALTER TABLE `commandLog` ENABLE KEYS */;

-- Dumping structure for table wellrestd.prefix
CREATE TABLE IF NOT EXISTS `prefix` (
  `prefix` varchar(10) NOT NULL,
  `usrId` int(10) unsigned DEFAULT NULL COMMENT 'Keys to the usr table, may be blank initially before the token is paired with a user',
  PRIMARY KEY (`prefix`),
  KEY `fk_prefix_usr_idx` (`usrId`),
  CONSTRAINT `fk_prefix_usr` FOREIGN KEY (`usrId`) REFERENCES `usr` (`usrId`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dumping data for table wellrestd.prefix: ~0 rows (approximately)
/*!40000 ALTER TABLE `prefix` DISABLE KEYS */;
INSERT INTO `prefix` (`prefix`, `usrId`) VALUES
	('BFE3C4EF', 1);
/*!40000 ALTER TABLE `prefix` ENABLE KEYS */;

-- Dumping structure for table wellrestd.token
CREATE TABLE IF NOT EXISTS `token` (
  `tokenCode` varchar(50) NOT NULL,
  `ipAddress` varchar(255) NOT NULL COMMENT 'The users IP address',
  `userAgent` text DEFAULT NULL,
  `prefix` varchar(10) NOT NULL COMMENT 'Keys to the prefix table',
  `expiresAt` bigint(20) NOT NULL COMMENT 'The date/time the token expires',
  `usrId` int(10) unsigned NOT NULL,
  `usrType` smallint(5) unsigned DEFAULT NULL,
  PRIMARY KEY (`tokenCode`),
  KEY `fk_tokens_prefix_idx` (`prefix`),
  KEY `fk_token_usrId_idx` (`usrId`),
  CONSTRAINT `fk_token_usrId` FOREIGN KEY (`usrId`) REFERENCES `usr` (`usrId`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_tokens_prefix` FOREIGN KEY (`prefix`) REFERENCES `prefix` (`prefix`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Dumping data for table wellrestd.token: ~0 rows (approximately)
/*!40000 ALTER TABLE `token` DISABLE KEYS */;
INSERT INTO `token` (`tokenCode`, `ipAddress`, `userAgent`, `prefix`, `expiresAt`, `usrId`, `usrType`) VALUES
	('j8iP5HSVaeVgKIhIl8t7fczm5LvXQ', '127.0.0.1', 'PostmanRuntime/7.1.1', 'BFE3C4EF', 1518273322, 1, 0);
/*!40000 ALTER TABLE `token` ENABLE KEYS */;

-- Dumping structure for table wellrestd.usr
CREATE TABLE IF NOT EXISTS `usr` (
  `usrId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `usrType` smallint(5) unsigned NOT NULL COMMENT '0 = general, 1 = admin',
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(150) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `lastName` varchar(255) NOT NULL,
  `newPasswordPin` int(10) unsigned DEFAULT NULL,
  `newPassword` varchar(150) DEFAULT NULL COMMENT 'Used to store the hash of the intended login password after a password reset request',
  `deleted` smallint(6) NOT NULL DEFAULT 0,
  `numLoginAttempts` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Is incremented whenever an incorrect password is entered',
  `lastLoginAttempt` timestamp NULL DEFAULT NULL,
  `numPinAttempts` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Incremented whenever an incorrect pin number has been entered for the password reset',
  PRIMARY KEY (`usrId`),
  UNIQUE KEY `idx_usr_username` (`username`),
  UNIQUE KEY `idx_usr_email` (`email`(191))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

-- Dumping data for table wellrestd.usr: ~2 rows (approximately)
/*!40000 ALTER TABLE `usr` DISABLE KEYS */;
INSERT INTO `usr` (`usrId`, `usrType`, `username`, `email`, `password`, `firstName`, `lastName`, `newPasswordPin`, `newPassword`, `deleted`, `numLoginAttempts`, `lastLoginAttempt`, `numPinAttempts`) VALUES
	(1, 0, 'admin', 'admin@example.com', '$2y$12$DyyWvN8Wc92LnTFi4EyPDe7CjyOBvJ87NxBRzQMYptiOWRk6c7A.a', 'Administrator', 'Administrator', NULL, NULL, 0, 0, NULL, 0);
/*!40000 ALTER TABLE `usr` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
