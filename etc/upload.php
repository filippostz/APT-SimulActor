<?php
//curl -F "uploaded=@file.ext" http://httpserver/upload.php
  if(!empty($_FILES['uploaded']))
  {
    $path = "upload/";
    $path = $path . basename( $_FILES['uploaded']['name']);
    if(@move_uploaded_file($_FILES['uploaded']['tmp_name'], $path)) {echo "1";} else{echo "0";}
  }
?>
