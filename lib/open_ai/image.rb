module OpenAI
  class Image
    BASE_TOKENS = 85
    TILE_TOKENS = 170
    TILE_SIZE = 512

    def self.from_tg_photo(file, model:)
      return unless file
      return unless model.has_vision?

      base64 = Base64.encode64(file.read)
      size = `identify -format "%w %h" ./#{file.original_filename}`
      width, height = size.split(" ")
      FileUtils.rm_rf("./#{file.original_filename}")

      new(width, height, base64)
    end

    attr_accessor :width, :height, :base64

    def initialize(width, height, base64)
      @width = width
      @height = height
      @base64 = base64
    end

    def tokens
      @tokens ||= begin
        tiles = tiles(width) * tiles(height)
        (tiles * TILE_TOKENS) + BASE_TOKENS
      end
    end

    def tiles(pixels)
      (pixels.to_f / TILE_SIZE).ceil
    end
  end
end