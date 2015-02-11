class WebrtcAgentsController < ApplicationController
  before_action :set_webrtc_agent, only: [:show, :edit, :update, :destroy]

  # GET /webrtc_agents
  # GET /webrtc_agents.json
  def index
    @webrtc_agents = WebrtcAgent.all
  end

  # GET /webrtc_agents/1
  # GET /webrtc_agents/1.json
  def show
  end

  # GET /webrtc_agents/new
  def new
    @webrtc_agent = WebrtcAgent.new
  end

  # GET /webrtc_agents/1/edit
  def edit
  end

  # POST /webrtc_agents
  # POST /webrtc_agents.json
  def create
    @webrtc_agent = WebrtcAgent.new(webrtc_agent_params)

    respond_to do |format|
      if @webrtc_agent.save
        format.html { redirect_to @webrtc_agent, notice: 'Webrtc agent was successfully created.' }
        format.json { render :show, status: :created, location: @webrtc_agent }
      else
        format.html { render :new }
        format.json { render json: @webrtc_agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /webrtc_agents/1
  # PATCH/PUT /webrtc_agents/1.json
  def update
    respond_to do |format|
      if @webrtc_agent.update(webrtc_agent_params)
        format.html { redirect_to @webrtc_agent, notice: 'Webrtc agent was successfully updated.' }
        format.json { render :show, status: :ok, location: @webrtc_agent }
      else
        format.html { render :edit }
        format.json { render json: @webrtc_agent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /webrtc_agents/1
  # DELETE /webrtc_agents/1.json
  def destroy
    @webrtc_agent.destroy
    respond_to do |format|
      format.html { redirect_to webrtc_agents_url, notice: 'Webrtc agent was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_webrtc_agent
      @webrtc_agent = WebrtcAgent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def webrtc_agent_params
      params.require(:webrtc_agent).permit(:user_id, :sip_domain, :phone_number)
    end
end
