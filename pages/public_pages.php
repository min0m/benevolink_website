<?php
/**
 * Public-facing pages.
 * Home, missions, mission detail, events, event detail, associations,
 * feedback, registration, and login pages.
 */
function renderHome(): void
{
    $stats = appStats();
    $missions = approvedMissions(6);
    $events = approvedEvents(4);
    $associations = approvedAssociations(6);
    $feedbacks = approvedFeedbacks(3);

    renderShell('Volunteer management platform', function () use ($stats, $missions, $events, $associations, $feedbacks) {
        ?>
        <section class="hero-section">
            <div class="container hero-grid">
                <div class="hero-copy reveal">
                    <span class="eyebrow">Social impact operations · missions · events · hours</span>
                    <h1>Coordinate volunteers with clarity, warmth, and trust.</h1>
                    <p class="hero-lead">Benevolink helps associations publish meaningful missions, review applications, validate participation, track volunteer hours, and show real community impact.</p>
                    <div class="hero-actions">
                        <a class="btn btn-primary btn-large" href="<?= e(appUrl('missions')) ?>">Explore missions</a>
                        <a class="btn btn-secondary btn-large" href="<?= e(appUrl('join')) ?>#owner">Register association</a>
                    </div>
                    <div class="hero-trust">
                        <span>✓ Admin-approved content</span>
                        <span>✓ Owner review workflow</span>
                        <span>✓ Member impact tracking</span>
                    </div>
                </div>

                <div class="hero-product reveal">
                    <div class="product-window">
                        <div class="window-bar"><span></span><span></span><span></span><strong>Impact cockpit</strong></div>
                        <div class="product-metrics">
                            <div><span>Missions</span><strong><?= e($stats['missions']) ?></strong></div>
                            <div><span>Members</span><strong><?= e($stats['members']) ?></strong></div>
                            <div><span>Hours</span><strong><?= e(number_format((float)$stats['hours'], 0)) ?></strong></div>
                        </div>
                        <div class="product-row">
                            <div class="pulse-dot"></div>
                            <div>
                                <strong>Applications queue</strong>
                                <small>Owners review volunteers before confirmation.</small>
                            </div>
                            <span class="pill warn"><?= e((string)$stats['pending']) ?> pending</span>
                        </div>
                        <div class="mini-board">
                            <span style="height:72%"></span>
                            <span style="height:48%"></span>
                            <span style="height:86%"></span>
                            <span style="height:58%"></span>
                            <span style="height:92%"></span>
                        </div>
                        <div class="product-row">
                            <div class="avatar-stack"><b>YM</b><b>AG</b><b>MS</b></div>
                            <div><strong>Volunteer impact verified</strong><small>Hours are validated by owner or admin.</small></div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="container proof-strip reveal">
            <div><strong><?= e((string)$stats['missions']) ?></strong><span>approved missions</span></div>
            <div><strong><?= e((string)$stats['events']) ?></strong><span>community events</span></div>
            <div><strong><?= e((string)$stats['associations']) ?></strong><span>verified associations</span></div>
            <div><strong><?= e(number_format((float)$stats['hours'], 1)) ?></strong><span>validated hours</span></div>
        </section>

        <section class="container section">
            <?php sectionHeader('Featured opportunities', 'Missions that need people now', 'Browse approved opportunities with clear dates, capacity, and association ownership.', appUrl('missions'), 'View all missions'); ?>
            <div class="mission-grid">
                <?php foreach ($missions as $m) { missionCard($m); } ?>
                <?php if (!$missions): ?>
                    <div class="empty-state"><strong>No approved missions yet.</strong><p>Admin-approved missions will appear here.</p></div>
                <?php endif; ?>
            </div>
        </section>

        <section class="container section split-section">
            <div class="panel reveal">
                <span class="eyebrow">How it works</span>
                <h2>A clean flow from discovery to verified impact.</h2>
                <div class="steps">
                    <div><span>01</span><strong>Discover</strong><p>Members browse public missions and events by city, category, association and date.</p></div>
                    <div><span>02</span><strong>Apply</strong><p>Applications and event registrations enter an owner/admin review queue.</p></div>
                    <div><span>03</span><strong>Validate</strong><p>Approved participations unlock hour submission and verification.</p></div>
                    <div><span>04</span><strong>Report</strong><p>Dashboards convert activity into readable impact metrics.</p></div>
                </div>
            </div>
            <div class="panel panel-accent reveal">
                <span class="eyebrow">For associations</span>
                <h2>Operate missions without spreadsheet chaos.</h2>
                <p>Create missions, review candidates, manage events, validate volunteer hours, and keep every decision traceable.</p>
                <a class="btn btn-primary" href="<?= e(appUrl('join')) ?>#owner">Start owner onboarding</a>
            </div>
        </section>

        <section class="container section">
            <?php sectionHeader('Upcoming events', 'Community moments that bring people together', 'Approved events remain public while registrations stay controlled by owners.', appUrl('events'), 'Browse events'); ?>
            <div class="event-grid">
                <?php foreach ($events as $event) { eventCard($event); } ?>
                <?php if (!$events): ?>
                    <div class="empty-state"><strong>No events available.</strong><p>Approved events will appear here.</p></div>
                <?php endif; ?>
            </div>
        </section>

        <section class="container section">
            <?php sectionHeader('Verified associations', 'Trusted organizations on the platform', 'Every association must be reviewed before publishing public opportunities.', appUrl('associations'), 'See associations'); ?>
            <div class="association-grid">
                <?php foreach ($associations as $a): ?>
                    <article class="association-card reveal">
                        <div class="org-badge"><?= e(initials($a['name'])) ?></div>
                        <span class="tag tag-sky"><?= e($a['category']) ?></span>
                        <h3><?= e($a['name']) ?></h3>
                        <p><?= e($a['mission_statement'] ?: mb_substr($a['description'], 0, 150)) ?></p>
                        <div class="card-bottom">
                            <span>📍 <?= e($a['city']) ?></span>
                            <span><?= e((string)$a['mission_count']) ?> missions</span>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        </section>

        <section class="container section testimonial-section">
            <?php sectionHeader('Community proof', 'Real stories, moderated for trust', 'Anyone can submit feedback. Admin approval keeps public stories clean and credible.', appUrl('feedback'), 'Leave feedback'); ?>
            <div class="testimonial-grid">
                <?php foreach ($feedbacks as $f): ?>
                    <article class="quote-card reveal">
                        <div class="stars"><?= str_repeat('★', (int)$f['rating']) ?></div>
                        <h3><?= e($f['title']) ?></h3>
                        <p>“<?= e($f['message']) ?>”</p>
                        <strong><?= e($f['author_name']) ?></strong>
                    </article>
                <?php endforeach; ?>
                <?php if (!$feedbacks): ?>
                    <div class="empty-state"><strong>No approved feedback yet.</strong><p>Submit a story and wait for admin approval.</p></div>
                <?php endif; ?>
            </div>
        </section>

        <section class="container section faq-grid">
            <div class="reveal">
                <span class="eyebrow">FAQ</span>
                <h2>Built for real association workflows.</h2>
                <p>Not every action is instantly public. Important content is reviewed before appearing to volunteers.</p>
            </div>
            <div class="faq-list reveal">
                <details open><summary>Who approves public content?</summary><p>Admins approve associations, missions, events and public feedback.</p></details>
                <details><summary>Who validates participation?</summary><p>Owners or admins can accept applications, event registrations and volunteer hours.</p></details>
                <details><summary>Can guests leave feedback?</summary><p>Yes. Feedback can be submitted by anyone, but it appears publicly only after admin approval.</p></details>
            </div>
        </section>
        <?php
    }, true, 'home-page');
}

function renderMissions(): void
{
    $filters = [
        'q' => trim((string)($_GET['q'] ?? '')),
        'city' => trim((string)($_GET['city'] ?? '')),
        'category' => trim((string)($_GET['category'] ?? '')),
        'association' => trim((string)($_GET['association'] ?? '')),
    ];
    $missions = approvedMissions(36, $filters);
    $options = lookupOptions();
    if (array_filter($filters)) {
        trackEvent('mission_search', 'mission', null, ['filters' => $filters, 'results' => count($missions)]);
    }

    renderShell('Mission discovery', function () use ($filters, $missions, $options) {
        ?>
        <section class="page-hero compact-hero">
            <div class="container">
                <span class="eyebrow">Mission discovery</span>
                <h1>Find the right way to help.</h1>
                <p>Filter approved missions by cause, city, association and timing. Save opportunities and apply when you are ready.</p>
            </div>
        </section>

        <section class="container discovery-layout">
            <aside class="filter-panel reveal">
                <div class="filter-heading">
                    <strong>Advanced filters</strong>
                    <a href="<?= e(appUrl('missions')) ?>">Reset</a>
                </div>
                <form method="get" class="filter-form">
                    <input type="hidden" name="page" value="missions">
                    <label>Search
                        <input type="search" name="q" value="<?= e($filters['q']) ?>" placeholder="Title, cause, association...">
                    </label>
                    <label>City
                        <select name="city">
                            <option value="">All cities</option>
                            <?php foreach ($options['cities'] as $c): ?>
                                <option value="<?= e($c['city']) ?>" <?= $filters['city'] === $c['city'] ? 'selected' : '' ?>><?= e($c['city']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </label>
                    <label>Category
                        <select name="category">
                            <option value="">All categories</option>
                            <?php foreach ($options['categories'] as $c): ?>
                                <option value="<?= e($c['category']) ?>" <?= $filters['category'] === $c['category'] ? 'selected' : '' ?>><?= e($c['category']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </label>
                    <label>Association
                        <select name="association">
                            <option value="">All associations</option>
                            <?php foreach ($options['associations'] as $a): ?>
                                <option value="<?= e((string)$a['id']) ?>" <?= $filters['association'] === (string)$a['id'] ? 'selected' : '' ?>><?= e($a['name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </label>
                    <button class="btn btn-primary full" type="submit">Apply filters</button>
                </form>

                <div class="saved-dock">
                    <strong>Saved missions</strong>
                    <p data-saved-count>0 saved locally</p>
                    <small>Saved missions are stored in your browser for quick review.</small>
                </div>
            </aside>

            <div class="result-panel">
                <div class="result-toolbar reveal">
                    <div>
                        <span class="eyebrow"><?= e((string)count($missions)) ?> results</span>
                        <h2>Approved volunteer missions</h2>
                    </div>
                    <button class="btn btn-secondary" type="button" data-command-open>Quick jump</button>
                </div>

                <?php if ($missions): ?>
                    <div class="mission-grid">
                        <?php foreach ($missions as $m) { missionCard($m); } ?>
                    </div>
                <?php else: ?>
                    <div class="empty-state large reveal">
                        <span>🔎</span>
                        <strong>No mission matches these filters.</strong>
                        <p>Try removing one filter or checking another city/category.</p>
                        <a class="btn btn-primary" href="<?= e(appUrl('missions')) ?>">Clear filters</a>
                    </div>
                <?php endif; ?>
            </div>
        </section>
        <?php
    });
}

function renderMissionDetail(): void
{
    $id = (int)($_GET['id'] ?? 0);
    $mission = oneMission($id);

    renderShell('Mission details', function () use ($mission) {
        if (!$mission) {
            echo '<section class="container section"><div class="empty-state large"><strong>Mission not found.</strong><p>This mission may have been removed or is not approved.</p><a class="btn btn-primary" href="' . e(appUrl('missions')) . '">Back to missions</a></div></section>';
            return;
        }

        $user = currentUser();
        $accepted = (int)($mission['accepted_count'] ?? 0);
        $seats = max(1, (int)$mission['seats']);
        $left = max(0, $seats - $accepted);
        ?>
        <section class="detail-hero">
            <div class="container detail-grid">
                <div class="detail-main reveal">
                    <span class="tag tag-teal"><?= e($mission['category']) ?></span>
                    <h1><?= e($mission['title']) ?></h1>
                    <p><?= e($mission['summary']) ?></p>
                    <div class="detail-meta">
                        <span>📍 <?= e($mission['city']) ?></span>
                        <span>🗓 <?= e(safeDate($mission['start_date'])) ?> → <?= e(safeDate($mission['end_date'])) ?></span>
                        <span>🏛 <?= e($mission['association_name']) ?></span>
                        <span>👥 <?= e((string)$left) ?> seats left</span>
                    </div>
                </div>
                <aside class="apply-card reveal">
                    <div class="score-ring"><strong><?= e((string)$left) ?></strong><span>seats left</span></div>
                    <h3>Ready to volunteer?</h3>
                    <p>Applications are reviewed by the association owner or an admin before participation is confirmed.</p>
                    <?php if (!$user): ?>
                        <a class="btn btn-primary full" href="<?= e(appUrl('login')) ?>">Sign in to apply</a>
                    <?php elseif ($user['role'] !== 'member'): ?>
                        <div class="notice">Only member accounts can apply to missions.</div>
                    <?php else: ?>
                        <form method="post" class="stack-form">
                            <?php csrfField(); ?>
                            <input type="hidden" name="action" value="apply_mission">
                            <input type="hidden" name="mission_id" value="<?= e((string)$mission['id']) ?>">
                            <label>Motivation message
                                <textarea name="motivation" rows="4" placeholder="Share your availability, skills, or why this mission matters to you."></textarea>
                            </label>
                            <button class="btn btn-primary full" type="submit">Send application</button>
                        </form>
                    <?php endif; ?>
                </aside>
            </div>
        </section>

        <section class="container detail-content">
            <article class="content-panel reveal">
                <h2>Mission brief</h2>
                <p><?= nl2br(e($mission['description'])) ?></p>
                <div class="info-cards">
                    <div><span>Cause</span><strong><?= e($mission['category']) ?></strong></div>
                    <div><span>Schedule</span><strong><?= e(daysUntil($mission['start_date'])) ?></strong></div>
                    <div><span>Capacity</span><strong><?= e((string)$accepted) ?>/<?= e((string)$seats) ?> confirmed</strong></div>
                </div>
            </article>
            <aside class="side-panel reveal">
                <h3>Association</h3>
                <div class="org-inline">
                    <span class="org-badge"><?= e(initials($mission['association_name'])) ?></span>
                    <div><strong><?= e($mission['association_name']) ?></strong><small><?= e($mission['association_category']) ?></small></div>
                </div>
                <p><?= e($mission['association_description']) ?></p>
                <div class="soft-list">
                    <span>📍 <?= e($mission['association_city']) ?></span>
                    <?php if (!empty($mission['association_email'])): ?><span>✉ <?= e($mission['association_email']) ?></span><?php endif; ?>
                </div>
            </aside>
        </section>
        <?php
    });
}

function renderEvents(): void
{
    $events = approvedEvents(32);
    renderShell('Events', function () use ($events) {
        ?>
        <section class="page-hero compact-hero">
            <div class="container">
                <span class="eyebrow">Community events</span>
                <h1>Join moments that move people.</h1>
                <p>Events are public only after approval. Registrations remain reviewable by owners and admins.</p>
            </div>
        </section>
        <section class="container section">
            <div class="event-grid wide">
                <?php foreach ($events as $event) { eventCard($event); } ?>
                <?php if (!$events): ?>
                    <div class="empty-state large"><strong>No approved events yet.</strong><p>Events will appear here once approved by admins.</p></div>
                <?php endif; ?>
            </div>
        </section>
        <?php
    });
}

function renderEventDetail(): void
{
    $id = (int)($_GET['id'] ?? 0);
    $event = oneEvent($id);
    renderShell('Event details', function () use ($event) {
        if (!$event) {
            echo '<section class="container section"><div class="empty-state large"><strong>Event not found.</strong><p>This event may be unavailable.</p></div></section>';
            return;
        }
        $user = currentUser();
        $accepted = (int)$event['accepted_count'];
        $capacity = max(1, (int)$event['capacity']);
        ?>
        <section class="detail-hero event-detail">
            <div class="container detail-grid">
                <div class="detail-main reveal">
                    <span class="tag tag-amber">Community event</span>
                    <h1><?= e($event['title']) ?></h1>
                    <p><?= e($event['summary']) ?></p>
                    <div class="detail-meta">
                        <span>📍 <?= e($event['city']) ?></span>
                        <span>🗓 <?= e(safeDate($event['event_date'])) ?></span>
                        <span>🏛 <?= e($event['association_name']) ?></span>
                        <span>👥 <?= e((string)$accepted) ?>/<?= e((string)$capacity) ?> confirmed</span>
                    </div>
                </div>
                <aside class="apply-card reveal">
                    <h3>Request a seat</h3>
                    <p>Registration is reviewed before being confirmed.</p>
                    <?php if (!$user): ?>
                        <a class="btn btn-primary full" href="<?= e(appUrl('login')) ?>">Sign in to register</a>
                    <?php elseif ($user['role'] !== 'member'): ?>
                        <div class="notice">Only member accounts can register for events.</div>
                    <?php else: ?>
                        <form method="post">
                            <?php csrfField(); ?>
                            <input type="hidden" name="action" value="register_event">
                            <input type="hidden" name="event_id" value="<?= e((string)$event['id']) ?>">
                            <button class="btn btn-primary full" type="submit">Request registration</button>
                        </form>
                    <?php endif; ?>
                </aside>
            </div>
        </section>
        <section class="container section">
            <div class="content-panel">
                <h2>Event details</h2>
                <p><?= nl2br(e($event['description'])) ?></p>
            </div>
        </section>
        <?php
    });
}

function renderAssociations(): void
{
    $associations = approvedAssociations(48);
    renderShell('Associations', function () use ($associations) {
        ?>
        <section class="page-hero compact-hero">
            <div class="container">
                <span class="eyebrow">Verified organizations</span>
                <h1>Associations with approved public activity.</h1>
                <p>Only approved association profiles are shown publicly.</p>
            </div>
        </section>
        <section class="container section">
            <div class="association-grid">
                <?php foreach ($associations as $a): ?>
                    <article class="association-card large reveal">
                        <div class="org-badge"><?= e(initials($a['name'])) ?></div>
                        <span class="tag tag-sky"><?= e($a['category']) ?></span>
                        <h3><?= e($a['name']) ?></h3>
                        <p><?= e($a['description']) ?></p>
                        <div class="impact-row">
                            <div><strong><?= e((string)$a['mission_count']) ?></strong><span>missions</span></div>
                            <div><strong><?= e((string)$a['event_count']) ?></strong><span>events</span></div>
                            <div><strong><?= e($a['city']) ?></strong><span>city</span></div>
                        </div>
                        <details class="contact-drawer">
                            <summary>Contact association</summary>
                            <form method="post" class="stack-form mini-form">
                                <?php csrfField(); ?>
                                <input type="hidden" name="action" value="send_message">
                                <input type="hidden" name="association_id" value="<?= e((string)$a['id']) ?>">
                                <label>Your name <input name="sender_name" value="<?= e(currentUser()['full_name'] ?? '') ?>" required></label>
                                <label>Email <input type="email" name="sender_email" value="<?= e(currentUser()['email'] ?? '') ?>" required></label>
                                <label>Message <textarea name="message" rows="3" required placeholder="Ask about availability, requirements, or partnership details."></textarea></label>
                                <button class="btn btn-secondary full" type="submit">Send message</button>
                            </form>
                        </details>
                    </article>
                <?php endforeach; ?>
            </div>
        </section>
        <?php
    });
}

function renderFeedback(): void
{
    $feedbacks = approvedFeedbacks(24);
    $user = currentUser();
    renderShell('Community stories', function () use ($feedbacks, $user) {
        ?>
        <section class="page-hero compact-hero">
            <div class="container">
                <span class="eyebrow">Feedback and trust</span>
                <h1>Stories are public only after admin approval.</h1>
                <p>Anyone can submit feedback. Admin moderation protects the public experience.</p>
            </div>
        </section>

        <section class="container feedback-layout section">
            <div class="testimonial-grid">
                <?php foreach ($feedbacks as $f): ?>
                    <article class="quote-card reveal">
                        <div class="stars"><?= str_repeat('★', (int)$f['rating']) ?></div>
                        <h3><?= e($f['title']) ?></h3>
                        <p>“<?= e($f['message']) ?>”</p>
                        <strong><?= e($f['author_name']) ?></strong>
                    </article>
                <?php endforeach; ?>
                <?php if (!$feedbacks): ?><div class="empty-state"><strong>No approved stories yet.</strong></div><?php endif; ?>
            </div>

            <aside class="form-panel reveal">
                <span class="eyebrow">Submit story</span>
                <h2>Leave feedback</h2>
                <form method="post" class="stack-form">
                    <?php csrfField(); ?>
                    <input type="hidden" name="action" value="feedback_submit">
                    <label>Name
                        <input name="author_name" value="<?= e($user['full_name'] ?? '') ?>" placeholder="Your name">
                    </label>
                    <label>Email
                        <input type="email" name="email" value="<?= e($user['email'] ?? '') ?>" placeholder="name@email.com">
                    </label>
                    <label>Rating
                        <select name="rating">
                            <option value="5">5 · Excellent</option>
                            <option value="4">4 · Good</option>
                            <option value="3">3 · Average</option>
                            <option value="2">2 · Needs work</option>
                            <option value="1">1 · Poor</option>
                        </select>
                    </label>
                    <label>Title
                        <input name="title" placeholder="Short title">
                    </label>
                    <label>Message
                        <textarea name="message" rows="5" placeholder="Share your experience."></textarea>
                    </label>
                    <button class="btn btn-primary full" type="submit">Submit for review</button>
                </form>
            </aside>
        </section>
        <?php
    });
}

function renderJoin(): void
{
    renderShell('Join', function () {
        ?>
        <section class="auth-page">
            <div class="container auth-grid">
                <div class="auth-intro reveal">
                    <span class="eyebrow">Create account</span>
                    <h1>Choose how you want to participate.</h1>
                    <p>Members apply to missions and track impact. Owners register associations and manage verified operations.</p>
                    <div class="mini-checks">
                        <span>✓ Admin-reviewed public content</span>
                        <span>✓ Owner validation workflow</span>
                        <span>✓ Member hours and badges</span>
                    </div>
                </div>

                <div class="auth-cards">
                    <article class="form-panel reveal">
                        <span class="tag tag-teal">Member</span>
                        <h2>Join as volunteer</h2>
                        <form method="post" class="stack-form">
                            <?php csrfField(); ?>
                            <input type="hidden" name="action" value="register_member">
                            <label>Full name <input name="full_name" required placeholder="Yasmine Mansour"></label>
                            <label>Email <input type="email" name="email" required placeholder="you@email.com"></label>
                            <label>City <input name="city" placeholder="Tunis"></label>
                            <label>Password <input type="password" name="password" required minlength="6" placeholder="At least 6 characters"></label>
                            <button class="btn btn-primary full" type="submit">Create member account</button>
                        </form>
                    </article>

                    <article class="form-panel reveal" id="owner">
                        <span class="tag tag-amber">Association owner</span>
                        <h2>Register an association</h2>
                        <form method="post" class="stack-form">
                            <?php csrfField(); ?>
                            <input type="hidden" name="action" value="register_owner">
                            <label>Owner full name <input name="full_name" required placeholder="Salma Ben Ali"></label>
                            <label>Email <input type="email" name="email" required placeholder="owner@email.com"></label>
                            <label>Password <input type="password" name="password" required minlength="6" placeholder="At least 6 characters"></label>
                            <label>Association name <input name="association_name" required placeholder="Association name"></label>
                            <label>Category <input name="category" placeholder="Education, food aid, care..."></label>
                            <label>City <input name="city" placeholder="Tunis"></label>
                            <label>Description <textarea name="description" rows="4" placeholder="What does your association do?"></textarea></label>
                            <button class="btn btn-dark full" type="submit">Create owner workspace</button>
                        </form>
                    </article>
                </div>
            </div>
        </section>
        <?php
    });
}

function renderLogin(): void
{
    renderShell('Sign in', function () {
        ?>
        <section class="auth-page">
            <div class="container login-grid">
                <article class="form-panel login-card reveal">
                    <span class="eyebrow">Secure workspace</span>
                    <h1>Sign in to Benevolink</h1>
                    <form method="post" class="stack-form">
                        <?php csrfField(); ?>
                        <input type="hidden" name="action" value="login">
                        <label>Email <input type="email" name="email" required placeholder="admin@benevolink.test"></label>
                        <label>Password <input type="password" name="password" required placeholder="••••••••"></label>
                        <button class="btn btn-primary full" type="submit">Open dashboard</button>
                    </form>
                    <div class="demo-box">
                        <strong>Demo accounts</strong>
                        <p>Admin: admin@benevolink.test / admin123</p>
                        <p>Owner: salma@croissant.test / resp123</p>
                        <p>Member: yasmine@demo.test / bene123</p>
                    </div>
                </article>
                <aside class="login-art reveal">
                    <div class="product-window compact">
                        <div class="window-bar"><span></span><span></span><span></span><strong>Daily operations</strong></div>
                        <div class="operation-list">
                            <div><span class="pill warn">Pending</span><strong>3 mission approvals</strong></div>
                            <div><span class="pill good">Accepted</span><strong>8 volunteer applications</strong></div>
                            <div><span class="pill neutral">Report</span><strong>42 verified hours this month</strong></div>
                        </div>
                    </div>
                </aside>
            </div>
        </section>
        <?php
    });
}

