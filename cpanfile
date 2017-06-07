requires 'indirect',    '>= 0.37';
requires 'DBIx::Connector', '>= 0.56';
requires 'DBD::Pg';

on test => sub {
    requires 'Test::More', '>= 0.98';
    requires 'Test::PostgreSQL';
};

on develop => sub {
    requires 'Devel::Cover', '>= 1.23';
    requires 'Devel::Cover::Report::Codecov', '>= 0.14';
};
