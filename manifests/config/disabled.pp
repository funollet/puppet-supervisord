define supervisord::config::disabled () {
    file { "${supervisord::conf_dir}/$title":
        ensure  => absent,
    }
}

