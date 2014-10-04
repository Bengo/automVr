 <?php
header('Content-Type: text/xml; charset=UTF-8');

if(isset($_GET['zone']) AND isset($_GET['action'])){
	$action = escapeshellarg($_GET['action']);
	$zone = escapeshellarg($_GET['zone']);
	echo('../scripts/volets.pl '.$action.' '.$zone);
	exec('../scripts/volets.pl '.$action.' '.$zone);
	

} elseif(isset($_GET['option']) AND isset($_GET['value'])){
	$option = escapeshellarg($_GET['option']);
	$value = escapeshellarg($_GET['value']);
	if(strcmp($option, "modeFete")){
		if(strcmp($value, "on")){
			echo('../scripts/volets.pl option modeFeteOn');
			exec('../scripts/volets.pl option modeFeteOn');
		}
		if(strcmp($value, "off")){
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

