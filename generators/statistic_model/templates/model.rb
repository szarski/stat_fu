class Statistic::<%= class_name %> < Statistic::Base
  set_table_name "statistic_<%= plural_name %>"

  # # Place fields that are your input here, like:
  # # parameters :date, :user_id, :category, :optional => [:category]
  parameters <%= attributes.collect{|a| ":#{a.name}"}.join(', ') %>

  def count

    # # Put your code that calculates one single record's data here.
    # # The function should set all the output variables.
    # # Example:
    # #
    # # if (self.category)
    # #   self.projects_count = User.find(self.user_id).projects.with_categeory_name(category).count
    # # else
    # #   self.projects_count = User.find(self.user_id).projects.count
    # # end
    # #
    # # You can cache stuff between records:
    # #
    # # self.projects_count = self.cache_in_batch "projects_for_user_#{self.user_id}" do
    # #   User.find(self.user_id).projects.with_categeory_name(category).count
    # # end

  end

  def check

    # # Put your code that validates single record's data coherence here.
    # # The code has to return true or false.

    return true
  end



# # This method is optional. Record won't be updated unless up_to_date? returns false or is not specified:
# #
#  def up_to_date?
#
#  end



# # You can define rake tasks here:
# #
# # Put the default argument set you want to update:
#   UPDATE_HASH = {}
# # like: 
# # UPDATE_HASH = {:date => lambda{:date => (3.months.ago.to_date..Time.now.to_date).to_a}, :user_id => User.all.map(&:id)}
# 
#   rake_tasks do |r|
#     r.namespace :<%= plural_name %> do |n|
#       n.namespace :update do |u|
#         u.default_update :all, "update all stats for <%= plural_name %>", UPDATE_HASH
#         u.namespace :all do |a|
#           a.default_update :force, "update all stats for <%= plural_name %>, force up_to_date ones", UPDATE_HASH.merge{:force => true}
#         end
#       end
#       n.namespace :clear do |c|
#         c.default_clear :all, "clear all <%= plural_name %> stats"
#       end
#       n.custom_task "Some Custom Task" do
#         # code here
#       end
#     end
#   end
# 
# # These produce:
# #
# # rake statistics:<%= plural_name %>:update:all
# #
# # rake statistics:<%= plural_name %>:update:all:force
# #
# # rake statistics:<%= plural_name %>:clear:all
# #
# # rake statistics:<%= plural_name %>:custom_task
# #
# # check rake stats:help to see all the stats tasks.

  describe_output <%= attributes.collect{|a| ":#{a.name} => :sum"}.join(', ') %>, :custom_method => lambda{|records| records.count}

end
