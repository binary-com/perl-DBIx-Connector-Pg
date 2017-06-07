package DBIx::Connector::Pg;
# ABSTRACT: ...

use strict;
use warnings;
use parent 'DBIx::Connector';

our $VERSION = '0.001';

sub connected {
    my $self = shift;
    return unless $self->_seems_connected;
    my $dbh = $self->{_dbh} or return;
    $dbh->state and $dbh->state =~ /^08|^57/ and return;
    return 1;
    #dbh->state and $dbh->state =~ /^BI/ and return 1;
    #return $self->driver->ping($dbh);
}

=head1 NAME

DBIx::Connector::Pg - DBIx::Connector subclass to check connection error instead of ping

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

L<DBIx::Connector>

=over 4

=item *

=back

