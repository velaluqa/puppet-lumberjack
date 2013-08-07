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
 
    if ($lumberjack2::ensure == 'present' ) { 
        concat::fragment{"${name}":
            target  => "${lumberjack2::params::configdir}/conf/lumberjack2.conf",
            content => template("${module_name}/file_format.erb"),
            order   => 010,
        }
    }
}
