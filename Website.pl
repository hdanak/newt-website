package Website;

use warnings;
use strict;

do 'Template.pl';

my $outdir = '/home/public/out';
foreach my $page (@Template::pages) {
	my $fname = Template::path_to_filename($page);
	print "Creating $page at $outdir/$fname... ";
	open(my $outfile, '>', "$outdir/$fname");
	print $outfile Template->render($page);
	close($outfile);
	print "[done]\n";
};
