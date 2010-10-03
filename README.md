Primary LuaDist Repository
==========================

This repository aggregates all the supported modules of the LuaDist project. Its primary purpose is to provide a manifest for modules. Modules are referenced using [git submodules][sub] and should always point to individual module repositories in the LuaDist project.

Cloning
-------

To clone the full repository:
	
	git clone git://github.com/LuaDist/Repository.git
	cd Repository
	git submodule init
	git submodule update
	
To clone individual modules you can specify the module name as follows:

	git submodule init lua
	git submodule update lua
	
Contributing
------------

1. Submit a [issue][issue] with a link to your git repository of the module.
2. A maintainer will fork the module into LuaDist grant you the rights to push changes into it.
3. The maintainer will add a submodule referencing the forked module into this LuaDist/Repository.

Call for Maintainers
--------------------

If you would like to help us maintain the repository and update modules without maintainers you are more than welcome. Please contact us at luadist-devel@lists.sourceforge.net.
