class ChangeTenderOpeningDateType < ActiveRecord::Migration
  def up
    change_column :tenders, :opening_date, :date
  end

  def down
    change_column :tenders, :opening_date, :string
  end
end

