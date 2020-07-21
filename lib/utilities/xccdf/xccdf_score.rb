module Utils
  # Perform scoring calculations for the different types that is used in a TestResult score.
  class XCCDFScore
    # @param groups [Array[HappyMapperTools::Benchmark::Group]]
    # @param rule_results [Array[RuleResultType]]
    def initialize(groups, rule_results)
      @groups = groups
      @rule_results = rule_results
    end

    # Calculate and return the urn:xccdf:scoring:default score for the entire benchmark.
    # @return ScoreType
    def default_score
      build_score_type('urn:xccdf:scoring:default', 100, score_benchmark_default)
    end

    # urn:xccdf:scoring:flat
    # @return ScoreType
    def flat_score
      results = score_benchmark_with_weights(true)
      build_score_type('urn:xccdf:scoring:flat', results[:max], results[:score])
    end

    # urn:xccdf:scoring:flat-unweighted
    # @return ScoreType
    def flat_unweighted_score
      results = score_benchmark_with_weights(false)
      build_score_type('urn:xccdf:scoring:flat-unweighted', results[:max], results[:score])
    end

    # urn:xccdf:scoring:absolute
    # @return ScoreType
    def absolute_score
      results = score_benchmark_with_weights(true)
      build_score_type('urn:xccdf:scoring:absolute', 1, (results[:max] == results[:score] && results[:max].positive? ? 1 : 0))
    end

    private

    def build_score_type(system, maximum, score)
      score_type = HappyMapperTools::Benchmark::ScoreType.new
      score_type.system = system
      score_type.maximum = maximum
      score_type.score = score
      score_type
    end

    # Return the overall score for the default model
    def score_benchmark_default
      return 0.0 unless @groups

      count = 0
      cumulative_score = 0.0

      @groups.each do |group|
        # Default weighted scoring only provides value when more than one rule exists per group. This implementation
        # is not currently supporting more than one rule per group so weight need not apply.
        rule_score = score_default_rule(test_results(group.rule.id))

        if rule_score[:rule_count].positive?
          count += 1
          cumulative_score += rule_score[:rule_score]
        end
      end

      return 0.0 unless count.positive?

      (cumulative_score / count).round(2)
    end

    # @param weighted [Boolean] Indicate to apply with weights.
    def score_benchmark_with_weights(weighted)
      score = 0.0
      max_score = 0.0

      return { score: score, max: max_score } unless @groups

      @groups.each do |group|
        # Default weighted scoring only provides value when more than one rule exists per group. This implementation
        # is not currently supporting more than one rule per group so weight need not apply.
        rule_score = rule_counts_and_score(test_results(group.rule.id))

        next unless rule_score[:rule_count].positive?

        weight =
          if weighted
            group.rule.weight.nil? ? 1.0 : group.rule.weight.to_f
          else
            group.rule.weight.nil? || group.rule.weight.to_f != 0.0 ? 1.0 : 0.0
          end

        max_score += weight
        score += (weight * rule_score[:rule_score]) / rule_score[:rule_count]
      end

      { score: score.round(2), max: max_score }
    end

    def score_default_rule(results)
      sum = rule_counts_and_score(results)
      return empty_score if sum[:rule_count].zero?

      sum[:rule_score] = (100 * sum[:rule_score]) / sum[:rule_count]
      sum
    end

    # Perform basic summation of rule results and passing tests
    def rule_counts_and_score(results)
      rule_count = 0
      rule_score = 0
      excluded_results = %w{notapplicable notchecked informational notselected}

      results.each do |result|
        unless excluded_results.include? result.result
          rule_count += 1
          rule_score += 1 if result.result == 'pass'
        end
      end

      return empty_score if rule_count.zero?

      { rule_count: rule_count, rule_score: rule_score }
    end

    # Used as a score when a rule is not included in scoring
    def empty_score
      {
        rule_count: 0,
        rule_score: 0
      }
    end

    # Get all test results with the matching rule id
    # @return [Array]
    def test_results(id)
      return [] unless @rule_results

      @rule_results.select { |r| r.idref == id }
    end
  end
end
