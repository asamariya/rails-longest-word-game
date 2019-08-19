require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = ('a'..'z').to_a.sample(10)
  end

  def score
    @word = params[:word]
    @available_letters = params[:availableLetters]
    @valid_game = english_word?(@word) && included?(@word, @available_letters) ? 'Yes' : 'No'
    @score = 0
    @message = message(@word, @available_letters)
    session[:score] += @score
    @total_score = session[:score]
  end

  private

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def included?(word, letters)
    word.chars.all? { |letter| word.count(letter) <= letters.count(letter) }
  end

  def message(attempt, letters)
    if included?(attempt, letters)
      if english_word?(attempt)
        @score += attempt.size
        "Congratulations, <strong>#{attempt}</strong> is an English word and your score is #{@score}".html_safe
      else
        "Sorry but <strong>#{attempt}</strong> does not seem to be a valid English word".html_safe
      end
    else
      "Sorry but <strong>#{attempt}</strong> can't be built out of #{letters}".html_safe
    end
  end
end
