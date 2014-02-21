 <?php
header('Content-Type: text/xml; charset=UTF-8');


function baisser($val)
{
   exec("/home/bengo/Outils/automVr/batch/baisser.pl $val");
} 

function pause($val)
{
   exec("/home/bengo/Outils/automVr/batch/pause.pl $val");
}

function lever($val)
{
   exec("/home/bengo/Outils/automVr/batch/lever.pl $val");
}


if($_GET['zone']!='')
{
   @call_user_func($_GET['action'], $_GET['zone']); 
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

