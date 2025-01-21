require "rails_helper"

module OkComputer
  describe ActiveRecordMigrationsCheck do
    it "is a subclass of Check" do
      expect(subject).to be_a Check
    end

    current_rails_version = Gem::Version.new(ActiveRecord::VERSION::STRING)

    # 4.0 <= Rails < 7.2
    if current_rails_version >= Gem::Version.new("7.1")
      # rails now supports multiple databases and checks
      # that any of them have pending migrations

      context "#check" do
        before do
          allow(Rails.configuration.active_record).to receive(:migration_error).and_return(nil)
        end

        context "with no pending migrations" do
          before do
            expect(ActiveRecord::Migration).to receive(:check_all_pending!).and_return(nil)
          end

          it { is_expected.to be_successful_check }
          it { is_expected.to have_message "NO pending migrations" }
        end

        context "with pending migrations" do
          before do
            expect(ActiveRecord::Migration).to receive(:check_all_pending!).and_raise(ActiveRecord::PendingMigrationError)
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
    else # Rails < 7.1
      context "#check" do
        before do
          allow(Rails.configuration.active_record).to receive(:migration_error).and_return(nil)
        end

        context "with no pending migrations" do
          before do
            expect(ActiveRecord::Migration).to receive(:check_pending!).and_return(nil)
          end

          it { is_expected.to be_successful_check }
          it { is_expected.to have_message "NO pending migrations" }
        end

        context "with pending migrations" do
          before do
            expect(ActiveRecord::Migration).to receive(:check_pending!).and_raise(ActiveRecord::PendingMigrationError)
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
end
