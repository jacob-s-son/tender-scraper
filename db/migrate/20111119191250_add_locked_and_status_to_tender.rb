class AddLockedAndStatusToTender < ActiveRecord::Migration
  def change
    add_column :tenders, :locked, :boolean
    add_column :tenders, :status, :string
  end
end
