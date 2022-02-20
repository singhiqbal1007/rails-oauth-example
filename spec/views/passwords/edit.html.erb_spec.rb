# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'passwords/edit.html.erb', type: :view do
#
#   context 'should show forgot password form' do
#     before do
#       confirmed_user = create(:user, :confirmed_now)
#       token = confirmed_user.generate_password_reset_token
#       TODO: FIX THIS
#       render template: 'passwords/edit.html.erb', locals: { password_reset_token: token }
#     end
#
#     it 'should show form fields fields' do
#       expect(rendered).to have_xpath("//input[@id='password']")
#       expect(rendered).to have_xpath("//input[@id='password_confrmation']")
#     end
#
#     it 'should have signup button' do
#       expect(rendered).to have_xpath("//button[@type='submit']")
#     end
#   end
# end
