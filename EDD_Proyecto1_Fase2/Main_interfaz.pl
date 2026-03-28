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

sub main {

    my $arbol_usuarios = avl->new(); #arbol para almacenar usuarios

    Vista::login->mostrar_login($arbol_usuarios);
}

main();