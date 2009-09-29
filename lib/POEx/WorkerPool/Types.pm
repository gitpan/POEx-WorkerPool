package POEx::WorkerPool::Types;
our $VERSION = '0.092720';



use warnings;
use strict;

#ABSTRACT: Type constraints for POEx::WorkerPool


use Moose::Util::TypeConstraints;
use MooseX::Types::Structured(':all');
use MooseX::Types::Moose(':all');
use POEx::WorkerPool::WorkerEvents(':all');

use MooseX::Types -declare =>
[
    'DoesWorker',
    'DoesWorkerPool',
    'DoesWorkerGuts',
    'DoesJob',
    'WorkerEvent',
    'JobStatus',
    'JobStep',
    'IsaError',
];



subtype DoesWorker,
    as 'Moose::Object',
    where { $_->does('POEx::WorkerPool::Role::WorkerPool::Worker') };


subtype DoesWorkerPool,
    as 'Moose::Object',
    where { $_->does('POEx::WorkerPool::Role::WorkerPool') };


subtype DoesWorkerGuts,
    as 'Moose::Object',
    where { $_->does('POEx::WorkerPool::Role::WorkerPool::Worker::Guts') };


subtype DoesJob,
    as 'Moose::Object',
    where { $_->does('POEx::WorkerPool::Role::Job') };


subtype WorkerEvent,
    as enum
    (
        [
            +PXWP_WORKER_CHILD_ERROR,
            +PXWP_WORKER_CHILD_EXIT,
            +PXWP_JOB_ENQUEUED,
            +PXWP_START_PROCESSING,
            +PXWP_JOB_DEQUEUED,
            +PXWP_STOP_PROCESSING,
            +PXWP_WORKER_INTERNAL_ERROR,
            +PXWP_JOB_COMPLETE,
            +PXWP_JOB_PROGRESS,
            +PXWP_JOB_FAILED,
            +PXWP_JOB_START,
            +PXWP_JOB_COMPLETE,
            +PXWP_WORKER_ERROR,
        ]
    );


subtype JobStatus,
    as Dict
    [
        type => WorkerEvent,
        ID => Str,
        msg => Ref,
        percent_complete => Maybe[Int]
    ],
    where
    {
        if($_->{type} eq +PXWP_JOB_PROGRESS)
        {
            return exists($_->{percent_complete}) && defined($_->{percent_complete});
        }

        return 1;
    };


subtype JobStep,
    as Tuple[CodeRef, ArrayRef];


subtype IsaError,
    as class_type('POEx::WorkerPool::Error');

1;



=pod

=head1 NAME

POEx::WorkerPool::Types - Type constraints for POEx::WorkerPool

=head1 VERSION

version 0.092720

=head1 DESCRIPTION

This module exports the type constrains needed for POEx::WorkerPool.

For importing options see MooseX::Types.



=head1 TYPES

=head2 DoesWorker

Must compose the POEx::WorkerPool::Role::WorkerPool::Worker role.



=head2 DoesWorkerPool

Must compose the POEx::WorkerPool::Role::WorkerPool role.



=head2 DoesWorkerGuts

Must compose the POEx::WorkerPool::Role::WorkerPool::Worker::Guts role.



=head2 DoesJob

Must compose the POEx::WorkerPool::Role::WorkerPool::Job role.



=head2 WorkerEvent

Must be one of the worker events defined in POEx::WorkerPool::WorkerEvents



=head2 JobStatus

JobStatus is what a Worker::Guts composed object must return. It consistes of 
a hash with three keys and potential forth depending on type. See below:

    {
        type => WorkerEvent,
        ID => Str,
        msg => Ref,
        percent_complete => Maybe[Int]
    }

percent_complete is only valid when type is +PXWP_JOB_PROGRESS



=head2 JobStep

When constructing Jobs, each step must match a Tuple[CodeRef, ArrayRef] where
the code ref is the actual thing to execute and the array ref is the collection
of arguments to be passed to the code ref verbatim.



=head2 IsaError

This is a convenience constraint that checks if the object inherits from Error



=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 



__END__
