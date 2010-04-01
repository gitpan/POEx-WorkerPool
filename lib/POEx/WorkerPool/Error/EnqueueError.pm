package POEx::WorkerPool::Error::EnqueueError;
$POEx::WorkerPool::Error::EnqueueError::VERSION = '1.100910';

#ABSTRACT: An error class indicating problems enqueuing a job

use MooseX::Declare;

class POEx::WorkerPool::Error::EnqueueError extends POEx::WorkerPool::Error
{

}

1;


=pod

=head1 NAME

POEx::WorkerPool::Error::EnqueueError - An error class indicating problems enqueuing a job

=head1 VERSION

version 1.100910

=head1 DESCRIPTION

This exception is thrown when there are issues enqueuing a job for execution.

=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

