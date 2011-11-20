CODES_TO_COUNTRIES = [
  [ :lt, "Lietuva" ],
  [ :lv, "Latvia"  ],
  [ :ee, "Estonia" ]
].inject(ActiveSupport::OrderedHash.new) {|memo, v| memo[v[0]] = v[1]; memo}