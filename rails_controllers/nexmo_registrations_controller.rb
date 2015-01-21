class RegistrationsController < Devise::RegistrationsController
  #require 'twilio-ruby'
  require 'nexmo'
  #attr_accessor :to, :from, :body
  def new
    super # no customization, simply call the devise standard implementation
  end

  def create
     @user = User.new(params[:user])
     usercode = Random.new
     usercode = (usercode.rand(1...10) << usercode.rand(1...10)  << usercode.rand(1...10)).to_i
     @user.usercode = usercode
     @user.validation = false
     nexmo = Nexmo::Client.new('KEY', 'ID')
      if @user.save
        #sign in and verify user
        sign_in @user
        #send sms to user
        @user = current_user
        @codice = "Il tuo codice di verifica e password:" + @user.usercode.to_s
        @numero = @user.number
        @from = "Getpeople" 
        nexmo.send_message!({:to => @user.prefix + @numero, :from => 'Getpeople', :text => @codice})
        flash[:notice] = "Ti abbiamo appena inviato un sms con codice di conferma. Inseriscilo qui sotto:"
        render :action => :confirm
      else
        render :action => :new
      end
  end

  def update
    # For Rails 4
    #account_update_params = devise_parameter_sanitizer.sanitize(:account_update)
    # For Rails 3
     account_update_params = params[:user]

    # required for settings form to submit when password is left blank
    if account_update_params[:password].blank?
      account_update_params.delete("password")
      account_update_params.delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(account_update_params)
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  def confirm 
    @user = current_user
    @codice = @user.usercode
    if params[:usercode]
       @verifica = params[:usercode]
      if ( @codice.to_s == @verifica.to_s )
        @user.update_attribute :validation, true

        ReferralMailer.welcome_message(@user.email).deliver
        flash[:notice] = "Grazie di aver confermato la tua registrazione"
        render :action => :referral
      else
        flash[:alert] = "Spiacenti, codice inserito non corretto. Riprova"
      end 
    else
      flash[:alert] = "Inserisci un codice"
    end
  end

  def referral
    
    @user = current_user
    tot_user = User.find(:all).count
    if current_user
      nil
    else
      redirect_to root_url
    end
    if is_numeric(params[:referral])
      if params[:referral] && params[:referral].to_i < User.last.id
        if @user.save
            id = params[:referral].to_s
            mail_ref = User.find_by_id(id).email
            ReferralMailer.new_message(mail_ref).deliver
        end
        render :action => :invited, :notice => "Grazie per aver completato tutti i campi di registrazione"
      else 
        flash[:alert] = "Spiacenti, inserire il codice di referral corretto"
      end
    else 
      flash[:alert] = "Spiacenti, inserire un valore numerico"
    end

  end

  def invited
    if current_user
      nil
    else
      redirect_to root_url
    end
    nexmo = Nexmo::Client.new('KEY', 'ID')
    @user = current_user
    @sender_number = @user.number
    @receiver_number = params[:invited]
    if params[:invited] && params[:invited] != @sender_number && !(User.exists?(:number => params[:invited])) && @user.invited = "" && @user.validation
       nexmo.send_message({:to => @receiver_number, :from => @user.prefix + @sender_number, :text => "Iscriviti su www.getpeople.in come ho appena fatto io! E' gratis e ricevi ottimi sconti via sms'"})
       @user.invited = @receiver_number
       @user.save
       redirect_to root_url 
       flash[:notice] = "Grazie per aver completato la registrazione"
    else
      if params[:invited]
        flash[:alert] = "Errore, il numero non valido"
      end
    end

  end

  def is_numeric(o)
    true if Integer(o) rescue false
  end

  protected

  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

end