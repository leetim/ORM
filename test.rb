require_relative "orm"
require "test/unit"

class Test2 < ORM::Table
	ORM::Database.init "test1.sqlite"
	define_method(:name){String}
	define_method(:surname){String}
	define_method(:price){Fixnum}
end

class MyTest < Test::Unit::TestCase
	def test01
		self.assert(true)
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