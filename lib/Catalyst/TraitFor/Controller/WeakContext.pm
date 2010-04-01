use strict;
use warnings;

# ABSTRACT: Make actions receive a weak proxy to the context object

package Catalyst::TraitFor::Controller::WeakContext;
use Moose::Role;

use Object::WeakProxy qw( weak_proxy );

use namespace::autoclean;

around create_action => sub {
    my ($orig, $self, %args) = @_;

    my $orig_code = delete $args{code};

    return $self->$orig(
        %args,
        code => sub {
            my ($ctrl, $ctx, @rest) = @_;

            return $ctrl->$orig_code(weak_proxy($ctx), @rest);
        },
    );
};

1;

__END__

=head1 SYNOPSIS

    package MyController;
    use Moose;
    BEGIN { extends 'Catalyst::Controller' }

    with 'Catalyst::TraitFor::Controller::WeakContext';

    sub foo: Chained('/') {
        my ($self, $ctx) = @_;

        # no leaking $ctx!
        $ctx->stash(uri_for_profile => sub {
            my ($username) = @_;
            $ctx->uri_for_action('/profile/view', $username);
        });
    }

=head1 DESCRIPTION

This controller trait will wrap all action callbacks and switch the context out
for a weakly proxied version via L<Object::WeakProxy>.

This means that you can safely reference the passed object in data structures
and closures you want to stash without worrying about cyclic references and
resulting leakages.

=head1 SEE ALSO

L<Object::WeakProxy>

=method create_action

This method is modified to allow interception of the context object. The actual
code reference will receive a proxy object created with L<Object::WeakProxy>
instead.

=cut
