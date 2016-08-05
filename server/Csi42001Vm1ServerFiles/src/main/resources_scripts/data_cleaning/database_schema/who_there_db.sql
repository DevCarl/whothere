-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema who_there_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema who_there_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `who_there_db` DEFAULT CHARACTER SET utf8 ;
USE `who_there_db` ;

-- -----------------------------------------------------
-- Table `who_there_db`.`Buildings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Buildings` (
  `Building_id` INT(11) NOT NULL AUTO_INCREMENT,
  `Building_name` VARCHAR(45) NOT NULL,
  `Building_info` VARCHAR(400) NULL DEFAULT NULL,
  `Longitude` FLOAT NOT NULL,
  `Latitude` FLOAT NOT NULL,
  PRIMARY KEY (`Building_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `who_there_db`.`Room`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Room` (
  `Room_id` INT(11) NOT NULL AUTO_INCREMENT,
  `Room_no` VARCHAR(45) NULL DEFAULT NULL,
  `Building` VARCHAR(45) NULL DEFAULT NULL,
  `Floor_no` VARCHAR(45) NULL DEFAULT NULL,
  `Campus` VARCHAR(45) NULL DEFAULT NULL,
  `Room_active` TINYINT(1) NULL DEFAULT NULL,
  `Capacity` INT(11) NULL DEFAULT NULL,
  `Plug_friendly` TINYINT(1) NULL DEFAULT NULL,
  PRIMARY KEY (`Room_id`),
  UNIQUE INDEX `Room_id_UNIQUE` (`Room_id` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 19
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `who_there_db`.`Ground_truth_data`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Ground_truth_data` (
  `Room_Room_id` INT(11) NOT NULL,
  `Date` DATE NOT NULL,
  `Time` TIME NOT NULL,
  `Room_used` TINYINT(1) NULL DEFAULT NULL,
  `Percentage_room_full` FLOAT NULL DEFAULT NULL,
  `No_of_people` INT(11) NULL DEFAULT NULL,
  `Lecture` TINYINT(1) NULL DEFAULT NULL,
  `Tutorial` TINYINT(1) NULL DEFAULT NULL,
  PRIMARY KEY (`Room_Room_id`, `Date`, `Time`),
  INDEX `fk_ground_truth_data_Room1_idx` (`Room_Room_id` ASC),
  CONSTRAINT `fk_ground_truth_data_Room1`
    FOREIGN KEY (`Room_Room_id`)
    REFERENCES `who_there_db`.`Room` (`Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `who_there_db`.`Input_logs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Input_logs` (
  `Input_id` INT(11) NOT NULL AUTO_INCREMENT,
  `Input_timestamp` DATETIME NULL DEFAULT NULL,
  `File_name` VARCHAR(1000) NULL DEFAULT NULL,
  `Success` TINYINT(1) NULL DEFAULT NULL,
  `Error_report` VARCHAR(1000) NULL DEFAULT NULL,
  PRIMARY KEY (`Input_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 2849
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `who_there_db`.`Module`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Module` (
  `Module_code` VARCHAR(45) NOT NULL,
  `Facilty` VARCHAR(90) NULL DEFAULT NULL,
  `Course_level` VARCHAR(90) NULL DEFAULT NULL,
  `Undergrad` TINYINT(1) NULL DEFAULT NULL,
  `Module_active` TINYINT(1) NULL DEFAULT '1',
  PRIMARY KEY (`Module_code`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `who_there_db`.`Time_table`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Time_table` (
  `Date` DATE NOT NULL,
  `Time_period` TIME NOT NULL,
  `Room_Room_id` INT(11) NOT NULL,
  `Module_Module_code` VARCHAR(45) NOT NULL,
  `No_expected_students` INT(11) NULL DEFAULT NULL,
  `Tutorial` TINYINT(1) NULL DEFAULT NULL,
  `Double_module` TINYINT(1) NULL DEFAULT '0',
  `Class_went_ahead` TINYINT(1) NULL DEFAULT NULL,
  PRIMARY KEY (`Date`, `Time_period`, `Room_Room_id`),
  INDEX `fk_time_table_Room1_idx` (`Room_Room_id` ASC),
  INDEX `fk_time_table_Module1_idx` (`Module_Module_code` ASC),
  CONSTRAINT `fk_time_table_Module1`
    FOREIGN KEY (`Module_Module_code`)
    REFERENCES `who_there_db`.`Module` (`Module_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_time_table_Room1`
    FOREIGN KEY (`Room_Room_id`)
    REFERENCES `who_there_db`.`Room` (`Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `who_there_db`.`Processed_data`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Processed_data` (
  `Data_input_id` INT(11) NOT NULL,
  `Time_table_Date` DATE NOT NULL,
  `Time_table_Time_period` TIME NOT NULL,
  `Time_table_Room_Room_id` INT(11) NOT NULL,
  `Time_stamp` DATETIME NOT NULL,
  `People_estimate` FLOAT NULL COMMENT '			\n',
  `Min_people_estimate` FLOAT NULL,
  `Max_people_estimate` FLOAT NULL,
  `Logistic_occupancy` VARCHAR(45) NULL,
  `Model_type` VARCHAR(400) NULL DEFAULT NULL,
  `Model_info` VARCHAR(400) NULL DEFAULT NULL,
  PRIMARY KEY (`Data_input_id`, `Time_table_Date`, `Time_table_Time_period`, `Time_table_Room_Room_id`),
  INDEX `fk_Processed_data_Time_table1_idx` (`Time_table_Date` ASC, `Time_table_Time_period` ASC, `Time_table_Room_Room_id` ASC),
  CONSTRAINT `fk_Processed_data_Time_table1`
    FOREIGN KEY (`Time_table_Date` , `Time_table_Time_period` , `Time_table_Room_Room_id`)
    REFERENCES `who_there_db`.`Time_table` (`Date` , `Time_period` , `Room_Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `who_there_db`.`Users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Users` (
  `Users_id` INT(11) NOT NULL AUTO_INCREMENT,
  `User_name` VARCHAR(45) NOT NULL,
  `Password` CHAR(75) NOT NULL,
  `Admin` TINYINT(1) NOT NULL DEFAULT '0',
  `Acount_active` TINYINT(1) NULL DEFAULT '1',
  `Ground_truth_access_code` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`Users_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `who_there_db`.`Wifi_log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `who_there_db`.`Wifi_log` (
  `Room_Room_id` INT(11) NOT NULL,
  `Date` DATE NOT NULL,
  `Time` TIME NOT NULL,
  `Associated_client_counts` INT(11) NULL DEFAULT NULL,
  `Authenticated_client_counts` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`Room_Room_id`, `Date`, `Time`),
  INDEX `fk_wifi_log_Room1_idx` (`Room_Room_id` ASC),
  CONSTRAINT `fk_wifi_log_Room1`
    FOREIGN KEY (`Room_Room_id`)
    REFERENCES `who_there_db`.`Room` (`Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
