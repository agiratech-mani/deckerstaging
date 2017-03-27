<?

$con = mysql_connect("localhost","root","");
 
$email = $_GET['email'];
$email = 'scott.schafer@gmail.com';

if (!$con)
{
  die('Could not connect: ' . mysql_error());
}
 
mysql_select_db("decker", $con);

$query = "SELECT data FROM 'users' WHERE 'email' =$email";
  
$datarow = mysql_query($query);

while($row = mysql_fetch_array($datarow, MYSQL_ASSOC))
{
  $data = $row['data'];
  
  echo $data;
}

mysql_close($con);

?>