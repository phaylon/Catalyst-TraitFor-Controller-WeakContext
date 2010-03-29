#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use Test::Most;

use lib "$FindBin::Bin/lib";
use Catalyst::Test 'TestApp';

is get('/reftype'), 'Object::WeakProxy::Instance', 'passed context is a weak proxy';

is get('/cycle'), 2, 'control reference has refcount of 2';
is +TestApp::Controller::Foo->refcheck, 1, 'control reference refcount back to 1';

is get('/forwarding'), 'Object::WeakProxy::Instance', 'forwarding target received proxied context';

done_testing;
