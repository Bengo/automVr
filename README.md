automVr
=======

Automatisation de l'ouverture/fermeture des volets roulants via un raspberry pi, et des modules yokis MVR500




____________
install de nodejs
pacman -Su node


____________
install de perl

pacman -Su perl
cpan install Config::IniFiles
cpan install LWP::Simple
cpan install XML::Simple
cpan install DateTime
cpan install Switch

#Ephemeride
0 2 * * * /home/bengo/Outils/automVr/scripts/ephemeride.pl

#Meteo
*/30 * * * * /home/bengo/Outils/automVr/scripts/meteo.pl

#Automatisation volets
*/1 * * * * /home/bengo/Outils/automVr/scripts/declenchementVR.pl
