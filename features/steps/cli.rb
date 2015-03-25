When(/^I run the bash command:$/) do |cmd|
  run_simple("bash -c '#{cmd}'", false)
end
