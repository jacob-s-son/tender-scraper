class FixMistype < ActiveRecord::Migration
  def change
    rename_column :tenders, :locked_status, :lock_status
  end
end
