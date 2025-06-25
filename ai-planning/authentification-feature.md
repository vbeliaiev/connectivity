# Authentication Feature Implementation Checklist

This checklist guides a developer through implementing a minimum user authentication system using Devise in a Rails project, styled with Tailwind CSS, and following all project and feature requirements.

---

## 1. Gem and Dependency Setup
- [ ] Add `devise` gem to the Gemfile (if not present).
- [ ] Add `letter_opener` gem to the development and test groups in the Gemfile.
- [ ] Run `bundle install`.
- [ ] Install Tailwind CSS if not already present (verify integration with Rails views).

## 2. Devise Installation
- [ ] Run `rails generate devise:install`.
- [ ] Follow Devise post-install instructions:
    - [ ] Set up default URL options in `config/environments/development.rb` and `config/environments/production.rb`.
    - [ ] Ensure flash messages are not required (per spec).
    - [ ] Configure root route in `config/routes.rb` if not already set.

## 3. User Model
- [ ] Generate the User model: `rails generate devise User display_name:string`
- [ ] Add `confirmable` and `recoverable` modules to the User model.
- [ ] Run the migration to create the users table.
- [ ] Add `:confirmable` and `:recoverable` to the Devise modules in `user.rb`.
- [ ] Add logic to set `display_name` to `email.split('@').first` if left blank on registration (model callback or Devise parameter sanitizer).
- [ ] Ensure only `display_name`, `email`, and password fields are present (no extra fields).

## 4. Devise Configuration
- [ ] In `config/initializers/devise.rb`, set:
    - [ ] `config.mailer_sender` to a valid email address.
    - [ ] Session timeout to a long duration (e.g., 2 weeks).
    - [ ] Remove or comment out `:lockable`, `:omniauthable`, and other unused modules.
    - [ ] Set password length to Devise default (6+ characters).
- [ ] Configure `config/environments/production.rb` to use Google SMTP for ActionMailer.
- [ ] Configure `config/environments/development.rb` and `test.rb` to use `letter_opener` for ActionMailer.

## 5. Routes
- [ ] Use `devise_for :users` in `config/routes.rb`.
- [ ] Set root route to the desired controller/action (e.g., `root to: 'home#index'`).
- [ ] Ensure all Devise routes are available (registrations, sessions, confirmations, passwords).

## 6. Views and Layouts
- [ ] Run `rails generate devise:views` to generate Devise views.
- [ ] Create a standalone layout for authentication views (e.g., `app/views/layouts/auth.html.erb`).
- [ ] Update Devise views to use the standalone layout.
- [ ] Add the project logo and favicon to the layout (reuse existing assets).
- [ ] Style all Devise views (sign in, sign up, forgot password, confirmation) with default Tailwind CSS classes and colors.
- [ ] Add a privacy policy link/button to the sign-up form that opens a modal window.
- [ ] Add a required checkbox for privacy policy acceptance on the sign-up form (user cannot register without checking it).

## 7. Privacy Policy Modal
- [ ] Create a simple modal component for the privacy policy (can be a partial or a stimulus controller).
- [ ] Write a default privacy policy (brief, clear, and generic).
- [ ] Ensure the modal is accessible from the sign-up form.

## 8. Email Templates
- [ ] Add the project logo to the default Devise email templates (confirmation, password reset).
- [ ] Do not otherwise customize email content.

## 9. User Profile Management
- [ ] Allow users to update their `display_name` from a profile/settings page.
- [ ] Allow users to update their password only if they provide their current password, new password, and password confirmation.
- [ ] If a user attempts to change their email, display a prompt instructing them to contact the administrator (do not allow email changes in the UI).

## 10. Redirects
- [ ] Configure Devise to redirect users to the root page after login, logout, sign up, and password reset.

## 11. Testing
- [ ] Test the full authentication flow:
    - [ ] Sign up (with and without display_name).
    - [ ] Email confirmation (ensure user cannot log in before confirming).
    - [ ] Login/logout.
    - [ ] Forgot password/reset password.
    - [ ] Privacy policy modal and acceptance.
    - [ ] Profile updates (display_name, password).
    - [ ] Attempted email change (ensure prompt is shown).
- [ ] Test email delivery in development (letter_opener) and production (Google SMTP, if possible).
- [ ] Test responsiveness and appearance of all authentication views.

## 12. Deployment
- [ ] Ensure Google SMTP credentials are set in production environment variables.
- [ ] Ensure all migrations are run in production.
- [ ] Verify that the root route and authentication flows work as expected after deployment.

---

**Notes:**
- No associations between User and Note/Node/Folder models at this stage.
- No admin dashboard, social login, flash messages, or extra user fields.
- Registration is open to all; no rate limiting, invitation, or CAPTCHA.
- UI is minimal, English-only, and uses default Tailwind responsiveness.

---

**End of Checklist**