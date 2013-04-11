#example 1 pg 62 of 623 (sideways ipad)
chainring  = 52 
cog = 11
ratio = chainring / cog.to_f
p ratio

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
p Gear.new(52,11).ratio
