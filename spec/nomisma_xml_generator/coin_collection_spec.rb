# frozen_string_literal: true

RSpec.describe NomismaXmlGenerator::CoinCollection do
  let(:coin_json_dir) { "#{$output_dir}/raw" }
  let(:mapper_csv) { "#{$fixture_path}/nomisma-mapper.csv" }
  let(:coin_collection) { described_class.new(coin_json_dir) }

  it 'to have a path to coin JSON' do
    expect(coin_collection).instance_of? NomismaXmlGenerator::CoinCollection

    expect(coin_collection.json_dir).to eq(coin_json_dir)
  end

  it 'to have a list of all json paths' do
    paths = coin_collection.all_json_paths
    expect(paths).instance_of? Array
    expect(paths).to include("#{coin_json_dir}/coin-1041.json")
    expect(paths).to include("#{coin_json_dir}/coin-1069.json")
  end

  it 'has a size value' do
    expect(coin_collection.size).to eq($unique_fixture_count)
  end

  it 'to generate a list of coin objects' do
    all_coins = coin_collection.all_coins
    expect(all_coins).instance_of? Array
    expect(all_coins.length).to eq($unique_fixture_count)

    single_coin = all_coins[0]
    expect(single_coin).instance_of? NomismaXmlGenerator::Coin
  end

  it 'can create a collection from txt file' do
    coin_list_path = File.join($output_dir, 'coin-list.txt')
    coin_collection2 = described_class.new(coin_json_dir, coin_list_path: coin_list_path)
    expect(coin_collection2.all_coins.length).to eq($unique_fixture_count)
  end

  context 'draws reference data from a csv file' do
    it 'creates a mapper from a csv file' do
      mapper = coin_collection.reference_link_mapper(mapper_csv)
      expect(mapper['https://catalog.princeton.edu/catalog/coin-490']).to eq('http://numismatics.org/pella/id/price.809')
      expect(mapper['https://catalog.princeton.edu/catalog/coin-766']).to eq('http://numismatics.org/pella/id/price.1410')
    end

    it 'ignores incorrectly formatted reference links' do
      mapper = coin_collection.reference_link_mapper(mapper_csv)
      expect(mapper['https://catalog.princeton.edu/catalog/coin-1034']).to eq(nil)
    end

    it 'applies that mapper to each coin' do
      coin_collection.apply_reference_link(mapper_csv)
      coin_collection.all_coins.each do |coin|
        expect(coin.reference_link).to eq('http://numismatics.org/crro/id/rrc-35.4') if coin.identifier == 'coin-1218'
      end
    end
  end
end
