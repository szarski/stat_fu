StatFu
======

This is a work in progress on a framework for managing statistics in Rails.


Example
=======

Generate a model and a migration:

script/generate statistic_model users_daily date:date user_count:integer average_posts_count:integer

Open app/models/statistic/users_daily.rb

class Statistic::UsersDaily < Statistic::Base
  set_table_name "statistic_users_dailies"

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
  # r.count_all "count all the stats for UsersDaily" do
  #   UsersDaily.create_or_update
  # end
  end

end

Set the fields that are the statistic parameters. In this example this is only the date.

parameters :date

Put some code in your count() method, say:

self.user_count = User.count
self.average_posts_count = (self.user_count > 0) ? (Post.count / self.user_count) : nil

If you want to check the data later, alter the check() method to return true or false.

Specify the rake tasks that you will be using:

rake_tasks do |r|
  r.count_today "count user stats" do
    Statistic::UsersDaily.create_or_update(Time.now.getutc.to_date)
  end

  r.namespace :remove do |n|
    n.all "remove all user stats" do
      Statistic::UsersDaily.destroy_all
    end
  end
end

and you're done:

class Statistic::UsersDaily < Statistic::Base
  set_table_name "statistic_users_dailies"

  parameters :date

  def count
    self.user_count = User.count
    self.average_posts_count = (self.user_count > 0) ? (Post.count / self.user_count) : nil
  end

  def check
    return true
  end

  rake_tasks do |r|
    r.count_today "count user stats" do
      Statistic::UsersDaily.create_or_update(Time.now.getutc.to_date)
    end
  
    r.remove_all "remove all user stats" do
      Statistic::UsersDaily.destroy_all
    end
  end

end

Now for the fun part. To run your stats, just add to your crontab:

rake stats:users_daily:count_all

Or

rake stats:users_daily:remove:all

Methods
=======

Instance:
  Required from the user:
    count
    check

  Added:
    count_and_check

Static:

  create
    object if saved
    false if not saved
  
  update
    object if updated
    false if found but not saved
    nil if not found
  
  create_or_update
    object if created or updated
    false if neither creted nor updated
  
  find_by_parameters
    object if found
    nil if not found


Copyright (c) 2010 Jacek Szarski (jacek@applicake.com), released under the MIT license
