package Vista::login;

use strict;
use warnings;
use Gtk3;

sub mostrar_login {

    my $dialog = Gtk3::Dialog->new(
        'Acceso al Sistema', undef, 'modal',
        'Entrar'   => 'accept',
        'Cancelar' => 'cancel'
    );
    $dialog->set_position('center');
    $dialog->set_default_size(300, -1);

    my $content = $dialog->get_content_area();
    $content->set_spacing(10);
    $content->set_border_width(15);

    my $label_usuario = Gtk3::Label->new("Usuario:");
    $label_usuario->set_xalign(0);
    my $entry_usuario = Gtk3::Entry->new();

    my $label_contrasena = Gtk3::Label->new("Contrasena:");
    $label_contrasena->set_xalign(0);
    my $entry_contrasena = Gtk3::Entry->new();
    $entry_contrasena->set_visibility(0); 
    $entry_contrasena->set_placeholder_text("**********");

    $content->pack_start($label_usuario, 0, 0, 0);
    $content->pack_start($entry_usuario, 0, 0, 5);
    $content->pack_start($label_contrasena, 0, 0, 0);
    $content->pack_start($entry_contrasena, 0, 0, 5);
    
    $dialog->show_all();
    $dialog->run();
    $dialog->destroy();
}
1;