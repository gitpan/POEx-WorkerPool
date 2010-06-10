
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'A multiprocess worker pool for the POE framework',
  'AUTHOR' => 'Nicholas R. Perez <nperez@cpan.org>',
  'BUILD_REQUIRES' => {
    'FindBin' => '0',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'POEx-WorkerPool',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'POEx::WorkerPool',
  'PREREQ_PM' => {
    'Class::MOP' => '0',
    'Data::UUID' => '0',
    'Moose' => '0',
    'Moose::Util::TypeConstraints' => '0',
    'MooseX::AttributeHelpers' => '0',
    'MooseX::CompileTime::Traits' => '0',
    'MooseX::Declare' => '0',
    'MooseX::Types' => '0',
    'MooseX::Types::Moose' => '0',
    'MooseX::Types::Structured' => '0',
    'POE' => '0',
    'POE::Filter::Reference' => '0',
    'POE::Wheel::ReadWrite' => '0',
    'POE::Wheel::Run' => '0',
    'POEx::PubSub' => '0',
    'POEx::Role::SessionInstantiation' => '0',
    'POEx::Types' => '0',
    'Sub::Exporter' => '0',
    'Throwable' => '0',
    'TryCatch' => '0',
    'aliased' => '0',
    'constant' => '0'
  },
  'VERSION' => '1.101610',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



