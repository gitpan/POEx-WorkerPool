package POEx::WorkerPool::Role::WorkerPool::Worker::GutsLoader;
BEGIN {
  $POEx::WorkerPool::Role::WorkerPool::Worker::GutsLoader::VERSION = '1.101610';
}

#ABSTRACT: Implementation role of the Guts loader

use MooseX::Declare;

role POEx::WorkerPool::Role::WorkerPool::Worker::GutsLoader
{
    use POE;
    use Class::MOP;
    use POEx::WorkerPool::Worker::Guts;
    use MooseX::Types;
    use MooseX::Types::Moose(':all');


    has job_classes => ( is => 'ro', isa => ArrayRef[ClassName], required => 1 );


    has init => ( is => 'ro', isa => CodeRef, lazy_build => 1 );


    has preamble => ( is => 'ro', isa => CodeRef, lazy_build => 1 );


    has main => ( is => 'ro', isa => CodeRef, lazy_build => 1 );


    has prologue => ( is => 'ro', isa => CodeRef, lazy_build => 1 );


    has loader => ( is => 'ro', isa => CodeRef, lazy_build => 1 );


    method _build_init
    {
        my $classes = $self->job_classes;
        return sub
        {
            Class::MOP::load_class($_) for @$classes;
        };
    }


    method _build_preamble
    {
        return sub
        {
            POE::Kernel->stop();
        };
    }


    method _build_main
    {
        return sub
        {
            POEx::WorkerPool::Worker::Guts->new();
        };
    }


    method _build_prologue
    {
        return sub
        {
            POE::Kernel->run();
        };
    }


    method _build_loader
    {
        my $init = $self->init;
        my $preamble = $self->preamble;
        my $main = $self->main;
        my $prologue = $self->prologue;

        return sub
        {
            $init->();
            $preamble->();
            $main->();
            $prologue->();
        };
    }
}

1;


=pod

=head1 NAME

POEx::WorkerPool::Role::WorkerPool::Worker::GutsLoader - Implementation role of the Guts loader

=head1 VERSION

version 1.101610

=head1 PUBLIC_ATTRIBUTES

=head2 job_classes

 is: ro, isa: ArrayRef[ClassName], required: 1

These are the job classes should be loaded during init using
Class::MOP::load_class

=head2 init

 is: ro, isa: CodeRef, lazy_build: 1

This holds the coderef that will be executed first to do any intitialization
prior to building the Guts session

=head2 preamble

 is: ro, isa: CodeRef, lazy_build: 1

This holds the coderef that is responsible for stopping the forked POE::Kernel
singleton

=head2 main

 is: ro, isa: CodeRef, lazy_build: 1

This holds the coderef that builds the actual Guts

=head2 prologue

 is: ro, isa: CodeRef, lazy_build: 1

This holds the coderef that calls run() on POE::Kernel to kickstart everything

=head2 loader

 is: ro, isa: CodeRef, lazy_build: 1

loader has the coderef that is used when building the POE::Wheel::Run instance
inside of Worker's child_wheel attribute. The coderef is actually an aggregate
of init, preamble, main, and prologue.

=head1 PROTECTED_METHODS

=head2 _build_init

_build_init builds the coderef used for initialization of the job classes in
the child process.

=head2 _build_preamble

_build_preamble builds the coderef that calls stop on POE::Kernel by default.

=head2 _build_main

_build_main builds the coderef that instantiates the Guts instance without any
arguments. If Guts has other roles applied at compile time that require extra
arguments, this method will need to be advised to provide those arguments to
the constructor.

=head2 _build_prologue

_build_prologue builds the coderef that calls run() on POE::Kernel by default.

=head2 _build_loader

_build_loader builds the coderef that is passed to the POE::Wheel::Run
constructor inside of Worker's child_wheel attribute builder. It creates a
closure around lexical references to init, preamble, main, and prologue, that
executes said coderefs in that order.

=head1 AUTHOR

  Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
