require 'rundock'
require 'thor'

module Rundock
  class CLI < Thor
    DEFAULT_SCENARIO_FILE_PATH = './scenario.yml'
    DEFAULT_SSH_OPTIONS_DEFAULT_FILE_PATH = './default_ssh.yml'
    DEFAULT_HOSTGROUP_FILE_PATH = './targetgroup.yml'

    class_option :log_level, type: :string, aliases: ['-l'], default: 'info'
    class_option :color, type: :boolean, default: true
    class_option :header, type: :boolean, default: true
    class_option :short_header, type: :boolean, default: false
    class_option :date_header, type: :boolean, default: true
    class_option :suppress_logging, type: :boolean, default: false

    def initialize(args, opts, config)
      super(args, opts, config)

      Rundock::Logger.level = ::Logger.const_get(options[:log_level].upcase)
      Rundock::Logger.formatter.colored = options[:color]
      Rundock::Logger.formatter.show_header = options[:header]
      Rundock::Logger.formatter.short_header = options[:short_header]
      Rundock::Logger.formatter.date_header = options[:date_header]
      Rundock::Logger.formatter.suppress_logging = options[:suppress_logging]
    end

    desc 'version', 'Print version'
    def version
      puts Rundock::VERSION.to_s
    end

    desc 'do [SCENARIO] [options]', 'Run rundock from scenario file'
    option :sudo, type: :boolean, default: false
    option :default_ssh_opts, type: :string, aliases: ['-d'], default: DEFAULT_SSH_OPTIONS_DEFAULT_FILE_PATH
    option :targetgroup, type: :string, aliases: ['-g']
    option :tasks, type: :string, aliases: ['-t'], banner: 'You can specify comma separated task file paths.[ex: task_file1,task_file2,..]'
    option :filtered_tasks, type: :string, aliases: ['-T'], banner: 'You can specify comma separated tasks.[ex: task1,task2,..]'
    option :hooks, type: :string, aliases: ['-k']
    option :run_anyway, type: :boolean, aliases: ['-r'], default: false
    option :dry_run, type: :boolean, aliases: ['-n']
    def do(*scenario_file_path)
      scenario_file_path = [DEFAULT_SCENARIO_FILE_PATH] if scenario_file_path.empty?
      opts = { :scenario => scenario_file_path[0] }

      Runner.run(opts.merge(options.deep_symbolize_keys))
    end

    desc 'ssh [options]', 'Run rundock ssh with various options'
    option :command, type: :string, aliases: ['-c']
    option :default_ssh_opts, type: :string, aliases: ['-d'], default: DEFAULT_SSH_OPTIONS_DEFAULT_FILE_PATH
    option :tasks, type: :string, aliases: ['-t'], banner: 'You can specify comma separated task file paths.[ex: task_file1,task_file2,..]'
    option :filtered_tasks, type: :string, aliases: ['-T'], banner: 'You can specify comma separated tasks.[ex: task1,task2,..]'
    option :hooks, type: :string, aliases: ['-k']
    option :host, type: :string, aliases: ['-h'], banner: 'You can specify comma separated hosts.[ex: host1,host2,..]'
    option :targetgroup, type: :string, aliases: ['-g']
    option :user, type: :string, aliases: ['-u']
    option :key, type: :string, aliases: ['-i']
    option :port, type: :numeric, aliases: ['-p']
    option :ssh_config, type: :string, aliases: ['-F']
    option :ask_password, type: :boolean, default: false
    option :sudo, type: :boolean, default: false
    option :run_anyway, type: :boolean, aliases: ['-r'], default: false
    option :dry_run, type: :boolean, aliases: ['-n']
    def ssh
      opts = {}

      Runner.run(opts.merge(options.deep_symbolize_keys))
    end

    desc 'configure [options]', 'Configure rundock options'
    option :ssh, type: :boolean, default: true
    option :ssh_config_path, type: :string, aliases: ['-s'], default: "#{Dir.home}/default_ssh.yml"
    def configure
      opts = {}

      Configure.start(opts.merge(options.deep_symbolize_keys))
    end

    def method_missing(command, *args)
      help
    end
  end
end
