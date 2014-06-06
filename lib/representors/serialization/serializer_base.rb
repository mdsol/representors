require 'representors/serialization/base'
require 'representors/serialization/serializer_factory'

module Representors
  module Serialization
    class SerializerBase < Base
      def self.inherited(subclass)
        SerializerFactory.register_serializers(subclass)
      end
      
      def to_media_type(options = {})
        @serialization ||= serialize(target)
        @serialization.call(options)
      end
    end
  end
end
