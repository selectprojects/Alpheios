use strict;
use Data::Dumper;

my $pofs = $ARGV[0];
my $data_file = $ARGV[1];
my $footnotes_file = $ARGV[2];
my $stem_file = $ARGV[3];

die "Usage: $0 <pofs> <data_file> <footnote_file> <stem_file> \n" unless $pofs && $data_file;

my %ATTS = 
(	'noun' =>
	{	
		'decl'  => [1,[qw(1st 2nd 3rd)]],
		'num'   => [2,[qw(singular dual plural)]],
		'gend'  => [3,[qw(feminine masculine neuter)]],
		'case'  => [4,[qw(nominative genitive dative accusative vocative)]],
		'type'  => [5,[qw(primary regular irregular)]],
		'infl-ending' =>[6, undef,undef,1],
		'dialects' => [7,\&check_dialect,\&format_dialect,1],
		'stem-class' => [8,undef, \&format_stemclass,1],
		'footnote' => [9,undef,\&format_footnote,1]
	},
	'adj' =>
	{	
		'decl'  => [1,[qw(1st 2nd 3rd)]],
		'num'   => [2,[qw(singular dual plural)]],
		'gend'  => [3,[qw(feminine masculine neuter common)]],
		'case'  => [4,[qw(nominative genitive dative accusative vocative)]],
		'type'  => [5,[qw(primary regular)]],
		'infl-ending' =>[6, undef,undef,1],
		'stem-class' => [7,undef, \&format_stemclass,1],
		'dialects' => [8,\&check_dialect,\&format_dialect,1],
		'footnote' => [9,undef,\&format_footnote,1]
	},
	'article' =>
	{	
		'num'   => [2,[qw(singular dual plural)]],
		'gend'  => [3,[qw(feminine masculine neuter common)]],
		'case'  => [4,[qw(nominative genitive dative accusative vocative)]],
		'type'  => [5,[qw(primary regular irregular)]],
		'infl-ending' =>[6, undef,undef,1],
		'dialects' => [7,\&check_dialect,\&format_dialect,1],
		'stem-class' => [8,undef, \&format_stemclass,1],
		'footnote' => [9,undef,\&format_footnote,1]
	},
	'pronoun' =>
	{	
		'num'   => [2,[qw(singular dual plural)]],
		'pers'  => [3,[qw(1st 2nd 3rd)]],
		'case'  => [4,[qw(nominative genitive dative accusative)]],
		'type'  => [5,[qw(primary regular irregular)]],
		'infl-ending' =>[6, undef,undef,1],
		'dialects' => [7,\&check_dialect,\&format_dialect,1],
		'stem-class' => [8,undef, \&format_stemclass,1],
		'footnote' => [9,undef,\&format_footnote,1]
	},
	'cardinal' =>
	{	
		'num'   => [2,[qw(singular dual plural)]],
		'gend'  => [3,[qw(feminine masculine neuter common)]],
		'case'  => [4,[qw(nominative genitive dative accusative)]],
		'type'  => [5,[qw(primary regular irregular)]],
		'infl-ending' =>[6, undef,undef,1],
		'dialects' => [7,\&check_dialect,\&format_dialect,1],
		'stem-class' => [8,undef, \&format_stemclass,1],
		'footnote' => [9,undef,\&format_footnote,1]
	}
);


my %atts = %{$ATTS{$pofs}};

my @group_by = qw( decl num gend pers case );
my @ending_atts = qw( type dialects footnote stem-class);

my $num_cols = scalar keys %atts;
my @atts =
           map { $_->[0] }
	   sort { $a->[1] <=> $b->[1] }
	   map { [ $_, @{$atts{$_}}->[0] ] }
           keys %atts;
my $i;
my @errors;
my %endings;
my %stems;
my %stems_by_value;

open DATA, "<$data_file" or die "$!\n";
if ($stem_file)
{
    open STEM, "<$stem_file" or die "$!\n";
    while (<STEM>) {
	    chomp;
	    my ($id,$text) = map { s/^\"\s*//; s/\s*\"$//; $_ } split /\,/,$_,2;
	    warn("Stem $id = $text\n");
	    next unless $id =~ /^stem-\d+$/;
	    $stems{$id} = $text;
	    $stems_by_value{$text} = $id;
    }
    close STEM;
}
my $XMLSTART = <<"EOS";
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/css" href="file:/C:/work/schemas/inflections.css"?>
<infl-data xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:noNamespaceSchemaLocation="file:/C:/work/schemas/infl-endings-ungrouped.xsd"
    xml:lang="greek">
EOS

my %XML_TABLES = ();
$XML_TABLES{'noun'} = <<"EOS";
  <stem-table>
    <stem decl="1st">α</stem>
    <stem decl="2nd">ο</stem>
    <stem decl="3rd">Consonants, Dipthongs, ι, ω
@{[join "\n", map {qq!    <stem-class id="$_">$stems{$_}</stem-class>! } keys %stems]}
    </stem>
  </stem-table>
  <order-table>
    <order-item attname="decl" order="1">1st</order-item>
    <order-item attname="decl" order="2">2nd</order-item>
    <order-item attname="decl" order="3">3rd</order-item>
    <order-item attname="case" order="1">nominative</order-item>
    <order-item attname="case" order="2">genitive</order-item>
    <order-item attname="case" order="3">dative</order-item>
    <order-item attname="case" order="4">accusative</order-item>
    <order-item attname="case" order="5">vocative</order-item>
    <order-item attname="gend" order="1">feminine</order-item>
    <order-item attname="gend" order="2">masculine</order-item>
    <order-item attname="gend" order="3">masculine feminine</order-item>
    <order-item attname="gend" order="5">neuter</order-item>
    <order-item attname="type" order="1">regular</order-item>
    <order-item attname="type" order="2">irregular</order-item>
    <order-item attname="num" order="1">singular</order-item>
    <order-item attname="num" order="2">dual</order-item>
    <order-item attname="num" order="3">plural</order-item>
  </order-table>
  <infl-endings>
EOS
$XML_TABLES{'adj'} = <<"EOS";
  <stem-table>
    <stem decl="1st">α</stem>
    <stem decl="2nd">ε, o, ω</stem>
    <stem decl="3rd">Consonants (ν, ντ, υ)</stem>
@{[join "\n", map {qq!    <stem-class id="stem-$_">$stems{$_}</stem-class>! } keys %stems]}
  </stem-table>
  <order-table>
    <order-item attname="decl" order="1">1st</order-item>
    <order-item attname="decl" order="2" footnote="foot-6">2nd</order-item>
    <order-item attname="decl" order="3" footnote="foot-13">3rd</order-item>
    <order-item attname="case" order="1">nominative</order-item>
    <order-item attname="case" order="2">genitive</order-item>
    <order-item attname="case" order="3">dative</order-item>
    <order-item attname="case" order="4">accusative</order-item>
    <order-item attname="case" order="5">vocative</order-item>
    <order-item attname="gend" order="1">feminine</order-item>
    <order-item attname="gend" order="2">masculine</order-item>
    <order-item attname="gend" order="3">masculine feminine</order-item>
    <order-item attname="gend" order="4">common</order-item>
    <order-item attname="gend" order="5">neuter</order-item>
    <order-item attname="type" order="2">regular</order-item>
    <order-item attname="type" order="3">irregular</order-item>
    <order-item attname="num" order="1">singular</order-item>
    <order-item attname="num" order="2">dual</order-item>
    <order-item attname="num" order="3">plural</order-item>
  </order-table>
  <infl-endings>
EOS
$XML_TABLES{'article'} = <<"EOS";
  <order-table>
    <order-item attname="case" order="1">nominative</order-item>
    <order-item attname="case" order="2">genitive</order-item>
    <order-item attname="case" order="3">dative</order-item>
    <order-item attname="case" order="4">accusative</order-item>
    <order-item attname="case" order="5">vocative</order-item>
    <order-item attname="gend" order="1">feminine</order-item>
    <order-item attname="gend" order="2">masculine</order-item>
    <order-item attname="gend" order="3">neuter</order-item>
    <order-item attname="type" order="2">regular</order-item>
    <order-item attname="type" order="3">irregular</order-item>
    <order-item attname="num" order="1">singular</order-item>
    <order-item attname="num" order="2">dual</order-item>
    <order-item attname="num" order="3">plural</order-item>
  </order-table>
  <infl-endings>
EOS
$XML_TABLES{'pronoun'} = <<"EOS";
  <order-table>
    <order-item attname="case" order="1">nominative</order-item>
    <order-item attname="case" order="2">genitive</order-item>
    <order-item attname="case" order="3">dative</order-item>
    <order-item attname="case" order="4">accusative</order-item>
    <order-item attname="case" order="5">vocative</order-item>
    <order-item attname="pers" order="1">1st</order-item>
    <order-item attname="pers" order="2">2nd</order-item>
    <order-item attname="pers" order="3">3rd</order-item>
    <order-item attname="type" order="2">regular</order-item>
    <order-item attname="type" order="3">irregular</order-item>
    <order-item attname="num" order="1">singular</order-item>
    <order-item attname="num" order="2">dual</order-item>
    <order-item attname="num" order="3">plural</order-item>
  </order-table>
  <infl-endings>
EOS
$XML_TABLES{'cardinal'} = <<"EOS";
  <order-table>
    <order-item attname="case" order="1">nominative</order-item>
    <order-item attname="case" order="2">genitive</order-item>
    <order-item attname="case" order="3">dative</order-item>
    <order-item attname="case" order="4">accusative</order-item>
    <order-item attname="case" order="5">vocative</order-item>
    <order-item attname="gend" order="1">feminine</order-item>
    <order-item attname="gend" order="2">masculine</order-item>
    <order-item attname="gend" order="3">masculine feminine</order-item>
    <order-item attname="gend" order="4">three genders</order-item>
    <order-item attname="gend" order="5">neuter</order-item>
    <order-item attname="type" order="2">regular</order-item>
    <order-item attname="type" order="3">irregular</order-item>
    <order-item attname="num" order="1">singular</order-item>
    <order-item attname="num" order="2">dual</order-item>
    <order-item attname="num" order="3">plural</order-item>
  </order-table>
  <infl-endings>
EOS
print_start_xml();
while (<DATA>){
    chomp;
    $i++;
    next if $_ =~/^\s*$/;
    my @cells = 
    	map {	s/^\"\s*//; 
		s/\s*\"$//; 
		s/\"\"/"/g;
		$_; 
	}
	split /\,/;
    my %row;
    for (my $j = 0; $j < $num_cols; $j++) {
	    my $col_head = $atts[$j];
	    my $value = $cells[$j];
	    if ($i == 1) {
		    if ($value ne $col_head) {
			    die "Unexpected column header: $value expected $col_head ($j)\n";
		    }
	    } else {
	        if (! $value || $value =~ /^\s+$/) 
		{ 
	                if (! $atts{$col_head}->[3])
			{
				push @errors, "Missing $col_head at $i: $value\n"
			}
			next;
		}
	        if (scalar @{$atts{$col_head}} > 2 &&
	            ref $atts{$col_head}->[2] eq 'CODE') {
		        $value = $atts{$col_head}->[2]($value);
	        }
		if (defined $atts{$col_head}->[1]) {
			if (ref $atts{$col_head}->[1] eq 'ARRAY') {
				my $error;
				foreach my $att_v (split /\||\s/, $value) {
                		    ++$error unless
				    	grep { $_ eq $att_v } 
				    	@{$atts{$col_head}->[1]};
				}
				push @errors, "Bad $col_head at $i: $value\n" if $error;
				$value =~ s/\|/ /g;
			}
			else {
				push @errors, "Bad $col_head at $i: $value\n"
				if $atts{$col_head}->[1]($value);
			}
		}
	    	$row{$col_head} = $value;

	    }
    }
    next unless keys %row;
    my $key = join '-', map { $row{$_} } @group_by;
    my %ending = map { $_ => $row{$_} } (@ending_atts,'infl-ending');
    push @{$endings{$key}}, \%ending;  
}
close DATA;
my %footnotes;
if ($footnotes_file)
{
    open FOOT, "<$footnotes_file" or die "$!\n";
    while (<FOOT>){
	chomp;
	my ($id,$text) = map { s/^\"\s*//; s/\s*\"$//; $_ } split /\,/,$_,2;
        $ text =~ s/\"\"/"/g;
	next unless $id =~ /^(foot-)?\d+$/;
	$footnotes{$id} = $text;
    }
    close FOOT;
}
print_data(\%endings);
print_end_xml();
if (@errors) {
    warn join "\n", @errors;
}



sub print_data() {
    my $endings = shift;
    foreach my $set (sort keys %{$endings}) {
	    my @set_atts = split /-/, $set;

	    if ($pofs eq 'adj' && $set =~ /Irreg-/)
	    {
		    # skip the Irregular declension for adjectives
		    # for now
		    next;
	    }
	    my %set_atts;
	    for (my $i=0; $i<@group_by; $i++) {
		$set_atts{$group_by[$i]} = @set_atts[$i];
 	    }

	    print <<"EOS";
    <infl-ending-set
      @{[join ' ', map { $set_atts{$_} ? qq!$_="$set_atts{$_}"! : ''  } keys %set_atts ]}>
EOS
	    foreach my $ending (@{$endings{$set}}) {
		# skip unless there's an ending
	        next unless $ending->{'infl-ending'};
	    	my %atts;
	    	for (my $i=0; $i<@ending_atts; $i++) {
			$atts{$ending_atts[$i]} = $ending->{$ending_atts[$i]};
 	    	}
		    print <<"EOS";
        <infl-ending
            @{[join ' ', map { $atts{$_} ? qq!$_="$atts{$_}"! : ''  } keys %atts ]}>$ending->{'infl-ending'}</infl-ending>
EOS
	    }
            print "    </infl-ending-set>\n";
    }
}
sub print_start_xml() {
	print $XMLSTART;
	print $XML_TABLES{$pofs};
}

sub print_end_xml() {
	print <<"EOS";
  </infl-endings>
EOS
print_footnotes();
print <<"EOS";
</infl-data>
EOS
}

sub print_footnotes() {
	return unless keys %footnotes;
	print "<footnotes>\n";
	foreach my $note (sort { $a <=> $b } keys %footnotes) {
		my $text = $footnotes{$note};
		# TODO - need to do complete XML escaping
		$text =~ s/\&/&amp;/g;

		# add the xrefs 
		# TODO final link syntax
		# TODO accomodate multiple link targets
	        $text =~ s#(Smyth\s*\#?(\d+))#<reflink xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="grammar:smyth:s\2">\1</reflink>#g;
		print qq!    <footnote id="$note">$text</footnote>\n!;

	}
	print "</footnotes>\n";
}

sub check_dialect() {
	my $str = shift;
	my @allowed = 
		qw(Homer Plato Attic Aeolic Doric Cretan Ionic Herodotus Poetry);
	push @allowed, ('Ionic Poetry', 'Old Attic', 'Comic Poets', 'New Ionic');
	my @dialects = split /,/, $str;
	my $no_match;
	foreach my $dialect (@dialects) {
	    $no_match++ unless grep { $dialect eq $_ } @allowed;
	}
	return $no_match;
}

sub format_dialect() {
	my $str = shift;
	$str =~ s/^\s+//;
	$str =~ s/\s+$//;
	my @dialects = map { s/^\s*//; s/\s*$//ms; s/\-/ /ms; $_ } split /\|\s+|\||\s+/, $str;
	return join ',', @dialects;
}

sub format_footnote() {
	my $str = shift;
	my @notes = map { s/^\s*//; s/\s*$//; $_ } split /\|\s+|\||\s+/, $str;
	return join ' ', map { "$_" }@notes;
}

sub format_stemclass() {
	my $str = shift;
	return if $pofs == 'adj'; # the adj stem classes are just wrong
	return if $str =~ /^\s*$/ms;
	my @notes = map { s/^\s*//; s/\s*$//; $_ } split /\|/, $str;
	@notes = grep { defined  && $_ !~ /^\s*$/ } @notes;
	if (@notes)
	{
		return join ' ', 
			map { if ($_ =~ /^\d+$/)
			       { "stem-" . $_ }
			       elsif ($stems_by_value{$_})
			       { "stem-" . $stems_by_value{$_} } 
			       else  
			       {
				  "ERROR";
			       }
		            } @notes;
	}
	else 
	{ 
		return '';
	}
}

sub add_stem_class() {
	my ($row,$str) = @_;
	my @notes = map { s/^\s*//; s/\s*$//; $_ } split / /, $str;
	my %foot_to_stem = (
       		8 => 'stem-1', # labial/palatal
		9 => 'stem-2', # dental
		10 => 'stem-3', # liquid
		11 => 'stem-4', # sigma
		12 => 'stem-5', # dipthongs
		13 => 'stem-6', # i and u
		14 => 'stem-3', 
		16 => 'stem-4', 
		17 => 'stem-6',
		18 => 'stem-5',
		19 => 'stem-5',
		20 => 'stem-4',
		21 => 'stem-2',
		28 => 'stem-5',
		29 => 'stem-5',
		32 => 'stem-5',
       		35 => 'stem-6',
		39 => 'stem-5',
		40 => 'stem-5',	);
	my @stems;
	foreach my $note (@notes) {
		my ($num) = $note =~ /^foot-(\d+)$/;
		if (exists $foot_to_stem{$num}) {
			push @stems, $foot_to_stem{$num};
		}
	}
	if (@stems) {
		$row->{'stem-class'} = join ' ', @stems;
	}
}

