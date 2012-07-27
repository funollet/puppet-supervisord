define supervisord::config () {

    file { "${supervisord::conf_files_dir}/$title":
        owner   => root, group => root, mode => 644,
        source  => [
            "puppet:///files/supervisord/conf.d/$title.${hostname}",
            "puppet:///files/supervisord/conf.d/$title",
            "puppet:///modules/supervisord/conf.d/$title",
        ],
        notify  => Exec["supervisorctl_update"],
    }

}
