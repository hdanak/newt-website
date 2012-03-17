package Website;

use warnings;
use strict;

do 'Template.pl';

my $outdir = './out';
foreach my $page (@Template::pages) {
	my $fname = Template::path_to_filename($page);
	print "Creating $page at $outdir/$fname... ";
	open(my $outfile, '>', "$outdir/$fname");
	print $outfile Template->render($page);
	close($outfile);
	print "[done]\n";
};

my @aux_pages = qw( style.css newt-logo.png );

foreach (@aux_pages) {
	system("cp $_ $outdir/$_");
}
