import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="option-picker"
//
// Lets the user switch a field between picking an existing option from a
// <select> and typing a brand new value to be created on save. Used for
// fields backed by a user-extensible list (brands, countries, ...).
export default class extends Controller {
  static targets = ["select", "newField", "toggleButton"]
  static values = {
    addLabel: String,
    chooseLabel: String
  }

  connect() {
    this.newFieldTarget.classList.add("hidden")
  }

  toggle() {
    const addingNewValue = !this.newFieldTarget.classList.contains("hidden")

    if (addingNewValue) {
      this.newFieldTarget.classList.add("hidden")
      this.newFieldInput.value = ""
      this.selectTarget.classList.remove("hidden")
      this.toggleButtonTarget.textContent = this.addLabelValue
    } else {
      this.selectTarget.classList.add("hidden")
      this.selectTarget.value = ""
      this.newFieldTarget.classList.remove("hidden")
      this.newFieldInput.focus()
      this.toggleButtonTarget.textContent = this.chooseLabelValue
    }
  }

  get newFieldInput() {
    return this.newFieldTarget.querySelector("input")
  }
}
