# frozen_string_literal: true

require 'rails_helper'

describe 'sessions/new.html.erb', type: :view do
  context 'should show signup form' do
    before do
      render
    end

    it 'should show email and password fields' do
      expect(rendered).to have_xpath("//input[@id='email']")
      expect(rendered).to have_xpath("//input[@id='password']")
    end

    it 'should have remember me checkbox' do
      expect(rendered).to have_xpath("//*[@id='user_remember_me']")
    end

    it 'should have login button' do
      expect(rendered).to have_xpath("//button[@type='submit']")
    end
  end
end
