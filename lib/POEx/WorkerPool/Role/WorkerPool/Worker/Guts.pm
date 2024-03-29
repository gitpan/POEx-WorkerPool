package POEx::WorkerPool::Role::WorkerPool::Worker::Guts;
BEGIN {
  $POEx::WorkerPool::Role::WorkerPool::Worker::Guts::VERSION = '1.102740';
}

#ABSTRACT: A role that provides common semantics for Worker guts

use MooseX::Declare;

role POEx::WorkerPool::Role::WorkerPool::Worker::Guts {
    with 'POEx::Role::SessionInstantiation';
    
    use Try::Tiny;
    
    use POEx::Types(':all');
    use POEx::WorkerPool::Types(':all');
    use MooseX::Types::Moose(':all');
    
    use Data::UUID;
    use POE::Filter::Reference;
    use POE::Wheel::ReadWrite;
    
    use POEx::WorkerPool::Error::JobError;

    use POEx::WorkerPool::WorkerEvents(':all');

    use aliased 'POEx::Role::Event';
    use aliased 'POEx::WorkerPool::Error::JobError';
    
    # As of POE v1.266 Wheel::ReadWrite does not subclass from POE::Wheel. bleh
    has host => ( is => 'rw', isa => Object );


    after _start is Event {
        my $wheel = POE::Wheel::ReadWrite->new
        (   
            'InputHandle'   => \*STDIN,
            'OutputHandle'  => \*STDOUT,
            'Filter'        => POE::Filter::Reference->new(),
            'InputEvent'    => 'init_job',
        );

        $self->host($wheel);
        $self->poe->kernel->sig( 'DIE' => 'die_signal');
    }


    method init_job(DoesJob $job, WheelID $wheel) is Event {
        try {
            $job->init_job();
            $self->yield('send_message', { ID => $job->ID, type => +PXWP_JOB_START, msg => \time() });
            $self->yield('process_job', $job);
            return $job;
        }
        catch {
            my $err = $_;
            $self->call($self, 'send_message', { ID => $job->ID, type => +PXWP_JOB_FAILED, msg => \$err, } );
        }
    }


    method process_job(DoesJob $job) is Event {
        try {
            my $status = $job->execute_step();
            die "No Status" if not is_JobStatus($status);
            $self->yield('send_message', $status);
            
            if($job->count_steps > 0) {
                $self->yield('process_job', $job);
            }

            return $status;
        }
        catch {
            my $err = $_;

            if(is_IsaError($err))
            {
                $self->call($self, 'send_message', $err->job_status);
            }
            else
            {
                $self->call($self, 'send_message', { ID => $job->ID, type => +PXWP_JOB_FAILED, msg => \$err } );
            }
        }
    }


    method send_message(JobStatus $status) is Event {
        if(!defined($self->host)) {
            die "Unable to communicate with the host";
        }

        $self->host()->put($status);
    }


    method die_signal(Str $signal, HashRef $stuff) is Event {
        $self->call($self, 'send_message', { ID => 0, type => +PXWP_WORKER_INTERNAL_ERROR, msg => $stuff });
    }
}

1;


=pod

=head1 NAME

POEx::WorkerPool::Role::WorkerPool::Worker::Guts - A role that provides common semantics for Worker guts

=head1 VERSION

version 1.102740

=head1 PUBLIC_METHODS

=head2 process_job

 (DoesJob $job) is Event

process_job takes the initialized job and calls ->execute_step on the job. If
there is more than one step, another process_job will be queued up via POE with
the same job as the argument. Each step along the way returns a JobStatus which
is then sent on to send_message which communicates with the parent process

=head2 send_message

 (JobStatus $status) is Event

send_messge communicates with the parent process each JobStatus it receives.

=head1 PROTECTED_METHODS

=head2 after _start

 is Event

_start is advised to buid the communication wheel back to the parent process
and also register a signal handler for DIE so we can communicate exceptions
back to the parent

=head2 init_job

 (DoesJob $job, WheelID $wheel) is Event

init_job is the InputEvent on the ReadWrite wheel that accepts input from the
parent process. It attempts to call ->init_job on the job it receives. If that
is successful it will then proceed on to send a return message of PXWP_JOB_START
and yield to process_job()

=head2 die_signal

 (Str $signal, HashRef $stuff) is Event

die_signal is our signal handler if something unexpected happens.

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
