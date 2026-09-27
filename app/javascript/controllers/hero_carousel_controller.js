import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hero-carousel"
//
// Cross-fades through a stack of full-bleed slides absolutely positioned
// on top of each other. Loops in both directions and auto-advances on a
// timer, which pauses while the pointer is over the carousel.
export default class extends Controller {
  static targets = ["slide", "dot"]
  static values = { interval: { type: Number, default: 6000 } }

  connect() {
    this.index = 0
    this.startAutoplay()
  }

  disconnect() {
    this.stopAutoplay()
  }

  startAutoplay() {
    if (this.slideTargets.length < 2) return
    this.timer = setInterval(() => this.next(), this.intervalValue)
  }

  stopAutoplay() {
    clearInterval(this.timer)
  }

  pause() {
    this.stopAutoplay()
  }

  resume() {
    this.startAutoplay()
  }

  prev() {
    this.goTo((this.index - 1 + this.slideTargets.length) % this.slideTargets.length)
  }

  next() {
    this.goTo((this.index + 1) % this.slideTargets.length)
  }

  select(event) {
    this.goTo(parseInt(event.currentTarget.dataset.index, 10))
  }

  goTo(index) {
    this.index = index

    this.slideTargets.forEach((slide, slideIndex) => {
      slide.classList.toggle("opacity-0", slideIndex !== index)
    })

    this.dotTargets.forEach((dot, dotIndex) => {
      dot.classList.toggle("bg-white", dotIndex === index)
      dot.classList.toggle("bg-white/50", dotIndex !== index)
    })
  }
}
