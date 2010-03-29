package TestApp::Controller::Foo;
use Moose;
BEGIN { extends 'Catalyst::Controller' }

use Scalar::Util::Refcount qw( refcount );

use namespace::autoclean;

with 'Catalyst::TraitFor::Controller::WeakContext';

our $REFCHECK = [];

sub refcheck { refcount $REFCHECK }

sub reftype: Chained('/') {
    my ($self, $ctx) = @_;

    $ctx->res->body(ref $ctx);
}

sub cycle: Chained('/') {
    my ($self, $ctx) = @_;

    $ctx->stash(
        handler => sub { $ctx->action->reverse },
        context => $ctx,
        check   => $REFCHECK,
    );

    $ctx->res->body($self->refcheck);
}

sub forwarding: Chained('/') {
    my ($self, $ctx) = @_;

    $ctx->forward('forwarding_target');
}

sub forwarding_target: Action {
    my ($self, $ctx) = @_;

    $ctx->res->body(ref $ctx);
}

1;
