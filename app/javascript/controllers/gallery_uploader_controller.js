import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery-uploader"
//
// Lets the user pick photos across multiple selections (each pick adds to
// the existing batch instead of replacing it), preview them, edit an
// optional description per photo, choose one as the cover, and remove any
// individual photo before submitting.
//
// Since a native <input type="file"> always replaces its FileList on every
// selection, we keep our own in-memory list of picked files and rebuild the
// input's FileList (via DataTransfer) on every change so the form still
// submits a single, cumulative photo_gallery[images][] array.
export default class extends Controller {
  static targets = ["input", "list", "emptyState"]
  static values = { max: { type: Number, default: 25 } }

  connect() {
    this.items = [] // [{ file, description, url }]
  }

  pick(event) {
    const selected = Array.from(event.target.files || [])
    event.target.value = "" // always clear so the same file can be re-picked and future picks stay additive

    if (selected.length === 0) return

    const availableSlots = this.maxValue - this.items.length

    if (availableSlots <= 0) {
      alert(`You can upload up to ${this.maxValue} photos at a time.`)
      return
    }

    const toAdd = selected.slice(0, availableSlots)
    if (selected.length > toAdd.length) {
      alert(`You can upload up to ${this.maxValue} photos at a time. Only the first ${toAdd.length} of your new selection were added.`)
    }

    toAdd.forEach((file) => {
      this.items.push({ file, description: "", url: URL.createObjectURL(file) })
    })

    if (!this.items.some((item) => item.cover)) {
      this.items[0].cover = true
    }

    this.syncInputFiles()
    this.render()
  }

  updateDescription(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    if (this.items[index]) this.items[index].description = event.currentTarget.value
  }

  selectCover(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    this.items.forEach((item, i) => (item.cover = i === index))
  }

  remove(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    const [removed] = this.items.splice(index, 1)
    if (removed) URL.revokeObjectURL(removed.url)

    if (removed?.cover && this.items.length > 0) {
      this.items[0].cover = true
    }

    this.syncInputFiles()
    this.render()
  }

  // Rebuilds the actual <input type="file"> FileList from our in-memory
  // items so the form submits every accumulated photo, in order.
  syncInputFiles() {
    const dataTransfer = new DataTransfer()
    this.items.forEach((item) => dataTransfer.items.add(item.file))
    this.inputTarget.files = dataTransfer.files
  }

  render() {
    this.listTarget.innerHTML = ""

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.toggle("hidden", this.items.length > 0)
    }

    this.items.forEach((item, index) => {
      const row = document.createElement("div")
      row.className = "flex items-center gap-3 border border-gray-200 rounded-md p-2"

      const img = document.createElement("img")
      img.src = item.url
      img.className = "w-16 h-16 object-cover rounded-md flex-shrink-0"
      row.appendChild(img)

      const fields = document.createElement("div")
      fields.className = "flex-grow"

      const nameEl = document.createElement("p")
      nameEl.className = "text-sm text-gray-600 mb-1"
      nameEl.textContent = item.file.name
      fields.appendChild(nameEl)

      const descInput = document.createElement("input")
      descInput.type = "text"
      descInput.name = "photo_gallery[image_descriptions][]"
      descInput.placeholder = "Description (optional)"
      descInput.value = item.description
      descInput.className = "block w-full text-sm shadow-sm rounded-md border border-gray-300 px-2 py-1"
      descInput.dataset.index = index
      descInput.dataset.action = "input->gallery-uploader#updateDescription"
      fields.appendChild(descInput)

      row.appendChild(fields)

      const coverLabel = document.createElement("label")
      coverLabel.className = "flex items-center gap-1 text-sm flex-shrink-0"
      const coverRadio = document.createElement("input")
      coverRadio.type = "radio"
      coverRadio.name = "photo_gallery[cover_selection]"
      coverRadio.value = `new:${index}`
      coverRadio.checked = !!item.cover
      coverRadio.dataset.index = index
      coverRadio.dataset.action = "change->gallery-uploader#selectCover"
      coverLabel.appendChild(coverRadio)
      coverLabel.appendChild(document.createTextNode("Cover"))
      row.appendChild(coverLabel)

      const removeButton = document.createElement("button")
      removeButton.type = "button"
      removeButton.textContent = "Remove"
      removeButton.className = "flex-shrink-0 text-sm text-red-600 hover:underline cursor-pointer"
      removeButton.dataset.index = index
      removeButton.dataset.action = "click->gallery-uploader#remove"
      row.appendChild(removeButton)

      this.listTarget.appendChild(row)
    })
  }
}
