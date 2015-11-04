class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :finish_signup]

  # GET /users/:id.:format
  def show
    # authorize! :read, @user
    if @user.datetime.nil? || Time.now > (@user.datetime) * (60 * 60 * 24)

      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['API_KEY']
        config.consumer_secret     = ENV['API_SECRET']
        config.access_token        = ENV['ACCESS_TOKEN']
        config.access_token_secret = ENV['ACCESS_SECRET']
      end

      # @followers = client.followers(@user.twitter_id)
      @followers = client.followers("yapinator")

      @followers.each do |twitter_follower|

        follower_id = twitter_follower[:id]
        follower = Follower.find_by(twitter_id: follower_id, user_id: @user.id)

        if follower.nil?

          follower = Follower.create(
            screen_name: twitter_follower[:screen_name],
            twitter_id: twitter_follower[:id],
            verified_follower: twitter_follower[:verified]
          )

          @user.followers << follower 
        end

        follower.followers_count = twitter_follower[:followers_count]
        follower.save
      end

      @user.datetime = Time.now

      @total_followers = 0
      @user.followers.each do |follower|
        @total_followers += follower.followers_count
      end

      ten_percent = (@user.followers.count / 10)
      @sorted_followers = @user.followers.order(followers_count: :desc).first(ten_percent)

    end
  end

  # GET /users/:id/edit
  def edit
    # authorize! :update, @user
  end

  # PATCH/PUT /users/:id.:format
  def update
    # authorize! :update, @user
    respond_to do |format|
      if @user.update(user_params)
        sign_in(@user == current_user ? @user : current_user, bypass: true)
        format.html { redirect_to @user, notice: 'Your profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    # authorize! :update, @user 
    if request.patch? && params[:user] #&& params[:user][:email] 
      if @user.update(user_params)
        # @user.skip_reconfirmation!
        sign_in(@user, bypass: true)
        redirect_to users_path(@user), notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
  end

  # DELETE /users/:id.:format
  def destroy
    # authorize! :delete, @user
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end
  
  private
    
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    accessible = [ :name, :email ] # extend with your own params
    accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
    params.require(:user).permit(accessible)
  end
end
