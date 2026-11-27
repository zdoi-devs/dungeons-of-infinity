//remove inst from large map items
var i = ds_list_find_index(global.LargeMapItems, id);
if(i != -1) ds_list_delete(global.LargeMapItems, i);