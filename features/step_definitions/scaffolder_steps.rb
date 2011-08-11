When /^creating a scaffold with the files "([^"]*)" and "([^"]*)"$/ do |x, y|
  scf_file = File.join(TMP,x)
  seq_file = File.join(TMP,y)
  @scaffold = Scaffolder.new( YAML.load(File.read(scf_file)), seq_file)
end

Then /^the scaffold should contain (.*) sequence entries$/ do |n|
  @scaffold.select{|s| s.entry_type == :sequence}.length.should == n.to_i
end

Then /^the scaffold should contain (.*) insert entries$/ do |n|
  @scaffold.select{|s| s.entry_type == :sequence}.inject(0) do |count,seq|
    count =+ seq.inserts.length
  end.should == n.to_i
end

And /^the scaffold sequence should be (.*)$/ do |sequence|
  generated_sequence = @scaffold.inject(String.new) do |build,entry|
    build << entry.sequence
  end
  generated_sequence.should == sequence
end
