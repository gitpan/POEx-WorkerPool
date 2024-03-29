package POEx::WorkerPool::Error::StartError;
BEGIN {
  $POEx::WorkerPool::Error::StartError::VERSION = '1.102740';
}

#ABSTRACT: An error class indicating the Worker queue failed to start

use MooseX::Declare;

class POEx::WorkerPool::Error::StartError extends POEx::WorkerPool::Error {

}

1;


=pod

=head1 NAME

POEx::WorkerPool::Error::StartError - An error class indicating the Worker queue failed to start

=head1 VERSION

version 1.102740

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

This exception is thrown when a Worker is told to start processing its queue
but there are no items within the queue
