-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Room`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Room` (
  `Room_id` VARCHAR(45) NOT NULL,
  `Room_no` VARCHAR(45) NULL,
  `Buildling` VARCHAR(45) NULL,
  `floor_no` VARCHAR(45) NULL,
  `Campus` VARCHAR(45) NULL,
  `Room_active` TINYINT(1) NULL,
  `Capacity` VARCHAR(45) NULL,
  `Plug_friendly` TINYINT(1) NULL,
  PRIMARY KEY (`Room_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Module`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Module` (
  `Module_code` INT NOT NULL,
  `Facilty` VARCHAR(45) NULL,
  `Course_level` VARCHAR(45) NULL,
  `Undergrad` VARCHAR(45) NULL,
  PRIMARY KEY (`Module_code`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`time_table`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`time_table` (
  `date` VARCHAR(45) NOT NULL,
  `time_period` VARCHAR(45) NOT NULL,
  `Room_Room_id` VARCHAR(45) NOT NULL,
  `Module_Module_code` INT NOT NULL,
  `No_expected_students` INT NULL,
  `Lecuter` TINYINT(1) NULL,
  `Tutorial` TINYINT(1) NULL,
  `double_module` TINYINT(1) NULL,
  PRIMARY KEY (`date`, `time_period`, `Room_Room_id`, `Module_Module_code`),
  INDEX `fk_time_table_Room1_idx` (`Room_Room_id` ASC),
  INDEX `fk_time_table_Module1_idx` (`Module_Module_code` ASC),
  CONSTRAINT `fk_time_table_Room1`
    FOREIGN KEY (`Room_Room_id`)
    REFERENCES `mydb`.`Room` (`Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_time_table_Module1`
    FOREIGN KEY (`Module_Module_code`)
    REFERENCES `mydb`.`Module` (`Module_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`wifi_log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`wifi_log` (
  `wifi_log_id` INT NOT NULL AUTO_INCREMENT,
  `Room_Room_id` VARCHAR(45) NOT NULL,
  `date` VARCHAR(45) NULL,
  `time` VARCHAR(45) NULL,
  `associated_client_counts` VARCHAR(45) NULL,
  `authenticated_client_counts` VARCHAR(45) NULL,
  PRIMARY KEY (`wifi_log_id`, `Room_Room_id`),
  UNIQUE INDEX `wifi_log_id_UNIQUE` (`wifi_log_id` ASC),
  INDEX `fk_wifi_log_Room1_idx` (`Room_Room_id` ASC),
  CONSTRAINT `fk_wifi_log_Room1`
    FOREIGN KEY (`Room_Room_id`)
    REFERENCES `mydb`.`Room` (`Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`ground_truth_data`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`ground_truth_data` (
  `data_input_id` INT NOT NULL AUTO_INCREMENT,
  `Room_Room_id` VARCHAR(45) NOT NULL,
  `date` VARCHAR(45) NULL,
  `time` VARCHAR(45) NULL,
  `Room_used` TINYINT(1) NULL,
  `percentage_room_full` VARCHAR(45) NULL,
  `no_of_people` VARCHAR(45) NULL,
  `lecture` TINYINT(1) NULL,
  `tutorial` TINYINT(1) NULL,
  PRIMARY KEY (`data_input_id`, `Room_Room_id`),
  INDEX `fk_ground_truth_data_Room1_idx` (`Room_Room_id` ASC),
  CONSTRAINT `fk_ground_truth_data_Room1`
    FOREIGN KEY (`Room_Room_id`)
    REFERENCES `mydb`.`Room` (`Room_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`users` (
  `users_id` INT NOT NULL,
  `user_name` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `admin` TINYINT(1) NOT NULL,
  `acount_active` TINYINT(1) NULL,
  `ground_truth_access_code` VARCHAR(45) NULL,
  PRIMARY KEY (`users_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`data_modeling_information`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`data_modeling_information` (
  `data_input_id` INT NOT NULL,
  `data` FLOAT NULL,
  PRIMARY KEY (`data_input_id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
