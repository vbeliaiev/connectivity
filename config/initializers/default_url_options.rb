# Ensures every path/URL helper defaults the `:locale` segment to `nil`
# (i.e. the unprefixed `fr` default) even when there is no active request to
# supply one — this covers `ActionDispatch::Integration::Session` (RSpec
# request/integration specs building a URL to hit *before* any request has
# been dispatched, and the `app.*_path` console/test helper), rake tasks,
# and any other caller that ultimately reaches
# `ActionDispatch::Routing::RouteSet#url_for`.
#
# Without this, a bare call like `folder_path(folder)` in one of those
# contexts has no `locale:` key merged into its options at all, so Rails
# falls back to positional-argument binding and assigns the `folder` object
# to the *first* dynamic segment in the route — which is `:locale` now that
# routes are wrapped in `scope "(:locale)", locale: /en/` — instead of
# `:id`, raising `ActionController::UrlGenerationError`.
#
# `ApplicationController#default_url_options` (see app/controllers/
# application_controller.rb) still takes priority over this default during
# a real request: `RouteSet#url_for` merges
# `Rails.application.routes.default_url_options` underneath the per-request
# options, so an explicit `locale: "en"` (or `nil`) from the controller
# override always wins over this global fallback.
#
# NOTE: this does NOT cover mailer views or any other class that does a
# bare `include Rails.application.routes.url_helpers` outside of
# ActionController/Integration::Session — those consult their *own*
# `default_url_options` class attribute for positional-argument route
# helper calls, not this route-set-level default. See
# `ApplicationMailer#default_url_options` for the mailer-specific fix.
Rails.application.routes.default_url_options[:locale] = nil
