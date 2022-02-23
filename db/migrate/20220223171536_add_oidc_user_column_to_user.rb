class AddOidcUserColumnToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :oidc_user, :boolean, null: false, default: 0
  end
end
