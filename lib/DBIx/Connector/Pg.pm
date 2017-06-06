package DBIx::Connector::Pg;
# ABSTRACT: ...

use strict;
use warnings;
use parent 'DBIx::Connector';

our $VERSION = '0.001';

sub _exec {
    return DBIx::Connector::_exec(@_);
}

sub _fixup_run {
    my ($self, $code) = @_;
    my $dbh = $self->_dbh;

    my $wantarray = wantarray;
    return _exec($dbh, $code, $wantarray)
        if $self->{_in_run} || !$dbh->FETCH('AutoCommit');

    local $self->{_in_run} = 1;
    my ($err, @ret);
    TRY: {
        local $@;
        @ret = eval { _exec($dbh, $code, $wantarray) };
        $err = $@;
    }

    if ($err) {
        die $err if $self->connected;
        # Not connected. Try again.
        return _exec($self->_connect, $code, $wantarray, @_);
    }

    return $wantarray ? @ret : $ret[0];
}

sub _txn_fixup_run {
    my ($self, $code) = @_;
    my $dbh    = $self->_dbh;
    my $driver = $self->driver;

    my $wantarray = wantarray;
    local $self->{_in_run} = 1;

    return _exec($dbh, $code, $wantarray) unless $dbh->FETCH('AutoCommit');

    my ($err, @ret);
    TRY: {
        local $@;
        eval {
            $driver->begin_work($dbh);
            @ret = _exec($dbh, $code, $wantarray);
            $driver->commit($dbh);
        };
        $err = $@;
    }

    if ($err) {
        if ($self->connected) {
            $err = $driver->_rollback($dbh, $err);
            die $err;
        }

        # Not connected. Try again.
        $dbh = $self->_connect;
        TRY: {
            local $@;
            eval {
                $driver->begin_work($dbh);
                @ret = _exec($dbh, $code, $wantarray);
                $driver->commit($dbh);
            };
            $err = $@;
        }
        if ($err) {
            $err = $driver->_rollback($dbh, $err);
            die $err;
        }
    }

    return $wantarray ? @ret : $ret[0];
}

=head1 NAME

DBIx::Connector::Pg - Module abstract

=head1 SYNOPSIS

    use DBIx::Connector::Pg;
    my $instance = DBIx::Connector::Pg->new;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

1;

=head1 AUTHOR

Chylli <chylli@163.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Chylli.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 SEE ALSO

=over 4

=item *

=back

