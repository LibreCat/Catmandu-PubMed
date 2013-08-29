#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

my $pkg;
BEGIN {
    $pkg = 'Catmandu::Importer::EBI';
    use_ok $pkg;
}

require_ok $pkg;

my $importer = Catmandu::Importer::EBI->new(query => '10779411');

isa_ok($importer, $pkg);

can_ok($importer, 'each');

done_testing 4;