package POEx::WorkerPool::Error::NoAvailableWorkers;
our $VERSION = '0.092650';


#ABSTRACT: An error class indicating that no workers are available

use MooseX::Declare;

class POEx::WorkerPool::Error::NoAvailableWorkers extends POEx::WorkerPool::Error
{

}

1;



=pod

=head1 NAME

POEx::WorkerPool::Error::NoAvailableWorkers - An error class indicating that no workers are available

=head1 VERSION

version 0.092650

=head1 DESCRIPTION

This exception class is thrown when attempting to enqueue a job but there are
no workers available (either all are active, or have full job queues)

=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut 



__END__

