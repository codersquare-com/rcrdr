<?
//var_dump($_REQUEST);
$data = $_REQUEST['mp3'];
$f = base64_decode($data);
file_put_contents('./tmp/test.zip', $f);

die();
?>
