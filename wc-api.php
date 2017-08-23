<?php
$post = $_POST;
$type = $post['type'];
$token = $post['token'];
$useragent = $post['useragent'];
$apiurl = $post['apiurl'];
$ip = $_SERVER['REMOTE_ADDR'];
$url = $_SERVER['HTTP_REFERER'];
$ch = curl_init();
$param = [];
$param['type'] = $type;
$param['ip'] = $ip;
$param['token'] = $token;
$param['useragent'] = $useragent;
$param['url'] = $url;
curl_setopt($ch, CURLOPT_URL,$apiurl);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS,http_build_query($param));

// in real life you should use something like:
// curl_setopt($ch, CURLOPT_POSTFIELDS, 
//          http_build_query(array('postvar1' => 'value1')));

// receive server response ...
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$server_output = curl_exec ($ch);

curl_close ($ch);
echo json_encode($server_output);
?>