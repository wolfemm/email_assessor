# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "email_assessor/version"

Gem::Specification.new do |spec|
  spec.name          = "email_assessor"
  spec.version       = EmailAssessor::VERSION
  spec.summary       = "Advanced ActiveModel email validation"
  spec.description   = "ActiveModel email validation with MX lookups, domain blacklisting and disposable email-domain blocking"

  spec.license = "MIT"

  spec.author   = "Michael Wolfe Millard"
  spec.email    = "wolfemm.development@gmail.com"
  spec.homepage = "https://github.com/wolfemm/email_assessor"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_runtime_dependency "mail", "~> 2.5"
  spec.add_runtime_dependency "activemodel", ">= 3.2"
end
