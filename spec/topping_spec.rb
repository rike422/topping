require 'spec_helper'

RSpec.describe Topping do
  it 'has a version number' do
    expect(Topping::VERSION).not_to be nil
  end
end
