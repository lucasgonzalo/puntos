# frozen_string_literal: true

class Ability
  include CanCan::Ability


  def initialize(user)
    Rails.logger.info "Inicializando Ability para el usuario con ID: #{user.id}"
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)
    cannot :acces, :redis_keys

    can :access, Catalog
    can :access, Product
    can %i[states], Country
    can %i[cities], State

    return unless user.present?

    #---------------------------EN USUARIOS - ROL PROPIETARIO DE COMERCIO (Un comercio tiene solo un dueño¿)---------------------------
    if user.company_owner_role?
      can :access, Customer, company: { user: user }  # Para acceder a clientes del Comercio
      can %i[create read enable_client], Customer # Clientes del Comercio
      can :access, Movement, branch: { company: { user: user } } # Para acceder a movimientos del Comercio
      can %i[create read annulment_movement], Movement #Movimientos del Comercio
      can %i[access read mark_as_read], Alert # Alertas del Comercio
      can %i[access], :my_qr # Toda la parte de QR
      can %i[access], :company_setting # Accesos de configuracion
      can %i[access], :branch_setting # Accesos de configuracion
      can %i[access], :indicators # Indicadores
      can %i[create read edit], PersonAddress
      can %i[create read edit], PersonEmail
      can %i[create read edit], PersonPhone
      can %i[access create read edit enable_employee], BranchUser # Empleados de un comercio&sucursal
      can :manage, Catalog
      can :manage, Product
    end

    #---------------------------EN USUARIOS/SUCURSAL - ROL GERENTE DEL COMERCIO (Es la mano derecha, creo que son los mismo que propietario de comercio)---------------------------
    if !user.branch_users.where(manager_role: true).blank?
      can :access, Customer, company: { user: user }
      can %i[create read enable_client], Customer
      can :access, Movement, branch: { company: { user: user } }
      can %i[create read annulment_movement], Movement
      can %i[access read mark_as_read], Alert
      can %i[access], :my_qr
      can %i[access], :company_setting
      can %i[access], :branch_setting
      can %i[access], :indicators # Indicadores
      can %i[create read edit], PersonAddress
      can %i[create read edit], PersonEmail
      can %i[create read edit], PersonPhone
      can %i[access create read edit enable_employee], BranchUser # Empleados de un comercio&sucursal
      can :manage, Catalog
      can :manage, Product
    end

    #---------------------------EN USUARIOS/SUCURSAL - ROL INTERMEDIO DEL COMERCIO (Contador, gente de marketing, administradores)---------------------------
    if !user.branch_users.where(intermediate_role: true).blank?
      can :access, Customer, company: { user: user }
      can %i[create read], Customer
      can :access, Movement, branch: { company: { user: user } }
      can %i[access read mark_as_read], Alert
      can %i[access], :my_qr
      can %i[access], :indicators # Indicadores
      can %i[create read edit], PersonAddress
      can %i[create read edit], PersonEmail
      can %i[create read edit], PersonPhone
      can :manage, Catalog
      can :manage, Product
    end


    #---------------------------EN USUARIOS/SUCURSAL - ROL BASICO DEL COMERCIO (Cajeros, Mozos, etc)---------------------------
    if !user.branch_users.where(basic_role: true).blank?
      can :access, Customer, company: { user: user }
      can %i[create read], Customer
      can :access, Movement, branch: { company: { user: user } }
      can %i[create read annulment_movement], Movement
      can %i[access], :my_qr
      can %i[create read edit], PersonAddress
      can %i[create read edit], PersonEmail
      can %i[create read edit], PersonPhone

    end

    #---------------------------EN USUARIOS - ROL AMINISTRADOR DE TODO (Super Admin de todo)------------------------------
    return unless user.admin_role?
    can :manage, :all
    can %i[read update create destroy], Post

    if user.group_owner_role?
      cannot :manage, [Country, State, City, Post, User, Customer, Group]
      can :create, BranchUser
      cannot :manage, :relationship
    end
  end
end
