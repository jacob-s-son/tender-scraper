class CreateProxyServers < ActiveRecord::Migration
  def change
    create_table :proxy_servers do |t|
      t.string :ip
      t.string :port
      t.integer :priority
      t.boolean :black_listed_flag

      t.timestamps
    end
  end
end
