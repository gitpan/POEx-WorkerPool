
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'POEx-WorkerPool',
  NAME      => 'POEx::WorkerPool',
  AUTHOR    => 'Nicholas\ Perez\ \<nperez\@cpan\.org\>',
  ABSTRACT  => 'A\ multiprocess\ worker\ pool\ for\ the\ POE\ framework',
  VERSION   => '0.092800',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "MooseX::CompileTime::Traits" => '0.092801',
    "MooseX::AttributeHelpers" => '0.21',
    "TryCatch" => '1.002000',
    "Throwable" => '0.092000',
    "POEx::PubSub" => '0.092460',
    "Data::UUID" => '1.202',
  },
  test => {TESTS => 't/*.t'}
);

