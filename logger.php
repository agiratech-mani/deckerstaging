<?php

try
	{
	$postdata = file_get_contents("php://input");
  	$request = json_decode($postdata);
	$url = $request->url;
	//$browser = ucwords($request->browser);
	 $userAgent = $request->userAgent;
		$obj = get_browser($request->userAgent, true);
	$os = $obj['platform'].' '.$obj['platform_bits'].' bit';
		$ip = $_SERVER['REMOTE_ADDR'];
		$session_id = '';
		$created = date('Y-m-d H:i:s');
		$data = $request->data;
		$place = $request->place;
 

		$log  = "User: ".$_SERVER['REMOTE_ADDR'].' - '.date("F j, Y, g:i a").PHP_EOL.
	        "URL: ".$url.PHP_EOL.
	        "PLACE: ".$place.PHP_EOL.
	        "UserAgent: ".$userAgent.PHP_EOL.
	        "OS: ".$os.PHP_EOL.
	        "DATA: ".$data.PHP_EOL.
	        "-------------------------".PHP_EOL;
		//Save string to log, use FILE_APPEND to append.
	  /*if(file_exists('./logs'))
	  {
	  	mkdir("./logs",'0755');
		}*/
		file_put_contents('./logs/log_'.date("j_n_Y").'.txt', $log, FILE_APPEND);
 

		
		// $servername = "localhost";
		// $username = "decker_deckerc";
		// $password = "wu7fZzhyGKCZ"; //Your User Password
		// $dbname = "decker_dcommweb"; //Your Database Name
		// $servername = "localhost";
		// $username = "root";
		// $password = "root"; //Your User Password
		// $dbname = "deckercomm"; //Your Database Name

		// // Create connection
		// $conn = new mysqli($servername, $username, $password, $dbname);
		// // Check connection
		// if ($conn->connect_error) {
		//     die("Connection failed: " . $conn->connect_error);
		// } 

		// $sql = "INSERT INTO course_log
		// 	(`url`, `useragent`, `browser`, `os`, `bandwidth`, `ip`, `created`)
		// VALUES ('$url','$userAgent','$browser','$os','$bandwidth','$ip','$created');";
		// echo $sql;
		// if ($conn->query($sql) === TRUE) {
		//     echo "New record created successfully";
		// } else {
		//     echo "Error: " . $sql . "<br>" . $conn->error;
		// }
 
		// $conn->close();
	}
	catch (Exception $e) {
    echo 'Caught exception: ',  $e->getMessage(), "\n";
	}
 ?>