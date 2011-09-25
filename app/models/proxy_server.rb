class ProxyServer < ActiveRecord::Base
  scope :available, where("black_listed_flag = ?", false)
end
