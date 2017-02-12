require 'spec_helper'

RSpec.describe SCNR::UI::CLI do
    it 'has a version number' do
        expect(SCNR::UI::CLI::VERSION).not_to be nil
    end
end
