package POEx::WorkerPool::Role::WorkerPool::Worker;
our $VERSION = '0.092461';


#ABSTRACT: A role that provides common semantics for Workers

use MooseX::Declare;

role POEx::WorkerPool::Role::WorkerPool::Worker
{
    with 'POEx::Role::SessionInstantiation';
  
    use MooseX::Types::Moose(':all');
    use MooseX::Types::Structured(':all');
    use POEx::Types(':all');
    use POEx::WorkerPool::Types(':all');
    use POEx::WorkerPool::WorkerEvents(':all');

    use Data::UUID;
    use POEx::PubSub;
    use POE::Filter::Reference;
    use POE::Wheel::Run;

    use POEx::WorkerPool::Worker::Guts;
    
    use POEx::WorkerPool::Error::EnqueueError;
    use POEx::WorkerPool::Error::StartError;
    use POEx::WorkerPool::Error::JobError;

    use aliased 'POEx::WorkerPool::Role::Job';
    use aliased 'POEx::WorkerPool::Error::EnqueueError';
    use aliased 'POEx::WorkerPool::Error::StartError';
    use aliased 'POEx::WorkerPool::Error::JobError';
    use aliased 'POEx::Role::Event';


    has job_class => ( is => 'ro', isa => ClassName, required => 1);


    has uuid => ( is => 'ro', isa => Str, lazy => 1, default => sub { Data::UUID->new()->create_str() } );


    has pubsub_alias => ( is => 'ro', isa => Str, lazy_build => 1);
    method _build_pubsub_alias { 'Worker-PubSub:'.$self->uuid }


    has status => ( is => 'rw', isa => Bool, default => 0 );


    method is_not_active { return ( $self->status == 0 ) }
    method is_active { return ( $self->status == 1) }


    has _in_process => ( is => 'rw', isa => DoesJob, clearer => '_clear_in_process'); 


    has _completed_jobs => ( is => 'rw', isa => ScalarRef, lazy_build => 1 );
    method _build__completed_jobs { my $i = 0; \$i }

    has _failed_jobs => ( is => 'rw', isa => ScalarRef, lazy_build => 1 );
    method _build__failed_jobs { my $i = 0; \$i }


    has jobs => 
    (
        metaclass => 'Collection::Array',
        is => 'ro', 
        isa => ArrayRef[DoesJob], 
        default => sub { [] },
        provides =>
        {
            push    => '_enqueue_job',
            shift   => '_dequeue_job',
            count   => 'count_jobs',
        }
    );


    has max_jobs => ( is => 'ro', isa => Int, default => 5 );


    has child_wheel => ( is => 'ro', isa => Wheel, lazy_build => 1 );
    method _build_child_wheel
    {
        my $class = $self->job_class;
        my $wheel = POE::Wheel::Run->new
        (
            Program => sub 
            {
                use Class::MOP;
                # this little Kernel dance is required to get POE running in
                # the subprocess and allow easy communication
                POE::Kernel->stop();
                
                Class::MOP::load_class($class);
                POEx::WorkerPool::Worker::Guts->new();

                POE::Kernel->run();
            },
            StdioFilter => POE::Filter::Reference->new(),
            StdoutEvent => 'guts_output',
            ErrorEvent  => 'guts_error_handler',
        ) or Carp::confess('WTF?');

        $self->poe->kernel->sig_child($wheel->PID, 'guts_exited');
        return $wheel;
    }


    method guts_error_handler(Str $op, Int $error_num, Str $error_str, WheelID $id, Str $handle_name) is Event
    {
        $self->post
        (
            $self->pubsub_alias, +PXWP_WORKER_CHILD_ERROR,
            worker_id => $self->ID,
            operation => $op,
            error_number => $error_num,
            error_string => $error_str,
            wheel_id => $id,
            handle_name => $handle_name,
        );
        
        $self->child_wheel()->kill();
    }


    method guts_exited(Str $chld, Int $pid, Int $exit_val) is Event
    {
        $self->post
        (
            $self->pubsub_alias, +PXWP_WORKER_CHILD_EXIT, 
            worker_id => $self->ID,
            process_id => $pid,
            exit_value => $exit_val
        );

        $self->clear_child_wheel();
    }


    after _start is Event
    {
        my $alias = $self->pubsub_alias;
        POEx::PubSub->new(alias => $alias);

        $self->call($alias, 'publish', event_name => +PXWP_WORKER_CHILD_ERROR);
        $self->call($alias, 'publish', event_name => +PXWP_WORKER_CHILD_EXIT);
        $self->call($alias, 'publish', event_name => +PXWP_JOB_ENQUEUED);
        $self->call($alias, 'publish', event_name => +PXWP_START_PROCESSING);
        $self->call($alias, 'publish', event_name => +PXWP_JOB_DEQUEUED);
        $self->call($alias, 'publish', event_name => +PXWP_STOP_PROCESSING);
        $self->call($alias, 'publish', event_name => +PXWP_WORKER_INTERNAL_ERROR);
        $self->call($alias, 'publish', event_name => +PXWP_JOB_COMPLETE);
        $self->call($alias, 'publish', event_name => +PXWP_JOB_PROGRESS);
        $self->call($alias, 'publish', event_name => +PXWP_JOB_FAILED);
        $self->call($alias, 'publish', event_name => +PXWP_JOB_START);

        $self->alias('Worker:'.$self->uuid);

        $self->child_wheel();
    }


    after _stop is Event
    {
        $self->call($self->pubsub_alias, 'destroy');
    }


    method enqueue_job(DoesJob $job) is Event
    {
        my $kernel = defined($self->poe->kernel) ? $self->poe->kernel : 'POE::Kernel';
        
        if($self->is_active)
        {
            EnqueueError->throw({message => 'Queue is currently active'});
        }
        
        if($self->count_jobs != $self->max_jobs)
        {
            $self->_enqueue_job($job);
            
            $kernel->post
            (
                $self->pubsub_alias, +PXWP_JOB_ENQUEUED, 
                worker_id => $self->ID,
                job_id => $job->ID,
            );
        }
        else
        {
            EnqueueError->throw({message => 'Queue is full'});
        }
    }


    method enqueue_jobs(ArrayRef[DoesJob] $jobs) is Event
    {
        my $kernel = defined($self->poe->kernel) ? $self->poe->kernel : 'POE::Kernel';
        
        if(($self->count_jobs + @$jobs) <= $self->max_jobs)
        {
            map 
            {
                $self->_enqueue_job($_); 
                $kernel->post
                (
                    $self->pubsub_alias, +PXWP_JOB_ENQUEUED, 
                    worker_id => $self->ID,
                    job_id => $_->ID,
                );
            }
            @$jobs;
        }
        else
        {
            EnqueueError->throw({message => 'Too many jobs'});
        }
    }


    method start_processing is Event
    {
        my $kernel = defined($self->poe->kernel) ? $self->poe->kernel : 'POE::Kernel';
        
        if($self->count_jobs < 1)
        {
            StartError->throw({message => 'No jobs in queue' });
        }
        
        $kernel->post
        (
            $self->pubsub_alias, +PXWP_START_PROCESSING, 
            worker_id => $self->ID,
            count_jobs => $self->count_jobs,
        );
        
        $self->status(1);
        $kernel->post($self->ID, '_process_queue');
    }


    method _process_queue is Event
    {
        my $job = $self->_dequeue_job();
        
        if(defined($job))
        {
            $self->post
            (
                $self->pubsub_alias, +PXWP_JOB_DEQUEUED, 
                worker_id => $self->ID,
                job_id => $job->ID,
            );
            
            $self->yield('_process_job', $job);
        }
        else
        {
            $self->post
            (
                $self->pubsub_alias, +PXWP_STOP_PROCESSING,
                worker_id => $self->ID,
                completed_jobs => ${$self->_completed_jobs},
                failed_jobs => ${$self->_failed_jobs},
            );

            $self->status(0);
            $self->_clear_completed_jobs();
            $self->_clear_failed_jobs();
        }
    }


    method _process_job(DoesJob $job) is Event
    {
        if(!defined($self->child_wheel))
        {
            $self->post
            (
                $self->pubsub_alias, +PXWP_WORKER_INTERNAL_ERROR, 
                worker_id => $self->ID,
                msg => \'Child process was null',
            );

            return;
        }
        
        $self->_in_process($job);
        $self->child_wheel->put($job);
    }


    method guts_output(JobStatus $job_status, WheelID $id) is Event
    {
        if($job_status->{type} eq +PXWP_JOB_COMPLETE)
        {
            $self->_clear_in_process();
            ${$self->_completed_jobs}++;

            $self->post
            (
                $self->pubsub_alias, +PXWP_JOB_COMPLETE,
                worker_id => $self->ID,
                job_id => $job_status->{ID},
                msg => $job_status->{msg},
            );

            $self->yield('_process_queue');
        }
        elsif($job_status->{type} eq +PXWP_JOB_PROGRESS)
        {
            $self->post
            (
                $self->pubsub_alias, +PXWP_JOB_PROGRESS,
                worker_id => $self->ID,
                job_id => $job_status->{ID},
                percent_complete => $job_status->{percent_complete},
                msg => $job_status->{msg},
            );
        }
        elsif($job_status->{type} eq +PXWP_JOB_FAILED)
        {
            $self->_clear_in_process();
            
            ${$self->_failed_jobs}++;
            
            $self->post
            (
                $self->pubsub_alias, +PXWP_JOB_FAILED,
                worker_id => $self->ID,
                job_id => $job_status->{ID},
                msg => $job_status->{msg},
            );
            
            $self->yield('_process_queue');
        }
        elsif($job_status->{type} eq +PXWP_JOB_START)
        {
            $self->post
            (
                $self->pubsub_alias, +PXWP_JOB_START, 
                worker_id => $self->ID,
                job_id => $job_status->{ID},
            );
        }
        else
        {
            JobError->throw({message => 'Unknown job status', job => $self->_in_process, job_status => $job_status});
        }
    }


    method halt is Event
    {
        POE::Kernel->sig_child($self->child_wheel->PID);
        $self->child_wheel->kill();
        $self->clear_alias();
    }
}

1;




=pod

=head1 NAME

POEx::WorkerPool::Role::WorkerPool::Worker - A role that provides common semantics for Workers

=head1 VERSION

version 0.092461

=head1 ATTRIBUTES

=head2 job_class is: ro, isa: ClassName, required: 1

In order for the serializer on the other side of the process boundary to
rebless jobs on the other side, it needs to make sure that class is loaded.

This attribute is used to indicate which class needs to be loaded.



=head2 uuid is: ro, isa: Str

This attribute holds the basis for the aliases for the Worker and its PubSub.
It defaults to Data::UUID->new()->create_str()



=head2 pubsub_alias is: ro, isa: Str

This is holds the alias to the associated PubSub component for this Worker



=head2 status is: rw, isa: Bool

status indicates whether the Worker is currently processing its queue.



=head2 _in_process is: rw, isa: DoesJob

This private attribute holds the currently processing Job



=head2 _completed_jobs is: rw, isa: ScalarRef

This private attribute is a counter to the number of completed jobs this 
current processing cycle.



=head2 _failed_jobs is: rw, isa: ScalarRef

This private attribute is a counter to the number of failed jobs this 
current processing cycle.



=head2 metaclass: Collection::Array, is: ro, isa: ArrayRef[DoesJob]

This is the FIFO queue of jobs this worker is responsible for processing.

The following provides are defined:

    {
        push    => '_enqueue_job',
        shift   => '_dequeue_job',
        count   => 'count_jobs',
    }



=head2 max_jobs is: ro, isa: Int

This determines the fill mark for the job queue.



=head2 child_wheel is: ro, isa: Wheel

child_wheel holds this Worker's POE::Wheel::Run instance



=head1 METHODS

=head2 is_[not_]active

These are convinence methods for checking the status of the Worker




=head2 guts_error_handler(Str $op, Int $error_num, Str $error_str, WheelID $id, Str $handle_name) is Event

guts_error_handler is the handler given to POE::Wheel::Run to handle errors
that may crop up during operation of the wheel. It will post the arguments via
+PXPW_WORKER_CHILD_ERROR using PubSub.

Subscribers will need the following signature:

    method handler
    (
        SessionID :$worker_id, 
        Str :$operation, 
        Int :$error_number, 
        Str :$error_string, 
        WheelID :$wheel_id, 
        Str :$handle_name
    ) is Event

This method will then issue a SIGTERM signal to the child process forcing it
to rebuild after exiting



=head2 guts_exited(Str $chld, Int $pid, Int $exit_val) is Event

This is the SIGCHLD handler for the child process. It will post the arguments
via +PXWP_WORKER_CHILD_EXIT using PubSub.

Subscribers will need to have the following signature:

    method handler
    (
        SessionID :$worker_id, 
        Int :$process_id, 
        Int :$exit_value
    ) is Event

The wheel will then cleared 



=head2 after _start is Event

_start is advised to create a new PubSub component specific for this Worker and
publish all of the various events that the Worker can fire.



=head2 after _stop is Event

_stop is advised to terminate the associated PubSub component by calling its
destroy event.



=head2 enqueue_job(DoesJob $job)

enqueue_job takes an object with the Job role and places it into the queue
after a few basic checks, such as if the Worker is currently processing or if
the job queue has met the max_jobs limitation. If either case is true, an
EnquueuError is thrown.

This method fires +PXWP_JOB_ENQUEUED to the associated PubSub component on
success.

Subscribers will need to have the following signature:

    method handler (SessionID :$worker_id, Str $job_id) is Event



=head2 enqueue_jobs(ArrayRef[DoesJob] $jobs)

enqueue_jobs does the same thing as enqueue_job, but it acts on an array of
jobs. Each job successfully enqueued means the worker will fire the 
+PXWP_JOB_ENQUEUED event via PubSub.



=head2 start_processing

start_processing kicks the Worker into gear and prevents adding jobs until the
crrent queue has been processed. If there are no jobs in the queue, StartError
will be thrown. This method fires the +PXWP_START_PROCESSING event via PubSub.

Subscribers should have the following signature:

    method handler (SessionID :$worker_id, Int :$count_jobs)



=head2 _process_queue is Event

This private event is the queue processor. As jobs are dequeued for processing,
+PXWP_JOB_DEQUEUED will be fired via PubSub. Subscribers will need the
following signature:

    method handler(SessionID :$worker_id, Str :$job_id) is Event

Once the queue has been depleted +PXWP_STOP_PROCESSING will be fired via
PubSub. Subscribers will need the following signature:

    method handler
    (
        SessionID :$worker_id,
        Int :$completed_jobs,
        Int :$failed_jobs
    ) is Event

Then the run stats will be cleared, and the status will be toggled so that the
Worker may again accept jobs.



=head2 _process_job(DoesJob $job) is Event

This private event takes the given job and feeds it to the child process to be
processed. If the child process doesn't exist for whatever reason, 
+PXWP_WORKER_INTERNAL_ERROR will be fired via PubSub. Subscribers need the 
following signature:

    method handler(SessionID :$worker_id, Ref :$msg)

This event also places the given job into the _in_process attribute.



=head2 guts_output(JobStatus $job_status) is Event

This is the StdoutEvent for the child POE::Wheel::Run. It handles all of the
child output which is in the form of JobStatus hashrefs. The following 
describes the potential events from the child and the actions taken

    Type: 
        +PXWP_JOB_COMPLETE

    Action: 
        _in_process is cleared and _completed_jobs for this session is
        incremented. yields() to _process_queue.

    PubSub Event:
        +PXWP_JOB_COMPLETE

    PubSub Signature:
        method handler(SessionID :$worker_id, Str :$job_id, Ref :$msg)

    Notes:
        The :$msg argument will contain the output from the Job's execution

    Type: 
        +PXWP_JOB_PROGRESS

    Action: 
        PubSub event posted.

    PubSub Event:
        +PXWP_JOB_COMPLETE

    PubSub Signature:
        method handler
        (
            SessionID :$worker_id, 
            Str :$job_id, 
            Int :$percent_complete,
            Ref :$msg,
        )

    Notes:
        The :$msg argument will contain the output from the last step executed
        for multi-step jobs

    Type: 
        +PXWP_JOB_FAILED

    Action: 
        _in_process is cleared and _failed_jobs for this session is
        incremented. yields() to _process_queue.

    PubSub Event:
        +PXWP_JOB_FAILED

    PubSub Signature:
        method handler(SessionID :$worker_id, Str :$job_id, Ref :$msg)

    Notes:
        The :$msg argument will contain the exception generated from the Job

    Type: 
        +PXWP_JOB_START

    Action: 
        PubSub event posted.

    PubSub Event:
        +PXWP_JOB_START

    PubSub Signature:
        method handler
        (
            SessionID :$worker_id, 
            Str :$job_id, 
        )

    Notes:
        This is an indication that the child process received the Job and is
        beginning execution.

    


=head2 halt is Event

halt will destroy the child process, and unset the associated alias ensuring 
that the Session will stop



=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 



__END__
