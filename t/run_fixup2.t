#!/usr/bin/env perl -w

use strict;
use warnings;
use Test::More;
use Test::MockModule;
use Test::PostgreSQL;
use Test::Exception;
use Scalar::Util qw(refaddr);
my $pgsql = Test::PostgreSQL->new()
    or plan skip_all => $Test::PostgreSQL::errstr;

my $CLASS;

BEGIN {
    $CLASS = 'DBIx::Connector::Pg';
    use_ok $CLASS or die;
}

ok my $conn = $CLASS->new($pgsql->dsn), 'Get a connection';
$conn->run(
    fixup => sub {
        $_->do(<<'SQL');
CREATE OR REPLACE FUNCTION f_exec(text)
  RETURNS void LANGUAGE plpgsql AS
$BODY$
BEGIN
   RAISE EXCEPTION using message='test_error', errcode='BI999';
END;
$BODY$;
SQL
    });
my $dbh_addr = refaddr $conn->dbh;
isa_ok($conn, $CLASS);
throws_ok {
    $conn->run(fixup => sub { $_->do("select f_exec('hello');") });
}
qr/test_error/;
$pgsql->stop;
$pgsql->start;
my $new_dbh_addr = $conn->run(fixup => sub { $_->do('select 1'); return refaddr $_});
isnt($dbh_addr, $new_dbh_addr);
done_testing();
