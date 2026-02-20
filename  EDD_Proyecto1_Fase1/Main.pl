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

use Controlador::RegistraMedicamento;
use constant RegistraMedicamento => 'Controlador::RegistraMedicamento';

sub main {

    my $lista_inventario = ListaDoblemente -> new();

    while (1){
        print "\n------------- Inicio de sesión -------------\n";
        print "\n1. Administrador";
        print  "\n2. Usuario departamental";
        print  "\n3. Salir\n";
        print "\nSelecccione una opción: \n";

        my $opcion_inicio = <STDIN>;
        chomp $opcion_inicio;

        my $terminar = inicio_sesion($opcion_inicio, $lista_inventario);
        last if $terminar;
    }   
}

sub inicio_sesion {
    
    my ($opcion, $lista_inventario) = @_;

    if ($opcion == 1){
        print "\n Ingrese usuario: \n";
        my $usuario_admin = <STDIN>;
        chomp $usuario_admin;

        print "\n Ingrese contraseña: \n";
        my $contrasena_admin = <STDIN>;
        chomp $contrasena_admin;
        
        if ($usuario_admin eq "admin" and $contrasena_admin eq "admin" ){
            menu_administrador($lista_inventario);
        }else{
            print "\n Usuario o contraseña incorrectos. Intente nuevamente.\n";
            return 0;
        }
    } elsif ($opcion == 2){

        #Usuario departamental quemado Nombre: "user" Contraseña: "user"

        print "\n Ingrese usuario: \n";
        my $usuario_departamental = <STDIN>;
        chomp $usuario_departamental;

        print "\n Ingrese contraseña: \n";
        my $contrasena_departamental = <STDIN>;
        chomp $contrasena_departamental;

        if ($usuario_departamental eq "user" and $contrasena_departamental eq "user" ){
            my $terminar = menu_usuario_departamental();
            return $terminar;
        }else{
            print "\n Usuario o contraseña incorrectos. Intente nuevamente.\n";
            return 0;
        }
    } elsif ($opcion == 3){
        print "\n Saliendo del programa. ¡Hasta luego!\n";
        return 1;
    } else {
        print "\n Opción inválida. Por favor, seleccione una opción válida.\n";
        return 0;
    }

}


sub menu_administrador {
    my ($lista_inventario) = @_;
    my $continuar_menu = 1;

    while ($continuar_menu) {
        print "\n------------- Administrador -------------\n";
        print "1. Registrar medicamentos\n";
        print "2. Carga masiva de medicamentos\n";
        print "3. Gestionar proveedores\n";
        print "4. Registrar entrega de proveedor\n";
        print "5. Procesar solicitudes de reabastecimiento\n";
        print "6. Visualizar inventario completo\n";
        print "7. Consultar inventario por proveedor\n";
        print "8. Cerrar Sesión\n";
        print "\nSeleccione una opción: ";

        my $opcion = <STDIN>;
        chomp $opcion;

        if ($opcion == 1) {
            print "\n--- Registrar medicamentos ---\n";
            RegistraMedicamento->registrarMedicamento($lista_inventario);
            
        } elsif ($opcion == 2) {
            print "\n-------------- Carga Masiva --------------\n";
            print "Ingrese la ruta del archivo a cargar:\n";
            my $ruta_archivo = <STDIN>;
            chomp $ruta_archivo;
            RegistraMedicamento->cargaMasiva($lista_inventario, $ruta_archivo);

            #Ruta de prueba para cargar masiva: /Volumes/Información y Archivos/Separadores cartapacios/prueba_f1.csv

        } elsif($opcion == 6){
            print "\n-------------- Visualizar Inventario --------------\n";
            $lista_inventario->imprimir();

        } elsif ($opcion == 8) {
            print "\nCerrando sesión de administrador...\n";
            $continuar_menu = 0; 

        } else {
            print "\nOpción inválida.\n";
        }
    }
    return 0; 
}

sub menu_usuario_departamental {

}

main() unless caller;