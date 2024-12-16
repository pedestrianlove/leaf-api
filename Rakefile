# frozen_string_literal: true

require 'rake/testtask'
require_relative 'require_app'

CODE = 'lib/'

task :default do
  puts `rake -T`
end

desc 'Run Development Server'
task :run do
  sh 'bundle exec puma'
end

desc 'run specs'
Rake::TestTask.new(:spec) do |t|
  puts 'Make sure worker is running in separate process'
  t.test_files = FileList['spec/**/*_spec.rb']
  t.warning = false
end

desc 'Keep rerunning tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

desc 'Keep rerunning web app upon changes'
task :rerun do
  sh "rerun -c --ignore 'coverage/*' -- bundle exec puma"
end

namespace :queues do
  task :config do
    require 'aws-sdk-sqs'
    require_relative 'config/environment' # load config info
    @api = Leaf::App
    @sqs = Aws::SQS::Client.new(
      access_key_id: @api.config.AWS_ACCESS_KEY_ID,
      secret_access_key: @api.config.AWS_SECRET_ACCESS_KEY,
      region: @api.config.AWS_REGION
    )
    @q_name = @api.config.WORKER_QUEUE
    @q_url = @sqs.get_queue_url(queue_name: @q_name).queue_url
    puts "Environment: #{@api.environment}"
  end
  desc 'Create SQS queue for worker'
  task create: :config do
    @sqs.create_queue(queue_name: @q_name)
    puts 'Queue created:'
    puts "  Name: #{@q_name}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{@q_url}"
  rescue StandardError => e
    puts "Error creating queue: #{e}"
  end
  desc 'Report status of queue for worker'
  task status: :config do
    puts 'Queue info:'
    puts "  Name: #{@q_name}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{@q_url}"
  rescue StandardError => e
    puts "Error finding queue: #{e}"
  end
  desc 'Purge messages in SQS queue for worker'
  task purge: :config do
    @sqs.purge_queue(queue_url: @q_url)
    puts "Queue #{@q_name} purged"
  rescue StandardError => e
    puts "Error purging queue: #{e}"
  end
end

namespace :worker do
  desc 'Run the background cloning worker in development mode'
  task dev: :config do
    require_relative 'config/environment' # load config info
    sh "rerun -c --ignore 'coverage/*' -- bundle exec shoryuken -r ./workers/queue_compute_worker.rb -q #{Leaf::App.config.WORKER_QUEUE}" # rubocop:disable Layout/LineLength
  end
end

desc 'Run application console'
task :console do
  sh 'pry -r ./load_all'
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app = Leaf::App
  end

  desc 'Run migrations'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.db, 'db/migrations')
  end

  desc 'Wipe records from all tables'
  task wipe: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    require_app('infrastructure')
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task drop: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(Leaf::App.config.DB_FILENAME)
    puts "Deleted #{Leaf::App.config.DB_FILENAME}"
  end
end

desc 'Generates a 64 by secret for Rack::Session'
task :new_session_secret do
  require 'base64'
  require 'securerandom'
  secret = SecureRandom.random_bytes(64).then { Base64.urlsafe_encode64(_1) }
  puts "SESSION_SECRET: #{secret}"
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  code = 'config/ app/'

  desc 'run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'code style linter'
  task :rubocop do
    sh 'rubocop'
  end

  desc 'code smell detector'
  task :reek do
    sh 'reek'
  end

  desc 'complexiy analysis'
  task :flog do
    sh "flog #{code}"
  end
end
