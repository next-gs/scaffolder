require 'delegate'
require 'bio'

# == Quick start
#
# Given a fasta file containing two sequences.
#
#   >seqA
#   GCGCGC
#   >seqB
#   ATATAT
#
# A simple genome scaffold containing the two sequences is specified as a YAML
# formatted text file shown below. Each dash (-) indicates a region in the
# scaffold. In the example below the keyword *sequence* inserts a sequence from
# the fasta file, the keyword *source* identifies that seqA should be used.
#
#   ---
#     - sequence:
#         source: 'seqA'
#     - sequence:
#         source: 'seqB'
#
# The scaffolder API can then be used as follows to generate a complete
# sequence.
#
#   scaffold = Scaffolder.new('scaffold.yml','sequences.fasta')
#   sequence = scaffold.inject(String.new) do |build,entry|
#     build << entry.sequence
#   end
#   puts sequence # Prints GCGCGCATATAT
#
# == The Scaffold File
#
# The above example is simplified to demonstrates basic usage. The sections
# below outline the types of regions that can be used in the scaffold file.
#
# === Sequence Regions
#
# Contigs sequences in the scaffold are specified using the *sequence* keyword.
# The *source* keyword should specifies the sequence to use from the fasta file
# and should match the first space delimited word in the fasta header.
#
# ==== Sub-Sequences
#
# When generating a scaffolder only a subset of a sequence may be required.
# Inserting sub-sequences into the scaffold is specified using the *start* and
# *stop* keywords. All of the sequence before the start coordinate is ignored
# and all of sequence after the stop coordinate is ignored, meaning only the
# sequence between the start and stop position inclusively is used in the
# scaffold.
#
#   ---
#     - sequence:
#         source: 'sequence1'
#         start: 42
#         stop: 1764
#
# ==== Reverse Complementation
#
# The *reverse* keyword specifies that the selected sequence is reversed
# complemented.
#
#   ---
#     - sequence:
#         source: 'sequence1'
#         reverse: true
#
# === Insert Regions
#
# Sequence contigs may contain gaps, for example where the sequence could not
# be correctly resolved during assembly. Additional sequencing may however
# produce sequences that can be used to fill these gaps. These inserts can be
# added to a sequence using the *insert* keyword and specifying a YAML array of
# the inserts. Multiple inserts can be specified, each separated by a dash (-)
# followed by a new line.
#
#   ---
#     - sequence:
#         source: 'sequence1'
#         inserts:
#           -
#             source: 'insert1'
#             open: 3
#             close: 10
#
# ==== Insert Position
#
# The location where an insert is added to a sequence is defined by either the
# *open*, *close* keywords, or both. This defines where the host sequence is
# 'opened' and 'closed' to add the insert. If only one parameter is used, for
# example using *open*, then the close position is determined from the length
# of the insert sequence and vice versa.
#
# ==== Insert Sub-Sequence
#
# An insert can be subsequenced in the same way as a sequence using the *start*
# and *stop* keywords. Similarly the insert sequence can be reverse completed
# using the *reverse* keyword.
#
#   ---
#     - sequence:
#         source: 'sequence1'
#         inserts:
#           -
#             source: 'insert1'
#             open: 3
#             close: 10
#             start: 8
#             stop: 16
#             reverse: true
#
#
# === Unresolved Regions
#
# There may be regions in between sequences in the genome which are unknown but
# which the approximate length is. These can be specified in the scaffold file
# using the *unresolved* keyword. Unresolved regions are filled with 'N'
# nucleotide characters equal to the value specified by the *length* keyword.
#
#   ---
#     - unresolved:
#         length: 10
#
# === Scaffold File Processing Order
#
# The scaffolder API processes the regions in YAML scaffold file as follows:
#
# * Each region in the scaffold in processed in the order specified in the
#   scaffolder file.
# * If the region is a sequence and inserts are specified, the inserts are
#   sorted by stop position, then processed from last to first.  Each insert is
#   processed as follows:
#
#   * The insert is subsequenced if specified.
#   * The insert is reverse complemented if specified.
#   * The insert is added to each host sequence replacing the region of
#     sequence specified by the open and close co-ordinates.
#   * The host sequence stop position is extended by the difference in length
#     that the insert sequence fills. For example if a 5 base pair insert fills
#     a 4 base region, the host sequence stop position is increased by the
#     difference: 1.
#   * The region is subsequenced if specified.
#   * The region is reverse complemented if specified.
#
# ==== WARNING
#
# Inserts with overlapping *open* and *close* regions in the same sequence will
# cause unexpected behaviour and should be avoided.
#
class Scaffolder < DelegateClass(Array)
  require 'scaffolder/errors'
  require 'scaffolder/region'

  # @param [Hash] assembly Produced from loading the scaffold file using YAML.load
  # @param [String] sequence Location of the fasta file corresponding to the
  #   scaffold sequences
  # @return [Array] Returns an array of scaffold regions
  # @example
  #   Scaffolder.new(YAML.load('scaffold.yml'),'sequences.fasta')
  def initialize(assembly,sequence)
    sequences = Hash[ *Bio::FlatFile::auto(sequence).collect { |s|
      [s.definition.split.first,s.seq]
    }.flatten]

    super(assembly.map do |entry|
      type, data = entry.keys.first, entry.values.first

      # Source is the only keyword. Used to fetch sequence from fasta file.
      data['raw_sequence'] = sequences[data['source']] if data['source']

      Scaffolder::Region[type].generate(data)
    end)
  end

end
