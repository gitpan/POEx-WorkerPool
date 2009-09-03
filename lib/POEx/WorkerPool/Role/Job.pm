package POEx::WorkerPool::Role::Job;
our $VERSION = '0.092460';


#ABSTRACT: Provides a role for common job semantics

use MooseX::Declare;

role POEx::WorkerPool::Role::Job
{
    use TryCatch;
    use Data::UUID;
    use MooseX::AttributeHelpers;
    
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
        metaclass => 'Collection::Array',
        is => 'rw', 
        isa => ArrayRef[JobStep],
        default => sub { [] },
        provides =>
        {
            push    => '_enqueue_step',
            shift   => 'dequeue_step',
            count   => 'count_steps',
        }
    );

    has total_steps => ( is => 'rw', isa => ScalarRef, lazy_build => 1 );
    method _build_total_steps { my $i = 0; \$i; }



    method enqueue_step(JobStep $step)
    {
        $self->_enqueue_step($step);
        ${$self->total_steps}++;
    }
    

    method is_multi_step returns (Bool)
    {
        return (${$self->total_steps} > 1);
    }

    method execute_step returns (JobStatus)
    {
        my $status;

        if($self->count_steps <= 0)
        {
            $status =
            {
                type => +PXWP_JOB_FAILED,
                ID => $self->ID,
                msg => \'Malformed job. No steps',
            };

            return $status;
        }
        

        my $step = $self->dequeue_step();
        my $val;

        try
        {
            $val = $step->[0]->(@{$step->[1]});
            if($self->count_steps > 0)
            {
                $status =
                {
                    type => +PXWP_JOB_PROGRESS,
                    ID => $self->ID,
                    msg => \$val,
                    percent_complete => int(((${$self->total_steps} - $self->count_steps) / ${$self->total_steps}) * 100),
                };
            }
            else
            {
                $status =
                {
                    type => +PXWP_JOB_COMPLETE,
                    ID => $self->ID,
                    msg => \$val,
                };
            }
        }
        catch ($error)
        {
            $status =
            {
                type => +PXWP_JOB_FAILED,
                ID => $self->ID,
                msg => \$error
            };
        }

        return $status;
    }
}

1;



=pod

=head1 NAME

POEx::WorkerPool::Role::Job - Provides a role for common job semantics

=head1 VERSION

version 0.092460

=head1 SYNOPSIS

class MyJob with POEx::WorkerPool::Role::Job
{
    method init_job
    {
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

=head1 ATTRIBUTES

=head2 ID is: ro, isa: Str

This attribute stores the unique ID for the job. By default it uses 
Data::UUID::create_str()



=head2 steps metaclass: Collection::Array, is: ro, isa: ArrayRef[JobStep]

This attribute stores the steps for the job. All jobs must have one step before
execution or else a JobError exception will be thrown.

The following provides are defined to access the steps of the job:

    {
        push    => '_enqueue_step',
        shift   => 'dequeue_step',
        count   => 'count_steps',
    }



=head1 METHODS

=head2 enqueue_step(JobStep $step)

enqueue_step takes a JobStep and places it into the steps collection and also 
increments the total_steps counter.



=head2 is_multi_step returns (Bool)

A simple convenience method to check if the job has multiple steps



=head2 execute_step returns (JobStatus)

execute_step dequeues a step from steps and executes it, building a proper 
JobStatus return value. 



=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 



__END__

