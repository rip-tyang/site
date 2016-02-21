require 'singleton'

class Continent
  include Singleton
  attr_reader :asia, :africa, :europe, :n_america, :s_america, :oceania

  def initialize
    this = nil
    @asia = []
    @africa = []
    @europe = []
    @n_america = []
    @s_america = []
    @oceania = []
    begin
      open("countries.csv").each do |line|
        case line.chomp
        when "Africa:"
          this = @africa
        when "Asia:"
          this = @asia
        when "Europe:"
          this = @europe
        when "N. America:"
          this = @n_america
        when "S. America:"
          this = @s_america
        when "Oceania:"
          this = @oceania
        else
          this << line.chomp
        end
      end
    rescue => err
      p err
    end
  end
end

class Airport
  attr_accessor :city, :country, :continent, :latitude, :longitude, :altitude

  def initialize *plist
    @city, @country, @latitude, @longitude, @altitude = plist
  end
end

class Airports
  include Singleton
  attr_accessor :airports

  def initialize
    @airports = []
    begin
      open("airports.csv").each do |line|
        t = line.split(",")
        next unless t[0].to_i > 0
        @airports[t[0].to_i] = Airport.new(t[2], t[3], t[6], t[7], t[8])
      end
    rescue => err
      p err
    end
  end
end

class Route
  attr_accessor :airline_id ,:source_id, :destination_id, :equip
  MAP = {"asia" => "AS.", "africa" => "AF.", "europe" => "EU.", "n_america" => "N. A", "s_america" => "S. A", "oceania" => "O."}

  def initialize *plist
    @airline_id, @source_id, @destination_id = plist
  end

  def customized_output
    t1 = Airports.instance.airports[source_id]
    t2 = Airports.instance.airports[destination_id]
    return nil unless t1 && t2
    t1_continent = t2_continent = nil
    Continent.instance.instance_variables.each do |v|
      t1_continent = v.to_s.delete("@") if Continent.instance.send(v.to_s.delete("@")).include? t1.country
      t2_continent = v.to_s.delete("@") if Continent.instance.send(v.to_s.delete("@")).include? t2.country
    end
    return nil unless t1_continent && t2_continent
    t3 = Airlines.instance.airlines[@airline_id] ? Airlines.instance.airlines[@airline_id].active : "N"
    %{#{t1.city},#{t1.country},#{MAP[t1_continent]},#{t2.city},#{t2.country},#{MAP[t2_continent]},#{t3}}
  end
end

class Routes
  include Singleton
  attr_accessor :routes

  def initialize
   @routes = []
    begin
      open("routes.csv").each_with_index do |line, i|
        next if 0 == i
        t = line.split(",")
        @routes << Route.new(t[1].to_i, t[3].to_i, t[5].to_i)
      end
    rescue => err
      p err
    end
  end

  def output
    f = File.new("output.csv", "w")
    @routes.each { |e| f.print(e.customized_output + "\n") if e.customized_output }
  end
end

class Airline
  attr_accessor :active

  def initialize plist
    @active = plist[1]
  end
end

class Airlines
  include Singleton
  attr_accessor :airlines

  def initialize
    @airlines = []
    begin
      open("airlines.csv").each_with_index do |line, i|
        next if 0 == i
        t = line.split(",")
        @airlines[t[0].to_i] = Airline.new(t[7])
      end
    rescue => err
      p err
    end
  end
end

Routes.instance.output