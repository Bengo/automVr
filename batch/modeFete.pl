#!/usr/bin/perl
use strict;
use warnings;
use Config::IniFiles;

# on ouvre le fichier de configuration 
my $cfg = Config::IniFiles->new( -file => "/home/bengo/Outils/automVr/config.ini");
my $modeFete =  $cfg->val("ModeFete","modeFete");

if ($#ARGV == -1) {
	print "Probleme de parametres";
}
else {
	$modeFete=$ARGV[0];
}

$cfg->newval("ModeFete","modeFete",$modeFete);
$cfg->WriteConfig("/home/pi/Outils/automVr/config.ini");
