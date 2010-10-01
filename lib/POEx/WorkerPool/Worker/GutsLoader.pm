package POEx::WorkerPool::Worker::GutsLoader;
BEGIN {
  $POEx::WorkerPool::Worker::GutsLoader::VERSION = '1.102740';
}

#ABSTRACT: A Loader implementation for Worker::Guts

use MooseX::Declare;

class POEx::WorkerPool::Worker::GutsLoader {
    with 'MooseX::CompileTime::Traits';
    with 'POEx::WorkerPool::Role::WorkerPool::Worker::GutsLoader';
}

1;


=pod

=head1 NAME

POEx::WorkerPool::Worker::GutsLoader - A Loader implementation for Worker::Guts

=head1 VERSION

version 1.102740

=head1 DESCRIPTION

This is only a shell of a class. For details on available methods and 
attributes please see POEx::WorkerPool::Role::WorkerPool::Worker::GutsLoader

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

