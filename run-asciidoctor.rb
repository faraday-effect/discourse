#!/usr/bin/env ruby

require 'asciidoctor'
require 'asciidoctor/extensions'

class ShowAST < Asciidoctor::Extensions::Treeprocessor
  def process document
    return unless document.blocks?
    process_blocks document
    nil
  end

  def tab_str depth
    '|   ' * depth
  end

  def process_blocks node, depth = 0
    node.blocks.each do |block|
      print tab_str(depth), "#{block.class}, #{block.context}, #{block.attributes}"
      if block.respond_to?('title')
        title = block.title
        unless title.nil? || title.empty?
          print ", #{title}"
        end
      end
      if block.respond_to?('lines')
        lines = block.lines.map { |line| tab_str(depth + 1) + "[#{line}]" }
        unless lines.empty?
          print "\n", lines * "\n"
        end
      end
      if block.respond_to?('text')
        print "\n", tab_str(depth + 1), block.text
      end
      puts
      process_blocks block, depth + 1 if block.blocks?
    end
  end
end

class SedBlock
  @@all_blocks = []
  def initialize(block)
    @block = block
    @@all_blocks << self
  end

  def attributes
    @block.attributes
  end

  def raw
    @block.lines
  end

  def processed
    @block.convert
  end

  class << self
    def all_blocks
      @@all_blocks
    end
  end
end

class SedBlockProcessor < Asciidoctor::Extensions::BlockProcessor
  use_dsl

  named :sed
  on_context :open

  def process parent, reader, attrs
    block = create_block parent, :open, reader.lines, attrs
    SedBlock.new(block)
    block
  end
end

class DoSed < Asciidoctor::Extensions::Treeprocessor
  def process document
    puts '<div class="reveal">'
    puts '<div class="slides">'
    SedBlock.all_blocks.each do |block|
      puts
      puts "<section>"
      puts block.processed
      puts "</section>"
    end
    puts '</div> <!-- slides -->'
    puts '</div> <!-- reveal -->'
  end
end

Asciidoctor::Extensions.register do
  block SedBlockProcessor
  # treeprocessor ShowAST
  treeprocessor DoSed
end

puts "<!-- LOADING FILE -->"
doc = Asciidoctor.load_file('test.adoc', safe: :safe)
puts "<!-- CONVERTING FILE -->"
html = doc.convert
puts "<!-- CONVERSION COMPLETE -->"
