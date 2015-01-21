class PostsController < ApplicationController; ActionMailer::Base
  before_filter :authenticate_user!, :except => [:show, :index] 

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.paginate(:page => params[:page], :per_page => 10).order('id DESC')
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])

    #SEO FACTS
    @meta_title = "Dreams interpretation: " + @post.text.truncate(70)
    @meta_keywords = "Dreams interpretation: " + @post.text.truncate(40)
    @meta_description = "Dreams interpretation: " + @post.text.truncate(140)
    @ogsitename = "Saysadream - Dreams interpretation network"
    @ogurl = "saysadream.com"
    @ogdescription = "Dream interpretation: " + @post.text.truncate(140)
    @ogtitle = "Dream interpretation: " + @post.text.truncate(40)
    @twittercard = "summary"
    #END SEO FACTS

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json

  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = current_user.posts.build(params[:post])

    respond_to do |format|
      if @post.save   
        format.html { redirect_to @post }
        format.js
        #format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        #format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end

end

class TagExtractor
        
        APP_KEY = 'tlwJuoPV34HI18.Cf1yF4zgdh18Q6.JnWjTlexW67ByDJuGpPWw_l0NNuT.kcTScZQk-'
        API_SITE_URL = 'api.search.yahoo.com'
        API_PAGE_URL = '/ContentAnalysisService/V1/termExtraction';
         
        require 'net/http'
        require 'rexml/document'
        require 'uri'
         
        # public wrapper for the retrieve and parse process
        def self.extract(text)
            options = Hash.new
            options[:context] = text
            tag_xml = retrieve(options)
         
            parse(tag_xml)
        end

        private
          # pass the content to YTE for term extraction
          def self.retrieve(options)
          options['appid'] = APP_KEY
          res = nil
           
          Net::HTTP.start(API_SITE_URL) do |http|
          req = Net::HTTP::Post.new(API_PAGE_URL)
          req.form_data = options
          res = http.request(req)
        end
         
        res.body
        end
        # parse the XML returned from YTE into an array of tags
        def self.parse(xml)
          tags = Array.new
          doc = REXML::Document.new(xml)
          doc.elements.each("*/Result") do |result|
          tags << result.text
        end
          tags.join(", ")
        end
end
