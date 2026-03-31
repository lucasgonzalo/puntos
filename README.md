# Puntos - Loyalty Points Management System

A comprehensive Rails 7.2 application for managing customer loyalty programs. Puntos enables businesses to create and manage multi-tenant loyalty point systems with role-based permissions, QR code integration, and flexible point redemption catalogs.

## 🎯 Purpose

Puntos is designed for businesses that want to implement customer loyalty programs through a centralized, multi-tenant platform. It supports both independent business loyalty programs and centralized group systems where points can be shared across multiple companies.

### Key Features

- **Multi-tenant Architecture**: Complete data isolation between companies
- **Role-based Access Control**: 6 permission levels with CanCanCan
- **Dual Entity Models**: Store-type (per-business) and Group-type (centralized) loyalty programs
- **QR Code Integration**: External customer interactions via QR codes
- **Flexible Points System**: Configurable conversion rates and day-specific discounts
- **Email Notifications**: SMTP-configurable alerts and communications
- **Audit Trail**: Complete movement tracking with annulment capabilities
- **Dashboard & Analytics**: Real-time insights with ApexCharts
- **Excel Integration**: Import/export capabilities for data management

## 🛠 Technical Stack

### Core Technologies
- **Ruby**: 3.3.4
- **Rails**: 7.2.1.2
- **Database**: PostgreSQL 16.1
- **Cache/Queue**: Redis 5.0

### Frontend
- **UI Framework**: Bootstrap 5
- **JavaScript**: Hotwire (Turbo + Stimulus)
- **Module Management**: Importmap
- **Charts**: ApexCharts
- **Tables**: DataTables

### Key Gems
- **Authentication**: Devise 4.9.2
- **Authorization**: CanCanCan
- **PDF Generation**: Prawn + QR codes
- **Excel**: CAXLSX + Roo
- **Monitoring**: Sentry
- **Testing**: Rails minitest + Capybara + Selenium

## 🐳 Docker Setup

This project runs entirely in Docker containers. All commands must be executed inside the `app` container.

### Architecture
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    App      │    │  Database   │    │    Redis    │    │  pgAdmin    │
│  (Rails)    │    │(PostgreSQL) │    │             │    │             │
│   Port:3000 │◄──►│  Port:5432  │◄──►│  Port:6378  │    │  Port:7000  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Prerequisites
- Docker and Docker Compose
- Git

### Quick Start

1. **Clone and navigate to project**
   ```bash
   git clone <repository-url>
   cd puntos
   ```

2. **Start all containers**
   ```bash
   docker compose up -d
   ```

3. **Install dependencies and setup database**
   ```bash
   docker compose exec app bundle install
   docker compose exec app bin/rails db:create
   docker compose exec app bin/rails db:migrate
   docker compose exec app bin/rails db:seed
   ```

4. **Access the application**
   - Web App: http://localhost:3000
   - pgAdmin: http://localhost:7000
   - Database: localhost:5432
   - Redis: localhost:6378

## 💻 Development Workflow

### Container Access
```bash
# Enter app container shell
docker compose exec app bash

# View running containers
docker compose ps

# View logs
docker compose logs app -f
```

### Common Commands (run inside container)

#### Database Operations
```bash
bin/rails db:migrate:status    # Check migration status
bin/rails db:rollback         # Rollback last migration
bin/rails console              # Rails console
bin/rails db:seed              # Load seed data
```

#### Testing
```bash
bin/rails test                 # Run all tests
bin/rails test:system         # Run system tests only
bin/rails db:test:prepare     # Prepare test database
```

#### Code Quality
```bash
bin/rubocop -f github         # Lint Ruby code
bin/brakeman --no-pager       # Security vulnerability scan
bin/importmap audit           # JavaScript dependency security scan
```

#### Custom Rake Tasks
```bash
bin/rails generate_random_data:ejecute_method    # Generate test data
bin/rails email_settings_task:execute_method     # Configure email settings
bin/rails generate_settings_branch:execute_method # Generate branch settings
bin/rails fix_data:execute_method                # Fix data inconsistencies
```

## 🏗 Architecture Overview

### Business Models

#### Store-Type Entities ("Por Comercio")
- **Purpose**: Independent loyalty programs per business
- **Use Case**: Individual businesses or chains with separate tracking
- **Features**: Isolated points, independent catalogs, company-specific reporting

#### Group-Type Entities ("Por Entidad") 
- **Purpose**: Centralized loyalty across multiple businesses
- **Use Case**: Franchises, shopping centers, corporate groups
- **Features**: Unified points, shared catalogs, consolidated reporting

### Permission System
- **Admin**: System-wide access
- **Company Owner**: Full access to their company
- **Manager**: Catalog and product management
- **Intermediate**: Limited access (accounting, marketing)
- **Basic**: Minimal access (cashiers, staff)
- **Group Owner**: Limited admin with restrictions

### Core Domain Models
- **Company**: Main business entity with settings
- **Branch**: Physical locations
- **User**: System users with roles
- **Customer**: End users earning/redeeming points
- **Movement**: Point transactions (sales, exchanges, redemptions)
- **Product/Catalog**: Items for point redemption
- **Alert**: System notifications

## 📧 Configuration

### Email Setup
See `docs/Email.md` for detailed SMTP configuration instructions.

### Environment Files
- `.env.web`: Application settings
- `.env.database`: Database credentials
- `.env.pg`: pgAdmin configuration


### Usefull redis variables
   enable_mail_by_redis	true
   smtp_ssl	true
   smtp_port	465
   smtp_openssl_verify_mode	none
   smtp_enable_starttls_auto	true
   smtp_password
   smtp_authentication	login
   smtp_user_name
   smtp_tls	true
   smtp_address
   mailer_delivery_method	smtp
   maintenance_mode	false

## 🔒 Security

- **Authentication**: Devise with secure password handling
- **Authorization**: CanCanCan role-based permissions
- **Security Scanning**: Brakeman integration
- **Dependency Audit**: Importmap security scanning
- **Monitoring**: Sentry error tracking

## 📊 Monitoring & Analytics

- **Error Tracking**: Sentry integration
- **Performance**: Rack Mini Profiler in development
- **Analytics**: ApexCharts for dashboards
- **Audit Trail**: Complete movement history

## 🧪 Testing

The application uses Rails minitest framework with:
- **Unit Tests**: Model and business logic testing
- **Integration Tests**: Controller and workflow testing  
- **System Tests**: Full browser testing with Capybara + Selenium
- **Parallel Execution**: Enabled for faster test runs

## 📚 Documentation

- **Business Logic**: `docs/Business-Doc.md`
- **Email Configuration**: `docs/Email.md`
- **Development Tasks**: `docs/ToDo-founded.md`
- **API Documentation**: Available in-app (when implemented)

## 🚀 Deployment

The application is containerized and ready for deployment to any Docker-compatible platform:
- Kubernetes (see `k8s/definition.yaml`)
- Docker Swarm
- Cloud container services (AWS ECS, Google Cloud Run, etc.)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and code quality checks
5. Submit a pull request

## 📄 License

[Add your license information here]

---

**Puntos** - Building customer loyalty, one point at a time.