Given /^the scaffold file has the sequences:$/ do |sequences|
  @scf_file = write_scaffold_file(sequences.hashes.map do |seq|
    {'sequence' => {'source' => seq['name']}}
  end)
  @seq_file = write_sequence_file(sequences.hashes.map do |seq|
    {:name => seq['name'], :sequence => seq['nucleotides']}
  end)
end

When /^creating a scaffolder object$/ do
  @scaffold = Scaffolder.new(YAML.load(File.read(@scf_file)),@seq_file)
end

Then /^the scaffold should contain (.*) sequence entries$/ do |n|
  @scaffold.select{|s| s.entry_type == :sequence}.length.should == n.to_i
end

And /^the scaffold sequence should be (.*)$/ do |sequence|
  generated_sequence = @scaffold.inject(String.new) do |build,entry|
    build << entry.sequence
  end
  generated_sequence.should == sequence
end
