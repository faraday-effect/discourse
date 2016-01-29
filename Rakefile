# Rakefile

require 'pathname'

base_dir = Pathname.new(Dir.pwd)
src_base_dir = base_dir.join('course')
dst_base_dir = base_dir.join('build')

# TODO: this is inelegant
courses = []
dst_base_dir.each_entry do |entry|
  next if entry.to_path.start_with?('.')
  courses << entry
end

courses.each do |course|
  src_dir = src_base_dir.join(course)
  dst_dir = dst_base_dir.join(course)

  Dir.chdir(src_dir) do
    Dir.glob('*.adoc') do |src_file|
      src_path = src_dir.join(src_file)
      dst_path = dst_dir.join('notes', src_file)
      puts "SRC #{src_path}"
      puts "DST #{dst_path}"
      file dst_path => src_path do
        puts "DO IT"
      end
    end
  end
end

# Rake::FileList.new('course/**/*.adoc') do |files|
#   puts files
# end

task :default

#task :default => 'build/cos284/notes/intro.html'

# Dir.glob('course/*/*.adoc').each do |entry|
#   puts Pathname.new(entry).each_filename
#   puts entry
# end
#
# file 'build/cos284/notes/intro.html' => 'course/cos284/intro.adoc' do
#    puts "hello"
# end
# #
