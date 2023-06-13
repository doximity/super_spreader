# frozen_string_literal: true

require "active_record"

module SuperSpreader
  # Methods in this module are suitable for use in Rails migrations.  It is
  # expected that their interface will remain stable.  If breaking changes are
  # introduced, a new module will be introduced so existing migrations will not
  # be affected.
  module BatchHelper
    # Execute SQL in small batches for an entire table.
    #
    # It is assumed that the table has a primary key named +id+.
    #
    # Recommendation for migrations: Use this in combination with +disable_ddl_transaction!+.  See also: https://github.com/ankane/strong_migrations#backfilling-data
    #
    # @param table_name [String] the name of the table
    # @param step_size [Integer] how many records to process in each batch
    # @yield [minimum_id, maximum_id] block that returns SQL to migrate records between minimum_id and maximum_id
    def batch_execute(table_name:, step_size:)
      result = execute(<<~SQL).to_a.flatten
        SELECT MIN(id) AS min_id, MAX(id) AS max_id FROM #{table_name}
      SQL
      min_id = result[0]["min_id"]
      max_id = result[0]["max_id"]
      return unless min_id && max_id

      lower_id = min_id
      loop do
        sql = yield(lower_id, lower_id + step_size)

        execute sql

        lower_id += step_size
        break if lower_id > max_id
      end
    end
  end
end
