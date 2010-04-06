package POEx::WorkerPool::Worker::Guts;
BEGIN {
  $POEx::WorkerPool::Worker::Guts::VERSION = '1.100960';
}

#ABSTRACT: A generic sub process implementation for Worker

use MooseX::Declare;

class POEx::WorkerPool::Worker::Guts
{
    with 'MooseX::CompileTime::Traits';
    with 'POEx::WorkerPool::Role::WorkerPool::Worker::Guts';
}

1;


=pod

=head1 NAME

POEx::WorkerPool::Worker::Guts - A generic sub process implementation for Worker

=head1 VERSION

version 1.100960

=head1 DESCRIPTION

This is only a shell of a class. For details on available methods and 
attributes please see POEx::WorkerPool::Role::WorkerPool::Worker::Guts

=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

