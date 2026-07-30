import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="department-filter"
//
// Scopes the department picker to the currently selected brand: a
// department always belongs to a brand, so only options tagged with the
// selected brand's id (via a data-brand-id attribute on each <option>)
// stay selectable, and the department select is disabled while no brand
// is chosen. Used both in the catalog item form (where the department
// select is paired with an option-picker "add new" toggle + text field)
// and in the catalog filters sidebar (plain select, no toggle/new field).
export default class extends Controller {
  static targets = ["brandSelect", "departmentSelect", "toggleButton", "newInput"]

  connect() {
    if (this.hasToggleButtonTarget) this.defaultToggleLabel = this.toggleButtonTarget.textContent
    this.filterOptions()
  }

  filterOptions() {
    const brandId = this.brandSelectTarget.value
    let selectionStillValid = false

    Array.from(this.departmentSelectTarget.options).forEach((option) => {
      if (!option.value) return // keep the blank "prompt" option as-is

      const matchesBrand = option.dataset.brandId === brandId
      option.hidden = !matchesBrand
      option.disabled = !matchesBrand

      if (matchesBrand && option.selected) selectionStillValid = true
    })

    if (!selectionStillValid) this.departmentSelectTarget.value = ""

    this.setDisabled(!brandId)
  }

  setDisabled(disabled) {
    this.departmentSelectTarget.disabled = disabled
    if (this.hasToggleButtonTarget) this.toggleButtonTarget.disabled = disabled
    if (this.hasNewInputTarget) this.newInputTarget.disabled = disabled

    if (disabled) this.resetToSelectMode()
  }

  // If the brand is cleared while the "add a new department" text field
  // is showing, fall back to the plain select so the disabled state reads
  // clearly instead of leaving a disabled, emptied text field visible.
  resetToSelectMode() {
    if (!this.hasNewInputTarget || !this.hasToggleButtonTarget) return

    this.newInputTarget.value = ""
    this.toggleButtonTarget.textContent = this.defaultToggleLabel

    const newFieldWrapper = this.newInputTarget.closest("[data-option-picker-target='newField']")
    if (newFieldWrapper && !newFieldWrapper.classList.contains("hidden")) {
      newFieldWrapper.classList.add("hidden")
      this.departmentSelectTarget.classList.remove("hidden")
    }
  }
}
