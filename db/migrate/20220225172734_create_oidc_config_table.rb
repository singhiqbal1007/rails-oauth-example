# frozen_string_literal: true

class CreateOidcConfigTable < ActiveRecord::Migration[6.1]
  def change
    create_table :oidc_configs do |t|
      t.string :name, null: false
      t.string :issuer, null: false
      t.string :authorization_endpoint, default: nil
      t.string :token_endpoint, default: nil

      t.timestamps
    end
  end
end
