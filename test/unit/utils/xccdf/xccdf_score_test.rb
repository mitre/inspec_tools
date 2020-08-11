require_relative '../../test_helper'
require_relative '../../../../lib/utilities/xccdf/xccdf_score'
require_relative '../../../../lib/happy_mapper_tools/benchmark'

# rubocop:disable Metrics/BlockLength

describe Utils::XCCDFScore do
  before do
    @dci = Utils::XCCDFScore.new(groups, rule_results)
  end

  let(:groups) { [] }
  let(:rule_results) { [] }
  let(:rule_result_pass_1) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'pass' }.tap { |r| r.idref = 'rule1' } }
  let(:rule_result_pass_2) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'pass' }.tap { |r| r.idref = 'rule2' } }
  let(:rule_result_pass_3) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'pass' }.tap { |r| r.idref = 'rule5' } }
  let(:rule_result_fail_1) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'fail' }.tap { |r| r.idref = 'rule3' } }
  let(:rule_result_fail_2) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'fail' }.tap { |r| r.idref = 'rule4' } }
  let(:rule_1) { HappyMapperTools::Benchmark::Rule.new.tap { |r| r.id = 'rule1' } }
  let(:group_1) { HappyMapperTools::Benchmark::Group.new.tap { |g| g.rule = rule_1 } }
  let(:rule_2) { HappyMapperTools::Benchmark::Rule.new.tap { |r| r.id = 'rule2' } }
  let(:group_2) { HappyMapperTools::Benchmark::Group.new.tap { |g| g.rule = rule_2 } }
  let(:rule_3) { HappyMapperTools::Benchmark::Rule.new.tap { |r| r.id = 'rule3' } }
  let(:group_3) { HappyMapperTools::Benchmark::Group.new.tap { |g| g.rule = rule_3 } }
  let(:rule_4) { HappyMapperTools::Benchmark::Rule.new.tap { |r| r.id = 'rule4' }.tap { |r| r.weight = 10.0 } }
  let(:group_4) { HappyMapperTools::Benchmark::Group.new.tap { |g| g.rule = rule_4 } }
  let(:rule_5) { HappyMapperTools::Benchmark::Rule.new.tap { |r| r.id = 'rule5' }.tap { |r| r.weight = 0.0 } }
  let(:group_5) { HappyMapperTools::Benchmark::Group.new.tap { |g| g.rule = rule_5 } }

  describe '#default_score' do
    it 'returns the correct system identifier' do
      assert_equal 'urn:xccdf:scoring:default', @dci.default_score.system
    end

    it 'returns the maximum score of 100' do
      assert_equal 100, @dci.default_score.maximum
    end

    describe 'when there are no results' do
      it 'returns a score of 0' do
        assert_equal 0, @dci.default_score.score
      end
    end

    describe 'when all tests pass' do
      let(:groups) { [group_1, group_2] }
      let(:rule_results) { [rule_result_pass_1, rule_result_pass_2] }

      it 'returns a score of 100' do
        assert_equal 100, @dci.default_score.score
      end
    end

    describe 'when some tests pass' do
      let(:groups) { [group_1, group_2, group_3] }
      let(:rule_results) { [rule_result_pass_1, rule_result_pass_2, rule_result_fail_1] }

      it 'returns a score of 66.67' do
        assert_equal 66.67, @dci.default_score.score
      end
    end

    describe 'when no tests pass' do
      it 'returns a score of 0' do
        assert_equal 0.0, @dci.default_score.score
      end
    end
  end

  describe '#flat_score' do
    let(:groups) { [group_1, group_2, group_3] }
    let(:rule_results) { [rule_result_pass_1, rule_result_pass_2, rule_result_fail_1] }

    it 'returns the correct system identifier' do
      assert_equal 'urn:xccdf:scoring:flat', @dci.flat_score.system
    end

    it 'returns the maximum score of 3' do
      assert_equal 3, @dci.flat_score.maximum
    end

    describe 'when a rule is weighted' do
      let(:groups) { [group_1, group_3, group_4] }
      let(:rule_results) { [rule_result_pass_1, rule_result_fail_1, rule_result_fail_2] }

      it 'applies weighting to the score' do
        score = @dci.flat_score
        assert_equal 1, score.score
        assert_equal 12, score.maximum
      end
    end

    describe 'when a rule has a weight of 0' do
      let(:groups) { [group_1, group_3, group_5] }
      let(:rule_results) { [rule_result_pass_1, rule_result_fail_1, rule_result_pass_3] }

      it 'is not included in the score' do
        score = @dci.flat_score
        assert_equal 1, score.score
        assert_equal 2, score.maximum
      end
    end

    describe 'when all tests pass' do
      let(:groups) { [group_1, group_2] }
      let(:rule_results) { [rule_result_pass_1, rule_result_pass_2] }

      it 'returns a score of 2' do
        assert_equal 2, @dci.flat_score.score
      end
    end

    describe 'when some tests pass' do
      let(:groups) { [group_1, group_2, group_3] }
      let(:rule_results) { [rule_result_pass_1, rule_result_pass_2, rule_result_fail_1] }

      it 'returns a score of 2' do
        assert_equal 2, @dci.flat_score.score
      end
    end

    describe 'when no tests pass' do
      let(:groups) { [group_3] }
      let(:rule_results) { [rule_result_fail_1] }

      it 'returns a score of 0' do
        assert_equal 0.0, @dci.flat_score.score
      end
    end
  end

  describe '#flat_unweighted_score' do
    let(:groups) { [group_1, group_2, group_3] }
    let(:rule_results) { [rule_result_pass_1, rule_result_pass_2, rule_result_fail_1] }

    it 'returns the correct system identifier' do
      assert_equal 'urn:xccdf:scoring:flat-unweighted', @dci.flat_unweighted_score.system
    end

    it 'returns the maximum score of 3' do
      assert_equal 3, @dci.flat_unweighted_score.maximum
    end

    describe 'when a rule is weighted' do
      let(:groups) { [group_1, group_3, group_4] }
      let(:rule_results) { [rule_result_pass_1, rule_result_fail_1, rule_result_fail_2] }

      it 'applies weighting to the score' do
        score = @dci.flat_unweighted_score
        assert_equal 1, score.score
        assert_equal 3, score.maximum
      end
    end

    describe 'when a rule has a weight of 0' do
      let(:groups) { [group_1, group_3, group_5] }
      let(:rule_results) { [rule_result_pass_1, rule_result_fail_1, rule_result_pass_3] }

      it 'is not included in the score' do
        score = @dci.flat_unweighted_score
        assert_equal 1, score.score
        assert_equal 2, score.maximum
      end
    end

    describe 'when all tests pass' do
      it 'returns a score of 2' do
        assert_equal 2, @dci.flat_unweighted_score.score
      end
    end

    describe 'when some tests pass' do
      it 'returns a score of 2' do
        assert_equal 2, @dci.flat_unweighted_score.score
      end
    end

    describe 'when no tests pass' do
      let(:groups) { [group_3] }
      let(:rule_results) { [rule_result_fail_1] }

      it 'returns a score of 0' do
        assert_equal 0.0, @dci.flat_unweighted_score.score
      end
    end
  end

  describe '#absolute_score' do
    it 'returns the correct system identifier' do
      assert_equal 'urn:xccdf:scoring:absolute', @dci.absolute_score.system
    end

    it 'returns the maximum score of 1' do
      assert_equal 1, @dci.absolute_score.maximum
    end

    describe 'when there are no results' do
      it 'returns a score of 0' do
        assert_equal 0, @dci.absolute_score.score
      end
    end

    describe 'when all tests pass' do
      let(:groups) { [group_1, group_2] }
      let(:rule_results) { [rule_result_pass_1, rule_result_pass_2] }

      it 'returns a score of 1' do
        assert_equal 1, @dci.absolute_score.score
      end
    end

    describe 'when some tests pass' do
      it 'returns a score of 0.0' do
        assert_equal 0.0, @dci.absolute_score.score
      end
    end

    describe 'when no tests pass' do
      it 'returns a score of 0.0' do
        assert_equal 0.0, @dci.absolute_score.score
      end
    end
  end

  describe '#rule_counts_and_score' do

    describe 'when no results are provided' do
      it 'returns count of 0 and score of 0' do
        results = []
        assert_equal @dci.send(:rule_counts_and_score, results), { rule_count: 0, rule_score: 0 }
      end
    end

    describe 'when a result is notapplicable' do
      let(:result_not_applicable) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'notapplicable' } }

      it 'is not counted in the rule count or score' do
        results = [result_not_applicable]
        assert_equal @dci.send(:rule_counts_and_score, results), { rule_count: 0, rule_score: 0 }
      end
    end

    describe 'when a result is notchecked' do
      let(:result_not_checked) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'notchecked' } }

      it 'is not counted in the rule count or score' do
        results = [result_not_checked]
        assert_equal @dci.send(:rule_counts_and_score, results), { rule_count: 0, rule_score: 0 }
      end
    end

    describe 'when a result is informational' do
      let(:result_informational) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'informational' } }

      it 'is not counted in the rule count or score' do
        results = [result_informational]
        assert_equal @dci.send(:rule_counts_and_score, results), { rule_count: 0, rule_score: 0 }
      end
    end

    describe 'when a result is notselected' do
      let(:result_not_selected) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'notselected' } }

      it 'is not counted in the rule count or score' do
        results = [result_not_selected]
        assert_equal @dci.send(:rule_counts_and_score, results), { rule_count: 0, rule_score: 0 }
      end
    end

    describe 'when a result is pass' do
      let(:result_pass) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'pass' } }

      it 'is counted in the rule count and score' do
        results = [result_pass]
        assert_equal @dci.send(:rule_counts_and_score, results), { rule_count: 1, rule_score: 1 }
      end
    end

    describe 'when a result is fail' do
      let(:result_fail) { HappyMapperTools::Benchmark::RuleResultType.new.tap { |r| r.result = 'fail' } }

      it 'is counted in the rule count and score' do
        results = [result_fail]
        assert_equal @dci.send(:rule_counts_and_score, results), { rule_count: 1, rule_score: 0 }
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
