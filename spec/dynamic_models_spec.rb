# frozen_string_literal: true

#
module DwCR
  RSpec.configure do |config|
#     config.warnings = false

    config.around(:each) do |example|
      DB.transaction(rollback: :always, auto_savepoint: true) {example.run}
    end
  end

  RSpec.describe 'DynamicModels' do

  end
end
