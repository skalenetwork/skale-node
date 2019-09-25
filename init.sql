USE db_skale;
CREATE TABLE `report` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `my_id` int unsigned NULL,
  `node_id` int unsigned NULL,
  `is_dead` tinyint(1) unsigned NULL,
  `latency` int NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25158 DEFAULT CHARSET=utf8;

CREATE TABLE `bounty_event` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `my_id` int unsigned NULL,
  `tx_dt` DATETIME NULL,
  `tx_hash` CHAR(66) UNIQUE NULL,
  `bounty` VARCHAR(28) NULL,
  `latency` int unsigned NULL,
  `downtime` int unsigned NULL,
  `gas` int unsigned NULL,
  `stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4196 DEFAULT CHARSET=utf8;

CREATE TABLE `bounty_receipt` (
  `tx_hash` CHAR(66) NOT NULL,
  `eth_balance_before` VARCHAR(28) NULL,
  `skl_balance_before` VARCHAR(28) NULL,
  `eth_balance` VARCHAR(28) NULL,
  `skl_balance` VARCHAR(28) NULL,
  `gas_used` DECIMAL(65) NULL,
  PRIMARY KEY (`tx_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

