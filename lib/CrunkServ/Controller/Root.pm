package CrunkServ::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

sub stylesheet : Regex('^cs\.css$') {
    my ($self, $c) = @_;
    
    $c->res->content_type('text/css');
    $c->stash->{current_view} = 'TT';
    $c->stash->{template} = 'cs.css';
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'index.tt2';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);    
}


sub end : ActionClass('RenderView') {}


1;
