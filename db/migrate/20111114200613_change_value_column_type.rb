class ChangeValueColumnType < ActiveRecord::Migration
  def up
    change_column :tenders, :value, :string
  end

  def down
    change_column :tenders, :value, :decimal
  end
end
