# Implementation Plan: Organisations Feature

## 1. Overview & Goals

The goal of this feature is to introduce a multi-tenant "Organisation" entity. Users will be able to create, join, and switch between organisations. All primary resources, like `Folders` and `Notes`, will be scoped to the user's currently active organisation. This will allow for collaboration and content segregation within the application.

This document outlines the step-by-step implementation plan.

---

## 2. Developer Checklist

### Phase 1: Database Schema & Migrations

- [x] **Task 1.1: Create `Organisation` Model File and Migration**
  - [x] Run migration: `rails g model Organisation name:string`
  - [x] Modify migration to add `null: false` and a unique index on `name`.

- [x] **Task 1.2: Create `OrganisationsUser` Model File and Migration**
  - [x] Run migration: `rails g model OrganisationsUser user:references organisation:references role:integer`
  - [x] Modify migration to add `null: false`, a default `role`, and a unique index on `[:user_id, :organisation_id]`.

- [x] **Task 1.3: Create Migration to Update `User` Model**
  - [x] Run migration: `rails g migration AddCurrentOrganisationToUsers current_organisation:references`

- [x] **Task 1.4: Create Migrations to Update `Folder` and `Note` Models**
  - [x] Run migrations to add `organisation:references` and `visibility:integer` to `nodes` (STI parent of folders and notes).
  - [x] Add `null: false` constraints and a default `visibility` to migrations.
  - [ ] ~~Create a data migration to backfill the `organisation_id` for all existing folders and notes.~~ (skipped)
        - **Logic**: Find the user with email `vladislav.belyaev.93@gmail.com`.
        - Ensure this user has a personal organisation.
        - Update all existing `Folders` and `Notes` to belong to this specific user's personal organisation.

- [ ] **Task 1.5: Run Migrations**
  - [ ] Run `rails db:migrate`.

---

### Phase 2: Backend Logic, Policies & Tests
*Note: For model tests, prefer using `shoulda-matchers`. When you add/update logic for a model or policy, add/update the related test at the same time.*

- [x] **Task 2.1: `Organisation` Model Logic & Tests**
  - [x] In `app/models/organisation.rb`, add associations and validations.
  - [x] **Tests (`spec/models/organisation_spec.rb`):** Test validations and associations (use `shoulda-matchers` for validations and associations).

- [x] **Task 2.2: `OrganisationsUser` Model Logic & Tests**
  - [x] In `app/models/organisations_user.rb`, add associations and the `role` enum.
  - [x] **Tests (`spec/models/organisations_user_spec.rb`):** Test associations, enum, and validations (use `shoulda-matchers` for associations, validations, and enums).

- [x] **Task 2.3: `User` Model Logic & Tests**
  - [x] In `app/models/user.rb`, add associations and the `after_create` callback.
  - [x] **Tests (`spec/models/user_spec.rb`):** Test associations (use `shoulda-matchers` for associations) and the callback.

- [x] **Task 2.4: `Folder` & `Note` Model Logic & Tests**
  - [x] In `app/models/folder.rb` and `app/models/note.rb`, add associations and the `visibility` enum.
  - [x] **Tests (`spec/models/folder_spec.rb`, `spec/models/note_spec.rb`):** Test the association and enum (use `shoulda-matchers` for associations and enums).

- [ ] **Task 2.5: Pundit Policies & Tests**
  - [ ] Generate policies: `rails g pundit:policy organisation`, `folder`, `note`.
  - [ ] **`ApplicationPolicy`:** Modify the `Scope` to filter by `current_organisation_id`.
      - **Test:** Verify the scope correctly filters records.
  - [ ] **`FolderPolicy` & `NotePolicy`:** Implement role-based permissions and public access.
      - **Test:** Verify all permissions for each role and for public visibility.
  - [ ] **`OrganisationPolicy`:** Implement logic for managing the organisation and its members, and add a `switch?` action.
      - **Test:** Verify permissions for all organisation-related actions. The `switch?` policy should only allow members of the organisation to switch to it.

- [ ] **Task 2.6: Controllers & Routes**
  - [ ] Generate `OrganisationsController` and `OrganisationsUsersController`.
  - [ ] Define routes for organisations and nested routes for members, including a `POST /organisations/:id/switch` route.
  - [ ] Implement `OrganisationsController`, including the `switch` action:
        - Find the `Organisation`.
        - Authorize the action against the policy: `authorize @organisation, :switch?`.
        - If authorized, update `current_user.update!(current_organisation: @organisation)`.
        - Redirect to `root_path` with a success notice.
  - [ ] Implement `OrganisationsUsersController` to manage members.
  - [ ] In `FoldersController` & `NotesController`, use `policy_scope` and assign `current_organisation`.
        - **Important:** Ensure all queries and actions are always scoped by the current organisation. Review all controller actions to confirm this.

- [ ] **Task 2.8: Update `Note.semantic_search` Method & Usage**
  - [ ] Refactor `Note.semantic_search` to accept a `scope:` argument, so the method signature is:
        `Note.semantic_search(scope:, query_embedding:, top:)`
  - [ ] Update all usages in controllers to pass a scope of notes that are already scoped by organisation (e.g., `current_organisation.notes`).
  - [ ] Test that semantic search only returns notes from the current organisation.

---

### Phase 3: Frontend (UI/UX)

- [ ] **Task 3.1: Create Organisation Switcher**
  - [ ] Add a dropdown to the main layout to switch between organisations.

- [ ] **Task 3.2: Create Organisation Management Views**
  - [ ] Create CRUD views for `organisations`.
  - [ ] The `show` view should list members and include forms for invitations and role changes.

- [ ] **Task 3.3: Implement Warnings & Prompts**
  - [ ] Add JavaScript confirmation for making a folder public.
  - [ ] Add a `data-confirm` prompt for leaving an organisation and handle the content retention/deletion flow.

---

### Phase 4: Integration Testing (RSpec)

- [ ] **Task 4.1: Request (Integration) Tests**
  - [ ] Test the full user flow: creating, switching, and updating organisations.
  - [ ] Test inviting, updating, and removing members via the `OrganisationsUsersController`.
  - [ ] Test that content is correctly scoped after switching organisations.
  - [ ] Test leaving an organisation and the content deletion/retention logic.