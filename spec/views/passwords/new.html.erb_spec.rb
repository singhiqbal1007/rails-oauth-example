# frozen_string_literal: true

require 'rails_helper'

describe 'passwords/new.html.erb', type: :view do
  context 'should show forgot password form' do
    before do
      render
    end

    it 'should show form fields fields' do
      expect(rendered).to have_xpath("//input[@id='email']")
    end

    it 'should have signup button' do
      expect(rendered).to have_xpath("//button[@type='submit']")
    end
  end
end
