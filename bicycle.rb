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

=begin
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
=end
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

# Chapter 8 Combining Objects With Composition
	# Composition is the act of combining distinct parts into a complex whole such that the whole becomes more than the sum of its parts.
	# Music is composed.


# Bicycle is now responsible for three things. Knowing its size, holding on to its parts, and answer its spares.
#pg 317 has diagram.

=begin
class Bicycle
	attr_reader :size, :parts

	def initialize(args={})
		@size = args[:size]
		@parts = args[:parts]
	end

	def spares 
		parts.spares
	end
end

class Parts
	attr_reader :chain, :tire_size

	def initialize(args={})
		@chain = args[:chain] || default_chain
		@tire_size = args[:tire_size] || default_tire_size
		post_initialize(args)
	end

	def spares
		{ tire_size: tire_size,
			chain: chain }.merge(local_spares)
	end

	def default_tire_size
		raise NotImplementedError
	end

	#subclasses may override
	def post_initialize(args)
		nil
	end

	def local_spares
		{}
	end

	def default_chain
		'10-speed'
	end

end
class RoadBikeParts < Parts
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

class MountainBikeParts < Parts
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

road_bike = Bicycle.new(
	size: "L",
	parts: RoadBikeParts.new(tape_color: "red"))
p road_bike.spares

mtnbike = Bicycle.new(
	size: "m",
	parts: MountainBikeParts.new(rear_shock: "Fox"))
p mtnbike.spares

=end

# Composing the parts object.

	# the parts list contains a list of individual parts.
	# This adds a class to represent a single part.
	# communicating the parts/part objects.

# Creating a Part.
	# The bicycle holds one Parts object which in turn holds many Part objects.
	# The new part class simplifies the existing Parts class, which now becomes a wrapper around an array of parts objects.
	# Parts can filter its list of part objects and return the one that need spares. 

=begin
class Bicycle
	attr_reader :size, :parts

	def initialize(args={})
		@size = args[:size]
		@parts = args[:parts]
	end

	def spares 
		parts.spares
	end
end

class Parts
	attr_reader :parts

	def initialize(parts)
		@parts = parts
	end

	def spares
		parts.select { |part| part.needs_spare }
	end
end

class Part
	attr_reader :name, :description, :needs_spare

	def initialize(args)
		@names = args[:name]
		@description = args[:description]
		@needs_spare = args.fetch(:needs_spare, true)
	end
end

chain = Part.new(name: "chain", description: "10-speed")
road_tire = Part.new(name: "tire_size", description: "23", needs_spare: false)
road_bike_parts = Parts.new([chain, road_tire])
p road_bike_parts

road_bike2 = Bicycle.new(
	size: 'L',
	parts: Parts.new([chain, road_tire]))
p road_bike2.spares
p road_bike2
=end

# The bad thing about this code is that  road_bike2.spares.size returns the size but road_bike.parts.size returns a nomethoderror
# the 1st works because spares returns an array. The next fails because parts returns instance of Parts.
# you could fix this by simply adding a size method which returns parts.size but this will make you want to keep making parts seem like an array and adding methods.
# you could also just have 
=begin 
class Parts < Array
	def spares
		select { |parts| part.needs_spare }
	end
end
=end
# but this contains a hidden flaw. When parts subclasses array it inherits all of Arrays behavior
# This includes behavior like + which adds two arrays and returns a third
# After combining two arrays like combo = (mtnparts + rdparts) combo.size returns correct but now combo_parts.spares is not understood.


# there is no perfect decision on which way to go. The next example is a middle ground between complexity and usability.
# Sending + to this results in NoMethodError bit Parts now responds to size,each and all of enumerable and raises errors if treated as actual Array.

=begin
class Bicycle
	attr_reader :size, :parts

	def initialize(args={})
		@size = args[:size]
		@parts = args[:parts]
	end

	def spares 
		parts.spares
	end
end

require 'forwardable'
class Parts
	extend Forwardable
	def_delegators :@parts, :size, :each
	include Enumerable

	def initialize(parts)
		@parts = parts
	end

	def spares
		select { |part| part.needs_spare }
	end
end

class Part
	attr_reader :name, :description, :needs_spare

	def initialize(args)
		@names = args[:name]
		@description = args[:description]
		@needs_spare = args.fetch(:needs_spare, true)
	end
end

chain = Part.new(name: "chain", description: "10-speed")
road_tire = Part.new(name: "tire_size", description: "23", needs_spare: false)
mtn_bike = Bicycle.new(size: "l",
	parts: Parts.new([chain, road_tire]))
p mtn_bike.spares.size
p mtn_bike.parts.size

=end

# Manufacturing Parts with Factories.

	# Unlike a hash this s2-d array provides no structural info. However, you understand the structure and can encode your
	#know how into a new object that manufactures parts.

# This modules job is to take an array and manufacture a parts object. it creates part objects but in public its responsibility
# is to create a parts.
#This factory knows the structure of the config array.
# Once you commit to keeping config in an array, you should ALWAYS create new parts objects using the factory.

=begin
class Bicycle
	attr_reader :size, :parts

	def initialize(args={})
		@size = args[:size]
		@parts = args[:parts]
	end

	def spares 
		parts.spares
	end
end

require 'forwardable'
class Parts
	extend Forwardable
	def_delegators :@parts, :size, :each
	include Enumerable

	def initialize(parts)
		@parts = parts
	end

	def spares
		select { |part| part.needs_spare }
	end
end

class Part
	attr_reader :name, :description, :needs_spare

	def initialize(args)
		@names = args[:name]
		@description = args[:description]
		@needs_spare = args.fetch(:needs_spare, true)
	end
end

module PartsFactory
	
	def self.build(config,
						part_class = Part,
						parts_class = Parts)
	parts_class.new(
		config.collect {|part_config| 
			part_class.new(
				name: 		part_config[0],
				description: part_config[1],
				needs_spare: part_config.fetch(2, true))})
	end
end
road_config = 
	[['chain', "10-speed"],
		["tire_size", "23"],
		["tape_color", "red"]]
 road_parts = PartsFactory.build(road_config)
p road_parts.part


=end

# THe Openstruct class is a lot like the Struct class that you've already seen. It provides a way to bundle
#a number of attributes into an object. 
# Struct takes position order initialization arguments
# OpenStruct takes a hash for its initialization and the derives attributes from the Hash.
#This code below is after refactoring to remove the part class.

=begin
class Bicycle
	attr_reader :size, :parts

	def initialize(args={})
		@size = args[:size]
		@parts = args[:parts]
	end

	def spares 
		parts.spares
	end
end

require 'forwardable'

class Parts
	extend Forwardable
	def_delegators :@parts, :size, :each
	include Enumerable

	def initialize(parts)
		@parts = parts
	end

	def spares
		select { |part| part.needs_spare }
	end
end

require 'ostruct'
module PartsFactory
	
	def self.build(config,
						parts_class = Parts)
	parts_class.new(
		config.collect {|part_config| 
			create_part(part_config)})
	end

	def self.create_part(part_config)
			OpenStruct.new(
				name: 		part_config[0],
				description: part_config[1],
				needs_spare: part_config.fetch(2, true))
	end
end
road_config = 
	[['chain', "10-speed"],
		["tire_size", "23"],
		["tape_color", "red"]]
 road_parts = PartsFactory.build(road_config)
 # p road_parts.each { |x| p x}

recumbent_config = 
	[["chain", "9-speed"],
	["tire_size", "28"],
	["flag", "tall and orange",false]]

recumbent_bike = 
	Bicycle.new(
		size: "L",
		parts: PartsFactory.build(recumbent_config))
p recumbent_bike.spares

=end
# Adding support for recumbent bikes took 19 new lines of code in Ch 6
# This can now be accomplished in 3. Shown above

# Delegation - When one object reveives a message and forwards it to another. This creates dependencies bc receiver must recognixe the message AND know where to send it
# Composition - A composed object is made up of parts with which it expects to interact via well-defined interfaces.
	# describes a "has-a" relationship. IE: meals have appetizers, univerities have departments, bikes have parts.
	# meals,universities, and bikes are composed objects. Appetizers, depts, and parts are roles.
	# This also means that the contained object (appetizer) has no life indpendent of its container.
	# mealse have appetizers but when meal is eaten the appetizer is also gone.
# Aggregation - Exactly like composition but the contained object has an independent life.
# Universities have departments who in turn have professors.
# it is reasonable to believe that if a Universities department dissapears, its professors continue to exist.
# The university => dept relationship is a composition and the department => professor is aggregation.

# The General Rules in Deciding BW Inheritance and Composition
	# When faced with a problem that composition can solve you should be biased in using composition.
	# If you cannot defend inheritance as a better solution use composition.

	# Inheritance is better when its use provides high rewards for low risk. 

# Accepting Consequences of Inheritance
# Goals for Code: TRUE
	# transparent, reasonable, usable, exemplary.

#Inheritance excels at the 2nd, 3rd, and 4th goals
=begin 
	Methods defined near the top of inheritance hierarchies have widespread influence bc the height of the hierarchy acts as a lever that multiplies their effects
	Changes made to these methods ripple down the inheritance tree.
	big changes in behavior can be achieved via small amounts of code.
	you can easily create new subclasses to accomodate new variants.

	- if you do not create correctly modeled hierarchies you could be flipping the excel coin. 
		New behavior may not fit or others will not want to use your code bc of all the dependencies.

	Look at page 348 for more examples of why these are good and bad.

# Consequences of Composition

	pg 351 fore examples

=end

# Chapter 9. Designing Cost-Effective Tests
	
	# Poorly Designed Code is difficult to change
	# Must be skilled at refactoring - improves the internal structure but does not alter external.
	# Preserves Maximum flexiibility at minimum cost by putting of decisions for commitment until specific requirements arrive.

	# Efficient test prove that altered code continues to begave correctly without raising overall costs. Good changes do not force rewrites of tests.
	# Write tests that remind you of the story you once had. Remember that you will forget.
	# Tests allow you to defer design decisions.
	# Good design naturally progresses toward small independent objects that rely on abstractions. 
	# Individual Abstractions make for clean code but also make the intent of the whole blurry. This is where the need for good tests come in.

	# Tests expose design flaws
	# it a test requires painful setup, the code expects too much context.
	# if testing one object drags a bunch of others into the mix, the code has too many dependencies.
	# If the test is hard to write, other objects will find the code difficult to reuse.

	# You should write loosely coupled tests only for the things that matter.

	# Most programmers write too many tests.
	# Test everything once in the proper place.

	# Willful ignorance of the internals of every other object is at the core of design.
	# Tests should only test the stable things. IE: Usually only public interface

	#Tests that make assertions about the values of messages return are tests of state.

	#Some outgoing messages have no side effects and only matter to their senders. The sender cares about the result it gets back, but no other part of the 
	#application cares if the message gets sent. Outgoing messages like this are knowns as Queries and they need not be tested by the 
	#sending object. Query messages are part of the public interface of the reciever and should be tested by the receivers state.

	# Some outgoing messages do have side effects. Such as file writting, db record saved, action taken by observer.
	#These are commands and it is the respoonsibility of the sending object to prove they are properly sent. Proving a
	#message gets sent is a test of behavior, not state, and involves assertions about the number of times and with what args it is sent.

	##* Incoming messages should be tested for the state they return.
	 #* Outgoing Command messages should be tested to ensure they get sent.
	 #* Outgoing query messages should not be tested.
	
	#You should write tests first, whenever it makes sense to do so.
	# writing first has a modicum of reusability built into an object from its inception.

	# Lack of design skills for novices will make testing baffingly difficult but if they perservere they will at least have testable code.
	#Tests are not a substitution for bad code!

	# TDD VS BDD

	#BDD - Takes an outside-in approach. Creating objects at the boundary of an app and working its way inward, mocking as necessary to supply
	 #as-yet-unwritten objects. 

	# TDD - Takes a inside-out approach, usually starting with tests of domain objects and then reusing these newly created domain objects in the tests of adjacent 
		#layers of code.

	# When testing think of your app as divided into two major categories. 
		# First category contains the object your'e testing, referred to as object under test.
		# Second category is everything else.
		 	#The tests should know things about the first category, but be as ignorant as possible about the second.
		 	# Think of it as the only info available during the test is that which can be gained from looking at the object under test.
		 # once you find your specific object you will need to choose a tesing POV.

	# Incoming messages make up an objects public interface, the face it presents to the world. 

# The Next tests MiniTest

#Here wheel responds to one incoming message. Diameter which is sent by Gear. Gear responds to two incoming messages. gear_inches and ratio.
	# Incoming Messges ought to have dependants
		# If you draw a table like the one on pg 378 and find a purported incoming message with no dependants you should biew it with suspicion.
		#It's really not incoming at, its a speculative implementation that reeks of guessing about the future and anticipates things that dont exist.
			# Do not test incoming messages with no dependants; delete it. Application are improved by eliminating code that is not actively begin used.

	# Proving the Public Interface.
		# Incoming messages are tested by making asseritns about the value, or state, that their invocation returns. 
			# The first requriement is to prove that it returns the correct value in every possible situation.

=begin

require 'minitest/autorun'
class Wheel 
	attr_reader :rim, :tire
	
	def initialize(rim,tire)
		@rim = rim 
		@tire = tire
	end

	def diameter 
		rim + (tire * 2)
	end
end

class Gear 
	attr_reader :chainring, :cog, :rim, :tire
	def initialize(args)
		@chainring = args[:chainring]
		@cog = args[:cog]
		@rim = args[:rim]
		@tire = args[:tire]
	end
	def gear_inches
		ratio * Wheel.new(rim,tire).diameter
	end

	def ratio
		chainring / cog.to_f
	end

end

class WheelTest < MiniTest::Unit::TestCase

	def test_calculates_diameter
	#create instance of wheel
		wheel = Wheel.new(26,1.5)
	#make assertions about wheel
		assert_in_delta(29,
				wheel.diameter,
				0.01)
	end
end
#This gear teset looks like WheelTest but it has entanglement the diameter test didnt have. Gears implementation of gear_inches creates and uses another object, Wheel.
#Gear and Wheel are coupled in teh code and the tests.
# This exposes a risk of tigh coupling and can be fixed slightly as it was in ch 3.
class GearTest < MiniTest::Unit::TestCase

	def test_calculates_gear_inches
		gear = Gear.new(
				chainring: 52,
				cog: 		11,
				rim: 		26,
				tire:    	1.5 )

		assert_in_delta(137.1,
						gear.gear_inches,
						0.01)
	end
end

=end

=begin

require 'minitest/autorun'
class Wheel 
	attr_reader :rim, :tire
	
	def initialize(rim,tire)
		@rim = rim 
		@tire = tire
	end

	def diameter 
		rim + (tire * 2)
	end
end

class Gear 
	attr_reader :chainring, :cog, :wheel
	def initialize(args)
		@chainring = args[:chainring]
		@cog = args[:cog]
		@wheel = args[:wheel]
	end
	# The change in making wheel understand diameter and not creating a 
	#new wheel here no longer cares about the injected object it only expects to implement diameter.
	# The diameter method is part of teh public interface of a role, that might be named diameterizable.
	# Because gear is now decoupled from wheel you must inject an instance of diameterizable during every gear creation.
	#the object in 'wheel' variable play the diameterizable role.
	def gear_inches
		ratio * wheel.diameter
	end

	def ratio
		chainring / cog.to_f
	end

end

class WheelTest < MiniTest::Unit::TestCase

	def test_calculates_diameter
	#create instance of wheel
		wheel = Wheel.new(26,1.5)
	#make assertions about wheel
		assert_in_delta(29,
				wheel.diameter,
				0.01)
	end
end

class GearTest < MiniTest::Unit::TestCase
# a wheel instance is now injected into the test
# using a wheel for the injected Diameterizable results in test code taht mirrors the application.
# it is now obvious in the tests and the application, that gear is using wheel. the invisible coupling is now publicly exposed

	def test_calculates_gear_inches
		gear = Gear.new(
				chainring: 52,
				cog: 		11,
				wheel: 		Wheel.new(26,1.5))

		assert_in_delta(137.1,
						gear.gear_inches,
						0.01)
	end
end
=end

#The role of diameterizable is all in your head so no one else using this app can guide a future maintainer.
# Structuring the test the way we have has a real advantage.
# When the code in tests use teh same collaborating objects as the code in your app, the tests break when they should. This is invaluable
# Imagine someone changes diameter methods name in Wheel to width and failed to update the name of the sent message in Gear. Gear still send diameter to its gear_inches method.
# The tests now fail bc gear test injects an instance of wheel and wheel implements width by Gear sends diameter.


=begin
require 'minitest/autorun'
class Wheel 
	attr_reader :rim, :tire
	
	def initialize(rim,tire)
		@rim = rim 
		@tire = tire
	end

	def width
		rim + (tire * 2)
	end
end

class Gear 
	attr_reader :chainring, :cog, :wheel
	def initialize(args)
		@chainring = args[:chainring]
		@cog = args[:cog]
		@wheel = args[:wheel]
	end
	# The change in making wheel understand diameter and not creating a 
	#new wheel here no longer cares about the injected object it only expects to implement diameter.
	# The diameter method is part of teh public interface of a role, that might be named diameterizable.
	# Because gear is now decoupled from wheel you must inject an instance of diameterizable during every gear creation.
	#the object in 'wheel' variable play the diameterizable role.
	def gear_inches
		ratio * wheel.diameter
	end

	def ratio
		chainring / cog.to_f
	end

end

class WheelTest < MiniTest::Unit::TestCase

	def test_calculates_diameter
	#create instance of wheel
		wheel = Wheel.new(26,1.5)
	#make assertions about wheel
		assert_in_delta(29,
				wheel.diameter,
				0.01)
	end
end

class GearTest < MiniTest::Unit::TestCase
# a wheel instance is now injected into the test
# using a wheel for the injected Diameterizable results in test code taht mirrors the application.
# it is now obvious in the tests and the application, taht gear is using wheel. the invisible coupling is now publicly exposed
# page 388 has an example.
# Diameterizable  is depended on by gear and implemented by wheel.

# There are two places in the code where object depends on knowledge of Diameterizable's interface.
	# Gear thinks taht it knows Diameterizables interface.(it believes it can send diameter to the injected object)
	# The code that created the object to be injected believes that WHeel implements this interface; that is it expects Wheel to implement diameter.
		# Now that diameterizable has changed there is a problem. Wheel has been updated to implement the new interface but gear expects the old one.

	# The whole point of dependency injection is to allow you to sub different concrete classes without changing existing code. 

	# Roles need tests of their own. 
	def test_calculates_gear_inches
		gear = Gear.new(
				chainring: 52,
				cog: 		11,
				wheel: 		Wheel.new(26,1.5))

		assert_in_delta(137.1,
						gear.gear_inches,
						0.01)
	end
end
=end

	# Testing Private Methods
