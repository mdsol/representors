require 'representors/representor_hash'
module Representors

  ##
  # Builder has methods to abstract the construction of Representor objects
  # In the present implementation it will create a hash of a specific format to
  # Initialize the Representor with, this will create classess with it.
  class RepresentorBuilder
    HREF_KEY = 'href'
    DATA_KEY = 'data'

    def initialize(representor_hash = {})
      @representor_hash = RepresentorHash.new(representor_hash)
    end

    # Returns a hash usable by the representor class
    def to_representor_hash
      @representor_hash
    end

    # Adds an attribute to the Representor. We are creating a hash where the keys are the
    # names of the attributes
    def add_attribute(name, value, options={})
      new_representor_hash = @representor_hash.dup
      new_representor_hash.attributes[name] = options.merge({value: value})
      RepresentorBuilder.new(new_representor_hash)
    end

    # Adds a transition to the Representor, each transition is a hash of values
    # The transition collection is an Array
    def add_transition(rel, href, options={})
      new_representor_hash = @representor_hash.dup
      link_values = options.merge({href: href, rel: rel})
      if options[DATA_KEY]
        link_values[Transition::DESCRIPTORS_KEY] = link_values.delete(DATA_KEY)
      end
      new_representor_hash.transitions.push(link_values)
      RepresentorBuilder.new(new_representor_hash)
    end

    # Adds directly an array to our array of transitions
    def add_transition_array(rel, array_of_hashes)
      array_of_hashes.reduce(RepresentorBuilder.new(@representor_hash)) do |memo, transition| 
        href = transition.delete(:href)
        binding.pry if href.is_a?(Hash)
        memo = memo.add_transition(rel, href, transition)
      end
    end

    def add_embedded(name, embedded_resource)
      new_representor_hash = @representor_hash.dup
      new_representor_hash.embedded[name] = embedded_resource
      embedded_resource = [embedded_resource] unless embedded_resource.is_a?(Array)

      transitions = embedded_resource.map do |resource|
        resource[:transitions].find { |transition| transition[:rel] == "self" } if resource[:transitions]
      end.compact

      RepresentorBuilder.new(new_representor_hash).add_transition_array(name, transitions)
    end

  end
end
