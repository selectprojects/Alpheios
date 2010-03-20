#!/usr/bin/perl
use strict;

my $e_input = $ARGV[0];
my $e_output = $ARGV[1];
my $e_lang = $ARGV[2];

open IN, "<$e_input" or die "$!\n";
open OUT, ">$e_output" or die "$!\n";
my $l = 0;
while (<IN>)
{
    
    if (/<text(.*?)>/)
    {
        my $atts = $1;
        unless ($atts =~ /(xml:)?lang=/)
        {
            $_ =~ s/<text(.*?)>/<text xml:lang="$e_lang" \1>/g
        } 
    }
    elsif (/<div/)
    {
        $l = 0;
    }
	elsif (/<l n="(\d+)"/)
	{	
		$l = $1;		
	}
	elsif (/<l>/)
	{
		++$l;
		s/<l>/<l n="$l">/;				
	}
	print OUT $_;
}
