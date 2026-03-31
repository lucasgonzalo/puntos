class RegistrationMailer < ApplicationMailer
  include ActionView::Helpers::NumberHelper

  def validate_email_registration(person_email,company)
    @person_email = person_email
    @company = company
    @person = @person_email.person
    @token = @person_email.generate_token_for(:email_validation)
    @validation_url = validate_email_url(@token)

    mail(
      from: "Registro <#{ApplicationMailer.default_from_address}>",
      to: @person_email.email,
      subject: "Valida tu correo electrónico para completar tu registro en #{@company.name}"
    )
  end
end