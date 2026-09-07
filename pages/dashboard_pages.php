<?php
/**
 * Workspace and dashboard pages.
 * Shared dashboard shell plus role-specific member, owner, and admin dashboards.
 */
function renderWorkspaceShell(string $title, string $active, callable $content): void
{
    $user = requireAuth();
    global $config;
    $notifications = fetchAllSafe('SELECT * FROM notifications WHERE user_id = ? ORDER BY id DESC LIMIT 6', [$user['id']]);
    $unread = (int)scalarSafe('SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0', [$user['id']], 0);
    trackEvent('workspace_view', 'dashboard', null, ['role' => $user['role'], 'title' => $title]);

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
<body class="workspace-body">
<a class="skip-link" href="#content">Skip to content</a>
<?php showFlash(); ?>
<div class="workspace-shell">
    <aside class="workspace-sidebar">
        <a class="brand workspace-brand" href="<?= e(appUrl('home')) ?>">
            <span class="brand-mark">B</span>
            <span><strong>Benevolink</strong><small><?= e(statusLabel($user['role'])) ?> workspace</small></span>
        </a>
        <nav class="workspace-nav">
            <a class="<?= $active === 'overview' ? 'active' : '' ?>" href="<?= e(appUrl('dashboard')) ?>">Overview</a>
            <a href="<?= e(appUrl('missions')) ?>">Public missions</a>
            <a href="<?= e(appUrl('events')) ?>">Events</a>
            <a href="<?= e(appUrl('feedback')) ?>">Feedback</a>
            <button type="button" data-command-open>Command menu</button>
        </nav>
        <div class="workspace-user">
            <span class="avatar"><?= e($user['initials'] ?: initials($user['full_name'])) ?></span>
            <div><strong><?= e($user['full_name']) ?></strong><small><?= e($user['email']) ?></small></div>
        </div>
    </aside>

    <div class="workspace-main">
        <header class="workspace-topbar">
            <div>
                <span class="eyebrow"><?= e(statusLabel($user['role'])) ?> console</span>
                <h1><?= e($title) ?></h1>
            </div>
            <div class="topbar-actions">
                <button class="icon-btn" type="button" data-theme-toggle>◐</button>
                <button class="icon-btn notification-trigger" type="button" data-popover-toggle="notifications">🔔<?php if ($unread): ?><span><?= e((string)$unread) ?></span><?php endif; ?></button>
                <form method="post" class="inline-form">
                    <?php csrfField(); ?>
                    <input type="hidden" name="action" value="logout">
                    <button class="btn btn-subtle" type="submit">Sign out</button>
                </form>
            </div>
            <div class="notification-panel" data-popover="notifications">
                <div class="panel-title">
                    <strong>Notifications</strong>
                    <form method="post">
                        <?php csrfField(); ?>
                        <input type="hidden" name="action" value="mark_notifications">
                        <button type="submit">Mark read</button>
                    </form>
                </div>
                <?php foreach ($notifications as $n): ?>
                    <article class="<?= (int)$n['is_read'] ? '' : 'unread' ?>">
                        <strong><?= e($n['title']) ?></strong>
                        <p><?= e($n['body']) ?></p>
                        <small><?= e(safeDate($n['created_at'], 'M j · H:i')) ?></small>
                    </article>
                <?php endforeach; ?>
                <?php if (!$notifications): ?><p class="muted">No notifications yet.</p><?php endif; ?>
            </div>
        </header>

        <main id="content" class="workspace-content">
            <?php $content($user); ?>
        </main>
    </div>
</div>

<div class="command-overlay" data-command-overlay aria-hidden="true">
    <div class="command-box" role="dialog" aria-modal="true">
        <div class="command-top">
            <span>⌘</span>
            <input data-command-search type="search" placeholder="Search workspace...">
            <button type="button" data-command-close>Close</button>
        </div>
        <div class="command-list">
            <a href="<?= e(appUrl('dashboard')) ?>">Dashboard overview</a>
            <a href="<?= e(appUrl('missions')) ?>">Mission discovery</a>
            <a href="<?= e(appUrl('events')) ?>">Events</a>
            <a href="<?= e(appUrl('associations')) ?>">Associations</a>
            <a href="<?= e(appUrl('feedback')) ?>">Feedback</a>
        </div>
    </div>
</div>
<script>window.BENEVOLINK = {csrf: "<?= e(csrf()) ?>", baseUrl: "<?= e($config['base_url']) ?>"};</script>
<script src="assets/app.js?v=dashboard-pro-2"></script>
</body>
</html><?php
}

function statCard(string $label, string $value, string $meta = '', string $tone = 'teal'): void
{
    echo '<article class="stat-card tone-' . e($tone) . ' reveal">';
    echo '<span>' . e($label) . '</span>';
    echo '<strong>' . e($value) . '</strong>';
    if ($meta !== '') {
        echo '<small>' . e($meta) . '</small>';
    }
    echo '</article>';
}

function actionForm(string $action, array $hidden, string $label, string $class = 'btn btn-secondary'): void
{
    echo '<form method="post" class="inline-form">';
    csrfField();
    echo '<input type="hidden" name="action" value="' . e($action) . '">';
    foreach ($hidden as $key => $value) {
        echo '<input type="hidden" name="' . e($key) . '" value="' . e((string)$value) . '">';
    }
    echo '<button class="' . e($class) . '" type="submit">' . e($label) . '</button>';
    echo '</form>';
}

function renderDashboard(): void
{
    $user = requireAuth();
    match ($user['role']) {
        'admin' => renderAdminDashboard(),
        'owner' => renderOwnerDashboard(),
        default => renderMemberDashboard(),
    };
}

function renderMemberDashboard(): void
{
    renderWorkspaceShell('Member impact dashboard', 'overview', function (array $user) {
        $applications = fetchAllSafe('
            SELECT ap.*, m.title, m.city, m.start_date, a.name AS association_name
            FROM applications ap
            JOIN missions m ON m.id = ap.mission_id
            JOIN associations a ON a.id = m.association_id
            WHERE ap.member_id = ?
            ORDER BY ap.id DESC
        ', [$user['id']]);

        $participations = fetchAllSafe('
            SELECT p.*, m.title, m.city, m.start_date, a.name AS association_name
            FROM participations p
            JOIN missions m ON m.id = p.mission_id
            JOIN associations a ON a.id = m.association_id
            WHERE p.member_id = ?
            ORDER BY p.id DESC
        ', [$user['id']]);

        $hours = fetchAllSafe('
            SELECT vh.*, m.title
            FROM volunteer_hours vh
            JOIN missions m ON m.id = vh.mission_id
            WHERE vh.member_id = ?
            ORDER BY vh.work_date DESC, vh.id DESC
        ', [$user['id']]);

        $eventRegs = fetchAllSafe('
            SELECT er.*, e.title, e.event_date, e.city
            FROM event_registrations er
            JOIN events e ON e.id = er.event_id
            WHERE er.member_id = ?
            ORDER BY er.id DESC
        ', [$user['id']]);

        $skills = tableExists('member_skills') ? fetchAllSafe('SELECT * FROM member_skills WHERE user_id = ? ORDER BY FIELD(level, "advanced", "intermediate", "beginner"), skill', [$user['id']]) : [];

        $approvedHours = (float)scalarSafe('SELECT COALESCE(SUM(hours),0) FROM volunteer_hours WHERE member_id = ? AND status = "approved"', [$user['id']], 0);
        $acceptedApps = (int)scalarSafe('SELECT COUNT(*) FROM applications WHERE member_id = ? AND status = "accepted"', [$user['id']], 0);
        $pendingApps = (int)scalarSafe('SELECT COUNT(*) FROM applications WHERE member_id = ? AND status = "pending"', [$user['id']], 0);
        $level = min(100, (int)round(($approvedHours / 50) * 100));
        $recommended = approvedMissions(4, ['city' => $user['city'] ?? '']);

        ?>
        <section class="workspace-hero member-hero reveal">
            <div>
                <span class="eyebrow">Welcome back</span>
                <h2><?= e($user['full_name']) ?>, your civic impact is growing.</h2>
                <p>Track accepted missions, submit hours, collect badges, and keep your next actions visible.</p>
            </div>
            <div class="level-card">
                <span>Impact level</span>
                <strong><?= e((string)$level) ?>%</strong>
                <div class="progress"><span style="width:<?= e((string)$level) ?>%"></span></div>
                <small><?= e(number_format($approvedHours, 1)) ?> verified hours toward the next level</small>
            </div>
        </section>

        <section class="stat-grid">
            <?php statCard('Verified hours', number_format($approvedHours, 1), 'Approved by owner/admin', 'teal'); ?>
            <?php statCard('Accepted missions', (string)$acceptedApps, 'Confirmed participations', 'sky'); ?>
            <?php statCard('Pending applications', (string)$pendingApps, 'Awaiting review', 'amber'); ?>
            <?php statCard('Event requests', (string)count($eventRegs), 'Community activities', 'violet'); ?>
        </section>

        <?php renderInteractiveInsights('member', $user); ?>

        <section class="workspace-grid two">
            <article class="workspace-panel reveal">
                <div class="panel-heading">
                    <div><span class="eyebrow">Next action</span><h3>Submit volunteer hours</h3></div>
                </div>
                <?php if ($participations): ?>
                    <form method="post" id="hours-form" class="stack-form compact-form">
                        <?php csrfField(); ?>
                        <input type="hidden" name="action" value="submit_hours">
                        <label>Participation
                            <select name="participation_id">
                                <?php foreach ($participations as $p): ?>
                                    <option value="<?= e((string)$p['id']) ?>"><?= e($p['title']) ?> · <?= e($p['association_name']) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </label>
                        <div class="form-row">
                            <label>Date <input type="date" name="work_date" value="<?= e(date('Y-m-d')) ?>"></label>
                            <label>Hours <input type="number" min="0.5" max="24" step="0.5" name="hours" value="2"></label>
                        </div>
                        <label>Note <input name="note" placeholder="What did you contribute?"></label>
                        <button class="btn btn-primary" type="submit">Submit for validation</button>
                    </form>
                <?php else: ?>
                    <div class="empty-state"><strong>No accepted participation yet.</strong><p>Apply to approved missions first.</p><a class="btn btn-secondary" href="<?= e(appUrl('missions')) ?>">Find missions</a></div>
                <?php endif; ?>
            </article>

            <article class="workspace-panel reveal">
                <div class="panel-heading">
                    <div><span class="eyebrow">Reputation</span><h3>Badges and certificates</h3></div>
                </div>
                <div class="badge-grid">
                    <div class="achievement <?= $approvedHours >= 1 ? 'earned' : '' ?>"><span>🌱</span><strong>First hour</strong><small>Submit approved hours</small></div>
                    <div class="achievement <?= $approvedHours >= 10 ? 'earned' : '' ?>"><span>🤝</span><strong>Reliable helper</strong><small>10 verified hours</small></div>
                    <div class="achievement <?= $acceptedApps >= 3 ? 'earned' : '' ?>"><span>🏅</span><strong>Mission regular</strong><small>3 accepted missions</small></div>
                </div>
                <div class="skill-cloud">
                    <?php foreach ($skills as $skill): ?>
                        <span class="skill-pill"><?= e($skill['skill']) ?> <small><?= e($skill['level']) ?></small></span>
                    <?php endforeach; ?>
                    <?php if (!$skills): ?><p class="muted">Add skills to improve recommendations.</p><?php endif; ?>
                </div>
                <form method="post" class="inline-skill-form">
                    <?php csrfField(); ?>
                    <input type="hidden" name="action" value="add_skill">
                    <input name="skill" placeholder="Add skill e.g. tutoring">
                    <select name="level"><option>beginner</option><option selected>intermediate</option><option>advanced</option></select>
                    <button class="btn btn-small btn-secondary" type="submit">Save skill</button>
                </form>
                <div class="certificate-card">
                    <strong>Volunteer certificate</strong>
                    <p>Generated after verified hours are approved.</p>
                    <button class="btn btn-subtle" type="button" disabled>Generate PDF soon</button>
                </div>
            </article>
        </section>

        <section class="workspace-grid two">
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Applications</span><h3>Your mission pipeline</h3></div></div>
                <div class="rich-table">
                    <?php foreach ($applications as $a): ?>
                        <div class="table-row">
                            <div><strong><?= e($a['title']) ?></strong><small><?= e($a['association_name']) ?> · <?= e(safeDate($a['start_date'])) ?></small></div>
                            <span class="pill <?= e(statusClass($a['status'])) ?>"><?= e(statusLabel($a['status'])) ?></span>
                        </div>
                    <?php endforeach; ?>
                    <?php if (!$applications): ?><div class="empty-state"><strong>No applications yet.</strong><p>Start by exploring approved missions.</p></div><?php endif; ?>
                </div>
            </article>

            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Recommended</span><h3>Near your city</h3></div><a href="<?= e(appUrl('missions')) ?>">View all</a></div>
                <div class="mini-card-list">
                    <?php foreach ($recommended as $m): ?>
                        <a href="<?= e(appUrl('mission', ['id' => $m['id']])) ?>">
                            <span class="tag tag-teal"><?= e($m['category']) ?></span>
                            <strong><?= e($m['title']) ?></strong>
                            <small><?= e($m['city']) ?> · <?= e(safeDate($m['start_date'])) ?></small>
                        </a>
                    <?php endforeach; ?>
                    <?php if (!$recommended): ?><div class="empty-state"><strong>No recommendations yet.</strong></div><?php endif; ?>
                </div>
            </article>
        </section>

        <section class="workspace-panel reveal">
            <div class="panel-heading"><div><span class="eyebrow">History</span><h3>Hours and event requests</h3></div></div>
            <div class="dual-list">
                <div>
                    <h4>Hours</h4>
                    <?php foreach ($hours as $h): ?>
                        <div class="table-row">
                            <div><strong><?= e(number_format((float)$h['hours'], 1)) ?>h · <?= e($h['title']) ?></strong><small><?= e(safeDate($h['work_date'])) ?></small></div>
                            <span class="pill <?= e(statusClass($h['status'])) ?>"><?= e(statusLabel($h['status'])) ?></span>
                        </div>
                    <?php endforeach; ?>
                    <?php if (!$hours): ?><p class="muted">No hour submissions yet.</p><?php endif; ?>
                </div>
                <div>
                    <h4>Events</h4>
                    <?php foreach ($eventRegs as $er): ?>
                        <div class="table-row">
                            <div><strong><?= e($er['title']) ?></strong><small><?= e($er['city']) ?> · <?= e(safeDate($er['event_date'])) ?></small></div>
                            <span class="pill <?= e(statusClass($er['status'])) ?>"><?= e(statusLabel($er['status'])) ?></span>
                        </div>
                    <?php endforeach; ?>
                    <?php if (!$eventRegs): ?><p class="muted">No event requests yet.</p><?php endif; ?>
                </div>
            </div>
        </section>
        <?php
    });
}

function renderOwnerDashboard(): void
{
    renderWorkspaceShell('Association operations', 'overview', function (array $user) {
        $assoc = ownerAssociation((int)$user['id']);
        $assocId = (int)($assoc['id'] ?? 0);

        $missions = fetchAllSafe('
            SELECT m.*, COUNT(ap.id) AS applications_count
            FROM missions m
            LEFT JOIN applications ap ON ap.mission_id = m.id
            WHERE m.owner_id = ?
            GROUP BY m.id
            ORDER BY m.id DESC
        ', [$user['id']]);

        $applications = fetchAllSafe('
            SELECT ap.*, m.title, m.start_date, u.full_name, u.city
            FROM applications ap
            JOIN missions m ON m.id = ap.mission_id
            JOIN users u ON u.id = ap.member_id
            WHERE m.owner_id = ?
            ORDER BY FIELD(ap.status, "pending", "accepted", "rejected"), ap.id DESC
        ', [$user['id']]);

        $hours = fetchAllSafe('
            SELECT vh.*, m.title, u.full_name
            FROM volunteer_hours vh
            JOIN missions m ON m.id = vh.mission_id
            JOIN users u ON u.id = vh.member_id
            WHERE m.owner_id = ?
            ORDER BY FIELD(vh.status, "pending", "approved", "rejected"), vh.id DESC
        ', [$user['id']]);

        $events = fetchAllSafe('SELECT * FROM events WHERE owner_id = ? ORDER BY id DESC', [$user['id']]);
        $eventRegs = fetchAllSafe('
            SELECT er.*, e.title, e.event_date, u.full_name
            FROM event_registrations er
            JOIN events e ON e.id = er.event_id
            JOIN users u ON u.id = er.member_id
            WHERE e.owner_id = ?
            ORDER BY FIELD(er.status, "pending", "accepted", "rejected"), er.id DESC
        ', [$user['id']]);

        $messages = tableExists('association_messages') ? fetchAllSafe('
            SELECT am.*, a.name AS association_name
            FROM association_messages am
            JOIN associations a ON a.id = am.association_id
            WHERE a.owner_id = ?
            ORDER BY am.id DESC
            LIMIT 8
        ', [$user['id']]) : [];

        $approvedHours = (float)scalarSafe('
            SELECT COALESCE(SUM(vh.hours),0)
            FROM volunteer_hours vh
            JOIN missions m ON m.id = vh.mission_id
            WHERE m.owner_id = ? AND vh.status = "approved"
        ', [$user['id']], 0);

        ?>
        <section class="workspace-hero owner-hero reveal">
            <div>
                <span class="eyebrow">Owner workspace · admin-governed</span>
                <h2><?= e($assoc['name'] ?? 'Association profile') ?></h2>
                <p><?= e($assoc ? 'Status: ' . statusLabel($assoc['status']) . ' · ' . $assoc['city'] . ' · admin has final approval on every public or participation decision.' : 'Create your association profile to start publishing missions.') ?></p>
            </div>
            <span class="pill <?= e(statusClass($assoc['status'] ?? 'pending')) ?>"><?= e(statusLabel($assoc['status'] ?? 'pending')) ?></span>
        </section>

        <section class="stat-grid">
            <?php statCard('Missions', (string)count($missions), 'Created by your association', 'teal'); ?>
            <?php statCard('Applications', (string)count($applications), 'All statuses', 'sky'); ?>
            <?php statCard('Waiting admin', (string)array_sum(array_map(fn($a) => $a['status'] === 'pending' ? 1 : 0, $applications)), 'Admin final approval', 'amber'); ?>
            <?php statCard('Approved hours', number_format($approvedHours, 1), 'Validated impact', 'violet'); ?>
        </section>

        <?php renderInteractiveInsights('owner', $user); ?>

        <section class="workspace-grid two">
            <article class="workspace-panel reveal" data-panel="create-mission">
                <div class="panel-heading"><div><span class="eyebrow">Create</span><h3>New mission</h3></div></div>
                <form method="post" class="stack-form compact-form">
                    <?php csrfField(); ?>
                    <input type="hidden" name="action" value="create_mission">
                    <label>Title <input name="title" required placeholder="Food distribution support"></label>
                    <label>Summary <input name="summary" required placeholder="Short public summary"></label>
                    <div class="form-row">
                        <label>Category <input name="category" value="Social impact"></label>
                        <label>City <input name="city" value="<?= e($assoc['city'] ?? $user['city'] ?? '') ?>"></label>
                    </div>
                    <div class="form-row">
                        <label>Start <input type="date" name="start_date" value="<?= e(date('Y-m-d')) ?>"></label>
                        <label>End <input type="date" name="end_date" value="<?= e(date('Y-m-d')) ?>"></label>
                        <label>Seats <input type="number" name="seats" min="1" value="5"></label>
                    </div>
                    <label>Description <textarea name="description" rows="4" required placeholder="What volunteers will do, what to bring, expected schedule..."></textarea></label>
                    <button class="btn btn-primary" type="submit">Send mission for approval</button>
                </form>
            </article>

            <article class="workspace-panel reveal" data-panel="create-event">
                <div class="panel-heading"><div><span class="eyebrow">Create</span><h3>New event</h3></div></div>
                <form method="post" class="stack-form compact-form">
                    <?php csrfField(); ?>
                    <input type="hidden" name="action" value="create_event">
                    <label>Title <input name="title" required placeholder="Community day"></label>
                    <label>Summary <input name="summary" required placeholder="Short public summary"></label>
                    <div class="form-row">
                        <label>City <input name="city" value="<?= e($assoc['city'] ?? $user['city'] ?? '') ?>"></label>
                        <label>Date <input type="date" name="event_date" value="<?= e(date('Y-m-d')) ?>"></label>
                        <label>Capacity <input type="number" name="capacity" min="1" value="20"></label>
                    </div>
                    <label>Description <textarea name="description" rows="4" required placeholder="What will happen during the event?"></textarea></label>
                    <button class="btn btn-dark" type="submit">Send event for approval</button>
                </form>
            </article>
        </section>

        <section class="workspace-grid two">
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Visibility</span><h3>Volunteer applications awaiting admin</h3></div></div>
                <div class="rich-table">
                    <?php foreach ($applications as $a): ?>
                        <div class="table-row with-actions">
                            <div><strong><?= e($a['full_name']) ?></strong><small><?= e($a['title']) ?> · <?= e($a['city'] ?? '') ?></small></div>
                            <span class="pill <?= e(statusClass($a['status'])) ?>"><?= e(statusLabel($a['status'])) ?></span>
                            <?php if ($a['status'] === 'pending'): ?>
                                <div class="row-actions">
                                    <span class="pill warn">Admin review</span>
                                </div>
                            <?php endif; ?>
                        </div>
                    <?php endforeach; ?>
                    <?php if (!$applications): ?><div class="empty-state"><strong>No applications yet.</strong></div><?php endif; ?>
                </div>
            </article>

            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Visibility</span><h3>Volunteer hours awaiting admin</h3></div></div>
                <div class="rich-table">
                    <?php foreach ($hours as $h): ?>
                        <div class="table-row with-actions">
                            <div><strong><?= e($h['full_name']) ?> · <?= e(number_format((float)$h['hours'], 1)) ?>h</strong><small><?= e($h['title']) ?> · <?= e(safeDate($h['work_date'])) ?></small></div>
                            <span class="pill <?= e(statusClass($h['status'])) ?>"><?= e(statusLabel($h['status'])) ?></span>
                            <?php if ($h['status'] === 'pending'): ?>
                                <div class="row-actions">
                                    <span class="pill warn">Admin validation</span>
                                </div>
                            <?php endif; ?>
                        </div>
                    <?php endforeach; ?>
                    <?php if (!$hours): ?><div class="empty-state"><strong>No submitted hours yet.</strong></div><?php endif; ?>
                </div>
            </article>
        </section>

        <section class="workspace-grid two">
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Missions</span><h3>Publication board</h3></div></div>
                <div class="kanban-board">
                    <?php foreach (['pending' => 'Pending', 'approved' => 'Approved', 'rejected' => 'Rejected', 'closed' => 'Closed'] as $status => $label): ?>
                        <div class="kanban-column">
                            <strong><?= e($label) ?></strong>
                            <?php foreach ($missions as $m): if ($m['status'] !== $status) continue; ?>
                                <div class="kanban-card">
                                    <span class="tag tag-teal"><?= e($m['category']) ?></span>
                                    <b><?= e($m['title']) ?></b>
                                    <small><?= e((string)$m['applications_count']) ?> applications · <?= e(safeDate($m['start_date'])) ?></small>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endforeach; ?>
                </div>
            </article>

            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Events</span><h3>Registrations</h3></div></div>
                <div class="rich-table">
                    <?php foreach ($eventRegs as $r): ?>
                        <div class="table-row with-actions">
                            <div><strong><?= e($r['full_name']) ?></strong><small><?= e($r['title']) ?> · <?= e(safeDate($r['event_date'])) ?></small></div>
                            <span class="pill <?= e(statusClass($r['status'])) ?>"><?= e(statusLabel($r['status'])) ?></span>
                            <?php if ($r['status'] === 'pending'): ?>
                                <div class="row-actions">
                                    <span class="pill warn">Admin review</span>
                                </div>
                            <?php endif; ?>
                        </div>
                    <?php endforeach; ?>
                    <?php if (!$eventRegs): ?><div class="empty-state"><strong>No event registrations yet.</strong></div><?php endif; ?>
                </div>
            </article>

            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Inbox</span><h3>Association messages</h3></div></div>
                <div class="rich-table">
                    <?php foreach ($messages as $msg): ?>
                        <div class="table-row">
                            <div>
                                <strong><?= e($msg['sender_name']) ?></strong>
                                <small><?= e($msg['association_name']) ?> · <?= e($msg['sender_email']) ?> · <?= e(safeDate($msg['created_at'], 'M j H:i')) ?></small>
                                <p class="table-note"><?= e($msg['message']) ?></p>
                            </div>
                            <span class="pill neutral"><?= e(statusLabel($msg['status'])) ?></span>
                        </div>
                    <?php endforeach; ?>
                    <?php if (!$messages): ?><div class="empty-state"><strong>No messages yet.</strong><p>Public association pages now include a contact form.</p></div><?php endif; ?>
                </div>
            </article>
        </section>
        <?php
    });
}

function moderationTable(string $entity, array $rows, array $columns): void
{
    echo '<div class="moderation-stack">';
    foreach ($rows as $row) {
        echo '<div class="moderation-card">';
        echo '<div>';
        echo '<span class="tag tag-amber">' . e($entity) . '</span>';
        echo '<h4>' . e($row[$columns['title']] ?? ('#' . $row['id'])) . '</h4>';
        if (isset($columns['subtitle'])) {
            echo '<p>' . e($row[$columns['subtitle']] ?? '') . '</p>';
        }
        echo '<small>ID #' . e((string)$row['id']) . ' · status: ' . e(statusLabel($row['status'] ?? 'pending')) . '</small>';
        echo '</div>';
        echo '<div class="row-actions">';
        actionForm('admin_status', ['entity' => $entity, 'id' => $row['id'], 'status' => 'approved'], 'Approve', 'btn btn-small btn-primary');
        actionForm('admin_status', ['entity' => $entity, 'id' => $row['id'], 'status' => 'rejected'], 'Reject', 'btn btn-small btn-subtle');
        echo '</div>';
        echo '</div>';
    }
    if (!$rows) {
        echo '<div class="empty-state"><strong>No pending ' . e($entity) . ' items.</strong><p>The queue is clean.</p></div>';
    }
    echo '</div>';
}

function adminDecisionTable(string $kind, array $rows): void
{
    echo '<div class="moderation-stack">';
    foreach ($rows as $row) {
        echo '<div class="moderation-card">';
        echo '<div>';
        echo '<span class="tag tag-sky">Admin final decision</span>';

        if ($kind === 'application') {
            echo '<h4>' . e($row['member_name']) . ' → ' . e($row['mission_title']) . '</h4>';
            echo '<p>' . e($row['motivation'] ?: 'No motivation message provided.') . '</p>';
            echo '<small>' . e($row['association_name']) . ' · ' . e($row['city'] ?? '') . ' · #' . e((string)$row['id']) . '</small>';
            echo '</div><div class="row-actions">';
            actionForm('review_application', ['application_id' => $row['id'], 'decision' => 'accepted'], 'Approve', 'btn btn-small btn-primary');
            actionForm('review_application', ['application_id' => $row['id'], 'decision' => 'rejected'], 'Reject', 'btn btn-small btn-subtle');
        } elseif ($kind === 'hours') {
            echo '<h4>' . e($row['member_name']) . ' · ' . e(number_format((float)$row['hours'], 1)) . 'h</h4>';
            echo '<p>' . e($row['mission_title']) . ' · ' . e(safeDate($row['work_date'])) . ' · ' . e($row['note'] ?: 'No note.') . '</p>';
            echo '<small>' . e($row['association_name']) . ' · #' . e((string)$row['id']) . '</small>';
            echo '</div><div class="row-actions">';
            actionForm('review_hours', ['hour_id' => $row['id'], 'decision' => 'approved'], 'Approve', 'btn btn-small btn-primary');
            actionForm('review_hours', ['hour_id' => $row['id'], 'decision' => 'rejected'], 'Reject', 'btn btn-small btn-subtle');
        } else {
            echo '<h4>' . e($row['member_name']) . ' → ' . e($row['event_title']) . '</h4>';
            echo '<p>' . e($row['association_name']) . ' · ' . e($row['city']) . ' · ' . e(safeDate($row['event_date'])) . '</p>';
            echo '<small>Registration #' . e((string)$row['id']) . '</small>';
            echo '</div><div class="row-actions">';
            actionForm('review_event_registration', ['registration_id' => $row['id'], 'decision' => 'accepted'], 'Approve', 'btn btn-small btn-primary');
            actionForm('review_event_registration', ['registration_id' => $row['id'], 'decision' => 'rejected'], 'Reject', 'btn btn-small btn-subtle');
        }

        echo '</div>';
        echo '</div>';
    }
    if (!$rows) {
        echo '<div class="empty-state"><strong>No pending ' . e(str_replace('_', ' ', $kind)) . ' items.</strong><p>Everything that needs admin approval will appear here.</p></div>';
    }
    echo '</div>';
}

function renderAdminDashboard(): void
{
    renderWorkspaceShell('Admin command center', 'overview', function (array $user) {
        $stats = appStats();
        $pendingAssociations = fetchAllSafe('SELECT * FROM associations WHERE status = "pending" ORDER BY id DESC');
        $pendingMissions = fetchAllSafe('SELECT m.*, a.name AS association_name FROM missions m JOIN associations a ON a.id = m.association_id WHERE m.status = "pending" ORDER BY m.id DESC');
        $pendingEvents = fetchAllSafe('SELECT e.*, a.name AS association_name FROM events e JOIN associations a ON a.id = e.association_id WHERE e.status = "pending" ORDER BY e.id DESC');
        $pendingFeedbacks = fetchAllSafe('SELECT * FROM feedbacks WHERE status = "pending" ORDER BY id DESC');
        $pendingApplications = fetchAllSafe('
            SELECT ap.*, u.full_name AS member_name, u.city, m.title AS mission_title, a.name AS association_name
            FROM applications ap
            JOIN users u ON u.id = ap.member_id
            JOIN missions m ON m.id = ap.mission_id
            JOIN associations a ON a.id = m.association_id
            WHERE ap.status = "pending"
            ORDER BY ap.id DESC
        ');
        $pendingHours = fetchAllSafe('
            SELECT vh.*, u.full_name AS member_name, m.title AS mission_title, a.name AS association_name
            FROM volunteer_hours vh
            JOIN users u ON u.id = vh.member_id
            JOIN missions m ON m.id = vh.mission_id
            JOIN associations a ON a.id = m.association_id
            WHERE vh.status = "pending"
            ORDER BY vh.id DESC
        ');
        $pendingEventRegs = fetchAllSafe('
            SELECT er.*, u.full_name AS member_name, e.title AS event_title, e.city, e.event_date, a.name AS association_name
            FROM event_registrations er
            JOIN users u ON u.id = er.member_id
            JOIN events e ON e.id = er.event_id
            JOIN associations a ON a.id = e.association_id
            WHERE er.status = "pending"
            ORDER BY er.id DESC
        ');
        $users = fetchAllSafe('SELECT * FROM users ORDER BY id DESC LIMIT 20');
        $logs = fetchAllSafe('SELECT al.*, u.full_name FROM audit_logs al LEFT JOIN users u ON u.id = al.actor_id ORDER BY al.id DESC LIMIT 12');

        ?>
        <section class="workspace-hero admin-hero reveal">
            <div>
                <span class="eyebrow">Governance cockpit · final approval layer</span>
                <h2>Every public action and participation decision is controlled by admin.</h2>
                <p>Approve associations, missions, events, feedback, applications, event seats, volunteer hours, users and platform activity from one place.</p>
            </div>
            <span class="pill warn"><?= e((string)$stats['pending']) ?> pending</span>
        </section>

        <section class="stat-grid">
            <?php statCard('Pending queue', (string)$stats['pending'], 'All admin-controlled approvals', 'amber'); ?>
            <?php statCard('Members', (string)$stats['members'], 'Active volunteers', 'teal'); ?>
            <?php statCard('Missions', (string)$stats['missions'], 'Approved public missions', 'sky'); ?>
            <?php statCard('Verified hours', number_format((float)$stats['hours'], 1), 'Approved impact', 'violet'); ?>
        </section>

        <?php renderInteractiveInsights('admin', $user); ?>

        <section class="workspace-grid two">
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Approval</span><h3>Associations</h3></div></div>
                <?php moderationTable('association', $pendingAssociations, ['title' => 'name', 'subtitle' => 'description']); ?>
            </article>
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Approval</span><h3>Missions</h3></div></div>
                <?php moderationTable('mission', $pendingMissions, ['title' => 'title', 'subtitle' => 'summary']); ?>
            </article>
        </section>

        <section class="workspace-grid two">
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Approval</span><h3>Events</h3></div></div>
                <?php moderationTable('event', $pendingEvents, ['title' => 'title', 'subtitle' => 'summary']); ?>
            </article>
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Moderation</span><h3>Feedback</h3></div></div>
                <?php moderationTable('feedback', $pendingFeedbacks, ['title' => 'title', 'subtitle' => 'message']); ?>
            </article>
        </section>

        <section class="workspace-grid three">
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Final approval</span><h3>Volunteer applications</h3></div></div>
                <?php adminDecisionTable('application', $pendingApplications); ?>
            </article>
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Final approval</span><h3>Event registrations</h3></div></div>
                <?php adminDecisionTable('event_registration', $pendingEventRegs); ?>
            </article>
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Final validation</span><h3>Volunteer hours</h3></div></div>
                <?php adminDecisionTable('hours', $pendingHours); ?>
            </article>
        </section>

        <section class="workspace-grid two">
            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">People</span><h3>User management</h3></div></div>
                <div class="rich-table">
                    <?php foreach ($users as $u): ?>
                        <div class="table-row with-actions">
                            <div><strong><?= e($u['full_name']) ?></strong><small><?= e($u['email']) ?> · <?= e(statusLabel($u['role'])) ?></small></div>
                            <span class="pill <?= e(statusClass($u['status'])) ?>"><?= e(statusLabel($u['status'])) ?></span>
                            <div class="row-actions">
                                <?php if ($u['status'] !== 'suspended'): ?>
                                    <?php actionForm('admin_status', ['entity' => 'user', 'id' => $u['id'], 'status' => 'suspended'], 'Suspend', 'btn btn-small btn-subtle'); ?>
                                <?php else: ?>
                                    <?php actionForm('admin_status', ['entity' => 'user', 'id' => $u['id'], 'status' => 'active'], 'Activate', 'btn btn-small btn-primary'); ?>
                                <?php endif; ?>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            </article>

            <article class="workspace-panel reveal">
                <div class="panel-heading"><div><span class="eyebrow">Analytics</span><h3>Platform health</h3></div></div>
                <div class="analytics-bars">
                    <div><span>Missions approved</span><strong><?= e((string)$stats['missions']) ?></strong><div class="progress"><span style="width:80%"></span></div></div>
                    <div><span>Events approved</span><strong><?= e((string)$stats['events']) ?></strong><div class="progress"><span style="width:55%"></span></div></div>
                    <div><span>Associations verified</span><strong><?= e((string)$stats['associations']) ?></strong><div class="progress"><span style="width:62%"></span></div></div>
                    <div><span>Volunteer hours</span><strong><?= e(number_format((float)$stats['hours'], 1)) ?></strong><div class="progress"><span style="width:72%"></span></div></div>
                </div>
                <div class="activity-feed">
                    <h4>Audit log</h4>
                    <?php foreach ($logs as $log): ?>
                        <div><span></span><p><strong><?= e($log['action']) ?></strong> on <?= e($log['entity_type']) ?> #<?= e((string)$log['entity_id']) ?><small><?= e($log['full_name'] ?? 'System') ?> · <?= e(safeDate($log['created_at'], 'M j H:i')) ?></small></p></div>
                    <?php endforeach; ?>
                    <?php if (!$logs): ?><p class="muted">No audit activity yet.</p><?php endif; ?>
                </div>
            </article>
        </section>
        <?php
    });
}
