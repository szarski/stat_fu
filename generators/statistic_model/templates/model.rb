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

#  rake_tasks do |r|
#    # put your rake tasks code here.
#    r.namespace :<%= plural_name %> do |n|
#      n.namespace :update do |u|
#        u.all "update all stats for <%= plural_name %>" do
#          [].each do |params|
#            Statistic::<%= class_name %>.create_or_update params
#          end
#        end
#        u.namespace :all do
#          a.force "update all stats for <%= plural_name %>, force up_to_date ones" do
#            [].each do |params|
#               Statistic::<%= class_name %>.create_or_update params.merge(:force => true)
#            end
#          end
#        end
#      end
#      n.namespace :clear do |f|
#        f.all "delete all <%= plural_name %> stats!" do
#          Statistic::<%= class_name %>.destroy_all
#          if Statistic::<%= class_name %>.count == 0
#            puts "deleted all"
#          else
#            puts "There still are some stats left!"
#          end
#        end
#      end
#
#
#    end
#  #
#  # first one produces:
#  # rake statistics:<%= plural_name %>:update:all
#  # second one:
#  # rake statistics:<%= plural_name %>:update:all:force
#  #
#  end

end
