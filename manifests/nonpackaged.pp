class supervisord::nonpackaged {

    # init script for non-Debian-packaged versions.
    file { "/etc/init.d/${supervisord::daemon}":
        owner  => root, group => root, mode => 755,
        source  => [
            "puppet:///files/supervisord/init.supervisord.${hostname}",
            "puppet:///files/supervisord/init.supervisord",
            "puppet:///modules/supervisord/init.supervisord",
        ],
        notify => [
            Exec["update-rc.d-supervisord-remove"],
            Exec["update-rc.d-supervisord"],
            Service["${supervisord::daemon}"],
        ]
    }

    # requirements that can be satisfied via dpkg
    case $lsbdistcodename {
        etch: {
            package { ["python-elementtree", "python-celementtree"]:
                ensure => installed,
                before => Exec["easy_install_supervisor"],
            }
        }
    }
        
    python::easy_install { "supervisor": creates => "/usr/bin/supervisord" }
    # NOTE:
    # Installing superlance-0.5 via easy_install / pip requires a version
    # of python-setuptools newer that the package in Debian Lenny (>=0.6c9).
    #
    # superlance can probably be forced to install by editing its 'ez-setup.py'
    # but this would be nasty so better do it by hand.
    #
    #python::easy_install { "superlance": creates => "/usr/bin/memmon" }

    file { "${supervisord::conf_dir}" :
        owner   => root, group => root, mode => 755,
        ensure  => directory,
    }

}
