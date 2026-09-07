<?php
declare(strict_types=1);

/**
 * Core bootstrap for Benevolink.
 * Loads the session, configuration, database helpers, common utilities,
 * analytics helpers, reusable UI components, and shell rendering helpers.
 */
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

$config = require dirname(__DIR__) . '/config.php';

function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

/**
 * Minimal error shell for initialization failures.
 * Used when renderShell isn't available yet.
 */
function errorShell(string $title, string $message): void
{
    global $config;
    $appName = $config['app_name'] ?? 'Benevolink';
    ?><!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e($title) ?> · <?= e($appName) ?></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; background: #f5f5f5; display: flex; align-items: center; justify-content: center; min-height: 100vh; padding: 2rem; }
        .error-card { background: white; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); max-width: 600px; padding: 3rem; }
        h1 { color: #dc2626; margin-bottom: 1rem; font-size: 1.5rem; }
        p { color: #666; line-height: 1.6; margin-bottom: 1rem; }
        pre { background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px; padding: 1rem; overflow-x: auto; font-size: 0.875rem; color: #374151; }
    </style>
</head>
<body>
    <div class="error-card">
        <h1><?= e($title) ?></h1>
        <div><?= e($message) ?></div>
    </div>
</body>
</html>
<?php
    exit;
}

/**
 * Get a connected PDO instance for the current request.
 *
 * This function caches the PDO object so the same connection is reused
 * across multiple database operations during one page load.
 */
function db(): PDO
{
    static $pdo = null;
    global $config;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $db = $config['db'];
    $dsn = "mysql:host={$db['host']};port={$db['port']};dbname={$db['name']};charset={$db['charset']}";

    try {
        $pdo = new PDO($dsn, $db['user'], $db['pass'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    } catch (Throwable $e) {
        errorShell('Database connection failed', 'Could not connect to the database. Start MySQL in XAMPP and ensure the database "benevolink" exists, then refresh this page. Error: ' . $e->getMessage());
    }

    return $pdo;
}

/**
 * Determine the requested page name from the URL.
 * Only safe characters are allowed to prevent directory traversal.
 */
function page(): string
{
    return preg_replace('/[^a-zA-Z0-9_\-]/', '', (string)($_GET['page'] ?? 'home')) ?: 'home';
}

/**
 * Build a full application URL for a named page and optional query params.
 */
function appUrl(string $page = 'home', array $params = []): string
{
    global $config;
    return $config['base_url'] . '?' . http_build_query(array_merge(['page' => $page], $params));
}

/**
 * Redirect the browser to a named page and stop execution.
 */
function redirectTo(string $page = 'home', array $params = []): void
{
    header('Location: ' . appUrl($page, $params));
    exit;
}

/**
 * Ensure a CSRF token exists in the session and return it.
 */
function csrf(): string
{
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}

/**
 * Print the hidden CSRF token field used by HTML forms.
 */
function csrfField(): void
{
    echo '<input type="hidden" name="csrf" value="' . e(csrf()) . '">';
}

/**
 * Validate incoming POST requests using the CSRF token.
 * Redirects back to home if the validation fails.
 */
function checkCsrf(): void
{
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        return;
    }
    if (!hash_equals($_SESSION['csrf'] ?? '', (string)($_POST['csrf'] ?? ''))) {
        flash('error', 'Security check failed. Please submit the form again.');
        redirectTo('home');
    }
}

/**
 * Store a flash message in session for display on the next page.
 */
function flash(string $type, string $message): void
{
    $_SESSION['flash'][] = ['type' => $type, 'message' => $message];
}

/**
 * Show any flash messages stored in the session.
 */
function showFlash(): void
{
    $items = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    if (!$items) {
        return;
    }
    echo '<div class="toast-stack" aria-live="polite">';
    foreach ($items as $item) {
        $type = e($item['type'] ?? 'info');
        echo '<article class="toast toast-' . $type . '">';
        echo '<span class="toast-icon"></span>';
        echo '<p>' . e($item['message'] ?? '') . '</p>';
        echo '</article>';
    }
    echo '</div>';
}

function fetchAllSafe(string $sql, array $params = []): array
{
    try {
        $stmt = db()->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    } catch (Throwable) {
        return [];
    }
}

function fetchOneSafe(string $sql, array $params = []): ?array
{
    $rows = fetchAllSafe($sql, $params);
    return $rows[0] ?? null;
}

function scalarSafe(string $sql, array $params = [], mixed $default = 0): mixed
{
    try {
        $stmt = db()->prepare($sql);
        $stmt->execute($params);
        $value = $stmt->fetchColumn();
        return $value === false ? $default : $value;
    } catch (Throwable) {
        return $default;
    }
}

function executeSafe(string $sql, array $params = []): bool
{
    try {
        $stmt = db()->prepare($sql);
        return $stmt->execute($params);
    } catch (Throwable) {
        return false;
    }
}

function tableExists(string $table): bool
{
    static $cache = [];
    if (array_key_exists($table, $cache)) {
        return $cache[$table];
    }
    try {
        $stmt = db()->prepare('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ?');
        $stmt->execute([$table]);
        $cache[$table] = (bool)$stmt->fetchColumn();
    } catch (Throwable) {
        $cache[$table] = false;
    }
    return $cache[$table];
}

function currentUser(): ?array
{
    if (empty($_SESSION['user_id'])) {
        return null;
    }
    return fetchOneSafe('SELECT * FROM users WHERE id = ? LIMIT 1', [(int)$_SESSION['user_id']]);
}

function isLogged(): bool
{
    return currentUser() !== null;
}

function role(): ?string
{
    return currentUser()['role'] ?? null;
}

function requireAuth(?string $role = null): array
{
    $user = currentUser();
    if (!$user) {
        flash('warning', 'Please sign in first.');
        redirectTo('login');
    }
    if ($role !== null && $user['role'] !== $role) {
        flash('error', 'You do not have access to this workspace.');
        redirectTo('home');
    }
    return $user;
}

function initials(string $name): string
{
    $parts = preg_split('/\s+/', trim($name));
    $first = $parts[0][0] ?? 'U';
    $last = $parts[count($parts) - 1][0] ?? '';
    return strtoupper($first . $last);
}

function statusLabel(string $status): string
{
    return [
        'pending' => 'Pending',
        'approved' => 'Approved',
        'rejected' => 'Rejected',
        'accepted' => 'Accepted',
        'active' => 'Active',
        'planned' => 'Planned',
        'completed' => 'Completed',
        'closed' => 'Closed',
        'draft' => 'Draft',
        'canceled' => 'Canceled',
        'suspended' => 'Suspended',
    ][$status] ?? ucfirst($status);
}

function statusClass(?string $status): string
{
    return match ($status) {
        'approved', 'accepted', 'active', 'completed' => 'good',
        'pending', 'planned', 'draft' => 'warn',
        'rejected', 'canceled', 'suspended' => 'bad',
        'closed' => 'neutral',
        default => 'neutral',
    };
}

function safeDate(?string $date, string $format = 'M j, Y'): string
{
    if (!$date) {
        return 'Not scheduled';
    }
    try {
        return (new DateTime($date))->format($format);
    } catch (Throwable) {
        return $date;
    }
}

function daysUntil(?string $date): string
{
    if (!$date) {
        return 'Flexible';
    }
    try {
        $today = new DateTime('today');
        $target = new DateTime($date);
        $diff = (int)$today->diff($target)->format('%r%a');
        if ($diff === 0) {
            return 'Today';
        }
        if ($diff === 1) {
            return 'Tomorrow';
        }
        if ($diff > 1) {
            return $diff . ' days';
        }
        return 'Started';
    } catch (Throwable) {
        return 'Scheduled';
    }
}

function appStats(): array
{
    return [
        'missions' => (int)scalarSafe("SELECT COUNT(*) FROM missions WHERE status = 'approved'", [], 0),
        'events' => (int)scalarSafe("SELECT COUNT(*) FROM events WHERE status = 'approved'", [], 0),
        'members' => (int)scalarSafe("SELECT COUNT(*) FROM users WHERE role = 'member' AND status = 'active'", [], 0),
        'hours' => (float)scalarSafe("SELECT COALESCE(SUM(hours),0) FROM volunteer_hours WHERE status = 'approved'", [], 0),
        'associations' => (int)scalarSafe("SELECT COUNT(*) FROM associations WHERE status = 'approved'", [], 0),
        'pending' => (int)scalarSafe("SELECT 
            (SELECT COUNT(*) FROM associations WHERE status = 'pending') +
            (SELECT COUNT(*) FROM missions WHERE status = 'pending') +
            (SELECT COUNT(*) FROM events WHERE status = 'pending') +
            (SELECT COUNT(*) FROM feedbacks WHERE status = 'pending') +
            (SELECT COUNT(*) FROM applications WHERE status = 'pending') +
            (SELECT COUNT(*) FROM event_registrations WHERE status = 'pending') +
            (SELECT COUNT(*) FROM volunteer_hours WHERE status = 'pending')", [], 0),
    ];
}

function approvedMissions(int $limit = 12, array $filters = []): array
{
    $where = ["m.status = 'approved'"];
    $params = [];

    if (!empty($filters['q'])) {
        $where[] = "(m.title LIKE ? OR m.summary LIKE ? OR m.description LIKE ? OR a.name LIKE ?)";
        $q = '%' . $filters['q'] . '%';
        array_push($params, $q, $q, $q, $q);
    }
    if (!empty($filters['city'])) {
        $where[] = 'm.city = ?';
        $params[] = $filters['city'];
    }
    if (!empty($filters['category'])) {
        $where[] = 'm.category = ?';
        $params[] = $filters['category'];
    }
    if (!empty($filters['association'])) {
        $where[] = 'a.id = ?';
        $params[] = (int)$filters['association'];
    }

    $limitSql = max(1, min(48, $limit));
    return fetchAllSafe("
        SELECT m.*, a.name AS association_name, a.category AS association_category,
               COALESCE(COUNT(CASE WHEN ap.status = 'accepted' THEN 1 END), 0) AS accepted_count
        FROM missions m
        JOIN associations a ON a.id = m.association_id
        LEFT JOIN applications ap ON ap.mission_id = m.id
        WHERE " . implode(' AND ', $where) . "
        GROUP BY m.id
        ORDER BY m.start_date ASC, m.id DESC
        LIMIT {$limitSql}
    ", $params);
}

function oneMission(int $id): ?array
{
    return fetchOneSafe("
        SELECT m.*, a.name AS association_name, a.description AS association_description, a.category AS association_category,
               a.city AS association_city, a.website AS association_website, a.email AS association_email,
               COALESCE(COUNT(CASE WHEN ap.status = 'accepted' THEN 1 END), 0) AS accepted_count
        FROM missions m
        JOIN associations a ON a.id = m.association_id
        LEFT JOIN applications ap ON ap.mission_id = m.id
        WHERE m.id = ?
        GROUP BY m.id
        LIMIT 1
    ", [$id]);
}

function approvedEvents(int $limit = 12): array
{
    $limitSql = max(1, min(48, $limit));
    return fetchAllSafe("
        SELECT e.*, a.name AS association_name,
               COALESCE(COUNT(CASE WHEN er.status = 'accepted' THEN 1 END), 0) AS accepted_count
        FROM events e
        JOIN associations a ON a.id = e.association_id
        LEFT JOIN event_registrations er ON er.event_id = e.id
        WHERE e.status = 'approved'
        GROUP BY e.id
        ORDER BY e.event_date ASC, e.id DESC
        LIMIT {$limitSql}
    ");
}

function oneEvent(int $id): ?array
{
    return fetchOneSafe("
        SELECT e.*, a.name AS association_name, a.description AS association_description,
               COALESCE(COUNT(CASE WHEN er.status = 'accepted' THEN 1 END), 0) AS accepted_count
        FROM events e
        JOIN associations a ON a.id = e.association_id
        LEFT JOIN event_registrations er ON er.event_id = e.id
        WHERE e.id = ?
        GROUP BY e.id
        LIMIT 1
    ", [$id]);
}

function approvedAssociations(int $limit = 12): array
{
    $limitSql = max(1, min(48, $limit));
    return fetchAllSafe("
        SELECT a.*,
               u.full_name AS owner_name,
               COUNT(DISTINCT m.id) AS mission_count,
               COUNT(DISTINCT e.id) AS event_count
        FROM associations a
        JOIN users u ON u.id = a.owner_id
        LEFT JOIN missions m ON m.association_id = a.id AND m.status = 'approved'
        LEFT JOIN events e ON e.association_id = a.id AND e.status = 'approved'
        WHERE a.status = 'approved'
        GROUP BY a.id
        ORDER BY mission_count DESC, a.name
        LIMIT {$limitSql}
    ");
}

function approvedFeedbacks(int $limit = 6): array
{
    $limitSql = max(1, min(24, $limit));
    return fetchAllSafe("SELECT * FROM feedbacks WHERE status = 'approved' ORDER BY rating DESC, id DESC LIMIT {$limitSql}");
}

function lookupOptions(): array
{
    return [
        'cities' => fetchAllSafe("SELECT DISTINCT city FROM missions WHERE status = 'approved' ORDER BY city"),
        'categories' => fetchAllSafe("SELECT DISTINCT category FROM missions WHERE status = 'approved' ORDER BY category"),
        'associations' => approvedAssociations(100),
    ];
}

function ownerAssociation(int $ownerId): ?array
{
    return fetchOneSafe('SELECT * FROM associations WHERE owner_id = ? ORDER BY id LIMIT 1', [$ownerId]);
}

function notifyUser(int $userId, string $title, string $body, string $type = 'info'): void
{
    executeSafe('INSERT INTO notifications (user_id, title, body, type) VALUES (?, ?, ?, ?)', [$userId, $title, $body, $type]);
}

function notifyAdmins(string $title, string $body, string $type = 'approval'): void
{
    $admins = fetchAllSafe('SELECT id FROM users WHERE role = "admin" AND status = "active"');
    foreach ($admins as $admin) {
        notifyUser((int)$admin['id'], $title, $body, $type);
    }
}

function createApprovalRequest(
    string $type,
    int $entityId,
    string $title,
    string $details = '',
    ?int $requesterId = null,
    ?int $ownerId = null,
    ?int $memberId = null
): void {
    if (!tableExists('approval_requests')) {
        return;
    }

    executeSafe(
        'INSERT INTO approval_requests
            (request_type, entity_id, requester_id, owner_id, member_id, title, details, status)
         VALUES (?, ?, ?, ?, ?, ?, ?, "pending")
         ON DUPLICATE KEY UPDATE
            requester_id = VALUES(requester_id),
            owner_id = VALUES(owner_id),
            member_id = VALUES(member_id),
            title = VALUES(title),
            details = VALUES(details),
            status = "pending",
            decided_by = NULL,
            decided_at = NULL',
        [
            mb_substr($type, 0, 50),
            $entityId,
            $requesterId,
            $ownerId,
            $memberId,
            mb_substr($title, 0, 180),
            mb_substr($details, 0, 500),
        ]
    );
}

function resolveApprovalRequest(string $type, int $entityId, string $status, int $adminId): void
{
    if (!tableExists('approval_requests')) {
        return;
    }

    executeSafe(
        'UPDATE approval_requests
         SET status = ?, decided_by = ?, decided_at = NOW()
         WHERE request_type = ? AND entity_id = ?',
        [$status, $adminId, mb_substr($type, 0, 50), $entityId]
    );
}

function audit(?int $actorId, string $action, string $entity, ?int $entityId, string $details = ''): void
{
    executeSafe('INSERT INTO audit_logs (actor_id, action, entity_type, entity_id, details) VALUES (?, ?, ?, ?, ?)', [
        $actorId, $action, $entity, $entityId, mb_substr($details, 0, 250)
    ]);
}


function trackEvent(string $event, ?string $entityType = null, ?int $entityId = null, array $meta = []): void
{
    if (!tableExists('feature_events')) {
        return;
    }

    $user = currentUser();
    $sessionId = session_id() ?: null;
    $page = page();
    $payload = json_encode($meta, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    $ip = $_SERVER['REMOTE_ADDR'] ?? null;
    $ua = $_SERVER['HTTP_USER_AGENT'] ?? null;

    executeSafe(
        'INSERT INTO feature_events (actor_id, session_id, event_name, entity_type, entity_id, page, metadata_json, ip_address, user_agent)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
            $user['id'] ?? null,
            $sessionId,
            mb_substr($event, 0, 80),
            $entityType,
            $entityId,
            $page,
            $payload,
            $ip,
            $ua ? mb_substr($ua, 0, 250) : null,
        ]
    );
}

function savePreference(int $userId, string $key, string $value): void
{
    if (!tableExists('user_preferences')) {
        return;
    }

    executeSafe(
        'INSERT INTO user_preferences (user_id, preference_key, preference_value)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE preference_value = VALUES(preference_value), updated_at = CURRENT_TIMESTAMP',
        [$userId, $key, $value]
    );
}

function jsonAttr(array $value): string
{
    return e(json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
}

function chartBlock(string $title, string $subtitle, string $type, array $data, string $tone = 'teal'): void
{
    $total = 0;
    foreach ($data as $item) {
        $total += (float)($item['value'] ?? 0);
    }
    $totalLabel = $total >= 1000 ? number_format($total) : rtrim(rtrim(number_format($total, 1), '0'), '.');

    echo '<article class="chart-card tone-' . e($tone) . ' reveal" data-chart="' . e($type) . '" data-chart-values="' . jsonAttr($data) . '">';
    echo '<div class="chart-head">';
    echo '<div><span class="eyebrow">' . e($subtitle) . '</span><h3>' . e($title) . '</h3></div>';
    echo '<div class="chart-head-actions"><span class="chart-total">' . e($totalLabel) . '</span><button class="mini-action" type="button" data-refresh-chart aria-label="Refresh chart">↻</button></div>';
    echo '</div>';
    echo '<div class="chart-canvas" aria-label="' . e($title) . ' chart"></div>';
    echo '</article>';
}

function renderUsageTimeline(?int $actorId = null, int $limit = 8): void
{
    if (!tableExists('feature_events')) {
        echo '<div class="empty-state"><strong>Analytics tables not installed.</strong><p>Import database_update.sql to activate usage tracking.</p></div>';
        return;
    }

    $sql = 'SELECT fe.*, u.full_name FROM feature_events fe LEFT JOIN users u ON u.id = fe.actor_id';
    $params = [];
    if ($actorId !== null) {
        $sql .= ' WHERE fe.actor_id = ?';
        $params[] = $actorId;
    }
    $sql .= ' ORDER BY fe.id DESC LIMIT ' . max(1, $limit);

    $events = fetchAllSafe($sql, $params);
    echo '<div class="usage-timeline">';
    foreach ($events as $event) {
        echo '<div class="usage-item">';
        echo '<span class="usage-dot"></span>';
        echo '<div>';
        echo '<strong>' . e(str_replace('_', ' ', $event['event_name'])) . '</strong>';
        echo '<small>' . e($event['full_name'] ?? 'Guest') . ' · ' . e($event['page'] ?? 'app') . ' · ' . e(safeDate($event['created_at'], 'M j H:i')) . '</small>';
        if (!empty($event['metadata_json'])) {
            $decoded = json_decode((string)$event['metadata_json'], true);
            if (is_array($decoded) && $decoded) {
                $preview = mb_substr(implode(' · ', array_map(fn($k, $v) => $k . ': ' . (is_scalar($v) ? $v : json_encode($v)), array_keys($decoded), $decoded)), 0, 120);
                echo '<em>' . e($preview) . '</em>';
            }
        }
        echo '</div>';
        echo '</div>';
    }
    if (!$events) {
        echo '<div class="empty-state"><strong>No usage captured yet.</strong><p>Navigate, search, apply, save, or approve items to populate this stream.</p></div>';
    }
    echo '</div>';
}

function renderInteractiveInsights(string $mode, array $user): void
{
    if (!tableExists('feature_events')) {
        ?>
        <section class="dash-suite reveal">
            <article class="dash-spotlight">
                <span class="eyebrow">Database analytics</span>
                <h3>Interactive dashboards are ready, but the tracking tables are missing.</h3>
                <p>Import the dashboard update SQL once. After that, searches, saves, submissions, approvals, views and exports are stored in the database and shown here.</p>
            </article>
        </section>
        <?php
        return;
    }

    if ($mode === 'member') {
        $approvedHours = (float)scalarSafe('SELECT COALESCE(SUM(hours),0) FROM volunteer_hours WHERE member_id = ? AND status = "approved"', [$user['id']], 0);
        $pendingHours = (float)scalarSafe('SELECT COALESCE(SUM(hours),0) FROM volunteer_hours WHERE member_id = ? AND status = "pending"', [$user['id']], 0);
        $acceptedApps = (int)scalarSafe('SELECT COUNT(*) FROM applications WHERE member_id = ? AND status = "accepted"', [$user['id']], 0);
        $savedCount = tableExists('saved_missions') ? (int)scalarSafe('SELECT COUNT(*) FROM saved_missions WHERE user_id = ?', [$user['id']], 0) : 0;

        $hoursByMonth = fetchAllSafe('
            SELECT DATE_FORMAT(work_date, "%b") AS label, COALESCE(SUM(hours),0) AS value
            FROM volunteer_hours
            WHERE member_id = ? AND status = "approved"
            GROUP BY YEAR(work_date), MONTH(work_date), DATE_FORMAT(work_date, "%b")
            ORDER BY MIN(work_date)
            LIMIT 6
        ', [$user['id']]);

        $appStatus = fetchAllSafe('
            SELECT status AS label, COUNT(*) AS value
            FROM applications
            WHERE member_id = ?
            GROUP BY status
        ', [$user['id']]);

        $eventStatus = fetchAllSafe('
            SELECT status AS label, COUNT(*) AS value
            FROM event_registrations
            WHERE member_id = ?
            GROUP BY status
        ', [$user['id']]);

        $saved = tableExists('saved_missions')
            ? fetchAllSafe('
                SELECT sm.*, m.title, m.city, m.category, m.start_date
                FROM saved_missions sm
                JOIN missions m ON m.id = sm.mission_id
                WHERE sm.user_id = ?
                ORDER BY sm.created_at DESC
                LIMIT 5
            ', [$user['id']])
            : [];

        $skills = tableExists('member_skills')
            ? fetchAllSafe('SELECT * FROM member_skills WHERE user_id = ? ORDER BY FIELD(level, "advanced", "intermediate", "beginner"), skill LIMIT 8', [$user['id']])
            : [];

        $level = min(100, (int)round(($approvedHours / 60) * 100));
        ?>
        <section class="dash-suite member-suite reveal">
            <article class="dash-spotlight">
                <div class="dash-copy">
                    <span class="eyebrow">Personal impact cockpit</span>
                    <h3>Turn every accepted mission into visible progress.</h3>
                    <p>Your applications, saved missions, hours and skills are connected to the database so the dashboard becomes a real volunteer profile.</p>
                    <div class="dash-actions">
                        <button type="button" class="btn btn-primary" data-scroll-target="#hours-form" data-track-click="member_jump_hours">Submit hours</button>
                        <a class="btn btn-subtle" href="<?= e(appUrl('missions')) ?>" data-track-click="member_discover_missions">Find missions</a>
                    </div>
                </div>
                <div class="impact-ring" style="--value:<?= e((string)$level) ?>">
                    <span><?= e((string)$level) ?>%</span>
                    <small>Impact level</small>
                </div>
            </article>

            <div class="dash-mini-grid">
                <article><span>Verified hours</span><strong><?= e(number_format($approvedHours, 1)) ?></strong><small>approved by admin</small></article>
                <article><span>Pending hours</span><strong><?= e(number_format($pendingHours, 1)) ?></strong><small>awaiting validation</small></article>
                <article><span>Accepted missions</span><strong><?= e((string)$acceptedApps) ?></strong><small>confirmed work</small></article>
                <article><span>Saved missions</span><strong><?= e((string)$savedCount) ?></strong><small>personal shortlist</small></article>
            </div>

            <div class="dash-chart-grid">
                <?php chartBlock('Verified hours trend', 'Approved work', 'bars', $hoursByMonth ?: [['label' => 'No data', 'value' => 0]], 'teal'); ?>
                <?php chartBlock('Applications pipeline', 'Status split', 'donut', $appStatus ?: [['label' => 'No data', 'value' => 1]], 'sky'); ?>
                <?php chartBlock('Event requests', 'Seat requests', 'donut', $eventStatus ?: [['label' => 'No data', 'value' => 1]], 'amber'); ?>
            </div>

            <div class="dash-board-grid">
                <article class="dash-panel">
                    <div class="panel-heading"><div><span class="eyebrow">Shortlist</span><h3>Saved missions</h3></div></div>
                    <div class="smart-list">
                        <?php foreach ($saved as $m): ?>
                            <a class="smart-row" href="<?= e(appUrl('mission', ['id' => $m['mission_id']])) ?>">
                                <span class="smart-icon">★</span>
                                <div><strong><?= e($m['title']) ?></strong><small><?= e($m['category']) ?> · <?= e($m['city']) ?> · <?= e(safeDate($m['start_date'])) ?></small></div>
                                <span class="row-arrow">→</span>
                            </a>
                        <?php endforeach; ?>
                        <?php if (!$saved): ?><div class="empty-state compact"><strong>No saved missions.</strong><p>Open a mission and save it to build your shortlist.</p></div><?php endif; ?>
                    </div>
                </article>

                <article class="dash-panel">
                    <div class="panel-heading"><div><span class="eyebrow">Profile strength</span><h3>Skills</h3></div></div>
                    <div class="skill-cloud">
                        <?php foreach ($skills as $skill): ?>
                            <span class="skill-pill"><?= e($skill['skill']) ?><small><?= e($skill['level']) ?></small></span>
                        <?php endforeach; ?>
                        <?php if (!$skills): ?><div class="empty-state compact"><strong>No skills saved.</strong><p>Add skills from your dashboard form to improve matching.</p></div><?php endif; ?>
                    </div>
                </article>

                <article class="dash-panel wide">
                    <div class="panel-heading"><div><span class="eyebrow">Live trail</span><h3>Your latest database activity</h3></div></div>
                    <?php renderUsageTimeline((int)$user['id'], 8); ?>
                </article>
            </div>
        </section>
        <?php
        return;
    }

    if ($mode === 'owner') {
        $assoc = ownerAssociation((int)$user['id']);
        $missionPerformance = fetchAllSafe('
            SELECT m.title AS label, COUNT(ap.id) AS value
            FROM missions m
            LEFT JOIN applications ap ON ap.mission_id = m.id
            WHERE m.owner_id = ?
            GROUP BY m.id, m.title
            ORDER BY value DESC
            LIMIT 6
        ', [$user['id']]);

        $appStatus = fetchAllSafe('
            SELECT ap.status AS label, COUNT(*) AS value
            FROM applications ap
            JOIN missions m ON m.id = ap.mission_id
            WHERE m.owner_id = ?
            GROUP BY ap.status
        ', [$user['id']]);

        $hourStatus = fetchAllSafe('
            SELECT vh.status AS label, COUNT(*) AS value
            FROM volunteer_hours vh
            JOIN missions m ON m.id = vh.mission_id
            WHERE m.owner_id = ?
            GROUP BY vh.status
        ', [$user['id']]);

        $eventStatus = fetchAllSafe('
            SELECT er.status AS label, COUNT(*) AS value
            FROM event_registrations er
            JOIN events e ON e.id = er.event_id
            WHERE e.owner_id = ?
            GROUP BY er.status
        ', [$user['id']]);

        $pendingApplications = (int)scalarSafe('
            SELECT COUNT(*) FROM applications ap
            JOIN missions m ON m.id = ap.mission_id
            WHERE m.owner_id = ? AND ap.status = "pending"
        ', [$user['id']], 0);
        $pendingHours = (int)scalarSafe('
            SELECT COUNT(*) FROM volunteer_hours vh
            JOIN missions m ON m.id = vh.mission_id
            WHERE m.owner_id = ? AND vh.status = "pending"
        ', [$user['id']], 0);
        $pendingEvents = (int)scalarSafe('
            SELECT COUNT(*) FROM event_registrations er
            JOIN events e ON e.id = er.event_id
            WHERE e.owner_id = ? AND er.status = "pending"
        ', [$user['id']], 0);
        $newMessages = tableExists('association_messages') && $assoc
            ? (int)scalarSafe('SELECT COUNT(*) FROM association_messages WHERE association_id = ? AND status = "new"', [$assoc['id']], 0)
            : 0;

        $messages = tableExists('association_messages') && $assoc
            ? fetchAllSafe('SELECT * FROM association_messages WHERE association_id = ? ORDER BY id DESC LIMIT 5', [$assoc['id']])
            : [];
        ?>
        <section class="dash-suite owner-suite reveal">
            <article class="dash-spotlight">
                <div class="dash-copy">
                    <span class="eyebrow">Association operations board</span>
                    <h3><?= e($assoc['name'] ?? 'Association workspace') ?> has a controlled approval pipeline.</h3>
                    <p>Owners prepare missions, events and review context. The admin keeps the final decision layer clean and auditable.</p>
                    <div class="dash-actions">
                        <button type="button" class="btn btn-primary" data-panel-open="create-mission" data-track-click="owner_open_mission_form">Create mission</button>
                        <button type="button" class="btn btn-subtle" data-panel-open="create-event" data-track-click="owner_open_event_form">Create event</button>
                    </div>
                </div>
                <div class="ops-stack">
                    <article><strong><?= e((string)$pendingApplications) ?></strong><span>Applications waiting</span></article>
                    <article><strong><?= e((string)$pendingHours) ?></strong><span>Hours waiting</span></article>
                    <article><strong><?= e((string)$newMessages) ?></strong><span>New messages</span></article>
                </div>
            </article>

            <div class="dash-mini-grid">
                <article><span>Applications</span><strong><?= e((string)$pendingApplications) ?></strong><small>pending admin decision</small></article>
                <article><span>Hours</span><strong><?= e((string)$pendingHours) ?></strong><small>pending validation</small></article>
                <article><span>Event seats</span><strong><?= e((string)$pendingEvents) ?></strong><small>pending approval</small></article>
                <article><span>Messages</span><strong><?= e((string)$newMessages) ?></strong><small>unread inbox</small></article>
            </div>

            <div class="dash-chart-grid">
                <?php chartBlock('Mission demand', 'Applications by mission', 'bars', $missionPerformance ?: [['label' => 'No data', 'value' => 0]], 'teal'); ?>
                <?php chartBlock('Application pipeline', 'Admin-governed', 'donut', $appStatus ?: [['label' => 'No data', 'value' => 1]], 'sky'); ?>
                <?php chartBlock('Hour validation', 'Quality control', 'donut', $hourStatus ?: [['label' => 'No data', 'value' => 1]], 'amber'); ?>
                <?php chartBlock('Event registrations', 'Seat workflow', 'donut', $eventStatus ?: [['label' => 'No data', 'value' => 1]], 'violet'); ?>
            </div>

            <div class="dash-board-grid">
                <article class="dash-panel">
                    <div class="panel-heading"><div><span class="eyebrow">Inbox</span><h3>Association messages</h3></div></div>
                    <div class="smart-list">
                        <?php foreach ($messages as $msg): ?>
                            <div class="smart-row">
                                <span class="smart-icon">✉</span>
                                <div><strong><?= e($msg['sender_name']) ?></strong><small><?= e(mb_substr($msg['message'], 0, 90)) ?><?= mb_strlen($msg['message']) > 90 ? '…' : '' ?></small></div>
                            </div>
                        <?php endforeach; ?>
                        <?php if (!$messages): ?><div class="empty-state compact"><strong>No messages yet.</strong><p>Public association contact messages will appear here.</p></div><?php endif; ?>
                    </div>
                </article>

                <article class="dash-panel wide">
                    <div class="panel-heading"><div><span class="eyebrow">Audit trail</span><h3>Owner activity stored in database</h3></div></div>
                    <?php renderUsageTimeline((int)$user['id'], 10); ?>
                </article>
            </div>
        </section>
        <?php
        return;
    }

    $featureUsage = fetchAllSafe('
        SELECT event_name AS label, COUNT(*) AS value
        FROM feature_events
        GROUP BY event_name
        ORDER BY value DESC
        LIMIT 8
    ');
    $dailyUsage = fetchAllSafe('
        SELECT DATE_FORMAT(created_at, "%b %d") AS label, COUNT(*) AS value
        FROM feature_events
        WHERE created_at >= DATE_SUB(NOW(), INTERVAL 14 DAY)
        GROUP BY DATE(created_at), DATE_FORMAT(created_at, "%b %d")
        ORDER BY DATE(created_at)
    ');
    $topPages = fetchAllSafe('
        SELECT COALESCE(NULLIF(page, ""), "unknown") AS label, COUNT(*) AS value
        FROM feature_events
        GROUP BY COALESCE(NULLIF(page, ""), "unknown")
        ORDER BY value DESC
        LIMIT 8
    ');
    $moderation = tableExists('approval_requests') ? fetchAllSafe('
        SELECT request_type AS label, COUNT(*) AS value
        FROM approval_requests
        WHERE status = "pending"
        GROUP BY request_type
        ORDER BY value DESC
    ') : [];

    $recentAdmin = fetchAllSafe('
        SELECT fe.*, u.full_name
        FROM feature_events fe
        LEFT JOIN users u ON u.id = fe.actor_id
        WHERE fe.event_name LIKE "admin_%" OR fe.event_name IN ("dashboard_refresh", "activity_exported")
        ORDER BY fe.id DESC
        LIMIT 8
    ');

    $totalEvents = (int)scalarSafe('SELECT COUNT(*) FROM feature_events', [], 0);
    $activeUsers = (int)scalarSafe('SELECT COUNT(DISTINCT actor_id) FROM feature_events WHERE actor_id IS NOT NULL AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)', [], 0);
    $todayEvents = (int)scalarSafe('SELECT COUNT(*) FROM feature_events WHERE DATE(created_at) = CURDATE()', [], 0);
    $pendingApprovals = tableExists('approval_requests') ? (int)scalarSafe('SELECT COUNT(*) FROM approval_requests WHERE status = "pending"', [], 0) : 0;
    ?>
    <section class="dash-suite admin-suite reveal">
        <article class="dash-spotlight">
            <div class="dash-copy">
                <span class="eyebrow">Admin intelligence center</span>
                <h3>One clean cockpit for approvals, usage and platform health.</h3>
                <p>The dashboard is connected to the database: every refresh, click, search, approval, application and hour validation leaves a measurable trace.</p>
                <div class="dash-actions">
                    <button type="button" class="btn btn-primary" data-export-table="usage" data-track-click="admin_export_activity">Export activity</button>
                    <button type="button" class="btn btn-subtle" data-refresh-chart data-track-click="admin_refresh_dashboard">Refresh dashboard</button>
                </div>
            </div>
            <div class="approval-meter">
                <span>Pending approval load</span>
                <strong><?= e((string)$pendingApprovals) ?></strong>
                <div class="progress"><span style="width:<?= e((string)min(100, $pendingApprovals * 8)) ?>%"></span></div>
                <small>Admin remains the final decision owner</small>
            </div>
        </article>

        <div class="dash-mini-grid">
            <article><span>Total events</span><strong><?= e((string)$totalEvents) ?></strong><small>stored interactions</small></article>
            <article><span>Today</span><strong><?= e((string)$todayEvents) ?></strong><small>fresh activity</small></article>
            <article><span>Active users</span><strong><?= e((string)$activeUsers) ?></strong><small>last 7 days</small></article>
            <article><span>Pending</span><strong><?= e((string)$pendingApprovals) ?></strong><small>approval requests</small></article>
        </div>

        <div class="dash-chart-grid admin-charts">
            <?php chartBlock('Usage over time', 'Last 14 days', 'bars', $dailyUsage ?: [['label' => 'No data', 'value' => 0]], 'teal'); ?>
            <?php chartBlock('Feature adoption', 'Most used actions', 'donut', $featureUsage ?: [['label' => 'No data', 'value' => 1]], 'violet'); ?>
            <?php chartBlock('Navigation signal', 'Top pages', 'bars', $topPages ?: [['label' => 'No data', 'value' => 0]], 'sky'); ?>
            <?php chartBlock('Approval queue', 'Pending by type', 'donut', $moderation ?: [['label' => 'No pending', 'value' => 1]], 'amber'); ?>
        </div>

        <div class="dash-board-grid">
            <article class="dash-panel">
                <div class="panel-heading"><div><span class="eyebrow">Moderation focus</span><h3>What needs admin attention</h3></div></div>
                <div class="smart-list">
                    <?php foreach ($moderation as $row): ?>
                        <?php $width = min(100, ((int)$row['value']) * 12); ?>
                        <div class="queue-row">
                            <div><strong><?= e(str_replace('_', ' ', $row['label'])) ?></strong><small><?= e((string)$row['value']) ?> pending</small></div>
                            <div class="micro-progress"><span style="width:<?= e((string)$width) ?>%"></span></div>
                        </div>
                    <?php endforeach; ?>
                    <?php if (!$moderation): ?><div class="empty-state compact"><strong>Queue is clean.</strong><p>No pending approval requests right now.</p></div><?php endif; ?>
                </div>
            </article>

            <article class="dash-panel">
                <div class="panel-heading"><div><span class="eyebrow">Admin actions</span><h3>Recent decisions</h3></div></div>
                <div class="smart-list">
                    <?php foreach ($recentAdmin as $event): ?>
                        <div class="smart-row">
                            <span class="smart-icon">✓</span>
                            <div><strong><?= e(str_replace('_', ' ', $event['event_name'])) ?></strong><small><?= e($event['full_name'] ?? 'System') ?> · <?= e($event['page'] ?? 'dashboard') ?> · <?= e(safeDate($event['created_at'], 'M j H:i')) ?></small></div>
                        </div>
                    <?php endforeach; ?>
                    <?php if (!$recentAdmin): ?><div class="empty-state compact"><strong>No admin decisions yet.</strong><p>Approve or reject items to fill this panel.</p></div><?php endif; ?>
                </div>
            </article>

            <article class="dash-panel wide" id="usage">
                <div class="panel-heading"><div><span class="eyebrow">Database activity stream</span><h3>Live product events</h3></div></div>
                <?php renderUsageTimeline(null, 14); ?>
            </article>
        </div>
    </section>
    <?php
}

