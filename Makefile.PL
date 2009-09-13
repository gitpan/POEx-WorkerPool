
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'POEx-WorkerPool',
  NAME      => 'POEx::WorkerPool',
  AUTHOR    => 'Nicholas\ Perez\ \<nperez\@cpan\.org\>',
  ABSTRACT  => 'A\ second\ generation\ publish\/subscribe\ component\ for\ the\ POE\ framework',
  VERSION   => '0.092560',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "MooseX::AttributeHelpers" => '0.21',
    "TryCatch" => '1.002000',
    "Throwable" => '0.092000',
    "POEx::PubSub" => '0.092460',
    "Data::UUID" => '1.202',
  },
);
