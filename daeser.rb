#!/usr/bin/ruby

# Requirements
require 'rubygems'
require 'erb'
require 'xml'
require 'benchmark'

# Turn these into parameters later
model_name = "scorpion"
model_path = '/Users/bradfordcp/Projects/blender/Scorpion/Scorpion2.dae'

# Empty structures to keep our arrays from flipping out
doc       = nil
positions = Array.new
normals   = Array.new
coords    = Array.new
indices   = Array.new

# Bring in the model's document
puts "\nLoading Document..."
puts Benchmark.measure {
  doc = XML::Document.file(model_path)

  # Set the default namespace
  doc.root.namespaces.default_prefix = "COLLADASchema"
}

# Load the positions
puts "\nLoading Positions..."
puts Benchmark.measure {
  raw_positions_eles = doc.find("COLLADASchema:library_geometries//COLLADASchema:float_array[@id='Mesh-mesh-positions-array']")
  if (raw_positions_eles.count > 0)
    raw_positions = raw_positions_eles[0].content.split(" ")
  
    raw_positions.each_with_index do |raw_position, i|
      case i % 3
      when 0 then
        positions << {}
        positions.last[:x] = raw_position
      when 1 then
        positions.last[:y] = raw_position
      when 2 then
        positions.last[:z] = raw_position
      end
    end
  end
}

# Load Normals
puts "\nLoading Normals..."
puts Benchmark.measure {
  raw_normals_eles = doc.find("COLLADASchema:library_geometries//COLLADASchema:float_array[@id='Mesh-mesh-normals-array']")
  if (raw_normals_eles.count > 0)
    raw_normals = raw_normals_eles[0].content.split(" ")
  
    raw_normals.each_with_index do |raw_normal, i|
      case i % 3
      when 0 then
        normals << {}
        normals.last[:x] = raw_normal
      when 1 then
        normals.last[:y] = raw_normal
      when 2 then
        normals.last[:z] = raw_normal
      end
    end
  end
}

# Load Texture coords
puts "\nLoading Texture Coordinates..."
puts Benchmark.measure {
  raw_coords_eles = doc.find("COLLADASchema:library_geometries//COLLADASchema:float_array[@id='Mesh-mesh-map-0-array']")
  if (raw_coords_eles.count > 0)
    coords = raw_coords_eles[0].content.split(" ")
  end
}

# Load the indices
puts "\nLoading Indices..."
puts Benchmark.measure {
  raw_indices_eles = doc.find("COLLADASchema:library_geometries//COLLADASchema:polylist//COLLADASchema:p")
  if (raw_indices_eles.count > 0)
    indices = raw_indices_eles[0].content.split(" ")
  end
}

# Load the template and execute it
puts "\nGenerating Header..."
puts Benchmark.measure {
  template_file = File.new("header.h.erb")
  template = template_file.read
  template_file.close

  b = binding
  header = ERB.new(template).result b
  header_file = File.new("#{model_name}.h", "w+")
  header_file.puts header
  header_file.close
}