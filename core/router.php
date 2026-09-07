<?php
/**
 * Simple page router.
 * Resolves the requested page and renders the matching screen.
 */
$route = page();

match ($route) {
    'home' => renderHome(),
    'missions' => renderMissions(),
    'mission' => renderMissionDetail(),
    'events' => renderEvents(),
    'event' => renderEventDetail(),
    'associations' => renderAssociations(),
    'feedback' => renderFeedback(),
    'join' => renderJoin(),
    'login' => renderLogin(),
    'dashboard' => renderDashboard(),
    default => renderHome(),
};
