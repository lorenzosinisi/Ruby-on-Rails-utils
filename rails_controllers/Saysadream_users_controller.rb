class UsersController < ApplicationController
  def index
        @users = User.paginate(:page => params[:page], :per_page => 10).order('id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def show
    
    @user = User.find_by_username(params[:id])
    @posts = @user.posts
    # tree starts here 
    
    @postcount = @user.posts.count
    @age = @user.posts.count + 40 + @user.comments.count
   
    @agepercentageprimus = @age.to_f  / 100
      if @agepercentageprimus >= 0.80
        @agepercentage = 0.72
      else 
        @agepercentage =  @age.to_f  / 100
      end
    @daysregistered = (Time.zone.now - @user.created_at).to_i / 1.day
    
    @postperday = @postcount.to_f / @daysregistered.to_f

      if @postperday >= 1 
        @postperday = 0
      else
        @postperday = -70
      end

    #end tree and start SEO 
    #SEO FACTS
    @meta_title = @user.username + ": dreams shared"
    @meta_keywords = "dreams interpretation, dreams tracked, dreams, user dreams, i dreamed to, dream meaning, meaning of dreams, dream interpretation"
    @meta_description = @user.username + "'s' dreams page. Dream meaning. Read dreams of this user and write your reviews"
    @ogurl = "saysadream.com/" + @user.username
    @ogdescription = ""
    @ogtitle = ""
    @twittercard = "summary"
    #END SEO FACTS
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def profile
    @user = User.find(params[:id])
  end

  def tree 
    
  end

end