class supervisord {

    $supervisorctl = "/usr/bin/supervisorctl"

    $daemon = $lsbdistcodename ? {
        /etch|lenny/    => "supervisord",
        default         => "supervisor",
    }
    $conf_dir = $lsbdistcodename ? {
        /etch|lenny/    => "/etc/supervisord.d",
        default         => "/etc/supervisor",
    }
    $conf_files_dir = $lsbdistcodename ? {
        /etch|lenny/    => "${conf_dir}",
        default         => "${conf_dir}/conf.d",
    }
    $main_conf = $lsbdistcodename ? {
        /etch|lenny/    => "/etc/supervisord.conf",
        default         => "${conf_dir}/supervisord.conf",
    }
    
    case $lsbdistcodename {
        /etch|lenny/: {
            include supervisord::nonpackaged
        }
        default: {
            package { "supervisor": ensure => installed }
        }
    }

    # default parameters for the daemon
    file { "/etc/default/${daemon}":
        owner  => root, group => root, mode => 644,
        source  => [
            "puppet:///files/supervisord/default.supervisord.${hostname}",
            "puppet:///files/supervisord/default.supervisord",
            "puppet:///modules/supervisord/default.supervisord",
        ],
        notify  => Service["${daemon}"],
        before  => Service["${daemon}"],
    }
    
    service { "${daemon}":
        enable    => true,
        ensure    => running,
        stop      => "supervisorctl shutdown",
        pattern   => "supervisord",
    }


    # Change default start number (S20/K20). If supervisord starts before user
    # auth is fully working all programs will be started as root.
    exec { "update-rc.d-supervisord-remove": 
        command     => "update-rc.d -f ${daemon} remove",
        refreshonly => true,
    }
    exec { "update-rc.d-supervisord": 
        command => "update-rc.d supervisord start 90 2 3 4 5 . stop 10 0 1 6 .",
        refreshonly => true,
        require     => Exec["update-rc.d-supervisord-remove"],
    }



    exec { "supervisorctl_update":
        command     => "${supervisorctl} reread && ${supervisorctl} update",
        refreshonly => true,
    }
    

    # Main config.
    file { "supervisord.conf":
        path    => "${main_conf}",
        owner   => root, group => root, mode => 644,
        source  => [
            "puppet:///files/supervisord/supervisord.conf.${hostname}",
            "puppet:///files/supervisord/supervisord.conf.${lsbdistcodename}",
            "puppet:///files/supervisord/supervisord.conf",
            "puppet:///modules/supervisord/supervisord.conf",
        ],
        notify  => Exec["supervisorctl_update"],
    }
}
