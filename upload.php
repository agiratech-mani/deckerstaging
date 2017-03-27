<?php
if(!empty($_POST['datauri'])){
    $basefolder = $_POST['basefolder'];
    $filename = $_POST['filename'];
    $folder = $basefolder.$filename;
    if(file_exists($folder))
    {
        unlink($folder);     
    }
    if(!is_dir($basefolder))
    {
    //Directory does not exist, so lets create it.
        mkdir($basefolder, 0777, true);
    }

    
    //$folder = $basefolder.$filename;
    $filepath =  __DIR__.'/'.$folder;
    $encoded_data = $_POST['datauri'];
    $encoded_data = str_replace('data:application/pdf;base64,', '', $encoded_data);
    $encoded_data = str_replace(' ', '+', $encoded_data);
    $decoded_data = base64_decode($encoded_data);
    file_put_contents($filepath, $decoded_data); 
    chmod($filepath, 0777);
    echo $folder;
} 
else {
    echo "No Data Sent"; 
}
exit();
?>
