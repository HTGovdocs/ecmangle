# frozen_string_literal: true

require 'json'
require 'custom_manglers/statistical_abstract'

SA = ECMangle::StatisticalAbstract
describe 'StatisticalAbstract' do
  let(:src) { SA.new }

  describe 'parse_ec' do
    it 'can parse them all' do
      matches = 0
      misses = 0
      input = File.dirname(__FILE__) + '/data/statabstract_enumchrons.txt'
      File.open(input, 'r').each do |line|
        line.chomp!
        ec = src.parse_ec(line)
        if ec.nil? || ec.empty?
          misses += 1
          # puts 'no match: ' + line
        else
          matches += 1
        end
      end
      puts "Statistical Abstract matches: #{matches}"
      puts "Statistical Abstract misses: #{misses}"
      expect(matches).to eq(1762)
      # expect(matches).to eq(matches+misses)
    end

    it 'can parse its canonical form' do
      expect(src.parse_ec('Edition:62, Year:1940')['year']).to eq('1940')
    end

    it 'can handle a single year' do
      expect(src.parse_ec('1980')['year']).to eq('1980')
    end

    it 'parses a double year' do
      expect(src.parse_ec('989 (1989)')['year']).to eq('1989')
    end

    it 'fixes 3 digit years' do
      expect(src.parse_ec('980')['year']).to eq('1980')
      expect(src.parse_ec('26-27 (903-904)')['start_year']).to eq('1903')
      expect(src.parse_ec('26-27 (903-904)')['end_year']).to eq('1904')
      expect(src.parse_ec('26-27 (903-904)')['end_edition']).to eq('27')
    end

    it "parses 'V. 2007' and 'V. 81 1960'" do
      expect(src.parse_ec('V. 2007')['year']).to eq('2007')
      expect(src.parse_ec('V. 81 1960')['year']).to eq('1960')
      expect(src.parse_ec('V. 81 1960')['edition']).to eq('81')
    end

    it "parses '92 1971
                92ND (1971)
                92ND,1971
                92ND ED. 1971
                92ND ED. (1971)'" do
      expect(src.parse_ec('92 1971')['year']).to eq('1971')
      expect(src.parse_ec('92ND (1971)')['year']).to eq('1971')
      expect(src.parse_ec('92ND,1971')['year']).to eq('1971')
      expect(src.parse_ec('92ND ED. 1971')['year']).to eq('1971')
      expect(src.parse_ec('92ND ED. (1971)')['year']).to eq('1971')
    end

    it "parses '1930 (NO. 52)'" do
      expect(src.parse_ec('1930 (NO. 52)')['year']).to eq('1930')
    end

    it "parses '1971 (92ND ED. )
                1971 92ND ED.'" do
      expect(src.parse_ec('1971 (92ND ED. )')['year']).to eq('1971')
      expect(src.parse_ec('1971 92ND ED.')['year']).to eq('1971')
    end

    it "deletes 'copy' nonsense" do
      expect(src.parse_ec('1921 COP. 2')['year']).to eq('1921')
      expect(src.parse_ec('1921 C. 2')['year']).to eq('1921')
    end

    it 'fixes 2 and 3 digit years' do
      expect(src.parse_ec('1998-01')['end_year']).to eq('2001')
      expect(src.parse_ec('1898-903')['end_year']).to eq('1903')
      expect(src.parse_ec('1988-1993')['end_year']).to eq('1993')
    end

    it 'removes copy information' do
      expect(src.parse_ec('C. 2 V. 86 1965')['year']).to eq('1965')
      expect(src.parse_ec('C. 1 2000')['year']).to eq('2000')
    end

    it "parses 'V. 128'" do
      expect(src.parse_ec('V. 128')['edition']).to eq('128')
    end
  end

  describe 'explode' do
    it 'should explode ranges' do
      expect(src.explode(src.parse_ec('1974-1977')).count).to eq(4)
    end

    it 'should not explode 1944-1945' do
      expect(src.explode(src.parse_ec('1944-1945')).count).to eq(1)
    end

    it 'should explode certain editions' do
      expect(src.explode(src.parse_ec('7TH-9TH')).count).to eq(2)
    end
  end

  describe 'ocns' do
    it 'has an ocns field' do
      expect(SA.new.ocns).to include(1_193_890)
    end
  end
end
