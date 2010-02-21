StatFu
======

This is a work in progress on a framework for managing statistics in Rails.


Example
=======

Examples will appear as son as the plugin is functional

Methods
=======

Instance:
  Required from the user:
    count
    check

  Added:
    count_and_check

Static:

  create
    object if saved
    false if not saved
  
  update
    object if updated
    false if found but not saved
    nil if not found
  
  create_or_update
    object if created or updated
    false if neither creted nor updated
  
  find_by_parameters
    object if found
    nil if not found


Copyright (c) 2010 Jacek Szarski (jacek@applicake.com), released under the MIT license
