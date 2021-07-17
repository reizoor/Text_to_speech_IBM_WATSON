class WatsonsController < ApplicationController
  require "json"
  require "ibm_watson/authenticators"
  require "ibm_watson/text_to_speech_v1"
  include IBMWatson
  require 'fileutils'


  before_action :authenticators, only: %i[index api]
  before_action :getlvoices, only: %i[index api]



  # GET /watsons or /watsons.json
  def index
    @voices = getlvoices
    @list = Array.new
    if @voices
      @voices.each do |v|
        @list.push(v["description"])
      end
    end
  end

  # GET /watsons/1 or /watsons/1.json

  def api
    @voices = getlvoices
    @list = Array.new
    if @voices
      @voices.each do |v|
        @list.push(v["description"])
      end
    end
    if params[:voice]
      voice = getVoice
    end
    text = params[:text]
    synt(text, voice)
    # new["categories"][0]["score"] de esta manera extraemos los datos del hash dentro de categories->primera categoria->su puntaje
  end


  # GET /watsons/new
  # def new
  #   @watson = Watson.new
  # end

  # GET /watsons/1/edit
  # def edit
  # end

  # POST /watsons or /watsons.json
  # def create
  #   @watson = Watson.new(watson_params)

  #   respond_to do |format|
  #     if @watson.save
  #       format.html { redirect_to @watson, notice: "Watson was successfully created." }
  #       format.json { render :show, status: :created, location: @watson }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @watson.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /watsons/1 or /watsons/1.json
  # def update
  #   respond_to do |format|
  #     if @watson.update(watson_params)
  #       format.html { redirect_to @watson, notice: "Watson was successfully updated." }
  #       format.json { render :show, status: :ok, location: @watson }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @watson.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /watsons/1 or /watsons/1.json
  # def destroy
  #   @watson.destroy
  #   respond_to do |format|
  #     format.html { redirect_to watsons_url, notice: "Watson was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    
    def authenticators()
      authenticator = Authenticators::IamAuthenticator.new(
        apikey: "moy4mYsEwJx2gMC5wHdt8p8lukWtDGtqQgUjmjv5gRGK"
      )

      text_to_speech = TextToSpeechV1.new(
        authenticator: authenticator
      )
      text_to_speech.service_url = "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/9a8a18fd-09c8-4b4a-a255-c8a6ca427bbb"
      return text_to_speech
    end

    def getlvoices()
      voices = authenticators.list_voices
      return JSON.parse(JSON.pretty_generate(voices.result))["voices"]
      
    end

    def getVoice()
      getlvoices().each do |g|
        if g["description"] == params[:voice]
          return g["name"]
        end
      end
    end 

    def synt(text, voice)
      text_to_speech = authenticators
      if File.exist?("public/audios/hello_world.mp3")
        File.delete("public/audios/hello_world.mp3")
      end
      File.open("public/audios/hello_world.mp3", "wb") do |audio_file|
        response = text_to_speech.synthesize(
          text: text,
          accept: "audio/mp3",
          voice: voice
        )
        
        audio_file.write(response.result)
        
      end
     
    end

    # def set_watson
    #   @watson = Watson.find(params[:id])
    # end

    # Only allow a list of trusted parameters through.
    def watson_params
      params.fetch(:watson, :text)
    end
end
