package POEx::WorkerPool::Role::Job;
BEGIN {
  $POEx::WorkerPool::Role::Job::VERSION = '1.102740';
}

#ABSTRACT: Provides a role for common job semantics

use MooseX::Declare;

role POEx::WorkerPool::Role::Job {
    use Try::Tiny;
    use Data::UUID;
    
    use MooseX::Types::Moose(':all');
    use MooseX::Types::Structured(':all');
    use POEx::WorkerPool::Types(':all');
    use POEx::WorkerPool::WorkerEvents(':all');
    use POEx::WorkerPool::Error::JobError;

    use aliased 'POEx::WorkerPool::Error::JobError';

    requires 'init_job';


    has ID => ( is => 'ro', isa => Str, lazy => 1, default => sub { Data::UUID->new()->create_str() } );


    has steps => 
    (
        traits => ['Array'],
        is => 'rw', 
        isa => ArrayRef[JobStep],
        default => sub { [] },
        handles => {
            _enqueue_step => 'push',
            dequeue_step => 'shift',
            count_steps => 'count',
        }
    );


    has total_steps => ( is => 'ro', isa => ScalarRef, lazy_build => 1 );
    method _build_total_steps { my $i = 0; \$i; }



    method enqueue_step(JobStep $step) {
        $self->_enqueue_step($step);
        ${$self->total_steps}++;
    }
    

    method is_multi_step returns (Bool) {
        return (${$self->total_steps} > 1);
    }


    method execute_step returns (JobStatus) {
        if($self->count_steps <= 0) {
            return { type => +PXWP_JOB_FAILED, ID => $self->ID, msg => \'Malformed job. No steps' };
        }
        
        try {
            my $step = $self->dequeue_step();
            my $val = $step->[0]->(@{$step->[1]});

            if($self->count_steps > 0) {
                return {
                    type => +PXWP_JOB_PROGRESS,
                    ID => $self->ID,
                    msg => \$val,
                    percent_complete => int(((${$self->total_steps} - $self->count_steps) / ${$self->total_steps}) * 100),
                };
            }
            else {
                return {
                    type => +PXWP_JOB_COMPLETE,
                    ID => $self->ID,
                    msg => \$val,
                };
            }
        }
        catch {
            my $error = $_;
            my $status = {
                type => +PXWP_JOB_FAILED,
                ID => $self->ID,
                msg => \$error
            };

            JobError->throw({ message => $error, job => $self, job_status => $status });
        }
    }
}

1;


=pod

=head1 NAME

POEx::WorkerPool::Role::Job - Provides a role for common job semantics

=head1 VERSION

version 1.102740

=head1 SYNOPSIS

    class MyJob with POEx::WorkerPool::Role::Job {
        method init_job {
            # Implement job initialization across the process boundary here
        }
    }

=head1 DESCRIPTION

POEx::WorkerPool::Role::Job provides the scaffolding required to execute
arbitrary tasks within the POEx::WorkerPool framework. Consuming classes only
need to implement init_job, which will be called once on the other side of the 
process boundary where coderefs, database handles, etc won't have survived.

Use init_job to initialize all of those ephemeral resources necessary for the
job and also to populate the steps to the job. 

=head1 PUBLIC_ATTRIBUTES

=head2 ID

 is: ro, isa: Str

This attribute stores the unique ID for the job. By default it uses 
Data::UUID::create_str()

=head2 steps 

 traits: Array, is: ro, isa: ArrayRef[JobStep]

This attribute stores the steps for the job. All jobs must have one step before
execution or else a JobError exception will be thrown.

The following handles are defined to access the steps of the job:
 {
        push    => '_enqueue_step',
        shift   => 'dequeue_step',
        count   => 'count_steps',
    }

=head1 PROTECTED_ATTRIBUTES

=head2 total_steps

 is: ro, isa: ScalarRef

 total_steps contains a scalar ref of the count of the total number of steps

=head1 PUBLIC_METHODS

=head2 enqueue_step

 (JobStep $step)

enqueue_step takes a JobStep and places it into the steps collection and also 
increments the total_steps counter.

=head2 is_multi_step 

 returns (Bool)

A simple convenience method to check if the job has multiple steps

=head2 execute_step 

 returns (JobStatus)

execute_step dequeues a step from steps and executes it, building a proper 
JobStatus return value. If executing the step produces an exception, the
exception class is JobError

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

