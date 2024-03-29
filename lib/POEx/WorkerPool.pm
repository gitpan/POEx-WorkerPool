package POEx::WorkerPool;
BEGIN {
  $POEx::WorkerPool::VERSION = '1.102740';
}

#ABSTRACT: A generic multiprocess worker pool for the POE framework

use MooseX::Declare;

class POEx::WorkerPool {
    with 'MooseX::CompileTime::Traits';
    with 'POEx::WorkerPool::Role::WorkerPool';
}

1;


=pod

=head1 NAME

POEx::WorkerPool - A generic multiprocess worker pool for the POE framework

=head1 VERSION

version 1.102740

=head1 SYNOPSIS

    use POE;
    use MooseX::Declare;

    class MyJob with POEx::WorkerPool::Role::Job {
        # this method is executed across the process boundary
        method init_job {
            # Multi step jobs are supported and even reported on, so just keep 
            # enqueuing steps

            $self->enqueue_step
            (
                [
                    sub { # do some work here },
                    [qw/ some arguments for the above sub/]
                ]
            )
        }
    }

    class NeedsParallelJobExecution {
        with 'POEx::Role::SessionInstantiation';
        use aliased 'POEx::Role::Event';
        
        use POEx::WorkerPool::Types(':all');
        use POEx::WorkerPool::WorkerEvents(':all');

        use POEx::WorkerPool;

        has pool => ( is => 'ro', isa => DoesWorkerPool, lazy_build => 1 );
        method _build_pool { POEx::WorkerPool->new() }

        after _start is Event {
            for(0..4) {
                # we get back the alias of the worker with which our job was 
                # enqueued

                my $alias = $self->pool->enqueue_job(MyJob->new());

                # we can subscribe to all sorts of events that the worker
                # generates but for the simple case, we just want to know our
                # jobs are done
                #
                # See POEx::PubSub for more information

                $self->post
                (
                    $alias, 'subscribe', 
                    event_name => +PXWP_JOB_COMPLETE,
                    event_handler => 'job_complete',
                );
            }
        }

        method job_complete (SessionID :$worker_id, Str :$job_id, Ref :$msg) is Event {
            print "Worker($worker_id) finished Job($job_id)\n";
        }
    }

    my $thing = NeedsParallelJobExecution->new();
    POE::Kernel->run();

=head1 DESCRIPTION

POEx::WorkerPool provides a multi-process framework for job execution. It makes
use of modern Perl tools including MooseX::Declare and also modern POE
facilities such as POEx::PubSub.

It is also highly extensible through the 'use' statement arguments in that 
custom roles can be supplied via the 'traits' argument and they will be 
consumed at compile time. The implementation details for each piece of this 
framework are actually all within the default roles that get consumed by the
classes. This allow easy consumption and composition in other projects.

To understand what methods and attributes are available for each piece, please
apply s/POEx::/POEx::WorkerPool::Role::/ to the class names.

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

