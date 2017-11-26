module Granite::ORM::Querying

  def last(clause = "", params = [] of DB::Any)
    all([clause.strip, "ORDER BY #{@@order_column} DESC LIMIT 1"].join(" "), params).first?
  end
end
