release: rake db:migrate; rake queues:create
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: bundle exec shoryuken -r ./workers/queue_compute_worker.rb -q ${WORKER_QUEUE:-development.fifo}
