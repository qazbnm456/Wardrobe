RailsAdmin.config do |config|

  config.authorize_with do
    unless current_user.admin?
      redirect_to(
          main_app.root_path,
          :flash => { :alert => "You are not permitted to view this page" }
      )
    end
  end

  config.current_user_method { current_user }

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
