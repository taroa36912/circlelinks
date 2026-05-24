# AGENTS.md

## Project Overview

CircleLinks is a Flutter/Dart app for university circle discovery, recruitment, circle-to-circle collaboration, event management, DM/chat, and portfolio building.

The app is intended to help university students and circles handle the full lifecycle of circle activity:

- Discovering and browsing university circles
- Creating and managing circles
- Recruiting new members
- Tagging users and members by skills or responsibilities
- Connecting with other circles
- Planning joint events
- Managing events and attendance
- Running temporary project/member recruitment
- Building a personal activity portfolio

## Tech Stack

- Flutter / Dart
- Riverpod
- Firebase Auth
- Cloud Firestore
- Supabase Storage
- Sizer
- Stripe exists in the codebase, but real payment features are not a current priority.

## Important Architecture Rules

- Do **not** assume `userId == circleId`.
- A user can manage multiple circles.
- Circle membership should be represented by `circles/{circleId}/members/{userId}`.
- Use explicit `circleId` values when working with circle-specific data.
- Keep old Firestore documents backward compatible when changing models.
- Model `fromFirestore` methods should safely handle missing fields.
- Avoid large rewrites unless explicitly requested.
- Prefer additive, compile-safe changes.
- Preserve existing routes and screens unless explicitly asked.
- Keep mock/demo features clearly separated from production data flows.
- Do not silently remove existing user-facing functionality.

## Current Product Priorities

Highest priority:

- Circle-to-circle collaboration
- Joint event planning
- New member recruitment
- Tag system
- Unified DM/application/member-add flow

Required near-term features:

- Tag system for users, members, recruitment, and projects
- New member recruitment
- Project and temporary member recruitment
- Circle recruitment status display
- Basic attendance persistence
- Manual/QR-style attendance check-in MVP

Important but later:

- Portfolio automation from attendance and planning history
- Richer event attendance analytics
- Cleaner role/permission management

Deferred:

- Real payment implementation
- Album upload feature
- Budget management
- Event budget management
- Enterprise/sponsor intervention
- Server scaling
- Local server migration

## Out of Scope Unless Explicitly Asked

Do not implement or expand the following unless the user specifically requests it:

- Real payment processing
- Stripe subscription billing
- PayPay or bank transfer automation
- Album/photo upload feature
- Budget management
- Event budget management
- Sponsor/company/enterprise features
- Server migration
- Infrastructure scaling based on revenue
- Large UI redesign
- Full camera QR scanner dependency changes
- Native platform-specific rewrites

## Commands

Run before reporting completion:

```bash
flutter analyze
```

For manual web testing:

```bash
flutter run -d chrome
```

When reporting work, include:

- Whether `flutter analyze` was run
- Number of errors
- Number of warnings
- Any remaining important info-level notes
- Any runtime checks performed manually

## Firestore/Data Notes

Preferred structure:

- `users/{userId}`
- `circles/{circleId}`
- `circles/{circleId}/members/{userId}`
- `tags/{tagId}`
- `circles/{circleId}/tags/{tagId}`
- `recruitments/{recruitmentId}`
- `recruitments/{recruitmentId}/applications/{applicationId}`
- `projects/{projectId}`
- `events/{eventId}`
- `events/{eventId}/attendances/{userId}`
- `connectionRequests/{requestId}`
- `dm_channels/{channelId}`
- `dm_channels/{channelId}/dm_messages/{messageId}`
- `chats/{chatId}`
- `chats/{chatId}/messages/{messageId}`

When adding new Firestore fields:

- Use safe defaults in model constructors and `fromFirestore`.
- Do not make existing documents crash.
- Avoid destructive migrations.
- Avoid changing collection paths unless explicitly requested.
- If a new path is introduced, document it in the final report.

## Authentication Notes

The app uses Firebase Auth.

Existing login-related flows include:

- Email/password login
- Google login
- LINE login
- Signup
- Password reset
- User upsert into Firestore

Do not change authentication logic unless explicitly requested.

Google profile images may be external `lh3.googleusercontent.com` URLs. These are not necessarily stored in Supabase Storage. Network image loading must have fallbacks because Google image URLs may fail or return HTTP 429.

## Storage Notes

Supabase Storage is used for uploaded images/documents.

The existing storage wrapper may have Firebase-like naming, but the actual implementation may use Supabase.

When adding image upload behavior:

- Do not store secrets in code.
- Keep public anon-key usage consistent with the current project.
- Add fallback UI for failed network images.
- Do not assume every `profileImageUrl` points to Supabase; it may be an external Google URL.

## UI/Language Notes

- User-facing labels are mostly Japanese.
- Keep Japanese labels unless there is a clear reason to change them.
- Prefer simple and usable UI over polished but risky redesigns.
- Do not introduce English-only UI into Japanese screens unless it is already consistent with the surrounding screen.
- Avoid layout overflow on Flutter Web.

## Routing Notes

Use `AppRoutes` for navigation where possible.

When adding route arguments:

- Use `Map<String, dynamic>` arguments.
- Safely cast route arguments:

```dart
final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
```

Common route argument conventions:

- Circle profile: `{ 'circleId': circleId }`
- Event details: `{ 'eventId': eventId }`
- Event creation: `{ 'circleId': circleId }`
- DM chat: `{ 'dmChannelId': channelId, 'recipientName': name }`
- Recruitment details: `{ 'recruitmentId': recruitmentId }`
- Recruitment management: `{ 'circleId': circleId }`

Do not navigate to screens that require `circleId` without passing it.

## Circle and Member Rules

Circle ownership/admin rights should be determined through membership:

- `circles/{circleId}/members/{userId}`
- `role == 'admin'` means the user can manage the circle.

Do not create new logic that assumes:

```dart
user.uid == circle.id
```

If old code uses this assumption, avoid making it worse. Prefer gradually migrating to explicit `circleId` and membership checks.

Member data may include:

- `role`
- `displayRole`
- `roleTags`
- `skillTags`
- `joinedAt`
- `updatedAt`

Examples of role tags:

- `会計`
- `広報`
- `代表`
- `副代表`
- `新歓担当`
- `撮影`
- `イベント運営`

## Recruitment Rules

New member recruitment should be separate from generic project recruitment.

Recruitment posts should support:

- Circle ID
- Circle name
- University name
- Title
- Description
- Status: `open`, `closed`, `draft`
- Target years
- Welcome tags
- Required tags
- Activity days
- Fee text
- Application method: `dm`, `form`, `event`
- Optional related event
- Capacity
- Deadline
- Applicant count

Recruitment applications should support:

- Recruitment ID
- Circle ID
- Applicant user ID
- Applicant name/email/profile image
- Message
- Applicant tags
- Status: `pending`, `accepted`, `declined`, `withdrawn`
- Created/updated timestamps

Admin acceptance can add the applicant to:

```text
circles/{circleId}/members/{userId}
```

## Project Recruitment Rules

The project board should support more than ordinary projects.

Supported recruitment types:

- `project`
- `temporary_member`
- `joint_event`
- `new_member`
- `staff`
- `other`

Supported application policies:

- `firstCome`
- `approvalRequired`

Supported visibility:

- `public`
- `connectedOnly`
- `private`

Do not break existing project posts. Old project documents should still render.

## Event and Attendance Rules

Event management should support both single-circle and joint events.

Joint event fields may include:

- `ownerCircleId`
- `organizerCircleIds`
- `circlePermissions`
- `collaborationStatus`
- `invitedCircleIds`

Attendance policy values:

- `qrOnly`
- `manualAllowed`
- `selfReport`
- `adminOnly`

Attendance documents should support:

- RSVP status
- Check-in method
- Checked-in user
- Checked-in-by admin
- Checked-in timestamp
- Optional note

For MVP, manual user ID input is acceptable for attendance check-in. Do not add a camera scanner dependency unless explicitly requested.

## Security Notes

Do not commit secrets.

Do not expose private keys.

Existing Supabase anon key usage is public-client style, but do not add new secrets.

Add `TODO_SECURITY` comments near sensitive client-side operations.

Firestore Security Rules must eventually enforce admin-only operations.

Sensitive operations include:

- Updating circle data
- Updating recruitment status
- Editing member roles/tags
- Accepting applications
- Adding/removing members
- Creating joint events
- Updating attendance manually
- Reading private events
- Reading private DM/chat data

UI-level hiding is not sufficient for real security. Use it for MVP UX, but leave TODOs for Firestore Rules.

## Network Image Safety

All network image rendering should be robust.

When using:

- `NetworkImage`
- `Image.network`
- `CircleAvatar(backgroundImage: ...)`
- custom image widgets

ensure fallback behavior exists.

For Google profile photo URLs, HTTP 429 may occur. The app should show a default avatar/icon instead of surfacing noisy image exceptions.

Preferred approach:

- Use `Image.network` with `errorBuilder` when practical.
- Use `onBackgroundImageError` for `CircleAvatar` if keeping `backgroundImage`.
- Centralize fallback behavior in `CustomImageWidget` when possible.

## Working Style for Agents

When asked to implement a feature:

1. Inspect the existing code first.
2. Identify affected models, services, routes, and screens.
3. Make the smallest coherent change.
4. Preserve backward compatibility.
5. Run `flutter analyze`.
6. Report files changed and known limitations.

Avoid:

- Large speculative rewrites
- Deleting working flows
- Mixing deferred features into current tasks
- Introducing new dependencies without asking
- Changing authentication, storage, or routing behavior unnecessarily

## Final Report Format

At the end of any coding task, report:

1. Files changed
2. Files added
3. Data models modified
4. Firestore collections/subcollections used
5. Main UI flows implemented
6. Known limitations/TODOs
7. Result of `flutter analyze`
8. Any manual runtime checks performed
