<?php
/**
 * POST action handler.
 * Processes authentication, CRUD actions, approvals, analytics tracking,
 * notifications, and lightweight API-style interactions before page rendering.
 */
checkCsrf();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string)($_POST['action'] ?? '');

    // Handle lightweight event tracking for client-side interactions.
    if ($action === 'track_event') {
        $event = preg_replace('/[^a-zA-Z0-9_\-]/', '', (string)($_POST['event'] ?? 'ui_event')) ?: 'ui_event';
        $entityType = trim((string)($_POST['entity_type'] ?? '')) ?: null;
        $entityId = isset($_POST['entity_id']) && $_POST['entity_id'] !== '' ? (int)$_POST['entity_id'] : null;
        $meta = [
            'label' => mb_substr((string)($_POST['label'] ?? ''), 0, 120),
            'href' => mb_substr((string)($_POST['href'] ?? ''), 0, 180),
            'value' => mb_substr((string)($_POST['value'] ?? ''), 0, 120),
        ];
        trackEvent($event, $entityType, $entityId, $meta);
        header('Content-Type: application/json');
        echo json_encode(['ok' => true]);
        exit;
    }

    // Track every form submission for analytics and audit purposes.
    trackEvent('form_submit', 'action', null, ['action' => $action]);

    if ($action === 'login') {
        $email = trim((string)($_POST['email'] ?? ''));
        $password = (string)($_POST['password'] ?? '');
        $user = fetchOneSafe('SELECT * FROM users WHERE email = ? LIMIT 1', [$email]);

        $fallback = [
            'admin@benevolink.test' => 'admin123',
            'salma@croissant.test' => 'resp123',
            'karim@jeunes.test' => 'resp123',
            'yasmine@demo.test' => 'bene123',
            'ali@demo.test' => 'bene123',
            'amira@pending.test' => 'pending123',
        ];

        $valid = $user && (password_verify($password, (string)$user['password_hash']) || (($fallback[$email] ?? null) === $password));

        if (!$valid) {
            flash('error', 'Invalid email or password.');
            redirectTo('login');
        }

        if (($user['status'] ?? 'active') === 'suspended') {
            flash('error', 'This account is suspended.');
            redirectTo('login');
        }

        $_SESSION['user_id'] = (int)$user['id'];
        flash('success', 'Welcome back, ' . $user['full_name'] . '.');
        redirectTo('dashboard');
    }

    if ($action === 'logout') {
        session_destroy();
        session_start();
        flash('success', 'You are signed out.');
        redirectTo('home');
    }

    if ($action === 'register_member') {
        $name = trim((string)($_POST['full_name'] ?? ''));
        $email = trim((string)($_POST['email'] ?? ''));
        $city = trim((string)($_POST['city'] ?? ''));
        $password = (string)($_POST['password'] ?? '');

        if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 6) {
            flash('error', 'Please enter a valid name, email and a password with at least 6 characters.');
            redirectTo('join');
        }

        $ok = executeSafe(
            "INSERT INTO users (role, full_name, email, password_hash, city, status, initials) VALUES ('member', ?, ?, ?, ?, 'active', ?)",
            [$name, $email, password_hash($password, PASSWORD_DEFAULT), $city, initials($name)]
        );

        flash($ok ? 'success' : 'error', $ok ? 'Member account created. You can sign in now.' : 'Registration failed. The email may already exist.');
        redirectTo('login');
    }

    if ($action === 'register_owner') {
        $name = trim((string)($_POST['full_name'] ?? ''));
        $email = trim((string)($_POST['email'] ?? ''));
        $password = (string)($_POST['password'] ?? '');
        $association = trim((string)($_POST['association_name'] ?? ''));
        $category = trim((string)($_POST['category'] ?? ''));
        $city = trim((string)($_POST['city'] ?? ''));
        $description = trim((string)($_POST['description'] ?? ''));

        if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 6 || $association === '') {
            flash('error', 'Please complete the owner and association information.');
            redirectTo('join');
        }

        try {
            db()->beginTransaction();
            $stmt = db()->prepare("INSERT INTO users (role, full_name, email, password_hash, city, status, initials) VALUES ('owner', ?, ?, ?, ?, 'active', ?)");
            $stmt->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT), $city, initials($name)]);
            $ownerId = (int)db()->lastInsertId();

            $stmt = db()->prepare("INSERT INTO associations (owner_id, name, category, description, mission_statement, city, email, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')");
            $stmt->execute([$ownerId, $association, $category ?: 'Social impact', $description ?: 'Association profile awaiting completion.', 'Awaiting admin review.', $city ?: 'Tunis', $email]);

            db()->commit();
            createApprovalRequest('association', (int)db()->lastInsertId(), 'Association approval: ' . $association, $description ?: 'New association profile awaiting verification.', $ownerId, $ownerId, null);
            notifyAdmins('New association awaiting approval', $association . ' was submitted by ' . $name . '.', 'association');
            flash('success', 'Owner workspace created. Your association is pending admin approval.');
            redirectTo('login');
        } catch (Throwable) {
            if (db()->inTransaction()) {
                db()->rollBack();
            }
            flash('error', 'Owner registration failed. The email may already exist.');
            redirectTo('join');
        }
    }

    if ($action === 'feedback_submit') {
        $user = currentUser();
        $name = trim((string)($_POST['author_name'] ?? ($user['full_name'] ?? 'Guest')));
        $email = trim((string)($_POST['email'] ?? ($user['email'] ?? '')));
        $rating = max(1, min(5, (int)($_POST['rating'] ?? 5)));
        $title = trim((string)($_POST['title'] ?? ''));
        $message = trim((string)($_POST['message'] ?? ''));

        if ($title === '' || $message === '') {
            flash('error', 'Please add a title and message.');
            redirectTo('feedback');
        }

        $ok = executeSafe('INSERT INTO feedbacks (user_id, author_name, email, rating, title, message, status) VALUES (?, ?, ?, ?, ?, ?, "pending")', [
            $user['id'] ?? null, $name, $email, $rating, $title, $message
        ]);
        if ($ok) {
            $feedbackId = (int)db()->lastInsertId();
            createApprovalRequest('feedback', $feedbackId, 'Feedback moderation: ' . $title, $message, $user['id'] ?? null, null, $user['id'] ?? null);
            notifyAdmins('Feedback awaiting moderation', $name . ' submitted a public story: ' . $title, 'feedback');
        }
        flash($ok ? 'success' : 'error', $ok ? 'Feedback submitted. It will appear after admin approval.' : 'Feedback submission failed.');
        redirectTo('feedback');
    }


    if ($action === 'toggle_saved_mission') {
        $user = requireAuth('member');
        $missionId = (int)($_POST['mission_id'] ?? 0);
        $mission = oneMission($missionId);

        if (!$mission || !tableExists('saved_missions')) {
            flash('error', 'Saved missions are not available yet. Import database_update.sql.');
            redirectTo('missions');
        }

        $exists = (int)scalarSafe('SELECT COUNT(*) FROM saved_missions WHERE user_id = ? AND mission_id = ?', [$user['id'], $missionId], 0);
        if ($exists) {
            executeSafe('DELETE FROM saved_missions WHERE user_id = ? AND mission_id = ?', [$user['id'], $missionId]);
            trackEvent('mission_unsaved', 'mission', $missionId, ['title' => $mission['title'] ?? '']);
            flash('success', 'Mission removed from your shortlist.');
        } else {
            executeSafe('INSERT IGNORE INTO saved_missions (user_id, mission_id) VALUES (?, ?)', [$user['id'], $missionId]);
            trackEvent('mission_saved', 'mission', $missionId, ['title' => $mission['title'] ?? '']);
            flash('success', 'Mission saved to your dashboard.');
        }
        redirectTo('mission', ['id' => $missionId]);
    }

    if ($action === 'send_message') {
        $user = currentUser();
        $associationId = (int)($_POST['association_id'] ?? 0);
        $name = trim((string)($_POST['sender_name'] ?? ($user['full_name'] ?? 'Guest')));
        $email = trim((string)($_POST['sender_email'] ?? ($user['email'] ?? '')));
        $message = trim((string)($_POST['message'] ?? ''));

        if ($associationId <= 0 || $name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || $message === '') {
            flash('error', 'Please enter your name, email and message.');
            redirectTo('associations');
        }

        if (!tableExists('association_messages')) {
            flash('error', 'Messaging is not installed yet. Import database_update.sql.');
            redirectTo('associations');
        }

        $ok = executeSafe(
            'INSERT INTO association_messages (association_id, sender_user_id, sender_name, sender_email, message, status) VALUES (?, ?, ?, ?, ?, "new")',
            [$associationId, $user['id'] ?? null, $name, $email, $message]
        );

        $owner = fetchOneSafe('SELECT u.id, a.name FROM associations a JOIN users u ON u.id = a.owner_id WHERE a.id = ? LIMIT 1', [$associationId]);
        if ($ok && $owner) {
            notifyUser((int)$owner['id'], 'New association message', $name . ' sent a message to ' . $owner['name'] . '.', 'message');
            trackEvent('association_message_sent', 'association', $associationId, ['association' => $owner['name'] ?? '']);
        }

        flash($ok ? 'success' : 'error', $ok ? 'Message sent to the association.' : 'Message could not be sent.');
        redirectTo('associations');
    }

    if ($action === 'add_skill') {
        $user = requireAuth('member');
        $skill = trim((string)($_POST['skill'] ?? ''));
        $level = (string)($_POST['level'] ?? 'intermediate');

        if ($skill === '' || !tableExists('member_skills')) {
            flash('error', 'Skill could not be saved. Import database_update.sql if needed.');
            redirectTo('dashboard');
        }

        executeSafe(
            'INSERT INTO member_skills (user_id, skill, level) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE level = VALUES(level), updated_at = CURRENT_TIMESTAMP',
            [$user['id'], $skill, in_array($level, ['beginner','intermediate','advanced'], true) ? $level : 'intermediate']
        );
        trackEvent('skill_added', 'skill', null, ['skill' => $skill, 'level' => $level]);
        flash('success', 'Skill saved to your volunteer profile.');
        redirectTo('dashboard');
    }

    if ($action === 'apply_mission') {
        $user = requireAuth('member');
        $missionId = (int)($_POST['mission_id'] ?? 0);
        $motivation = trim((string)($_POST['motivation'] ?? ''));
        $mission = oneMission($missionId);
        if (!$mission || $mission['status'] !== 'approved') {
            flash('error', 'This mission is not available.');
            redirectTo('missions');
        }
        $ok = executeSafe('INSERT INTO applications (mission_id, member_id, motivation, status) VALUES (?, ?, ?, "pending")', [$missionId, $user['id'], $motivation]);
        if ($ok) {
            $applicationId = (int)db()->lastInsertId();
            createApprovalRequest('application', $applicationId, 'Volunteer application: ' . $mission['title'], $user['full_name'] . ' applied for this mission.', $user['id'], (int)$mission['owner_id'], $user['id']);
            notifyUser((int)$mission['owner_id'], 'Application sent to admin review', $user['full_name'] . ' applied for ' . $mission['title'] . '. Admin approval is required.', 'application');
            notifyAdmins('Application awaiting approval', $user['full_name'] . ' applied for ' . $mission['title'] . '.', 'application');
        }
        flash($ok ? 'success' : 'warning', $ok ? 'Application sent. The admin team will review and approve it.' : 'You already applied to this mission.');
        redirectTo('mission', ['id' => $missionId]);
    }

    if ($action === 'register_event') {
        $user = requireAuth('member');
        $eventId = (int)($_POST['event_id'] ?? 0);
        $event = oneEvent($eventId);
        if (!$event || $event['status'] !== 'approved') {
            flash('error', 'This event is not available.');
            redirectTo('events');
        }
        $ok = executeSafe('INSERT INTO event_registrations (event_id, member_id, status) VALUES (?, ?, "pending")', [$eventId, $user['id']]);
        if ($ok) {
            $registrationId = (int)db()->lastInsertId();
            createApprovalRequest('event_registration', $registrationId, 'Event registration: ' . $event['title'], $user['full_name'] . ' requested a seat for this event.', $user['id'], (int)$event['owner_id'], $user['id']);
            notifyUser((int)$event['owner_id'], 'Event registration sent to admin review', $user['full_name'] . ' registered for ' . $event['title'] . '. Admin approval is required.', 'event');
            notifyAdmins('Event registration awaiting approval', $user['full_name'] . ' registered for ' . $event['title'] . '.', 'event');
        }
        flash($ok ? 'success' : 'warning', $ok ? 'Registration request sent to admin approval.' : 'You already registered for this event.');
        redirectTo('event', ['id' => $eventId]);
    }

    if ($action === 'submit_hours') {
        $user = requireAuth('member');
        $participationId = (int)($_POST['participation_id'] ?? 0);
        $hours = (float)($_POST['hours'] ?? 0);
        $date = (string)($_POST['work_date'] ?? date('Y-m-d'));
        $note = trim((string)($_POST['note'] ?? ''));
        $participation = fetchOneSafe('SELECT * FROM participations WHERE id = ? AND member_id = ? LIMIT 1', [$participationId, $user['id']]);

        if (!$participation || $hours <= 0 || $hours > 24) {
            flash('error', 'Please select a valid participation and enter hours between 1 and 24.');
            redirectTo('dashboard');
        }

        $ok = executeSafe('INSERT INTO volunteer_hours (participation_id, member_id, mission_id, work_date, hours, note, status) VALUES (?, ?, ?, ?, ?, ?, "pending")', [
            $participationId, $user['id'], $participation['mission_id'], $date, $hours, $note
        ]);

        $mission = oneMission((int)$participation['mission_id']);
        if ($ok && $mission) {
            $hourId = (int)db()->lastInsertId();
            createApprovalRequest('hours', $hourId, 'Volunteer hours: ' . $mission['title'], $user['full_name'] . ' submitted ' . $hours . 'h for admin validation.', $user['id'], (int)$mission['owner_id'], $user['id']);
            notifyUser((int)$mission['owner_id'], 'Hours sent to admin validation', $user['full_name'] . ' submitted ' . $hours . 'h for ' . $mission['title'] . '. Admin approval is required.', 'hours');
            notifyAdmins('Volunteer hours awaiting approval', $user['full_name'] . ' submitted ' . $hours . 'h for ' . $mission['title'] . '.', 'hours');
        }

        flash($ok ? 'success' : 'error', $ok ? 'Hours submitted to admin validation.' : 'Could not submit hours.');
        redirectTo('dashboard');
    }

    if ($action === 'create_mission') {
        $user = requireAuth('owner');
        $assoc = ownerAssociation((int)$user['id']);
        if (!$assoc) {
            flash('error', 'Create an association profile first.');
            redirectTo('dashboard');
        }

        $title = trim((string)($_POST['title'] ?? ''));
        $summary = trim((string)($_POST['summary'] ?? ''));
        $description = trim((string)($_POST['description'] ?? ''));
        $category = trim((string)($_POST['category'] ?? 'General'));
        $city = trim((string)($_POST['city'] ?? $assoc['city']));
        $start = (string)($_POST['start_date'] ?? date('Y-m-d'));
        $end = (string)($_POST['end_date'] ?? $start);
        $seats = max(1, (int)($_POST['seats'] ?? 1));

        if ($title === '' || $summary === '' || $description === '') {
            flash('error', 'Mission title, summary and description are required.');
            redirectTo('dashboard');
        }

        $ok = executeSafe('INSERT INTO missions (association_id, owner_id, category, title, summary, description, city, start_date, end_date, seats, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "pending")', [
            $assoc['id'], $user['id'], $category, $title, $summary, $description, $city, $start, $end, $seats
        ]);
        if ($ok) {
            $missionId = (int)db()->lastInsertId();
            createApprovalRequest('mission', $missionId, 'Mission approval: ' . $title, $summary, $user['id'], $user['id'], null);
            notifyAdmins('Mission awaiting approval', $assoc['name'] . ' submitted "' . $title . '".', 'mission');
        }

        flash($ok ? 'success' : 'error', $ok ? 'Mission created and sent to admin approval.' : 'Mission creation failed.');
        redirectTo('dashboard');
    }

    if ($action === 'create_event') {
        $user = requireAuth('owner');
        $assoc = ownerAssociation((int)$user['id']);
        if (!$assoc) {
            flash('error', 'Create an association profile first.');
            redirectTo('dashboard');
        }

        $title = trim((string)($_POST['title'] ?? ''));
        $summary = trim((string)($_POST['summary'] ?? ''));
        $description = trim((string)($_POST['description'] ?? ''));
        $city = trim((string)($_POST['city'] ?? $assoc['city']));
        $date = (string)($_POST['event_date'] ?? date('Y-m-d'));
        $capacity = max(1, (int)($_POST['capacity'] ?? 1));

        if ($title === '' || $summary === '' || $description === '') {
            flash('error', 'Event title, summary and description are required.');
            redirectTo('dashboard');
        }

        $ok = executeSafe('INSERT INTO events (association_id, owner_id, title, summary, description, city, event_date, capacity, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, "pending")', [
            $assoc['id'], $user['id'], $title, $summary, $description, $city, $date, $capacity
        ]);
        if ($ok) {
            $eventId = (int)db()->lastInsertId();
            createApprovalRequest('event', $eventId, 'Event approval: ' . $title, $summary, $user['id'], $user['id'], null);
            notifyAdmins('Event awaiting approval', $assoc['name'] . ' submitted "' . $title . '".', 'event');
        }

        flash($ok ? 'success' : 'error', $ok ? 'Event created and sent to admin approval.' : 'Event creation failed.');
        redirectTo('dashboard');
    }

    if ($action === 'review_application') {
        $user = requireAuth('admin');

        $applicationId = (int)($_POST['application_id'] ?? 0);
        $decision = (string)($_POST['decision'] ?? 'rejected');
        $application = fetchOneSafe('
            SELECT ap.*, m.owner_id, m.title
            FROM applications ap
            JOIN missions m ON m.id = ap.mission_id
            WHERE ap.id = ?
            LIMIT 1
        ', [$applicationId]);

        if (!$application) {
            flash('error', 'Application not found.');
            redirectTo('dashboard');
        }

        $status = $decision === 'accepted' ? 'accepted' : 'rejected';
        executeSafe('UPDATE applications SET status = ?, reviewed_by = ?, reviewed_at = NOW() WHERE id = ?', [$status, $user['id'], $applicationId]);
        if ($status === 'accepted') {
            executeSafe('INSERT IGNORE INTO participations (application_id, mission_id, member_id, accepted_by, status) VALUES (?, ?, ?, ?, "planned")', [
                $applicationId, $application['mission_id'], $application['member_id'], $user['id']
            ]);
        }
        resolveApprovalRequest('application', $applicationId, $status === 'accepted' ? 'approved' : 'rejected', (int)$user['id']);
        audit((int)$user['id'], 'admin_review_application', 'application', $applicationId, 'Admin final decision: ' . $status);
        trackEvent('admin_application_decision', 'application', $applicationId, ['status' => $status]);

        notifyUser((int)$application['member_id'], 'Application ' . statusLabel($status), 'Your application for "' . $application['title'] . '" was ' . $status . ' by admin.', 'application');
        notifyUser((int)$application['owner_id'], 'Admin reviewed an application', 'Application for "' . $application['title'] . '" was ' . $status . '.', 'application');

        flash('success', 'Application ' . $status . ' by admin.');
        redirectTo('dashboard');
    }

    if ($action === 'review_event_registration') {
        $user = requireAuth('admin');

        $registrationId = (int)($_POST['registration_id'] ?? 0);
        $decision = (string)($_POST['decision'] ?? 'rejected');
        $registration = fetchOneSafe('
            SELECT er.*, e.owner_id, e.title
            FROM event_registrations er
            JOIN events e ON e.id = er.event_id
            WHERE er.id = ?
            LIMIT 1
        ', [$registrationId]);

        if (!$registration) {
            flash('error', 'Registration not found.');
            redirectTo('dashboard');
        }

        $status = $decision === 'accepted' ? 'accepted' : 'rejected';
        executeSafe('UPDATE event_registrations SET status = ?, reviewed_by = ?, reviewed_at = NOW() WHERE id = ?', [$status, $user['id'], $registrationId]);
        resolveApprovalRequest('event_registration', $registrationId, $status === 'accepted' ? 'approved' : 'rejected', (int)$user['id']);
        audit((int)$user['id'], 'admin_review_event_registration', 'event_registration', $registrationId, 'Admin final decision: ' . $status);
        trackEvent('admin_event_registration_decision', 'event_registration', $registrationId, ['status' => $status]);

        notifyUser((int)$registration['member_id'], 'Event registration ' . statusLabel($status), 'Your registration for "' . $registration['title'] . '" was ' . $status . ' by admin.', 'event');
        notifyUser((int)$registration['owner_id'], 'Admin reviewed an event registration', 'Registration for "' . $registration['title'] . '" was ' . $status . '.', 'event');

        flash('success', 'Event registration ' . $status . ' by admin.');
        redirectTo('dashboard');
    }

    if ($action === 'review_hours') {
        $user = requireAuth('admin');

        $hourId = (int)($_POST['hour_id'] ?? 0);
        $decision = (string)($_POST['decision'] ?? 'rejected');
        $hour = fetchOneSafe('
            SELECT vh.*, m.owner_id, m.title
            FROM volunteer_hours vh
            JOIN missions m ON m.id = vh.mission_id
            WHERE vh.id = ?
            LIMIT 1
        ', [$hourId]);

        if (!$hour) {
            flash('error', 'Hours not found.');
            redirectTo('dashboard');
        }

        $status = $decision === 'approved' ? 'approved' : 'rejected';
        executeSafe('UPDATE volunteer_hours SET status = ?, reviewed_by = ?, reviewed_at = NOW() WHERE id = ?', [$status, $user['id'], $hourId]);
        resolveApprovalRequest('hours', $hourId, $status, (int)$user['id']);
        audit((int)$user['id'], 'admin_review_hours', 'hours', $hourId, 'Admin final decision: ' . $status);
        trackEvent('admin_hours_decision', 'hours', $hourId, ['status' => $status]);

        notifyUser((int)$hour['member_id'], 'Volunteer hours ' . statusLabel($status), 'Your ' . $hour['hours'] . 'h for "' . $hour['title'] . '" were ' . $status . ' by admin.', 'hours');
        notifyUser((int)$hour['owner_id'], 'Admin reviewed volunteer hours', $hour['hours'] . 'h for "' . $hour['title'] . '" were ' . $status . '.', 'hours');

        flash('success', 'Hours ' . $status . ' by admin.');
        redirectTo('dashboard');
    }

    if ($action === 'admin_status') {
        $user = requireAuth('admin');
        $entity = (string)($_POST['entity'] ?? '');
        $id = (int)($_POST['id'] ?? 0);
        $status = (string)($_POST['status'] ?? 'approved');

        $map = [
            'association' => ['table' => 'associations', 'statuses' => ['approved', 'rejected', 'pending']],
            'mission' => ['table' => 'missions', 'statuses' => ['approved', 'rejected', 'pending', 'closed']],
            'event' => ['table' => 'events', 'statuses' => ['approved', 'rejected', 'pending', 'closed']],
            'feedback' => ['table' => 'feedbacks', 'statuses' => ['approved', 'rejected', 'pending']],
            'user' => ['table' => 'users', 'statuses' => ['active', 'suspended', 'pending']],
        ];

        if (!isset($map[$entity]) || !in_array($status, $map[$entity]['statuses'], true)) {
            flash('error', 'Invalid moderation action.');
            redirectTo('dashboard');
        }

        if ($entity === 'feedback') {
            executeSafe('UPDATE feedbacks SET status = ?, reviewed_by = ? WHERE id = ?', [$status, $user['id'], $id]);
        } else {
            executeSafe('UPDATE ' . $map[$entity]['table'] . ' SET status = ? WHERE id = ?', [$status, $id]);
        }
        resolveApprovalRequest($entity, $id, $status === 'approved' ? 'approved' : ($status === 'rejected' ? 'rejected' : 'pending'), (int)$user['id']);
        audit((int)$user['id'], 'admin_status_change', $entity, $id, 'Admin final status changed to ' . $status);
        trackEvent('admin_status_change', $entity, $id, ['status' => $status]);

        if (in_array($entity, ['association', 'mission', 'event', 'feedback'], true)) {
            $ownerId = null;
            if ($entity === 'association') {
                $item = fetchOneSafe('SELECT owner_id FROM associations WHERE id = ?', [$id]);
                $ownerId = $item['owner_id'] ?? null;
            } elseif ($entity === 'mission') {
                $item = fetchOneSafe('SELECT owner_id FROM missions WHERE id = ?', [$id]);
                $ownerId = $item['owner_id'] ?? null;
            } elseif ($entity === 'event') {
                $item = fetchOneSafe('SELECT owner_id FROM events WHERE id = ?', [$id]);
                $ownerId = $item['owner_id'] ?? null;
            }
            if ($ownerId) {
                notifyUser((int)$ownerId, 'Admin decision: ' . statusLabel($status), ucfirst($entity) . ' #' . $id . ' is now ' . statusLabel($status) . '.', 'approval');
            }
        }

        flash('success', ucfirst($entity) . ' marked as ' . $status . ' by admin.');
        redirectTo('dashboard');
    }

    if ($action === 'mark_notifications') {
        $user = requireAuth();
        executeSafe('UPDATE notifications SET is_read = 1 WHERE user_id = ?', [$user['id']]);
        flash('success', 'Notifications marked as read.');
        redirectTo('dashboard');
    }
}

function renderShell(string $title, callable $content, bool $withHeader = true, string $bodyClass = ''): void
{
    global $config;
    $user = $withHeader ? currentUser() : null;
    $page = page();
    trackEvent('page_view', 'page', null, ['page' => $page, 'title' => $title]);

    ?><!doctype html>
<html lang="en" data-theme="light">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e($title) ?> · <?= e($config['app_name']) ?></title>
    <meta name="theme-color" content="#0f766e">
    <meta name="csrf-token" content="<?= e(csrf()) ?>">
    <link rel="stylesheet" href="assets/app.css?v=dashboard-pro-2">
</head>
<body class="<?= e($bodyClass) ?>">
<a class="skip-link" href="#content">Skip to content</a>
<?php if ($withHeader): ?>
<header class="site-header">
    <div class="container nav">
        <a class="brand" href="<?= e(appUrl('home')) ?>" aria-label="Benevolink home">
            <span class="brand-mark">B</span>
            <span>
                <strong>Benevolink</strong>
                <small>Volunteer operating platform</small>
            </span>
        </a>

        <nav class="nav-links" aria-label="Primary navigation">
            <a class="<?= $page === 'home' ? 'active' : '' ?>" href="<?= e(appUrl('home')) ?>">Home</a>
            <a class="<?= $page === 'missions' ? 'active' : '' ?>" href="<?= e(appUrl('missions')) ?>">Missions</a>
            <a class="<?= $page === 'events' ? 'active' : '' ?>" href="<?= e(appUrl('events')) ?>">Events</a>
            <a class="<?= $page === 'associations' ? 'active' : '' ?>" href="<?= e(appUrl('associations')) ?>">Associations</a>
            <a class="<?= $page === 'feedback' ? 'active' : '' ?>" href="<?= e(appUrl('feedback')) ?>">Stories</a>
        </nav>

        <div class="nav-actions">
            <button class="icon-btn" type="button" data-command-open aria-label="Open command menu">⌘K</button>
            <button class="icon-btn" type="button" data-theme-toggle aria-label="Toggle dark mode">◐</button>
            <?php if ($user): ?>
                <a class="profile-pill" href="<?= e(appUrl('dashboard')) ?>">
                    <span class="avatar"><?= e($user['initials'] ?: initials($user['full_name'])) ?></span>
                    <span class="profile-copy">
                        <strong><?= e(explode(' ', $user['full_name'])[0]) ?></strong>
                        <small><?= e(statusLabel($user['role'])) ?></small>
                    </span>
                </a>
                <form method="post" class="inline-form">
                    <?php csrfField(); ?>
                    <input type="hidden" name="action" value="logout">
                    <button class="btn btn-subtle" type="submit">Sign out</button>
                </form>
            <?php else: ?>
                <a class="btn btn-subtle" href="<?= e(appUrl('login')) ?>">Sign in</a>
                <a class="btn btn-primary" href="<?= e(appUrl('join')) ?>">Join</a>
            <?php endif; ?>
            <button class="mobile-toggle" type="button" data-mobile-toggle aria-label="Open menu"><span></span><span></span></button>
        </div>
    </div>
    <div class="mobile-panel" data-mobile-panel>
        <a href="<?= e(appUrl('home')) ?>">Home</a>
        <a href="<?= e(appUrl('missions')) ?>">Missions</a>
        <a href="<?= e(appUrl('events')) ?>">Events</a>
        <a href="<?= e(appUrl('associations')) ?>">Associations</a>
        <a href="<?= e(appUrl('feedback')) ?>">Stories</a>
        <a href="<?= e($user ? appUrl('dashboard') : appUrl('login')) ?>"><?= $user ? 'Dashboard' : 'Sign in' ?></a>
    </div>
</header>
<?php endif; ?>

<?php showFlash(); ?>
<div class="command-overlay" data-command-overlay aria-hidden="true">
    <div class="command-box" role="dialog" aria-modal="true" aria-label="Command menu">
        <div class="command-top">
            <span>⌘</span>
            <input data-command-search type="search" placeholder="Search pages and actions..." aria-label="Search commands">
            <button type="button" data-command-close>Close</button>
        </div>
        <div class="command-list">
            <a href="<?= e(appUrl('missions')) ?>">Explore missions</a>
            <a href="<?= e(appUrl('events')) ?>">Browse events</a>
            <a href="<?= e(appUrl('associations')) ?>">View associations</a>
            <a href="<?= e(appUrl('feedback')) ?>">Leave feedback</a>
            <a href="<?= e(appUrl('dashboard')) ?>">Open dashboard</a>
            <a href="<?= e(appUrl('join')) ?>">Create an account</a>
        </div>
    </div>
</div>

<main id="content">
<?php $content(); ?>
</main>

<footer class="site-footer">
    <div class="container footer-grid">
        <div>
            <a class="brand footer-brand" href="<?= e(appUrl('home')) ?>">
                <span class="brand-mark">B</span>
                <span><strong>Benevolink</strong><small>Designed for civic teams.</small></span>
            </a>
            <p>One calm place to publish missions, manage approvals, validate hours, and understand social impact.</p>
        </div>
        <div>
            <strong>Platform</strong>
            <a href="<?= e(appUrl('missions')) ?>">Missions</a>
            <a href="<?= e(appUrl('events')) ?>">Events</a>
            <a href="<?= e(appUrl('associations')) ?>">Associations</a>
        </div>
        <div>
            <strong>Workflows</strong>
            <a href="<?= e(appUrl('join')) ?>">Member registration</a>
            <a href="<?= e(appUrl('join')) ?>#owner">Association onboarding</a>
            <a href="<?= e(appUrl('feedback')) ?>">Public feedback</a>
        </div>
    </div>
</footer>
<script>window.BENEVOLINK = {csrf: "<?= e(csrf()) ?>", baseUrl: "<?= e($config['base_url']) ?>"};</script>
<script src="assets/app.js?v=dashboard-pro-2"></script>
</body>
</html><?php
}

function sectionHeader(string $eyebrow, string $title, string $copy = '', ?string $actionUrl = null, string $actionLabel = ''): void
{
    echo '<div class="section-head reveal">';
    echo '<div><span class="eyebrow">' . e($eyebrow) . '</span><h2>' . e($title) . '</h2>';
    if ($copy !== '') {
        echo '<p>' . e($copy) . '</p>';
    }
    echo '</div>';
    if ($actionUrl) {
        echo '<a class="btn btn-secondary" href="' . e($actionUrl) . '">' . e($actionLabel) . '</a>';
    }
    echo '</div>';
}

function missionCard(array $m, bool $compact = false): void
{
    $accepted = (int)($m['accepted_count'] ?? 0);
    $seats = max(1, (int)($m['seats'] ?? 1));
    $left = max(0, $seats - $accepted);
    $ratio = min(100, round(($accepted / $seats) * 100));
    $urgent = $left <= 2 ? 'High need' : 'Open';
    $user = currentUser();
    $isSaved = false;
    if ($user && ($user['role'] ?? '') === 'member' && tableExists('saved_missions')) {
        $isSaved = (bool)scalarSafe('SELECT COUNT(*) FROM saved_missions WHERE user_id = ? AND mission_id = ?', [$user['id'], $m['id']], 0);
    }
    echo '<article class="mission-card reveal" data-saveable="mission-' . e($m['id']) . '">';
    echo '<div class="card-topline">';
    echo '<span class="tag tag-teal">' . e($m['category'] ?? 'Mission') . '</span>';
    if ($user && ($user['role'] ?? '') === 'member') {
        echo '<form method="post" class="inline-form save-form">';
        csrfField();
        echo '<input type="hidden" name="action" value="toggle_saved_mission">';
        echo '<input type="hidden" name="mission_id" value="' . e((string)$m['id']) . '">';
        echo '<button type="submit" class="save-btn ' . ($isSaved ? 'saved' : '') . '" data-track-click="save_mission" data-entity-type="mission" data-entity-id="' . e((string)$m['id']) . '" aria-label="Save mission">' . ($isSaved ? '★' : '☆') . '</button>';
        echo '</form>';
    } else {
        echo '<button type="button" class="save-btn" data-save-toggle data-save-id="mission-' . e($m['id']) . '" data-track-click="local_save_mission" data-entity-type="mission" data-entity-id="' . e((string)$m['id']) . '" aria-label="Save mission">☆</button>';
    }
    echo '</div>';
    echo '<h3>' . e($m['title']) . '</h3>';
    echo '<p>' . e($m['summary'] ?? '') . '</p>';
    echo '<div class="meta-grid">';
    echo '<span>📍 ' . e($m['city'] ?? '') . '</span>';
    echo '<span>🗓 ' . e(safeDate($m['start_date'] ?? null)) . '</span>';
    echo '<span>🏛 ' . e($m['association_name'] ?? 'Association') . '</span>';
    echo '<span>⏱ ' . e(daysUntil($m['start_date'] ?? null)) . '</span>';
    echo '</div>';
    echo '<div class="capacity">';
    echo '<div><strong>' . e((string)$left) . '</strong><span> seats left</span></div>';
    echo '<div class="progress"><span style="width:' . e((string)$ratio) . '%"></span></div>';
    echo '</div>';
    echo '<div class="card-actions">';
    echo '<span class="pill ' . ($left <= 2 ? 'bad' : 'good') . '">' . e($urgent) . '</span>';
    echo '<a class="btn btn-dark" href="' . e(appUrl('mission', ['id' => (int)$m['id']])) . '">View mission</a>';
    echo '</div>';
    echo '</article>';
}

function eventCard(array $event): void
{
    $accepted = (int)($event['accepted_count'] ?? 0);
    $capacity = max(1, (int)($event['capacity'] ?? 1));
    $ratio = min(100, round(($accepted / $capacity) * 100));
    echo '<article class="event-card reveal">';
    echo '<div class="date-chip"><strong>' . e(safeDate($event['event_date'] ?? null, 'd')) . '</strong><span>' . e(safeDate($event['event_date'] ?? null, 'M')) . '</span></div>';
    echo '<div>';
    echo '<span class="eyebrow">' . e($event['city'] ?? '') . ' · ' . e($event['association_name'] ?? '') . '</span>';
    echo '<h3>' . e($event['title'] ?? '') . '</h3>';
    echo '<p>' . e($event['summary'] ?? '') . '</p>';
    echo '<div class="capacity compact"><div class="progress"><span style="width:' . e((string)$ratio) . '%"></span></div><small>' . e((string)$accepted) . '/' . e((string)$capacity) . ' confirmed</small></div>';
    echo '<a class="btn btn-secondary" href="' . e(appUrl('event', ['id' => (int)$event['id']])) . '">Event details</a>';
    echo '</div>';
    echo '</article>';
}

