use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use Controlador::ListaSimple;
use constant ListaSimple => 'Controlador::ListaSimple';

use Controlador::ListaCircular;
use constant ListaCircular => 'Controlador::ListaCircular';

use Controlador::ListaDoblemente;
use constant ListaDoblemente => 'Controlador::ListaDoblemente';

use Modelo::Medicamento;
use constant Medicamento => 'Modelo::Medicamento';

use Modelo::Proveedor;
use constant Proveedor => 'Modelo::Proveedor';

sub main{

    while (1){
        print "\n------------- Inicio de sesión -------------\n";
        print "\n1. Administrador\n";
        print  "\n2. Usuario departamental\n";
        print "\nSelecccione una opción: \n";

        my $opcion_inicio = <STDIN>;
        chomp $opcion_inicio;

        my $terminar = inicio_sesion($opcion_inicio);
        last if $terminar;
    }   
}

sub inicio_sesion{

}

sub menu_administrador{

    
}

sub menu_usuario_departamental{

}

main() unless caller;