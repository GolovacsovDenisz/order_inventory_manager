# Fix 401: Configure Supabase to Accept Firebase JWTs

Your app is correctly sending the Firebase ID token. Supabase returns 401 with:

- **Code:** PGRST301  
- **Message:** "No suitable key was found to decode the JWT"

That means the Supabase project is **not** configured to verify Firebase JWTs. Configure it as follows.

## 1. Add Firebase as Third-Party Auth in Supabase

1. Open **[Supabase Dashboard](https://supabase.com/dashboard)** → your project.
2. Go to **Authentication** → **Third-Party Auth** (or **Providers** / **Auth** settings).
3. Add a **Firebase** (or “Third-party”) integration.
4. Enter your **Firebase Project ID**:
   - Open [Firebase Console](https://console.firebase.google.com) → your project → **Project settings** (gear) → **General**.
   - Copy **Project ID** (e.g. `order-inventory-manager-e569e`).
5. Save. Supabase will then accept and verify JWTs issued by that Firebase project.

## 2. (Recommended) Set `role: 'authenticated'` for Firebase users

Supabase uses the JWT `role` claim to choose the Postgres role. Firebase tokens don’t include `role` by default, so Supabase may treat the user as `anon`.

- **Option A – Blocking function (Firebase Identity Platform):**  
  Use a [blocking function](https://firebase.google.com/docs/auth/extend-with-blocking-functions) that sets `customClaims: { role: 'authenticated' }` on sign-in/sign-up.
- **Option B – Cloud Function:**  
  Use an `onCreate` (and optionally sign-in) Cloud Function that sets the same custom claim via the Admin SDK.
- **Option C – One-off for existing users:**  
  Run a script with the Firebase Admin SDK that calls `setCustomUserClaims(uid, { role: 'authenticated' })` for each user.

After this, new (and optionally existing) Firebase ID tokens will contain `role: 'authenticated'`, and Supabase will use the `authenticated` role for RLS/API.

## 3. RLS (if you use it)

If you use Row Level Security, your policies must allow the `authenticated` role (and optionally restrict by `auth.jwt() ->> 'sub'` or Firebase `iss`/`aud`). The [Supabase Firebase Auth guide](https://supabase.com/docs/guides/auth/third-party/firebase-auth) has examples.

---

**Summary:** Add Firebase as Third-Party Auth in Supabase and enter your Firebase Project ID. Optionally add the `role: 'authenticated'` claim for Firebase users. No changes are required in your Flutter app.
