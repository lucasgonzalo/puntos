import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["navItem", "subNavItem"];
  static values = {
    currentPath: String,
    activeClass: { type: String, default: "active" },
    collapsedState: { type: String, default: "active" }
  };

  connect() {
    this.restoreSidebarState();
    this.updateActiveStates();
    this.setupTurboListeners();
    this.setupThemeListeners();
    this.setupCollapseListeners();
  }

  disconnect() {
    this.removeTurboListeners();
    this.removeCollapseListeners();
  }

  // Sidebar state management
  restoreSidebarState() {
    const savedState = localStorage.getItem('sidebarState');
    const isMobile = window.innerWidth <= 768;
    
    if (isMobile) {
      this.setSidebarState('collapsed');
    } else if (savedState) {
      this.setSidebarState(savedState);
    } else {
      this.setSidebarState('active');
    }
  }

  setSidebarState(state) {
    const sidebar = document.getElementById('sidebarId');
    
    // Remove existing classes
    sidebar.classList.remove('active', 'collapsed');
    
    // Add new state class
    sidebar.classList.add(state);
    
    // Save to localStorage
    localStorage.setItem('sidebarState', state);
    
    // Update controller value
    this.collapsedStateValue = state;
  }

  // Make method accessible from external JavaScript
  toggleSidebar() {
    const currentState = this.collapsedStateValue;
    const newState = currentState === 'active' ? 'collapsed' : 'active';
    this.setSidebarState(newState);
  }

  // Active state management
  updateActiveStates() {
    const currentPath = window.location.pathname;
    this.setActiveStates(currentPath);
  }

  setActiveStates(path) {
    // First process sub-items to detect which ones are active
    const activeSubItems = [];
    
    this.subNavItemTargets.forEach(item => {
      this.updateItemState(item, path);
      if (this.isCurrentPage(item.getAttribute('href'), path)) {
        activeSubItems.push(item);
      }
    });
    
    // Then process main items and activate parents of active sub-items
    this.navItemTargets.forEach(item => {
      this.updateItemState(item, path);
      
      // If this item has active sub-items, activate it too
      if (this.hasActiveSubItems(item, activeSubItems)) {
        item.classList.add(this.activeClassValue);
        this.expandParentMenu(item);
      }
    });
  }

  updateItemState(item, currentPath) {
    const href = item.getAttribute('href');
    if (this.isCurrentPage(href, currentPath)) {
      item.classList.add(this.activeClassValue);
    } else {
      item.classList.remove(this.activeClassValue);
    }
  }


  isCurrentPage(href, currentPath) {
    const basePath = href.split('?')[0];

    // Exact match always works
    if (basePath === currentPath) return true;

    // Only allow parent-child matching for collapse menu items (href startswith #)
    if (href.startsWith('#')) {
      return basePath !== '/' && currentPath.startsWith(basePath);
    }

    // For all other links, require exact match
    return false;
  }


  // Enhanced Turbo navigation support
  setupTurboListeners() {
    this.turboVisitHandler = this.handleTurboVisit.bind(this);
    this.turboLoadHandler = this.handleTurboLoad.bind(this);
    
    document.addEventListener('turbo:visit', this.turboVisitHandler);
    document.addEventListener('turbo:load', this.turboLoadHandler);
  }

  removeTurboListeners() {
    document.removeEventListener('turbo:visit', this.turboVisitHandler);
    document.removeEventListener('turbo:load', this.turboLoadHandler);
  }

  handleTurboVisit() {
    // Preserve sidebar state during navigation
    requestAnimationFrame(() => {
      this.restoreSidebarState();
      this.updateActiveStates();
    });
  }

  handleTurboLoad() {
    // Ensure sidebar state and active states are correct after page loads
    this.restoreSidebarState();
    this.updateActiveStates();
    this.expandActiveParents();
  }

  // Bootstrap collapse integration
  setupCollapseListeners() {
    this.collapseShowHandler = this.handleCollapseShow.bind(this);
    this.collapseHideHandler = this.handleCollapseHide.bind(this);
    
    // Listen for Bootstrap collapse events
    document.addEventListener('show.bs.collapse', this.collapseShowHandler);
    document.addEventListener('hide.bs.collapse', this.collapseHideHandler);
  }

  removeCollapseListeners() {
    document.removeEventListener('show.bs.collapse', this.collapseShowHandler);
    document.removeEventListener('hide.bs.collapse', this.collapseHideHandler);
  }

  handleCollapseShow(event) {
    // Add visual feedback for expanded state
    const targetId = event.target.id;
    const trigger = document.querySelector(`[data-bs-target="#${targetId}"], [href="#${targetId}"]`);
    
    if (trigger) {
      trigger.classList.add('expanded');
    }
  }

  handleCollapseHide(event) {
    // Remove visual feedback for collapsed state
    const targetId = event.target.id;
    const trigger = document.querySelector(`[data-bs-target="#${targetId}"], [href="#${targetId}"]`);
    
    if (trigger) {
      trigger.classList.remove('expanded');
    }
  }

  // Theme integration
  setupThemeListeners() {
    // Listen for theme changes via custom event
    document.addEventListener('theme:changed', () => {
      // Force re-render of active states to apply theme-specific shadows
      this.updateActiveStates();
    });
  }

  // Check if a parent menu item has active sub-items
  hasActiveSubItems(parentItem, activeSubItems) {
    const parentHref = parentItem.getAttribute('href');
    const parentCollapseId = parentItem.getAttribute('href')?.replace('#', '');
    
    if (!parentCollapseId) return false;
    
    const collapseElement = document.getElementById(parentCollapseId);
    if (!collapseElement) return false;
    
    // Find sub-items within this collapse container
    const subItemsInContainer = collapseElement.querySelectorAll('[data-sidebar-navigation-target="subNavItem"]');
    
    return Array.from(subItemsInContainer).some(subItem => 
      activeSubItems.includes(subItem)
    );
  }

  // Expand parent menu automatically
  expandParentMenu(parentItem) {
    const collapseId = parentItem.getAttribute('href')?.replace('#', '');
    if (!collapseId) return;
    
    const collapseElement = document.getElementById(collapseId);
    if (!collapseElement) return;
    
    // Use Bootstrap API to expand
    const bsCollapse = new bootstrap.Collapse(collapseElement, {
      toggle: false
    });
    bsCollapse.show();
    
    // Update visual state
    parentItem.classList.add('expanded');
    parentItem.setAttribute('aria-expanded', 'true');
  }

  // Find parent menu item for a sub-item
  findParentMenuItem(subItem) {
    // Search up in DOM to find collapse container
    const collapseContainer = subItem.closest('.collapse');
    if (!collapseContainer) return null;
    
    // Find the trigger that controls this collapse
    const collapseId = collapseContainer.id;
    const parentTrigger = document.querySelector(`[href="#${collapseId}"], [data-bs-target="#${collapseId}"]`);
    
    return parentTrigger;
  }

  // Expand active parents when page loads
  expandActiveParents() {
    // Find all active sub-items and expand their parents
    this.subNavItemTargets.forEach(subItem => {
      if (subItem.classList.contains(this.activeClassValue)) {
        const parentItem = this.findParentMenuItem(subItem);
        if (parentItem) {
          parentItem.classList.add(this.activeClassValue);
          this.expandParentMenu(parentItem);
        }
      }
    });
  }
}


// ToDo:
// The issue is that when you're on /movements/new, the
// currentPath.startsWith(basePath) condition returns true for /movements
// because /movements/new starts with /movements. This causes both the "Lista
// de Movimientos" link and the parent "Movimientos" menu to be marked as
// active.

// The problem is in
// app/javascript/controllers/sidebar_navigation_controller.js:103 where the
// startsWith logic is too broad. It should be more precise to avoid matching
// parent routes when a child route is active.