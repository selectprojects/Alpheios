#!/usr/bin/perl
use strict;
use Data::Dumper;

my $indir = $ARGV[0];
my $outdir = $ARGV[1];
my $cmd = "C:\\Program Files\\Word-to-LaTeX\\word-to-latex.exe";
my $cfg = "C:\\Program Files\\Word-to-LaTeX\\XMLConfig.xml";

if (! -d $outdir)
{
	mkdir $outdir or die $!;
}

opendir(DIR,"$indir") or die $!;
my @vols = grep { -d && /Vol/i }
	   map {  $indir . "\\" . $_ } 
           readdir(DIR);
closedir(DIR);

foreach my $voldir (@vols)
{
	my ($vol) = $voldir =~ /Vol\. (\d+)/;
	opendir(DIR,$voldir) or die $!;
	my @files = grep /\.doc/, readdir(DIR);
	closedir(DIR);
	foreach my $file (@files)
	{
		my ($page) = $file =~/^(.*?)\.doc$/;
		my $inputfile = $voldir . "\\" . $file;
		my $outputfile = $outdir . "\\" . $vol . "_" . $page .".xml";
		my @args = (qq!-i "$inputfile"!, qq!-o "$outputfile"!, qq!-opt "$cfg"!);
		system ($cmd,@args) == 0 or die "FAILED: $? \n";
	}
	if ($vol > 1)
	{
		last;
	}

}

