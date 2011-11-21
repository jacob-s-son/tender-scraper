class AddLockedAtAndLockedByToTender < ActiveRecord::Migration
  def change
    add_column :tenders, :locked_at, :datetime
    add_column :tenders, :locked_by, :string
  end
end
