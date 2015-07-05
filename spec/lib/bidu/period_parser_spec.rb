require 'spec_helper'

describe Bidu::PeriodParser do
  shared_examples 'a class who knows how to parse time' do |tests|
    tests.each do |string, expected|
      it "parses #{string} into #{expected} seconds" do
        expect(described_class.parse(string)).to eq(expected)
      end
    end
  end

  it_behaves_like 'a class who knows how to parse time', {
    '3' => 3.seconds,
    '3seconds' => 3.seconds,
    '3minutes' => 3.minutes,
    '3hours' => 3.hours,
    '3days' => 3.days,
    '3months' => 3.months,
    '3years' => 3.years
  }
end
