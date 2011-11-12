class CreateTenders < ActiveRecord::Migration
  def change
    create_table :tenders do |t|
      t.string :url
      t.string :registration_number
      t.string :buyer_name
      t.string :address
      t.string :city
      t.string :post_code
      t.string :country
      t.string :contact
      t.string :phone_number
      t.string :mobile_phone_number
      t.string :fax_number
      t.string :email
      t.string :website
      t.string :heading
      t.text :cpv_codes
      t.string :procurement_procedure
      t.string :case_number
      t.string :nuts_code
      t.date :publication_date
      t.date :closing_date
      t.string :closing_time
      t.string :opening_date
      t.string :opening_time
      t.date :material_closing_date
      t.string :material_closing_time
      t.string :assignment
      t.string :attachment
      t.string :tender_type
      t.string :sector
      t.decimal :value
      t.text :document
      t.integer :exported_times
      t.time :exported_at
      t.integer :last_time_exported_by

      t.timestamps
    end
  end
end
