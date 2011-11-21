class ChangeAndRenameColumnOnTender < ActiveRecord::Migration
  def change
    change_column :tenders, :locked, :string
    rename_column :tenders, :locked, :locked_status
  end
end
