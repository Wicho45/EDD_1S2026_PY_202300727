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
        print "\n1. Administrador";
        print  "\n2. Usuario departamental";
        print  "\n3. Salir\n";
        print "\nSelecccione una opción: \n";

        my $opcion_inicio = <STDIN>;
        chomp $opcion_inicio;

        my $terminar = inicio_sesion($opcion_inicio);
        last if $terminar;
    }   
}

sub inicio_sesion{
    
    my ($opcion) = @_;

    if ($opcion == 1){
        print "\n Ingrese usuario: \n";
        my $usuario_admin = <STDIN>;
        chomp $usuario_admin;

        print "\n Ingrese contraseña: \n";
        my $contrasena_admin = <STDIN>;
        chomp $contrasena_admin;
        
        if ($usuario_admin eq "admin" and $contrasena_admin eq "admin" ){
            
            menu_administrador();
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

sub menu_administrador{
    
    my $bandera = 1;

    while ($bandera){
        print "\n------------- Administrador -------------\n";
        print "\n1. Registrar medicamentos";
        print "\n2. Cargar masiva de medicamentos";
        print "\n3. Gestionar proveedores";
        print "\n4. Registrar entrega de proveedor";
        print "\n5. Procesar solicitudes de reabastecimiento";
        print "\n6. Visualizar inventario completo";
        print "\n7. Consultar inventario por proveedor";
        print "\n8. Salir\n";
        print "\nSelecccione una opción: \n";

        my $opcion_administrador = <STDIN>;
        chomp $opcion_administrador;

        if ($opcion_administrador == 1){

        } elsif ($opcion_administrador == 8){
            print "\n Saliendo del programa. ¡Hasta luego!\n";
            $bandera = 0;
        } else {
            print "\n Opción inválida. Por favor, seleccione una opción válida.\n";
            $bandera = 1;
        }
    }

    return 0;

}

sub menu_usuario_departamental{

}

main() unless caller;