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

# Inheritance at its core is a mechanism for automatic message delegation. 
# When to use inheritance
	# -- 

=begin
class Bicycle
	attr_reader :size, :tape_color

	def initialize(args)
		@size 		= args[:size]
		@tape_color = args[:tape_color]
	end

	def spares
		#normally should not put defaults in the method. But ok for this example.
		{ chain: "10-speed",
	      tire_size: "23",
	      tape_color: tape_color }
	end

end

bike = Bicycle.new(
	size: 'M',
	tape_color: 'red')
p bike.size
p bike.spares
=end


#Structuring code as below can have many negative consequences. 
# -- if add new style the if statement must change.
# -- careless code where last option is default an unexpected style could do something that is not expected.
# -- some strings are now duplicated in the code for the defaults "10-speed"
# Think of the class of an object as a specifica case of an attribute that holds the category of self.
# **Inheritance provides a way to define two objects as having a relationship such that when the first receives a message
# that it does not understand it automatically forwards the message to the second.
=begin
class Bicycle
	attr_reader  :style, :size, :tape_color, :front_shock, :rear_shock

	def initialize(args)
		@style 		= args[:style]
		@size 		= args[:size]
		@tape_color = args[:tape_color]
		@front_shock= args[:front_shock]
		@rear_shock = args[:rear_shock]
	end

	def spares
		#normally should not put defaults in the method. But ok for this example.
		if style == :road
		{ chain: "10-speed",
	      tire_size: "23",
	      tape_color: tape_color }
	  else
	  	{ chain: "10-speed",
	  		tire_size: "2.1",
	  		rear_shock: rear_shock }
	  	end
	end
end

bike = Bicycle.new(
	style: :mountain,
	front_shock: "Minotaur",
	rear_shock: "Fox",
	size: 'M',
	tape_color: 'red')
p bike.size
p bike.spares
=end

=begin
class Bicycle
	attr_reader  :style, :size, :tape_color, :front_shock, :rear_shock

	def initialize(args)
		@style 		= args[:style]
		@size 		= args[:size]
		@tape_color = args[:tape_color]
		@front_shock= args[:front_shock]
		@rear_shock = args[:rear_shock]
	end

	def spares
		#normally should not put defaults in the method. But ok for this example.
		{ chain: "10-speed",
	      tire_size: "23",
	      tape_color: tape_color }
	end
end
# this now creates some behavior taht doesnt make sense such as inheriting the defaults for the original road bike taht do not work with mtn bikes

class MountainBike < Bicycle
	attr_reader :front_shock, :rear_shock

	def intialize(args)
		@front_shock = args[:front_shock]
		@rear_shock = args[:rear_shock]
		super(args)
	end
	def spares
		super.merge(rear_shock: rear_shock)
	end
end
mtnbike = MountainBike.new(
	front_shock: "Minotaur",
	rear_shock: "Fox",
	size: 'M',)
p mtnbike.size
p mtnbike.spares
=end

# for inheritance to work two rules must be followed
# -- objects taht you are modeling must truly havea generalization-specialization relationship.
# -- you must use the correct coding techniques

=begin
class Bicycle 
	attr_reader :size, :chain, :tire_size

	def initialize(args={})
		@size = args[:size]
		@chain = args[:chain]
		@tire_size = args[:tire_size]
	end

	def spares
		{ chain: "10-speed",
	      tire_size: "23" }
	 end
end
# It is easier to move the entire bicycle class into roadbike and then promote back up to bicycle so that no artifacts are left behind.
#RoadBike now inherits the size method frim bicycle. When roadbike receives size Ruby dlegates the message up the superclass chain.
class RoadBike < Bicycle
	attr_reader  :tape_color

	def initialize(args)
		@tape_color = args[:tape_color]
		super(args)
	end

	def spares
		#normally should not put defaults in the method. But ok for this example.
		{ 
	      tape_color: tape_color }
	end
end
# this now creates some behavior taht doesnt make sense such as inheriting the defaults for the original road bike taht do not work with mtn bikes

class MountainBike < Bicycle
	attr_reader :front_shock, :rear_shock

	def intialize(args)
		@front_shock = args[:front_shock]
		@rear_shock = args[:rear_shock]
		super(args)
	end
	def spares
		super.merge(rear_shock: rear_shock)
	end
end
rdbike = RoadBike.new(
	tape_color: "Red",
	size: 'M',)
p rdbike.size
p rdbike.spares
=end


=begin
class Bicycle 
	attr_reader :size, :chain, :tire_size
	# However, now that there is a  default_tire_size needed as a method we need to document that this must be inside every new bicycle subclass.
	# You need to implement a default_tire_size raise NotImplementedError.

	def initialize(args={})
		@size = args[:size]
		@chain = args[:chain] || default_chain
		@tire_size = args[:tire_size] || default_tire_size
	end

	
	def spares
		{ chain: "10-speed",
	      tire_size: "23" }
	end

	def default_chain
		'10-speed'
	end

	#* This provides documentation for later users of the program that they need a default_tire_size method.
	#While you may rely on only raising the error to track down this error you should add additional documentation.
	#Attention to detail marks you as a serious programmer
	def default_tire_size
		raise NotImplementedError,
			"This #{self.class} cannot respond to:"
	end
end
# It is easier to move the entire bicycle class into roadbike and then promote back up to bicycle so that no artifacts are left behind.
#RoadBike now inherits the size method frim bicycle. When roadbike receives size Ruby dlegates the message up the superclass chain.
class RoadBike < Bicycle
	attr_reader  :tape_color

	def initialize(args)
		@tape_color = args[:tape_color]
		super(args)
	end

	def default_tire_size 
		'23'
	end

	def spares
		#normally should not put defaults in the method. But ok for this example.
		{ 
	      tape_color: tape_color }
	end
end
# this now creates some behavior taht doesnt make sense such as inheriting the defaults for the original road bike taht do not work with mtn bikes

class MountainBike < Bicycle
	attr_reader :front_shock, :rear_shock

	def intialize(args)
		@front_shock = args[:front_shock]
		@rear_shock = args[:rear_shock]
		super(args)
	end

	def default_tire_size
		'2.1'
	end

	def spares
		super.merge(rear_shock: rear_shock)
	end
end

class RecumbentBike < Bicycle
	def default_chain
		'9-speed'
	end
end
rdbike = RoadBike.new(
	tape_color: "Red",
	size: 'M',)
p rdbike.size
p rdbike

bent = RecumbentBike.new
=end

 # This hieararchy below workds however, it still contains a booby trap.
 # B/c both bikes know things about themselves and their superclass these become dependencies
 # If someone creates a new subclass and forgets to send super in the initialize then nothing will get initialized except for the inputs by the user. All defaults will be nil.
 # This can also happen if super is missed in the spares method and the hash will be wrong. No one will notice this until it is too late.
 # This new example adds spares to Bicycle so that MountainBike can now use the spares can be implemented by its superclass and merged with its own spares.
=begin
class Bicycle 
	attr_reader :size, :chain, :tire_size

	def initialize(args={})
		@size = args[:size]
		@chain = args[:chain] || default_chain
		@tire_size = args[:tire_size] || default_tire_size
	end

	def spares
		{ chain: chain,
	      tire_size: tire_size }
	end

	def default_chain
		'10-speed'
	end

	def default_tire_size
		raise NotImplementedError,
			"This #{self.class} cannot respond to:"
	end
end
class RoadBike < Bicycle
	attr_reader  :tape_color

	def initialize(args)
		@tape_color = args[:tape_color]
		super(args)
	end

	def default_tire_size 
		'23'
	end
	# Changed this to mirror mountain bikes to bring RoadBike along with the spares in Bicycle.
	def spares
		#normally should not put defaults in the method. But ok for this example.
	      super.merge({tape_color: tape_color})
	end
end

class MountainBike < Bicycle
	attr_reader :front_shock, :rear_shock

	def initialize(args)
		@front_shock = args[:front_shock]
		@rear_shock = args[:rear_shock]
		super(args)
	end

	def default_tire_size
		'2.1'
	end

	def spares
		super.merge({rear_shock: rear_shock})
	end
end

class RecumbentBike < Bicycle
	def default_chain
		'9-speed'
	end
end
rdbike = RoadBike.new(
	tape_color: "Red",
	size: 'M')
p rdbike.size
p rdbike.spares

mtnbike = MountainBike.new(
	front_shock: "Fox",
	size: "L",
	rear_shock: "Mongoose"
	)
p mtnbike

rcmbike = RecumbentBike.new

=end

# All of the problems with the above implementation can be avoided using hooks.This removes knowledge of algorithm from sublcasses and returns control to superclass.
# These hooks exists solely to provide subclasses a place to contribute information by implementing matching methods.

=begin

class Bicycle 
	attr_reader :size, :chain, :tire_size

	def initialize(args={})
		@size = args[:size]
		@chain = args[:chain] || default_chain
		@tire_size = args[:tire_size] || default_tire_size
		post_initialize(args) #bicycle sends this and implements 
	end
	#This
	# This change doesnt remove only the send of super but removes the initialize method altogether from subclasses.
	# subclasses may override
	# Subclasses are still responsible for what they initialize but not when it occurs.
	def post_initialize(args)
		nil
	end

	def spares
		{ chain: chain,
	      tire_size: tire_size }.merge(local_spares)
	end
	# by adding local spares instead of the call to super this decouples them further and adds a hook. 
	# Bicycle provides a default implementation that returns an empty hash. RoadBike overrides it to return in own version of local_spares.
	def local_spares
		{}
	end

	def default_chain
		'10-speed'
	end

	def default_tire_size
		raise NotImplementedError,
			"This #{self.class} cannot respond to:"
	end
end

class RoadBike < Bicycle
	attr_reader  :tape_color

	def post_initialize(args)
		@tape_color = args[:tape_color]
	end

	def default_tire_size 
		'23'
	end
	
	def local_spares
	      {tape_color: tape_color}
	end
end

class MountainBike < Bicycle
	attr_reader :front_shock, :rear_shock

	def post_initialize(args)
		@front_shock = args[:front_shock]
		@rear_shock = args[:rear_shock]
	end

	def default_tire_size
		'2.1'
	end

	def local_spares
		{rear_shock: rear_shock}
	end
end

class RecumbentBike < Bicycle
	attr_reader :flag

	def post_initialize(args)
		@flag = args[:flag]
	end

	def local_spares
		{flag: flag}
	end

	def default_chain
		'9-speed'
	end

	def default_tire_size
		"28"
	end
end
rdbike = RoadBike.new(
	tape_color: "Red",
	size: 'M')
p rdbike.size
p rdbike.spares

mtnbike = MountainBike.new(
	front_shock: "Fox",
	size: "L",
	rear_shock: "Mongoose"
	)
p mtnbike
p mtnbike.spares

rcmbike = RecumbentBike.new(flag: 'orange and pretty')
p rcmbike
p rcmbike.spares

=end

# Chapter 7 Sharing Role Behavior with Modules
# before using classical inheritance to solve all of lifes problems think about what happens when you need a recumbent mountain bike! ahh!
# This is just one example of how inheritance can go awry.
# Always thing of costs and benefits of each coding style.

# Finding Roles
 # The preparer duck type from chapter 5 is role. Objects that implement preparers interface play this role. 
 # The existence of a preparer role shows that there is also a parallel preparable role. The trip class acts as a preparable.
 # It implements the preparable interface. This includes all the messages that any preparer might expect to send to a preparable.

# Modules
	# Methods can be defuned in a module and then the module can be added to any object. Modules allow objects of dif lasses to play a common role using a single set of code
	# Methods defined in a module become available via automatic delegation.
	# The total set of messages and object can respond includes:
		# Those it Implements
		# Those implemented in all objects above it in the hierarchy
		# Those implemented in any module that has been added to it.
		# Those implemented in all modules added to any object above it in the hierarchy.

#This code hides the knowledge of who the schedule is and what the schedule does inside of bicycle. Objects holding on to Bicycle no longer need to know about the existence of the Scheduel
=begin
class Schedule
	def scheduled?(schedulable, start_date, end_date)
		puts "This #{schedulable.class} " + "is not scheduled\n" + " between #{start_date} and #{end_date}" 
		false
	end
end

class Bicycle 
	attr_reader :size, :chain, :tire_size, :schedule

	def initialize(args={})
		@schedule = args[:schedule] || Schedule.new # inject schedule and provide default
		@size = args[:size]
		@chain = args[:chain] || default_chain
		@tire_size = args[:tire_size] || default_tire_size ||
		post_initialize(args) #bicycle sends this and implements 
	end

	def schedulable?(start_date,end_date)#return true if this bike is available during the (now bike specific) interval
		!scheduled?(start_date - lead_days, end_date)
	end

	def scheduled?(start_date,end_date) #return the schedules answer
		schedule.scheduled?(self, start_date, end_date)
	end
	
	#number of lead days before a bicycle can be scheduled 
	def lead_days
		1
	end
	#This
	# This change doesnt remove only the send of super but removes the initialize method altogether from subclasses.
	# subclasses may override
	# Subclasses are still responsible for what they initialize but not when it occurs.
	def post_initialize(args)
		nil
	end

	def spares
		{ chain: chain,
	      tire_size: tire_size }.merge(local_spares)
	end
	# by adding local spares instead of the call to super this decouples them further and adds a hook. 
	# Bicycle provides a default implementation that returns an empty hash. RoadBike overrides it to return in own version of local_spares.
	def local_spares
		{}
	end

	def default_chain
		'10-speed'
	end

	# changed this just to get it to work as an example. 
	def default_tire_size
		"40"
	end
end

require 'date'
starting = Date.parse("2015/09/04")
ending = Date.parse("2015/09/10")
b = Bicycle.new
p b.schedulable?(starting,ending)

=end

#This next code extracts teh abstraction so that we can use this same code with Vehicles and Mechanics

module Schedulable
	attr_writer :schedule

	#this returns an instance of the overall Schedule
	def schedule
		@schedule ||= ::Schedule.new
	end

	def schedulable?(start_date,end_date)
		!scheduled?(start_date - lead_days, end_date)
	end

	def scheduled?(start_date,end_date)
		schedule.scheduled?(self, start_date, end_date)
	end

	#set at 0 so taht includers may override.
	def lead_days
		0
	end

end

class Schedule
	def scheduled?(schedulable, start_date, end_date)
		puts "This #{schedulable.class} " + "is not scheduled\n" + " between #{start_date} and #{end_date}" 
		false
	end
end

class Bicycle
	include Schedulable 
	attr_reader :size, :chain, :tire_size

	def initialize(args={})
		@size = args[:size]
		@chain = args[:chain] || default_chain
		@tire_size = args[:tire_size] || default_tire_size
		post_initialize(args) #bicycle sends this and implements 
	end
	#This
	# This change doesnt remove only the send of super but removes the initialize method altogether from subclasses.
	# subclasses may override
	# Subclasses are still responsible for what they initialize but not when it occurs.
	def post_initialize(args)
		nil
	end

	def spares
		{ chain: chain,
	      tire_size: tire_size }.merge(local_spares)
	end
	# by adding local spares instead of the call to super this decouples them further and adds a hook. 
	# Bicycle provides a default implementation that returns an empty hash. RoadBike overrides it to return in own version of local_spares.
	def local_spares
		{}
	end

	def default_chain
		'10-speed'
	end

	def default_tire_size
		raise NotImplementedError,
			"This #{self.class} cannot respond to:"
	end

	def lead_days
		1
	end
end

class Vehicle
	include Schedulable

	def lead_days
		3
	end
end

class Mechanic
	include Schedulable

	def lead_days
		4 
	end
end


class MountainBike < Bicycle
	attr_reader :front_shock, :rear_shock

	def post_initialize(args)
		@front_shock = args[:front_shock]
		@rear_shock = args[:rear_shock]
	end

	def default_tire_size
		'2.1'
	end

	def local_spares
		{rear_shock: rear_shock}
	end
end
require 'date'
starting = Date.parse("2015/09/04")
ending = Date.parse("2015/09/10")
#b = Bicycle.new
#b.schedulable?(starting,ending)

v = Vehicle.new
v.schedulable?(starting, ending)

m = Mechanic.new
m.schedulable?(starting,ending)

mtnbike = MountainBike.new
mtnbike.schedulable?(starting,ending)

# It is also possible to add a modules methods to a single object, using the extend keyword. Page 300 of 623 shows a diagram of te hierarchy.

# Writing Inheritable Code.
	# The usefulness and maintainability of inheritance hierarchies and modules is in direct proportion to the quality of the code.
		# Recognize Antipatterns.
			# an object that uses a variable with a name like type or category to determine what message to send to self contains
			#two highly related but slightly different types. 

			# when sending object checks the class of a receiving object to determin what message to send , you may have overlooked a chance to ducktype
			# In addition to sharing an interface ducktypes might also share behavior. When they do place the sahred code in a module and include that module in each class or object that 
			#plays that role.

		# Insist on Abstraction
			# All code in an abstraction should apply to every class that inherits it.
			# Superclasses should not contain code that applies to some, but not ak, subclasses.
			#this restriction applie to modules as well.
			# sublclasses taht rais an exception lie "does not implement" come close to declaring they are not that thing.

		# Honor the Contract
			 # In order for a tyoe system to be sane, subtypes must be substitutable for their supertypes.

		# Use the Template method Pattern
			# seperate abstract from the concrete.
			# abstract code defines the algorithms and the concrete inheritors of that abstraction contribute specializations
			#by overriding these template methods.

		# Preemtively Decouple Classes
			# Avoid writing code that requires inheritors to send super. Instead use hook messages.
			# Hooks solve problem of super, but only for adjacent levels of hierarchy.

		# Create Shallow Hierarchies
			# an objects depth is the number of superclasses between it and the top.
			# its breadth is the number of its direct subclasses.
			# Shallow, Narrow Hierarchies are easy to understand. pg 308 of 623 has a diagram
			
