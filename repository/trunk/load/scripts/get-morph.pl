#!/usr/local/bin/perl
use strict;
use Data::Dumper;
use LWP::Simple;
use URI::Escape;

my %forms;
my $e_morph = $ARGV[0];
my $e_infile = $ARGV[1];
my $e_outfile = $ARGV[2];
my $e_lang = $ARGV[3];
unless ($e_morph && $e_infile && $e_outfile && $e_lang)
{
	die "Usage: $0 <morph service> <input file> <output file> <language>\n"
}

open FILE, "<$e_infile" or die "$!\n";
while (<FILE>)
{
    chomp;
    my ($data) = /<words>(.*)<\/words>/;
    my @lines = split /\s+/, $data;
    foreach my $line (@lines)
    { 
        my ($urn,$form,$clean) = split /,/, $line;
        $clean ||= $form;
        $form =~ s/<//;
        $form =~ s/>//;
        $clean =~ s/<//;
        $clean =~ s/>//;
        unless (exists $forms{$form})
        {
        	$forms{$form} = { 'urns' => [],
		          'clean' => $clean,
		          'morph' => undef};
        }
        push @{$forms{$form}{urns}},$urn;
    }        
}
close FILE;

my %seen;
my $missed;
foreach my $form (keys %forms)
{
	my $url = $e_morph;
        $url =~ s/<WORD>/uri_escape($forms{$form}{clean})/e;
    $seen{$forms{$form}{clean}}++;        
	my $morph = get($url);
	
	# skip the unknown results
	
    $morph =~ s/<unknown\s*.*?>.*?<\/unknown>//mg;
	if ($morph && $morph !~ /^\s*$/)
	{
	    $forms{$form}{morph} = $morph;	 
	}
	else 
	{
	   unless ($seen{$forms{$form}{clean}} > 1) 
	   {
	       warn("Unknown or no output for $forms{$form}{clean}\nUrl:$url\nOutput:$morph\n");
	       $missed++;	       
	   }
	}
}

open FILE, ">$e_outfile" or die "$!\n";

print FILE <<'EOS';
<?xml version="1.0" encoding="UTF-8"?>
<forms 
    xmlns="http://alpheios.net/namespaces/forms"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:treebank="http://nlp.perseus.tufts.edu/syntax/treebank/1.5" 
    version="1.0">
EOS

foreach my $form (keys %forms)
{
    print FILE qq!<inflection form="$form">\n!;
    foreach my $urn (@{$forms{$form}{urns}})
    {
	    print FILE "<urn>$urn</urn>\n";
    }
    print FILE $forms{$form}{morph};
    print FILE "</inflection>\n";
}
print FILE "</forms>\n";
close FILE;
warn("Total forms: " + (scalar keys %seen) + "\n");
warn("Missed forms: " + $missed + "\n");