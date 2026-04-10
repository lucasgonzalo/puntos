// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

//import { Controller } from "stimulus"
import { Controller } from "@hotwired/stimulus";

//import axios from "axios";

export default class extends Controller {

  static targets = [
    "branchValue", // sucursal seleccionada
    "amountValue", // importe de venta
    "amountDiscounted", // importe descontado 
    "amountWithDiscount", // importe con descuento 
    "points", // puntos a acumular
    "exchangePoints", // puntos a canjear
    "totalImport", // total a pagar

    "errorFeedbackBranch", // error de sucursal
    "errorFeedbackAmount", //error de importe de venta
    "errorFeedbackExchange", // error de puntos a canjear

    "discountValue", // descuento
    "conversionValue", // conversion
    "pointsBalance", //saldo de puntos
    "submitButton",

    // New targets for select and forms
    "movementTypeSelect",
    "saleForm",
    "saleExchangeForm",
    "productExchangeForm",

    // targets de filtro de busqueda de productos en canje-producto
    'card',
    'defaultCatalogId',
    'catalogContent',
    'selectedProductId',
    'selectedProductDisplay',
    'submitExchangeForm'
  ]


  connect() {
    if (this.hasAmountDiscountedTarget) { this.amountDiscountedTarget.value = ``; }
    if (this.hasAmountWithDiscountTarget) { this.amountWithDiscountTarget.value = ``; }
    if (this.hasPointsTarget) { this.pointsTarget.value = ``; }
    if (this.hasTotalImportTarget) { this.totalImportTarget.value = ``; }
    if (this.hasBranchValueTarget) { this.displayBranchSettings(); }

    // Set initial form visibility based on select value
    if (this.hasMovementTypeSelectTarget) { this.handleMovementTypeChange(); }
  }

  get isAgent() {
    return this.element.dataset.customerIsAgent === "true";
  }

  get activeForm() {
    if (this.hasSaleFormTarget && !this.saleFormTarget.classList.contains("d-none")) {
      return this.saleFormTarget;
    } else if (this.hasSaleExchangeFormTarget && !this.saleExchangeFormTarget.classList.contains("d-none")) {
      return this.saleExchangeFormTarget;
    }
    return this.element;
  }

  updateSubmitButtonState() {
    // Enable the submit button if a product is selected, disable otherwise
    this.submitExchangeFormTarget.disabled = !this.selectedProductIdTarget.value;
  }

  // Handle select change to show/hide forms
  handleMovementTypeChange() {
    const selectedType = this.movementTypeSelectTarget.value;
    this.hideAllForms();
    if (selectedType === "sale") {
      this.saleFormTarget.classList.remove("d-none");

    } else if (selectedType === "sale-exchange") {
      this.saleExchangeFormTarget.classList.remove("d-none");

    } else if (selectedType === "product-exchange") {
      // Load the separate product exchange form via turbo frame
      const turboFrame = document.getElementById('product_exchange_form');
      if (turboFrame) {
        turboFrame.src = `/movements/product_exchange_form?customer_id=${this.element.dataset.customerId}&branch_id=${this.element.dataset.branchId}`;
      }
      // show product exchange form
      this.productExchangeFormTarget.classList.remove("d-none");
    }
  }

  // Hide all forms
  hideAllForms() {
    this.saleFormTarget.classList.add("d-none");
    this.saleExchangeFormTarget.classList.add("d-none");
    this.productExchangeFormTarget.classList.add("d-none");
  }

  // mostramos conversion y descuento de conf. de sucursales 
  async displayBranchSettings() {
    const { discountValue, conversionValue, conversionAgentValue } = await this.getBranchSetting();
    this.discountParam = discountValue;
    this.conversionParam = conversionValue;
    this.conversionAgentParam = conversionAgentValue;  // NUEVO
    this.showSettingsFormat(discountValue, this.isAgent ? conversionAgentValue : conversionValue);  // CAMBIO: mostrar la conversión correcta
    this.updateValues();
    this.clearValidationErrors();
  }

  showSettingsFormat(discountParam, conversionParam) {
    if (discountParam != -1 && conversionParam != -1) {
      const formattedDiscount = parseFloat(discountParam).toFixed(2).replace('.', ',');
      const parts = parseFloat(conversionParam).toFixed(2).split('.');
      let integerPart = parts[0];
      let decimalPart = parts[1];
      integerPart = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, '.');

      this.discountValueTargets.forEach(el => el.textContent = `${formattedDiscount}%`);
      this.conversionValueTargets.forEach(el => el.textContent = `${integerPart}${','}${decimalPart}`);
    } else {
      this.discountValueTargets.forEach(el => el.textContent = ``);
      this.conversionValueTargets.forEach(el => el.textContent = ``);
    }
  }

  async getBranchSetting() {
    const branchId = this.branchValueTarget.value
    let discountValue = -1;
    let conversionValue = -1;
    let conversionAgentValue = -1;  // NUEVO
    if (branchId) {
      try {
        const response = await window.axios.get(`/branches/${branchId}/today_settings`);
        const { discount, conversion, conversion_agent } = response.data;
        discountValue = discount;
        conversionValue = conversion;
        conversionAgentValue = conversion_agent;  // NUEVO
      } catch (error) {
        console.error("Error al obtener la configuración de la sucursal:", error);
      }
    }
    return { discountValue, conversionValue, conversionAgentValue };  // NUEVO
  }

  updateValues() {
    const effectiveConversion = this.isAgent ? this.conversionAgentParam : this.conversionParam;
    const form = this.activeForm;
    const amountEl = form.querySelector('[data-movements-target="amountValue"]');
    const discountEl = form.querySelector('[data-movements-target="amountDiscounted"]');
    const withDiscountEl = form.querySelector('[data-movements-target="amountWithDiscount"]');
    const pointsEl = form.querySelector('[data-movements-target="points"]');
    const exchangeEl = form.querySelector('[data-movements-target="exchangePoints"]');
    const totalEl = form.querySelector('[data-movements-target="totalImport"]');
    if (this.discountParam != -1 && effectiveConversion != -1 && amountEl) {
      const amountValue = parseFloat(amountEl.value) || 0;
      const discountAmount = amountValue * (this.discountParam / 100);
      const amountWithDiscount = amountValue - discountAmount;
      const exchangePoints = parseInt((exchangeEl?.value || '0').replace(/\D/g, ''), 10) || 0;
      const points = Math.round(amountWithDiscount * effectiveConversion);
      const totalImport = amountWithDiscount - parseFloat(exchangePoints || 0);
      if (discountEl) discountEl.value = `${discountAmount.toFixed(2)}`;
      if (withDiscountEl) withDiscountEl.value = `${amountWithDiscount.toFixed(2)}`;
      if (pointsEl) pointsEl.value = `${points}`;
      if (totalEl) totalEl.value = `${totalImport.toFixed(2)}`;
      if (exchangeEl) exchangeEl.value = (isNaN(exchangePoints) || exchangePoints === '') ? 0 : exchangePoints;
    } else {
      if (discountEl) discountEl.value = ``;
      if (withDiscountEl) withDiscountEl.value = ``;
      if (pointsEl) pointsEl.value = ``;
      if (totalEl) totalEl.value = ``;
      if (exchangeEl) exchangeEl.value = ``;
    }
  }

  validateBranch() {
    //event.preventDefault();
    //this.clearValidationErrors();
    if (this.branchValueTarget.value.trim() === '') {
      this.showValidationError(this.branchValueTarget, "Es requerido seleccionar una sucursal", this.errorFeedbackBranchTarget);
    }
  }

  validateAmount() {
    //event.preventDefault();
    //this.clearValidationErrors();
    if (isNaN(this.amountValueTarget.value) || Number(this.amountValueTarget.value) <= 0) {
      this.showValidationError(this.amountValueTarget, "Es requerido el valor de Importe", this.errorFeedbackAmountTarget);
    }
  }

  validateExchangePoints() {
    this.clearValidationErrors();
    let isValid = true;

    if (Number(this.exchangePointsTarget.value) > Number(this.pointsBalanceTarget.value)) {
      this.showValidationError(
        this.exchangePointsTarget,
        "Los puntos a canjear exceden los puntos disponibles",
        this.errorFeedbackExchangeTarget
      );
      isValid = false;
    }

    if (Number(this.exchangePointsTarget.value) > Number(this.amountWithDiscountTarget.value)) {
      this.showValidationError(
        this.exchangePointsTarget,
        "Los puntos a canjear exceden el importe con descuento",
        this.errorFeedbackExchangeTarget
      );
      isValid = false;
    }

    // Enable or disable the submit button based on validation
    this.submitButtonTarget.disabled = !isValid;
  }

  // validateInputs(){
  //   this.validateBranch();
  //   this.validateAmount();
  //   this.validateExchangePoints();

  //   // Check if there are any validation errors
  //   const hasErrors = this.hasValidationErrors();
  //   this.submitButtonTarget.disabled = hasErrors;
  // }

  validateInputs() {
    const selectedType = this.movementTypeSelectTarget.value;

    if (selectedType === "sale") {
      this.validateSaleForm();
    } else if (selectedType === "sale-exchange") {
      this.validateSaleExchangeForm();
    } else if (selectedType === "product-exchange") {
      this.validateProductExchangeForm();
    }

    // This stays - it's essential!
    const hasErrors = this.hasValidationErrors();
    this.submitButtonTarget.disabled = hasErrors;
  }

  validateSaleForm() {
    this.validateBranch();
    this.validateAmount();
    // No exchange validation needed
  }

  validateSaleExchangeForm() {
    this.validateBranch();
    this.validateAmount();
    this.validateExchangePoints(); // Always safe to call
  }

  validateProductExchangeForm() {
    this.validateBranch();
    this.validateProductSelection(); // Product-specific validation
  }

  clearValidationErrors() {
    this.branchValueTarget.classList.remove("is-invalid");
    this.amountValueTarget.classList.remove("is-invalid");
    this.exchangePointsTarget.classList.remove("is-invalid");

    this.errorFeedbackBranchTarget.textContent = "";
    this.errorFeedbackAmountTarget.textContent = "";
    this.errorFeedbackExchangeTarget.textContent = "";
  }

  showValidationError(target, message, errorTarget) {
    target.classList.add("is-invalid");
    errorTarget.textContent = message;
  }

  hasValidationErrors() {
    const form = this.element;
    const errors = form.querySelectorAll('.is-invalid');

    console.log("Errores encontrados:", errors.length);
    return errors.length > 0;
  }

  validateSubmitForm(event) {
    console.log("Validando el formulario...");
    const button = event.currentTarget;
    event.preventDefault();

    this.clearValidationErrors();
    this.validateInputs();
    console.log(this.hasValidationErrors());

    if (!this.hasValidationErrors()) {
      button.textContent = 'Enviando...';
      this.element.closest('form').submit();
    }

  }
}
