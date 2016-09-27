class ConfirmationsController < Devise::ConfirmationsController
  protected

  def after_confirmation_path_for(resource_name, resource)
    p = Rancher::Api::Project.all.first
    sid = p.stacks.create(:name => emailSubstitude(resource.email), :accountId => "#{p.id}").id
    resource.stackId = sid
    if resource.save
      super
    end
  end
end
