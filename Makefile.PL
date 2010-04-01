
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'POEx::WorkerPool',
                       'DISTNAME' => 'POEx-WorkerPool',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.31'
                                               },
                       'AUTHOR' => 'Nicholas Perez <nperez@cpan.org>',
                       'BUILD_REQUIRES' => {
                                             'Test::More' => '0',
                                             'FindBin' => '0'
                                           },
                       'ABSTRACT' => 'A multiprocess worker pool for the POE framework',
                       'EXE_FILES' => [],
                       'VERSION' => '1.100910',
                       'PREREQ_PM' => {
                                        'POE::Wheel::Run' => '0',
                                        'POEx::Role::SessionInstantiation' => '0',
                                        'MooseX::Types::Moose' => '0',
                                        'MooseX::Declare' => '0',
                                        'Class::MOP' => '0',
                                        'MooseX::Types::Structured' => '0',
                                        'Sub::Exporter' => '0',
                                        'Moose::Util::TypeConstraints' => '0',
                                        'aliased' => '0',
                                        'MooseX::CompileTime::Traits' => '0',
                                        'Moose' => '0',
                                        'POE::Filter::Reference' => '0',
                                        'constant' => '0',
                                        'Data::UUID' => '0',
                                        'MooseX::AttributeHelpers' => '0',
                                        'TryCatch' => '0',
                                        'POE::Wheel::ReadWrite' => '0',
                                        'MooseX::Types' => '0',
                                        'POEx::PubSub' => '0',
                                        'POEx::Types' => '0',
                                        'POE' => '0'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{BUILD_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.56) };

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



