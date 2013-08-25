use strict;

my $toc;
my (%last, %next, %prev, %end);
my %html;

my %SFX = ( 'en' => '_en',
	    'greek' => '' );

my %head;
my $alph_home = "http://dev.alpheios.net:8008/site";
$head{'greek'} = <<"EOS";
<!DOCTYPE html SYSTEM "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>Alpheios: Homer, Odyssey</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<meta id="alpheios-pedagogical-text" content="true"/>
        <meta id="alpheios-level-selected" content="reader"/>
	<link rel="stylesheet" type="text/css" href="align_proto.css"/>
	<link rel="stylesheet" type="text/css" href="site_menus.css"/>
	<link rel="stylesheet" type="text/css" href="/css/alph_text.css"/>
	<link rel="stylesheet" type="text/css" href="/css/hopper.css"/>
        <link rel="stylesheet" type="text/css" href="site_menus/css/superfish.css"/>
        <script type="text/javascript" src="site_menus/js/jquery-1.2.6.min.js"></script>
        <script type="text/javascript" src="site_menus/js/hoverIntent.js"></script>
        <script type="text/javascript" src="site_menus/js/superfish.js"></script>
        <script type="text/javascript">

          // initialise plugins
          jQuery(function(){
              jQuery('ul.sf-menu').superfish();
          });

        </script>
</head>
<body>
<div class="alpheios-ignore">
  <div id="alph-page-header">
    <a class="alpheios-logo" href="$alph_home" alt="Alpheios">
    <img src="GreekRiver.jpg"/>Alpheios</a>
    <br/>
  </div>
  <div id="alph-toolbar" class="alpheios-toolbar">
    <div id="alph-toolbar-main">
        <ul class="sf-menu">
            <li class="current"><a href="#">Alpheios</a>
                <ul>
                    <li class="current alpheios-toolbar-options"><a href="#">Options</a></li>
                    <li class="current alpheios-toolbar-about"><a href="#">About</a></li>
                </ul>
            </li>
            <li class="current alpheios-toolbar-translation"><a href="#">Translation</a></li>
            <li class="current alpheios-toolbar-tree"><a href="#">Diagram</a></li>
            <li class="current"><a href="#">Skill Level</a>
                <ul>
                    <li class="current alpheios-toolbar-level"><a href="#">Learner</a></li>
                    <li class="current alpheios-toolbar-level"><a href="#">Reader</a></li>
                </ul>
            </li>
        </ul>
    
    </div>
    <div id="alph-toolbar-tools">
          <div class="alph-toolbar-label">Tools:</div>
        <ul class="sf-menu">
            <li class="current alpheios-toolbar-inflect"><a href="#">Inflection Tables</a></li>
            <li class="current alpheios-toolbar-grammar"><a href="#">Grammar</a></li>
            <li class="current alpheios-toolbar-wordlist"><a href="#">Word Lists</a></li>
            <li class="current alpheios-toolbar-help"><a href="#">Help</a></li>
        </ul>
    </div>
  </div>
  <br clear="all"/>
  <div id="header">
    <div id="alph-text-links"></div>
    <div id="header_text">
	<h1><span class="author">Homer,</span> <span class="title">Odyssey</span>
	   <a id="alph-citation-links" href="#citation" alt="Citation"><img src="cite.gif"/></a>
        </h1>
    </div>
  </div>
</div>
EOS

my %foot;
$foot{'greek'} = <<"EOS";
    <div id="alph-trans-url" url="<URL_en>" src_lang="greek"></div>
    <div class="alpheios-ignore">
    <div id="citation">
        <p>Homer. The Odyssey with an English Translation by A.T. Murray, PH.D. in two volumes. Cambridge, MA., Harvard University Press; London, William Heinemann, Ltd. 1919.</p>

        <p>The Annenberg CPB/Project provided support for entering this text.</p>
    </div> 
    
    <div class="rights_info">
	<p class="cc_rights"><!--Creative Commons License-->
		<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/us/">
		<img alt="Creative Commons License" style="border-width:0" src="http://creativecommons.org/images/public/somerights20.png" />

		</a>
		<br />This work is licensed under a 
		<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/us/">Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License</a>.
	<!--/Creative Commons License--></p>
    </div> 
    </div>
  </body>
</html>
EOS

my $in_summary;
my $lang;
while (<>) {
	chomp;
	next if /<\/?alignment>/;
	last if (/<summary>/);
	if (/alph-proto-sentence/) {
		my ($id) = /id="(.*?)"/;
		$id =~ s/=/_/;
		$id =~ s/:/-/;
		warn("id=$id\n");
		($lang) = /lang="(.*?)"/;
		$next{$lang} = $id . $SFX{$lang} . '.html';
		if ($prev{$lang}) {
			my $next_link = 
			qq!<a class="alph-proto-next" href="$next{$lang}">! .
			qq!<img src="/img/next.gif" alt="next"/></a>\n!;
		        $html{$lang} =~ s/<NEXT>/$next_link/;
			$html{$lang} .= $foot{$lang};
			$html{$lang} =~ s/<URL_(\w+)>/get_trans_url($1,$prev{$lang})/e;
		        warn("printing file=$prev{$lang}\n");
			open FILE, ">$prev{$lang}" or die "$!\n";
			print FILE $html{$lang};
			close FILE;
		}
		# reset the html
		$html{$lang} = $head{$lang} . $_ . "\n";
		$end{$lang} = undef;		
	} elsif (/<\/p>/) {
		my $nav;
		if ($lang eq 'greek') {
		    $nav = qq!<div class="alpheios-ignore" id="alph-proto-nextprev">\n!;
		    my $hide_class = '';
		    if (! $prev{$lang}) {
			    $hide_class = 'hide-prev';
		    }
		    $nav .= qq!<a class="alph-proto-prev $hide_class" href="$prev{$lang}"><img alt="previous" src="/img/prev.gif"/></a>!;
		    $nav .= qq!<NEXT></div>\n!;
		}
		$html{$lang} .= $_ . "\n";
	        $html{$lang} .= $nav;
		$last{$lang} = $prev{$lang};
		$prev{$lang} = $next{$lang};
		$end{$lang} = $next{$lang};
	} else {
		$html{$lang} .= $_ . "\n";
	}
}
foreach my $lang (keys %end) {
	$html{$lang} =~ s/<NEXT>//;
	$html{$lang} .= $foot{$lang};
	$html{$lang} =~ s/<URL_(\w+)>/get_trans_url($1,$end{$lang})/e;
	open FILE, ">$last{$lang}" or die "$!\n";
	print FILE $html{$lang};
	close FILE;
}


sub get_trans_url {
	my ($lang,$file) = @_;
	$file =~ s/$SFX{'greek'}\.html/$SFX{'en'}.html/;
	return 'http://dev.alpheios.net:8020/alpheios_proto/' . 
		$file;
}
