require_relative "../../test_helper"

module SmartAnswer::Calculators
  class HolidayEntitlementTest < ActiveSupport::TestCase
    context "calculating fraction of year" do
      should "return 1 with no start date or leaving date" do
        calc = HolidayEntitlement.new
        assert_equal 1, calc.fraction_of_year
      end

      context "with a start_date" do
        should "return the fraction of a year" do
          calc = HolidayEntitlement.new(start_date: Date.parse("2011-02-21"))
          assert_equal "0.8603", sprintf("%.4f", calc.fraction_of_year)
        end

        should "return the fraction of a year in a leap year" do
          calc = HolidayEntitlement.new(start_date: Date.parse("2012-02-21"))
          assert_equal "0.8607", sprintf("%.4f", calc.fraction_of_year)
        end

        should "return the fraction of a year in a leap year not covering Feb 29th" do
          calc = HolidayEntitlement.new(start_date: Date.parse("2012-03-01"))
          assert_equal "0.8361", sprintf("%.4f", calc.fraction_of_year)
        end
      end

      context "with a leaving_date" do
        should "return the fraction of a year" do
          calc = HolidayEntitlement.new(leaving_date: Date.parse("2011-06-21"))
          assert_equal "0.4712", sprintf("%.4f", calc.fraction_of_year)
        end

        should "return the fraction of a year in a leap year" do
          calc = HolidayEntitlement.new(leaving_date: Date.parse("2012-06-21"))
          assert_equal "0.4727", sprintf("%.4f", calc.fraction_of_year)
        end

        should "return the fraction of a year in a leap year not covering Feb 29th" do
          calc = HolidayEntitlement.new(leaving_date: Date.parse("2012-01-21"))
          assert_equal "0.0574", sprintf("%.4f", calc.fraction_of_year)
        end
      end

      context "with a leave_year_start" do
        context "with a start date" do
          context "start date before leave_year_start" do
            should "return the fraction of a year" do
              calc = HolidayEntitlement.new(start_date: Date.parse("2011-01-21"), leave_year_start_date: Date.parse("2011-02-01"))
              assert_equal "0.0301", sprintf("%.4f", calc.fraction_of_year)
            end

            should "return the fraction of a year in a leap year" do
              # 2011-12-31 to 2012-12-30
              calc = HolidayEntitlement.new(start_date: Date.parse("2012-02-02"), leave_year_start_date: Date.parse("2012-12-31"))
              assert_equal "0.9098", sprintf("%.4f", calc.fraction_of_year)
            end

            should "return the fraction of a year in a leap year not covering Feb 29th" do
              calc = HolidayEntitlement.new(start_date: Date.parse("2013-01-21"), leave_year_start_date: Date.parse("2013-02-01"))
              assert_equal "0.0301", sprintf("%.4f", calc.fraction_of_year)
            end
          end # context - start date before leave_year_start

          context "start date after leave_year_start" do
            should "return the fraction of a year" do
              calc = HolidayEntitlement.new(start_date: Date.parse("2011-04-21"), leave_year_start_date: Date.parse("2011-02-01"))
              assert_equal "0.7836", sprintf("%.4f", calc.fraction_of_year)
            end

            should "return the fraction of a year in a leap year" do
              calc = HolidayEntitlement.new(start_date: Date.parse("2012-02-21"), leave_year_start_date: Date.parse("2012-02-01"))
              assert_equal "0.9454", sprintf("%.4f", calc.fraction_of_year)
            end

            should "return the fraction of a year in a leap year not covering Feb 29th" do
              calc = HolidayEntitlement.new(start_date: Date.parse("2012-04-21"), leave_year_start_date: Date.parse("2012-02-01"))
              assert_equal "0.7814", sprintf("%.4f", calc.fraction_of_year)
            end
          end # context - start date after leave_year_start
        end # context - with a start date

        context "with a leave date" do
          context "leaving date before leave_year_start" do
            should "return the fraction of a year" do
              calc = HolidayEntitlement.new(leaving_date: Date.parse("2011-01-21"), leave_year_start_date: Date.parse("2011-02-01"))
              assert_equal "0.9726", sprintf("%.4f", calc.fraction_of_year)
            end

            should "return the fraction of a year in a leap year" do
              calc = HolidayEntitlement.new(leaving_date: Date.parse("2013-01-21"), leave_year_start_date: Date.parse("2013-02-01"))
              assert_equal "0.9727", sprintf("%.4f", calc.fraction_of_year)
            end

            should "return the fraction of a year in a leap year not covering Feb 29th" do
              calc = HolidayEntitlement.new(leaving_date: Date.parse("2012-01-21"), leave_year_start_date: Date.parse("2012-03-01"))
              assert_equal "0.8934", sprintf("%.4f", calc.fraction_of_year)
            end
          end # context - leaving date before leave_year_start

          context "leaving date after leave_year_start" do
            should "return the fraction of a year" do
              calc = HolidayEntitlement.new(leaving_date: Date.parse("2011-04-21"), leave_year_start_date: Date.parse("2011-02-01"))
              assert_equal "0.2192", sprintf("%.4f", calc.fraction_of_year)
            end

            should "return the fraction of a year in a leap year" do
              calc = HolidayEntitlement.new(leaving_date: Date.parse("2012-04-21"), leave_year_start_date: Date.parse("2012-02-01"))
              assert_equal "0.2213", sprintf("%.4f", calc.fraction_of_year)
            end

            should "return the fraction of a year in a leap year not covering Feb 29th" do
              calc = HolidayEntitlement.new(leaving_date: Date.parse("2012-02-21"), leave_year_start_date: Date.parse("2012-02-01"))
              assert_equal "0.0574", sprintf("%.4f", calc.fraction_of_year)
            end
          end # context - leaving date after leave_year_start
        end # context - with a leave date
      end # context - with a leave_year_start

      should "format the result" do
        calc = HolidayEntitlement.new(start_date: Date.parse("2012-02-21"))
        assert_equal "0.87", calc.formatted_fraction_of_year
      end
    end # context - calculating fraction of year

    context "calculating full-time or part-time holiday entitlement" do
      context "working for a full year" do
        should "calculate entitlement for 5 days a week" do
          calc = HolidayEntitlement.new(
            days_per_week: 5,
          )

          assert_equal 28, calc.full_time_part_time_days
        end

        should "calculate entitlement for more than 5 days a week" do
          calc = HolidayEntitlement.new(
            days_per_week: 6,
          )

          # 28 is the max
          assert_equal 28, calc.full_time_part_time_days
        end

        should "calculate entitlement for less than 5 days a week" do
          calc = HolidayEntitlement.new(
            days_per_week: 3,
          )

          assert_equal "16.80", sprintf("%.2f", calc.full_time_part_time_days)
        end
      end # full year

      context "starting this year" do
        should "calculate entitlement for 5 days a week" do
          calc = HolidayEntitlement.new(
            start_date: Date.parse("2012-03-12"),
            days_per_week: 5,
          )
          assert_equal "22.57", sprintf("%.2f", calc.full_time_part_time_days)
        end

        should "calculate entitlement for more than 5 days a week" do
          calc = HolidayEntitlement.new(
            start_date: Date.parse("2012-03-12"),
            days_per_week: 7,
          )
          # Capped
          assert_equal "22.57", sprintf("%.2f", calc.full_time_part_time_days)
        end

        should "cap entitlement at 28 days if starting on first day" do
          calc = HolidayEntitlement.new(
            start_date: Date.parse("2012-01-01"),
            days_per_week: 7,
          )
          assert_equal 28, calc.full_time_part_time_days
        end

        should "calculate entitlement for less than 5 days per week" do
          calc = HolidayEntitlement.new(
            start_date: Date.parse("2012-03-12"),
            days_per_week: 3,
          )
          assert_equal "13.54", sprintf("%.2f", calc.full_time_part_time_days)
        end
      end # starting this year

      context "leaving this year" do
        should "calculate entitlement for 5 days a week" do
          calc = HolidayEntitlement.new(
            leaving_date: Date.parse("2012-07-24"),
            days_per_week: 5,
          )
          assert_equal "15.76", sprintf("%.2f", calc.full_time_part_time_days)
        end

        should "calculate entitlement for more than 5 days a week" do
          calc = HolidayEntitlement.new(
            leaving_date: Date.parse("2012-07-24"),
            days_per_week: 6,
          )
          # Capped
          assert_equal "15.76", sprintf("%.2f", calc.full_time_part_time_days)
        end

        should "cap entitlement at 28 days if leaving at end of year" do
          calc = HolidayEntitlement.new(
            leaving_date: Date.parse("2012-12-31"),
            days_per_week: 7,
          )
          assert_equal 28, calc.full_time_part_time_days
        end

        should "calculate entitlement for less than 5 days a week" do
          calc = HolidayEntitlement.new(
            leaving_date: Date.parse("2012-07-24"),
            days_per_week: 3,
          )
          assert_equal "9.46", sprintf("%.2f", calc.full_time_part_time_days)
        end
      end # leaving this year

      should "format the result using format_days" do
        calc = HolidayEntitlement.new
        calc.expects(:full_time_part_time_days).returns(18.342452)

        assert_equal "18.4", calc.formatted_full_time_part_time_days
      end
    end

    context "calculating full time or part time holiday entitlement by hour" do
      [{ hours_per_week: 32.5, days_per_week: 5, start_date: Date.parse("2012-03-01"), leave_year_start_date: Date.parse("2011-04-01"), expected: "15.5" },
       { hours_per_week: 15, days_per_week: 3, expected: "84" },
       { hours_per_week: 30, days_per_week: 6, expected: "140" }].each do |example|
        should example.to_s do
          calc = HolidayEntitlement.new(example.except(:expected))
          assert_equal example[:expected], calc.formatted_full_time_part_time_hours
        end
      end
    end

    context "calculating compressed hours entitlement" do
      should "return the hours and minutes of entitlement" do
        calc = HolidayEntitlement.new(hours_per_week: 20.5, days_per_week: 3)
        assert_equal [114, 48], calc.compressed_hours_entitlement
      end

      should "return the hours and minutes of daily entitlement" do
        calc = HolidayEntitlement.new(hours_per_week: 20.5, days_per_week: 3)
        assert_equal [6, 50], calc.compressed_hours_daily_average
      end
    end

    context "calculating shift worker shifts" do
      context "full year" do
        setup do
          @calc = HolidayEntitlement.new(
            hours_per_shift: 7.5,
            shifts_per_shift_pattern: 4,
            days_per_shift_pattern: 8,
          )
        end

        should "return the average shifts per week" do
          assert_equal 3.5, @calc.send(:shifts_per_week)
        end

        should "return the holiday entitlement in shifts" do
          assert_equal "19.600", sprintf("%.3f", @calc.shift_entitlement)
        end
      end # full year

      context "starting this year" do
        setup do
          @calc = HolidayEntitlement.new(
            start_date: Date.parse("2012-07-01"),
            hours_per_shift: 7.5,
            shifts_per_shift_pattern: 4,
            days_per_shift_pattern: 8,
          )
        end

        should "return the holiday entitlement in shifts" do
          assert_equal "9.854", sprintf("%.3f", @calc.shift_entitlement)
        end
      end

      context "leaving this year" do
        setup do
          @calc = HolidayEntitlement.new(
            leaving_date: Date.parse("2012-09-30"),
            hours_per_shift: 7.5,
            shifts_per_shift_pattern: 4,
            days_per_shift_pattern: 8,
          )
        end

        should "return the holiday entitlement in shifts" do
          assert_equal "14.673", sprintf("%.3f", @calc.shift_entitlement)
        end
      end
    end

    context "strip_zeros" do
      setup do
        @calc = HolidayEntitlement.new
      end

      should "strip trailing zeroes after the dp from numbers" do
        assert_equal "123", @calc.strip_zeros(123.0)
      end

      should "not strip significant zeroes" do
        assert_equal "120", @calc.strip_zeros(120.0)
      end
    end

    context "formatted version of anything" do
      # implemented with method_missing
      setup do
        @calc = HolidayEntitlement.new
        class << @calc
          def foo; end
        end
      end

      should "return foo to 1 dp by default" do
        @calc.stubs(:foo).returns(123.6593)
        assert_equal "123.7", @calc.formatted_foo
      end

      should "round up in all cases" do
        @calc.stubs(:foo).returns(123.00001)
        assert_equal "123.1", @calc.formatted_foo
      end

      should "allow overriding the dp" do
        @calc.stubs(:foo).returns(123.6593)
        assert_equal "123.66", @calc.formatted_foo(2)
      end

      should "strip .0 from foo" do
        @calc.stubs(:foo).returns(0.0)
        assert_equal "0", @calc.formatted_foo
      end

      should "respond to foo" do
        assert @calc.respond_to?(:foo)
      end
    end

    context "decimal precision in hours and minutes calculations" do
      setup do
        @calc = HolidayEntitlement.new(
          hours_per_week: 28,
          days_per_week: 5,
          start_date: nil,
          leave_year_start_date: nil,
        )
      end
      should "calculate with the correct precision" do
        assert_equal 156.8, @calc.full_time_part_time_hours
      end
    end
    context "decimal precision in days_per_week calculations" do
      setup do
        @calc = HolidayEntitlement.new(
          days_per_week: 4.5,
          start_date: nil,
          leave_year_start_date: nil,
        )
      end
      should "calculate with the correct precision" do
        assert_equal 25.2, @calc.full_time_part_time_days
      end
    end
  end
end
