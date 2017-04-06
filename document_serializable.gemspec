# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'document_serializable/version'

Gem::Specification.new do |spec|
  spec.name          = "document_serializable"
  spec.version       = DocumentSerializable::VERSION
  spec.authors       = ["Alex"]
  spec.email         = ["aleksandra@nerdgeschoss.de"]

  spec.summary       = "Document serializer"
  spec.homepage      = "https://github.com/nerdgeschoss/document_serializable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "hashdiff"
  spec.add_dependency "virtus"
end
