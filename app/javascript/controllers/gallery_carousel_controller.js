import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery-carousel"
//
// Renders a single "current" photo + description, a strip of clickable
// thumbnails, and previous/next navigation. Supports left/right arrow
// keys. Stops at the first/last item (no wrap-around). Keeps the current
// item id in the URL (via pushState) so the page can be shared/linked
// directly to a specific photo.
export default class extends Controller {
  static targets = ["image", "description", "thumbnail", "prev", "next"]
  static values = {
    items: Array, // [{ id, url, thumbUrl, description }]
    currentId: Number,
    baseUrl: String
  }

  connect() {
    this.boundKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
    this.renderCurrent()
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
  }

  get currentIndex() {
    return this.itemsValue.findIndex((item) => item.id === this.currentIdValue)
  }

  handleKeydown(event) {
    if (event.key === "ArrowLeft") this.prev()
    if (event.key === "ArrowRight") this.next()
  }

  prev() {
    const index = this.currentIndex
    if (index > 0) this.goTo(index - 1)
  }

  next() {
    const index = this.currentIndex
    if (index < this.itemsValue.length - 1) this.goTo(index + 1)
  }

  select(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    this.goTo(index)
  }

  goTo(index) {
    const item = this.itemsValue[index]
    if (!item) return

    this.currentIdValue = item.id
    this.renderCurrent()

    const url = `${this.baseUrlValue}?item_id=${item.id}`
    history.pushState({}, "", url)
  }

  renderCurrent() {
    const index = this.currentIndex
    const item = this.itemsValue[index]
    if (!item) return

    this.imageTarget.setAttribute("src", item.url)
    this.descriptionTarget.textContent = item.description || ""
    this.descriptionTarget.classList.toggle("hidden", !item.description)

    this.thumbnailTargets.forEach((thumb, thumbIndex) => {
      thumb.classList.toggle("ring-2", thumbIndex === index)
      thumb.classList.toggle("ring-blue-600", thumbIndex === index)
    })

    if (this.hasPrevTarget) this.prevTarget.disabled = index === 0
    if (this.hasNextTarget) this.nextTarget.disabled = index === this.itemsValue.length - 1
  }
}
