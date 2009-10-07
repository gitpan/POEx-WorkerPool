
use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
  module_name   => 'POEx::WorkerPool',
  license       => 'perl',
  dist_abstract => "A\ multiprocess\ worker\ pool\ for\ the\ POE\ framework",
  dist_name     => "POEx\-WorkerPool",
  dist_author   => [
"Nicholas\ Perez\ \<nperez\@cpan\.org\>",
  ],
  requires      => {
    "MooseX::CompileTime::Traits" => '0.092801',
    "MooseX::AttributeHelpers" => '0.21',
    "TryCatch" => '1.002000',
    "Throwable" => '0.092000',
    "POEx::PubSub" => '0.092460',
    "Data::UUID" => '1.202',
  },
  script_files => [ qw() ],
);

$build->create_build_script;
