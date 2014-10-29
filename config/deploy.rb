# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'demo'
set :deploy_user, 'ubuntu'

set :scm, :git
set :repo_url, 'git@github.com:CBluowei/demo.git'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# what specs should be run before deployment is allowed to
# continue, see lib/capistrano/tasks/run_tests.cap
set :tests, %w(spec)

# which config files should be copied by deploy:setup_config
# see documentation in lib/capistrano/tasks/setup_config.cap
# for details of operations
set(:config_files, %w(
  nginx.conf
  unicorn.rb
  unicorn_init.sh
))

# which config files should be made executable after copying
# by deploy:setup_config
set(:executable_config_files, %w(
  unicorn_init.sh
))

# files which need to be symlinked to other parts of the
# filesystem. For example nginx virtualhosts, log rotation
# init scripts etc. The full_app_name variable isn't
# available at this point so we use a custom template {{}}
# tag and then add it at run time.
set(:symlinks, [
  {
    source: "nginx.conf",
    link: "/etc/nginx/sites-enabled/{{full_app_name}}"
  },
  {
    source: "unicorn_init.sh",
    link: "/etc/init.d/unicorn_{{full_app_name}}"
  }
])

namespace :deploy do
  # only allow a deploy with passing tests to deployed
  before :deploy, "deploy:run_tests"

  after :finishing, 'deploy:cleanup'

  before :publishing, 'deploy:setup_config'

  # reload nginx to it will pick up any modified vhosts from
  # setup_config
  after 'deploy:setup_config', 'nginx:reload'

  after :publishing, 'deploy:restart'
end
