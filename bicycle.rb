#Chapter 2 
#example 1 pg 62 of 623 (sideways ipad)
=begin
chainring  = 52 
cog = 11
ratio = chainring / cog.to_f
p ratio
=end

#example 2 pg 63 of 623
=begin
class Gear
	attr_reader :chainring, :cog

	def initialize(chainring,cog)
		@chainring = chainring
		@cog = cog
	end

	def ratio 
		chainring / cog.to_f
	end
end

p Gear.new(52,11).ratio
=end
#example 3 pg 65 of 623

=begin
class Gear
	attr_reader :chainring, :cog, :rim, :tire

	def initialize(chainring,cog,rim,tire)
		@chainring = chainring
		@cog = cog
		@rim = rim
		@tire = tire
	end

	def ratio 
		chainring / cog.to_f
	end

	def gear_inches
		ratio * ( rim + ( tire * 2 ) )
	end
end

puts Gear.new(52, 11, 26, 1.5).gear_inches
p Gear.new(52,11).ratio #this won't work now
=end

=begin
class RevealingReferences
	attr_reader :wheels
	def initialize(data)
		@wheels = wheelify(data)
	end
	#diameters has no knowledge of the structure of the array
	def diameters
		wheels.collect {|wheel|
			wheel.rim + (wheel.tire * 2) }
	end

	#now everyone can send rim/tire to wheel

	Wheel = Struct.new(:rim, :tire)
	def wheelify(data)
		data.collect {|cell|
			Wheel.new(cell[0],cell[1])}
		end
	end

	test = RevealingReferences.new([[1,2],[2,3]])
	p test.diameters
=end

#because diameters has two responsibilities: iterating over the wheels and calculating the diameter it can be split into two methods.
# sub this in the above code to see it work.

=begin
def diameters 
	wheels.collect { |wheel| diameter(wheel) }
end

def diameter(wheel)
	wheel.rim + (wheel.tire * 2))
end
=end


#you can also add the gear_inches method and refactor it to use diameter instead of calculating it by itself.
#gear class should be calculating gear inches but not diameter
=begin
def diameters 
	wheels.collect { |wheel| diameter(wheel) }
end

def gear_inches
	ratio * diameter
end

def diameter(wheel)
	wheel.rim + (wheel.tire * 2))
end
=end

#b/c gear is not responsible for diameter wheel could be moved into its own class but that is not needed yet and 
#would make the code less changeable at the moment. Below is a way to remove diameter from gear without a new class.

=begin
class Gear
	attr_reader :chainring, :cog, :wheel

	def initialize(chainring,cog,rim,tire)
		@chainring = chainring
		@cog = cog
		@wheel = Wheel.new(rim,tire)
	end

	def ratio 
		chainring / cog.to_f
	end

	def gear_inches
		ratio * wheel.diameter
	end

	Wheel = Struct.new(:rim, :tire) do
		def diameter
			rim + ( tire * 2 )
		end	
	end
end

p Gear.new(52, 11, 26, 1.5).gear_inches
p Gear.new(52,11).ratio #this doesn't work bc arg errors
=end

#in the real world now that you know that the customer needs a wheel circumference as well as diameter to 
#do its job you can now make a wheel class.

=begin
class Gear
	attr_reader :chainring, :cog, :wheel

	def initialize(chainring,cog, wheel=nil)
		@chainring = chainring
		@cog = cog
		@wheel = wheel
	end

	def ratio 
		chainring / cog.to_f
	end

	def gear_inches
		ratio * wheel.diameter
	end

end

class Wheel
	attr_reader :rim, :tire
	
	def initialize(rim, tire)
		@rim = rim
		@tire = tire
	end
		
	def diameter
		rim + ( tire * 2 )
	end	

	def circumference 
		diameter * Math::PI
	end
end

@wheel = Wheel.new(26, 1.5)
p @wheel.circumference
p Gear.new(52, 11, @wheel).gear_inches
p Gear.new(52,11).ratio #this now works
=end

#Chapter 3 Managing Dependencies

#this is an example where gear could be forced to change depending on changes to wheel
# Here gear has 4 dependencies on wheel.
#Gear expects a class name Wheel
#Gear expects a Wheel instance to respond to diameter
#Gear knows that Wheel.new requires rim and tire
#Gear knows the first argument to Wheel.new should be rim and te second be tire

=begin

class Gear
	attr_reader :chainring, :cog, :rim, :tire

	def initialize(chainring,cog,rim,tire)
		@chainring = chainring
		@cog = cog
		@rim = rim
		@tire = tire
	end

	def ratio 
		chainring / cog.to_f
	end

	def gear_inches
		ratio * Wheel.new(rim,tire).diameter
	end

end

class Wheel
	attr_reader :rim, :tire
	
	def initialize(rim, tire)
		@rim = rim
		@tire = tire
	end
		
	def diameter
		rim + ( tire * 2 )
	end	

	def circumference 
		diameter * Math::PI
	end
end
p Gear.new(52, 11, 26, 1.5).gear_inches

=end









