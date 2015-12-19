require "simplecov"

SimpleCov.start

require "test/unit"
require_relative "table"

system("rm test.sqlite")
ORM::Database.init("test.sqlite")

class Test2 < ORM::Table
	define_method(:name){String}
	define_method(:surname){String}
	define_method(:price){Fixnum}
end


class MyTest < Test::Unit::TestCase
	@@a = Test2.new
	@@x = [
		[9, "D", "Bespalov", 100],
		[10, "D", "Teterin", 502],
		[11, "D", "Kurochkin", 323],
		[2, "B", "Lavandov", 2555],
		[3, "C", "Prihod\'ko", 2020],
		[4, "D", "Karpov", 90],
		[5, "E", "Tartarov", 615],
		[6, "F", "Lebedev", 100000]
	]

	def test01_insert
		@@x.each do |i|
			self.assert(@@a.insert(*i) == [])
			self.assert(@@a.find(i.shift)[0].to_a == i)
		end
	end

	def test02_select 
		@@x.each do |i|
			self.assert(@@a.select.map(&:to_a).include? i.to_a)
		end
	end

	def test03_delete
		@@a.insert(1001, "Del", "IVANOV", 242)
		@@a.insert(1002, "Del", "IVANOV", 242)
		@@a.insert(1003, "Del", "IVANOV", 242)
		@@a.insert(1004, "Del", "IVANOV", 242)
		a = @@a.find_name_eq("Del").map &:to_a
		self.assert_equal(a, [["Del", "IVANOV", 242], ["Del", "IVANOV", 242], ["Del", "IVANOV", 242], ["Del", "IVANOV", 242]])
		@@a.delete(1001)
		self.assert_equal(@@a.find(1001), [])
		@@a.delete_id_gt(1002)
		self.assert_equal(@@a.find_id_gt(1002), [])
		@@a.delete_name_eq("Del")
		self.assert_equal(@@a.find_name_eq("Del"), [])
	end

	def test04_update
		@@a.insert(1001, "Upd", "IVANOV1", 2410000)
		@@a.insert(1002, "Upd", "IVANOV2", 2420000)
		@@a.insert(1003, "Upd", "IVANOV3", 2430000)
		@@a.insert(1004, "Upd", "IVANOV4", 2440000)
		@@a.update(1001, "Upd", "Petrov1", 2410000)
		self.assert_equal(@@a.find(1001)[0].surname, "Petrov1")
		@@a.update(1002, "Upd", "Petrov2", 242)
		self.assert_equal(@@a.find(1002)[0].surname, "Petrov2")
		@@a.update(1003, "Upd", "Petrov3", 243)
		self.assert_equal(@@a.find(1003)[0].surname, "Petrov3")
		@@a.update(1004, "Upd", "Petrov4", 244)
		self.assert_equal(@@a.find(1004)[0].surname, "Petrov4")
		@@a.delete_name_eq("Upd")
	end

	def test05_find
		@@a.insert(1001, "find", "IVANOV1", 2410000)
		@@a.insert(1002, "find", "IVANOV2", 2420000)
		@@a.insert(1003, "find", "IVANOV3", 2430000)
		@@a.insert(1004, "find", "IVANOV4", 2440000)

		@@a.find_name_eq("find").each do |x|
			self.assert_equal x.name, "find"
		end

		@@a.find_surname_lt("L").each do |x|
			self.assert x.surname < "L" 
		end

		@@a.find_price_ge(1000).each do |x|
			self.assert x.price >= 1000 
		end

		@@a.delete_name_eq("find")
	end

	def test06_to_s
		args = [
			[1001, "string", "IVANOV", 2410000],
			[1002, "string", "Karpov", 2420000],
			[1003, "string", "Tartarov", 2430000],
			[1004, "string", "Lebedev", 2440000]
		]
		args.each do |x|
			@@a.insert(*x)
			x.shift
		end
		args.map!{|x| x.map(&:to_s).join(" ")}
		@@a.find_id_gt(1000).each do |x|
			self.assert(args.include? x.to_s)
		end
	end

	def test07_delete
		@@a.find_id_gt(1000).each do |x|
			x.delete()
			self.assert_equal(x.to_s, "deleted")
		end
	end

	def test08_update
		@@a.insert(1001, "update", "IVANOV1", 2410000)
		@@a.insert(1002, "update", "IVANOV2", 2420000)
		@@a.insert(1003, "update", "IVANOV3", 2430000)
		@@a.insert(1004, "update", "IVANOV4", 2440000)
		a = @@a.find_name_eq("update")
		a.each do |x|
			x.update_name "updated"
			assert_equal(@@a.find(x.id)[0], x)
		end
	end

	def test09_wrong_comand_and_fields
		self.assert_equal(@@a.foo(13), nil)
		self.assert_equal(@@a.update_foo_eq(13), nil)
		self.assert_equal(@@a.delete_bar_eq(13), nil)
		self.assert_equal(@@a.find_bar_eq(13), nil)
		self.assert_equal(@@a.find_bar_eq_assa_dsada(13), nil)

		@@a.select.each do |x|
			self.assert_equal(x.foo, nil)
			self.assert_equal(x.update_foo, nil)
		end
	end

	def test10_
		@@a.insert(1011, "update", "IVANOV1", 2410000)
		el = @@a.find(1011)[0]
		self.assert_equal(el.id, 1011)
		self.assert_equal(el.name, "update")
		self.assert_equal(el.surname, "IVANOV1")
		self.assert_equal(el.price, 2410000)

		el.update_name "Vasya"
		el.update_surname "Petrov"
		el.update_price 0

		self.assert_equal(@@a.find(1011)[0], el)
	end
end