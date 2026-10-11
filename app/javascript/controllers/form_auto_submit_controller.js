import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-auto-submit"
//
// Submits the surrounding form as soon as the field changes, so dropdowns
// like the catalog sort order apply immediately instead of waiting for the
// user to find the "Search" button. Without JS the field still round-trips
// with the form on the next regular submit.
export default class extends Controller {
  submit() {
    const form = this.element.form || this.element.closest("form")
    if (!form) return

    // requestSubmit() (unlike submit()) runs validation and fires the submit
    // event, which keeps Turbo in charge of the navigation.
    form.requestSubmit()
  }
}
