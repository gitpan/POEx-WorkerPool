
use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
  module_name   => 'POEx::WorkerPool',
  license       => 'perl',
  dist_abstract => "A\ second\ generation\ publish\/subscribe\ component\ for\ the\ POE\ framework",
  dist_name     => "POEx\-WorkerPool",
  dist_author   => [
"Nicholas\ Perez\ \<nperez\@cpan\.org\>",
  ],
  requires      => {
    "Throwable" => '0.092000',
    "TryCatch" => '1.002000',
    "MooseX::AttributeHelpers" => '0.21',
    "POEx::PubSub" => '0.092460',
    "Data::UUID" => '1.202',
    "POE" => '1.268',
  },
  script_files => [ qw() ],
);

$build->create_build_script;
