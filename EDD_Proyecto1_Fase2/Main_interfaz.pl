use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin";

use Gtk3 -init;

use Vista::login;

use Controlador::bst;
use constant bst => 'Controlador::bst';
use Controlador::avl;
use constant avl => 'Controlador::avl';
use Controlador::listaCircularDoblemente;
use constant listaCircularDoblemente => 'Controlador::listaCircularDoblemente';
use Controlador::listaDoblemente;
use constant listaDoblemente => 'Controlador::listaDoblemente';

sub main {

    my $arbol_usuarios = avl->new(); #arbol para almacenar usuarios
    my $lista_proveedores = listaCircularDoblemente->new(); #lista circular para almacenar proveedores
    my $lista_medicamentos = listaDoblemente->new(); #lista circular para almacenar medicamentos
    my $arbol_equipo = bst->new(); #arbol para almacenar equipo 

    Vista::login->mostrar_login($arbol_usuarios, $lista_proveedores, $lista_medicamentos, $arbol_equipo);
}

main();