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

########################################
# thruk finds exactly this browser and can render with it
# (the selftest names the version: chrome-headless-shell 121 for el7 does
# not print it with --version. Without user namespaces, as on el7, the
# renderer notes on stdout that it runs without sandbox.)
my $no_sandbox_note = '(browser did not start with sandbox .*, sandbox is off for this run\n)?';
my $selftest = { cmd => "/bin/su - $site -c 'share/thruk/script/html2pdf.sh --selftest'", like => ['/^version: \S+\/\d+\.\d+/m', '/^sandbox: (on|off)$/m', '/rendering test OK/'] };
my $tests = [
  { cmd => "/bin/su - $site -c 'omd start'", like => '/Starting/' },
  { cmd => "/bin/su - $site -c 'share/thruk/script/html2pdf.sh --find-browser'", like => '/^'.quotemeta($btest->{'stdout'}).'$/' },
  $selftest,
  { cmd => "/bin/su - $site -c 'share/thruk/script/html2pdf.sh http://localhost:5000/".$site."/thruk/cgi-bin/remote.cgi tmp/test.pdf'", like => '/^'.$no_sandbox_note.'$/' },
  { cmd => "/bin/su - $site -c 'file tmp/test.pdf'", like => '/PDF document/' },
  # the puppeteer module is not shipped any more (lib/node_modules/npm comes with packages/node)
  { cmd => "/bin/su - $site -c 'test ! -e lib/node_modules/puppeteer && echo gone'", like => '/^gone$/' },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}
diag($1." (".$btest->{'stdout'}.")") if(($selftest->{'stdout'} // '') =~ m/^version: (.*)$/m);

##################################################
# cleanup test site
TestUtils::remove_test_site($site);

done_testing();
