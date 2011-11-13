module CountryCommonMethods
  module Lt
    def default_date date_str
      
      if match_data = date_str.match(/((20[1-9][1-9])[\-\/]([0-1]?[0-9])[\-\/]([0-3][0-9])|([0-1]?[0-9])[\-\/]([0-3]?[0-9])[\-\/](20[1-9][1-9]))/)
        #first date format matched
        if match_data[2]
          Date.civil(match_data[2].to_i, match_data[3].to_i, match_data[4].to_i)
        else
          Date.civil(match_data[7].to_i, match_data[5].to_i, match_data[6].to_i)
        end
      end
      
    end
  end
  
end