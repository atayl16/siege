// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

// Initialize Bootstrap tooltips and popovers
document.addEventListener("turbo:load", () => {
  // Enable tooltips everywhere
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })

  // Initialize all modals
  document.querySelectorAll('[data-bs-toggle="modal"]').forEach(button => {
    button.addEventListener('click', () => {
      const target = button.getAttribute('data-bs-target')
      const modalElement = document.querySelector(target)
      if (modalElement) {
        const modal = new bootstrap.Modal(modalElement)
        modal.show()
      }
    })
  })
})

// Make bootstrap globally available
window.bootstrap = bootstrap
