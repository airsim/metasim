require 'yaml'

# MetaSim root path
ROOT_PATH = File.expand_path File.dirname(__FILE__)

# Load the YAML configuration file
CONF_FILE = File.join ROOT_PATH, 'metasim.yaml'
CONF = File.open(CONF_FILE) { |f| YAML.load f }
raise "Unable to load YAML configuration file from #{CONF_FILE}" unless CONF
CONF.each do |param, val|
  Object.const_set "CONF_#{param.upcase}", val
end

# MetaSim workspace
WORK_PATH = File.join ROOT_PATH, 'workspace'

# Required binaries
BINARIES = ['git', 'cmake', 'make']
BINARIES.each do |bin|
  bin_path = %x[ which #{bin} ].strip
  raise "Executable #{bin} not found!" unless File.executable?(bin_path)
  Object.const_set "#{bin.upcase}_BIN", bin_path
end

# Path to cloned sources
def component_src_path(cmp)
  File.join WORK_PATH, 'src', cmp
end

# Path to build output
def component_buid_path(cmp)
  File.join WORK_PATH, 'build', cmp
end

# Path to installed components
def component_install_path(cmp)
  File.join WORK_PATH, 'install', cmp
end

# Run a shell command
def do_shell(cmd)
  puts "METASIM: #{cmd}"
  raise "Shell command failure" unless system(cmd)
end

# Lookup the version of a component
def component_version(cmp)
  cmp_src_path = component_src_path cmp
  cmp_build_path = component_buid_path cmp
  cmake_vars = {}
  if File.executable?(cmp_src_path) && File.executable?(cmp_build_path)
    ::Dir.chdir(cmp_build_path) do
      result = %x[ #{CMAKE_BIN} -N -LA #{cmp_src_path} ]
      if $?.success?
        result.split("\n").each do |line|
          variable, value = line.split(':', 2)
          cmake_vars[variable] = value.split('=', 2).last if value
        end
      else
        STDERR.puts "CMake error while loading the cache from #{cmp_build_path}"
      end
    end
  end
  cmake_vars['PACKAGE_VERSION']
end

desc "Display configuration information"
task :info do
  puts "Components:"
  CONF_COMPONENTS.each do |cmp, cmp_deps|
    puts " * #{cmp}"
    puts "   Depends on #{cmp_deps.join ', '}" unless cmp_deps.empty?
    puts "   Source cloned at #{component_src_path cmp}"
    puts "   Built from #{component_buid_path cmp}"
    puts "   Installed to #{component_install_path cmp}"
  end
  puts "Checkout branch : #{CONF_BRANCH}"
  puts "CMake arguments : #{CONF_CMAKE_ARGS}"
  puts "Publish to      : #{CONF_PUBLISH_PATH}"
end

directory WORK_PATH

desc "Clone all components"
task :clone

desc "Checkout all components"
task :checkout

desc "Pull changes on all components"
task :pull

desc "Configure all components"
task :configure

desc "Install all components"
task :install

desc "Clean all components"
task :clean

desc "Distribute all components"
task :dist

CONF_COMPONENTS.each do |cmp, cmp_deps|
  cmp_src_path = component_src_path cmp
  cmp_build_path = component_buid_path cmp
  cmp_install_path = component_install_path cmp
  
  # Checkout tasks
  
  file cmp_src_path => WORK_PATH do
    do_shell "#{GIT_BIN} clone git://gitorious.orinet.nce.amadeus.net/#{cmp}/#{cmp}.git #{cmp_src_path}"
  end
  desc "Clone component #{cmp} in #{cmp_src_path}"
  task "clone_#{cmp}" => cmp_src_path
  task :clone => "clone_#{cmp}"
  
  desc "Checkout branch #{CONF_BRANCH} of component #{cmp}"
  task "checkout_#{cmp}" => cmp_src_path do
    ::Dir.chdir(cmp_src_path) do
      do_shell "#{GIT_BIN} checkout #{CONF_BRANCH}"
    end
  end
  task :checkout => "checkout_#{cmp}"
  
  # Pull tasks
  
  desc "Pull changes on component #{cmp}"
  task "pull_#{cmp}" => cmp_src_path do
    ::Dir.chdir(cmp_src_path) do
      do_shell "#{GIT_BIN} pull"
    end
  end
  task :pull => "pull_#{cmp}"
  
  # Configuration tasks
   
  cmake_deps_args = cmp_deps.map { |dep| "-DWITH_#{dep.upcase}_PREFIX=#{component_install_path dep}" }.join ' '
  
  config_prereqs = ["checkout_#{cmp}"] + cmp_deps.map { |dep| "install_#{dep}" }
  
  cmp_makefile = File.join cmp_build_path, 'Makefile'
  
  file cmp_makefile => config_prereqs do
    mkdir_p cmp_build_path
    ::Dir.chdir(cmp_build_path) do
      do_shell "#{CMAKE_BIN} #{cmake_deps_args} #{CONF_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=#{cmp_install_path} #{cmp_src_path}"
    end
  end
  desc "Configure component #{cmp} in #{cmp_build_path}"
  task "configure_#{cmp}" => cmp_makefile
  task :configure => "configure_#{cmp}"
  
  # Installation tasks
  
  desc "Install component #{cmp} to #{cmp_install_path}"
  task "install_#{cmp}" => cmp_makefile do
    ::Dir.chdir(cmp_build_path) do
      do_shell "#{MAKE_BIN} install"
    end
  end
  task :install => "install_#{cmp}"
  
  # Cleaning tasks
  
  desc "Clean component #{cmp} in #{cmp_build_path}"
  task "clean_#{cmp}" => cmp_makefile do
    ::Dir.chdir(cmp_build_path) do
      do_shell "#{MAKE_BIN} clean"
    end
  end
  task :clean => "clean_#{cmp}"
  
  # Distribution tasks
  
  cmp_version = component_version cmp
  if cmp_version
    arch_name = "#{cmp}-#{cmp_version}.tar.bz2"
    arch_path_src = File.join cmp_build_path, arch_name
    
    file arch_path_src => cmp_makefile do
      ::Dir.chdir(cmp_build_path) do
        do_shell "#{MAKE_BIN} dist"
      end
    end
    
    directory CONF_PUBLISH_PATH
    
    arch_path_dst = File.join CONF_PUBLISH_PATH, arch_name
    
    file arch_path_dst => [arch_path_src, CONF_PUBLISH_PATH] do
      cp arch_path_src, arch_path_dst
    end
    desc "Publish component #{cmp} to #{arch_path_dst}"
    task "dist_#{cmp}" => arch_path_dst
    task :dist => "dist_#{cmp}"
  else
    puts "Warning: package version of component #{cmp} is not available. You have to install it first."
  end
end

task :default => :install
