use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin";

use Vista::login;
use Gtk3 -init;


sub main {
    Vista::login->mostrar_login();
}

main();