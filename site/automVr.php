 <?php
header('Content-Type: text/xml; charset=UTF-8');

if(isset($_GET['zone']) AND isset($_GET['position'])){
	$position = escapeshellcmd($_GET['position']);
	$zone = escapeshellcmd($_GET['zone']);
	$commande = '../scripts/volets.pl '.$zone.' '.$position;
	echo $commande;
	exec($commande);
	

} elseif(isset($_GET['option']) AND isset($_GET['value'])){
	$option = escapeshellcmd($_GET['option']);
	$value = escapeshellcmd($_GET['value']);
		
	if(!strcmp($option, "modeFete")){
		if(!strcmp($value, "on")){
			echo exec('whoami');
			
			echo('../scripts/volets.pl option modeFeteOn');
			exec('../scripts/volets.pl option modeFeteOn');
		}
		if(!strcmp($value, "off")){
			echo('../scripts/volets.pl option modeFeteOff');
			exec('../scripts/volets.pl option modeFeteOff');
		}
		
	}
}
else
{
   echo "<response>

            <error>".utf8_encode("Requête Invalide")."</error>

            <action>".$_GET['action']."</action>

            <zone>".$_GET['zone']."</zone>

         </response>";

}

?>

