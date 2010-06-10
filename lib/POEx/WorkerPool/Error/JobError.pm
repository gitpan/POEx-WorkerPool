package POEx::WorkerPool::Error::JobError;
BEGIN {
  $POEx::WorkerPool::Error::JobError::VERSION = '1.101610';
}

#ABSTRACT: An error class indicating something failed with the job

use MooseX::Declare;

class POEx::WorkerPool::Error::JobError extends POEx::WorkerPool::Error
{
    use POEx::WorkerPool::Types(':all');


    has job => ( is => 'ro', isa => DoesJob, required => 1 ); 
    
    
    has job_status => ( is => 'ro', isa => JobStatus, required => 1 ); 
}

1;


=pod

=head1 NAME

POEx::WorkerPool::Error::JobError - An error class indicating something failed with the job

=head1 VERSION

version 1.101610

=head1 DESCRIPTION

This exception is thrown when there is an irrecoverable error with a job

=head1 PUBLIC_ATTRIBUTES

=head2 job 

 is: ro, isa: DoesJob

This contains the job that errored

=head2 job_status 

 is:ro, isa: JobStatus

This contains the useful information captured from the try block around the job
during execution of the previous step

=head1 AUTHOR

  Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

