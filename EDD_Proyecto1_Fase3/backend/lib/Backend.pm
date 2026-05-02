package Backend;
use Mojo::Base 'Mojolicious';
use Backend::Controlador::avl;
use Backend::Controlador::tablaHash;
use Backend::Controlador::grafo;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

sub startup {
    my $self = shift;

    $self->secrets(['EDD_2026_PROYECTO_FASE3_SECRET']);

    $self->attr(avl_usuarios => sub { Backend::Controlador::avl->new });
    $self->attr(tabla_hash_personal => sub { Backend::Controlador::tablaHash->new });
    $self->attr(grafo_colaboracion => sub { Backend::Controlador::grafo->new });

    $self->hook(before_dispatch => sub {
        my $c = shift;
        $c->res->headers->header('Access-Control-Allow-Origin' => '*');
        $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, POST, OPTIONS');
        $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type, Authorization');
        
        if ($c->req->method eq 'OPTIONS') {
            $c->render(text => '', status => 200);
        }
    });

    my $r = $self->routes;
    $r->post('/registro')->to('usuario#registrar');
    $r->post('/login')->to('usuario#login');
    $r->post('/carga-masiva')->to('usuario#procesar_carga');
    $r->get('/personal')->to('usuario#listar_personal');
}

1;