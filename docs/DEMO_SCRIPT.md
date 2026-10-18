# isitiyaGarden: demo script (about 6 minutes)

## Before you present (do this the day before and an hour before)

- [ ] Supabase project is **active**. Free projects pause after about a week of
      inactivity, so open the dashboard and check. Restore it if it is paused.
- [ ] Phone is charged, on Wi-Fi or good mobile data, and **the release APK is installed**.
- [ ] Two accounts exist, with passwords written down privately:

      | Role | Email | Password |
      |---|---|---|
      | Farmer | | |
      | Buyer | | |

- [ ] The farmer has 4 or 5 realistic listings: at least one with a photo, one
      with "Low availability", one negotiable, and one **unavailable**.
- [ ] Remove odd test listings ("Test", "asdf") from the Table Editor.
- [ ] Do a full run-through once on the phone you will present with.
- [ ] Record a screen video of the full flow as a backup in case the network fails.
- [ ] Have `docs/SRS_traceability.md` and the security test results open.

## The story (say this in your own words)

> Many smallholder farmers in rural communities grow produce but buyers nearby
> cannot see what is available today. isitiyaGarden makes that produce visible
> and lets the buyer contact the farmer directly. It does not process payments
> or delivery.

## 1. Farmer (about 2.5 minutes)

1. Open the app: splash, onboarding (mention Skip), log in as the **farmer**.
2. Show the dashboard: how many listings buyers can see.
3. **Add produce:**
   - Tap Add with an empty form to show the inline validation.
   - Try to save without a price to show the price rule; switch on "Price is negotiable".
   - Add a photo, choose buyer types, save. Point out the upload stages and the
     success message.
4. **My produce:** edit a quantity, **mark one listing unavailable**, deactivate
   one and show it moves to the Deactivated tab.

## 2. Buyer (about 2.5 minutes)

1. Log out, log in as the **buyer**.
2. Home: produce from the buyer's own community first. Tap a category.
3. Search a name, add a filter, show the "no results" message, clear the filters.
4. Open a listing: photo, quantity, price, farmer information, "Who is this for?".
5. **The key moment:** the listing the farmer marked unavailable and the one they
   deactivated are **not shown** (NFR10).
6. Tap **Contact farmer**: call, WhatsApp, SMS. Point out the notice that
   payments and delivery are not handled.

## 3. Quality and security (about 1 minute)

- Show the traceability table: every requirement mapped to code and a test.
- Show the security test table: 12 of 12 PASS (a buyer cannot edit a farmer's
  listing, roles cannot be changed, logged-out users see nothing).
- Mention `flutter test` and the accessibility checks (large text, TalkBack,
  words with every status badge, not colour alone).

## If something goes wrong

| Problem | What to do |
|---|---|
| No internet | Show the friendly error and Try again button (that is the error-state requirement), then play the backup video |
| Data does not load | Check the Supabase project is not paused |
| App crashes | Reopen it. You stay logged in. Continue the story |
| Phone does not respond | Switch to the backup video |

## Questions you may be asked

- **Why Supabase?** Hosted PostgreSQL with authentication, storage and built-in
  row-level security, so rules are enforced in the database, not just the app.
- **How do you stop one farmer editing another's produce?** Row Level Security
  policies check the logged-in user on every request (security tests S01-S10).
- **What is out of scope?** Payments, delivery, ratings, chat, recommendations,
  as the SRS states.
- **What would you improve next?** Request timeouts, an atomic database
  function for saving listings, offline caching, email confirmation, and a
  distance-based "nearby".
