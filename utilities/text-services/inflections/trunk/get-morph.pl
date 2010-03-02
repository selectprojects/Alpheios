#!/usr/local/bin/perl
use strict;
use Data::Dumper;
use LWP::Simple;
use URI::Escape;

my %forms;
my $MORPH_SVC = "http://localhost:8200/greek?word=";
open FILE, "<$ARGV[0]" or die "$!\n";
while (<FILE>)
{
    chomp;
    my ($urn,$form,$beta) = split /,/;
    $form =~ s/<//;
    $form =~ s/>//;
    $beta =~ s/<//;
    $beta =~ s/>//;
    unless (exists $forms{$form})
    {
	$forms{$form} = { 'urns' => [],
		          'beta' => $beta,
		          'morph' => undef};
    }
    push @{$forms{$form}{urns}},$urn;
}
close FILE;

foreach my $form (keys %forms)
{
	my $morph = get($MORPH_SVC . uri_escape($forms{$form}{beta}));

	if ($morph && $morph !~ /<unknown/)
	{
	    $forms{$form}{morph} = $morph;
	}
	else 
	{
	    warn("Unknown or no output for $form\n");
	}
}

print <<'EOS';
<?xml version="1.0" encoding="UTF-8"?>
<forms 
    xmlns="http://alpheios.net/namespaces/forms"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:treebank="http://nlp.perseus.tufts.edu/syntax/treebank/1.5" 
    version="1.0"  
    xml:lang="grc">
EOS

foreach my $form (keys %forms)
{
    print qq!<inflection form="$form">\n!;
    foreach my $urn (@{$forms{$form}{urns}})
    {
	    print "<urn>$urn</urn>\n";
    }
    print $forms{$form}{morph};
    print "</inflection>\n";
}
print "</forms>\n"
