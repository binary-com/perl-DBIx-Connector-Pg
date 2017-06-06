#!/usr/bin/env perl -w

use strict;
use warnings;
#use Test::More tests => 49;
use Test::More;
use Test::MockModule;
use Test::PostgreSQL;
use Scalar::Util qw(refaddr);
my $pgsql = Test::PostgreSQL->new()
  or plan skip_all => $Test::PostgreSQL::errstr;

my $CLASS;

BEGIN {
    $CLASS = 'DBIx::Connector::Pg';
    use_ok $CLASS or die;
}

ok my $conn = $CLASS->new($pgsql->dsn), 'Get a connection';
my $dbh_addr = refaddr $conn->dbh;
isa_ok($conn, $CLASS);
$pgsql->stop;
$pgsql->start;
my $new_dbh_addr = $conn->run(fixup => sub{$_->do('select 1'); return refaddr $_});
isnt($dbh_addr, $new_dbh_addr);
done_testing();
