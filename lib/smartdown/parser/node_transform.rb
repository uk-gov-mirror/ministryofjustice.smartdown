require 'parslet/transform'
require 'smartdown/model/node'
require 'smartdown/model/front_matter'
require 'smartdown/model/rule'
require 'smartdown/model/nested_rule'
require 'smartdown/model/next_node_rules'
require 'smartdown/model/element/question/multiple_choice'
require 'smartdown/model/element/question/date'
require 'smartdown/model/element/question/salary'
require 'smartdown/model/element/question/text'
require 'smartdown/model/element/start_button'
require 'smartdown/model/element/markdown_heading'
require 'smartdown/model/element/markdown_paragraph'
require 'smartdown/model/element/conditional'
require 'smartdown/model/element/next_steps'
require 'smartdown/model/predicate/equality'
require 'smartdown/model/predicate/set_membership'
require 'smartdown/model/predicate/named'
require 'smartdown/model/predicate/combined'
require 'smartdown/model/predicate/function'
require 'smartdown/model/predicate/comparison/greater_or_equal'
require 'smartdown/model/predicate/comparison/greater'
require 'smartdown/model/predicate/comparison/less_or_equal'
require 'smartdown/model/predicate/comparison/less'

module Smartdown
  module Parser
    class NodeTransform < Parslet::Transform
      rule(body: subtree(:body)) {
        Smartdown::Model::Node.new(
          node_name, body, Smartdown::Model::FrontMatter.new({})
        )
      }

      rule(h1: simple(:content)) {
        Smartdown::Model::Element::MarkdownHeading.new(content)
      }

      rule(p: simple(:content)) {
        Smartdown::Model::Element::MarkdownParagraph.new(content)
      }

      rule(:start_button => simple(:start_node)) {
        Smartdown::Model::Element::StartButton.new(start_node)
      }

      rule(:front_matter => subtree(:attrs), body: subtree(:body)) {
        Smartdown::Model::Node.new(
          node_name, body, Smartdown::Model::FrontMatter.new(Hash[attrs])
        )
      }
      rule(:front_matter => subtree(:attrs)) {
        [Smartdown::Model::FrontMatter.new(Hash[attrs])]
      }
      rule(:name => simple(:name), :value => simple(:value)) {
        [name.to_s, value.to_s]
      }

      rule(:value => simple(:value), :label => simple(:label)) {
        [value.to_s, label.to_s]
      }

      rule(:url => simple(:url), :label => simple(:label)) {
        [url.to_s, label.to_s]
      }

      rule(:multiple_choice => {identifier: simple(:identifier), options: subtree(:choices)}) {
        Smartdown::Model::Element::Question::MultipleChoice.new(
          identifier, Hash[choices]
        )
      }

      rule(:date => {identifier: simple(:identifier)}) {
        Smartdown::Model::Element::Question::Date.new(
          identifier.to_s
        )
      }

      rule(:salary => {identifier: simple(:identifier)}) {
        Smartdown::Model::Element::Question::Salary.new(
          identifier.to_s
        )
      }

      rule(:text => {identifier: simple(:identifier)}) {
        Smartdown::Model::Element::Question::Text.new(
          identifier.to_s
        )
      }

      rule(:next_steps => { content: simple(:content) }) {
        Smartdown::Model::Element::NextSteps.new(content.to_s)
      }

      # Conditional with no content in true-case
      rule(:conditional => {:predicate => subtree(:predicate)}) {
        Smartdown::Model::Element::Conditional.new(predicate)
      }

      # Conditional with content in true-case
      rule(:conditional => {
             :predicate => subtree(:predicate),
             :true_case => subtree(:true_case)
           }) {
        Smartdown::Model::Element::Conditional.new(predicate, true_case)
      }

      # Conditional with content in both true-case and false-case
      rule(:conditional => {
             :predicate => subtree(:predicate),
             :true_case => subtree(:true_case),
             :false_case => subtree(:false_case)
           }) {
        Smartdown::Model::Element::Conditional.new(predicate, true_case, false_case)
      }

      rule(:equality_predicate => { varname: simple(:varname), expected_value: simple(:expected_value) }) {
        Smartdown::Model::Predicate::Equality.new(varname, expected_value)
      }

      rule(:set_value => simple(:value)) { value }

      rule(:set_membership_predicate => { varname: simple(:varname), values: subtree(:values) }) {
        Smartdown::Model::Predicate::SetMembership.new(varname, values)
      }

      rule(:named_predicate => simple(:name) ) {
        Smartdown::Model::Predicate::Named.new(name)
      }

      rule(:otherwise_predicate => simple(:name) ) {
        Smartdown::Model::Predicate::Otherwise.new
      }

      rule(:combined_predicate => {first_predicate: subtree(:first_predicate), and_predicates: subtree(:and_predicates) }) {
        Smartdown::Model::Predicate::Combined.new([first_predicate]+and_predicates)
      }

      rule(:function_argument => simple(:argument)) { argument }

      rule(:function_predicate => { name: simple(:name), arguments: subtree(:arguments) }) {
        Smartdown::Model::Predicate::Function.new(name, Array(arguments))
      }

      rule(:function_predicate => { name: simple(:name) }) {
        Smartdown::Model::Predicate::Function.new(name, [])
      }

      rule(:comparison_predicate => { varname: simple(:varname), 
                                       value: simple(:value),
                                       operator: simple(:operator)
                                     }) { 
        case operator
        when "<="
          Smartdown::Model::Predicate::Comparison::LessOrEqual.new(varname, value)
        when "<"
          Smartdown::Model::Predicate::Comparison::Less.new(varname, value)
        when ">="
          Smartdown::Model::Predicate::Comparison::GreaterOrEqual.new(varname, value)
        when ">"
          Smartdown::Model::Predicate::Comparison::Greater.new(varname, value)
        else
          raise "Comparison operator not recognised"
        end
      }

      rule(:rule => {predicate: subtree(:predicate), outcome: simple(:outcome_name) } ) {
        Smartdown::Model::Rule.new(predicate, outcome_name)
      }
      rule(:nested_rule => {predicate: subtree(:predicate), child_rules: subtree(:child_rules) } ) {
        Smartdown::Model::NestedRule.new(predicate, child_rules)
      }
      rule(:next_node_rules => subtree(:rules)) {
        Smartdown::Model::NextNodeRules.new(rules)
      }
    end
  end
end

