module Riot
  class YieldsMacro < AssertionMacro
    register :yields

    def evaluate(actual, expected)
      actual_yields = actual.yield

      if expected == actual_yields
        pass new_message.yields(expected)
      else
        fail expected_message(expected).not(actual_yields)
      end
    end

    def devaluate(actual, expected)
      actual_yeilds = actual.yield

      if expected != actual_yields
        pass new_message.yields(expected).when_it_is(actual_yields)
      else
        fail new_message.did_not_expect(actual_yields)
      end
    end
  end
end
