use strict;

my @DECLS = qw(1st 2nd 3rd attic);
my @GEND = qw(feminine masculine masculine|feminine neuter);
my @NUM = qw(singular dual plural);
my @CASE = qw(nominative genitive dative accusative vocative);
my @TYPE = qw(primary|regular regular irregular);

print_noun_sheet();

sub print_noun_sheet {
    print join ",", qw(decl num gend case type infl-ending stem-class dialects footnote);
    print "\n";
    foreach my $decl (@DECLS) {
	foreach my $num (@NUM) {
	    foreach my $gend (@GEND) {
		foreach my $case (@CASE) {
		    foreach my $type (@TYPE) {
			print join ",", ($decl, $num, $gend, $case, $type, "","");
			print "\n";
		    }
		}
	    }
	}
    }
}
