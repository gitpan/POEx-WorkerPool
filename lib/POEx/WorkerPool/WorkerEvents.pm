package POEx::WorkerPool::WorkerEvents;
our $VERSION = '0.092450';


#ABSTRACT: Exported event symbols for WorkerPool

use warnings;
use strict;

use Moose;

use constant
{
    PXWP_WORKER_CHILD_ERROR     => 'PXWP_WORKER_CHILD_ERROR',
    PXWP_WORKER_CHILD_EXIT      => 'PXWP_WORKER_CHILD_EXIT',
    PXWP_JOB_ENQUEUED           => 'PXWP_JOB_ENQUEUED',
    PXWP_START_PROCESSING       => 'PXWP_START_PROCESSING',
    PXWP_JOB_DEQUEUED           => 'PXWP_JOB_DEQUEUED',
    PXWP_STOP_PROCESSING        => 'PXWP_STOP_PROCESSING',
    PXWP_WORKER_INTERNAL_ERROR  => 'PXWP_WORKER_INTERNAL_ERROR',
    PXWP_JOB_COMPLETE           => 'PXWP_JOB_COMPLETE',
    PXWP_JOB_PROGRESS           => 'PXWP_JOB_PROGRESS',
    PXWP_JOB_FAILED             => 'PXWP_JOB_FAILED',
    PXWP_JOB_START              => 'PXWP_JOB_START',
};

use Sub::Exporter -setup => 
{ 
    exports => 
    [ 
        qw/ 
            PXWP_WORKER_CHILD_ERROR
            PXWP_WORKER_CHILD_EXIT
            PXWP_JOB_ENQUEUED
            PXWP_START_PROCESSING
            PXWP_JOB_DEQUEUED
            PXWP_STOP_PROCESSING
            PXWP_WORKER_INTERNAL_ERROR
            PXWP_JOB_COMPLETE
            PXWP_JOB_PROGRESS
            PXWP_JOB_FAILED
            PXWP_JOB_START
        /
    ] 
};


1;



=pod

=head1 NAME

POEx::WorkerPool::WorkerEvents - Exported event symbols for WorkerPool

=head1 VERSION

version 0.092450

=head1 DESCRIPTION

This modules exports the needed symbols for subscribing to a Workers associated
PubSub events. See POEx::WorkerPool::Role::WorkerPool::Worker for more details
on signatures required for each event

=head1 EXPORTS

    PXWP_WORKER_CHILD_ERROR
    PXWP_WORKER_CHILD_EXIT
    PXWP_JOB_ENQUEUED
    PXWP_START_PROCESSING
    PXWP_JOB_DEQUEUED
    PXWP_STOP_PROCESSING
    PXWP_WORKER_INTERNAL_ERROR
    PXWP_JOB_COMPLETE
    PXWP_JOB_PROGRESS
    PXWP_JOB_FAILED
    PXWP_JOB_START
    PXWP_JOB_COMPLETE



=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 



__END__


