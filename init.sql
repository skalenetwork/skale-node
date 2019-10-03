USE db_skale;
CREATE TABLE `report` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `my_id` int unsigned NULL,
  `target_id` int unsigned NULL,
  `is_offline` tinyint(1) unsigned NULL,
  `latency` int NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25158 DEFAULT CHARSET=utf8;
CREATE TABLE `report_event` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `my_id` int unsigned NULL,
  `target_id` int unsigned NULL,
  `downtime` int unsigned NULL,
  `latency` int unsigned NULL,
  `gas_used` DECIMAL(65) NULL,
  `tx_dt` DATETIME NULL,
  `tx_hash` CHAR(66) UNIQUE NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4196 DEFAULT CHARSET=utf8;
CREATE TABLE `bounty_event` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `my_id` int unsigned NULL,
  `bounty` VARCHAR(28) NULL,
  `downtime` int unsigned NULL,
  `latency` int unsigned NULL,
  `gas_used` DECIMAL(65) NULL,
  `tx_dt` DATETIME NULL,
  `tx_hash` CHAR(66) UNIQUE NULL,
  `block_number` int NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4196 DEFAULT CHARSET=utf8;
CREATE TABLE `bounty_stats` (
  `tx_hash` CHAR(66) NOT NULL,
  `eth_balance_before` VARCHAR(28) NULL,
  `skl_balance_before` VARCHAR(28) NULL,
  `eth_balance` VARCHAR(28) NULL,
  `skl_balance` VARCHAR(28) NULL,
  PRIMARY KEY (`tx_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;