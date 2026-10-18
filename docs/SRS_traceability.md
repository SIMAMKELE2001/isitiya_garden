# isitiyaGarden: requirements traceability

How each SRS requirement is implemented and how it is verified.
Fill in the last column as you test on the phone (tick, date, notes).
Test ids: **T1-T10** = buyer tests (Phase 5) and farmer tests (Phase 6);
**S01-S12** = database security tests; **U** = automated tests (`flutter test`).

## Functional requirements

| Req | Implemented in | Verified by | Result |
|---|---|---|---|
| FR01 Register | `register_page.dart`, `AuthRepository.register`, trigger `handle_new_user` | Register farmer and buyer; rows appear in `profiles` and role tables | |
| FR02 Login | `login_page.dart`, `AuthRepository.signIn` | Log in; wrong password shows error | |
| FR03 Role identification | `AppGate` in `app.dart`, `profiles.role`, trigger `lock_role` | Farmer and buyer land on different screens; S05 | |
| FR04 Farmer profile | `farmer_profile_page.dart`, `edit_farmer_profile_page.dart` | Edit farm name, WhatsApp, about; reopen app | |
| FR05 Create listing | `listing_form_page.dart`, `FarmerRepository.createListing` | Farmer test: add produce; row has own `farmer_id` | |
| FR06 Upload photo | `_pickImage`, `uploadImage`, bucket `produce-images` | Add listing with photo; buyer sees it | |
| FR07 Name and category | Form fields; `categories` table | Farmer test; U (`ListingValidators.name`) | |
| FR08 Quantity and unit | Form fields; `units` table | U (`quantity`) | |
| FR09 Price / negotiable | Form switch; constraint `price_or_negotiable` | U (`price`); Test B in Phase 1 | |
| FR10 Availability | `availability_status`, `available_from/until` | Edit status and dates; U (`Format.availability`) | |
| FR11 General location | `community_id`, `location_note` | Listing shows community on card | |
| FR12 Intended buyer types | `listing_buyer_types`, pills in the form | Table Editor shows rows after save | |
| FR13 Additional information | `description` field | Detail page shows it | |
| FR14 Edit listing | `ListingFormPage(existing:)`, `updateListing` | Edit quantity; card updates | |
| FR15 Mark unavailable | `ListingTile` menu, `setAvailability` | Buyer no longer sees it (T10, S06) | |
| FR16 Deactivate | `ListingTile` menu, `setActive` | Moves to Deactivated; hidden from buyers | |
| FR17 Buyer profile | `buyer_profile_page.dart`, `edit_buyer_profile_page.dart` | Edit and save | |
| FR18 Buyer type | Register dropdown, edit page, `buyer_profiles` | Detail page suitability note changes | |
| FR19 Browse | `buyer_home_page.dart`, view `active_listings` | Buyer test 1 | |
| FR20 Search | `search_page.dart`, `fetchActive(query:)` | Search "spin"; "zzz" shows no results | |
| FR21 Filter | Category, availability, community pills | Buyer tests 5 and 6 | |
| FR22 Details | `produce_detail_page.dart` | Buyer test 7 | |
| FR23 Farmer information | Farmer panel; contact numbers in the view | Buyer test 7 | |
| FR24 Intended buyer type | "Who is this for?" section | Change buyer type; note changes | |
| FR25 Contact farmer | `contact_sheet.dart` | Call, WhatsApp, SMS open; no payment text | |

## Non-functional requirements

| Req | Implemented in | Verified by | Result |
|---|---|---|---|
| NFR01 Usability | Few steps per task, large targets, plain language | Walk through with a non-technical user | |
| NFR02 Security (authentication) | `AppGate`; RLS policies `to authenticated` | S11, S12; log out and relaunch | |
| NFR03 Authorization | RLS policies, composite role foreign keys, `lock_role` | S01-S10 | |
| NFR04 Data validation | `Validators`, `ListingValidators`, database CHECK constraints | U; empty-form tests on phone | |
| NFR05 Error handling | `friendlyAuthError`, `FormErrorBox`, `ErrorState` | Airplane-mode test; wrong password; U (widget) | |
| NFR06 Data integrity | Constraints, triggers, undo in `createListing` | Edit and mark unavailable; Table Editor check | |
| NFR07 Maintainability | Feature folders, repository layer, providers | Code review | |
| NFR08 Mobile compatibility | Flutter, Android | Runs on a physical phone | |
| NFR09 Performance | Server-side filtering, search debounce, skeletons | Time search and list loading on mobile data | |
| NFR10 Information accuracy | View `active_listings` hides inactive/unavailable/expired | T10, S06, S09 | |

## Acceptance criteria (SRS section 7)

| Group | Criteria | Where to see it | Result |
|---|---|---|---|
| Create listing | Fields shown; valid saves; tied to the farmer; active by default; invalid blocked | Add produce form; Table Editor (`farmer_id`, `is_active`) | |
| Intended buyer types | One or more; saved; shown to buyers | Form pills; `listing_buyer_types`; detail page | |
| Search | Enter term; active matches only; shows details; "no match" message | Search tab | |
| Filter | Apply, change, remove; inactive excluded | Search tab pills, Clear filters | |
| Contact farmer | Contact info reachable; action offered; communication starts; no payment or delivery | Contact sheet and its notice | |
