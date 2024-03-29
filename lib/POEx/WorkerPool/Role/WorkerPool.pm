package POEx::WorkerPool::Role::WorkerPool;
BEGIN {
  $POEx::WorkerPool::Role::WorkerPool::VERSION = '1.102740';
}

#ABSTRACT: A role that provides common semantics for WorkerPools

use MooseX::Declare;

role POEx::WorkerPool::Role::WorkerPool {
    use Moose::Util::TypeConstraints;
    use MooseX::Types::Moose(':all');
    use POEx::WorkerPool::Types(':all');
    use POEx::Types(':all');
    
    use POEx::WorkerPool::Worker;
    use POEx::WorkerPool::Error::NoAvailableWorkers;

    use aliased 'POEx::WorkerPool::Worker';
    use aliased 'POEx::WorkerPool::Error::NoAvailableWorkers';


    has job_classes => ( is => 'ro', isa => ArrayRef[ClassName], required => 1);


    has options => ( is => 'ro', isa => HashRef );

    has queue_type => ( is => 'ro', isa => enum([qw|round_robin fill_up|]), default => 'round_robin');
    
    
    has max_workers => ( is => 'ro', isa => Int, default => 5 );
    

    has current_worker_index => ( is => 'rw', isa => ScalarRef, lazy_build => 1);
    method _build_current_worker_index { my $i = 0; \$i };



    has workers => 
    (
        is => 'ro',
        isa => ArrayRef[DoesWorker],
        lazy_build => 1,
    );
    method _build_workers {
        my $workers = [];

        for(0..$self->max_workers) {
            push
            (
                @$workers, 
                Worker->new
                (
                    job_classes => $self->job_classes,
                    max_jobs => $self->max_jobs_per_worker,
                    ($self->options ? (options => $self->options) : ()),
                ) 
            );
        }

        return $workers;
    }


    has max_jobs_per_worker => ( is => 'ro', isa => Int, default => 5 );

    method BUILDARGS (ClassName $class: @args) {
        my %retargs = @args;
        Class::MOP::load_class($_) for @{$retargs{job_classes}};
        return \%retargs;
    }


    method incr_worker_index returns (Int) {
        if(++${$self->current_worker_index} > $self->max_workers - 1) {
            $self->clear_current_worker_index();
        }
        
        return ${$self->current_worker_index};
    }


    method get_next_worker(Int $index?) returns (DoesWorker) {
        NoAvailableWorkers->throw({message => 'Iterated through all workers and none are available'}) 
            if defined($index) && $index == ${$self->current_worker_index};
        
        if($self->queue_type eq 'round_robin') {
            my $worker = $self->workers()->[$self->incr_worker_index];
            
            if($worker->is_active) {
                return $self->get_next_worker( defined($index) ? $index : ${$self->current_worker_index} );
            }
            else {
                return $worker;
            }
        }
        elsif($self->queue_type eq 'fill_up') {
            my $current = $self->workers()->[${$self->current_worker_index}];
            
            if($current->count_jobs < $current->max_jobs && $current->is_not_active) {
                return $current;
            }
            else {
                return $self->get_next_worker( defined($index) ? $index : $self->incr_worker_index );
            }
        }
    }


    method enqueue_job(DoesJob $job) returns (SessionAlias) {
        my $worker = $self->get_next_worker();
        $worker->enqueue_job($job);
        $worker->start_processing();
        return $worker->pubsub_alias;
    }


    method halt {
        $_->halt() for (@{$self->workers});
    }
}

1;


=pod

=head1 NAME

POEx::WorkerPool::Role::WorkerPool - A role that provides common semantics for WorkerPools

=head1 VERSION

version 1.102740

=head1 PUBLIC_ATTRIBUTES

=head2 job_classes

 is: ro, isa: ArrayRef[ClassName], required: 1

In order for the serializer on the other side of the process boundary to
rebless jobs on the other side, it needs to make sure that the classes are 
loaded.

This attribute is used to indicate which classes need to be loaded.

=head2 options

 is: ro, isa: HashRef

options is the same options that would be passed to Sessions. Setting trace to
1 will allow tracing for the Workers.

    POEx::WorkerPool->new(options => { trace => 1 });

=head2 queue_type

 is: ro, isa: enum([qw|round_robin fill_up|]), default: round_robin

This attribute specifies the queue type for the WorkerPool and changes how
workers are pulled from the pool

=head2 max_workers 

 is: ro, isa: Int, default: 5

This determines how many workers the Pool will spin up

=head2 current_worker_index

 is: rw, isa: ScalarRef

This stores the current index into workers. Dereference to manipulate the Int value.

=head2 workers

 is: ro, isa: ArrayRef[Worker]

This attribute holds all of the workers in the pool

=head2 max_jobs_per_worker

 is: ro, isa: Int, default: 5

This attribute let's the workers know how many jobs their queue can hold

=head1 PUBLIC_METHODS

=head2 incr_worker_index

 returns Int

This is a convenience method for incrementing the index and wrapping around
when it exceeds max_workers

=head2 get_next_worker

 returns (DoesWorker)

This returns the next worker in the pool as determined by the queue_type
attribute.

For round_robin, it will return the next immediate worker if isn't active.
fill_up will continue to return the same worker until its job queue is full.

If it is unable to return a suitable worker (all of the workers are currently
active or all of their job queues are full, etc), it will throw a
POEx::WorkerPool::Error::NoAvailableWorkers exception.

=head2 enqueue_job

 (DoesJob $job) returns (SessionAlias)

This method grabs the next available worker, enqueues the job, starts the
worker's queue processing and returns the worker's pubsub alias that can be 
used to subscribe to various events that the worker fires.

=head2 halt

This method will halt any active workers in the worker pool and force them to
release resouces and clean up.

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
