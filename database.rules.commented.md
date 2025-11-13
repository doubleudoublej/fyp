## Commented Realtime Database rules (human-readable)

The project `database.rules.json` must be valid JSON (no // comments).
I restored the earlier, human-friendly version here for reference and editing.

DO NOT deploy this file directly. Instead, copy the cleaned JSON from
`database.rules.json` into the Firebase Console or use the Firebase CLI to
deploy rules.

---

{
    "forum": {
      "posts": {
        ".read": "true",                         // allow public read (change to auth != null to require sign-in)
        ".write": "auth != null",
        "$postId": {
          // require the post to include the listed fields and that authorUid matches auth.uid when creating
          ".validate": "newData.hasChildren(['authorUid','author','title','content','timestamp'])",
          "authorUid": {
            ".validate": "newData.val() === auth.uid"
          },
          "comments": {
            ".write": "auth != null",
            "$commentId": {
              ".validate": "newData.hasChildren(['authorUid','author','content','timestamp']) && newData.child('authorUid').val() === auth.uid"
            }
          }
        }
      }
    },
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid === $uid",
        ".write": "auth != null && auth.uid === $uid"
      }
    },
    // default deny
    ".read": false,
    ".write": false
}

---

Quick notes:
- The cleaned/valid JSON lives in `database.rules.json` at the repo root — use
  that for deployments.
- The important paths for your app are:
  - `forum/posts` — reads are public, writes require authentication.
  - `users/{uid}` — users may read/write only their own node (used for points).
- If you keep getting `permission_denied` for `forum/posts`:
  1) Verify the app user is actually signed in (AuthService.authStateChanges).
  2) Confirm the app is pointing at the same Realtime Database instance as
     the rules (check `databaseURL` in `lib/firebase_options.dart` and the
     console project).
  3) If you deployed the rules and still get denied, open the Firebase
     Console → Realtime Database → Rules and paste the JSON from
     `database.rules.json` to ensure it's the active rules.

How to deploy from CLI (PowerShell):

```powershell
# login once
npm i -g firebase-tools
firebase login

# deploy the database rules (replace YOUR_PROJECT_ID if needed)
firebase deploy --only database:rules --project YOUR_PROJECT_ID
```

If you'd like, I can also:
- implement an atomic increment (transaction) for `users/{uid}/points` in
  `PointsService` so concurrent updates don't race, and switch your Home code
  to use it. Tell me to proceed and I'll make the change and run the analyzer.
