class WatsonsController < ApplicationController
  require 'fileutils'
  require "json"
  require "ibm_watson/authenticators"
  require "ibm_watson/text_to_speech_v1"
  require "ibm_watson/language_translator_v3"
  include IBMWatson
  # GET /watsons or /watsons.json
  def index
    @b=authenticatorst
    trans = getlangs
    @voices = getlvoices
    @listv = Array.new
    @listt = Array.new
    
    if @voices
      @voices.each do |v|
        @listv.push(v["description"])
      end
    end
    if trans
      trans.each do |t|
        @listt.push(t["language_name"])
      end
    end
    if params[:voice1] || params[:tran1]
      if params[:voice1] || params[:voice2]
        voice = getVoice
      end
      if params[:tran1] && params[:tran2]
        len = getLang
        @a = getLang
      end
      text = params[:text]
      if auth_model(@a) == true
        @translate = gettrans(text,@a)[0]["translation"]
      else
        @translate = false
      end
      synt(text, voice, @translate)
    end
    
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  #Text-to-speech-funct
  def authenticatorsv()
    authenticator = Authenticators::IamAuthenticator.new(
        apikey: "moy4mYsEwJx2gMC5wHdt8p8lukWtDGtqQgUjmjv5gRGK"
    )
    text_to_speech = TextToSpeechV1.new(
      authenticator: authenticator
    )
    text_to_speech.service_url = "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/9a8a18fd-09c8-4b4a-a255-c8a6ca427bbb"
    return text_to_speech
  end

  def authenticatorst()
    authenticator = Authenticators::IamAuthenticator.new(
      apikey: "ufy7mqaeG4RrIJIS66RChPAkU07U3W2tdHK7TbJLfB5O"
    )
    language_translator = LanguageTranslatorV3.new(
      version: "2018-05-01",
      authenticator: authenticator
    )
    language_translator.service_url = "https://api.us-south.language-translator.watson.cloud.ibm.com/instances/36c238a2-9a8b-4fdb-92f1-d8e7fad87288"
    return language_translator
  end 

  def getlvoices()
    return JSON.parse(JSON.pretty_generate(authenticatorsv.list_voices.result))["voices"]
  end

  def getVoice()
    v1 = nil
    v2 = nil
    getlvoices().each do |g|
      if g["description"] == params[:voice1]
        v1 = g["name"]
      elsif g["description"] == params[:voice2] 
        v2 = g["name"]
      end
    end
    v = [v1,v2]
    return v
  end 

  def synt(text, voice,trans)
    text_to_speech = authenticatorsv
    if File.exist?("public/audios/hello_world1.mp3")
      File.delete("public/audios/hello_world1.mp3")
    end
    File.open("public/audios/hello_world1.mp3", "wb") do |audio_file|
      response = text_to_speech.synthesize(
        text: text,
        accept: "audio/mp3",
        voice: voice[0]
      )
      audio_file.write(response.result)
    end
    if trans != false
      if File.exist?("public/audios/hello_world2.mp3")
        File.delete("public/audios/hello_world2.mp3")
      end
      File.open("public/audios/hello_world2.mp3", "wb") do |audio_file|
        response = text_to_speech.synthesize(
          text: trans,
          accept: "audio/mp3",
          voice: voice[1]
        )
        audio_file.write(response.result)
      end
    end
  end

  #Text-to-speech-funct
  def getlangs()
    return JSON.parse(JSON.pretty_generate(authenticatorst.list_languages.result))["languages"]
  end
  def getLang()
    t1 = nil
    t2 = nil
    getlangs().each do |l|
      if l["language_name"] == params[:tran1]
        t1 = l["language"]
      elsif l["language_name"] == params[:tran2]
        t2 = l["language"]
      end
    end
    return t1 + "-" + t2
  end
  def auth_model(len)
    b = false
    JSON.parse(JSON.pretty_generate(authenticatorst.list_models.result))["models"].each do |a|
      if a["model_id"] == len
        b = true
      end
    end
    return b
  end
  def gettrans(text, len)
    return JSON.parse(JSON.pretty_generate(authenticatorst.translate(
      text: text,
      model_id: len
    ).result))["translations"]
  end
  # Only allow a list of trusted parameters through.
  def watson_params
    params.fetch(:watson, :text)
  end
  # def set_watson
  #   @watson = Watson.find(params[:id])
  # end
end
