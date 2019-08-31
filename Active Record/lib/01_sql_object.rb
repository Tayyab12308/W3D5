require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    table = self.table_name
    @data ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table}
    SQL
    @data.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) { attributes[column] }
      define_method("#{column}=") { |value| attributes[column] = value }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    self.parse_all(data)
  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
    SQL
    return nil if data.empty? || data.nil?
    self.new(data.first)
  end

  def initialize(params = {})
    # ...
    params.each do |key, value|
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key.to_sym)
      send("#{key}=", value)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    @attributes.values
  end

  def insert
    # ...
    # debugger
    col_names = self.class.columns[1..-1]
    question_marks = ["?"] * (col_names.length - 1)
    attributes = self.attribute_values
    DBConnection.execute(<<-SQL, attributes)
      INSERT INTO
        #{self.class.table_name} (#{*col_names})
      VALUES
        (#{question_marks})
    SQL
    # debugger
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
