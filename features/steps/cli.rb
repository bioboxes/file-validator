When(/^I run the bash command:$/) do |cmd|
  run_simple("bash -c '#{cmd}'", false)
end

When(/^I copy a gzipped fastq file named (.*)/) do |file|
  gzipped_file = File.expand_path('../../features/data/' + file, File.dirname(__FILE__))
  FileUtils.cp(gzipped_file, "tmp/aruba")
end