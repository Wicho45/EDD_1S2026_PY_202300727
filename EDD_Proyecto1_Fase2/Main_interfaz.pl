use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin";

use Vista::login;
use Gtk3 -init;


sub main {
    my $continuar = 1;

    ## bucle principal para inicio de sesion
    while ($continuar) {
        my $opcion = Vista::login->mostrar_login();

        if ($opcion == 1) {
            print "Cargando Login...\n";
            if (Vista::login->mostrar_login()) {
                print "¡Login Correcto!\n";
            }
        } 
        else {
            print "Saliendo del programa...\n";
            $continuar = 0;
        }
    }
}

main();