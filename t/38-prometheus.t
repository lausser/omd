#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use Sys::Hostname;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan( tests => 78 );

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();

my $site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
TestUtils::test_command({ cmd => $omd_bin." config $site set APACHE_MODE ssl" });
TestUtils::test_command({ cmd => $omd_bin." config $site set THRUK_COOKIE_AUTH off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE none" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PROMETHEUS on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set BLACKBOX_EXPORTER on" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => ['/Starting prometheus\.+OK/', '/Starting blackbox_exporter\.+OK/'] });
sleep(2);
#admin interface
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H 127.0.0.1 -p 9090 --onredirect=follow -s \"<title>Prometheus Time Series Collection and Processing Server</title>\"'", like => '/HTTP OK:/' });
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

$site    = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
TestUtils::test_command({ cmd => $omd_bin." config $site set APACHE_MODE ssl" });
TestUtils::test_command({ cmd => $omd_bin." config $site set THRUK_COOKIE_AUTH off" });
TestUtils::test_command({ cmd => $omd_bin." config $site set CORE none" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PROMETHEUS on" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PROMETHEUS_TCP_PORT 10000" });
TestUtils::test_command({ cmd => $omd_bin." config $site set PROMETHEUS_TCP_ADDR 127.0.0.2" });
TestUtils::test_command({ cmd => $omd_bin." start $site", like => '/Starting prometheus\.+OK/' });
sleep(2);
#admin interface
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H 127.0.0.2 -p 10000 --onredirect=follow -s \"<title>Prometheus Time Series Collection and Processing Server</title>\"'", like => '/HTTP OK:/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'lib/nagios/plugins/check_http -t 60 -H 127.0.0.1 -p 5000 --onredirect=follow -a omdadmin:omd -u \"/$site/prometheus\" --ssl -s \"<title>Prometheus Time Series Collection and Processing Server</title>\"'", like => '/HTTP OK:/' });
TestUtils::test_command({ cmd => $omd_bin." stop $site" });
TestUtils::remove_test_site($site);

