package DBIx::Connector::Pg;
# ABSTRACT: ...

use strict;
use warnings;
use parent 'DBIx::Connector';

our $VERSION = '0.001';

1;

__END__

# This module started as an attempt to prevent excessive PING operations
# on the database. Unfortunately, this didn't work as expected.
