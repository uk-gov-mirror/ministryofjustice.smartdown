require 'parslet/transform'
require 'smartdown/model/node'
require 'smartdown/model/front_matter'
require 'smartdown/model/rule'
require 'smartdown/model/nested_rule'
require 'smartdown/model/question/multiple_choice'
require 'smartdown/model/element/start_button'
require 'smartdown/model/predicate/equality'
require 'smartdown/model/predicate/set_membership'
require 'smartdown/model/predicate/named'

module Smartdown
  module Parser
    class NodeTransform < Parslet::Transform
      rule(body: subtree(:body)) {
        Smartdown::Model::Node.new(
          node_name, body, Smartdown::Model::FrontMatter.new({})
        )
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

      rule(:multiple_choice => subtree(:choices)) {
        Smartdown::Model::Question::MultipleChoice.new(
          node_name, Hash[choices]
        )
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

      rule(:rule => {predicate: subtree(:predicate), outcome: simple(:outcome_name) } ) {
        Smartdown::Model::Rule.new(predicate, outcome_name)
      }
      rule(:nested_rule => {predicate: subtree(:predicate), child_rules: subtree(:child_rules) } ) {
        Smartdown::Model::NestedRule.new(predicate, child_rules)
      }
    end
  end
end

