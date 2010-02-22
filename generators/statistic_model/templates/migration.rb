class Create<%= plural_name.underscore.camelize %> < ActiveRecord::Migration
  def self.up
    create_table "statistic_<%= plural_name %>", :force => true do |t|
    <% attributes.each do |attribute| -%>
    t.<%= attribute.type %> :<%= attribute.name %>
    <% end -%>
      # obligatory fields:
      t.boolean :coherent
      t.float :generation_time_seconds
      t.timestamps
    end
  end
 
  def self.down
    drop_table "statistic_<%= plural_name %>"
  end
end
