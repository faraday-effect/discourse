# Rakefile

require 'pathname'

COMMON_DIR = Pathname.new(Dir.pwd.pathmap('%d'))
SRC_BASE_DIR = COMMON_DIR.join('discourse')
SRC_DIR = SRC_BASE_DIR.join('course')

adoc_files = Rake::FileList.new(SRC_DIR.join('**/*.adoc'))
image_files = Rake::FileList.new(SRC_DIR.join('**/*.jpg'))

desc 'Convert notes'
task :notes => adoc_files.pathmap('%{/discourse,/discourse-server}d/notes/%n.html')

desc 'Convert visuals'
task :visuals => adoc_files.pathmap('%{/discourse,/discourse-server}d/visuals/%n.html')

desc 'Copy images'
task :images => image_files.pathmap('%{/discourse,/discourse-server}p')

def html_dst_path adoc_file, type
  adoc_file.pathmap("%{/discourse,/discourse-server}d/#{type}/%n.html")
end

def image_dst_path image_file
  image_file.pathmap('%{/discourse,/discourse-server}p')
end

adoc_files.each do |file|
  file html_dst_path(file, 'notes') => file do |t|
    mkdir_p t.name.pathmap("%d")
    run_asciidoctor(t.source, t.name)
  end
  file html_dst_path(file, 'visuals') => file do |t|
    mkdir_p t.name.pathmap("%d")
    run_asciidoctor(t.source, t.name)
  end
end

image_files.each do |file|
  file image_dst_path(file) => file do |t|
    mkdir_p t.name.pathmap("%d")
    sh "cp", t.source, t.name
  end
end

desc "Default task"
task :default => [:notes, :visuals, :images]

def run_asciidoctor(src, dst)
  cmd = %Q{asciidoctor \
--trace \
--safe-mode unsafe \
--load-path #{SRC_BASE_DIR} \
--require asciidoctor-sed \
--attribute visuals_template=templates/visuals.html.erb \
--attribute visuals_dir=../discourse-server/course/cos284/visuals \
--destination-dir #{dst.pathmap('%d')} \
#{src}}
  sh cmd
end


# base_dir = Pathname.new(Dir.pwd)
# SRC_BASE_DIR = base_dir.join('course')
# dst_base_dir = base_dir.join('build')
#
# # TODO: this is inelegant
# courses = []
# dst_base_dir.each_entry do |entry|
#   next if entry.to_path.start_with?('.')
#   courses << entry
# end
#
# courses.each do |course|
#   SRC_DIR = SRC_BASE_DIR.join(course)
#   dst_dir = dst_base_dir.join(course)
#
#   Dir.chdir(SRC_DIR) do
#     Dir.glob('*.adoc') do |src_file|
#       src_path = SRC_DIR.join(src_file)
#       html_dst_path = dst_dir.join('notes', src_file)
#       puts "SRC #{src_path}"
#       puts "DST #{html_dst_path}"
#       file html_dst_path => src_path do
#         puts "DO IT"
#       end
#     end
#   end
# end
#
# # Rake::FileList.new('course/**/*.adoc') do |files|
# #   puts files
# # end
#
# task :default
#
# #task :default => 'build/cos284/notes/intro.html'
#
# # Dir.glob('course/*/*.adoc').each do |entry|
# #   puts Pathname.new(entry).each_filename
# #   puts entry
# # end
# #
# # file 'build/cos284/notes/intro.html' => 'course/cos284/intro.adoc' do
# #    puts "hello"
# # end
# # #
