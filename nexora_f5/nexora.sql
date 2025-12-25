CREATE TABLE IF NOT EXISTS `nexora_playtime` (
    `identifier` VARCHAR(64) NOT NULL,
    `playtime` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;