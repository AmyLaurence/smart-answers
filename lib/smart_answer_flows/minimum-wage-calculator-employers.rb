require "smart_answer_flows/shared/minimum_wage_flow"

module SmartAnswer
  class MinimumWageCalculatorEmployersFlow < Flow
    def define
      start_page_content_id "cc25f6ca-0553-4400-9dba-a43294fee84b"
      flow_content_id "fe2a4b16-bd8c-42c7-bd89-8c5f825673e2"
      name "minimum-wage-calculator-employers"
      status :published
      satisfies_need "100145"

      # Q1
      multiple_choice :what_would_you_like_to_check? do
        option "current_payment"
        option "past_payment"

        calculate :calculator do |response|
          if response == "past_payment"
            Calculators::MinimumWageCalculator.new(date: Date.parse("2018-04-01"))
          else
            Calculators::MinimumWageCalculator.new
          end
        end

        calculate :accommodation_charge

        next_node do |response|
          case response
          when "current_payment"
            question :are_you_an_apprentice?
          when "past_payment"
            question :were_you_an_apprentice?
          end
        end
      end

      # Q3
      value_question :how_old_are_you?, parse: Integer do
        precalculate :age_title do
          "How old are you?"
        end

        validate do |response|
          calculator.valid_age?(response)
        end

        next_node do |response|
          calculator.age = response
          if calculator.under_school_leaving_age?
            outcome :under_school_leaving_age
          else
            question :how_often_do_you_get_paid?
          end
        end
      end

      append(Shared::MinimumWageFlow.build)
    end
  end
end
