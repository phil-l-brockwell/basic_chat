# Basic Chat

A simple real-time chat app

- Sign up and sign in with an email address and password.
- Every new user joins the `#basic` room.
- Messages appear for everyone in the room straight away, over WebSockets.
- Older messages load as you scroll up.
- Every Monday at 9am (London time), each user is emailed how many messages
  were exchanged that week, and how many they've received since their last
  message.

## Running it

You need Ruby 4.0.7 (see `.ruby-version`), PostgreSQL, and Chrome for the
browser specs.

```sh
bin/setup   # installs gems, prepares the database and starts the server
```

Then open http://localhost:3000 and create an account. Once set up, start the
server with `bin/dev`.

## Tests

```sh
bundle exec rspec
```

## Emails in development

Emails open in your browser (via
[letter_opener](https://github.com/ryanb/letter_opener)) instead of being sent.

- **Preview the weekly email:** http://localhost:3000/rails/mailers/digest_mailer/weekly
- **Send it to every user:**
  ```sh
  bin/rails runner 'ActiveJob::Base.queue_adapter = :inline; WeeklyDigestJob.perform_now'
  ```

## Data Model

Chat uses three tables, alongside `users` and `sessions` (see "Users and sign-in"):

- **rooms**: a unique, lowercase `name`.
- **user_rooms**: joins users and rooms (many-to-many). A unique index on
  `[room_id, user_id]` means a user can join a room only once.
- **messages**: a `body`, belonging to a room and a user. Indexed on
  `[room_id, created_at]` for loading history.

Deleting a user or room deletes their memberships and messages too.

## How it works

### Users and sign-in

Sign-in uses Rails 8's built-in authentication generator, plus a sign-up page:

- Signing up creates the account and signs you straight in. Confirmation has been left out for ease of use during development.
- Passwords must be at least 8 characters, and email addresses must be valid
  and unique (ignoring case).
- Each signed-in browser is a `Session` row, referenced from a signed,
  HTTP-only cookie. Every page requires signing in unless a controller opts out.
- The generator's password reset has been left out for now.

### Rooms

- A `Room` has a unique, lowercase name such as `basic`. Users join rooms
  through `UserRoom` records, at most once per room.
- New users are added to `#basic` when their account is created. `#basic` is
  created on first use, and `bin/rails db:seed` creates it too.
- Rooms are only ever looked up among the current user's rooms, so viewing or
  posting to a room you're not in returns a 404.
- `/` takes you to `#basic`, or shows "You're not in any rooms yet" if you
  aren't in it.

### Messages over WebSockets

1. The message form posts to `MessagesController#create` as a normal Turbo form
   submission. On success the response just resets the form.
2. Once the message is committed, `Message` broadcasts its rendered partial to
   the room's stream (`broadcast_append_to room`). The partial is rendered once
   for everyone, so it can't depend on who's viewing.
3. Every browser with the room open is subscribed through
   `turbo_stream_from @room`, and Turbo appends the message. That includes the
   sender, which is how their own message appears.
4. The WebSocket connection authenticates with the same signed session cookie
   as page requests, and rejects anyone without one.

Messages are 1 to 1,000 characters, with surrounding whitespace removed.

### Weekly email

`WeeklyDigestJob` runs at 9am every Monday, London time, as a Solid Queue
recurring task (`config/recurring.yml`). It emails every user:

> 600 messages have been exchanged in the last week.
> 750 since your last message on the 1st of February.

How I read the requirement:

- **"Sent and received in the last week"** counts every message in the user's
  rooms during the 7 days before the run, including their own.
- **"Since your last message"** counts other people's messages in the user's
  rooms since the user last posted anywhere. Someone who has never posted gets
  "since you joined on …" instead.
- Each run fixes one cut-off time and passes it to every email, so every digest
  from a run covers the same week, however long delivery takes.

The counting lives in `WeeklyDigest` (`app/models/weekly_digest.rb`), and the
wording in `config/locales/en.yml`. The app's time zone is London, so dates in
the email are UK dates. The year is added when the date isn't in the current
year.
