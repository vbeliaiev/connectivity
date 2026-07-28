module UsersHelper
  ROLE_LABELS = {
    "member" => "Membre",
    "moderator" => "Modérateur",
    "admin" => "Administrateur"
  }.freeze

  def role_label(role)
    ROLE_LABELS.fetch(role.to_s, role.to_s.capitalize)
  end
end
