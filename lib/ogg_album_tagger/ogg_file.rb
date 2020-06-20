require 'shellwords'
require 'set'
require 'taglib'
require 'ogg_album_tagger/exceptions'
require 'ogg_album_tagger/tag_container'
require 'ogg_album_tagger/picture'
require 'base64'
require 'image_size'

module OggAlbumTagger

# Store the tags of an ogg track.
#
# Each tag is associated to a Set of values.
class OggFile < OggAlbumTagger::TagContainer
    attr_accessor :path

    MBP = 'METADATA_BLOCK_PICTURE'

    # Initialize a TagContainer from an ogg file.
    def initialize(file)
        begin
            h = Hash.new

            TagLib::Ogg::Vorbis::File.open(file.to_s) do |ogg|
                ogg.tag.field_list_map.each do |tag, values|

                    h[tag] = Set.new
                    values.each do |value|
                        if tag.upcase == MBP
                            pic = TagLib::FLAC::Picture::new
                            if (pic.parse(Base64.strict_decode64(value)))
                                width = pic.width
                                height = pic.height

                                # Dimensions are usually not set. Get them another way.
                                if width == 0 or height == 0
                                    img = ImageSize.new(pic.data)
                                    width = img.width
                                    height = img.height
                                end

                                h[MBP].add(Picture.new(pic.data,
                                                       pic.type,
                                                       pic.mime_type,
                                                       width,
                                                       height,
                                                       pic.color_depth,
                                                       pic.num_colors,
                                                       pic.description))
                            end
                        else
                            h[tag].add(value.strip)
                        end
                    end
                end
            end

            super(h)
            @path = file
        rescue Exception => ex
            STDERR.puts ex
            raise OggAlbumTagger::ArgumentError, "#{file} does not seems to be a valid ogg file."
        end
    end

    # Write the tags in the specified file.
    def write(file)
        begin
            TagLib::Ogg::Vorbis::File.open(file.to_s) do |ogg|
                tags = ogg.tag

                # Remove old tags
                tags.field_list_map.keys.each { |t| tags.remove_field(t) }

                # Set new tags (Taglib will write them sorted)
                @hash.each do |tag, values|
                    values.sort.each do |v|
                        if tag == MBP
                            tags.add_field(tag, v.to_mbp, false)
                        else
                            tags.add_field(tag, v, false)
                        end
                    end
                end

                # Save everything
                ogg.save
            end
        rescue Exception
            raise OggAlbumTagger::ArgumentError, "#{file} cannot be written."
        end
    end

    def to_s
        OggFile.sorted_tags(@hash.keys).map do |tag|
            OggFile.pp_tag(@hash[tag])
        end.join "\n"
    end

    # Sort the tag keys alphabetically, but put METADATA_BLOCK_PICTURE at the end.
    def self.sorted_tags(tags)
        a = tags.sort
        a.delete('METADATA_BLOCK_PICTURE') and a.push('METADATA_BLOCK_PICTURE')
        block_given? ? a.each { |v| yield v } : a
    end
end

end # module OggAlbumTagger
