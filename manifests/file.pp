define lumberjack2::file (
    $paths,
    $fields,
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
 
    $files = { 
        "file" => {
            "paths" => $paths,
            "fields"=> $fields,
         }
    }   
   
    concat::fragment{"${name}":
        target  => "${lumberjack2::params::configdir}/conf/lumberjack2.conf",
        content => inline_template('<%= files.to_json %>'),
        order   => 010,
    }
}
