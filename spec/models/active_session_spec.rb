# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveSession, type: :model do
  let(:active_session) { create(:active_session) }

  it 'should be valid' do
    expect(active_session).to be_valid
  end

  it 'should have a user' do
    active_session.user = nil
    expect(active_session).not_to be_valid
  end
end
