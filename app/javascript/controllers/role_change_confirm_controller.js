import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="role-change-confirm"
//
// Asks for an explicit confirmation before submitting the user edit form
// when the selected role differs from the role the user had when the page
// loaded, to avoid accidentally granting/revoking admin or moderator
// permissions with a stray click.
export default class extends Controller {
  static targets = ["role"]
  static values = { original: String }

  submit(event) {
    if (this.roleTarget.value === this.originalValue) return

    const confirmed = window.confirm(
      "Vous êtes sur le point de changer le rôle de cet adhérent. Confirmer ce changement ?"
    )
    if (!confirmed) event.preventDefault()
  }
}
