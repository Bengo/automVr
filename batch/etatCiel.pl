#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;
use LWP::Simple;
use XML::Simple;

# récupere la couverture nuageuse afin de determiner un indice de visibilite allant de 0 (aucun nuage) a 4 (aucune visibilite)

#calcul le coefficient d'une couche de nuage
#prend en parametre l'altitude du bas des nuages
sub Calcul_Multi_Couche($) {
	my ($alt) = @_;
	my $multi = 1;
	if($alt lt 6500) {
		# couche basse
		$multi = (-20*$alt)/6500+100;
	} elsif($alt lt 23000) {
		# couche moyenne
		$multi = (-50*$alt)/16500+60;
	} else {
		# couche elevee
		$multi = (-20*$alt)/17000+40;
	}
	return $multi;
}

#calcul l'indice de visibilite d'une couche de nuage
#prend en param le type de nuage, et l'altitude de ces nuages
sub Calcul_Indice_Visibilite_Couche($$){
	my %tableauVisibilite = (
		"FEW" => "1",
		"SCT" => "2",
		"BKN" => "3",
		"OVC" => "4",	
	    );

	my ($type,$alt) = @_;
	my $indice = $tableauVisibilite{$type};
	my $multi = Calcul_Multi_Couche($alt);
		
	return $indice*$multi/100;
}

# récupère le corps de la réponse
my $request = HTTP::Request->new(GET => "http://aviationweather.gov/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=xml&stationString=LFRB&hoursBeforeNow=1");
my $ua = new LWP::UserAgent();
$ua->proxy( 'http', 'http://proxy.gicm.net:3128/');
my $response = $ua->request($request);

if ($response->is_error) {
	print STDERR $response->status_line, "\n";
	print STDERR status_message($response->status_line), "\n";
	print STDERR $response->error_as_HTML, "\n";
}
else { 
	my $metarContent =  $response->decoded_content;

	my $metarXml = XMLin($metarContent);

	#il peut y avoir plusieurs METAR (on ne garde que le premier)
	my $nbMetar = $metarXml->{data}->{num_results};
	my $metar;
	if($nbMetar eq "1"){
		$metar = $metarXml->{data}->{METAR};
	} else {
		$metar = $metarXml->{data}->{METAR}->[0];
	}

	
	# il peut y avoir plusieurs sky_condition simultanees (une par strate de nuages)
	# si il n'y a pas de sky_condition : ciel clair	
	# on se base sur le premier metar du xml
	
	#indice de visibilite allant de 0 (aucun nuage) a 4 (aucune visibilite)
	my $iv = 0;
	if (ref($metar->{sky_condition}) eq "ARRAY"){	
		my @tabIv = ();		
		foreach my $condition (@{$metar->{sky_condition}}) {				
			push(@tabIv,Calcul_Indice_Visibilite_Couche($condition->{sky_cover},$condition->{cloud_base_ft_agl}));
		}
		#on calcul la moyenne des iv des differentes couches
		my $moy = 0;			
		foreach my $indice (@tabIv) {
		  $moy = $moy + $indice
		}
		my $length = scalar @tabIv;
		$iv=$moy/$length;
	} else {
		if(!defined $metar->{sky_condition}->{sky_cover}){
			#cas NSC
			$iv = 0;
		} else {

			if($metar->{sky_condition}->{sky_cover} eq "CAVOK"){
				#cas CAVOK
				$iv = 0;				
			} else {
				$iv = Calcul_Indice_Visibilite_Couche($metar->{sky_condition}->{sky_cover},$metar->{sky_condition}->{cloud_base_ft_agl});
			}
		}
		
	}
	print  "$iv;\n";
}






