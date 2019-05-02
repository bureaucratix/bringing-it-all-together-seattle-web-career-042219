require 'Pry'
class Dog
  @@all = []
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
    @@all << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    self if @id.nil?
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, name, breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end

  def self.create(hash)
    doggie = new(hash)
    doggie.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    arr = DB[:conn].execute(sql, id).flatten
    new(id: id, name: arr[1], breed: arr[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    arr = DB[:conn].execute(sql, name).flatten
    new(id: arr[0], name: name, breed: arr[2])
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    arr = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
    # binding.pry
    if arr.empty?
      create(hash)
    else
      @@all.find { |dog| dog.name == arr[1] && dog.breed == arr[2] }
    end
  end

  def self.new_from_db(row)
    new({id:row[0], name: row[1], breed: row[2]})
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, breed, id)
  end

end
