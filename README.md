Templar.nvim
============

Templar is a simple template manager for Neovim (tested on neovim 0.5), written in lua.

Quickstart
----------

To start using Templar :
    * Create a `templates` directory in `.config/nvim` directory.
    * Fill your template with the desired informations (eventually with fields, see `:h templar-fields`)
    * Register your template using `:TemplarRegister {regex}` (see `:h TemplarRegister`)
    * Edit a new file matching previously given regex
    * Templar fills everything in

More informations
-----------------

Check out `:h templar.txt` to have a more in depth overview of the plugin.
For more powerfull templates, check out `:h templar-fields`.
