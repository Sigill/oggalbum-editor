# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ogg_album_tagger/version'

Gem::Specification.new do |spec|
  spec.name          = "ogg_album_tagger"
  spec.version       = OggAlbumTagger::VERSION
  spec.authors       = ["Cyrille Faucheux"]
  spec.email         = ["cyrille.faucheux@gmail.com"]
  spec.summary       = "Interactive edition of ogg tags with support for whole albums."
  spec.homepage      = "https://github.com/Sigill/OggAlbumTagger"
  spec.license       = "MIT"

  spec.files         = %w{bin/ogg-album-tagger
                          lib/ogg_album_tagger/exceptions.rb
                          lib/ogg_album_tagger/library.rb
                          lib/ogg_album_tagger/picture.rb
                          lib/ogg_album_tagger/tag_container.rb
                          lib/ogg_album_tagger/version.rb}
  spec.executables   = %w{ogg-album-tagger}
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "exiftool", ["~> 0.6"]
  spec.add_runtime_dependency "taglib-ruby", ["~> 0.7"]
end
