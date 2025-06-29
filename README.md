# Siege Clan Tracker (Rails Version)

A legacy Ruby on Rails web application built to support an Old School RuneScape (OSRS) clan with player tracking, event listings, and real-time stats. This project has been succeeded by a newer React + Supabase implementation, but remains archived here for historical reference and potential reactivation.

## Features

- Rails 5 monolith app with PostgreSQL and Redis
- Admin dashboard to manage players and clans
- In-game data integration using OSRS Hiscores
- Job queues via Sidekiq for player stat syncing
- Simple user authentication and session tracking
- Basic frontend built with ERB, Bootstrap

## Getting Started

### Prerequisites
- Ruby 2.7+
- Rails 5.2+
- PostgreSQL
- Redis

### Installation
```bash
git clone https://github.com/atayl16/siege.git
cd siege
bundle install
yarn install
rails db:setup
redis-server
rails server
```

### Environment Variables
Create a `.env` file and define the following if required:
```
RAILS_MASTER_KEY=your_key_here
```

## Development

- Job queues powered by Sidekiq
- Player data syncs pulled from OSRS API
- Performance monitored via Skylight (if enabled)

## Tests

This repo does not include full automated test coverage but supports RSpec if added. The new version improves testing setup.

## Deployment

Originally hosted on Heroku with Redis, PostgreSQL, and a background worker. App remains archived.

## Roadmap

The project has been succeeded by:
➡️ [siege-clan-tracker (React + Supabase)](https://github.com/atayl16/siege-clan-tracker)

## License
MIT

## Author
**Alisha Taylor**  
GitHub: [@atayl16](https://github.com/atayl16)  
LinkedIn: [Alisha Taylor](https://www.linkedin.com/in/alisha-t-098785180/)
