class Person < ApplicationRecord
  enum :gender, { masculine: 'Masculino', feminine: 'Femenino' }
  enum :document_type, { dni: 'DNI', cuil: 'CUIL', identity_card: 'Cédula de Identidad', passport: 'Pasaporte' }
  enum :status, { correct: 'Correcto', duplicated: 'Duplicado', triplicated: 'Triplicado' }

  has_many :person_addresses, dependent: :destroy
  has_many :person_emails, dependent: :destroy
  has_many :person_phones, dependent: :destroy

  has_many :customers, dependent: :destroy
  has_many :companies, through: :customers

  has_many :person_relationships, dependent: :destroy
  has_many :relationships, through: :person_relationships
  has_many :person_relations, through: :person_relationships, class_name: 'Person', dependent: :destroy

  has_many :movements, dependent: :destroy

  validates :last_name, presence: true
  validates :first_name, presence: true

  validates :document_number, uniqueness: { scope: :document_type, message: "ya existe con esta combinación." }

  before_validation :sanitize_document_number

  before_create :set_person_status
  default_scope { order('people.last_name', 'people.first_name') }


  def sanitize_document_number
    self.document_number = document_number.to_s.gsub('.', '') if document_number.present?
  end

  def set_person_status
    # document = document_number
    # document_type = self.document_type
    # count_people = Person.where(document_number: document, document_type: document_type).count
    self.status = :correct
  end

  def full_name
    "#{last_name}, #{first_name}"
  end

  def full_document
    "#{document_type&.upcase} - #{document_number}"
  end

  def formated_gender
    return unless gender
    gender == 'masculine' ? 'Masculino' : 'Femenino'
  end

  def formatted_date_birth
    birth_date.strftime("%d/%m/%Y") if birth_date
  end

  def html_card
    %{
      <div class="card my-2">
        <div class="card-body">
          <div class="text-start">
            <p class="text-muted mb-2 font-16"><strong>Nombre :</strong> <span class="ms-2">#{full_name}</span></p>
            <p class="text-muted mb-2 font-16"><strong>Documento :</strong><span class="ms-2">#{full_document}</span></p>
            <p class="text-muted mb-2 font-16"><strong>Fecha Nacimiento :</strong> <span class="ms-2 ">#{formatted_date_birth}</span></p>
          </div>
        </div>
      </div>
    }.html_safe
  end

  def get_years_person
    return unless birth_date
    actual_year = Time.zone.now.strftime('%Y')
    birth_date_year = birth_date.strftime('%Y')
    actual_year.to_i - birth_date_year.to_i
  end

  def family_group
    Person.where(id: PersonRelationship.where(person_relation_id: id).pluck(:person_id))
  end

  def relationship_type(person)
    person_relationship = PersonRelationship.find_by(person: person, person_relation: self)
    person_relationship ? person_relationship.relationship.name : 'No vinculado/a'
  end
  
  def points_balance_amount(group)
    balance = 0
    person_movements = group.account_type_group? ? movements.where(group: group) : movements.where.not(movement_type: :group_load)
    person_movements.each do |movement|
      multiplier = 1 if movement.credit_points_movement?
      multiplier = -1 if movement.debit_points_movement?
      balance += multiplier * movement.points
    end
    balance
  end

  def get_details_movement(group)
    arr = []
    balance = 0
    person_saving = 0
    person_movements = movements.where(group: group)
    person_movements = group.account_type_group? ? person_movements : person_movements.where.not(movement_type: :group_load)
    unless person_movements.blank?
      person_movements.order(created_at: :asc).each do |movement|
        #----------------------Para cta. cte. de PUNTOS----------------------------
        multiplier = 1 if movement.credit_points_movement?
        multiplier = -1 if movement.debit_points_movement?
        balance += movement.points * multiplier

        #----------------------Para cta. cte. de AHORRO----------------------------
        add_value = movement.amount_discounted if movement.movement_type_sale? || movement.movement_type_sale_annulment?
        add_value = 0 if movement.movement_type_exchange? || movement.movement_type_exchange_annulment? || movement.movement_type_group_load? || movement.movement_type_product_exchange?
         add_value = 0 unless add_value.present?
        person_saving += add_value * multiplier

        #-------------------------------Array----------------------------
        arr << {
          id: movement.id,
          annulled: movement.annulled,
          date_created: movement.created_at.strftime('%d/%m/%Y - %H:%M'),
          group_name: movement.group ? movement.group.name : "",
          company_name: movement.company ? movement.company.name : "",
          movement_type: movement.movement_type,
          amount: movement.amount,
          points: movement.points,
          balance: balance,
          discount: movement.discount,
          amount_discounted: movement.amount_discounted,
          person_saving: person_saving,
          total_import: movement.total_import
        }
      end
    end
    arr.reverse
  end

  # Ahorro del Ultimo Mes
  def get_monthly_saving(group)
    movements.where(
      created_at: 1.months.ago..0.month.ago,
      annulled: false,
      movement_type: :sale,
      group_id: group.id
    ).sum(:amount_discounted)
  end

  # RETORNA CANTIDAD DE CANJES
  def get_count_exchange(group)
    count_exchange = movements.where(group: group, movement_type: [:exchange, :product_exchange]).count
    count_exchange_annulment = movements.where(group: group, movement_type: [:exchange_annulment, :product_exchange_annulment]).count
    count_exchange.to_i-count_exchange_annulment.to_i
  end
end
