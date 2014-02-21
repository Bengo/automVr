#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use LWP::Simple;
use XML::Simple;

# on ouvre le fichier de configuration 
my $cfg = Config::IniFiles->new( -file => "/home/bengo/Outils/automVr/config.ini");

# date du jour
my (undef, undef, undef, $jour, $mois, undef, undef, undef, undef) = localtime(time); 
$mois +=1;
$jour = sprintf("%02d",$jour);
$mois = sprintf("%02d",$mois);

# récupère le corps de la réponse
my $request = HTTP::Request->new(GET => "http://www.earthtools.org/sun/48.4333/-4.6167/$jour/$mois/1/0");
my $ua = new LWP::UserAgent();
my $response = $ua->request($request);

if ($response->is_error) {
	$cfg->newval("Erreur","Cause",$response->status_line);
	print STDERR $response->status_line, "\n";
	print STDERR status_message($response->status_line), "\n";
	print STDERR $response->error_as_HTML, "\n";
}
else { 
	my $earthtoolsContent =  $response->decoded_content;
	# récupère heure lever et coucher de soleil
	my $earthtoolsXml = XMLin($earthtoolsContent);
	my $leverSoleil = $earthtoolsXml->{morning}->{twilight}->{civil};
	my $coucherSoleil = $earthtoolsXml->{evening}->{twilight}->{civil};

	$cfg->newval("Ephemeride","leverSoleil",$leverSoleil);
	$cfg->newval("Ephemeride","coucherSoleil",$coucherSoleil);
	$cfg->newval("Erreur","Cause","");
}

$cfg->WriteConfig("/home/bengo/Outils/automVr/config.ini");





