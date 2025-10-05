Local dev private access flow

This project includes helpers to test Stripe checkout -> private access flows locally without relying on external webhook infrastructure.

Files added for local dev testing:
- `scripts/dev-verify.sh` — automates creating a Stripe product, price, test customer, checkout session, calls the admin grant endpoint, and then calls `/api/verify-session` to retrieve a JWT. Requires `STRIPE_SECRET_KEY` and `ADMIN_ONBOARD_TOKEN` in the environment or `.env.local`.
- `app/api/admin-grant-access/route.ts` — admin-only endpoint to grant access for a Stripe customer (local dev only; requires `ADMIN_ONBOARD_TOKEN`).
- `app/api/admin-revoke-access/route.ts` — admin-only endpoint to revoke access for a Stripe customer.
- `.v2u-mock-kv.json` — persisted mock KV store (project-local). This file is ignored by git.

Quick start

1. Add your dev keys to `.env.local`:

```
ADMIN_ONBOARD_TOKEN=your_onboard_token_here
STRIPE_SECRET_KEY=sk_test_...
```

2. Start the Next dev server:

```
npm run dev
```

3. Run the automated script (it will print the Checkout session id and the JWT if successful):

```
./scripts/dev-verify.sh
```

4. Use the printed JWT to call private endpoints:

```
curl -H "Authorization: Bearer <JWT>" http://localhost:3000/api/r2/private/...
```

Security note: All added helpers are intended for local development only. Do not commit `.env.local` or `.v2u-mock-kv.json` to your repository; they are added to `.gitignore` by the script.
