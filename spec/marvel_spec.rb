require 'spec_helper'

describe Marvel do
  it 'has a version number' do
    expect(Marvel::VERSION).not_to be nil
  end

  context 'given a proper configuration' do
    before do
      Marvel.set_config(
        public_key: 'c94d87eb20347745bbd4d3344530b76c',
        private_key: '<previously recorded>'
      )
    end

    describe '#total_characters' do
      it 'fetches the total number of comic characters' do
        VCR.use_cassette('characters') do
          expect(described_class.total_characters).to eq(1485)
        end
      end
    end

    describe '#sample_character_thumbnail' do
      it 'gets a character thumbnail' do
        VCR.use_cassette('sample_thumbnail') do
          expect(described_class.sample_character_thumbnail).to eq('http://i.annihil.us/u/prod/marvel/i/mg/3/00/4c003c66d3393.jpg')
        end
      end
    end

    describe '#characters_in_comics' do
      it 'returns the character names for two comics' do
        VCR.use_cassette('characters_filtered_by_comic_ids') do
          character_names = described_class.characters_in_comics(comic_ids: [30090, 162])
          expected_characters = [
            'Captain America',
            'Captain Britain',
            'Iron Man',
            'Spider-Man',
            'Thor'
          ]
          expect(character_names).to eq(expected_characters)
        end
      end

      it 'avoids calling the remote API if not comic ids are specified' do
        character_names = described_class.characters_in_comics(comic_ids: [])
        expect(character_names).to be_nil
      end
    end
  end

  context 'without being configured first' do
    describe '#total_characters' do
      it 'raises an exception' do
        Marvel.set_config(nil)
        expect {
          described_class.total_characters
        }.to raise_exception(Marvel::NotConfigured, /Not configured/)
      end
    end

    describe '#sample_character_thumbnail' do
      it 'raises an exception' do
        Marvel.set_config({public_key: 'something'})
        expect {
          described_class.sample_character_thumbnail
        }.to raise_exception(Marvel::NotConfigured, /No Marvel API private/)
      end
    end

    describe '#characters_in_comics' do
      it 'raises an exception' do
        Marvel.set_config({private_key: 'something'})
        expect {
          described_class.characters_in_comics(comic_ids: [30090, 162])
        }.to raise_exception(Marvel::NotConfigured, /No Marvel API public/)
      end
    end
  end

  context 'with an unsuccessful API response' do
    before do
      Marvel.set_config(
        public_key: 'foo',
        private_key: 'bar'
      )
    end

    describe '#total_characters' do
      it 'encapsulates the error in a known exception' do
        VCR.use_cassette('api_error') do
          expect {
            described_class.total_characters
          }.to raise_exception(
                 Marvel::ApiError,
                 'Unexpected API response. code=401 reason=The passed API key is invalid.'
               )
        end
      end
    end
  end
end
