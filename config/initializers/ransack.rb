# frozen_string_literal: true

Ransack.configure do |c|
  c.postgres_fields_sort_option = :nulls_always_last
end
