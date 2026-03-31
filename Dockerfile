FROM ruby:3.3.4
# Install system dependencies (same as old Azure base image)
RUN apt-get update && apt-get install -y \
    postgresql-client \
    pdftk \
    imagemagick \
    nodejs \
    curl \
    build-essential \
    libpq-dev \
    git \
    && curl -L https://www.npmjs.com/install.sh | sh \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*
RUN gem update --system
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install --no-cache
COPY . .
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]


