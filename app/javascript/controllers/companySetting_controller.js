//import { Controller } from "stimulus"
import { Controller } from "@hotwired/stimulus";


export default class extends Controller {
  static targets = [
    "field", "optionNav", "branchValue",
    "amountWithDiscount","importDiscounted", "totalImport", 
    "points", "exchangePoints", 
    "errorFeedback", "errorFeedbackExchange", "errorFeedbackBranch"
  ]


  static values = {
    currentConversion: Number, 
    currentDiscount: Number, 
    currentType: String,
    currentAvailablePoints: Number,
  }

  connect(){
    this.change();
  }

  setErrorFeedback(message) {
    const feedbackElement = this.nameTarget.nextElementSibling;
    feedbackElement.textContent = message;
  }

  // Para validar un campo del formulario antes de enviar el form
  validation_method(event){
    event.preventDefault();

    this.fieldTarget.classList.remove("is-invalid");
    this.exchangePointsTarget.classList.remove("is-invalid");
    this.branchValueTarget.classList.remove("is-invalid");

    this.errorFeedbackTarget.textContent = "";
    this.errorFeedbackExchangeTarget.textContent = "";
    this.errorFeedbackExchangeTarget.textContent = "";


    // Para determinar Valor requerido del importe 
    if (isNaN(this.fieldTarget.value) || Number(this.fieldTarget.value) <= 0) {
      this.fieldTarget.classList.add("is-invalid");
      this.errorFeedbackTarget.textContent = "Es requerido el valor de Importe";
    }

    if (isNaN(this.exchangePointsTarget.value)) {
      this.exchangePointsTarget.value=0;
    }

    if (Number(this.exchangePointsTarget.value) > Number(this.currentAvailablePointsValue)) {
      this.exchangePointsTarget.classList.add("is-invalid");
      this.errorFeedbackExchangeTarget.textContent = "Los puntos a canjear exceden los puntos disponibles";
    } 

    if (Number(this.exchangePointsTarget.value) > Number(this.amountWithDiscountTarget.value)) {
      this.exchangePointsTarget.classList.add("is-invalid");
      this.errorFeedbackExchangeTarget.textContent = "Los puntos a canjear exceden el importe con descuento";
    }

    var branch_id = $("#movement_branch_id").val();

    console.log("#######################################33");
    console.log(this.branchValueTarget);


    if (!branch_id){
      this.branchValueTarget.classList.add("is-invalid");
      this.errorFeedbackBranchTarget.textContent = "Debe agregar sucursal";
    }
  }

  validation_send(event){
    event.preventDefault();

    let show_error = false 

    if(isNaN(this.fieldTarget.value) || Number(this.fieldTarget.value) <= 0) {
      show_error = true
      this.fieldTarget.classList.add("is-invalid");
      this.errorFeedbackTarget.textContent = "Es requerido el valor de Importe";
    } 

    if(Number(this.exchangePointsTarget.value) > Number(this.currentAvailablePointsValue)) {
      show_error = true
      this.exchangePointsTarget.classList.add("is-invalid");
      this.errorFeedbackExchangeTarget.textContent = "Los puntos a canjear exceden los puntos disponibles";
    } 

    if(Number(this.exchangePointsTarget.value) > Number(this.amountWithDiscountTarget.value)) {
      show_error = true
      this.exchangePointsTarget.classList.add("is-invalid");
      this.errorFeedbackExchangeTarget.textContent = "Los puntos a canjear exceden el importe con descuento";
    }
    
    var branch_id = $("#movement_branch_id").val();
    if (!branch_id){
      show_error = true
      this.branchValueTarget.classList.add("is-invalid");
      this.errorFeedbackBranchTarget.textContent = "Debe agregar sucursal";
    }

    if(show_error==false){
      this.fieldTarget.classList.remove("is-invalid");
      this.exchangePointsTarget.classList.remove("is-invalid");
      this.branchValueTarget.classList.remove("is-invalid");

      this.errorFeedbackTarget.textContent = "";
      this.errorFeedbackExchangeTarget.textContent = "";
      this.errorFeedbackExchangeTarget.textContent = "";
      this.element.submit();
    }   
     
  }

  submit_once(event) {
    const button = event.currentTarget;
    console.log(button)
    button.disabled = true; // Deshabilita el botón después de hacer clic en él
    button.textContent = 'Enviando...'; // Cambia el texto del botón para indicar que se está enviando el formulario
    // Envía el formulario
    this.element.closest('form').submit();
  }

  movement_method(){
    if (isNaN(this.exchangePointsTarget.value) || this.exchangePointsTarget.value=='') {
      this.exchangePointsTarget.value=0;
    }
    // Esto es para ver la cantidad de puntos a canjear
    this.exchangePointsTarget.value = parseInt(this.exchangePointsTarget.value.replace(/\D/g, ''), 10);

    // Este es el valor que se tiene que descontar 
    let val_discounted = (this.fieldTarget.value * (this.currentDiscountValue/100))
    this.importDiscountedTarget.value = `${val_discounted.toFixed(2)}`

    // Este es el importe con descuento 
    this.amountWithDiscountTarget.value = `${(this.fieldTarget.value - val_discounted).toFixed(2)}`

    //Este es el valor de puntos a acumular en base a la conversion del día
    this.pointsTarget.value = `${Math.round(this.amountWithDiscountTarget.value * this.currentConversionValue)}`

    //Este es el importe a pagar 
    this.totalImportTarget.value = `${(this.amountWithDiscountTarget.value - this.exchangePointsTarget.value).toFixed(2)}`  
  }






















  
  // --------------------------------------------------------------------------------------------------------------------------

  sale_method(){
    let val_discounted = (this.fieldTarget.value * (this.currentDiscountValue/100))
    this.pointsTarget.value = `${Math.round(this.fieldTarget.value * this.currentConversionValue)}`

    this.importDiscountedTarget.value = `${val_discounted.toFixed(2)}`
    this.amountWithDiscountTarget.value = `${(this.fieldTarget.value - val_discounted).toFixed(2)}`
    this.totalImportTarget.value = `${(this.amountWithDiscountTarget.value - this.exchangePointsTarget.value).toFixed(2)}`
    console.log(this.fieldTarget.value)
    console.log(val_discounted)
    console.log(this.amountWithDiscountTarget.value)
  }

  exchange_method(){
    console.log("holaaaaaaaa")
    this.fieldTarget.value = (this.pointsTarget.value/this.currentConversionValue).toFixed(2)
    let val_discounted = (this.fieldTarget.value * (this.currentDiscountValue/100))
    this.importDiscountedTarget.value = `${val_discounted.toFixed(2)}`
    this.amountWithDiscountTarget.value = `${(this.fieldTarget.value - val_discounted).toFixed(2)}`
    this.totalImportTarget.value = `${(this.amountWithDiscountTarget.value - this.exchangePointsTarget.value).toFixed(2)}`

    $('#msg-error').hide();
  }
  
  change() {
    let val_discounted = (this.fieldTarget.value * (this.currentDiscountValue/100))
    // Los puntos a acumular  = Importe * Conversion y debe ser numeros enteros
    //this.pointsTarget.value = `${Math.round(this.fieldTarget.value * this.currentConversionValue)}`
    // Importe Descontado  = Importe * Valor a descontar en %
    this.importDiscountedTarget.value = `${val_discounted.toFixed(2)}`
    // Importe con descuento = Importe - Importe descontado
    this.amountWithDiscountTarget.value = `${(this.fieldTarget.value - val_discounted).toFixed(2)}` 
    //Total a pagar = Importe con descuento - Puntos a descontar
    this.totalImportTarget.value = `${(this.amountWithDiscountTarget.value - this.exchangePointsTarget.value).toFixed(2)}`

  }

  

}
