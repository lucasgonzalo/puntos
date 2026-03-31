class GroupUsersController < ApplicationController
  before_action :set_group, except: %i[ create destroy ]
  before_action :set_combos, only: %i[ new create ]

  # GET /groups or /groups.json
  def index
    @group_users = @group.group_users
  end

  # GET /groups/new
  def new
    @group_user = GroupUser.new
  end

  # POST /groups or /groups.json
  def create
    @group_user = GroupUser.new(group_user_params)
    @group = @group_user.group

    respond_to do |format|
      if @group_user.save
        format.html { redirect_to group_users_url(group_id: @group.id), notice: 'Usuario vinculado correctamente.'}
        format.json { render :show, status: :created, location: @group_user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group_user = GroupUser.find(params[:id])
    @group = @group_user.group
    @group_user.destroy

    respond_to do |format|
      format.html { redirect_to group_users_url(group_id: @group.id), notice: 'Usuario desvinculado correctamente.'}
      format.json { head :no_content }
    end
  end

  private
  # Only allow a list of trusted parameters through.
  def group_user_params
    params.require(:group_user).permit(:group_id, :user_id)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:group_id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group_user).permit(:group_id, :user_id)
  end

  def set_combos
    @users = User.all.order(:email)
  end
end
