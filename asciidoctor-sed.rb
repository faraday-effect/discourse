require 'asciidoctor'
require 'asciidoctor/extensions'

require 'tilt'
require 'tilt/erubis'

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
  @@next_seq_num = 1

  def initialize(block)
    @block = block
    @seq_num = @@next_seq_num
    @@next_seq_num += 1
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

  def id_attribute
    "sed-block-#{@seq_num}"
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
    new_block = create_block parent, :open, reader.lines, attrs.merge({ 'role' => 'sidebarblock' })
    sed_block = SedBlock.new(new_block)
    id = sed_block.id_attribute
    parent << create_block(parent, :pass, %{<button onclick="request_visual('#{id}')">Request #{id}</button>}, attrs)
    new_block
  end
end

class SedTreeProcessor < Asciidoctor::Extensions::Treeprocessor
  def output_path document
    ::File.join document.attr(:visuals_dir),
                %(#{document.attr(:docname)}#{document.attr(:outfilesuffix)})
  end

  def process document
    template = Tilt.new(document.attr(:visuals_template))
    File.open output_path(document), 'w' do |file|
      file.write template.render(SedBlock)
    end
  end
end

class SedPostprocessor < Asciidoctor::Extensions::Postprocessor
  def process document, output
    replacement = %(
<script src="/socket.io/socket.io.js"></script>
<script>
    var socket = io();
    function request_visual(id) {
        socket.emit('request-visual', id);
    }
</script>
)
    output.sub /(?=<\/body>)/, replacement
  end
end

Asciidoctor::Extensions.register do
  block SedBlockProcessor
  treeprocessor SedTreeProcessor
  # treeprocessor ShowAST
  postprocessor SedPostprocessor
end
