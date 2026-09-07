Benevolink Human Pro — Interactive Dashboard + Database Tracking Upgrade

Folder name:
benevolink_human_pro

Install app files:
1. Delete:
   C:\xampp\htdocs\benevolink_human_pro

2. Copy this folder into:
   C:\xampp\htdocs\

3. Keep your current MySQL database:
   benevolink

Database upgrade:
1. Open phpMyAdmin.
2. Select/import the file:
   database_update.sql
3. This upgrade DOES NOT drop the database.
4. It adds:
   - feature_events
   - saved_missions
   - user_preferences
   - member_skills
   - association_messages
   - impact_goals
   - analytics views
   - triggers for applications, hours and event registrations

Open:
http://localhost/benevolink_human_pro/index.php

Demo accounts:
admin@benevolink.test / admin123
salma@croissant.test / resp123
karim@jeunes.test / resp123
yasmine@demo.test / bene123

What is new:
- database-backed usage tracking
- interactive charts in member/owner/admin dashboards
- saved missions stored in database for logged-in members
- association contact messages stored in database
- member skills stored in database
- automatic database event logging through triggers
- page views, clicks, forms, searches and dashboard interactions logged in feature_events
