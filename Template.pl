package Template;
use Markapl;
use YAML;
use strict;
use warnings;
use Data::Dumper;


open(my $data_file, "< data.yaml");
my @data_lines = <$data_file>;
my $yaml_out = join('', @data_lines);
my $data = Load($yaml_out);
close($data_file);

sub template_common ($$&$;$) {
	my ($first_name, $second_name, $guts_sub, $pre_sub) = @_;
	sub {
	html {
		head {
			html_link (rel => "stylesheet", type => "text/css", href => "style.css");
			title {"The Newt Programming Language"};
		};
		body {
			center {
				navbar($first_name);
				div ('.clear');

				div ("#page-bubble") {
					div ("#newt-title") {
						a (href => "/") {
							img (src => "newt-logo.png", alt => " : Newt");
						};
					};
					div ('.clear');
					div ("#newt-body") {
						$pre_sub->() if defined($pre_sub);
						
						newt_block({id => 'newt-content'}, sub {
							subnavbar($second_name);
							div ('#content') { $guts_sub->() };
						});
					};
					newt_block({id => "newt-footer"}, "Footer");
				};
			};
		};
	};
	}
}

our $site_structure = [
	{ 'index' => [
			{'news'},
			{'intro'}
		     ]
	},
	{ 'learn' => [
			{'intro'},
			{'numbers'},
			{'functions'},
			{'strings'},
			{'classes & objects'},
			{'specs'},
			{'adaptors'},
		#	{''},
		     ]
	},
	{ 'documentation' => [
				{'core library'},
				{'user guide'},
				{'NWDoc'},
			     ]
	},
	{ 'development' => [
				{'source' => 'https://github.com/hdanak/Newt'},
				{'wiki'   => 'https://github.com/hdanak/Newt/wiki'},
			   ]
	},
	{ 'about' }
];

my %special_headers = (
'index' => sub {
		newt_block({id => 'newt-intro'}, sub {
			newt_block({id => 'newt-basics'}, sub { 
				h3 {"Some code..."};
				code_block($data->{"basics"});
			});
			$data->{"intro"};
		});
	}
);

sub flatten_pages {
	my ($tree, $header) = @_;
	my @a = ();
	foreach my $branch (@$tree) {
		my ($head, $tail) = %$branch;
		my @fp = ();
		if (defined $tail && (ref($tail) eq 'ARRAY')) {
			@fp = defined $header ? flatten_pages($tail,
							      "$header/$head")
					      : flatten_pages($tail, "$head");
		}
		my $heading = defined $header ? "$header/$head" : $head;
		push @a, ($heading, @fp);
	}
	return @a;
}
our @pages = flatten_pages($site_structure);
print Dumper \@pages;
foreach my $page (@pages) {
	my $page_ = $page;
	$page_ =~ tr/\//_/;
	my $final_page = $data->{$page_.'_content'} =~ /^#(\S+)$/ ? $1
								  : $page;
	my $final_content = $final_page;
	$final_content =~ tr/\//_/;
	$final_content = $data->{$final_content.'_content'};
	my $section = $page;
	$section =~ s/^(\S+)\/.*$/\1/;
	template $page, template_common($section, $final_page,
					sub {$final_content},
					$special_headers{$page});
}

sub newt_block {
	my ($atts, $block) = @_;
	if (ref($block) eq 'CODE') {
		div (%$atts, (class => "newt-block")) {$block->()};
	} else {
		div (%$atts, (class => "newt-block")) {$block};
	}
}

sub code_block {
	my ($text) = @_;
	$text = trim_around($text);
	#$text =~ s/$/<br \/>/mg;
	$text = `echo -e "$text" | pygmentize -O style=default,linenos=0,noclasses,nobackground -f html -l perl`;
	#$text = "<code>$text</code>";
	return $text;
}
sub trim_around {
	my ($text) = @_;
	$text =~ s/^\s*\n//;
	$text =~ s/\n\s*$//;
	$text =~ s/^\s*/ /mg;
	return $text;
}
sub path_to_filename {
	my ($path) = @_;
	my $filename = $path;
	$filename =~ tr/\//_/;
	$filename .= '.html';
	return $filename;
}

sub tc {
	my ($str) = @_;
	$str =~ s/(\w+)/\u$1/g;
	return $str;
}

sub navbar {
	my ($page) = @_;
	div ('#navbar') {
		ul {
			foreach my $section (@$site_structure) {
				my ($name) = keys %$section;
				next if $name eq 'index';
				my $url = $name.'.html';
				$name = tc $name;
				li {
					a (href=>$url) {
						lc($name) eq lc($page) ? "<b>$name</b>" : $name
					}
				};
			}
			div ('.clear');
		}
	}
}
sub subnavbar {
	my ($page) = @_;
	my ($main_page, $sub_page) = split /\//, $page;

	my ($name, $branches);
	foreach my $section (@$site_structure) {
		($name) = keys %$section;
		next if $name ne $main_page;
		$branches = $section->{$name};
		return '' unless ref($branches) eq 'ARRAY';
	}
	newt_block ({id => 'subnavbar'}, sub {
		ul {
			foreach my $page (@$branches) {
				my ($name) = keys %$page;
				my $url = (defined $page->{$name}) ? $page->{$name} : $main_page.'_'.$name.'.html';
				$name = tc $name;
				li {
					a (href=>$url) {
						lc($name) eq lc($sub_page) ? "<b>$name</b>" : $name
					}
				};
			}
			div ('.clear');
		}
	});
}

#bak:
#sub horiz_sidebar {
#	my ($sidebar_ref, $highlight) = @_;
#	foreach my $subtitle (keys %$sidebar_ref) {
#		div ('.sidebar-block') {
#			h3 ('.float') { $subtitle };
#			br;
#			div ('.clear');
#			div ('.float') {'\_'};
#			my $spaces = '';
#			foreach my $list_item (@{$sidebar_ref->{$subtitle}}) {
#				my ($name, $url) = @$list_item;
#				div ('#floatmenu') {
#					outs $spaces;
#					a (href=>$url) {
#						$name eq $highlight ? "<b>$name</b>" : $name
#					}
#				};
#				$spaces = ' - ' if $spaces eq '';
#			}
#		};
#	}
#}
