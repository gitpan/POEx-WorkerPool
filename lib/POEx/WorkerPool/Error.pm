package POEx::WorkerPool::Error;
BEGIN {
  $POEx::WorkerPool::Error::VERSION = '1.100960';
}

use MooseX::Declare;

#ABSTRACT: Error class for WorkerPool using Throwable

class POEx::WorkerPool::Error with Throwable
{
    use MooseX::Types::Moose(':all');


    has message => ( is => 'ro', isa => Str, required => 1);
}

1;



=pod

=head1 NAME

POEx::WorkerPool::Error - Error class for WorkerPool using Throwable

=head1 VERSION

version 1.100960

=head1 DESCRIPTION

This is mostly a base class for other exeptions within POEx::WorkerPool.

Please see any of the following for more information:

    POEx::WorkerPool::Error::EnqueueError
    POEx::WorkerPool::Error::JobError
    POEx::WorkerPool::Error::NoAvailableWorkers
    POEx::WorkerPool::Error::StartError

=head1 PUBLIC_ATTRIBUTES

=head2 message is: ro, isa: Str, required: 1

A human readable error message

=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

