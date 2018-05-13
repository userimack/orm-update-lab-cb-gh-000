require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql =<<-SQL
    CREATE TABLE students (
    id integer primary key,
    name text,
    grade integer
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students;")
  end

  def save
    if self.id
      self.update
    else
      sql =<<-SQL
      INSERT INTO students(name, grade) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() from students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = self.new(name = name, grade = grade)
    new_student.save
  end

  def self.new_from_db(row)
    self.new(id=row[1], name=row[2], grade=row[0])
  end

  def self.find_by_name(name)
    sql=<<-SQL
    SELECT * from students where name = ? limit 1
    SQL
    DB[:conn].execute(sql, name).map {|s| new_from_db(s)}.first
  end

  def update
    sql =<<-SQL
    UPDATE students set name = ?, grade =? where id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end