# frozen_string_literal: true
require 'yaml'

class Episode
  attr_accessor :name,
                :audio,
                :picture,
                :description

  def initialize(name, audio, picture, description)
    @name = name
    @audio = audio
    @picture = picture
    @description = description
    validate_audio_filename(audio_path)
  end

  def validate_audio_filename
    raise 'Wrong filename format. Should match /rt[0-9]{4}\.mp3/' if (@audio =~ /rt[0-9]{4}\.mp3/) == nil
  end

  def self.from_yaml_path(path)
    config = YAML.load(File.new(path).read())
    raise 'Missing configs' unless (
        config.key?('name') &&
        config.key?('audio') &&
        config.key?('picture') &&
        config.key?('description')
      )
    Episode.new(config['name'], config['audio'], config['picture'], config['description'])
  end
end
