require "suture/adapter/dictaphone"
require "suture/value/test_results"

module Suture
  class TestsPatient
    def test(test_plan)
      dictaphone = Suture::Adapter::Dictaphone.new(test_plan)
      experienced_failure_in_life = false
      Value::TestResults.new(dictaphone.play.map { |observation|
        if test_plan.fail_fast && experienced_failure_in_life
          {
            :observation => observation,
            :ran => false
          }
        else
          invoke(test_plan, observation).merge({
            :observation => observation,
            :ran => true
          }).tap { |r| experienced_failure_in_life = true unless r[:passed]}
        end
      })
    end

    def invoke(test_plan, observation)
      {}.tap do |result|
        begin
          result[:new_result] = test_plan.subject.call(*observation.args)
          # TODO: Comparators go here:
          result[:passed] = result[:new_result] == observation.result
        rescue StandardError => e
          result[:passed] = false
          result[:error] = e
        end
      end
    end
  end
end

