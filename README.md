# Benevolink Human Pro

Benevolink Human Pro is a small volunteer and association management platform built with PHP.
It provides public pages for missions, events, associations, and feedback, plus a dashboard area for members, owners, and admins.

## Project purpose

This app is designed to:
- let volunteers browse and save missions and events
- let associations publish mission and event opportunities
- let users submit feedback and contact associations
- let admins review applications, hours, events, and association requests
- log user activity with event tracking

## Key features

- Public landing pages for missions, events, associations and feedback
- Member registration and sign-in
- Owner registration with association onboarding
- Admin moderation and approval flows
- Saved missions, volunteer hours submission, and event registrations
- Notifications and audit tracking for workflow actions
- Simple routing via `core/router.php`
- Database-backed storage using MySQL

## File structure

- `index.php` — application entry point
- `config.php` — database and app configuration
- `core/bootstrap.php` — shared helpers, DB connection, session and CSRF utilities
- `core/router.php` — simple page dispatching
- `actions/handle_post.php` — POST form processing and business logic
- `pages/public_pages.php` — public-facing page renderers
- `pages/dashboard_pages.php` — authenticated dashboard renderers
- `assets/` — CSS, JavaScript, and UI assets

## Configuration

Open `config.php` and verify the database settings:

- `host`: your MySQL host (`127.0.0.1` or `localhost`)
- `port`: MySQL port (`3306`)
- `name`: database name (`benevolink`)
- `user`: MySQL user (`root` by default)
- `pass`: this project is now configured with an empty password (`''`)

This means the app expects the local MySQL `root` account to have no password.

## Usage

1. Place the `benevolink_human_pro` folder inside your web server root, for example `C:\xampp\htdocs\`.
2. Ensure MySQL is running.
3. Create or import the `benevolink` database.
4. Access the site at:
   - `http://localhost/benevolink_human_pro/index.php`

## Notes

- The app includes inline PHP comments and documentation in the main helper files.
- The database password has been updated to an empty string for local development.
- Keep the `config.php` password value secure if deploying to a non-local or production environment.

## Demo accounts

These example accounts are referenced in the original project docs:

- `admin@benevolink.test` / `admin123`
- `salma@croissant.test` / `resp123`
- `karim@jeunes.test` / `resp123`
- `yasmine@demo.test` / `bene123`

If you want, I can also add more comments to the page renderers and dashboard logic next.
