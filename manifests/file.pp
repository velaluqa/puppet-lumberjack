define lumberjack2::file (
    $paths,
    $fields,
    $instance  = 'agent',
){
    
    File {
        owner => 'root',
        group => 'root',
    }

    if ($paths != '') {
        validate_array($paths)
    }
    if ($fields != ''){
        validate_hash($fields)
    }
 
    $file = {
      "paths" => $paths,
      "fields"=> $fields,
    }   
    
    concat::fragment{"${name}":
        target  => "/etc/lumberjack2/$instance/lumberjack.conf",
        content => inline_template('<%= file.to_json %>'),
        order   => 010,
    }
}
