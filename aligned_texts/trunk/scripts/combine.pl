use strict;
use Data::Dumper;

my ($next, %sentences, $last, $total_words, %unique_words);
my @missing;
my %missing;
open FILE1, "<$ARGV[0]" or die "$!\n";
my $order = 0;
while (<FILE1>) {
	chomp;
	next if /^\s*$/;
	if (/^# Sentence pair (Perseus-text.*?) \(1-1 alignment="(.*?)"\)/) {
		$last = $1;
		# get rid of . : - and = in the id 
		$last =~ s/\./_/g;
		$last =~ s/=/_/g;
		$last =~ s/-/_/g;
		$last =~ s/:/_/g;
		my $one_to_one = $2;
		$next = 'ref';
		$sentences{$last} = { one_to_one => $one_to_one,
	                              order      => $order++	
			            };
	} elsif ($next eq 'ref') {
		my $text = process_ref($_);
		$sentences{$last}{'en'}{text_ref} = $text;
		$next = 'src';
	} elsif ($next eq 'src') {
		my $text = process_src($_);
		$sentences{$last}{'greek'}{text_src} = $text;
		$next = undef;
	} else {
		warn "Unexpected sentence: $_\n";
	}
}
close FILE1;
open FILE2, "<$ARGV[1]" or die "$!\n";
while (<FILE2>) {
	chomp;
	next if /^\s*$/;
	if (/^# Sentence pair (Perseus-text.*?) \(1-1 alignment="(.*?)"\)/) {
		$last = $1;
		$last =~ s/\./_/g;
		$last =~ s/=/_/g;
		$last =~ s/-/_/g;
		$last =~ s/:/_/g;
		my $one_to_one = $2;
		$next = 'ref';
		unless (exists $sentences{$last}) {
			warn ("Sentence $last not in file 1\n");
		}
	} elsif ($next eq 'ref') {
		my $text = process_ref($_);
		$sentences{$last}{'greek'}{text_ref} = $text;
		$next = 'src';
	} elsif ($next eq 'src') {
		my $text = process_src($_);
		$sentences{$last}{'en'}{text_src} = $text;
		$next = undef;
	} else {
		warn "Unexpected sentence: $_\n";
	}
}
close FILE2;

sub process_ref {
	my $input = shift;
	pos $input = 0;
	my @text;
	while (pos $input < length $input) {
		my $ref_id;
		if ($input =~ m{ \G([^\s]+)(\[(\d+)\]) }gcxms) {
			$ref_id = "$last:$3";
			push @text, [$1,$ref_id];
		} elsif ($input =~ m{ \G(\s+) }gxcms) {
			push @text, $1;
		} else {
			$input =~ m/ \G ([^\n]*) /gcxms;
			my $context = $1;
			warn "Error near $context";
		}
	}
	return \@text;
}

sub process_src {
	my $input = shift;
	pos $input = 0;
	my @text;
	my $src_ref;
	while (pos $input < length $input) {
		if ($input =~ m# \G([^\s]+)\s(\(\{(.*?)\}\)) #gcxms) {
			my $src_ref = $3;
			my $word = $1;
			# get rid of leading and trailing spaces
			$src_ref =~ s/^\s+//;
			$src_ref =~ s/\s+$//;
			$src_ref = join " ",
				map { "$last:$_" }
				split /\s/, $src_ref if $src_ref;
			push @text, [$word,$src_ref];
			if (! $src_ref) {
				push @missing, $word;
				$missing{$word} = 1;
			}
			$total_words++;
			$unique_words{$word} = 1;
		} elsif ($input =~ m{ \G(\s+) }gxcms) {
			push @text, $1;
		} else {
			$input =~ m/ \G ([^\n]*) /gcxms;
			my $context = $1;
			warn "Error near $context";
		}
	}
	return \@text;
}


print "<alignment>\n";
foreach my $lang qw(greek en) {
    foreach my $num ( 
	    sort { $sentences{$a}{order} <=> $sentences{$b}{order} }
	    keys %sentences ) {
	my $markup = '';
	print qq!<p lang="$lang" id="$num" class="alph-proto-sentence">\n!;
	my $src = $sentences{$num}{$lang}{'text_src'};
	my $ref = $sentences{$num}{$lang}{'text_ref'};
	for (my $i=0; $i<scalar @$src; $i++) {
	    my $item = $src->[$i];
	    if (ref $item eq 'ARRAY') {
		    my $word = $item->[0];
		    my $ref_id = $item->[1];
		    my $src_id = $ref->[$i][1];
		    if ($ref->[$i][0] ne $word) {
			warn ("mismatch between src and ref text for $word ($ref->[$i][0])");
		    }
		    $markup = $markup . qq!<span class="alph-proto-word" id="$src_id" ref="$ref_id">$word</span>!
	    } else {
		    $markup = $markup . $item;
	    }
	}
        print qq!$markup\n</p>\n!;
    }
    
}
print qq!</alignment>\n!;

=pod 

print <<"EOS";
  <summary>
    <unique_words>@{[scalar keys %unique_words]}</unique_words>
    <total_words>@{[$total_words]}</total_words>
    <missing unique="@{[scalar(keys %missing)]}" total="@{[scalar @missing]}" perc="@{[sprintf '%.2F', (scalar keys %missing)/scalar(keys %unique_words)]}%">
EOS
foreach my $word (sort keys %missing) {
	print qq!      <word lang="$langs{'src'}">$word</word>\n!;
}


print <<"EOS";
    </missing>
  </summary>
</alignment>
EOS

=cut

