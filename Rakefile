require 'rubygems'
require 'yaml'

# Components and dependencies
COMPONENTS = {
  'stdair' => [],
  'airrac' => ['stdair'],
  'rmol'   => ['stdair', 'airrac'],
  'airinv' => ['stdair', 'airrac', 'rmol']
}

# Common CMake arguments
CMAKE_ARGS = "-DLIB_SUFFIX=64 -DCMAKE_BUILD_TYPE:STRING=Debug -DINSTALL_DOC:BOOL=ON"

# MetaSim root path
ROOT_PATH = File.expand_path File.dirname(__FILE__)

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

directory WORK_PATH

desc "Checkout all components"
task :checkout

desc "Configure all components"
task :configure

desc "Install all components"
task :install

COMPONENTS.each do |cmp, cmp_deps|
  cmp_src_path = component_src_path cmp
  cmp_build_path = component_buid_path cmp
  cmp_install_path = component_install_path cmp
  branch = 'trunk'
  
  desc "Checkout component #{cmp}"
  file cmp_src_path => WORK_PATH do
    do_shell "#{GIT_BIN} clone -b #{branch} git://gitorious.orinet.nce.amadeus.net/#{cmp}/#{cmp}.git #{cmp_src_path}"
  end
  task :checkout => cmp_src_path
  
  cmake_deps_args = cmp_deps.map { |dep| "-DWITH_#{dep.upcase}_PREFIX=#{component_install_path dep}" }.join ' '
  
  config_prereqs = [cmp_src_path] + cmp_deps.map { |dep| "install_#{dep}" }
  
  cmp_makefile = File.join cmp_build_path, 'Makefile'
  
  file cmp_makefile => config_prereqs do
    mkdir_p cmp_build_path
    ::Dir.chdir(cmp_build_path) do
      do_shell "#{CMAKE_BIN} #{cmake_deps_args} #{CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=#{cmp_install_path} #{cmp_src_path}"
    end
  end
  desc "Configure component #{cmp}"
  task "configure_#{cmp}" => cmp_makefile
  task :configure => "configure_#{cmp}"
  
  desc "Install component #{cmp}"
  task "install_#{cmp}" => "configure_#{cmp}" do
    ::Dir.chdir(cmp_build_path) do
      do_shell "#{MAKE_BIN} install"
    end
  end
  task :install => "install_#{cmp}"
end

task :default => :install
