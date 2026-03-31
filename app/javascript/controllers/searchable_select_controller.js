// app/javascript/controllers/searchable_select_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "dropdown", "option", "hiddenField"]
  
  connect() {
    // Ocultar dropdown inicialmente
    this.hideDropdown()
    
    // Cerrar dropdown al hacer clic fuera
    document.addEventListener('click', this.handleOutsideClick.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick.bind(this))
  }
  
  search() {
    const query = this.searchInputTarget.value.toLowerCase()
    
    this.optionTargets.forEach(option => {
      const text = option.dataset.text.toLowerCase()
      
      if (text.includes(query)) {
        option.style.display = 'block'
      } else {
        option.style.display = 'none'
      }
    })
    
    this.showDropdown()
  }
  
  showDropdown() {
    this.dropdownTarget.classList.add('show')
  }
  
  hideDropdown() {
    this.dropdownTarget.classList.remove('show')
  }
  
  selectOption(event) {
    const selectedOption = event.currentTarget
    const value = selectedOption.dataset.value
    const text = selectedOption.dataset.text
    
    // Establecer valores
    this.hiddenFieldTarget.value = value
    this.searchInputTarget.value = text
    
    // Ocultar dropdown
    this.hideDropdown()
    
    // Marcar visualmente la opción seleccionada
    this.optionTargets.forEach(opt => opt.classList.remove('active'))
    selectedOption.classList.add('active')
  }
  
  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }
}