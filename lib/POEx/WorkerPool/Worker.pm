package POEx::WorkerPool::Worker;
BEGIN {
  $POEx::WorkerPool::Worker::VERSION = '1.101610';
}

#ABSTRACT: A generic worker class for WorkerPool

use MooseX::Declare;

class POEx::WorkerPool::Worker
{
    with 'MooseX::CompileTime::Traits';
    with 'POEx::WorkerPool::Role::WorkerPool::Worker';
}

1;


=pod

=head1 NAME

POEx::WorkerPool::Worker - A generic worker class for WorkerPool

=head1 VERSION

version 1.101610

=head1 DESCRIPTION

This is only a shell of a class. For details on available methodsand attributes
please see POEx::WorkerPool::Role::WorkerPool::Worker

=head1 AUTHOR

  Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

