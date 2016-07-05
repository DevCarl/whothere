-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema who_there_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema who_there_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `who_there_db` DEFAULT CHARACTER SET utf8 ;
USE `who_there_db` ;

-- -----------------------------------------------------
-- Table `who_there_db`.`Room`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Room` (
  `Room_id` INT NOT NULL AUTO_INCREMENT,
  `Room_no` VARCHAR(45) NULL,
  `Buildling` VARCHAR(45) NULL,
  `Floor_no` VARCHAR(45) NULL,
  `Campus` VARCHAR(45) NULL,
  `Room_active` TINYINT(1) NULL,
  `Capacity` INT NULL,
  `Plug_friendly` TINYINT(1) NULL,
  PRIMARY KEY (`Room_id`),
  UNIQUE INDEX `Room_id_UNIQUE` (`Room_id` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `who_there_db`.`Module`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Module` (
  `Module_code` VARCHAR(45) NOT NULL,
  `Facilty` VARCHAR(90) NULL,
  `Course_level` VARCHAR(90) NULL,
  `Undergrad` TINYINT(1) NULL,
  `Module_active` TINYINT(1) NULL DEFAULT 1,
  PRIMARY KEY (`Module_code`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `who_there_db`.`time_table`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`time_table` (
  `Date` DATE NOT NULL,
  `Time_period` TIME NOT NULL,
  `Room_Room_id` INT NOT NULL,
  `Module_Module_code` VARCHAR(45) NOT NULL,
  `No_expected_students` INT NULL,
  `Tutorial` TINYINT(1) NULL,
  `Double_module` TINYINT(1) NULL DEFAULT 0 COMMENT '	',
  `class_went_ahead` TINYINT(1) NULL,
  PRIMARY KEY (`Date`, `Time_period`, `Room_Room_id`, `Module_Module_code`),
  INDEX `fk_time_table_Room1_idx` (`Room_Room_id` ASC),
  INDEX `fk_time_table_Module1_idx` (`Module_Module_code` ASC),
  CONSTRAINT `fk_time_table_Room1`
    FOREIGN KEY (`Room_Room_id`)
    REFERENCES `who_there_db`.`Room` (`Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_time_table_Module1`
    FOREIGN KEY (`Module_Module_code`)
    REFERENCES `who_there_db`.`Module` (`Module_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `who_there_db`.`wifi_log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`wifi_log` (
  `Wifi_log_id` INT NOT NULL AUTO_INCREMENT,
  `Room_Room_id` INT NOT NULL,
  `Date` DATE NULL,
  `Time` TIME NULL,
  `Associated_client_counts` INT NULL,
  `Authenticated_client_counts` INT NULL,
  PRIMARY KEY (`Wifi_log_id`),
  UNIQUE INDEX `wifi_log_id_UNIQUE` (`Wifi_log_id` ASC),
  INDEX `fk_wifi_log_Room1_idx` (`Room_Room_id` ASC),
  CONSTRAINT `fk_wifi_log_Room1`
    FOREIGN KEY (`Room_Room_id`)
    REFERENCES `who_there_db`.`Room` (`Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `who_there_db`.`ground_truth_data`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`ground_truth_data` (
  `Data_input_id` INT NOT NULL AUTO_INCREMENT,
  `Room_Room_id` INT NULL,
  `Date` DATE NULL,
  `Time` TIME NULL,
  `Room_used` TINYINT(1) NULL,
  `Percentage_room_full` FLOAT NULL,
  `No_of_people` INT NULL,
  `lecture` TINYINT(1) NULL,
  `tutorial` TINYINT(1) NULL,
  PRIMARY KEY (`Data_input_id`),
  INDEX `fk_ground_truth_data_Room1_idx` (`Room_Room_id` ASC),
  UNIQUE INDEX `Data_input_id_UNIQUE` (`Data_input_id` ASC),
  CONSTRAINT `fk_ground_truth_data_Room1`
    FOREIGN KEY (`Room_Room_id`)
    REFERENCES `who_there_db`.`Room` (`Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `who_there_db`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`users` (
  `users_id` INT NOT NULL,
  `user_name` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `admin` TINYINT(1) NOT NULL,
  `acount_active` TINYINT(1) NULL,
  `ground_truth_access_code` VARCHAR(45) NULL,
  PRIMARY KEY (`users_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `who_there_db`.`data_modeling_information`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`data_modeling_information` (
  `data_input_id` INT NOT NULL,
  `data` FLOAT NULL,
  PRIMARY KEY (`data_input_id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
