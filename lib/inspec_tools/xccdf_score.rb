module InspecTools
  # Perform scoring calculations for the different types that is used in a TestResult score.
  class XCCDFScore # rubocop:disable Metrics/ClassLength
    # @param groups [Array[HappyMapperTools::Benchmark::Group]]
    # @param rule_results [Array[RuleResultType]]
    def initialize(groups, rule_results)
      @groups = groups
      @rule_results = rule_results
    end

    # Calculate and return the urn:xccdf:scoring:default score for the entire benchmark.
    # @return ScoreType
    def default_score
      score = HappyMapperTools::Benchmark::ScoreType.new
      score.system = 'urn:xccdf:scoring:default'
      score.maximum = 100
      score.score = score_benchmark_default
      score
    end

    # urn:xccdf:scoring:flat
    # @return ScoreType
    def flat_score
      results = score_benchmark_flat

      score = HappyMapperTools::Benchmark::ScoreType.new
      score.system = 'urn:xccdf:scoring:flat'
      score.maximum = results[:max]
      score.score = results[:score]
      score
    end

    # urn:xccdf:scoring:flat-unweighted
    # @return ScoreType
    def flat_unweighted_score
      results = score_benchmark_flat_unweighted

      score = HappyMapperTools::Benchmark::ScoreType.new
      score.system = 'urn:xccdf:scoring:flat-unweighted'
      score.maximum = results[:max]
      score.score = results[:score]
      score
    end

    # urn:xccdf:scoring:absolute
    # @return ScoreType
    def absolute_score
      results = score_benchmark_flat

      score = HappyMapperTools::Benchmark::ScoreType.new
      score.system = 'urn:xccdf:scoring:absolute'
      score.maximum = 1
      score.score = (results[:max] == results[:score] && results[:max].positive? ? 1 : 0)
      score
    end

    private

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

      round_number(cumulative_score / count)
    end

    def score_benchmark_flat
      score_benchmark_with_weights(true)
    end

    def score_benchmark_flat_unweighted
      score_benchmark_with_weights(false)
    end

    # @param weighted [Boolean] Indicate to apply with weights.
    def score_benchmark_with_weights(weighted)
      score = 0.0
      max_score = 0.0

      return { score: score, max: max_score } unless @groups

      @groups.each do |group|
        # Default weighted scoring only provides value when more than one rule exists per group. This implementation
        # is not currently supporting more than one rule per group so weight need not apply.
        rule_score = score_flat_rule(test_results(group.rule.id))

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

      { score: round_number(score), max: max_score }
    end

    def score_default_rule(results)
      sum = rule_counts_and_score(results)
      return empty_score if sum[:rule_count].zero?

      score = {}
      score[:rule_count] = sum[:rule_count]
      score[:rule_score] = (100 * sum[:rule_score]) / sum[:rule_count]
      score
    end

    def score_flat_rule(results)
      rule_counts_and_score(results)
    end

    # Perform basic summation of or rule results and passing tests
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

    # Round to 2 digits, removing if there are none.
    def round_number(value)
      format('%<number>g', number: format('%<number>.2f', number: value)).to_f
    end
  end
end
