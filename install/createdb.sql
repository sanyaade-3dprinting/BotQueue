  /*
    This file is part of BotQueue.

    BotQueue is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BotQueue is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BotQueue.  If not, see <http://www.gnu.org/licenses/>.
  */

SET character_set_client = utf8;

CREATE DATABASE IF NOT EXISTS botqueue;
USE botqueue;

CREATE TABLE IF NOT EXISTS `activities` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `user_id` int(11) unsigned NOT NULL,
  `activity` text NOT NULL,
  `action_date` datetime NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `bots` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `user_id` int(11) unsigned NOT NULL default '0',
  `job_id` int(11) unsigned NOT NULL default '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `identifier` varchar(255) NOT NULL DEFAULT '',
  `model` varchar(255) NOT NULL,
  `status` enum('idle', 'slicing', 'working', 'waiting', 'error', 'maintenance', 'offline') NOT NULL default 'idle',
  `last_seen` datetime NOT NULL,
  `slice_config_id` int(11) unsigned NOT NULL,
  `slice_engine_id` int(11) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`),
  KEY `identifier` (`identifier`),
  KEY `slice_config_id` (`slice_config_id`),
  KEY `slice_engine_id` (`slice_engine_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `comments` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `user_id` int(11) unsigned NOT NULL,
  `comment` text NOT NULL,
  `comment_date` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `email_queue` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `user_id` int(11) unsigned NOT NULL default '0',
  `subject` varchar(255) NOT NULL,
  `text_body` text NOT NULL,
  `html_body` text NOT NULL,
  `to_email` varchar(255) NOT NULL,
  `to_name` varchar(255) NOT NULL,
  `queue_date` datetime NOT NULL,
  `sent_date` datetime NOT NULL,
  `status` enum('queued','sent') NOT NULL default 'queued',
  UNIQUE KEY `id` (`id`),
  KEY `user_id` (`user_id`),
  KEY `status` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `jobs` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `user_id` int(11) unsigned NOT NULL default '0',
  `queue_id` int(11) unsigned NOT NULL default '0',
  `source_file_id` int(11) unsigned  NOT NULL default '0',
  `file_id` int(11) unsigned NOT NULL default '0',
  `slice_job_id` int(11) unsigned NOT NULL default '0',
  `name` varchar(255) NOT NULL,
  `status` enum('available', 'taken', 'slicing', 'downloading', 'qa', 'complete', 'failure') NOT NULL default 'available',
  `taken_time` datetime NOT NULL,
  `slice_complete_time` datetime NOT NULL,
  `start` datetime NOT NULL,
  `end` datetime NOT NULL,
  `user_sort` int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`),
  KEY `queue_id` (`queue_id`),
  KEY `status` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `oauth_consumer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `consumer_key` varchar(255) NOT NULL,
  `consumer_secret` varchar(255) NOT NULL,
  `active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `oauth_consumer_nonce` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `consumer_id` int(11) NOT NULL,
  `timestamp` bigint(20) NOT NULL,
  `nonce` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `consumer_id` (`consumer_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `oauth_token` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL,
  `consumer_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `token_secret` varchar(255) NOT NULL,
  `callback_url` text NOT NULL,
  `verifier` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `consumer_id` (`consumer_id`),
  KEY `user_id` (`user_id`),
  KEY `type` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `queues` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `user_id` int(11) unsigned NOT NULL default '0',
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `s3_files` (
  `id` bigint(11) unsigned NOT NULL auto_increment,
  `type` varchar(255) NOT NULL,
  `size` int(10) unsigned NOT NULL,
  `hash` char(32) NOT NULL,
  `bucket` varchar(255) NOT NULL,
  `path` varchar(255) NOT NULL,
  `add_date` datetime NOT NULL,
  `source_url` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `shortcodes` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `url` (`url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `tokens` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `user_id` int(11) unsigned NOT NULL,
  `hash` varchar(40) NOT NULL,
  `expire_date` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `pass_hash` (`hash`),
  KEY `expire_date` (`expire_date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `username` varchar(32) NOT NULL,
  `email` varchar(255) NOT NULL,
  `pass_hash` varchar(40) NOT NULL,
  `pass_reset_hash` char(40) NOT NULL,
  `location` varchar(255) NOT NULL,
  `birthday` date NOT NULL,
  `last_active` datetime NOT NULL,
  `registered_on` datetime NOT NULL,
  `is_admin` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `last_active` (`last_active`),
  KEY `username` (`username`),
  KEY `pass_hash` (`pass_hash`),
  KEY `email` (`email`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

alter table oauth_consumer add name varchar(255) default '';
alter table oauth_consumer add user_id int(11) default 0;

DROP TABLE IF EXISTS `slice_engines`;
CREATE TABLE `slice_engines` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `engine_name` varchar(255) NOT NULL,
  `engine_path` varchar(255) NOT NULL,
  `engine_description` text NOT NULL,
  `is_featured` tinyint(1)  NOT NULL,
  `is_public` tinyint(1) NOT NULL,
  `add_date` datetime NOT NULL,
  `default_config_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `engine_name` (`engine_name`),
  KEY `is_featured` (`is_featured`),
  KEY `is_public` (`is_public`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `slice_configs`;
CREATE TABLE `slice_configs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `fork_id` int(11) unsigned NOT NULL,
  `engine_id` int(11) unsigned NOT NULL,
  `user_id` int(11) unsigned NOT NULL,
  `config_name` varchar(255) NOT NULL,
  `config_data` text NOT NULL,
  `add_date` datetime NOT NULL,
  `edit_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fork_id` (`fork_id`),
  KEY `user_id` (`user_id`),
  KEY `engine_id` (`engine_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `slice_jobs`;
CREATE TABLE `slice_jobs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `job_id` int(11) unsigned NOT NULL,
  `input_id` int(11) unsigned NOT NULL,
  `output_id` int(11) unsigned NOT NULL,
  `output_log` text NOT NULL,
  `error_log` text,
  `slice_config_id` int(11) unsigned NOT NULL,
  `slice_config_snapshot` text NOT NULL,
  `status` enum('available', 'slicing', 'pending', 'complete', 'failure', 'expired') default 'available',
  `progress` float NOT NULL DEFAULT '0',
  `add_date` datetime NOT NULL,
  `taken_date` datetime NOT NULL,
  `finish_date` datetime NOT NULL,
  `uid` char(40) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `job_id` (`job_id`),
  KEY `slice_config_id` (`slice_config_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `slice_engines` (`id`, `engine_name`, `engine_path`, `engine_description`, `is_featured`, `is_public`, `add_date`, `default_config_id`)
VALUES
	(1,'Slic3r 0.9.2','slic3r-0.9.2','An awesome slicing engine that is compatible with RepRap, Ultimaker, RepRap, and more!',0,1,'2012-10-11 09:02:13',1),
	(2,'Slic3r 0.9.3','slic3r-0.9.3','An awesome slicing engine that is compatible with RepRap, Ultimaker, RepRap, and more!',1,1,'2012-10-11 09:04:58',2);

INSERT INTO `slice_configs` (`id`, `fork_id`, `engine_id`, `user_id`, `config_name`, `config_data`, `add_date`, `edit_date`)
VALUES
	(1,0,1,1,'Default','# generated by Slic3r 0.9.2 on Thu Oct 11 17:01:00 2012\nacceleration = 0\nbed_size = 200,200\nbed_temperature = 0\nbridge_fan_speed = 100\nbridge_flow_ratio = 1\nbridge_speed = 60\nbrim_width = 0\ncomplete_objects = 0\ncooling = 0\ndisable_fan_first_layers = 1\nduplicate = 1\nduplicate_distance = 6\nduplicate_grid = 1,1\nend_gcode = M104 S0 ; turn off temperature\\nG28 X0  ; home X axis\\nM84     ; disable motors\nexternal_perimeter_speed = 100%\nextra_perimeters = 1\nextruder_clearance_height = 20\nextruder_clearance_radius = 20\nextruder_offset = 0x0\nextrusion_axis = E\nextrusion_multiplier = 1\nextrusion_width = 0\nfan_always_on = 0\nfan_below_layer_time = 60\nfilament_diameter = 3\nfill_angle = 45\nfill_density = 0.4\nfill_pattern = rectilinear\nfirst_layer_bed_temperature = 0\nfirst_layer_extrusion_width = 200%\nfirst_layer_height = 100%\nfirst_layer_speed = 30%\nfirst_layer_temperature = 200\ng0 = 0\ngcode_arcs = 0\ngcode_comments = 0\ngcode_flavor = reprap\ninfill_acceleration = 50\ninfill_every_layers = 1\ninfill_extruder = 1\ninfill_extrusion_width = 0\ninfill_speed = 60\nlayer_gcode = \nlayer_height = 0.4\nmax_fan_speed = 100\nmin_fan_speed = 35\nmin_print_speed = 10\nnotes = \nnozzle_diameter = 0.5\nonly_retract_when_crossing_perimeters = 0\noutput_filename_format = [input_filename_base].gcode\nperimeter_acceleration = 25\nperimeter_extruder = 1\nperimeter_extrusion_width = 0\nperimeter_speed = 30\nperimeters = 3\npost_process = \nprint_center = 100,100\nrandomize_start = 1\nretract_before_travel = 2\nretract_length = 1\nretract_length_toolchange = 3\nretract_lift = 0\nretract_restart_extra = 0\nretract_restart_extra_toolchange = 0\nretract_speed = 30\nrotate = 0\nscale = 1\nskirt_distance = 6\nskirt_height = 1\nskirts = 1\nslowdown_below_layer_time = 15\nsmall_perimeter_speed = 30\nsolid_fill_pattern = rectilinear\nsolid_infill_below_area = 70\nsolid_infill_speed = 60\nsolid_layers = 3\nstart_gcode = G28 ; home all axes\nsupport_material = 0\nsupport_material_angle = 0\nsupport_material_extruder = 1\nsupport_material_extrusion_width = 0\nsupport_material_pattern = rectilinear\nsupport_material_spacing = 2.5\nsupport_material_threshold = 45\ntemperature = 200\nthreads = 2\ntop_solid_infill_speed = 50\ntravel_speed = 130\nuse_relative_e_distances = 0\nz_offset = 0\n','2012-10-11 09:02:13','2012-10-11 09:02:13'),
	(2,0,2,1,'Default','# generated by Slic3r 0.9.3 on Thu Oct 11 17:03:28 2012\nacceleration = 0\nbed_size = 200,200\nbed_temperature = 0\nbridge_fan_speed = 100\nbridge_flow_ratio = 1\nbridge_speed = 60\nbrim_width = 0\ncomplete_objects = 0\ncooling = 0\ndisable_fan_first_layers = 1\nduplicate = 1\nduplicate_distance = 6\nduplicate_grid = 1,1\nend_gcode = M104 S0 ; turn off temperature\\nG28 X0  ; home X axis\\nM84     ; disable motors\nexternal_perimeter_speed = 100%\nextra_perimeters = 1\nextruder_clearance_height = 20\nextruder_clearance_radius = 20\nextruder_offset = 0x0\nextrusion_axis = E\nextrusion_multiplier = 1\nextrusion_width = 0\nfan_always_on = 0\nfan_below_layer_time = 60\nfilament_diameter = 3\nfill_angle = 45\nfill_density = 0.4\nfill_pattern = rectilinear\nfirst_layer_bed_temperature = 0\nfirst_layer_extrusion_width = 200%\nfirst_layer_height = 100%\nfirst_layer_speed = 30%\nfirst_layer_temperature = 200\ng0 = 0\ngcode_arcs = 0\ngcode_comments = 0\ngcode_flavor = reprap\ninfill_acceleration = 50\ninfill_every_layers = 1\ninfill_extruder = 1\ninfill_extrusion_width = 0\ninfill_speed = 60\nlayer_gcode = \nlayer_height = 0.4\nmax_fan_speed = 100\nmin_fan_speed = 35\nmin_print_speed = 10\nnotes = \nnozzle_diameter = 0.5\nonly_retract_when_crossing_perimeters = 0\noutput_filename_format = [input_filename_base].gcode\nperimeter_acceleration = 25\nperimeter_extruder = 1\nperimeter_extrusion_width = 0\nperimeter_speed = 30\nperimeters = 3\npost_process = \nprint_center = 100,100\nrandomize_start = 1\nretract_before_travel = 2\nretract_length = 1\nretract_length_toolchange = 3\nretract_lift = 0\nretract_restart_extra = 0\nretract_restart_extra_toolchange = 0\nretract_speed = 30\nrotate = 0\nscale = 1\nskirt_distance = 6\nskirt_height = 1\nskirts = 1\nslowdown_below_layer_time = 15\nsmall_perimeter_speed = 30\nsolid_fill_pattern = rectilinear\nsolid_infill_below_area = 70\nsolid_infill_every_layers = 0\nsolid_infill_speed = 60\nsolid_layers = 3\nstart_gcode = G28 ; home all axes\nsupport_material = 0\nsupport_material_angle = 0\nsupport_material_extruder = 1\nsupport_material_extrusion_width = 0\nsupport_material_pattern = rectilinear\nsupport_material_spacing = 2.5\nsupport_material_threshold = 45\ntemperature = 200\nthreads = 2\ntop_solid_infill_speed = 50\ntravel_speed = 130\nuse_relative_e_distances = 0\nz_offset = 0\n','2012-10-11 09:04:58','2012-10-11 09:04:58');