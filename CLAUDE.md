# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Puntos** is a Rails 7.2 loyalty points management system for businesses. It enables companies to manage customer relationships, track transactions, and award loyalty points. The system supports multiple companies, branches, employees with role-based permissions, and QR code functionality for external interactions.

## Development Commands

### Docker Commands
This project runs inside Docker containers. All Rails commands must be executed inside the `app` container:

```bash
docker compose up -d              # Start all containers in background
docker compose down              # Stop all containers
docker compose ps                # List running containers
docker compose exec app bash     # Enter the app container shell
docker compose logs app -f       # Follow app container logs
```

### Setup and Installation (run inside container)
```bash
docker compose exec app bundle install           # Install Ruby dependencies
docker compose exec app bin/rails db:create     # Create databases
docker compose exec app bin/rails db:migrate    # Run database migrations
docker compose exec app bin/rails db:seed       # Load seed data
```

### Development Server
The Rails server automatically starts when the container runs (see docker-compose.yml).
Access the application at: http://localhost:3000

### Testing (run inside container)
```bash
docker compose exec app bin/rails test                    # Run all tests
docker compose exec app bin/rails test:system            # Run system tests only
docker compose exec app bin/rails db:test:prepare        # Prepare test database
```

### Code Quality and Security (run inside container)
```bash
docker compose exec app bin/rubocop -f github    # Lint Ruby code
docker compose exec app bin/brakeman --no-pager  # Security vulnerability scan
docker compose exec app bin/importmap audit      # JavaScript dependency security scan
```

### Database Operations (run inside container)
```bash
docker compose exec app bin/rails db:migrate:status      # Check migration status
docker compose exec app bin/rails db:rollback           # Rollback last migration
docker compose exec app bin/rails console               # Rails console
docker compose exec app bin/rails generate              # Generate files (migrations, controllers, etc.)
```

### Custom Rake Tasks (run inside container)
```bash
docker compose exec app bin/rails generate_random_data:ejecute_method    # Generate test data
docker compose exec app bin/rails email_settings_task:execute_method     # Configure email settings
docker compose exec app bin/rails generate_settings_branch:execute_method # Generate branch settings
docker compose exec app bin/rails fix_data:execute_method                # Fix data inconsistencies
```

## Architecture Overview

### Core Domain Models
- **Company**: Main business entity with settings and configuration
- **Branch**: Physical locations belonging to companies
- **User**: System users with role-based permissions
- **Customer**: End users who earn and redeem points
- **Movement**: Point transactions (sales, exchanges, redemptions)
- **Product/Catalog**: Items available for point redemption
- **Alert**: Notifications for various business events

### Permission System
The application uses CanCanCan for authorization with these roles:
- **Company Owner**: Full access to their company data
- **Manager**: Similar to owner, can manage catalogs and products
- **Intermediate**: Limited access (accounting, marketing roles)
- **Basic**: Minimal access (cashiers, basic staff)
- **Admin**: Super admin with system-wide access
- **Group Owner**: Limited admin with specific restrictions

### Key Features
- **Multi-tenancy**: Companies are isolated from each other
- **Role-based Access Control**: Different permission levels per user
- **QR Code Integration**: External customer interactions via QR codes
- **Points System**: Configurable conversion rates and discounts by day of week
- **Email System**: SMTP configuration for notifications
- **Audit Trail**: Movement tracking and annulment capabilities

### Frontend Stack
- **Hotwire**: Turbo and Stimulus for SPA-like behavior
- **Bootstrap 5**: UI framework
- **SCSS**: Styling with Sass
- **Importmap**: JavaScript module management
- **DataTables**: Enhanced table functionality

### Key Controllers
- `ApplicationController`: Base controller with common methods
- `PagesController`: Dashboard and main pages
- `MovementsController`: Point transactions
- `CustomersController`: Customer management with wizard
- `CatalogsController`: Product catalog management
- `BranchesController`: Branch management and settings
- `QrBranchesController`: QR code functionality

### Database Notes
- Uses PostgreSQL in production
- Extensive migration history with point system evolution
- Supports multiple address/email/phone per person
- Group system for organizing customers and movements

### Configuration Files
- Spanish is the default locale (`config.i18n.default_locale = :es`)
- Email configuration documented in `docs/email.md`
- Devise handles authentication
- Redis used for caching and background jobs

### Testing Strategy
- Uses Rails minitest framework
- System tests with Capybara and Selenium
- Parallel test execution enabled
- CI pipeline includes security scanning and linting