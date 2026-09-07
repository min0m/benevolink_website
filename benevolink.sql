-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 24, 2026 at 04:01 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `benevolink`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_record_feature_event` (IN `p_actor_id` INT, IN `p_event_name` VARCHAR(80), IN `p_entity_type` VARCHAR(80), IN `p_entity_id` INT, IN `p_page` VARCHAR(80), IN `p_metadata` JSON)   BEGIN
    INSERT INTO feature_events (actor_id, event_name, entity_type, entity_id, page, metadata_json)
    VALUES (p_actor_id, p_event_name, p_entity_type, p_entity_id, p_page, p_metadata);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `applications`
--

CREATE TABLE `applications` (
  `id` int(11) NOT NULL,
  `mission_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `motivation` text DEFAULT NULL,
  `status` enum('pending','accepted','rejected','canceled') NOT NULL DEFAULT 'pending',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `applications`
--

INSERT INTO `applications` (`id`, `mission_id`, `member_id`, `motivation`, `status`, `reviewed_by`, `reviewed_at`, `created_at`) VALUES
(1, 1, 5, 'I can help with logistics and welcoming families.', 'accepted', 2, '2026-04-10 09:00:00', '2026-04-17 13:59:12'),
(2, 1, 6, 'Available the full day and comfortable with distribution.', 'rejected', 2, '2026-04-10 09:30:00', '2026-04-17 13:59:12'),
(3, 3, 6, 'I have experience helping younger students.', 'accepted', 3, '2026-04-11 10:00:00', '2026-04-17 13:59:12'),
(4, 3, 5, 'I can join weekend tutoring sessions.', 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(5, 6, 7, 'I live nearby and want to help with cleanup.', 'accepted', 2, '2026-04-12 11:00:00', '2026-04-17 13:59:12'),
(6, 7, 8, 'I can support packing and coordination.', 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(7, 8, 9, 'I enjoy mentoring teenagers and can facilitate discussions.', 'accepted', 3, '2026-04-13 14:00:00', '2026-04-17 13:59:12'),
(8, 9, 10, 'I have gardening experience.', 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(9, 10, 5, 'I can help organize supplies accurately.', 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(10, 11, 6, 'I can support math revision.', 'accepted', 3, '2026-04-14 15:00:00', '2026-04-17 13:59:12'),
(11, 12, 7, 'I can explain recycling simply to children.', 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(12, 2, 8, 'I can help with donation labeling.', 'accepted', 2, '2026-04-15 09:00:00', '2026-04-17 13:59:12'),
(14, 11, 5, '', 'pending', NULL, NULL, '2026-04-17 15:07:56'),
(15, 13, 5, '', 'accepted', 11, '2026-04-17 17:15:02', '2026-04-17 15:14:42'),
(16, 13, 12, '', 'accepted', 1, '2026-04-18 16:07:47', '2026-04-18 14:05:15'),
(17, 13, 13, 'IM SO DUMB', 'accepted', 1, '2026-04-19 22:03:32', '2026-04-19 20:01:36');

--
-- Triggers `applications`
--
DELIMITER $$
CREATE TRIGGER `trg_application_insert` AFTER INSERT ON `applications` FOR EACH ROW BEGIN
    INSERT INTO feature_events (actor_id, event_name, entity_type, entity_id, page, metadata_json)
    VALUES (NEW.member_id, 'application_created', 'application', NEW.id, 'database', JSON_OBJECT('mission_id', NEW.mission_id, 'status', NEW.status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_application_status_update` AFTER UPDATE ON `applications` FOR EACH ROW BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO feature_events (actor_id, event_name, entity_type, entity_id, page, metadata_json)
        VALUES (NEW.reviewed_by, 'application_status_changed', 'application', NEW.id, 'database', JSON_OBJECT('mission_id', NEW.mission_id, 'old_status', OLD.status, 'new_status', NEW.status));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `approval_requests`
--

CREATE TABLE `approval_requests` (
  `id` int(11) NOT NULL,
  `request_type` varchar(50) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `requester_id` int(11) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `member_id` int(11) DEFAULT NULL,
  `title` varchar(180) NOT NULL,
  `details` varchar(500) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `decided_by` int(11) DEFAULT NULL,
  `decided_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approval_requests`
--

INSERT INTO `approval_requests` (`id`, `request_type`, `entity_id`, `requester_id`, `owner_id`, `member_id`, `title`, `details`, `status`, `decided_by`, `decided_at`, `created_at`, `updated_at`) VALUES
(1, 'association', 1, 2, 2, NULL, 'Association approval: Croissant Solidaire', 'We coordinate food support for families facing financial hardship.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(2, 'association', 2, 3, 3, NULL, 'Association approval: Jeunes pour Tous', 'We support children and teenagers through tutoring, reading clubs and mentoring.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(3, 'association', 3, 4, 4, NULL, 'Association approval: Care Neighbors', 'We connect volunteers with isolated elderly people and families needing social support.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(4, 'association', 4, 2, 2, NULL, 'Association approval: Green Streets', 'Community cleanups and small urban gardening actions.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(5, 'association', 5, 11, 11, NULL, 'Association approval: LIONS', 'educate you', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(8, 'mission', 1, 2, 2, NULL, 'Mission approval: Food parcel distribution', 'Prepare and distribute essential food parcels for vulnerable households.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(9, 'mission', 2, 2, 2, NULL, 'Mission approval: Donation sorting day', 'Sort clothing and essential donations before dispatch.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(10, 'mission', 3, 3, 3, NULL, 'Mission approval: Primary tutoring support', 'Help children with reading, homework and confidence-building.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(11, 'mission', 4, 3, 3, NULL, 'Mission approval: Community reading circle', 'Facilitate a calm reading session and creative activity.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(12, 'mission', 5, 4, 4, NULL, 'Mission approval: Elderly visit support', 'Offer weekly companionship visits to isolated elderly people.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(13, 'mission', 6, 2, 2, NULL, 'Mission approval: Neighborhood cleanup sprint', 'Join a morning cleanup and awareness action.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(14, 'mission', 7, 2, 2, NULL, 'Mission approval: Ramadan meal prep team', 'Help prepare and pack hot meals with the kitchen team.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(15, 'mission', 8, 3, 3, NULL, 'Mission approval: Teen career discovery workshop', 'Support teenagers during a discovery workshop.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(16, 'mission', 9, 2, 2, NULL, 'Mission approval: Urban garden planting day', 'Plant herbs and small trees in a shared community garden.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(17, 'mission', 10, 2, 2, NULL, 'Mission approval: Back-to-school kit assembly', 'Prepare school kits for children from low-income families.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(18, 'mission', 11, 3, 3, NULL, 'Mission approval: Exam revision weekend', 'Support students with revision planning and calm study routines.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(19, 'mission', 12, 2, 2, NULL, 'Mission approval: Recycling awareness booth', 'Run a small booth explaining recycling basics to families.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(20, 'mission', 13, 11, 11, NULL, 'Mission approval: Workshop Arduino', 'FREE intro to robotics', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(23, 'event', 1, 2, 2, NULL, 'Event approval: Solidarity open day', 'A public day to present local aid actions and recruit new volunteers.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(24, 'event', 2, 3, 3, NULL, 'Event approval: Education volunteer meetup', 'A calm meetup for tutoring volunteers and parents.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(25, 'event', 3, 2, 2, NULL, 'Event approval: Clean city morning', 'Community cleanup plus awareness circle.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(26, 'event', 4, 4, 4, NULL, 'Event approval: Care network briefing', 'Training session for future elderly support volunteers.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(27, 'event', 5, 2, 2, NULL, 'Event approval: Food bank orientation', 'Intro session for first-time volunteers.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(28, 'event', 6, 3, 3, NULL, 'Event approval: Children reading festival', 'Reading booths and creative workshops.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(29, 'event', 7, 2, 2, NULL, 'Event approval: Garden neighbors picnic', 'Community picnic after urban garden work.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(30, 'event', 8, 2, 2, NULL, 'Event approval: Donor thank-you evening', 'Small recognition event for donors and volunteers.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(31, 'event', 9, 3, 3, NULL, 'Event approval: Mentor training lab', 'Practical training for youth mentors.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(32, 'event', 10, 2, 2, NULL, 'Event approval: Recycling family workshop', 'Interactive awareness event for children and parents.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(38, 'feedback', 1, NULL, NULL, NULL, 'Feedback moderation: Simple and respectful', 'I found a mission in minutes and the association contacted me quickly.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(39, 'feedback', 2, 5, NULL, 5, 'Feedback moderation: Clear process', 'The dashboard helped me understand what was accepted and what still needed review.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(40, 'feedback', 3, NULL, NULL, NULL, 'Feedback moderation: Useful for discovery', 'The filters made it easy to find missions near my city.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(41, 'feedback', 4, 6, NULL, 6, 'Feedback moderation: Good for volunteering hours', 'Tracking validated hours is very helpful for my student file.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(42, 'feedback', 5, NULL, NULL, NULL, 'Feedback moderation: Professional experience', 'It feels trustworthy and organized, not like a random listing page.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(43, 'feedback', 6, 7, NULL, 7, 'Feedback moderation: Nice mission cards', 'The cards show dates, city and association clearly.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(44, 'feedback', 7, NULL, NULL, NULL, 'Feedback moderation: Great for associations', 'The approval process gives confidence that content is reviewed.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(45, 'feedback', 8, 8, NULL, 8, 'Feedback moderation: Fast registration', 'The registration flow is short and easy to understand.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(46, 'feedback', 9, NULL, NULL, NULL, 'Feedback moderation: Human and clear', 'I like that the platform focuses on real community needs.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(47, 'feedback', 10, 9, NULL, 9, 'Feedback moderation: Motivating', 'Seeing approved feedbacks and real missions makes the platform feel alive.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(53, 'application', 1, 5, 2, 5, 'Volunteer application: Food parcel distribution', 'I can help with logistics and welcoming families.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(54, 'application', 2, 6, 2, 6, 'Volunteer application: Food parcel distribution', 'Available the full day and comfortable with distribution.', 'rejected', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(55, 'application', 3, 6, 3, 6, 'Volunteer application: Primary tutoring support', 'I have experience helping younger students.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(56, 'application', 4, 5, 3, 5, 'Volunteer application: Primary tutoring support', 'I can join weekend tutoring sessions.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(57, 'application', 5, 7, 2, 7, 'Volunteer application: Neighborhood cleanup sprint', 'I live nearby and want to help with cleanup.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(58, 'application', 6, 8, 2, 8, 'Volunteer application: Ramadan meal prep team', 'I can support packing and coordination.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(59, 'application', 7, 9, 3, 9, 'Volunteer application: Teen career discovery workshop', 'I enjoy mentoring teenagers and can facilitate discussions.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(60, 'application', 8, 10, 2, 10, 'Volunteer application: Urban garden planting day', 'I have gardening experience.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(61, 'application', 9, 5, 2, 5, 'Volunteer application: Back-to-school kit assembly', 'I can help organize supplies accurately.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(62, 'application', 10, 6, 3, 6, 'Volunteer application: Exam revision weekend', 'I can support math revision.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(63, 'application', 11, 7, 2, 7, 'Volunteer application: Recycling awareness booth', 'I can explain recycling simply to children.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(64, 'application', 12, 8, 2, 8, 'Volunteer application: Donation sorting day', 'I can help with donation labeling.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(65, 'application', 14, 5, 3, 5, 'Volunteer application: Exam revision weekend', '', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(66, 'application', 15, 5, 11, 5, 'Volunteer application: Workshop Arduino', '', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(68, 'event_registration', 1, 5, 2, 5, 'Event registration: Solidarity open day', 'Seat request for Tunis on 2026-05-09', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(69, 'event_registration', 2, 6, 3, 6, 'Event registration: Education volunteer meetup', 'Seat request for Sfax on 2026-05-13', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(70, 'event_registration', 3, 7, 2, 7, 'Event registration: Clean city morning', 'Seat request for Ariana on 2026-05-20', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(71, 'event_registration', 4, 8, 2, 8, 'Event registration: Food bank orientation', 'Seat request for Tunis on 2026-04-30', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(72, 'event_registration', 5, 9, 3, 9, 'Event registration: Children reading festival', 'Seat request for Sfax on 2026-06-12', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(73, 'event_registration', 6, 10, 2, 10, 'Event registration: Donor thank-you evening', 'Seat request for Tunis on 2026-06-28', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(74, 'event_registration', 7, 6, 3, 6, 'Event registration: Mentor training lab', 'Seat request for Sfax on 2026-05-30', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(75, 'event_registration', 8, 7, 2, 7, 'Event registration: Recycling family workshop', 'Seat request for Ariana on 2026-07-03', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(76, 'event_registration', 9, 8, 2, 8, 'Event registration: Solidarity open day', 'Seat request for Tunis on 2026-05-09', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(77, 'event_registration', 10, 5, 3, 5, 'Event registration: Education volunteer meetup', 'Seat request for Sfax on 2026-05-13', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(83, 'hours', 1, 5, 2, 5, 'Volunteer hours: Food parcel distribution', '5.00h on 2026-04-20 — Parcel preparation and distribution support.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(84, 'hours', 2, 8, 2, 8, 'Volunteer hours: Donation sorting day', '4.00h on 2026-04-24 — Sorting and box labeling.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(85, 'hours', 3, 6, 3, 6, 'Volunteer hours: Primary tutoring support', '2.50h on 2026-04-19 — Tutoring session with primary students.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(86, 'hours', 4, 9, 3, 9, 'Volunteer hours: Teen career discovery workshop', '3.00h on 2026-05-11 — Mentoring workshop support.', 'pending', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(87, 'hours', 5, 6, 3, 6, 'Volunteer hours: Exam revision weekend', '2.00h on 2026-05-25 — Revision planning assistance.', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(88, 'hours', 6, 5, 11, 5, 'Volunteer hours: Workshop Arduino', '2.00h on 2026-04-17 — ', 'approved', NULL, NULL, '2026-04-17 15:16:50', '2026-04-17 15:16:50'),
(89, 'application', 16, 12, 11, 12, 'Volunteer application: Workshop Arduino', 'mouhib applied for this mission.', 'approved', 1, '2026-04-18 16:07:47', '2026-04-18 14:05:15', '2026-04-18 14:07:47'),
(90, 'application', 17, 13, 11, 13, 'Volunteer application: Workshop Arduino', 'yomn applied for this mission.', 'approved', 1, '2026-04-19 22:03:32', '2026-04-19 20:01:36', '2026-04-19 20:03:32');

-- --------------------------------------------------------

--
-- Table structure for table `associations`
--

CREATE TABLE `associations` (
  `id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `name` varchar(160) NOT NULL,
  `category` varchar(80) NOT NULL,
  `description` text NOT NULL,
  `mission_statement` varchar(255) DEFAULT NULL,
  `city` varchar(80) NOT NULL,
  `address` varchar(180) DEFAULT NULL,
  `email` varchar(160) DEFAULT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `website` varchar(180) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `associations`
--

INSERT INTO `associations` (`id`, `owner_id`, `name`, `category`, `description`, `mission_statement`, `city`, `address`, `email`, `phone`, `website`, `status`, `created_at`) VALUES
(1, 2, 'Croissant Solidaire', 'Food aid', 'We coordinate food support for families facing financial hardship.', 'Practical help, dignity and reliable neighborhood support.', 'Tunis', '12 Avenue Habib Bourguiba', 'contact@croissant.test', '+216 71 111 111', 'https://croissant.example', 'approved', '2026-04-17 13:59:12'),
(2, 3, 'Jeunes pour Tous', 'Education', 'We support children and teenagers through tutoring, reading clubs and mentoring.', 'Learning confidence for every child, one session at a time.', 'Sfax', '8 Rue de la Liberté', 'contact@jeunes.test', '+216 74 222 222', 'https://jeunes.example', 'approved', '2026-04-17 13:59:12'),
(3, 4, 'Care Neighbors', 'Care', 'We connect volunteers with isolated elderly people and families needing social support.', 'Human presence matters.', 'Nabeul', '22 Rue des Jasmins', 'contact@care.test', '+216 72 333 333', NULL, 'pending', '2026-04-17 13:59:12'),
(4, 2, 'Green Streets', 'Environment', 'Community cleanups and small urban gardening actions.', 'Cleaner streets, stronger neighborhoods.', 'Ariana', '4 Rue des Oliviers', 'green@croissant.test', '+216 70 444 444', NULL, 'approved', '2026-04-17 13:59:12'),
(5, 11, 'LIONS', 'education', 'educate you', 'Awaiting admin review.', 'tunis', NULL, 'gastonayari5@gmail.com', NULL, NULL, 'approved', '2026-04-17 15:10:51');

-- --------------------------------------------------------

--
-- Table structure for table `association_messages`
--

CREATE TABLE `association_messages` (
  `id` int(11) NOT NULL,
  `association_id` int(11) NOT NULL,
  `sender_user_id` int(11) DEFAULT NULL,
  `sender_name` varchar(120) NOT NULL,
  `sender_email` varchar(160) NOT NULL,
  `message` text NOT NULL,
  `status` enum('new','read','archived') NOT NULL DEFAULT 'new',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `association_messages`
--

INSERT INTO `association_messages` (`id`, `association_id`, `sender_user_id`, `sender_name`, `sender_email`, `message`, `status`, `created_at`) VALUES
(1, 1, 5, 'Yasmine Mansour', 'yasmine@demo.test', 'I am available next weekend and would like to know if I should bring any documents.', 'new', '2026-04-17 15:06:02'),
(2, 2, 6, 'Ali Gharbi', 'ali@demo.test', 'Can volunteers join the tutoring program for a full semester?', 'new', '2026-04-17 15:06:02'),
(3, 1, NULL, 'Local Partner', 'partner@example.com', 'We want to coordinate a donation drive with your team.', 'new', '2026-04-17 15:06:02');

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) DEFAULT NULL,
  `action` varchar(80) NOT NULL,
  `entity_type` varchar(80) NOT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `actor_id`, `action`, `entity_type`, `entity_id`, `details`, `created_at`) VALUES
(1, 1, 'status_change', 'association', 5, 'Status changed to approved', '2026-04-17 15:13:03'),
(2, 1, 'status_change', 'mission', 13, 'Status changed to approved', '2026-04-17 15:14:18'),
(3, NULL, 'database_upgrade', 'approval_requests', NULL, 'Admin-final approval workflow installed', '2026-04-17 15:16:50'),
(4, 1, 'admin_review_application', 'application', 16, 'Admin final decision: accepted', '2026-04-18 14:07:47'),
(5, 1, 'admin_review_application', 'application', 17, 'Admin final decision: accepted', '2026-04-19 20:03:32');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `id` int(11) NOT NULL,
  `association_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `title` varchar(180) NOT NULL,
  `summary` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `city` varchar(80) NOT NULL,
  `event_date` date NOT NULL,
  `capacity` int(11) NOT NULL DEFAULT 1,
  `status` enum('pending','approved','rejected','closed') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`id`, `association_id`, `owner_id`, `title`, `summary`, `description`, `city`, `event_date`, `capacity`, `status`, `created_at`) VALUES
(1, 1, 2, 'Solidarity open day', 'A public day to present local aid actions and recruit new volunteers.', 'Meet associations, discover missions and join practical mini-workshops.', 'Tunis', '2026-05-09', 80, 'approved', '2026-04-17 13:59:12'),
(2, 2, 3, 'Education volunteer meetup', 'A calm meetup for tutoring volunteers and parents.', 'Exchange methods, review needs and prepare upcoming sessions.', 'Sfax', '2026-05-13', 45, 'approved', '2026-04-17 13:59:12'),
(3, 4, 2, 'Clean city morning', 'Community cleanup plus awareness circle.', 'A short, organized action for residents and families.', 'Ariana', '2026-05-20', 60, 'approved', '2026-04-17 13:59:12'),
(4, 3, 4, 'Care network briefing', 'Training session for future elderly support volunteers.', 'Safety rules, communication basics and care route explanation.', 'Nabeul', '2026-05-16', 30, 'pending', '2026-04-17 13:59:12'),
(5, 1, 2, 'Food bank orientation', 'Intro session for first-time volunteers.', 'Learn the parcel flow, hygiene basics and beneficiary welcome approach.', 'Tunis', '2026-04-30', 35, 'approved', '2026-04-17 13:59:12'),
(6, 2, 3, 'Children reading festival', 'Reading booths and creative workshops.', 'A welcoming event for families and young readers.', 'Sfax', '2026-06-12', 90, 'approved', '2026-04-17 13:59:12'),
(7, 4, 2, 'Garden neighbors picnic', 'Community picnic after urban garden work.', 'Informal gathering to celebrate volunteers and residents.', 'Ariana', '2026-06-21', 50, 'pending', '2026-04-17 13:59:12'),
(8, 1, 2, 'Donor thank-you evening', 'Small recognition event for donors and volunteers.', 'Share results, stories and next campaign needs.', 'Tunis', '2026-06-28', 70, 'approved', '2026-04-17 13:59:12'),
(9, 2, 3, 'Mentor training lab', 'Practical training for youth mentors.', 'Short exercises, role examples and facilitation methods.', 'Sfax', '2026-05-30', 32, 'approved', '2026-04-17 13:59:12'),
(10, 4, 2, 'Recycling family workshop', 'Interactive awareness event for children and parents.', 'Simple sorting games and practical household tips.', 'Ariana', '2026-07-03', 40, 'approved', '2026-04-17 13:59:12');

-- --------------------------------------------------------

--
-- Table structure for table `event_registrations`
--

CREATE TABLE `event_registrations` (
  `id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `status` enum('pending','accepted','rejected','canceled') NOT NULL DEFAULT 'pending',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `event_registrations`
--

INSERT INTO `event_registrations` (`id`, `event_id`, `member_id`, `status`, `reviewed_by`, `reviewed_at`, `created_at`) VALUES
(1, 1, 5, 'accepted', 2, '2026-04-15 09:00:00', '2026-04-17 13:59:12'),
(2, 2, 6, 'accepted', 3, '2026-04-16 09:00:00', '2026-04-17 13:59:12'),
(3, 3, 7, 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(4, 5, 8, 'accepted', 2, '2026-04-17 10:00:00', '2026-04-17 13:59:12'),
(5, 6, 9, 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(6, 8, 10, 'accepted', 2, '2026-04-18 11:00:00', '2026-04-17 13:59:12'),
(7, 9, 6, 'accepted', 3, '2026-04-19 12:00:00', '2026-04-17 13:59:12'),
(8, 10, 7, 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(9, 1, 8, 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(10, 2, 5, 'accepted', 3, '2026-04-20 08:30:00', '2026-04-17 13:59:12');

--
-- Triggers `event_registrations`
--
DELIMITER $$
CREATE TRIGGER `trg_event_registration_insert` AFTER INSERT ON `event_registrations` FOR EACH ROW BEGIN
    INSERT INTO feature_events (actor_id, event_name, entity_type, entity_id, page, metadata_json)
    VALUES (NEW.member_id, 'event_registration_created', 'event_registration', NEW.id, 'database', JSON_OBJECT('event_id', NEW.event_id, 'status', NEW.status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_event_registration_update` AFTER UPDATE ON `event_registrations` FOR EACH ROW BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO feature_events (actor_id, event_name, entity_type, entity_id, page, metadata_json)
        VALUES (NEW.reviewed_by, 'event_registration_status_changed', 'event_registration', NEW.id, 'database', JSON_OBJECT('event_id', NEW.event_id, 'old_status', OLD.status, 'new_status', NEW.status));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `feature_events`
--

CREATE TABLE `feature_events` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) DEFAULT NULL,
  `session_id` varchar(128) DEFAULT NULL,
  `event_name` varchar(80) NOT NULL,
  `entity_type` varchar(80) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `page` varchar(80) DEFAULT NULL,
  `metadata_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata_json`)),
  `ip_address` varchar(64) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `feature_events`
--

INSERT INTO `feature_events` (`id`, `actor_id`, `session_id`, `event_name`, `entity_type`, `entity_id`, `page`, `metadata_json`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 1, NULL, 'database_upgrade_imported', 'system', NULL, 'setup', '{\"version\": \"interactive-dashboard-v1\"}', NULL, NULL, '2026-04-17 15:06:02'),
(2, 1, NULL, 'admin_dashboard_ready', 'dashboard', NULL, 'dashboard', '{\"feature\": \"usage analytics\"}', NULL, NULL, '2026-04-17 15:06:02'),
(3, 5, NULL, 'member_profile_enriched', 'member', 5, 'dashboard', '{\"skills\": 3}', NULL, NULL, '2026-04-17 15:06:02'),
(4, 2, NULL, 'owner_inbox_ready', 'association', 1, 'dashboard', '{\"messages\": 2}', NULL, NULL, '2026-04-17 15:06:02'),
(5, 5, NULL, 'application_created', 'application', 14, 'database', '{\"mission_id\": 11, \"status\": \"pending\"}', NULL, NULL, '2026-04-17 15:07:56'),
(6, 5, NULL, 'application_created', 'application', 15, 'database', '{\"mission_id\": 13, \"status\": \"pending\"}', NULL, NULL, '2026-04-17 15:14:42'),
(7, 11, NULL, 'application_status_changed', 'application', 15, 'database', '{\"mission_id\": 13, \"old_status\": \"pending\", \"new_status\": \"accepted\"}', NULL, NULL, '2026-04-17 15:15:02'),
(8, 5, NULL, 'hours_submitted', 'volunteer_hours', 6, 'database', '{\"mission_id\": 13, \"hours\": 2.00, \"status\": \"pending\"}', NULL, NULL, '2026-04-17 15:15:34'),
(9, 11, NULL, 'hours_status_changed', 'volunteer_hours', 6, 'database', '{\"mission_id\": 13, \"old_status\": \"pending\", \"new_status\": \"approved\", \"hours\": 2.00}', NULL, NULL, '2026-04-17 15:16:09'),
(10, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:17:54'),
(11, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"B\\n            BenevolinkOwner workspace\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:17:55'),
(12, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:17:55'),
(13, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:00'),
(14, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"AG\\n                    \\n                        Ayari\\n                        Owner\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:00'),
(15, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'dashboard_refresh', NULL, NULL, 'home', '{\"label\":\"chart refresh\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:03'),
(16, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Refresh\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:03'),
(17, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'dashboard_refresh', NULL, NULL, 'home', '{\"label\":\"chart refresh\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:04'),
(18, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Refresh\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:04'),
(19, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:05'),
(20, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:05'),
(21, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:05'),
(22, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:05'),
(23, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:06'),
(24, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:06'),
(25, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:09'),
(26, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:09'),
(27, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:09'),
(28, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:18:09'),
(29, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Refresh\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:22:18'),
(30, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'dashboard_refresh', NULL, NULL, 'home', '{\"label\":\"chart refresh\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:22:18'),
(31, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:22:19'),
(32, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:22:20'),
(33, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:23:13'),
(34, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:23:14'),
(35, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:29:48'),
(36, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:00'),
(37, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:00'),
(38, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:00'),
(39, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:00'),
(40, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:01'),
(41, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:01'),
(42, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:06'),
(43, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:06'),
(44, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:06'),
(45, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:30:06'),
(46, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:17'),
(47, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:17'),
(48, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:17'),
(49, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:17'),
(50, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:18'),
(51, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:18'),
(52, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:23'),
(53, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:23'),
(54, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:23'),
(55, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:31:23'),
(56, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:46:03'),
(57, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:46:03'),
(58, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:46:03'),
(59, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 15:46:03'),
(60, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:50'),
(61, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:50'),
(62, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'events', '{\"page\":\"events\",\"title\":\"Events\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:51'),
(63, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Events\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=events\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:51'),
(64, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:51'),
(65, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:51'),
(66, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:52'),
(67, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:52'),
(68, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:55'),
(69, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:55'),
(70, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:56'),
(71, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:56'),
(72, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:59'),
(73, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:59'),
(74, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:59'),
(75, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:24:59'),
(76, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Public missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:01'),
(77, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:01'),
(78, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"View mission\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=mission&id=3\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:07'),
(79, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'mission', '{\"page\":\"mission\",\"title\":\"Mission details\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:07'),
(80, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open command menu\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:12'),
(81, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:13'),
(82, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:16'),
(83, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Stories\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=feedback\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:17'),
(84, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'feedback', '{\"page\":\"feedback\",\"title\":\"Community stories\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:17'),
(85, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'associations', '{\"page\":\"associations\",\"title\":\"Associations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:17'),
(86, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Associations\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=associations\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:18'),
(87, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:18'),
(88, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:18'),
(89, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:19'),
(90, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:19'),
(91, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:19'),
(92, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:19'),
(93, 11, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'home', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:20'),
(94, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:20'),
(95, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:22'),
(96, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:22'),
(97, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:25'),
(98, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:25'),
(99, NULL, 'h7ihb0ess6l07gf2olci4hsk00', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:25'),
(100, 1, 'h7ihb0ess6l07gf2olci4hsk00', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 16:25:25'),
(101, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 13:59:42'),
(102, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 13:59:47'),
(103, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 13:59:47'),
(104, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:00:22'),
(105, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:00:22'),
(106, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:00:25'),
(107, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:00:25'),
(108, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open command menu\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:00:38'),
(109, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:00:55'),
(110, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:00:55'),
(111, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:00:56'),
(112, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:00:56'),
(113, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:01:06'),
(114, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:01:06'),
(115, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:01:13'),
(116, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:01:13'),
(117, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:01:13'),
(118, 1, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:01:13'),
(119, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"☀\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:01:54'),
(120, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"◐\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:01:56'),
(121, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Public missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:26'),
(122, 1, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:26'),
(123, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Apply filters\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:33'),
(124, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"unknown_form\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:33'),
(125, 1, '5j7k19ou77nevepanuimhrc8ko', 'filter_search_submit', NULL, NULL, 'home', '{\"label\":\"page=missions&q=lions&city=&category=&association=\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:33'),
(126, 1, '5j7k19ou77nevepanuimhrc8ko', 'mission_search', 'mission', NULL, 'missions', '{\"filters\":{\"q\":\"lions\",\"city\":\"\",\"category\":\"\",\"association\":\"\"},\"results\":1}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:33'),
(127, 1, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:33'),
(128, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Quick jump\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:39'),
(129, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:42'),
(130, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:42'),
(131, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'missions', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:42'),
(132, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:43'),
(133, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:44'),
(134, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:44'),
(135, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:51'),
(136, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:02:51'),
(137, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:03:23'),
(138, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:03:23'),
(139, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:03:25'),
(140, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:03:25'),
(141, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Create member account\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:04'),
(142, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'join', '{\"action\":\"register_member\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:04'),
(143, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"register_member\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:05'),
(144, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:05'),
(145, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:31'),
(146, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:31'),
(147, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:31'),
(148, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:31'),
(149, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:45'),
(150, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:45'),
(151, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:45'),
(152, 12, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:46'),
(153, 12, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:55'),
(154, 12, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Public missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:04:55'),
(155, 12, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Apply filters\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:09'),
(156, 12, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"unknown_form\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:09'),
(157, 12, '5j7k19ou77nevepanuimhrc8ko', 'filter_search_submit', NULL, NULL, 'home', '{\"label\":\"page=missions&q=robotics&city=&category=&association=\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:09'),
(158, 12, '5j7k19ou77nevepanuimhrc8ko', 'mission_search', 'mission', NULL, 'missions', '{\"filters\":{\"q\":\"robotics\",\"city\":\"\",\"category\":\"\",\"association\":\"\"},\"results\":1}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:09'),
(159, 12, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:09'),
(160, 12, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"View mission\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=mission&id=13\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:13'),
(161, 12, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'mission', '{\"page\":\"mission\",\"title\":\"Mission details\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:13'),
(162, 12, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Send application\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:15'),
(163, 12, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"apply_mission\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:15'),
(164, 12, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'mission', '{\"action\":\"apply_mission\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:15'),
(165, 12, NULL, 'application_created', 'application', 16, 'database', '{\"mission_id\": 13, \"status\": \"pending\"}', NULL, NULL, '2026-04-18 14:05:15'),
(166, 12, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'mission', '{\"page\":\"mission\",\"title\":\"Mission details\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:15'),
(167, 12, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:20'),
(168, 12, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:20'),
(169, 12, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'mission', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:20'),
(170, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:20'),
(171, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:21'),
(172, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:21'),
(173, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:24'),
(174, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:24'),
(175, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:33'),
(176, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:33'),
(177, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:33');
INSERT INTO `feature_events` (`id`, `actor_id`, `session_id`, `event_name`, `entity_type`, `entity_id`, `page`, `metadata_json`, `ip_address`, `user_agent`, `created_at`) VALUES
(178, 11, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:34'),
(179, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔3\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:41'),
(180, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔3\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:43'),
(181, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔3\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:44'),
(182, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Command menu\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:05:53'),
(183, 11, '5j7k19ou77nevepanuimhrc8ko', 'chart_point_focus', NULL, NULL, 'home', '{\"label\":\"Workshop Arduino\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:06:00'),
(184, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Workshop Arduino\\n                    \\n                    2\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:06:00'),
(185, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Workshop Arduino\\n                    \\n                    2\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:06:01'),
(186, 11, '5j7k19ou77nevepanuimhrc8ko', 'chart_point_focus', NULL, NULL, 'home', '{\"label\":\"Workshop Arduino\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:06:01'),
(187, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Events\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=events\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:06:37'),
(188, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'events', '{\"page\":\"events\",\"title\":\"Events\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:06:37'),
(189, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"AG\\n                    \\n                        Ayari\\n                        Owner\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:06:40'),
(190, 11, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:06:40'),
(191, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:18'),
(192, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:18'),
(193, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:18'),
(194, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:18'),
(195, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:23'),
(196, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:23'),
(197, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:26'),
(198, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:26'),
(199, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:32'),
(200, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:32'),
(201, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:32'),
(202, 1, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:32'),
(203, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Approve\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:47'),
(204, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"review_application\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:47'),
(205, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"review_application\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:47'),
(206, 1, NULL, 'application_status_changed', 'application', 16, 'database', '{\"mission_id\": 13, \"old_status\": \"pending\", \"new_status\": \"accepted\"}', NULL, NULL, '2026-04-18 14:07:47'),
(207, 1, '5j7k19ou77nevepanuimhrc8ko', 'admin_application_decision', 'application', 16, 'dashboard', '{\"status\":\"accepted\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:47'),
(208, 1, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:47'),
(209, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:50'),
(210, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:50'),
(211, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:50'),
(212, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:50'),
(213, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:51'),
(214, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:51'),
(215, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:53'),
(216, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:53'),
(217, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:58'),
(218, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:58'),
(219, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:58'),
(220, 11, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:07:58'),
(221, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'feedback', '{\"page\":\"feedback\",\"title\":\"Community stories\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:16'),
(222, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Feedback\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=feedback\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:16'),
(223, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Events\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=events\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:35'),
(224, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'events', '{\"page\":\"events\",\"title\":\"Events\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:35'),
(225, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Associations\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=associations\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:39'),
(226, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'associations', '{\"page\":\"associations\",\"title\":\"Associations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:39'),
(227, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Association onboarding\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join#owner\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:45'),
(228, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:45'),
(229, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'feedback', '{\"page\":\"feedback\",\"title\":\"Community stories\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:49'),
(230, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Public feedback\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=feedback\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:50'),
(231, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'associations', '{\"page\":\"associations\",\"title\":\"Associations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:53'),
(232, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Associations\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=associations\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 14:08:53'),
(233, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:54:36'),
(234, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:54:40'),
(235, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:54:40'),
(236, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'home', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:54:40'),
(237, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:54:40'),
(238, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open command menu\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:26'),
(239, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:34'),
(240, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:34'),
(241, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Apply filters\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:40'),
(242, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"unknown_form\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:40'),
(243, NULL, '5j7k19ou77nevepanuimhrc8ko', 'filter_search_submit', NULL, NULL, 'home', '{\"label\":\"page=missions&q=lions&city=&category=&association=\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:40'),
(244, NULL, '5j7k19ou77nevepanuimhrc8ko', 'mission_search', 'mission', NULL, 'missions', '{\"filters\":{\"q\":\"lions\",\"city\":\"\",\"category\":\"\",\"association\":\"\"},\"results\":1}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:40'),
(245, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:40'),
(246, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Apply filters\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:45'),
(247, NULL, '5j7k19ou77nevepanuimhrc8ko', 'filter_search_submit', NULL, NULL, 'home', '{\"label\":\"page=missions&q=&city=&category=&association=\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:45'),
(248, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"unknown_form\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:45'),
(249, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:45'),
(250, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Events\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=events\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:52'),
(251, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'events', '{\"page\":\"events\",\"title\":\"Events\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:52'),
(252, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Associations\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=associations\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:56'),
(253, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'associations', '{\"page\":\"associations\",\"title\":\"Associations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:55:56'),
(254, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Stories\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=feedback\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:03'),
(255, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'feedback', '{\"page\":\"feedback\",\"title\":\"Community stories\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:03'),
(256, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:12'),
(257, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:14'),
(258, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:15'),
(259, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:15'),
(260, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:15'),
(261, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:23'),
(262, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:27'),
(263, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:27'),
(264, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:42'),
(265, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:42'),
(266, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:45'),
(267, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:45'),
(268, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:50'),
(269, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:50'),
(270, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:50'),
(271, 1, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:56:50'),
(272, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔2\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:57:49'),
(273, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔2\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:57:56'),
(274, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔2\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:57:57'),
(275, 1, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:57:58'),
(276, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Public missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:57:58'),
(277, 1, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'events', '{\"page\":\"events\",\"title\":\"Events\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:03'),
(278, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Events\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=events\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:03'),
(279, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Associations\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=associations\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:04'),
(280, 1, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'associations', '{\"page\":\"associations\",\"title\":\"Associations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:04'),
(281, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Stories\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=feedback\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:05'),
(282, 1, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'feedback', '{\"page\":\"feedback\",\"title\":\"Community stories\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:05'),
(283, 1, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:06'),
(284, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:06'),
(285, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"NP\\n                    \\n                        Nadia\\n                        Admin\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:07'),
(286, 1, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:07'),
(287, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:29'),
(288, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:29'),
(289, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:29'),
(290, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:29'),
(291, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:31'),
(292, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:31'),
(293, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:40'),
(294, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:40'),
(295, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:40'),
(296, 11, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:58:40'),
(297, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:33'),
(298, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Public missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:33'),
(299, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:36'),
(300, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:36'),
(301, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Events\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=events\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:36'),
(302, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'events', '{\"page\":\"events\",\"title\":\"Events\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:36'),
(303, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Associations\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=associations\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:37'),
(304, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'associations', '{\"page\":\"associations\",\"title\":\"Associations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:37'),
(305, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:37'),
(306, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:37'),
(307, 11, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:38'),
(308, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:38'),
(309, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:39'),
(310, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:39'),
(311, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'home', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:39'),
(312, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:39'),
(313, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:40'),
(314, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 19:59:40'),
(315, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Create member account\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:07'),
(316, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Create member account\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:09'),
(317, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'join', '{\"action\":\"register_member\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:09'),
(318, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"register_member\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:09'),
(319, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:09'),
(320, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:11'),
(321, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:11'),
(322, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:13'),
(323, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:13'),
(324, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:16'),
(325, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:16'),
(326, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:16'),
(327, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:16'),
(328, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:29'),
(329, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:29'),
(330, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:29'),
(331, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:29'),
(332, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:42'),
(333, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:42'),
(334, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:42'),
(335, 13, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:00:42'),
(336, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Social impact\\n                            Workshop Arduino\\n                            tunis · Apr 22, 2026\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=mission&id=13\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:22'),
(337, 13, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'mission', '{\"page\":\"mission\",\"title\":\"Mission details\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:22'),
(338, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Send application\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:36'),
(339, 13, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"apply_mission\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:36'),
(340, 13, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'mission', '{\"action\":\"apply_mission\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:36'),
(341, 13, NULL, 'application_created', 'application', 17, 'database', '{\"mission_id\": 13, \"status\": \"pending\"}', NULL, NULL, '2026-04-19 20:01:36'),
(342, 13, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'mission', '{\"page\":\"mission\",\"title\":\"Mission details\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:36'),
(343, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:43'),
(344, 13, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:43'),
(345, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:44'),
(346, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:45'),
(347, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:46');
INSERT INTO `feature_events` (`id`, `actor_id`, `session_id`, `event_name`, `entity_type`, `entity_id`, `page`, `metadata_json`, `ip_address`, `user_agent`, `created_at`) VALUES
(348, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"YY\\n                    \\n                        yomn\\n                        Member\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:46'),
(349, 13, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:46'),
(350, 13, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:54'),
(351, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:54'),
(352, 13, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:54'),
(353, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:54'),
(354, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:57'),
(355, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:57'),
(356, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:01:59'),
(357, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:03'),
(358, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:03'),
(359, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:03'),
(360, 11, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:03'),
(361, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔5\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:12'),
(362, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:50'),
(363, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:50'),
(364, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:50'),
(365, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:50'),
(366, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:51'),
(367, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:51'),
(368, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:53'),
(369, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:53'),
(370, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:56'),
(371, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:56'),
(372, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:56'),
(373, 1, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:56'),
(374, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔3\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:02:59'),
(375, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔3\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:01'),
(376, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"review_application\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:32'),
(377, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Approve\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:32'),
(378, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"review_application\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:32'),
(379, 1, NULL, 'application_status_changed', 'application', 17, 'database', '{\"mission_id\": 13, \"old_status\": \"pending\", \"new_status\": \"accepted\"}', NULL, NULL, '2026-04-19 20:03:32'),
(380, 1, '5j7k19ou77nevepanuimhrc8ko', 'admin_application_decision', 'application', 17, 'dashboard', '{\"status\":\"accepted\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:32'),
(381, 1, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:32'),
(382, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:35'),
(383, 1, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:35'),
(384, 1, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:35'),
(385, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:35'),
(386, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:37'),
(387, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:37'),
(388, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:41'),
(389, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:41'),
(390, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:41'),
(391, 11, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"owner\",\"title\":\"Association operations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:41'),
(392, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔6\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:42'),
(393, 11, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:45'),
(394, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:45'),
(395, 11, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:45'),
(396, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:45'),
(397, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:47'),
(398, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:47'),
(399, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:48'),
(400, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:48'),
(401, NULL, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:54'),
(402, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:54'),
(403, NULL, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:54'),
(404, 13, '5j7k19ou77nevepanuimhrc8ko', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:03:54'),
(405, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:04:05'),
(406, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:04:07'),
(407, 13, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:04:19'),
(408, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Public missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:04:19'),
(409, 13, '5j7k19ou77nevepanuimhrc8ko', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:04:31'),
(410, 13, '5j7k19ou77nevepanuimhrc8ko', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:04:31'),
(411, 13, '5j7k19ou77nevepanuimhrc8ko', 'form_submit', 'action', NULL, 'missions', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:04:31'),
(412, NULL, '5j7k19ou77nevepanuimhrc8ko', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-19 20:04:31'),
(413, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:25'),
(414, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Home\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=home\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:28'),
(415, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:28'),
(416, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open command menu\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:37'),
(417, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:43'),
(418, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Toggle dark mode\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:43'),
(419, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:46'),
(420, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:46'),
(421, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:48'),
(422, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:48'),
(423, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:52'),
(424, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:52'),
(425, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:56'),
(426, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:56'),
(427, NULL, 'roks0ea34rpla233dlm0c0o6h8', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:56'),
(428, 1, 'roks0ea34rpla233dlm0c0o6h8', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:27:56'),
(429, 1, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔3\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:29:00'),
(430, 1, 'roks0ea34rpla233dlm0c0o6h8', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔3\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:29:06'),
(431, NULL, 'l80q2i88c3a0tmcqqagad6ckah', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:29:50'),
(432, NULL, 'l80q2i88c3a0tmcqqagad6ckah', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:30:01'),
(433, NULL, 'l80q2i88c3a0tmcqqagad6ckah', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:30:01'),
(434, NULL, '3rfp0m65a8mp1m0d76ld1vnm1b', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 09:37:12'),
(435, NULL, 'ak7a6ckrhm0jcborg1ps0ui4f6', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-20 10:20:19'),
(436, NULL, '93ou9blsjvo2r69dng1btv1n8p', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-22 17:46:50'),
(437, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:36:40'),
(438, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:36:48'),
(439, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:36:49'),
(440, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'associations', '{\"page\":\"associations\",\"title\":\"Associations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:36:52'),
(441, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'events', '{\"page\":\"events\",\"title\":\"Events\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:36:54'),
(442, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'feedback', '{\"page\":\"feedback\",\"title\":\"Community stories\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:36:54'),
(443, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:36:56'),
(444, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:36:57'),
(445, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:25'),
(446, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open command menu\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:40'),
(447, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Events\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=events\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:44'),
(448, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'events', '{\"page\":\"events\",\"title\":\"Events\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:44'),
(449, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'associations', '{\"page\":\"associations\",\"title\":\"Associations\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:46'),
(450, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Associations\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=associations\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:46'),
(451, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Stories\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=feedback\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:47'),
(452, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'feedback', '{\"page\":\"feedback\",\"title\":\"Community stories\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:47'),
(453, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:50'),
(454, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:50'),
(455, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:52'),
(456, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:52'),
(457, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:55'),
(458, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:55'),
(459, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:55'),
(460, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:51:56'),
(461, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:01'),
(462, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"NP\\n                    \\n                        Nadia\\n                        Admin\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:02'),
(463, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:02'),
(464, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'feedback', '{\"page\":\"feedback\",\"title\":\"Community stories\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:05'),
(465, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"NP\\n                    \\n                        Nadia\\n                        Admin\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:07'),
(466, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:07'),
(467, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:09'),
(468, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"NP\\n                    \\n                        Nadia\\n                        Admin\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:11'),
(469, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:11'),
(470, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:18'),
(471, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:18'),
(472, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:19'),
(473, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:19'),
(474, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:39'),
(475, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:39'),
(476, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:44'),
(477, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:44'),
(478, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:44'),
(479, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:44'),
(480, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:46'),
(481, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"MM\\n                    \\n                        mouhib\\n                        Member\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:47'),
(482, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:47'),
(483, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:51'),
(484, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:52:51'),
(485, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:20'),
(486, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:22'),
(487, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:22'),
(488, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:25'),
(489, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:25'),
(490, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:25'),
(491, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:25'),
(492, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:31'),
(493, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:32'),
(494, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Public missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:43'),
(495, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:43'),
(496, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open command menu\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:46'),
(497, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Stories\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=feedback\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:49'),
(498, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'feedback', '{\"page\":\"feedback\",\"title\":\"Community stories\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:49'),
(499, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"MM\\n                    \\n                        mouhib\\n                        Member\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:49'),
(500, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:50'),
(501, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:51'),
(502, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:52'),
(503, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"🔔1\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:52'),
(504, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Mark read\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:53'),
(505, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"mark_notifications\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:53'),
(506, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"mark_notifications\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:53'),
(507, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:53'),
(508, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Public missions\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=missions\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:55'),
(509, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'missions', '{\"page\":\"missions\",\"title\":\"Mission discovery\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:55'),
(510, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"MM\\n                    \\n                        mouhib\\n                        Member\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=dashboard\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:56'),
(511, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"member\",\"title\":\"Member impact dashboard\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:56'),
(512, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:58'),
(513, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:58'),
(514, 12, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:58'),
(515, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:58'),
(516, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'join', '{\"page\":\"join\",\"title\":\"Join\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:59'),
(517, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Join\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=join\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:58:59'),
(518, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign in\",\"href\":\"http://localhost/benevolink_human_pro/index.php?page=login\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:01');
INSERT INTO `feature_events` (`id`, `actor_id`, `session_id`, `event_name`, `entity_type`, `entity_id`, `page`, `metadata_json`, `ip_address`, `user_agent`, `created_at`) VALUES
(519, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'login', '{\"page\":\"login\",\"title\":\"Sign in\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:01'),
(520, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Open dashboard\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:04'),
(521, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"login\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:04'),
(522, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit', 'action', NULL, 'login', '{\"action\":\"login\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:04'),
(523, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'workspace_view', 'dashboard', NULL, 'dashboard', '{\"role\":\"admin\",\"title\":\"Admin command center\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:04'),
(524, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'ui_click', NULL, NULL, 'home', '{\"label\":\"Sign out\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:18'),
(525, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit_client', NULL, NULL, 'home', '{\"label\":\"logout\",\"href\":\"\",\"value\":\"\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:18'),
(526, 1, 'd6js9ib9mujed2jc23ss37ubc7', 'form_submit', 'action', NULL, 'dashboard', '{\"action\":\"logout\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:18'),
(527, NULL, 'd6js9ib9mujed2jc23ss37ubc7', 'page_view', 'page', NULL, 'home', '{\"page\":\"home\",\"title\":\"Volunteer management platform\"}', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-24 13:59:18');

-- --------------------------------------------------------

--
-- Table structure for table `feedbacks`
--

CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `author_name` varchar(120) NOT NULL,
  `email` varchar(160) DEFAULT NULL,
  `rating` tinyint(4) NOT NULL DEFAULT 5,
  `title` varchar(140) NOT NULL,
  `message` text NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `reviewed_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `feedbacks`
--

INSERT INTO `feedbacks` (`id`, `user_id`, `author_name`, `email`, `rating`, `title`, `message`, `status`, `reviewed_by`, `created_at`) VALUES
(1, NULL, 'Leila N.', 'leila@example.com', 5, 'Simple and respectful', 'I found a mission in minutes and the association contacted me quickly.', 'approved', 1, '2026-04-05 08:00:00'),
(2, 5, 'Yasmine Mansour', 'yasmine@demo.test', 5, 'Clear process', 'The dashboard helped me understand what was accepted and what still needed review.', 'approved', 1, '2026-04-06 09:00:00'),
(3, NULL, 'Sami R.', 'sami@example.com', 4, 'Useful for discovery', 'The filters made it easy to find missions near my city.', 'approved', 1, '2026-04-07 10:00:00'),
(4, 6, 'Ali Gharbi', 'ali@demo.test', 5, 'Good for volunteering hours', 'Tracking validated hours is very helpful for my student file.', 'approved', 1, '2026-04-08 11:00:00'),
(5, NULL, 'Mouna B.', 'mouna@example.com', 5, 'Professional experience', 'It feels trustworthy and organized, not like a random listing page.', 'pending', NULL, '2026-04-09 12:00:00'),
(6, 7, 'Meriem Saidi', 'meriem@demo.test', 4, 'Nice mission cards', 'The cards show dates, city and association clearly.', 'approved', 1, '2026-04-10 13:00:00'),
(7, NULL, 'Hatem K.', 'hatem@example.com', 5, 'Great for associations', 'The approval process gives confidence that content is reviewed.', 'approved', 1, '2026-04-11 14:00:00'),
(8, 8, 'Omar Mejri', 'omar@demo.test', 4, 'Fast registration', 'The registration flow is short and easy to understand.', 'pending', NULL, '2026-04-12 15:00:00'),
(9, NULL, 'Nour A.', 'nour@example.com', 5, 'Human and clear', 'I like that the platform focuses on real community needs.', 'approved', 1, '2026-04-13 16:00:00'),
(10, 9, 'Lina Kacem', 'lina@demo.test', 5, 'Motivating', 'Seeing approved feedbacks and real missions makes the platform feel alive.', 'approved', 1, '2026-04-14 17:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `impact_goals`
--

CREATE TABLE `impact_goals` (
  `id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `association_id` int(11) NOT NULL,
  `title` varchar(160) NOT NULL,
  `target_hours` decimal(8,2) NOT NULL DEFAULT 100.00,
  `target_participants` int(11) NOT NULL DEFAULT 20,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('active','completed','paused') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `impact_goals`
--

INSERT INTO `impact_goals` (`id`, `owner_id`, `association_id`, `title`, `target_hours`, `target_participants`, `start_date`, `end_date`, `status`, `created_at`) VALUES
(1, 2, 1, 'Spring food-aid campaign', 120.00, 35, '2026-04-01', '2026-06-30', 'active', '2026-04-17 15:06:02'),
(2, 3, 2, 'Tutoring semester impact', 180.00, 25, '2026-04-01', '2026-07-15', 'active', '2026-04-17 15:06:02');

-- --------------------------------------------------------

--
-- Table structure for table `member_skills`
--

CREATE TABLE `member_skills` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `skill` varchar(100) NOT NULL,
  `level` enum('beginner','intermediate','advanced') NOT NULL DEFAULT 'intermediate',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `member_skills`
--

INSERT INTO `member_skills` (`id`, `user_id`, `skill`, `level`, `updated_at`) VALUES
(1, 5, 'Food distribution', 'advanced', '2026-04-17 15:06:02'),
(2, 5, 'Communication', 'intermediate', '2026-04-17 15:06:02'),
(3, 5, 'Event support', 'intermediate', '2026-04-17 15:06:02'),
(4, 6, 'Tutoring', 'advanced', '2026-04-17 15:06:02'),
(5, 6, 'Child mentoring', 'intermediate', '2026-04-17 15:06:02'),
(6, 7, 'Logistics', 'advanced', '2026-04-17 15:06:02'),
(7, 8, 'Community outreach', 'intermediate', '2026-04-17 15:06:02');

-- --------------------------------------------------------

--
-- Table structure for table `missions`
--

CREATE TABLE `missions` (
  `id` int(11) NOT NULL,
  `association_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `category` varchar(80) NOT NULL,
  `title` varchar(180) NOT NULL,
  `summary` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `city` varchar(80) NOT NULL,
  `address` varchar(180) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `seats` int(11) NOT NULL DEFAULT 1,
  `status` enum('draft','pending','approved','rejected','closed') NOT NULL DEFAULT 'pending',
  `approval_note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `missions`
--

INSERT INTO `missions` (`id`, `association_id`, `owner_id`, `category`, `title`, `summary`, `description`, `city`, `address`, `start_date`, `end_date`, `seats`, `status`, `approval_note`, `created_at`) VALUES
(1, 1, 2, 'Food aid', 'Food parcel distribution', 'Prepare and distribute essential food parcels for vulnerable households.', 'Volunteers help assemble parcels, verify delivery lists, welcome beneficiaries and support dignified doorstep distribution.', 'Tunis', 'Community center, Tunis', '2026-04-20', '2026-04-20', 8, 'approved', NULL, '2026-04-17 13:59:12'),
(2, 1, 2, 'Logistics', 'Donation sorting day', 'Sort clothing and essential donations before dispatch.', 'Volunteers classify items by type and condition, prepare boxes, label packages and help the team keep a clear inventory.', 'Ariana', 'Croissant Solidaire storage room', '2026-04-24', '2026-04-24', 6, 'approved', NULL, '2026-04-17 13:59:12'),
(3, 2, 3, 'Education', 'Primary tutoring support', 'Help children with reading, homework and confidence-building.', 'Volunteers work in small groups with children, explain simple exercises, encourage participation and share progress notes.', 'Sfax', 'Youth learning room', '2026-04-18', '2026-06-10', 5, 'approved', NULL, '2026-04-17 13:59:12'),
(4, 2, 3, 'Events', 'Community reading circle', 'Facilitate a calm reading session and creative activity.', 'Volunteers prepare the room, welcome children, guide reading time and animate a simple creative exercise.', 'Sfax', 'Municipal library', '2026-04-28', '2026-04-28', 4, 'pending', NULL, '2026-04-17 13:59:12'),
(5, 3, 4, 'Care', 'Elderly visit support', 'Offer weekly companionship visits to isolated elderly people.', 'Volunteers provide respectful social presence, simple conversation and light support while following the association safety checklist.', 'Nabeul', 'Neighborhood care route', '2026-05-02', '2026-06-30', 10, 'pending', NULL, '2026-04-17 13:59:12'),
(6, 4, 2, 'Environment', 'Neighborhood cleanup sprint', 'Join a morning cleanup and awareness action.', 'Volunteers receive gloves and bags, clean assigned areas, sort recyclable materials and invite residents to keep the area clean.', 'Ariana', 'El Menzah park entrance', '2026-05-04', '2026-05-04', 18, 'approved', NULL, '2026-04-17 13:59:12'),
(7, 1, 2, 'Food aid', 'Ramadan meal prep team', 'Help prepare and pack hot meals with the kitchen team.', 'Volunteers assist with packing, hygiene flow, queue organization and handover to delivery teams.', 'Tunis', 'Partner kitchen, Bab El Khadra', '2026-04-26', '2026-04-26', 12, 'approved', NULL, '2026-04-17 13:59:12'),
(8, 2, 3, 'Mentoring', 'Teen career discovery workshop', 'Support teenagers during a discovery workshop.', 'Volunteers facilitate small-group conversations, help teenagers list interests and support the coordinator during activities.', 'Sfax', 'Youth center, Sfax', '2026-05-11', '2026-05-11', 7, 'approved', NULL, '2026-04-17 13:59:12'),
(9, 4, 2, 'Environment', 'Urban garden planting day', 'Plant herbs and small trees in a shared community garden.', 'Volunteers prepare soil, plant seedlings, water areas and install simple labels for residents.', 'Ariana', 'Green Streets garden', '2026-05-18', '2026-05-18', 14, 'approved', NULL, '2026-04-17 13:59:12'),
(10, 1, 2, 'Logistics', 'Back-to-school kit assembly', 'Prepare school kits for children from low-income families.', 'Volunteers sort supplies, assemble kits by grade level, count stock and prepare delivery boxes.', 'Tunis', 'Croissant Solidaire HQ', '2026-06-02', '2026-06-02', 9, 'approved', NULL, '2026-04-17 13:59:12'),
(11, 2, 3, 'Education', 'Exam revision weekend', 'Support students with revision planning and calm study routines.', 'Volunteers help students organize revision sheets, explain simple concepts and keep the space calm and encouraging.', 'Sfax', 'School partner room', '2026-05-25', '2026-05-26', 8, 'approved', NULL, '2026-04-17 13:59:12'),
(12, 4, 2, 'Awareness', 'Recycling awareness booth', 'Run a small booth explaining recycling basics to families.', 'Volunteers guide visitors, distribute simple materials and collect pledges from residents.', 'Ariana', 'Local market square', '2026-06-08', '2026-06-08', 6, 'approved', NULL, '2026-04-17 13:59:12'),
(13, 5, 11, 'Social impact', 'Workshop Arduino', 'FREE intro to robotics', 'Get into the world of robotics', 'tunis', NULL, '2026-04-22', '2026-04-22', 5, 'approved', NULL, '2026-04-17 15:12:10');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(160) NOT NULL,
  `body` varchar(255) NOT NULL,
  `type` varchar(40) NOT NULL DEFAULT 'info',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `body`, `type`, `is_read`, `created_at`) VALUES
(1, 5, 'Application accepted', 'You were accepted for Food parcel distribution.', 'application', 0, '2026-04-17 13:59:12'),
(2, 6, 'Application accepted', 'You were accepted for Primary tutoring support.', 'application', 0, '2026-04-17 13:59:12'),
(3, 7, 'Mission participation planned', 'Your cleanup participation is now planned.', 'mission', 0, '2026-04-17 13:59:12'),
(4, 8, 'Hours approved', 'Your donation sorting hours were approved.', 'hours', 1, '2026-04-17 13:59:12'),
(5, 9, 'Application accepted', 'You were accepted for the mentoring workshop.', 'application', 0, '2026-04-17 13:59:12'),
(6, 2, 'New application pending', 'A member applied to Ramadan meal prep team.', 'owner', 0, '2026-04-17 13:59:12'),
(7, 3, 'Hours pending review', 'A volunteer submitted tutoring hours.', 'hours', 0, '2026-04-17 13:59:12'),
(8, 1, 'Feedback pending approval', 'A public feedback is waiting for moderation.', 'admin', 0, '2026-04-17 13:59:12'),
(9, 3, 'New mission application', 'Yasmine Mansour applied for Exam revision weekend.', 'application', 0, '2026-04-17 15:07:56'),
(10, 11, 'New mission application', 'Yasmine Mansour applied for Workshop Arduino.', 'application', 0, '2026-04-17 15:14:42'),
(11, 5, 'Application Accepted', 'Your application for \"Workshop Arduino\" was accepted.', 'application', 0, '2026-04-17 15:15:02'),
(12, 11, 'Hours awaiting validation', 'Yasmine Mansour submitted 2h for Workshop Arduino.', 'hours', 0, '2026-04-17 15:15:34'),
(13, 5, 'Volunteer hours Approved', 'Your 2.00h for \"Workshop Arduino\" were approved.', 'hours', 0, '2026-04-17 15:16:09'),
(14, 11, 'Application sent to admin review', 'mouhib applied for Workshop Arduino. Admin approval is required.', 'application', 0, '2026-04-18 14:05:15'),
(15, 1, 'Application awaiting approval', 'mouhib applied for Workshop Arduino.', 'application', 0, '2026-04-18 14:05:15'),
(16, 12, 'Application Accepted', 'Your application for \"Workshop Arduino\" was accepted by admin.', 'application', 1, '2026-04-18 14:07:47'),
(17, 11, 'Admin reviewed an application', 'Application for \"Workshop Arduino\" was accepted.', 'application', 0, '2026-04-18 14:07:47'),
(18, 11, 'Application sent to admin review', 'yomn applied for Workshop Arduino. Admin approval is required.', 'application', 0, '2026-04-19 20:01:36'),
(19, 1, 'Application awaiting approval', 'yomn applied for Workshop Arduino.', 'application', 0, '2026-04-19 20:01:36'),
(20, 13, 'Application Accepted', 'Your application for \"Workshop Arduino\" was accepted by admin.', 'application', 0, '2026-04-19 20:03:32'),
(21, 11, 'Admin reviewed an application', 'Application for \"Workshop Arduino\" was accepted.', 'application', 0, '2026-04-19 20:03:32');

-- --------------------------------------------------------

--
-- Table structure for table `participations`
--

CREATE TABLE `participations` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `mission_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `accepted_by` int(11) DEFAULT NULL,
  `status` enum('planned','active','completed','canceled') NOT NULL DEFAULT 'planned',
  `presence_confirmed` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `participations`
--

INSERT INTO `participations` (`id`, `application_id`, `mission_id`, `member_id`, `accepted_by`, `status`, `presence_confirmed`, `created_at`) VALUES
(1, 1, 1, 5, 2, 'completed', 1, '2026-04-17 13:59:12'),
(2, 3, 3, 6, 3, 'active', 1, '2026-04-17 13:59:12'),
(3, 5, 6, 7, 2, 'planned', 0, '2026-04-17 13:59:12'),
(4, 7, 8, 9, 3, 'planned', 0, '2026-04-17 13:59:12'),
(5, 10, 11, 6, 3, 'planned', 0, '2026-04-17 13:59:12'),
(6, 12, 2, 8, 2, 'completed', 1, '2026-04-17 13:59:12'),
(7, 15, 13, 5, 11, 'planned', 0, '2026-04-17 15:15:02'),
(8, 16, 13, 12, 1, 'planned', 0, '2026-04-18 14:07:47'),
(9, 17, 13, 13, 1, 'planned', 0, '2026-04-19 20:03:32');

-- --------------------------------------------------------

--
-- Table structure for table `saved_missions`
--

CREATE TABLE `saved_missions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `mission_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `saved_missions`
--

INSERT INTO `saved_missions` (`id`, `user_id`, `mission_id`, `created_at`) VALUES
(1, 5, 1, '2026-04-17 15:06:02'),
(2, 5, 3, '2026-04-17 15:06:02'),
(3, 6, 3, '2026-04-17 15:06:02'),
(4, 7, 2, '2026-04-17 15:06:02'),
(5, 8, 6, '2026-04-17 15:06:02');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `role` enum('admin','owner','member') NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `email` varchar(160) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `city` varchar(80) DEFAULT NULL,
  `status` enum('active','pending','suspended') NOT NULL DEFAULT 'active',
  `initials` varchar(8) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `role`, `full_name`, `email`, `password_hash`, `phone`, `city`, `status`, `initials`, `created_at`) VALUES
(1, 'admin', 'Nadia Platform', 'admin@benevolink.test', '$2y$12$3bwLgBDbCZ55FMH0kRfSFOOpHovbrL7OJ7sOfU7tKSIJfEzo/AnQa', '+216 20 100 000', 'Tunis', 'active', 'NP', '2026-04-17 13:59:12'),
(2, 'owner', 'Salma Ben Ali', 'salma@croissant.test', '$2y$12$8BIcScJZWpv3MikGDYy1YOEYRRKfkUlzx37r1qRm29VCaAwLQ2SzG', '+216 21 111 111', 'Tunis', 'active', 'SB', '2026-04-17 13:59:12'),
(3, 'owner', 'Karim Trabelsi', 'karim@jeunes.test', '$2y$12$8BIcScJZWpv3MikGDYy1YOEYRRKfkUlzx37r1qRm29VCaAwLQ2SzG', '+216 22 222 222', 'Sfax', 'active', 'KT', '2026-04-17 13:59:12'),
(4, 'owner', 'Amira Haddad', 'amira@pending.test', '$2y$12$oVmewPgI8nMqXHhYJHc5uemEA7tyyDXWUNWPGgyGyzZwP7TWw8M9G', '+216 24 444 444', 'Nabeul', 'active', 'AH', '2026-04-17 13:59:12'),
(5, 'member', 'Yasmine Mansour', 'yasmine@demo.test', '$2y$12$O8.5av6ID5X4MHe8ko0DWudlCSdq0N6I1Nhx1cakR44axXnhs1aJO', '+216 23 333 333', 'Tunis', 'active', 'YM', '2026-04-17 13:59:12'),
(6, 'member', 'Ali Gharbi', 'ali@demo.test', '$2y$12$O8.5av6ID5X4MHe8ko0DWudlCSdq0N6I1Nhx1cakR44axXnhs1aJO', '+216 25 555 555', 'Sfax', 'active', 'AG', '2026-04-17 13:59:12'),
(7, 'member', 'Meriem Saidi', 'meriem@demo.test', '$2y$12$O8.5av6ID5X4MHe8ko0DWudlCSdq0N6I1Nhx1cakR44axXnhs1aJO', '+216 26 666 666', 'Ariana', 'active', 'MS', '2026-04-17 13:59:12'),
(8, 'member', 'Omar Mejri', 'omar@demo.test', '$2y$12$O8.5av6ID5X4MHe8ko0DWudlCSdq0N6I1Nhx1cakR44axXnhs1aJO', '+216 27 777 777', 'Tunis', 'active', 'OM', '2026-04-17 13:59:12'),
(9, 'member', 'Lina Kacem', 'lina@demo.test', '$2y$12$O8.5av6ID5X4MHe8ko0DWudlCSdq0N6I1Nhx1cakR44axXnhs1aJO', '+216 28 888 888', 'Nabeul', 'active', 'LK', '2026-04-17 13:59:12'),
(10, 'member', 'Firas Jaziri', 'firas@demo.test', '$2y$12$O8.5av6ID5X4MHe8ko0DWudlCSdq0N6I1Nhx1cakR44axXnhs1aJO', '+216 29 999 999', 'Sousse', 'active', 'FJ', '2026-04-17 13:59:12'),
(11, 'owner', 'Ayari Med Ghassen', 'gastonayari5@gmail.com', '$2y$10$8c5nQNkVpqfWIPSquyttaeM3kvhEoABgBoztn7v5x7Wgp2HPLF3E2', NULL, 'tunis', 'active', 'AG', '2026-04-17 15:10:51'),
(12, 'member', 'mouhib', 'mouhibrezgui65123@gmail.com', '$2y$10$WwdWMbIoRFp0IOgHHh1VMuUh8l9KIGnOn.mcLJzI8ftwnD8t.4lQi', NULL, 'tunis', 'active', 'MM', '2026-04-18 14:04:05'),
(13, 'member', 'yomn', 'yomn@gmail.com', '$2y$10$TtTRJkz5f19UALGImGpMueeFpc26Y0TLPPitPLWKTaJnTIHnEldDq', NULL, 'tunis', 'active', 'YY', '2026-04-19 20:00:09');

-- --------------------------------------------------------

--
-- Table structure for table `user_preferences`
--

CREATE TABLE `user_preferences` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `preference_key` varchar(80) NOT NULL,
  `preference_value` varchar(255) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `volunteer_hours`
--

CREATE TABLE `volunteer_hours` (
  `id` int(11) NOT NULL,
  `participation_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `mission_id` int(11) NOT NULL,
  `work_date` date NOT NULL,
  `hours` decimal(5,2) NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `volunteer_hours`
--

INSERT INTO `volunteer_hours` (`id`, `participation_id`, `member_id`, `mission_id`, `work_date`, `hours`, `note`, `status`, `reviewed_by`, `reviewed_at`, `created_at`) VALUES
(1, 1, 5, 1, '2026-04-20', 5.00, 'Parcel preparation and distribution support.', 'approved', 2, '2026-04-20 18:00:00', '2026-04-17 13:59:12'),
(2, 6, 8, 2, '2026-04-24', 4.00, 'Sorting and box labeling.', 'approved', 2, '2026-04-24 17:30:00', '2026-04-17 13:59:12'),
(3, 2, 6, 3, '2026-04-19', 2.50, 'Tutoring session with primary students.', 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(4, 4, 9, 8, '2026-05-11', 3.00, 'Mentoring workshop support.', 'pending', NULL, NULL, '2026-04-17 13:59:12'),
(5, 5, 6, 11, '2026-05-25', 2.00, 'Revision planning assistance.', 'approved', 3, '2026-05-25 16:00:00', '2026-04-17 13:59:12'),
(6, 7, 5, 13, '2026-04-17', 2.00, '', 'approved', 11, '2026-04-17 17:16:09', '2026-04-17 15:15:34');

--
-- Triggers `volunteer_hours`
--
DELIMITER $$
CREATE TRIGGER `trg_hours_insert` AFTER INSERT ON `volunteer_hours` FOR EACH ROW BEGIN
    INSERT INTO feature_events (actor_id, event_name, entity_type, entity_id, page, metadata_json)
    VALUES (NEW.member_id, 'hours_submitted', 'volunteer_hours', NEW.id, 'database', JSON_OBJECT('mission_id', NEW.mission_id, 'hours', NEW.hours, 'status', NEW.status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_hours_status_update` AFTER UPDATE ON `volunteer_hours` FOR EACH ROW BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO feature_events (actor_id, event_name, entity_type, entity_id, page, metadata_json)
        VALUES (NEW.reviewed_by, 'hours_status_changed', 'volunteer_hours', NEW.id, 'database', JSON_OBJECT('mission_id', NEW.mission_id, 'old_status', OLD.status, 'new_status', NEW.status, 'hours', NEW.hours));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_admin_final_approval_queue`
-- (See below for the actual view)
--
CREATE TABLE `v_admin_final_approval_queue` (
`id` int(11)
,`request_type` varchar(50)
,`entity_id` int(11)
,`title` varchar(180)
,`details` varchar(500)
,`status` enum('pending','approved','rejected')
,`owner_id` int(11)
,`owner_name` varchar(120)
,`member_id` int(11)
,`member_name` varchar(120)
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_feature_usage`
-- (See below for the actual view)
--
CREATE TABLE `v_feature_usage` (
`event_name` varchar(80)
,`total_events` bigint(21)
,`unique_users` bigint(21)
,`first_seen` timestamp
,`last_seen` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_member_impact`
-- (See below for the actual view)
--
CREATE TABLE `v_member_impact` (
`member_id` int(11)
,`full_name` varchar(120)
,`city` varchar(80)
,`applications_count` bigint(21)
,`participations_count` bigint(21)
,`approved_hours` decimal(27,2)
,`saved_missions_count` bigint(21)
,`skills_count` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_owner_operations`
-- (See below for the actual view)
--
CREATE TABLE `v_owner_operations` (
`owner_id` int(11)
,`owner_name` varchar(120)
,`association_name` varchar(160)
,`missions_count` bigint(21)
,`events_count` bigint(21)
,`applications_count` bigint(21)
,`pending_applications` decimal(22,0)
,`inbox_messages` bigint(21)
,`approved_hours` decimal(27,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_platform_dashboard`
-- (See below for the actual view)
--
CREATE TABLE `v_platform_dashboard` (
`active_members` bigint(21)
,`approved_associations` bigint(21)
,`approved_missions` bigint(21)
,`approved_events` bigint(21)
,`approved_hours` decimal(27,2)
,`tracked_events` bigint(21)
,`pending_feedbacks` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_platform_stats`
-- (See below for the actual view)
--
CREATE TABLE `v_platform_stats` (
`active_members` bigint(21)
,`approved_associations` bigint(21)
,`approved_missions` bigint(21)
,`approved_events` bigint(21)
,`approved_hour_rows` bigint(21)
,`total_hours` decimal(27,2)
,`pending_feedbacks` bigint(21)
,`pending_missions` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_public_missions`
-- (See below for the actual view)
--
CREATE TABLE `v_public_missions` (
`id` int(11)
,`title` varchar(180)
,`summary` varchar(255)
,`category` varchar(80)
,`city` varchar(80)
,`start_date` date
,`end_date` date
,`seats` int(11)
,`status` enum('draft','pending','approved','rejected','closed')
,`association_name` varchar(160)
,`association_category` varchar(80)
,`accepted_count` bigint(21)
,`places_left` bigint(22)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_usage_by_day`
-- (See below for the actual view)
--
CREATE TABLE `v_usage_by_day` (
`usage_date` date
,`events_count` bigint(21)
,`active_users` bigint(21)
,`sessions_count` bigint(21)
);

-- --------------------------------------------------------

--
-- Structure for view `v_admin_final_approval_queue`
--
DROP TABLE IF EXISTS `v_admin_final_approval_queue`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_admin_final_approval_queue`  AS SELECT `ar`.`id` AS `id`, `ar`.`request_type` AS `request_type`, `ar`.`entity_id` AS `entity_id`, `ar`.`title` AS `title`, `ar`.`details` AS `details`, `ar`.`status` AS `status`, `ar`.`owner_id` AS `owner_id`, `owner`.`full_name` AS `owner_name`, `ar`.`member_id` AS `member_id`, `member`.`full_name` AS `member_name`, `ar`.`created_at` AS `created_at`, `ar`.`updated_at` AS `updated_at` FROM ((`approval_requests` `ar` left join `users` `owner` on(`owner`.`id` = `ar`.`owner_id`)) left join `users` `member` on(`member`.`id` = `ar`.`member_id`)) WHERE `ar`.`status` = 'pending' ORDER BY `ar`.`created_at` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `v_feature_usage`
--
DROP TABLE IF EXISTS `v_feature_usage`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_feature_usage`  AS SELECT `feature_events`.`event_name` AS `event_name`, count(0) AS `total_events`, count(distinct `feature_events`.`actor_id`) AS `unique_users`, min(`feature_events`.`created_at`) AS `first_seen`, max(`feature_events`.`created_at`) AS `last_seen` FROM `feature_events` GROUP BY `feature_events`.`event_name` ;

-- --------------------------------------------------------

--
-- Structure for view `v_member_impact`
--
DROP TABLE IF EXISTS `v_member_impact`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_member_impact`  AS SELECT `u`.`id` AS `member_id`, `u`.`full_name` AS `full_name`, `u`.`city` AS `city`, count(distinct `a`.`id`) AS `applications_count`, count(distinct `p`.`id`) AS `participations_count`, coalesce(sum(case when `vh`.`status` = 'approved' then `vh`.`hours` else 0 end),0) AS `approved_hours`, count(distinct `sm`.`id`) AS `saved_missions_count`, count(distinct `ms`.`id`) AS `skills_count` FROM (((((`users` `u` left join `applications` `a` on(`a`.`member_id` = `u`.`id`)) left join `participations` `p` on(`p`.`member_id` = `u`.`id`)) left join `volunteer_hours` `vh` on(`vh`.`member_id` = `u`.`id`)) left join `saved_missions` `sm` on(`sm`.`user_id` = `u`.`id`)) left join `member_skills` `ms` on(`ms`.`user_id` = `u`.`id`)) WHERE `u`.`role` = 'member' GROUP BY `u`.`id`, `u`.`full_name`, `u`.`city` ;

-- --------------------------------------------------------

--
-- Structure for view `v_owner_operations`
--
DROP TABLE IF EXISTS `v_owner_operations`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_owner_operations`  AS SELECT `u`.`id` AS `owner_id`, `u`.`full_name` AS `owner_name`, `ass`.`name` AS `association_name`, count(distinct `m`.`id`) AS `missions_count`, count(distinct `e`.`id`) AS `events_count`, count(distinct `ap`.`id`) AS `applications_count`, sum(case when `ap`.`status` = 'pending' then 1 else 0 end) AS `pending_applications`, count(distinct `am`.`id`) AS `inbox_messages`, coalesce(sum(case when `vh`.`status` = 'approved' then `vh`.`hours` else 0 end),0) AS `approved_hours` FROM ((((((`users` `u` left join `associations` `ass` on(`ass`.`owner_id` = `u`.`id`)) left join `missions` `m` on(`m`.`owner_id` = `u`.`id`)) left join `events` `e` on(`e`.`owner_id` = `u`.`id`)) left join `applications` `ap` on(`ap`.`mission_id` = `m`.`id`)) left join `volunteer_hours` `vh` on(`vh`.`mission_id` = `m`.`id`)) left join `association_messages` `am` on(`am`.`association_id` = `ass`.`id`)) WHERE `u`.`role` = 'owner' GROUP BY `u`.`id`, `u`.`full_name`, `ass`.`name` ;

-- --------------------------------------------------------

--
-- Structure for view `v_platform_dashboard`
--
DROP TABLE IF EXISTS `v_platform_dashboard`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_platform_dashboard`  AS SELECT (select count(0) from `users` where `users`.`role` = 'member' and `users`.`status` = 'active') AS `active_members`, (select count(0) from `associations` where `associations`.`status` = 'approved') AS `approved_associations`, (select count(0) from `missions` where `missions`.`status` = 'approved') AS `approved_missions`, (select count(0) from `events` where `events`.`status` = 'approved') AS `approved_events`, (select coalesce(sum(`volunteer_hours`.`hours`),0) from `volunteer_hours` where `volunteer_hours`.`status` = 'approved') AS `approved_hours`, (select count(0) from `feature_events`) AS `tracked_events`, (select count(0) from `feedbacks` where `feedbacks`.`status` = 'pending') AS `pending_feedbacks` ;

-- --------------------------------------------------------

--
-- Structure for view `v_platform_stats`
--
DROP TABLE IF EXISTS `v_platform_stats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_platform_stats`  AS SELECT (select count(0) from `users` where `users`.`role` = 'member' and `users`.`status` = 'active') AS `active_members`, (select count(0) from `associations` where `associations`.`status` = 'approved') AS `approved_associations`, (select count(0) from `missions` where `missions`.`status` = 'approved') AS `approved_missions`, (select count(0) from `events` where `events`.`status` = 'approved') AS `approved_events`, (select count(0) from `volunteer_hours` where `volunteer_hours`.`status` = 'approved') AS `approved_hour_rows`, (select coalesce(sum(`volunteer_hours`.`hours`),0) from `volunteer_hours` where `volunteer_hours`.`status` = 'approved') AS `total_hours`, (select count(0) from `feedbacks` where `feedbacks`.`status` = 'pending') AS `pending_feedbacks`, (select count(0) from `missions` where `missions`.`status` = 'pending') AS `pending_missions` ;

-- --------------------------------------------------------

--
-- Structure for view `v_public_missions`
--
DROP TABLE IF EXISTS `v_public_missions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_public_missions`  AS SELECT `m`.`id` AS `id`, `m`.`title` AS `title`, `m`.`summary` AS `summary`, `m`.`category` AS `category`, `m`.`city` AS `city`, `m`.`start_date` AS `start_date`, `m`.`end_date` AS `end_date`, `m`.`seats` AS `seats`, `m`.`status` AS `status`, `a`.`name` AS `association_name`, `a`.`category` AS `association_category`, coalesce(`accepted`.`accepted_count`,0) AS `accepted_count`, greatest(`m`.`seats` - coalesce(`accepted`.`accepted_count`,0),0) AS `places_left` FROM ((`missions` `m` join `associations` `a` on(`a`.`id` = `m`.`association_id`)) left join (select `applications`.`mission_id` AS `mission_id`,count(0) AS `accepted_count` from `applications` where `applications`.`status` = 'accepted' group by `applications`.`mission_id`) `accepted` on(`accepted`.`mission_id` = `m`.`id`)) WHERE `m`.`status` = 'approved' AND `a`.`status` = 'approved' ;

-- --------------------------------------------------------

--
-- Structure for view `v_usage_by_day`
--
DROP TABLE IF EXISTS `v_usage_by_day`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_usage_by_day`  AS SELECT cast(`feature_events`.`created_at` as date) AS `usage_date`, count(0) AS `events_count`, count(distinct `feature_events`.`actor_id`) AS `active_users`, count(distinct `feature_events`.`session_id`) AS `sessions_count` FROM `feature_events` GROUP BY cast(`feature_events`.`created_at` as date) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `applications`
--
ALTER TABLE `applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_application_member_mission` (`mission_id`,`member_id`),
  ADD KEY `fk_application_reviewer` (`reviewed_by`),
  ADD KEY `idx_applications_member_status` (`member_id`,`status`),
  ADD KEY `idx_applications_mission_status` (`mission_id`,`status`);

--
-- Indexes for table `approval_requests`
--
ALTER TABLE `approval_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_approval_request` (`request_type`,`entity_id`),
  ADD KEY `idx_approval_status_type` (`status`,`request_type`),
  ADD KEY `idx_approval_owner` (`owner_id`),
  ADD KEY `idx_approval_member` (`member_id`),
  ADD KEY `fk_approval_requester` (`requester_id`),
  ADD KEY `fk_approval_decider` (`decided_by`);

--
-- Indexes for table `associations`
--
ALTER TABLE `associations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_associations_status_city` (`status`,`city`),
  ADD KEY `idx_associations_owner` (`owner_id`);

--
-- Indexes for table `association_messages`
--
ALTER TABLE `association_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_messages_sender` (`sender_user_id`),
  ADD KEY `idx_messages_association_status` (`association_id`,`status`,`created_at`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_audit_actor` (`actor_id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_event_association` (`association_id`),
  ADD KEY `idx_events_status_date` (`status`,`event_date`),
  ADD KEY `idx_events_owner_status` (`owner_id`,`status`);

--
-- Indexes for table `event_registrations`
--
ALTER TABLE `event_registrations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_event_registration` (`event_id`,`member_id`),
  ADD KEY `fk_event_registration_reviewer` (`reviewed_by`),
  ADD KEY `idx_event_registrations_member_status` (`member_id`,`status`),
  ADD KEY `idx_event_registrations_event_status` (`event_id`,`status`);

--
-- Indexes for table `feature_events`
--
ALTER TABLE `feature_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_feature_events_actor_time` (`actor_id`,`created_at`),
  ADD KEY `idx_feature_events_name_time` (`event_name`,`created_at`),
  ADD KEY `idx_feature_events_page_time` (`page`,`created_at`),
  ADD KEY `idx_feature_events_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `feedbacks`
--
ALTER TABLE `feedbacks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_feedback_user` (`user_id`),
  ADD KEY `fk_feedback_reviewer` (`reviewed_by`),
  ADD KEY `idx_feedbacks_status_rating` (`status`,`rating`);

--
-- Indexes for table `impact_goals`
--
ALTER TABLE `impact_goals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_goals_owner` (`owner_id`),
  ADD KEY `idx_goals_association_status` (`association_id`,`status`);

--
-- Indexes for table `member_skills`
--
ALTER TABLE `member_skills`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_member_skill` (`user_id`,`skill`),
  ADD KEY `idx_member_skills_level` (`level`);

--
-- Indexes for table `missions`
--
ALTER TABLE `missions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_missions_search` (`status`,`city`,`category`,`start_date`),
  ADD KEY `idx_missions_owner_status` (`owner_id`,`status`),
  ADD KEY `idx_missions_association` (`association_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user_read` (`user_id`,`is_read`);

--
-- Indexes for table `participations`
--
ALTER TABLE `participations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `application_id` (`application_id`),
  ADD KEY `fk_participation_acceptor` (`accepted_by`),
  ADD KEY `idx_participations_member_status` (`member_id`,`status`),
  ADD KEY `idx_participations_mission` (`mission_id`);

--
-- Indexes for table `saved_missions`
--
ALTER TABLE `saved_missions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_saved_mission` (`user_id`,`mission_id`),
  ADD KEY `fk_saved_missions_mission` (`mission_id`),
  ADD KEY `idx_saved_missions_user_time` (`user_id`,`created_at`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_users_role_status` (`role`,`status`),
  ADD KEY `idx_users_city` (`city`);

--
-- Indexes for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_preference` (`user_id`,`preference_key`);

--
-- Indexes for table `volunteer_hours`
--
ALTER TABLE `volunteer_hours`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_hours_participation` (`participation_id`),
  ADD KEY `fk_hours_reviewer` (`reviewed_by`),
  ADD KEY `idx_hours_member_status` (`member_id`,`status`),
  ADD KEY `idx_hours_mission_status` (`mission_id`,`status`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `applications`
--
ALTER TABLE `applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `approval_requests`
--
ALTER TABLE `approval_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91;

--
-- AUTO_INCREMENT for table `associations`
--
ALTER TABLE `associations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `association_messages`
--
ALTER TABLE `association_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `event_registrations`
--
ALTER TABLE `event_registrations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `feature_events`
--
ALTER TABLE `feature_events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=528;

--
-- AUTO_INCREMENT for table `feedbacks`
--
ALTER TABLE `feedbacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `impact_goals`
--
ALTER TABLE `impact_goals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `member_skills`
--
ALTER TABLE `member_skills`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `missions`
--
ALTER TABLE `missions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `participations`
--
ALTER TABLE `participations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `saved_missions`
--
ALTER TABLE `saved_missions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `user_preferences`
--
ALTER TABLE `user_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `volunteer_hours`
--
ALTER TABLE `volunteer_hours`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `applications`
--
ALTER TABLE `applications`
  ADD CONSTRAINT `fk_application_member` FOREIGN KEY (`member_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_application_mission` FOREIGN KEY (`mission_id`) REFERENCES `missions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_application_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `approval_requests`
--
ALTER TABLE `approval_requests`
  ADD CONSTRAINT `fk_approval_decider` FOREIGN KEY (`decided_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_approval_member` FOREIGN KEY (`member_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_approval_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_approval_requester` FOREIGN KEY (`requester_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `associations`
--
ALTER TABLE `associations`
  ADD CONSTRAINT `fk_association_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `association_messages`
--
ALTER TABLE `association_messages`
  ADD CONSTRAINT `fk_messages_association` FOREIGN KEY (`association_id`) REFERENCES `associations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_audit_actor` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `events`
--
ALTER TABLE `events`
  ADD CONSTRAINT `fk_event_association` FOREIGN KEY (`association_id`) REFERENCES `associations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_event_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `event_registrations`
--
ALTER TABLE `event_registrations`
  ADD CONSTRAINT `fk_event_registration_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_event_registration_member` FOREIGN KEY (`member_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_event_registration_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `feature_events`
--
ALTER TABLE `feature_events`
  ADD CONSTRAINT `fk_feature_events_actor` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `feedbacks`
--
ALTER TABLE `feedbacks`
  ADD CONSTRAINT `fk_feedback_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_feedback_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `impact_goals`
--
ALTER TABLE `impact_goals`
  ADD CONSTRAINT `fk_goals_association` FOREIGN KEY (`association_id`) REFERENCES `associations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_goals_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `member_skills`
--
ALTER TABLE `member_skills`
  ADD CONSTRAINT `fk_member_skills_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `missions`
--
ALTER TABLE `missions`
  ADD CONSTRAINT `fk_mission_association` FOREIGN KEY (`association_id`) REFERENCES `associations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_mission_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `participations`
--
ALTER TABLE `participations`
  ADD CONSTRAINT `fk_participation_acceptor` FOREIGN KEY (`accepted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_participation_application` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_participation_member` FOREIGN KEY (`member_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_participation_mission` FOREIGN KEY (`mission_id`) REFERENCES `missions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `saved_missions`
--
ALTER TABLE `saved_missions`
  ADD CONSTRAINT `fk_saved_missions_mission` FOREIGN KEY (`mission_id`) REFERENCES `missions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_saved_missions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD CONSTRAINT `fk_preferences_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `volunteer_hours`
--
ALTER TABLE `volunteer_hours`
  ADD CONSTRAINT `fk_hours_member` FOREIGN KEY (`member_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_hours_mission` FOREIGN KEY (`mission_id`) REFERENCES `missions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_hours_participation` FOREIGN KEY (`participation_id`) REFERENCES `participations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_hours_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
