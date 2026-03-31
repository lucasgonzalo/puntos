class PostsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all.order(created_at: :desc)
    @post = Post.new
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    respond_to do |format|
      format.html { render :edit }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(dom_id(@post), partial: 'posts/form', locals: { post: @post })
      end
    end
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend('posts', partial: 'posts/post', locals: { post: @post })
        end
        format.html { redirect_to posts_url, notice: "Post was successfully created." }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('form', partial: 'form', locals: { post: @post })
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(dom_id(@post), partial: 'posts/post', locals: { post: @post })
        end
        format.html { redirect_to posts_url, notice: "Post was successfully updated." }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(dom_id(@post), partial: 'posts/form', locals: { post: @post })
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    respond_to do |format|
      if @post.destroy
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove("post_#{@post.id}") # Aquí se elimina el post del DOM
        end
        format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      else
        format.html { redirect_to posts_url, alert: "Post could not be destroyed." }
      end
    end
  end

  def job_groups
    AddFirstGroupToMovementsJob.perform_now

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Tarea ejecutada" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :content)
    end
end
