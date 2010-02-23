class Statistic::<%= class_name %> < Statistic::Base
  set_table_name "statistic_<%= plural_name %>"

  parameters # place here fields that are parameters for the stat, like:
  # parameters :date, :user_id

  def count

    # put your code that counts stats here

  end

  def check

    # put your code that validates data coherence here

    return true
  end

# This method is optional. When doing an update, if it is specified, Stat_fu will call it
# and update only if up_to_date?() returns false
#
#  def up_to_date?
#
#  end

  rake_tasks do |r|
  #  put your rake tasks here.
  # r.count_all "count all the stats for <%= class_name %>" do
  #   <%= class_name %>.create_or_update
  # end
  # r.namespace :destroy do |n|
  #   n.all "delete all stats" do
  #     Statistic::<%= class_name %>.destroy_all
  #   end
  # end
  #
  # first one produces:
  # rake statistic:<%= singular_name %>:count_all
  # second one:
  # rake statistic:<%= singular_name %>:destroy:all
  #
  end

end
