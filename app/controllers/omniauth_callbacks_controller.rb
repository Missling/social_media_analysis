class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter
    @user = User.find_for_oauth(env["omniauth.auth"], current_user)
    if @user.persisted?
      puts "persisted"
      puts "*" * 100 
      @user_info = request.env['omniauth.auth'].to_hash
      @user.twitter_id = @user_info["uid"]
      @user.screen_name = @user_info["info"]["nickname"]
      @user.save

      sign_in_and_redirect @user, event: :authentication
    else
      puts "not persisted"
      puts "*" * 100 
      session["devise.twitter_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def after_sign_in_path_for(resource)
    if resource.email_verified?
      super resource
    else
      finish_signup_path(resource)
    end
  end
end
