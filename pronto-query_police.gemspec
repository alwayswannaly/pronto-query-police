# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'pronto/query_police/version'

Gem::Specification.new do |s|
  s.name = 'pronto-query_police'
  s.version = Pronto::QueryPoliceVersion::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Shubham Anand']
  s.email = 'shubham@scaler.com'
  s.homepage = 'https://github.com/alwayswannaly/pronto-query-police'
  s.summary = <<-EOF
    Pronto runner for flagging bad queries
  EOF

  s.licenses = ['MIT']
  s.required_ruby_version = '>= 2.4'
  s.rubygems_version = '1.8.23'

  s.files = Dir.glob('{lib}/**/*') + %w(LICENSE README.md)
  s.test_files = `git ls-files -- {spec}/*`.split("\n")
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.require_paths = ['lib']

  s.add_dependency('pronto', '~> 0.10.0')
  s.add_dependency('rugged', '~> 0.24', '>= 0.23.0')
  s.add_development_dependency('rake', '~> 12.0')
  s.add_development_dependency('rspec', '~> 3.4')
end
