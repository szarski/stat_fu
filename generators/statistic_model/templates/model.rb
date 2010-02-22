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

  rake_tasks do |r|
  #  put your rake tasks here.
  # r.count_all "count all the stats for <%= class_name %>" do
  #   <%= class_name %>.create_or_update
  # end
  end

end
