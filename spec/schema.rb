ActiveRecord::Schema.define :version => 0 do
 
  create_table :foo do |t|
    t.string     :color
    t.integer    :day
    t.date       :date
    t.string     :output
    t.float      :generation_time_seconds
    t.boolean    :coherent
    t.timestamps
  end

end
