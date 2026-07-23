import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nav-select"
//
// Navigates to the selected option's value (a URL) when the user picks an
// option from a plain <select>, used for "New..." style link pickers.
export default class extends Controller {
  connect() {
    // Browsers restore the previously selected <option> when navigating
    // back/forward (form state restoration / bfcache), which makes the
    // dropdown look "stuck" on the last choice even though nothing was
    // picked this time. Reset it every time the controller connects.
    this.element.value = ""
  }

  go(event) {
    const url = event.target.value
    if (url) Turbo.visit(url)
  }
}
