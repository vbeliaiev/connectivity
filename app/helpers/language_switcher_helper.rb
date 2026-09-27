# Helpers backing `layouts/_language_switcher.html.erb`.
#
# The switcher is driven entirely by `I18n.available_locales`, so adding a
# new language only requires:
#   1. adding the locale to `config.i18n.available_locales`
#      (config/application.rb; the route constraint picks it up automatically),
#   2. adding `layouts.language_switcher.<locale>` (the language's own name)
#      to every locale file,
#   3. dropping a flag at `app/assets/images/flags/<locale>.svg`.
module LanguageSwitcherHelper
  # Human-readable name of a locale, written in that language (e.g. "Français").
  def language_name(locale)
    t("layouts.language_switcher.#{locale}")
  end

  # Flag image for a locale. Decorative: the language name is always rendered
  # next to it, so the image is hidden from assistive technologies.
  def language_flag_tag(locale, extra_class: "")
    image_tag "flags/#{locale}.svg",
              alt: "",
              aria: { hidden: true },
              class: "h-3 w-[18px] flex-shrink-0 rounded-sm object-cover ring-1 ring-gray-200 #{extra_class}"
  end

  # Path to the current page in `locale`, preserving controller, action,
  # resource id and query string. The default locale is rendered unprefixed.
  #
  # Only routing params go through `url_for` (with `only_path: true`); the
  # query string is appended separately. Passing raw request params to
  # `url_for` would let `?host=...` / `?protocol=...` rewrite the link target.
  def switch_locale_path(locale)
    locale = locale.to_sym
    path = url_for(
      request.path_parameters.merge(
        locale: (locale == I18n.default_locale ? nil : locale),
        only_path: true
      )
    )
    query = request.query_parameters.except("locale").to_query
    query.present? ? "#{path}?#{query}" : path
  end
end
