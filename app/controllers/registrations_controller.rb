class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    p = Rancher::Api::Project.all.first
    sid = p.stacks.create(:name => emailSubstitude(resource.email), :accountId => "#{p.id}").id
    resource.stackId = sid
    if resource.save
      super
    end
  end
end
