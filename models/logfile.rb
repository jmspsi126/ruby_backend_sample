require 'date'
require 'time'

class InvalidLogfilePathError < StandardError
end

class FindLogfiles
  attr_accessor :root_path, :dir, :entries, :ext
  include Enumerable

  def initialize(options = {})
    options = { ext: "zip"}.merge(options)

    @root_path = options[:root_path]
    @dir = options[:dir]
    @ext = options[:ext]
  end

  def all(options={})
    self.entries = in_root_directory do
      dir.glob(glob(options)).map do |f|
        Logfile.new_with_filename(f).tap { |l| l.root = @root_path }
      end
    end
    self
  end

  def sort_by_date
    self.entries = self.entries.sort_by{ |f| f.date }.reverse
    self
  end

  def arrange_by_date
    self.entries = sort_by_date.inject([]) do |files, file|
      files.tap do |files|
        month_year = (files.find do |f|
          f[:month_year] == file.month_year
        end) || ({
          month_year: file.month_year, items: []
        })

        files << month_year unless files.include?(month_year)
        month_year[:items] << file
      end
    end
    self
  end

  def [](index)
    entries[index]
  end

  def each(&block)
    entries.each(&block)
  end

  def length
    entries.length
  end

  def to_json(options={})
    entries.to_json(options)
  end

  def << (item)
    entries << item
  end

  def include(others)
    others.each { |o| self.entries << o }
    self
  end

  private
  def glob(options)
    no_pad = pad = proc { |d| d.to_s }

    components = [
      component(options[:customer_id], pad),
      component(options[:year], no_pad),
      component(options[:month], pad),
      component(options[:day], pad),
      component(options[:locomotive_id], pad),
      component(options[:system_id], pad),
      (options[:filename] || "*.#{ext}")
    ]
    File.join(*components)
  end

  def in_root_directory(&block)
    old_working_dir = dir.pwd
    dir.chdir root_path
    block.call.tap { dir.chdir old_working_dir }
  end

  def component(part, formatter)
    part = part.nil? ? "*" : formatter.call(part)
  end
end

class Logfile
  attr_accessor :path, :customer_id, :date, :locomotive_id, :system_id,
    :filename, :url, :new, :root, :absolute_path, :label

  def self.all(root_path, options)
    FindLogfiles.new(dir: Dir, root_path: root_path).all(options)
  end

  def self.find(root_path, options)
    all(root_path, options).first
  end

  def self.new_with_filename(filename)
    attrs = filename.split('/')
    raise InvalidLogfilePathError, "Invalid logfile path: #{filename}" if attrs.length != 7

    self.new({
      path: filename,
      customer_id: attrs.shift.to_i,
      date: Date.parse("#{attrs.shift}-#{attrs.shift}-#{attrs.shift}"),
      locomotive_id: attrs.shift.to_i,
      system_id: attrs.shift.to_i,
      filename: attrs.shift
    })
  end

  def initialize(options={})
    options = { date: Date.today }.merge(options)

    options.each { |k, v| self.send("#{k}=", v) }
  end

  def url
    File.join("/api", "locomotives", @locomotive_id.to_s, "systems",
              @system_id.to_s, "logfiles", @date.year.to_s,
              @date.month.to_s, @date.day.to_s, @filename.to_s)
  end

  def month_year
    self.date.strftime("%B %Y")
  end

  def absolute_path
    File.join("#{self.root}", "#{self.path}") if self.root
  end

  def new?(file_system=File)
    if absolute_path && file_system.exists?(absolute_path)
      file_system.ctime(absolute_path) >= (Time.now - 120)
    else
      false
    end
  end

  def label
    @label ||= self.date
  end

  def exists?
    absolute_path && File.exists?(absolute_path)
  end

  def attributes
    self.instance_variables.inject({}) do |attrs, ivar|
      key = ivar.to_s[1..-1].to_sym
      attrs.tap { |attrs| attrs[key] = instance_variable_get(ivar) }
    end.tap do |attrs|
      attrs[:new] = self.new?
      attrs[:label] = self.label
      attrs[:exists] = self.exists?
      attrs[:url] = self.url
      attrs.delete :root
    end
  end

  def as_json(options={})
    attributes
  end

  def to_json
    attributes.to_json
  end

end

