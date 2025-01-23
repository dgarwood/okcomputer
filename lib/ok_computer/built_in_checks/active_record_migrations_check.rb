module OkComputer
  class ActiveRecordMigrationsCheck < Check
    # Public: Check if migrations are pending or not
    def check
      # this check is only valid if config.active_record.migration_error
      # is set to false rather than :page_load
      # :page_load is the default in development, otherwise this is false
      if Rails.configuration.active_record.migration_error
        return mark_message("NO pending migrations") if Rails.env.development?

        return check_on_page_load
      end

      if Gem::Version.new(Rails.version) >= Gem::Version.new("7.1")
        ActiveRecord::Migration.check_all_pending!
      else
        ActiveRecord::Migration.check_pending!
      end

      mark_message "NO pending migrations"
    rescue ActiveRecord::PendingMigrationError
      mark_failure
      mark_message "Pending migrations"
    end

    private

    # We do not fail the check here since this method is only called
    # when rails is configured to make the check and throw an error
    def check_on_page_load
      mark_message "NOTE: pending migrations are checked on page_load"
    end
  end
end
