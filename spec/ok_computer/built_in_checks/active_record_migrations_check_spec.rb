require "rails_helper"

module OkComputer
  describe ActiveRecordMigrationsCheck do
    let(:rails_pending_migration_method) do
      if Rails.version >= "7.1"
        # rails now supports multiple databases and checks
        # that any of them have pending migrations
        :check_all_pending!
      else
        :check_pending!
      end
    end

    it "is a subclass of Check" do
      expect(subject).to be_a Check
    end

    context "#check" do
      before do
        allow(Rails.configuration.active_record).to receive(:migration_error).and_return(nil)
      end

      context "with no pending migrations" do
        before do
          expect(ActiveRecord::Migration).to receive(rails_pending_migration_method).and_return(nil)
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "NO pending migrations" }
      end

      context "with pending migrations" do
        before do
          expect(ActiveRecord::Migration).to receive(rails_pending_migration_method).and_raise(ActiveRecord::PendingMigrationError)
        end

        it { is_expected.not_to be_successful_check }
        it { is_expected.to have_message "Pending migrations" }
      end

      context "when active_record.migration_error set to :page_load" do
        before do
          allow(Rails.application.config.active_record).to receive(:migration_error).and_return(:page_load)
        end

        it { is_expected.to be_successful_check }
        it { is_expected.to have_message "NOTE: pending migrations are checked on page_load" }

        context "when in the development env" do
          before do
            allow(Rails.env).to receive(:development?).and_return(true)
          end

          it { is_expected.to be_successful_check }
          it { is_expected.to have_message "NO pending migrations" }
        end
      end
    end
  end
end
