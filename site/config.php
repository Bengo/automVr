<?php
 $data = parse_ini_file(realpath("../config.ini"),true);


  echo json_encode($data);


?>
