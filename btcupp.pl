#!/usr/bin/perl -w

#################################################
#						#
#	Public Data Collector by Platypus	#
#		     2015			#
#	Nie fertig werdendes Teufelszeug..	#
#						#
#################################################

#############
# LIBRARYS: #
#############

use strict; 
use warnings; 
use Getopt::Std;
use LWP::UserAgent;
use HTTP::Cookies;
use WWW::Mechanize;

##############
# VARIABLEN: #
##############

my %options=();

# Einstellungen:
my $userId = "";
my $username;
my $password;
my $maximum = 0;
my $leetmode = "false";
my $htmldump = "facebook.html";
my $falsepositive = "falsepositive.txt";


# Daten:
my $name;
my $surname;
my $day;
my $month;
my $century;
my $year;
my $partner;

my @likes;

############
# OPTIONS: #
############

getopts("hu:e:p:r:lak", \%options);

if (defined $options{u}){
	$userId = $options{u};
}
else {
	&printhelp;	
}	
if (defined $options{h}){
	&printhelp;
}
if (defined $options{e}){
	$username = $options{e};
}
if (defined $options{p}){
	$password = $options{p};
}
if (defined $options{r}){
	$maximum = $options{r};
}
if (defined $options{l}){
	$leetmode = "true";
}

################
# MAINROUTINE: #
################

print "\n                                                   ";
print "\n   ------------------------------------------------";
print "\n   |             Public Data Collector            |";
print "\n   |                 Platypus 2015                |";
print "\n   ------------------------------------------------";
print "\n                                                   ";
print "\n                                                   ";
print "\nFetching Data for User: $userId";
if (defined $options{e}){
	print "\nLoging in with: $username:$password";
}
print "\n";
print "\nSending Http request.... ";
&getFacebook;
print "\nOpening File... I'll take a look inside";
&openHtml;
print "           OK";
print "\n";
print "\nFound some Interesting Data... Lets see whats missing:";
&complete;
print "\n";
print "Fine... I'll write that down:";
&testprint;
print "\nPress any key to print the test-output:\n";
<STDIN>;
&justprint;
&adddates;

############
# HELPSUB: #
############

sub printhelp
{
	print "\n                                                   ";
	print "\n   ------------------------------------------------";
	print "\n   |             Public Data Collector            |";
	print "\n   |                 Platypus 2015                |";
	print "\n   ------------------------------------------------";
	print "\n                                                   ";
	print "\n                                                   ";
	print "\n Usage: perl btcupp.pl <Options>";
	print "\n Example: perl btcupp-pl -u roswitha.thomas -r 9999";
	print "\n";
	print "\n    -u    Facebook UserID (behind http://facebook.com/)";
	print "\n    -e    Email for Facebook login";
	print "\n    -p    Password for Facebook login";    
	print "\n    -r    Add random numbers from 0 to defined maxvalue;";
	print "\n    -l    Leet -> 1337 Mode";
	print "\n";
	print "\n";
	print "\n";
	exit;
}
sub printhelp;

################
# GETFACEBOOK: #
################

sub getFacebook
{
	my $response;
	
	if (defined $username && defined $password) {

	# Create the fake browser (user agent) and the cookie;	
	my $mech = WWW::Mechanize->new();
	$mech->cookie_jar(HTTP::Cookies->new());

	# Pretend to be Internet Explorer.
	$mech->agent("Windows IE 7");

	# Login to the page
	$mech->get('http://www.facebook.com/');
	$mech->form_name('menubar_login');
	$mech->field("email", $username);
	$mech->field("pass", $password);
	$mech->click;



#	Hier brauchts wohl etwas JavaScript oder doch WWW:Mechanize::Firefox
#	Um ans Ende der Seite zu Scrollen. By now passt der Login und die 
#	Navigation. Aber eben leider nur die halbe Seiite.



	# Catch the response.
	$response = $mech->get('https://www.facebook.com/'.$userId.'/about/');	



#	Jetzt noch die anderen Seiten abcrawlen.	
#	$mech->get('https://www.facebook.com/'.$userId.'/likes_all/');
#	Wäre mal n Anfang.


	}

	else {
		
	# Create the fake browser (user agent) and the cookie;
	my $ua = LWP::UserAgent->new();
	$ua->cookie_jar(HTTP::Cookies->new());
    
	# Pretend to be Internet Explorer. Can be changed to $ua->agent("Mozilla/8.0");
	$ua->agent("Windows IE 7");

	# Catch the response.
	$response = $ua->get('https://www.facebook.com/'.$userId);
	
	}

	unless($response->is_success) {
		print "Error: " . $response->status_line;
	}
	unless(open SAVE, '>' . $htmldump) {
		die "\nCannot create save file '$htmldump'\n";
	}
    
	# Without this line, we may get a 'wide characters in print' warning.
	binmode(SAVE, ":utf8");   
	print SAVE $response->decoded_content;
	close SAVE;
	print "                         OK\nSaved " . length($response->decoded_content) . " bytes of data to '$htmldump'.    OK";
}
sub getFacebook;

#############
# OPENFILE: #
#############

sub openHtml
{
	my $capture;
	my $real;

	open HTMLDUMP,$htmldump or die "File '$htmldump' couldn't be found.\n";
	while(my $line=<HTMLDUMP>) {
		if ($line =~ m/pageTitle">(\w+).(\w+)/) {
			$surname = $1;
			$name = $2;
		}	

		while ($line =~ m/title="([^"]+)"/) {
			$capture = $1;
			$line =~ s/title/substituted/;
			$real = "true";
			open FALSEPOSITIVE,$falsepositive or die "File '$falsepositive' couldn't be found.\n";
			while(my $linefp=<FALSEPOSITIVE>) {
				if ($linefp =~ m/$capture/) {
					$real = "false";
				}		
			}
			close FALSEPOSITIVE;
			if ($real eq "true") {
				push @likes, $capture;
			}
		}
	}
	close HTMLDUMP;	
}
sub openHtml;

#############
# COMPLETE: #
#############

sub complete
{
	if (!defined $surname) {
		print "\nBitte Vornamen eingeben:\n";
		$surname = <STDIN>;
	}	
	if (!defined $name) {
		print "\nBitte Nachnamen eingeben:\n";
		$name = <STDIN>;
	}	
	if (!defined $year) {
		print "\nBitte Geburtsdatum eingeben: (ddmmyyyy)\n";
		my $birthday = <STDIN>;
		if ($birthday =~ m/(\d\d)(\d\d)(\d\d)(\d\d)/){
			$day = $1;
			$month = $2;
			$century = $3;
			$year = $4;
		}
	}
	if (!defined $partner) {
		print "\nBitte Partner eingeben:\n";
		$partner = <STDIN>;
	}
		
}
sub complete;

# Namen usw. auswerfen
sub testprint
{
	print "\nSurname: $surname";
	print "\nName: $name";	
	print "\nBirthday: $day.$month.$century$year";	
	print "\nPartner: $partner";

}	
sub testprint;

# Interessen auswerfen
sub justprint
{
	print "Found likes:"; 
	foreach (@likes) {
		print "\n$_";
	}

}
sub justprint;

# Datum anhängen
sub adddates
{
	print "\n\nAdding dates:"; 
	foreach (@likes) {
		print "\n$_$year";
		print "\n$_$century$year";		
		print "\n$_$day$month$century$year";		
	}
}
sub adddates;


# sub addrandoms
# {
# }
# sub addrandoms;
# sub leetmode
# {
# }
# sub leetmode;