class CreateCalculators < ActiveRecord::Migration[5.0]
  def change
    create_table :calculators do |t|
      t.string :data
      t.string :col_index
      t.string :row_index
      t.string :url_gen
      t.timestamps
    end
  end
end
