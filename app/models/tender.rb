class Tender < ActiveRecord::Base
  serialize :cpv_codes, Array
end
