class CreatePixiAsks < ActiveRecord::Migration
  def change
    create_table :pixi_asks do |t|
      t.integer :user_id
      t.string :pixi_id

      t.timestamps
    end
  end
end
