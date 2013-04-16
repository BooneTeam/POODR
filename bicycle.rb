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
# A class should know just enough to do its job. No More!
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

#Injecting Dependencies
#This now expects a "duck" that knows "diameter"
#Gear can now collaborate with any instance that implements diameter

=begin
class Gear
	attr_reader :chainring, :cog, :wheel

	def initialize(chainring, cog, wheel)
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

p Gear.new(52,11, Wheel.new(26,1.5)).gear_inches
=end

#if you are constrained and canot change the code to inject a wheel into gear, isolate the creation of wheel inside the gear class
#do this to expose the dependency while reducing reach into the class.

#moved from gear_inches method to to gears init method (unintentionally creates a gear each time a gear is created)
=begin
class Gear
	attr_reader :chainring, :cog, :wheel
	def initialize(chainring, cog, rim, tire)
		@chainring = chainring
		@cog = cog
		@wheel = Wheel.new(rim, tire)
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

p Gear.new(52,11, 26,1.5).gear_inches
=end

#this alternative creates wheel in its own explicitly defined wheel method.
=begin

class Gear
	attr_reader :chainring, :cog, :rim, :tire

	def initialize(chainring, cog, rim, tire)
		@chainring = chainring
		@cog = cog
		@rim =  rim
		@tire = tire
	end

	def ratio 
		chainring / cog.to_f
	end

	def gear_inches
		ratio * wheel.diameter
	end

	def wheel 
		@wheel ||= Wheel.new(rim, tire)
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

p Gear.new(52,11, 26,1.5).gear_inches

=end

#this is more DRY and removes the dependency of wheel from gear_inches.
=begin
	
def gear_inches
	ratio * diameter
end

def diameter
	wheel.diameter
end

=end

#Use Hashes for Initialization Arguments to avoid having fixed-order arguments
#if using a method whose param list in lengths and unstable this is a good technique
#if writing for your own use that multiplies two numers it is far simpler to accept dependency on order.
=begin
class Gear
	attr_reader :chainring, :cog, :wheel
	def initialize(args)
		@chainring = args[:chainring]
		@cog 	   = args[:cog]
		@wheel 	   = args[:wheel]
	end

	def ratio 
		chainring / cog.to_f
	end

	def gear_inches
		ratio * wheel.diameter
	end

	def wheel 
		@wheel ||= Wheel.new(rim, tire)
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

p Gear.new(
	:chainring => 52,
	:cog 	   => 11, 
	:wheel     => Wheel.new(26,1.5)).gear_inches
=end

#You can use non-boolean defaults using  || to use both techniques (hash and/or ordered)
# if using boolean arguments or need to distinguish b/w false and nil use the fetch method instead of || (or)

=begin
class Gear
	attr_reader :chainring, :cog, :wheel
	def initialize(args)
		@chainring = args[:chainring] || 40
		@cog 	   = args[:cog]		  || 18
		@wheel 	   = args[:wheel]
	end

	def ratio 
		chainring / cog.to_f
	end

	def gear_inches
		ratio * wheel.diameter
	end

	def wheel 
		@wheel ||= Wheel.new(rim, tire)
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

p Gear.new(
	#:chainring => 52,
	#:cog 	   => 11, 
	:wheel     => Wheel.new(26,1.5)).gear_inches

=end

#The fetch method expects the key you are fetching to be in the hash and supplies several options for handling missing keys
#It does not automatically return nil when it fails to find your key
#This means you can set it to nil or false if you need to instead of it always returning the default


=begin
class Gear
	attr_reader :chainring, :cog, :wheel
	def initialize(args)
	@chainring = args.fetch(:chainring, 40)
	@cog 		= args.fetch(:cog, 18)
	@wheel 		= args[:wheel]
	end

	def ratio 
		if cog == false 
			"It's False!"
		else
			chainring / cog.to_f 
		end
	end

	def gear_inches
		ratio * wheel.diameter
	end

	def wheel 
		@wheel ||= Wheel.new(rim, tire)
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
	
	p Gear.new(
		#:chainring => 52,
		:cog 	   => false, #this breaks the gear_inches though 
		:wheel     => Wheel.new(26,1.5)).ratio

=end


# The defaults method below defines a hash that's merged into the options hash during init.
#In this case merge has the same effect as fetch; defaults will only get merged if their keys arent in the hash
# if defaults are more than simple numbers or strings implement a default method or do it anyways b/c its cleaner and clearer.

=begin
class Gear
	attr_reader :chainring, :cog, :wheel
	def initialize(args)
		args = defaults.merge(args)
		@chainring = args[:chainring]
		@cog 		= args[:cog]
		@wheel 		= args[:wheel]
	end

	def defaults
	{:chainring => 40, :cog => 18}
	end

	def ratio 
		if cog == false 
			"It's False!"
		else
			chainring / cog.to_f 
		end
	end

	def gear_inches
		ratio * wheel.diameter
	end

	def wheel 
		@wheel ||= Wheel.new(rim, tire)
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
	
	p Gear.new(
		#:chainring => 52,
		#:cog 	   => 11,
		:wheel     => Wheel.new(26,1.5)).gear_inches

=end

#Sometimes you'll be forced to depeend on a method that requires
#fixed-order args where you dont own and cant change the method itself
#Say gears init method is external to your app and has many places you must create a new instance
#you can create a method to wrap the eternal interface. classes in your app should depend on code you own.

#someframework is not owned by you. The gearwrapper module avoids having multiple dependencies on order.


=begin
module SomeFramework
	class Gear
		attr_reader :chainring, :cog, :wheel

		def initialize(chainring, cog, wheel)
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
	#wrap interface to protect from changes
	#gearwrapper is responsible fore creating instances of SomeFramework::Gear
	# This is called a factory. An object that creates other objects.
	module GearWrapper
		def self.gear(args)
			SomeFramework::Gear.new(args[:chainring],
									args[:cog],
									args[:wheel])
		end
	end


	# used to have to do this p Gear.new(52,11, Wheel.new(26,1.5)).gear_inches
	#now do this
	p GearWrapper.gear(
		:chainring => 52,
		:cog 	   => 11,
		:wheel     => Wheel.new(26,1.5)).gear_inches

=end

#Managing Dependency Direction

# Think of classes as people. Tell them to depend on things that change less often than you do.
# -- Some classes are more likely than others to have changes in requirements
# -- Concrete classes are more likely to change than abstract classes
# -- Changing a class tha has many dependants will result in widespread consequences.

# depending on abstraction is always safer than concretion


# Chapter 4 - Creating Flexible Interfaces

# - A OO App is more than just classes. It is made up of classes but defined by messages
# Clases control whats in your source code repository; messages reflect the living application.

# A class is like a kitchen. It exists to fulfill a single responsibilty but has many methods.
# some methods are public like menu others are private like how to make the food.

# Public Interface - The face it presents to the world
# -- Reveal primary responsibility
# -- Expected to be invoked by others
# -- Will not change on a whim
# -- Are safe for others to depend on
# -- Are thoroughly documented in the tests

# -- Public Interfaces rule of thumb list
# -- Be explicitly identified as such
# -- Be more about what than how
# -- Have names that, insofar as you can anticipate, will not change
# -- Take a hash as an options parameter

# Private Interfaces - All others in the class
# -- Handle implentation details
# -- Are not expected to be sent by other objects
# -- Can change for any reason whatsoever
# -- Are unsafe for others to depend on
# -- May not even be referenced in the tests

# Public, Protected, and Private are used to indicate which methods are stable or unstable
# -- They also control how visible a method is to other parts of your application.

# Private - denotes the least stable kind of method and provides most restricted visibility.
# -- These methods must be called with an implicit receiver and may never be called with explicit receiver.
# --- If class Trip contains private method fun you cannot send self.fun from within Trip or a_trip.fun from another object.
# you may send fun defaulting to self from witihin instances of Trip and its subclasses

# Protected - indicates unstable method, but with different visibility restrictions. Allow explicit receivers
# as long as receiver is self or instance of same class or subclass of self.
# -- self.fun is possible but only from within a class where self is the same thing as a_trip

# Public methods indicate a stable method. They are visible everywhere

# Law of Demeter
# - Prohibits routing a message to a third object via a second object of a different type.
# - "Only talk to your immediate neighbors" - "Use only one dot"
# hash.keys.sort.join("") is reasonable. customer.bicycle.wheel.rotate is not.


# Chapter 5. Reducing costs with Duck Typing.

# -- Duck types are public interfaces taht are not tied to any specific class. 
=begin
class Trip
	attr_reader :bicycles, :customers, :vehicle

	#this mechanic argument could be of any class
	def prepare(mechanic)
		mechanic.prepare_bicycles(bicycles)
	end
end

#if you happen to pass an instance of *this* class it workds

class Mechanic
	def prepare_bicycles(bicycles)
		bicycles.each { |bicycle| prepare_bicycle(bicycle) }
	end

	def prepare_bicycle(bicycle)
	end
end
=end

=begin
# This code below can put you in a corner with no way out
# Sequence diagrams should be simpler than the code they represent

class Trip
	attr_reader :bicycles, :customers, :vehicle

	#this mechanic argument could be of any class
	def prepare(preparers)
		preparers.each { |preparer| 
			case preparer
			when Mechanic
				preparer.prepare_bicycles
			when TripCoordinator
				perparer.buy_food(customers) 
			when Driver
				preparer.gas_up(vehicle)
				preparer.fill_water_tank(vehicle)
			end
		}
	end
end

class Mechanic
	def prepare_bicycles(bicycles)
		bicycles.each { |bicycle| prepare_bicycle(bicycle) }
	end

	def prepare_bicycle(bicycle)
	end
end

class TripCoordinator
	def buy_food(customers)
		#
	end
end

class Driver 
	def gas_up(vehicle)
		#
	end

	def fill_water_tank(vehicle)
		#
	end
end
=end

=begin
#trip preparation becomes easier
class Trip
	attr_reader :bicycles, :customers, :vehicle

	def prepare(preparers)
		preparers.each { |preparer|
			preparer.prepare_trip(self) }
	end
end

#when every preparer is a Duck that respoonds to 'prepare_trip'

class Mechanic 
	def prepare_trip(trip)
		trip.bicycles.each {|bicycle|
			prepare_bicycle(bicycle) }
	end
end

class TripCoordinator
	def prepare_trip(trip)
		buy_food(trip.customers)
	end

class Driver 
	def prepare_trip(trip)
		vehicle = trip.vehicle
		gas_up(vehicle)
		fill_water_tank(vehicle)
	end
end
=end
# The prepare method can now accept new preparers
# without being forced to change, and its easy to create additional preparers if the need arises

# Recognizing when you need a duck.
# -- Case statements that switch on class
# -- kind_of? and is_a?
# -- responds_to?

=begin
# this indicates that prepares must share something. Your'e job is to find that something.
# "What is it that prepare wants from each of its arguments"
# This wants its prepare argument to prepare the trip this prepare_trip becomes a method of the Preparer duck

def prepare(preparers)
		preparers.each { |preparer| 
			case preparer
			when Mechanic
				preparer.prepare_bicycles
			when TripCoordinator
				perparer.buy_food(customers) 
			when Driver
				preparer.gas_up(vehicle)
				preparer.fill_water_tank(vehicle)
			end
end
=end

# kind_of? and is_a?
=begin
	if preparer.kind_of?(Mechanic)
		#something
	elsif preparer.kindof?(Driver)
		#something else
	end	
	# This is no different than teh case example above and should be handled with a duck type.
		# if kind_of? is checking on a Ruby class such as Integer or Hash this is acceptable as this
		# is much less likey to change in the future.
=end

# Responds_to?
=begin
	if preparer.responds_to?(:prepare_bicycles)
		#something
	elsif preparer.responds_to?(:buy_food)
		#something else
	end
 	# This slightly decreases dependency but it still has too many
 	# the class names are gone but the code is stil bound to class.
 	#this still expects very specific classes. This controls rather than trusts objects
=end

# Doc your Ducks
	# when creating Duck types document and test their public interfaces. 

	
# Chapter 6 Acquiring behavior through inheritance





