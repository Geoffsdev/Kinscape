class MigrateActiveStorageVariantsPkToUuid < ActiveRecord::Migration[6.1]
  def change
    add_column :active_storage_variant_records, :uuid, :uuid, default: 'uuid_generate_v4()', null: false
    rename_column :active_storage_variant_records, :id, :integer_id
    rename_column :active_storage_variant_records, :uuid, :id
    execute 'ALTER TABLE active_storage_variant_records DROP CONSTRAINT IF EXISTS active_storage_variant_records_pkey;'
    execute 'ALTER TABLE active_storage_variant_records ADD PRIMARY KEY (id);'

    execute 'ALTER TABLE ONLY active_storage_variant_records ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :active_storage_variant_records, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS active_storage_variant_records_id_seq'
  end
end
