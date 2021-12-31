class Dog

    attr_reader :name
    attr_reader :breed
    attr_accessor :id

    def initialize(name:, breed:, id: nil)
        @name=name
        @breed=breed
        @id=id
    end

    def self.create_table()
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table()
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        self

    end

    def self.create(name:, breed:)
        sql=<<-SQL
            INSERT INTO dogs (name, breed)
            VALUES(?, ?)
        SQL

        DB[:conn].execute(sql, name, breed)
        arr = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        Dog.new(name: name, breed: breed, id: arr)
    end

    def self.new_from_db(row)
        Dog.new(id:row[0], name:row[1], breed:row[2])
    end

    def self.all

        sql=<<-SQL
            SELECT *
            FROM dogs
        SQL

        DB[:conn].execute(sql).map do |row|
            Dog.new_from_db(row)
        end
    end

    def self.find_by_name(name)

        sql=<<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        row=DB[:conn].execute(sql, name)
        self.new_from_db(row[0])
    end


    def self.find(id)

        sql=<<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        row=DB[:conn].execute(sql, id)
        self.new_from_db(row[0])
    end

end
