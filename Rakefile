# Rakefile

require 'pathname'

# Find ourself in the file system.
PARENT_DIR = Pathname.new(Dir.getwd().pathmap('%d'))

# This should go away after converting asciidoctor-sed into a gem [?] or library.
DISCOURSE_DIR = PARENT_DIR.join('discourse')

# Content source and destination directories
SOURCE_DIR = PARENT_DIR.join('discourse/src')
SERVER_DIR = PARENT_DIR.join('discourse-server/course')

class Adoc
  def initialize(rel_path)
    @rel_path = rel_path
  end

  def adoc_path
    SOURCE_DIR.join(@rel_path)
  end

  def notes_path
    Rake::FileList.new(SERVER_DIR.join(@rel_path.pathmap('%X') + '-notes.html'))
  end

  def visuals_path
    Rake::FileList.new(SERVER_DIR.join(@rel_path.pathmap('%X') + '-visuals.html'))
  end

  def to_s
    %{#<#{self.class}:#{@rel_path}>}
  end
end

Dir.chdir(SOURCE_DIR)
adocs = Rake::FileList.new('**/*.adoc').map { |path| Adoc.new(path) }
copied_files = Rake::FileList.new('**/*.{jpg,png}', '**/*.{c,js,rb,cpp}')

desc 'Convert notes'
task :notes => adocs.map { |adoc| adoc.notes_path }

desc 'Convert visuals'
task :visuals => adocs.map { |adoc| adoc.visuals_path }

desc 'Copy other files'
task :others => copied_files.map { |file| SERVER_DIR.join(file) }

adocs.each do |adoc|
  # TODO: There must be a better way to create these two file dependencies
  file adoc.notes_path => adoc.adoc_path do |t|
    mkdir_p t.name.pathmap('%d')
    run_asciidoctor(t.source,
                    adoc.notes_path,
                    adoc.visuals_path)
  end
  file adoc.visuals_path => adoc.adoc_path do |t|
    mkdir_p t.name.pathmap('%d')
    run_asciidoctor(t.source,
                    adoc.notes_path,
                    adoc.visuals_path)
  end
end

copied_files.each do |file|
  file SERVER_DIR.join(file) => SOURCE_DIR.join(file) do |t|
    mkdir_p t.name.pathmap("%d")
    sh "cp", t.source, t.name
  end
end

desc "Default task"
task :default => [:notes, :visuals, :others]

def run_asciidoctor(adoc_file, notes_file, visuals_file)
  cmd = %Q{asciidoctor \
--trace \
--safe-mode unsafe \
--load-path #{DISCOURSE_DIR} \
--require asciidoctor-sed \
--attribute visuals_template=#{DISCOURSE_DIR.join('templates/visuals.html.erb')} \
--attribute visuals_file=#{visuals_file} \
--attribute imagesdir="images" \
--out-file #{notes_file} \
#{adoc_file}}
  sh cmd
end
