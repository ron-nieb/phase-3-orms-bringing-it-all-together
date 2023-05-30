class Dog
    attr_accessor :id, :name, :breed
  
    def initialize(attributes)
      @id = attributes[:id]
      @name = attributes[:name]
      @breed = attributes[:breed]
    end
  
    def self.create_table
      DB[:conn].execute(<<-SQL)
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
    end
  
    def self.drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end
  
    def save
      if self.id
        update
      else
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end
  
    def self.create(attributes)
      dog = Dog.new(attributes)
      dog.save
    end
  
    def self.new_from_db(row)
      attributes = { id: row[0], name: row[1], breed: row[2] }
      Dog.new(attributes)
    end
  
    def self.all
      sql = "SELECT * FROM dogs"
      rows = DB[:conn].execute(sql)
      rows.map { |row| new_from_db(row) }
    end
  
    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
      row = DB[:conn].execute(sql, name).first
      new_from_db(row)
    end
  
    def self.find(id)
      sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
      row = DB[:conn].execute(sql, id).first
      new_from_db(row)
    end
  
    private
  
    def update
      DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end
  
    def self.db
      @db ||= SQLite3::Database.new(":memory:")
    end
  
    def self.setup_database
      DB[:conn] = db
      create_table
    end
  end
