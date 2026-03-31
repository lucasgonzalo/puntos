//import { Controller } from "stimulus"
import { Controller } from "@hotwired/stimulus";

//import axios from "axios";

export default class extends Controller {

  // Updated targets for multi-product selection functionality
  static targets = [ 
    "searchInput", "card", 'defaultCatalogId',
    'catalogContent', 'selectedProductsArray', 'selectedProductsDisplay',  // Renamed from singular to plural
    'submitExchangeForm', 'totalPointsDisplay',  // New target for showing total points required
    'customerAvailablePoints', 'errorFeedbackPoints', 'branchValue', // New for show validation points
    'totalMoneySection', 'totalMoneyDisplay'
  ]

  connect() {
    // Initialize multi-product selection array with quantity support
    // Array structure: [{product_id: 45, quantity: 1}, {product_id: 47, quantity: 2}]
    this.selectedProducts = [];
    
    // Initialize product filter,filtro busqueda de productos en canje-producto
    if (this.hasSearchInputTarget) { this.filter();}
    if (this.hasCardTarget) { this.updateSelectedIds();} // Initialize selected IDs based on active cards
    if (this.hasSubmitExchangeFormTarget) {  this.updateSubmitButtonState();}

    // Para cargar el catalogo?
    const catalogId = this.defaultCatalogIdTarget.dataset.catalogId;
    this.catalogContentTarget.src = `/movements/catalog_content?catalog_id=${catalogId}`;
  }

  // Filter products based on search input
  filter() {
      const query = this.searchInputTarget.value.toLowerCase();
      // console.log(query)
      this.cardTargets.forEach(card => {
        // console.log(`card: ${card.dataset.name}`)
        card.style.display = (query === "" || card.dataset.name.toLowerCase().includes(query)) ? "" : "none";
    });
  }

  // Updated toggleSelect for multi-product selection with quantity support
  toggleSelect(event) {
    const card = event.currentTarget;
    const productId = card.dataset.id;

    // Check if the clicked card is already active (for deselection)
    if (card.classList.contains("active-product")) {
      // Remove from selection
      card.classList.remove("active-product");
      this.removeProduct(productId);
    } else {
      // Add to selection with quantity 1 (allow multiple selections)
      card.classList.add("active-product");
      this.addProduct(productId, 1);
    }

    // Update displays and form state
    this.updateAllDisplays();
  }

  // Updated for multi-product display with quantity support
  updateSelectedProductsDisplay() {
    if (this.selectedProducts.length === 0) {
      this.clearSelectedProductsDisplay();
      return;
    }

    // Generate HTML for all selected products
    let productsHtml = '<div class="row">';
    
    this.selectedProducts.forEach(item => {
      const card = this.cardTargets.find(c => c.dataset.id === item.product_id.toString());
      if (!card) return;

      // Extract product details from the card's data attributes
      const name = card.dataset.name;
      const imageUrl = card.dataset.image || "";
      const points = parseInt(card.dataset.points || 0);
      const price = card.dataset.priceFormatted || card.dataset.price || "";
      const description = card.querySelector(".small.text-muted")?.textContent || "";
      const productType = card.dataset.productType || "default";
      const quantity = item.quantity;
      const subtotalPoints = points * quantity;

      // Determine the product type text
      let productTypeText;
      switch (productType) {
        case "points":
          productTypeText = "CON PUNTOS";
          break;
        case "currency_points":
          productTypeText = "PUNTOS + DINERO";
          break;
        default:
          productTypeText = "No corresponde a un tipo correcto.";
      }

      // Generate HTML for individual product card with quantity controls and remove button
      productsHtml += `
        <div class="col-12 col-md-6 col-lg-4 mb-3">
          <div class="card h-100 position-relative">
            <div class="card-img-top position-relative" style="height: 120px; background: ${imageUrl ? `url('${imageUrl}') center/cover no-repeat` : '#e0e0e0'};">
              ${!imageUrl ? `<div class="d-flex align-items-center justify-content-center h-100 text-muted">Sin imagen</div>` : ""}
              <div class="position-absolute top-0 start-0">
                <span class="badge bg-info">${productTypeText}</span>
                <span class="badge bg-warning text-dark ms-1">x${quantity}</span>
              </div>
            </div>
            <div class="card-body">
              <h6 class="card-title text-primary">${name}</h6>
              <p class="card-text small text-muted">${description}</p>
              <div class="text-center mb-2">
                <span class="badge rounded-pill bg-info ">Puntos: ${points}</span>
                ${price ? `<span class="badge rounded-pill bg-secondary ">${price}</span>` : ""}
              </div>
              <div class="text-center">
                <span class="badge rounded-pill bg-success ">Subtotal: ${subtotalPoints} pts</span>
              </div>
              <!-- Quantity controls in selected products display -->
              <div class="quantity-controls d-flex align-items-center justify-content-center mt-2">
                <button type="button" class="btn btn-sm btn-outline-secondary" 
                        data-action="click->product-exchange-movements#decreaseQuantity"
                        data-product-id="${item.product_id}">-</button>
                <span class="mx-2 fw-bold">${quantity}</span>
                <button type="button" class="btn btn-sm btn-outline-secondary" 
                        data-action="click->product-exchange-movements#increaseQuantity"
                        data-product-id="${item.product_id}">+</button>
              </div>
            </div>
          </div>
        </div>
      `;
    });

    productsHtml += '</div>';
    this.selectedProductsDisplayTarget.innerHTML = productsHtml;
  }

  // Updated method name for multi-product functionality
  clearSelectedProductsDisplay() {
    this.selectedProductsDisplayTarget.innerHTML = `
      <div class="card p-2">
        <p class="text-muted">Ningún producto seleccionado</p>
      </div>
    `;
  }
  
  // Initialize selectedIds based on active cards (legacy method, updated for quantity support)
  updateSelectedIds() {
    // Clear current selection
    this.selectedProducts = [];
    
    // Build selected products array from active cards
    this.cardTargets.forEach(card => {
      if (card.classList.contains("active-product")) {
        const productId = card.dataset.id;
        const quantityDisplay = card.querySelector('.quantity-display');
        const quantity = quantityDisplay ? parseInt(quantityDisplay.textContent) || 1 : 1;
        
        this.selectedProducts.push({
          product_id: parseInt(productId),
          quantity: quantity
        });
      }
    });
    
    this.updateAllDisplays();
  }
  
  // Updated to handle multi-product array for form submission
  updateHiddenField() {
    if (this.hasSelectedProductsArrayTarget) {
      this.selectedProductsArrayTarget.value = JSON.stringify(this.selectedProducts);
    }
  }

  // Updated to check multi-product array instead of single selection
  updateSubmitButtonState() {
    const hasProducts = this.selectedProducts.length > 0;
    const hasBranch = this.branchValueTarget.value;
    const totalRequired = this.calculateTotalPoints();
    const availablePoints = parseInt(this.customerAvailablePointsTarget.value) || 0;
    const hasValidPoints = totalRequired <= availablePoints;

    this.submitExchangeFormTarget.disabled = !(hasProducts && hasValidPoints && hasBranch);

    if (hasValidPoints) {
      this.hidePointsError();
    } else {
      this.showPointsError();
    }
  }

  // Updated method: Calculate total points required for all selected products with quantities
  calculateTotalPoints() {
    return this.selectedProducts.reduce((total, item) => {
      const card = this.cardTargets.find(c => c.dataset.id === item.product_id.toString());
      const points = parseInt(card?.dataset.points || 0);
      return total + (points * item.quantity);
    }, 0);
  }

  // New method: Update the total points display
  updateTotalPointsDisplay() {
    if (this.hasTotalPointsDisplayTarget) {
      const totalPoints = this.calculateTotalPoints();
      this.totalPointsDisplayTarget.textContent = totalPoints.toLocaleString();
    }
  }

  // === QUANTITY MANAGEMENT METHODS ===
  
  // New method: Find product index in selected products array
  findProductIndex(productId) {
    return this.selectedProducts.findIndex(item => item.product_id.toString() === productId.toString());
  }

  // New method: Add product to selection with specified quantity
  addProduct(productId, quantity = 1) {
    const index = this.findProductIndex(productId);
    if (index !== -1) {
      this.selectedProducts[index].quantity += quantity;
    } else {
      this.selectedProducts.push({product_id: parseInt(productId), quantity: quantity});
    }
  }

  // New method: Remove product from selection
  removeProduct(productId) {
    this.selectedProducts = this.selectedProducts.filter(item => item.product_id.toString() !== productId.toString());
  }

  // New method: Get current quantity for a product
  getProductQuantity(productId) {
    const item = this.selectedProducts.find(item => item.product_id.toString() === productId.toString());
    return item ? item.quantity : 0;
  }

  // New method: Increase product quantity
  increaseQuantity(event) {
    event.stopPropagation(); // Prevent event from bubbling up to toggleSelect
    const productId = event.currentTarget.dataset.productId;
    this.addProduct(productId, 1);
    this.updateAllDisplays();
  }

  // New method: Decrease product quantity
  decreaseQuantity(event) {
    event.stopPropagation(); // Prevent event from bubbling up to toggleSelect
    const productId = event.currentTarget.dataset.productId;
    const index = this.findProductIndex(productId);
    
    if (index !== -1) {
      if (this.selectedProducts[index].quantity > 1) {
        this.selectedProducts[index].quantity -= 1;
      } else {
        // Remove product if quantity would be 0
        this.removeProduct(productId);
        // Update card visual state
        const card = this.cardTargets.find(c => c.dataset.id === productId.toString());
        if (card) {
          card.classList.remove("active-product");
        }
      }
    }
    
    this.updateAllDisplays();
  }

  // New method: Update all displays at once
  updateAllDisplays() {
    this.updateSelectedProductsDisplay();
    this.updateHiddenField();
    this.updateTotalPointsDisplay();
    this.updateTotalMoneyDisplay();
    this.updateQuantityDisplays();
    this.updateSubmitButtonState();
  }

  // New method: Update quantity displays in catalog
  updateQuantityDisplays() {
    this.cardTargets.forEach(card => {
      const productId = card.dataset.id;
      const quantity = this.getProductQuantity(productId);
      const quantityDisplay = card.querySelector('.quantity-display');
      
      if (quantityDisplay) {
        quantityDisplay.textContent = quantity;
      }
      
      // Update card visual state
      if (quantity > 0) {
        card.classList.add("active-product");
      } else {
        card.classList.remove("active-product");
      }
    });
  }

  showPointsError() {
    if (this.hasErrorFeedbackPointsTarget) {
      this.errorFeedbackPointsTarget.style.display = 'block';
    }
  }

  hidePointsError() {
    if (this.hasErrorFeedbackPointsTarget) {
      this.errorFeedbackPointsTarget.style.display = 'none';
    }
  }

  // New method: Calculate total money required for currency_points products only
  calculateTotalMoney() {
    return this.selectedProducts.reduce((total, item) => {
      const card = this.cardTargets.find(c => c.dataset.id === item.product_id.toString());
      const productType = card?.dataset.productType;
      const price = parseFloat(card?.dataset.price) || 0;
      
      // Only include money for currency_points products
      if (productType === "currency_points") {
        return total + (price * item.quantity);
      }
      return total;
    }, 0);
  }
  // New method: Check if any selected products are currency_points type
  hasCurrencyPointsSelected() {
    return this.selectedProducts.some(item => {
      const card = this.cardTargets.find(c => c.dataset.id === item.product_id.toString());
      return card?.dataset.productType === "currency_points";
    });
  }
  // New method: Update the total money display with visibility control
  updateTotalMoneyDisplay() {
    if (this.hasTotalMoneyDisplayTarget && this.hasTotalMoneySectionTarget) {
      const hasCurrencyProducts = this.hasCurrencyPointsSelected();
      
      if (hasCurrencyProducts) {
        const totalMoney = this.calculateTotalMoney();
        this.totalMoneyDisplayTarget.textContent = `$${totalMoney.toLocaleString('es-AR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
        this.totalMoneySectionTarget.style.display = 'block';
      } else {
        this.totalMoneySectionTarget.style.display = 'none';
      }
    }
  }


}