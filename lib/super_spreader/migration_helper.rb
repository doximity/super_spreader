# frozen_string_literal: true

module SuperSpreader
  module MigrationHelper
    def batch_execute(table_name:, step_size:, &block)
      min_id, max_id = execute(<<~SQL).to_a.flatten
        SELECT MIN(id) AS min_id, MAX(id) AS max_id FROM #{table_name}
      SQL
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
