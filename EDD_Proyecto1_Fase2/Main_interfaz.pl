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
use Controlador::btree;
use constant btree => 'Controlador::btree';
use Controlador::MatrizDispersa;
use constant MatrizDispersa => 'Controlador::MatrizDispersa';

sub main {

    my $arbol_usuarios = avl->new(); #arbol para almacenar usuarios
    my $lista_proveedores = listaCircularDoblemente->new(); #lista circular para almacenar proveedores
    my $lista_medicamentos = listaDoblemente->new(); #lista circular para almacenar medicamentos
    my $arbol_equipo = bst->new(); #arbol para almacenar equipo 
    my $arbol_suministros = btree->new(4); #btree para almacenar suministros
    my $matriz_proveedores_fabricantes = MatrizDispersa->new(); #matriz dispersa para relacionar proveedores y fabricantes

    Vista::login->mostrar_login($arbol_usuarios, $lista_proveedores, $lista_medicamentos, $arbol_equipo, $arbol_suministros, $matriz_proveedores_fabricantes);
}

main();