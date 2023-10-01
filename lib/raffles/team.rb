# frozen_string_literal: true

require 'pry-byebug'
require 'json'
require 'httparty'

module Raffle
  class Team
    def self.call
      jogadores_json = File.read(File.expand_path('../../db/jogadores.json', __dir__))
      data = JSON.parse(jogadores_json)

      sortear(data)
    end

    # TODO: Tratar data = [] para quando o array vir vazio
    def self.sortear(data = [])
      goleiros = data['goleiros']
      jogadores_linha = data['linhas']

      @time_azul = (goleiros.sample(goleiros.length - 1) + jogadores_linha.sample(jogadores_linha.length - 5))
      @time_preto = []
      goleiros.each { |nome| @time_preto << nome unless @time_azul.include?(nome) }

      jogadores_linha.each do |nome|
        next if @time_preto.length == 6

        @time_preto << nome unless @time_azul.include?(nome)
      end

      times = <<~TIMES
        Time Preto: #{@time_preto.join(', ')}
        Time Azul: #{@time_azul.join(', ')}
      TIMES
      send_message(times)
    end

    def self.send_message(times)
      # TODO: Não deixar esses tokens chumbado no código
      api_key = 'colocar api token aqui'
      chat_id = 'colocar chat_id aqui'
      HTTParty.post("https://api.telegram.org/bot#{api_key}/sendMessage",
                    headers: {
                      'Content-Type' => 'application/json'
                    },
                    body: {
                      chat_id: chat_id,
                      text: times
                    }.to_json)
    end
  end
end
