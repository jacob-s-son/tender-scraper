class AddLastTimeEditedByMarkedForExportToTender < ActiveRecord::Migration
  def change
    add_column :tenders, :last_time_edited_by, :integer
    add_column :tenders, :marked_for_export, :boolean
  end
end
