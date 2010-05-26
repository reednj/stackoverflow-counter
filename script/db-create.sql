-- phpMyAdmin SQL Dump
-- version 2.11.9.3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 30, 2010 at 10:09 AM
-- Server version: 5.0.51
-- PHP Version: 5.2.4-2ubuntu5.10

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `stackoverflow_count`
--

-- --------------------------------------------------------

--
-- Table structure for table `Tag`
--

CREATE TABLE IF NOT EXISTS `Tag` (
  `tag_id` int(11) NOT NULL auto_increment,
  `tag_name` varchar(128) character set latin1 NOT NULL,
  PRIMARY KEY  (`tag_id`),
  UNIQUE KEY `tag_name` (`tag_name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `TagValue`
--

CREATE TABLE IF NOT EXISTS `TagValue` (
  `value_id` int(11) NOT NULL auto_increment,
  `tag_id` int(11) NOT NULL,
  `tag_value` double NOT NULL,
  `created_date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`value_id`),
  UNIQUE KEY `tag_id` (`tag_id`,`created_date`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
