require 'pp'
require 'csv'
require 'pry'

slcsp = CSV.read('./slcsp.csv')
plans = CSV.read('./plans.csv')
zipcodes = CSV.read('./zips.csv')

$zipcodes_hash = {}
$plans_hash = {}

def calculate_slcsp(plans)
  plans.delete_if do |element|
    if element[1] != 'Silver'
      true
    end
  end
  
  plans = plans.sort_by { |a, b, c| c.to_i }
  
  # Can't calculate slcsp if one or zero silver plans
  if plans.length < 2
    return nil
  end

  return plans[1][2]
end
  
def get_slcsp(zipcode)
  areas = $zipcodes_hash[zipcode]
  available_areas = []
  areas.each do |area|
    available_areas << area[0]
  end
   
 	# A ZIP Code can also be in more than one rate area. In that case, the answer is ambiguous
	# and should be left blank.
  if available_areas.uniq.length > 1
    return nil
  end
  
  #Retrieving Plans
  rate_area = available_areas[0]
  plans = $plans_hash[rate_area]
  
  if not plans
    return nil
  end
  
  slcsp = calculate_slcsp(plans)
end

# Making
# "00698"=>[["PR1", "72153", "Yauco Municipio"]]}
# "36003"=>[["AL11", "72153", "Autauga"], ["AL13", "72153", "XXXXX"]]}
zipcodes.drop(1).each do |line|
  zipcode = line[0]
  rate_area = line[1] + line[4]
  if not $zipcodes_hash.key?(zipcode)
    $zipcodes_hash[zipcode] = []
  end  
  $zipcodes_hash[zipcode] << [rate_area, line[2], line[3]]
end

# Making
# "IA1"=>
#   [["00105JH5379769", "Bronze", "214.43"],
#    ["94313WQ8579602", "Silver", "322.34"],
#    ["99015AH8158731", "Silver", "388.68"],
#    ["29700DK6896673", "Silver", "287.3"]]}

plans.drop(1).each do |line|
  rate_area = line[1] + line[4]
  if not $plans_hash.key?(rate_area)
    $plans_hash[rate_area] = []
  end
  $plans_hash[rate_area] << [line[0], line[2], line[3]]
end

slcsp.drop(1).each do |line|
  line[1] = get_slcsp(line[0])
end

File.write('slcsp_filled.csv', slcsp.map(&:to_csv).join)