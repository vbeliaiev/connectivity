class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  # Mailers don't run within a request cycle, so `I18n.locale` reflects
  # whatever the background job/console/current thread last set it to
  # rather than a specific visitor's locale. Path/URL helpers called from
  # mailer views merge this hash into their generated URL options; without
  # an explicit `locale:` key here, a bare `folder_url(folder)` call binds
  # the model positionally to the route's first dynamic segment (`:locale`,
  # per `config/routes.rb`'s `scope "(:locale)"`) instead of `:id` and
  # raises `ActionController::UrlGenerationError`. Defaulting to `nil`
  # (the `fr` default locale) keeps mailer links safe out of the box;
  # a specific mailer can still override this per-email (e.g. to honor a
  # user's saved locale preference) by merging `locale:` into its own
  # `default_url_options` or passing `locale:` explicitly to a helper call.
  def default_url_options
    super.merge(locale: nil)
  end
end
