#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or TestUtils::bail_out("no further testing without site");

########################################
# the site environment names the browser thruk uses
my $btest = { cmd => "/bin/su - $site -c 'echo \$THRUK_BROWSER'", like => '/^\//' };
TestUtils::test_command($btest) or TestUtils::bail_out("no further testing without THRUK_BROWSER");
chomp($btest->{'stdout'});
my $vtest = { cmd => "/bin/su - $site -c '\"\$THRUK_BROWSER\" --version'", like => '/\d+\.\d+/' };
TestUtils::test_command($vtest) or TestUtils::bail_out("no further testing without working browser");
chomp($vtest->{'stdout'});
diag($vtest->{'stdout'}." (".$btest->{'stdout'}.")");

########################################
# thruk finds exactly this browser and can render with it
my $tests = [
  { cmd => "/bin/su - $site -c 'omd start'", like => '/Starting/' },
  { cmd => "/bin/su - $site -c 'share/thruk/script/html2pdf.sh --find-browser'", like => '/^'.quotemeta($btest->{'stdout'}).'$/' },
  { cmd => "/bin/su - $site -c 'share/thruk/script/html2pdf.sh --selftest'", like => ['/^sandbox: (on|off)$/m', '/rendering test OK/'] },
  { cmd => "/bin/su - $site -c 'share/thruk/script/html2pdf.sh http://localhost:5000/".$site."/thruk/cgi-bin/remote.cgi tmp/test.pdf'", like => '/^$/' },
  { cmd => "/bin/su - $site -c 'file tmp/test.pdf'", like => '/PDF document/' },
  # no NodeJS module tree is shipped any more
  { cmd => "/bin/su - $site -c 'test ! -e lib/node_modules && echo gone'", like => '/^gone$/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test) || diag(`/usr/bin/env; /bin/su - $site -c '/usr/bin/env'`);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
