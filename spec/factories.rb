FactoryGirl.define do
  factory :valid_proxy_server, :class => ProxyServer do
    ip '78.129.251.87'
    port  '3128'
    black_listed_flag false
  end
  
  factory :black_listed_proxy_server, :class => ProxyServer do
    ip '78.129.251.87'
    port  '3128'
    black_listed_flag true
  end
  
  factory :invalid_proxy_server, :class => ProxyServer do
    ip '78.129.251.86'
    port  '3128'
    black_listed_flag false
  end
end