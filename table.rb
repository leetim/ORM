require "sqlite3"

module ORM

	module Database
		@@db
		@@hex = Hash[String => "TEXT", Fixnum => "INTEGER", Float => "FLOAT", Bignum => "INTEGER"]
		@@logic_operations = Hash[nil => "=", :eq => "=", :ne => "<>", :lt => "<", :le => "<=", :gt => ">", :ge => ">="]

		def Database.init(adress)
			@@db = SQLite3::Database.new(adress)
		end

		def Database.transaction()
			@@db.transaction
		end

		def Database.commit()
			@@db.commit
		end

		def Database.close()
			@@db.close
		end
	end

	class Line
		include Database
		@@table_name
		@@fields_writer
		@@fields_reader

		def initialize(values)
			self.load(values)
		end

		def load(values)
			[@@fields_writer, values].transpose.each do |x|
				self.send *x
			end
		end

		def self.make_fields(fields, table_name)
			@@table_name = table_name
			@@fields_reader = fields.unshift(:id)
			@@fields_writer = fields.map{|x| (x.to_s + "=").to_sym}
			fields.each do |x|
				attr_accessor x
			end
		end

		def deleted?()
			@@db.execute("SELECT * FROM #{@@table_name} WHERE id = ?", self.id).empty?
		end

		def delete()
			if not self.deleted?
				@@db.execute("DELETE FROM #{@@table_name} WHERE id = ?", self.id)
			end
		end

		def update(field, value)
			@@db.execute("UPDATE #{@@table_name} SET #{field.to_s} = ? WHERE id = ?", value, self.id)
			self.load @@db.execute("SELECT * FROM #{@@table_name} WHERE id = ?", self.id).shift
		end

		def to_s()
			if not self.deleted? 
				@@fields_reader.map{|x| self.send(x).to_s}.join " " 
			else 
				"deleted"
			end
		end

		def to_a()
			@@fields_reader.map{|i| self.send i}
		end

		def ==(other)
			self.to_a == other.to_a
		end

		def method_missing(name, *args)
			if name.to_s.split("_").size == 2
				method, field = name.to_s.split("_").map(&:to_sym)
				if method != :update or not @@fields_reader.include? field then return nil end
				self.send(method, field, *args)
			else
				return nil
			end
		end
	end

	class Table
		include Database
		@table_name
		@fields
		@line_class

		def initialize()
			a = self.class.instance_methods - Table.instance_methods
			@table_name = self.class.to_s
			@line_class = Class.new(Line)
			@line_class.make_fields a, @table_name
			@fields = a.map &:to_s
			a.shift
			create_table self.class.to_s, a.map(&:to_s), a.map{|x| self.send x}
		end

		def create_table(name, fields, types)
			@table_name = name
			@fields = fields
			s = [fields, types.map{|i| @@hex[i]} ].transpose.map!{|x| x.join(" ")}.join(", ")
			@@db.execute("CREATE TABLE IF NOT EXISTS #{name} (id INTEGER PRIMARY KEY, #{s})")
		end

		def insert(*args)
			@@db.execute("INSERT INTO #{@table_name} (id, #{@fields.join(", ")}) VALUES (#{args.map{"?"}.join(", ")})", *args)
		end

		def update(id, *args)
			@@db.execute("UPDATE #{@table_name} SET #{@fields.map{|x| x + " = ?"}.join ', '} WHERE id = ?", *args, id)
		end

		def delete(logic_op = :eq, field_name = "id", value)
			@@db.execute("DELETE FROM #{@table_name} WHERE #{field_name} #{@@logic_operations[logic_op]} ?", value)
		end

		def select()
			@@db.execute("SELECT * FROM #{@table_name}").map{|x| @line_class.new(x)}
		end

		def find(logic_op = :eq, field_name = "id", value)
			@@db.execute("SELECT * FROM #{@table_name} WHERE #{field_name} #{@@logic_operations[logic_op]} ?", value).map{|x| @line_class.new(x)}
		end

		def method_missing(name, *args)
			s = name.to_s.split "_"
			if s.length <= 3 
				method, field, logic_op = s.map(&:to_sym)
			else
				return nil
			end
			if [:find, :delete].include?(method) and (@fields.map(&:to_sym).push(:id)).include?(field)
				self.send method, logic_op, field, *args
			end
		end

	end

end