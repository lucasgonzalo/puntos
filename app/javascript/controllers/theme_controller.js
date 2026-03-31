import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toggle"];
  static values = {
    current: { type: String, default: "light" }
  };

  connect() {
    const forcedTheme = this.element.getAttribute('data-theme-force-theme');
    
    if (forcedTheme) {
      // Apply forced theme without saving
      this.applyForcedTheme(forcedTheme);
    } else {
      this.loadTheme();
    }
    
    this.updateToggleIcon();
    
    // Restore original theme when navigating away
    document.addEventListener('turbo:before-visit', () => this.restoreOriginalTheme());
  }

  toggle() {
    const currentTheme = this.getCurrentTheme();
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    
    this.setTheme(newTheme);
    this.saveTheme(newTheme);
    this.updateToggleIcon();
    this.emitThemeChanged(newTheme);
  }

  getCurrentTheme() {
    return document.documentElement.getAttribute('data-theme') || 
           document.documentElement.getAttribute('data-bs-theme') || 'light';
  }

  setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    document.documentElement.setAttribute('data-bs-theme', theme);
    this.currentValue = theme;
    this.emitThemeChanged(theme);
  }

  saveTheme(theme) {
    localStorage.setItem('theme', theme);
  }

  loadTheme() {
    const savedTheme = localStorage.getItem('theme');
    const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    const theme = savedTheme || systemTheme;
    
    this.setTheme(theme);
  }

  updateToggleIcon() {
    if (this.hasToggleTarget) {
      const currentTheme = this.getCurrentTheme();
      const icon = currentTheme === 'light' ? 'mdi mdi-weather-night' : 'mdi mdi-weather-sunny';
      
      // Update the existing icon class instead of replacing content
      const iconElement = this.toggleTarget.querySelector('i');
      if (iconElement) {
        iconElement.className = `${icon}`;
      }
    }
  }

  emitThemeChanged(theme) {
    // Emit custom event for other controllers to listen
    const event = new CustomEvent('theme:changed', {
      detail: { theme },
      bubbles: true
    });
    document.dispatchEvent(event);
  }

  // Listen for system theme changes
  handleSystemThemeChange(event) {
    if (!localStorage.getItem('theme')) {
      const systemTheme = event.matches ? 'dark' : 'light';
      this.setTheme(systemTheme);
      this.updateToggleIcon();
    }
  }

  applyForcedTheme(theme) {
    // Store current theme before forcing
    this.originalThemeValue = this.getCurrentTheme();
    this.setTheme(theme);
  }
  
  restoreOriginalTheme() {
    if (this.originalThemeValue) {
      this.setTheme(this.originalThemeValue);
      this.originalThemeValue = null;
    }
  }
}

  // Set up system theme listener
  const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
  mediaQuery.addListener((event) => {
    const controller = document.querySelector('[data-controller~="theme"]')?.application?.getControllerForElementAndIdentifier(document.querySelector('[data-controller~="theme"]'), 'theme');
    if (controller) {
      controller.handleSystemThemeChange(event);
    }
});

