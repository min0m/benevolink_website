<?php
declare(strict_types=1);

/**
 * Entry point for the Benevolink app.
 * This file intentionally stays small:
 * - load bootstrap/helpers
 * - handle POST actions
 * - load page renderers
 * - dispatch to the router
 */
require __DIR__ . '/core/bootstrap.php';
require __DIR__ . '/actions/handle_post.php';
require __DIR__ . '/pages/public_pages.php';
require __DIR__ . '/pages/dashboard_pages.php';
require __DIR__ . '/core/router.php';
