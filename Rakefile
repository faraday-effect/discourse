# Rakefile

require 'pathname'

# This should go away after converting asciidoctor-sed into a gem [?] or library.
DISCOURSE_DIR = '/Users/tom/Taylor/Projects/Faraday/discourse'

# Content source and destination directories
SOURCE_DIR = '/Users/tom/Taylor/Projects/Faraday/discourse/course'
SERVER_DIR = '/Users/tom/Taylor/Projects/Faraday/discourse-server/course'

adoc_files = Rake::FileList.new(SOURCE_DIR + '/**/*.adoc')
image_files = Rake::FileList.new([SOURCE_DIR + '/**/*.jpg', SOURCE_DIR + '/**/*.png'])

def source_to_server filename, type=nil
  if type
    filename.pathmap("%{/discourse,/discourse-server}d/#{type}/%n.html")
  else
    filename.pathmap("%{/discourse,/discourse-server}p")
  end
end

## Extract the course name from a adoc file name.
def extract_course adoc_file
  m = %r{(/.*)/(\w+)/([\w\.]+)$}.match(adoc_file)
  m[2]
end

desc 'Convert notes'
task :notes => adoc_files.map { |file| source_to_server(file, 'notes') }

desc 'Convert visuals'
task :visuals => adoc_files.map { |file| source_to_server(file, 'visuals') }

desc 'Copy images'
task :images => image_files.map { |file| source_to_server(file) }

adoc_files.each do |file|
  ['notes', 'visuals'].each do |type|
    file source_to_server(file, type) => file do |t|
      mkdir_p t.name.pathmap('%d')
      run_asciidoctor(t.source,
                      extract_course(file),
                      source_to_server(file, 'notes'),
                      source_to_server(file, 'visuals'))
    end
  end
end

image_files.each do |file|
  file source_to_server(file) => file do |t|
    mkdir_p t.name.pathmap("%d")
    sh "cp", t.source, t.name
  end
end

desc "Default task"
task :default => [:notes, :visuals, :images]

def run_asciidoctor(adoc_file, course, notes_file, visuals_file)
  cmd = %Q{asciidoctor \
--trace \
--safe-mode unsafe \
--load-path #{DISCOURSE_DIR} \
--require asciidoctor-sed \
--attribute visuals_template=#{DISCOURSE_DIR + '/templates/visuals.html.erb'} \
--attribute visuals_dir=#{visuals_file.pathmap('%d')} \
--attribute imagesdir="/#{course}/images" \
--destination-dir #{notes_file.pathmap('%d')} \
#{adoc_file}}
  sh cmd
end
