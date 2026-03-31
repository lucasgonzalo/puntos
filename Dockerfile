FROM nuntius.azurecr.io/rails:latest

# Set working directory
WORKDIR /app

# Copy the rest of the application files
COPY . .

RUN bundle install --no-cache

# Expose port
EXPOSE 3000

# Start Rails server in development mode
CMD ["rails", "server", "-b", "0.0.0.0"]


