class AdminController < ApplicationController
  before_filter :admin_user
   
  def string_count(sentence)
   counts = Hash.new(0)
   str_array = sentence
   for string in str_array
     counts[string] += 1
   end
   counts
  end

  def index
  	@users = User.all
  	@users_number = @users.count / 10
    @users_cap = Array.new
    @users_age = Array.new
    @users_sex = Array.new
    @users.each do |user|
      @users_cap.push(user.city)
    end
     @users.each do |user|
      @users_age.push(user.age)
    end
  	@most_common_value_city = string_count(@users_cap)
    @most_common_value_age = string_count(@users_age)
  end

end
