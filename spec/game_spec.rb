# frozen_string_literal: true

require 'game'

describe Game do
  subject(:game) { described_class.new }
  it 'accepts a white move' do
    allow(game).to receive(:gets).and_return('e3', '')
    game.run
    history = game.instance_variable_get(:@history)
    expect(history).to eq('1.e3 ')
  end

  it 'accepts one full turn' do
    allow(game).to receive(:gets).and_return('e3', 'e6', '')
    game.run
    history = game.instance_variable_get(:@history)
    expect(history).to eq('1.e3 e6 ')
  end

  it 'accepts a series of turns' do
    allow(game).to receive(:gets).and_return('e3', 'e6', 'f4', 'f7', '')
    game.run
    history = game.instance_variable_get(:@history)
    expect(history).to eq('1.e3 e6 2.f4 f7 ')
  end

  it 'accepts a long series of turns' do
    allow(game).to receive(:gets).and_return('Nf3', 'Nf6', 'c4', 'g6', 'Nc3', 'Bg7', 'd4', '')
    game.run
    history = game.instance_variable_get(:@history)
    expect(history).to eq('1.Nf3 Nf6 2.c4 g6 3.Nc3 Bg7 4.d4 ')
  end
end
