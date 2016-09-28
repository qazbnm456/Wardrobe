require 'open3'
class DockerController < ApplicationController
  before_action :authenticate_user!
  # Rancher Api still not support to list images on host (https://github.com/rancher/rancher/issues/1277)
  <<~'Rancher::Api::Image'
  def updateAllImages
    @available = []
    Rancher::Api::Image.all.to_a.each do |image|
      ele = ActiveSupport::JSON.decode(image.to_json)["attributes"]["data"]["dockerImage"]
      @available.push([ele["repository"], ele["tag"]])
    end
    respond_to do |format|
      format.js
    end
  end
  Rancher::Api::Image

  def getAllImages
    @available = Image.all.group_by { |image| image.name }
    respond_to do |format|
      format.js
    end
  end

  def getUserImages
    @user = current_user
    @available = @user.images
    respond_to do |format|
      format.js
    end
  end

  def assignToUser
    @user = current_user
    if @user.count < 1
      @user.count += 1
      @image_name = instances_params[:image_name]
      @image_tag = instances_params[:image_tag]
      @record = Record.new
      @record.user = @user
      @record.image = Image.find_by({name: @image_name, tag: @image_tag})
      p = Rancher::Api::Project.all.first
      s = p.stacks.find("#{@user.stackId}")
      s.create_service_with_name(getInstanceName(@user.email + "-1-" + @image_name + "-1-" + @image_tag), @image_name, @image_tag, s.id, p.id)
      @record.save
      if @record && @record.errors.any?
        @user.count -= 1
      end
      @user.save
      respond_to do |format|
        format.js
      end
    else
      redirect_to(
          main_app.root_path,
          :flash => { :alert => "You've exceeded the maximum number of available instances." }
      )
    end
  end

  def spawnInstance
    @user = current_user
    @image_name = instances_params[:image_name]
    @image_tag = instances_params[:image_tag]
    @commit = instances_params[:commit]
    begin
    p = Rancher::Api::Project.all.first
    if @commit != ""
      @record = Record.find_by({user_id: @user, image_id: Image.find_by({name: @image_name, tag: @image_tag})})
      if @commit == "Start"
        p.services.where(:name => getInstanceName(@user.email + "-1-" + @image_name + "-1-" + @image_tag))[0].activate
        @record.update(status: "active")
      elsif @commit == "Eliminate"
        p.services.where(:name => getInstanceName(@user.email + "-1-" + @image_name + "-1-" + @image_tag))[0].deactivate
        @record.update(status: "inactive")
      elsif @commit == "Remove"
        p.services.where(:name => getInstanceName(@user.email + "-1-" + @image_name + "-1-" + @image_tag))[0].remove
        @record.destroy
        @user.count -= 1
        @user.save
      end
    else
      @container = p.services.where(:name => getInstanceName(@user.email + "-1-" + @image_name + "-1-" + @image_tag))[0].instances[0].terminal(%w(/bin/sh -c TERM=xterm-256color;\ export\ TERM;\ [\ -x\ /bin/bash\ ]\ &&\ ([\ -x\ /usr/bin/script\ ]\ &&\ /usr/bin/script\ -q\ -c\ "/bin/bash"\ /dev/null\ ||\ exec\ "/bin/bash")\ ||\ exec\ /bin/sh))
      @uri = URI.parse(@container.url)
      @uri.query = "token=#{@container.token}"
      @ws = @uri.to_s
    end
    respond_to do |format|
      format.js
    end
    rescue NoMethodError
      respond_to do |format|
        format.js {render :spawnInstanceWithError }
      end
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def instances_params
    params.permit(:utf8, :authenticity_token, :image_name, :image_tag, :commit)
  end
end
