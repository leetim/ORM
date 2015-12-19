require "test/unit"
require "simplecov"

SimpleCov.start

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
		[9, "D", "Bespalov", 13],
		[10, "D", "Bespalov", 13],
		[11, "D", "Bespalov", 13],
		[2, "B", "Batrakov", 13],
		[3, "C", "Batrakov", 13],
		[4, "D", "Batrakov", 13],
		[5, "E", "Batrakov", 13],
		[6, "F", "Batrakov", 13]
	]

	def test01_select
		@@x.each do |i|
			@@a.insert(*i)
			self.assert(@@a.find(i.shift)[0].to_a == i)
		end
	end
end

# Test::Unit::UI::Console::TestRunner.run MyTest
# p Test

# Бывает же
# a = Test2.new
# a.deleteby_name_eq("D")
# r = a.select
#p r
# r.each do |line|
	#line.update_price(112)
# 	puts line.to_s
# end
# p a.findby_name_gt "b"
# p 1
# p "asss".to_sym
# p "asss".class.instance_methods
# a.insert(9, "D", "Bespalov", 13)
# a.insert(10, "D", "Bespalov", 13)
# a.insert(11, "D", "Bespalov", 13)
# a.insert(2, "B", "Batrakov", 13)
# a.insert(3, "C", "Batrakov", 13)
# a.insert(4, "D", "Batrakov", 13)
# a.insert(5, "E", "Batrakov", 13)
# a.insert(6, "F", "Batrakov", 13)
# a.commit
# ORM::Database.close

# p ORM::Table